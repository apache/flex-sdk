/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package macromedia.asc.semantics;

import macromedia.asc.util.*;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.MetaDataNode;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import static macromedia.asc.util.BitSet.*;
import static macromedia.asc.parser.Tokens.*;

/**
 * A slot gives a compile-time description of an operation.
 * This includes:
 * - type of the resulting value
 * - expected types of the operands
 * - var_index if used to access a particular variable
 * - objValue, value, or intValue if used to store a constant value
 * - method_id if used to identify a native method or operation
 * - call_seq used to invoke
 *
 * @author Jeff Dyer
 */
public abstract class Slot
{
	public static final int PUSH_none = 0;
	public static final int PUSH_env = 0x1 << 0;
	public static final int PUSH_this = 0x1 << 1;
	public static final int PUSH_opd1 = 0x1 << 2;
	public static final int PUSH_opd2 = 0x1 << 3;
	public static final int PUSH_args = 0x1 << 4;
	public static final int PUSH_size = 0x1 << 5;

	/*
	 * Call sequences.
	 */

	public static final int CALL_Empty = PUSH_none;
	public static final int CALL_Unary = PUSH_opd1 | PUSH_args;
	public static final int CALL_ThisUnary = PUSH_this | PUSH_opd1 | PUSH_args;
	public static final int CALL_Binary = PUSH_opd1 | PUSH_opd2;
	public static final int CALL_Method = PUSH_args;
	public static final int CALL_ThisMethod = PUSH_this | PUSH_args;
	public static final int CALL_Closure = PUSH_env | PUSH_this | PUSH_args | PUSH_size;

    public static final int CALL_Args       = PUSH_args;
    public static final int CALL_ThisArgs   = PUSH_this | PUSH_args;
    public static final int CALL_EnvThisArgs= PUSH_env  | PUSH_this | PUSH_args | PUSH_size;

	public static final int DISPATCH_final = 0;
	public static final int DISPATCH_virtual = 1;

    public static final int DISP_undefined = DISPATCH_virtual; // DISPATCH_virtual is unused
    public static final int DISP_CallProperty = DISP_undefined+1;
    public static final int DISP_ConstructProperty = DISP_CallProperty+1;
    public static final int DISP_CallClosure = DISP_ConstructProperty+1;
    public static final int DISP_ConstructClosure = DISP_CallClosure+1;
    public static final int DISP_CallPropLex = DISP_ConstructClosure+1;
    public static final int DISP_CallFinal = DISPATCH_final;  // to minimize disruption, scheduled for removal

    public static final int THIS_undefined = 0;
    public static final int THIS_Global = THIS_undefined+1;
    public static final int THIS_Scope = THIS_Global+1;
    public static final int THIS_Base = THIS_Scope+1;
    public static final int THIS_Temp = THIS_Base+1;
    public static final int THIS_None = THIS_Temp+1;

    // for function call type checking, distinguish between required, optional, and rest parameters (and void for no params)
    public static final int PARAM_Required = 0;
    public static final int PARAM_Optional = PARAM_Required+1;
    public static final int PARAM_Rest = PARAM_Optional+1;
    public static final int PARAM_Void = PARAM_Rest+1;

    private static final int FINAL_Flag               = 1;
    private static final int OVERRIDE_Flag            = 2;
    private static final int CONST_Flag               = 4;
    private static final int IMPORTED_Flag            = 8;
    private static final int INTRINSIC_Flag           = 16;
    private static final int NEEDS_INIT_Flag          = 32;
    private static final int METHOD_Flag              = 64; // used to distinguish between getters and methods

    private static final int CALL_SEQUENCE_Mask       = 0x0000FF00;
    private static final int DISPATCH_KIND_Mask       = 0x00FF0000;
    private static final int CALL_SEQUENCE_Shift      = 8;
    private static final int DISPATCH_KIND_Shift      = 16;   
    
    private int flags = OVERRIDE_Flag;

    protected static final int AUX_OverriddenSlot       = 0;
    protected static final int AUX_EmbeddedData         = 1;
    protected static final int AUX_MetaData             = 2;
    protected static final int AUX_BaseNode             = 3;
    protected static final int AUX_ImplNode             = 4;
    protected static final int AUX_UnaryOverloads       = 5;
    protected static final int AUX_BinaryOverloads      = 6;
    protected static final int AUX_DebugName            = 7;
    protected static final int AUX_ImplicitCall         = 8;
    protected static final int AUX_ImplicitConstruct    = 9;
    protected static final int AUX_MethodName           = 10;
    
	private Object[] auxDataItems = null;
	public int id;
	public ObjectValue declaredBy;
	private BitSet def_bits;
	private Value value;
    private TypeInfo type;
	private ObjectList<TypeInfo> types;
    private byte version = 0;

    protected final void setAuxData(int type, Object value)
	{
		if (auxDataItems != null)
		{
			for (int i=0; i<auxDataItems.length; i+=2)
			{
				if (((Integer)auxDataItems[i]).intValue() == type)
				{
					auxDataItems[i+1] = value;
					return;
				}
			}
		}
		Object[] newData;
		if (auxDataItems != null)
		{
			newData = new Object[auxDataItems.length+2];
			System.arraycopy(auxDataItems, 0, newData, 0, auxDataItems.length);
		}
		else
		{
			newData = new Object[2];
		}
		newData[newData.length-2] = IntegerPool.getNumber(type);
		newData[newData.length-1] = value;
		
		auxDataItems = newData;
	}
	
	protected final Object getAuxData(int type)
	{
		if (auxDataItems != null)
		{
			for (int i=0; i<auxDataItems.length; i+=2)
			{
				if (((Integer)auxDataItems[i]).intValue() == type)
				{
					return auxDataItems[i+1];
				}
			}				
		}
		return null;
	}

    public Slot(TypeValue type, int id)
    {
        this(type!=null?type.getDefaultTypeInfo():null, id);
    }
    
	public Slot(TypeInfo type, int id)
	{		
		this.type = type;
		this.id = id;
		
		this.setCallSequence(CALL_ThisUnary);
		this.setDispatchKind(DISPATCH_final);
		
		//Node.tally(this);
		
		/* This is redundant -- Java automatically does this
		embeddedData = null;
		def_bits = null;
		inheritedSlot = null;
		base_node = null;
		impl_node = null;
		is_const = false;
		*/
	}

	public final boolean isCompatible(TypeValue t1, TypeValue t2)
	{
		return t1 != null && t2 != null && (t1.getTypeId() & t2.getTypeId()) != 0;
	}

	public final void addDefBits(BitSet mask)
	{
		setDefBits(set(getDefBits(), mask));
	}

	// The set of implicit methods used to be a HashMap.  This is overkill
	// because there are tons of implicit methods over the course of a
	// compile, but any particular slot will have a very low number of
	// implicit methods by itself.  So, a simple int[] array with a linear
	// search really should suffice, and saves a lot of memory.
	public final void implicit(int kind, int slot_index)
	{		
		switch (kind)
		{
		case EMPTY_TOKEN:
			setAuxData(AUX_ImplicitCall, IntegerPool.getNumber(slot_index));
			break;
		case NEW_TOKEN:
			setAuxData(AUX_ImplicitConstruct, IntegerPool.getNumber(slot_index));
			break;
		default:
			assert false;
		}
	}

	public final int implies(Context cx, int kind)
	{
		Integer value = null;
		switch (kind)
		{
		case EMPTY_TOKEN:
			value = (Integer)getAuxData(AUX_ImplicitCall);
			break;
		case NEW_TOKEN:
			value = (Integer)getAuxData(AUX_ImplicitConstruct);
			break;
		default:
			assert false;
			break;
		}
		return (value != null) ? value.intValue() : 0;
	}

	public final void overload(TypeValue t1, int slot_index)
	{
		Overload unary_overloads = getUnaryOverloads();
		if (unary_overloads == null)
		{
			unary_overloads = new Overload();
			setUnaryOverloads(unary_overloads);
		}
		unary_overloads.put(t1, slot_index);
	}

	public final void overload(TypeValue t1, TypeValue t2, int slot_index)
	{
		Overload o = new Overload();
		o.put(t2, slot_index);
		Map<TypeValue, Overload> binary_overloads = getBinaryOverloads();
		if (binary_overloads == null)
		{
			binary_overloads = new HashMap<TypeValue, Overload>();
			setBinaryOverloads(binary_overloads);
		}
		binary_overloads.put(t1, o);
	}

	public final int dispatch(Context cx, TypeValue t1)
	{
		boolean found = false;
		int value = 0;
		// IntList found = new IntList();

		Overload unary_overloads = getUnaryOverloads();
		if (unary_overloads != null)
		{
			for (TypeValue t : unary_overloads.keySet())
			{
				// C: t.equals(t1) or t == t1??
				if (t.equals(t1))
				{
					return unary_overloads.get(t);
				}
				else if (isCompatible(t, t1))
				{
					if (!found)
					{
						found = true;
						value = unary_overloads.get(t);
						// found.add(unary_overloads.get(t));
					}
					else
					{
						return 0;
					}
				}
			}
		}

		return value;
		/*
		if (found.size() == 1)
		{
			return found.get(0);
		}
		else
		{
			return 0;
		}
		*/
	}

	public final int dispatch(Context cx, TypeValue t1, TypeValue t2)
	{
		Map<TypeValue, Overload> binary_overloads = getBinaryOverloads();
		if (binary_overloads != null)
		{
			for (TypeValue i : binary_overloads.keySet())
			{
				if (i == null || t1 == null)
				{
					cx.internalError("internal type error");
				}

				if (isCompatible(i, t1))
				{
					Overload overload = binary_overloads.get(i);
					for (TypeValue j : overload.keySet())
					{
						if (isCompatible(j, t2))
						{
							return overload.get(j);
						}
					}
				}
			}
		}

		Overload o = (binary_overloads == null) ? null : binary_overloads.get(t1);
		if (o == null)
		{
			o = new Overload();
			o.put(t2, 0);
			if (binary_overloads == null)
			{
				binary_overloads = new HashMap<TypeValue, Overload>();
				setBinaryOverloads(binary_overloads);
			}
			binary_overloads.put(t1, o);
		}
		else if (o.get(t2) == null)
		{
			o.put(t2, 0);
		}

		return binary_overloads.get(t1).get(t2);
	}

	public final void attrs(int call_seq, int method_id)
	{
		this.setCallSequence((byte)call_seq);
		this.setMethodID(method_id);
	}

    public final void addMetadata(MetaDataNode meta)
    {
        addMetadata(meta.getMetadata());
    }

    public final void addMetadata(MetaData meta)
    {
        if( meta == null )
            return;
        if( getMetadata() == null )
        {
            setMetadata(new ArrayList<MetaData>());
        }
        getMetadata().add(meta);
    }

	public final boolean isFinal()
	{
		return (flags & FINAL_Flag) != 0;
	}

	public final void setFinal(boolean is_final)
	{
		flags = is_final ? (flags | FINAL_Flag) : (flags & ~FINAL_Flag);
	}

	public final boolean isOverride()
	{
		return (flags & OVERRIDE_Flag) != 0;
	}

	public final void setOverride(boolean is_override)
	{
		flags = is_override ? (flags | OVERRIDE_Flag) : (flags & ~OVERRIDE_Flag);
	}

	public final boolean isConst()
	{
		return (flags & CONST_Flag) != 0;
	}

	public final void setConst(boolean is_const)
	{
		flags = is_const ? (flags | CONST_Flag) : (flags & ~CONST_Flag);
	}

	public final boolean isImported()
	{
		return (flags & IMPORTED_Flag) != 0;
	}

	public final void setImported(boolean is_imported)
	{
		flags = is_imported ? (flags | IMPORTED_Flag) : (flags & ~IMPORTED_Flag);
	}

	public final boolean isIntrinsic()
	{
		return (flags & INTRINSIC_Flag) != 0;
	}

    public final boolean needsInit()
    {
        return (flags & NEEDS_INIT_Flag) != 0;
    }

    public final void setNeedsInit(boolean needs_init)
    {
		flags = needs_init ? (flags | NEEDS_INIT_Flag) : (flags & ~NEEDS_INIT_Flag);
	}

	public final void setIntrinsic(boolean is_intrinsic)
	{
		flags = is_intrinsic ? (flags | INTRINSIC_Flag) : (flags & ~INTRINSIC_Flag);
	}
	
	public final int getCallSequence()
	{
		return (flags & CALL_SEQUENCE_Mask) >> CALL_SEQUENCE_Shift;
	}

	public final void setCallSequence(int call_seq)
	{
		flags &= ~CALL_SEQUENCE_Mask;
		flags |= (call_seq << CALL_SEQUENCE_Shift);
	}

	public final int getDispatchKind()
	{
		return (flags & DISPATCH_KIND_Mask) >> DISPATCH_KIND_Shift;
	}

	public final void setDispatchKind(int dispatch_kind)
	{
		flags &= ~DISPATCH_KIND_Mask;
		flags |= (dispatch_kind << DISPATCH_KIND_Shift);
	}

	final class Overload extends HashMap<TypeValue, Integer>
	{
	}
	
	// for packages
	public final void setBaseNode(Node base_node)
	{
		setAuxData(AUX_BaseNode, base_node);
	}
	
	public final Node getBaseNode()
	{
		return (Node)getAuxData(AUX_BaseNode);
	}

	// for interfaces
	public final void setImplNode(Node impl_node)
	{
		setAuxData(AUX_ImplNode, impl_node);
	}

	public final Node getImplNode()
	{
		return (Node)getAuxData(AUX_ImplNode);
	}

	//metadata associated with this slot	
	public final void setMetadata(ArrayList<MetaData> metadata)
	{
		setAuxData(AUX_MetaData, metadata);
	}

	public final ArrayList<MetaData> getMetadata()
	{
		return (ArrayList<MetaData>)getAuxData(AUX_MetaData);
	}

	//compiler host can add custom data here
	public final void setEmbeddedData(Object embeddedData)
	{
		setAuxData(AUX_EmbeddedData, embeddedData);
	}

	public final Object getEmbeddedData()
	{
		return getAuxData(AUX_EmbeddedData);
	}

	public final void setOverriddenSlot(Slot overriddenSlot)
	{
		setAuxData(AUX_OverriddenSlot, overriddenSlot);
	}

	public final Slot getOverriddenSlot()
	{
		return (Slot)getAuxData(AUX_OverriddenSlot);
	}

	private final void setUnaryOverloads(Overload unary_overloads)
	{
		setAuxData(AUX_UnaryOverloads, unary_overloads);
	}

	private final Overload getUnaryOverloads()
	{
		return (Overload)getAuxData(AUX_UnaryOverloads);
	}

	private final void setBinaryOverloads(Map<TypeValue, Overload> binary_overloads)
	{
		setAuxData(AUX_BinaryOverloads, binary_overloads);
	}

	private final Map<TypeValue, Overload> getBinaryOverloads()
	{
		return (Map<TypeValue, Overload>)getAuxData(AUX_BinaryOverloads);
	}

	public final void setObjectValue(ObjectValue objectValue)
	{
		this.setValue(objectValue);
	}

	public final ObjectValue getObjectValue()
	{
		return (ObjectValue)getValue();
	}

    public ObjectValue getInitializerValue()
    {
        return (ObjectValue)getValue();
    }

	public void setDebugName(String debug_name)
	{
		setAuxData(AUX_DebugName, debug_name);
	}

	public String getDebugName()
	{
		String value = (String)getAuxData(AUX_DebugName);
		return (value != null) ? value : "";
	}
	
	public boolean isGetter()
	{
		return (flags & METHOD_Flag) == 0;
	}
	
	public void setGetter(boolean isGetter)
	{
		flags = !isGetter ? (flags | METHOD_Flag) : (flags & ~METHOD_Flag);
	}

	public abstract void setVarIndex(int var_index);
	public abstract int getVarIndex();

	public abstract void setMethodID(int method_id);
	public abstract int getMethodID();

	public abstract void setMethodName(String method_name);
	public abstract String getMethodName();

	public abstract void setTypeRef(ReferenceValue typeref);
	public abstract ReferenceValue getTypeRef();
	public abstract void setDeclStyles(ByteList decl_styles);
	public abstract ByteList getDeclStyles();

	public abstract void addDeclStyle(int style);	

	public void setType(TypeInfo type)
	{
		this.type = type;
	}

	public TypeInfo getType()
	{
		return type;
	}

	public void setTypes(ObjectList<TypeInfo> types)
	{
		this.types = types;
	}

	public ObjectList<TypeInfo> getTypes()
	{
		return types;
	}

	public void addType(TypeInfo type)
	{
		if (types == null)
			types = new ObjectList<TypeInfo>(2);
		types.push_back(type);
	}

	public void setValue(Value value)
	{
		this.value = value;
	}

	public Value getValue()
	{
		return value;
	}

	public void setDefBits(BitSet def_bits)
	{
		this.def_bits = def_bits;
	}

	public BitSet getDefBits()
	{
		return def_bits;
	}

    public void setVersion(byte version)
    {
        this.version = version;
    }

    public byte getVersion()
    {
        return this.version;
    }
}
