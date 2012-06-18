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

import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.*;
import static macromedia.asc.semantics.Slot.*;

/**
 *  A builder has two jobs to initialize a compile-time value (build()), and to
 *  add and remove properties from a value (ExplicitVar, etc).
 *
 *  Different builders know how to create properties on different kinds of
 *  objects. That is, each builder has a lexical context in which it is used.
 *
 *  Builders and their contexts
 *  ---------------------------
 *  ActivationBuilder - parameters
 *  BlockBuilder - local block
 *  ClassBuilder - class statics
 *  InstanceBuilder - class non-statics
 *  GlobalBuilder - global scope
 *  PackageBuilder - package scope
 *
 *  Builders added properties to object values according to the meaning of
 *  various add actions in the builder's context. The actions are:
 *
 *  Variable       - add a variable slot
 *  Method         - add a method slot
 *  ExplicitVar    - add a named variable
 *  ImplicitVar    - add an unnamed variable (e.g. method closure)
 *  ExplicitGet    - add a named get accessor
 *  ImplicitGet    - add an unnamed get accessor
 *  ExplicitCall   - add a named method
 *  ImplicitCall   - add an unamed method, refrenced from an explicit trait
 *  UnaryOperator  - add a unary operator
 *  UnaryOverload  - add a unary operator that overloads a more generic unary operator
 *  BinaryOperator - add a binary operator
 *  BinaryOverload - add a binary operator that overloads a more generic binary operator
 *
 *  Variable and Method actions allocate a variable and method slot in either
 *  the local or global frames depending on the builder. The Explicit/Implicit
 *  actions add traits that reference a variable or method slot, to the object
 *
 *  var_offset indicates the meaning of the 0th var_index in this context. E.g.
 *  In an activation object, var_offset = 1 to allow for 'this'. In a derived
 *  instance object, var_offset might be 4 indicating that their are 4 instance
 *  variable in the base class, so the 0th variable in the current class would
 *  be at slot 4.
 *
 * @author Jeff Dyer
 */

public abstract class Builder
{
	/*
	 * TODO: {pmd} I cant be sure, but I'd guess that removeBuilderNames was a temporary hack put in while shifting the names table from
	 * here to ObjectValue, once someone verifies this, all references should be removed. It is an unclear thing to leave lying around.
	 */
	public static final boolean removeBuilderNames = true;
	
	protected Builder()
	{
		//macromedia.asc.parser.Node.tally(this);
	}
	
	protected ObjectValue objectValue;
	// context I was defined in
	public int contextId;

	private Names names; // only used when !removeBuilderNames
	
	public QName classname;
	public String pkgname = "";

	public int var_offset;
	public int method_offset;
    public int method_count;
	public int reg_offset;
	public int temp_reg = -1;
    public boolean is_intrinsic;
    public boolean is_dynamic;
    public boolean is_final;
    
	public abstract void build(Context cx, ObjectValue ob);
 
	public void addNames(Names names) 
	{
		if (names != null)
		{
			getNamesAndCreate().putAll(names);
		}
	}
	
	public Names getNames()
	{
		return removeBuilderNames ? objectValue.getNames() : names;
	}
	
	private Names getNamesAndCreate()
	{
		if(removeBuilderNames)
			return objectValue.getNamesAndCreate();
		else {
			if(names == null)
				names = new Names();
			return names;
		}			
	}
	
	public void clearNames()
	{
		if(!removeBuilderNames)
			names = null;
	}


	// Builder helpers

	public void UnaryOperator(Context cx, ObjectValue ob, TypeValue type, int call_seq, int slot_id)
	{
		cx.statics.pushExpectedSlotID(slot_id);

		CHECK_SLOT_INDEX(slot_id, ob.addMethodSlot(cx, type));
		ob.getSlot(cx, slot_id).attrs(call_seq, getUnaryOp(slot_id));
	}

	public void UnaryOverload(Context cx, ObjectValue ob, int slot_id, TypeValue type, TypeValue opd_type, int call_seq, int over_id)
	{
		cx.statics.pushExpectedSlotID(over_id);

		CHECK_SLOT_INDEX(over_id, ob.addSlotOverload(cx, slot_id, type, opd_type));
		ob.getSlot(cx, over_id).attrs(call_seq, getUnaryOp(over_id));
	}

	public void BinaryOperator(Context cx, ObjectValue ob, TypeValue type, int slot_id)
	{
		cx.statics.pushExpectedSlotID(slot_id);
		
		CHECK_SLOT_INDEX(slot_id, ob.addMethodSlot(cx, type));
		ob.getSlot(cx, slot_id).attrs(Slot.CALL_Binary, getBinaryOp(slot_id));
	}

	public void BinaryOverload(Context cx, ObjectValue ob, int slot_id, TypeValue type, TypeValue lhs_type, TypeValue rhs_type, int over_id)
	{
		cx.statics.pushExpectedSlotID(over_id);

		CHECK_SLOT_INDEX(over_id, ob.addSlotOverload(cx, slot_id, type, lhs_type, rhs_type));
		ob.getSlot(cx, over_id).attrs(Slot.CALL_Binary, getBinaryOp(over_id));
	}

	public int ExplicitGet(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override, int expected_id)
	{
		return ExplicitGet(cx, ob, name, ns, type, is_final, is_override, expected_id, -1, -1);
	}

	public int ExplicitGet(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override)
	{
		return ExplicitGet(cx, ob, name, ns, type, is_final, is_override, -1, -1, -1);
	}

	public int ExplicitGet(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id)
	{
		int slot_id = ob.addMethodSlot(cx, type);
		CHECK_SLOT_INDEX(expected_id, slot_id);
		ob.defineName(cx, GET_TOKEN, name, ns, slot_id);
		ob.getSlot(cx, slot_id).attrs(Slot.CALL_ThisMethod, method_id);

		if(!Builder.removeBuilderNames)
		{
			if (method_id >= 0)
			{
				Name(cx, GET_TOKEN, name, ns);
			}
		}
		return slot_id;
	}

	public int ExplicitGet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override)
	{
		return ExplicitGet(cx, ob, name, namespaces, type, is_final, is_override, -1, -1, -1);
	}

	public int ExplicitGet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id , int method_id , int var_id  )
	{
		int slot_id = ob.addMethodSlot(cx,type);
		CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineNames(cx,GET_TOKEN,name,namespaces,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);

		// do backend binding

		if(!Builder.removeBuilderNames)
		{
			if( method_id >= 0 )
			{
				for (ObjectValue n : namespaces)
				{
					Name(cx, GET_TOKEN, name,n);
				}
			}
		}

		return slot_id;
	}

	public int ExplicitSet(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override,int expected_id)
	{
		return ExplicitSet(cx, ob, name, ns, type, is_final, is_override,expected_id, -1, -1);
	}

	public int ExplicitSet(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override,int expected_id, int method_id)
	{
		return ExplicitSet(cx, ob, name, ns, type,  is_final, is_override,expected_id, method_id, -1);
	}

	public int ExplicitSet(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id)
	{
		int slot_id = ob.addMethodSlot(cx, type);
		CHECK_SLOT_INDEX(expected_id, slot_id);
		ob.defineName(cx, SET_TOKEN, name, ns, slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);

		if(!Builder.removeBuilderNames)
		{
			if( method_id >= 0 )
			{
				Name(cx,SET_TOKEN,name,ns);
			}
		}

		return slot_id;
	}

	public int ExplicitSet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id)
	{
		return ExplicitSet(cx, ob, name, namespaces, type, is_final, is_override, expected_id, -1, -1);
	}

	public int ExplicitSet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id , int var_id )
	{
		int slot_id = ob.addMethodSlot(cx,type);
		CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineNames(cx,SET_TOKEN,name,namespaces,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);

		// do backend binding

		if(!Builder.removeBuilderNames)
		{
			if( method_id >= 0 )
			{
				for (ObjectValue n : namespaces)
				{
					Name(cx,SET_TOKEN,name,n);
				}
			}
		}

		return slot_id;
	}

	public int ExplicitVar(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, int expected_id)
	{
		return ExplicitVar(cx, ob, name, ns, type, expected_id, -1, -1);
	}

	public int ExplicitVar(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, int expected_id, int method_id, int var_id)
	{
		int slot_id = ob.addVariableSlot(cx, type, var_id);
		ob.getSlot(cx, slot_id).addType(type.getDefaultTypeInfo());
		CHECK_SLOT_INDEX(expected_id, slot_id);
		ob.defineName(cx, GET_TOKEN, name, ns, slot_id);		
		ob.defineName(cx, SET_TOKEN, name, ns, slot_id);
		ob.getSlot(cx, slot_id).attrs(Slot.CALL_ThisMethod, method_id);

		if ( var_id >= 0 )
		{
			Name(cx, VAR_TOKEN, name, ns);
		}
		
		return slot_id;
	}

	public int ExplicitVar( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, int expected_id)
	{
		return ExplicitVar(cx, ob, name, namespaces, type, expected_id, -1, -1);
	}

	public int ExplicitVar( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, int expected_id, int method_id, int var_id  )
	{
		int slot_id = ob.addVariableSlot(cx,type,var_id);
        ob.getSlot(cx, slot_id).addType(type.getDefaultTypeInfo());
        CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineNames(cx,GET_TOKEN,name,namespaces,slot_id);		
		ob.defineNames(cx,SET_TOKEN,name,namespaces,slot_id);
		ob.getSlot(cx,slot_id).attrs(CALL_ThisMethod,method_id);

		// do backend binding

		if( var_id >= 0 )
		{
			for (ObjectValue n : namespaces)
			{
				Name(cx, VAR_TOKEN, name, n);
			}
		}	

		return slot_id;
	}

	public int ImplicitVar(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, int expected_id)
	{
		return ImplicitVar(cx, ob, name, ns, type, expected_id, -1, -1);
	}

	public int ImplicitVar(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, int expected_id, int method_id, int var_id)
	{
		cx.statics.pushExpectedSlotID(expected_id);
		
		int slot_id = ob.addVariableSlot(cx, type, var_id);
		CHECK_SLOT_INDEX(expected_id, slot_id);
		ob.defineName(cx, GET_TOKEN, name, ns, slot_id);
		ob.defineName(cx, SET_TOKEN, name, ns, slot_id);
		ob.getSlot(cx, slot_id).attrs(Slot.CALL_ThisMethod, method_id);

		return slot_id;		
	}

	public void ImplicitCall(Context cx, ObjectValue ob, int slot_id, TypeValue type, int call_seq, int method_id, int expected_id)
	{
		cx.statics.pushExpectedSlotID(expected_id);

		int implied_id = ob.addSlotImplicit(cx, slot_id, EMPTY_TOKEN, type);
		CHECK_SLOT_INDEX(expected_id, implied_id);
		ob.getSlot(cx, implied_id).attrs(call_seq, method_id);
		ob.getSlot(cx, implied_id).setGetter(false);
	}

	public int ExplicitCall(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override,  int expected_id)
	{
		return ExplicitCall(cx, ob, name, ns, type, is_final, is_override, expected_id, -1, -1);
	}

	public int ExplicitCall(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id)
	{
		TypeValue functionType = cx.useStaticSemantics() ? cx.functionType() : type;
		int slot_id = ob.addMethodSlot(cx, functionType);
		CHECK_SLOT_INDEX(expected_id, slot_id);
		ob.defineName(cx, EMPTY_TOKEN, name, ns, slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		ob.getSlot(cx,slot_id).attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);
		slot.setGetter(false);

		// do backend binding
		Name(cx,EMPTY_TOKEN,name,ns);

		return slot_id;
	}

	public int ExplicitCall( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id , int var_id )
	{
		TypeValue functionType = cx.useStaticSemantics() ? cx.functionType() : type;
		int slot_id = ob.addMethodSlot(cx,functionType);
		CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineNames(cx,GET_TOKEN,name,namespaces,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		ob.getSlot(cx,slot_id).attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);
		slot.setGetter(false);

		// do backend binding

		if( method_id >= 0 )
		{
			for (ObjectValue n : namespaces)
			{
				Name(cx, EMPTY_TOKEN, name, n);
			}
		}

		return slot_id;
	}

	public void ImplicitConstruct(Context cx, ObjectValue ob, int slot_id, TypeValue type, int call_seq, int method_id, int expected_id)
	{
        int implied_id = ob.addSlotImplicit(cx,slot_id,NEW_TOKEN,type);
        CHECK_SLOT_INDEX(expected_id,implied_id);
		ob.getSlot(cx, implied_id).attrs(call_seq, method_id);
		ob.getSlot(cx, implied_id).setGetter(false);
	}

	public int Variable(Context cx, ObjectValue ob)
	{
		return ob.addVar(cx);
	}

	public int Method(Context cx, ObjectValue ob, String name, Namespaces namespaces, boolean is_intrinsic)
	{
		if (this.is_intrinsic || is_intrinsic)
		{
			return -1;
		}

		return cx.getEmitter().GetMethodId(name,namespaces);
	}

    public int local_method_count;

	/*
	GetMethodId translates the name of a method into an index of the local
	method table. This mapping is different than is used for lookup.
	*/

    /*
    GetMethodId translates the name of a method into an index of the local
    method table.  This mapping is different than is used for lookup
    */

    public int GetMethodId(Context cx, String name, Namespaces namespaces)
    {
		if(getNames() != null)
		{
        	for (ObjectValue ns : namespaces)
        	{
        		if(!Builder.removeBuilderNames)
        		{
            		// old way
        			int index = getNames().get(name, ns, Names.LOCAL_METHOD_NAMES);
        			if(index != -1)
        				return index;
        		} 
        		else 
        		{
        			// new way
	        		int slot_id = objectValue.getSlotIndex(cx, GET_TOKEN, name, ns);
	        		if(slot_id > 0)
	        		{
		        		Slot s = objectValue.getSlot(cx, slot_id);
		        		if(s.getMethodID() != -1 && s.declaredBy == objectValue)
		        		{
		        			return s.getMethodID();
		        		}
	        		}
        		}
	        }
        }

        // We have a new name, so count it
        ++local_method_count;

        if(!Builder.removeBuilderNames)
        {
	        // Add each namespace to the qualifiers map
	        for (ObjectValue ns : namespaces)
	        {
	        	getNamesAndCreate().putMask(name, ns, Names.LOCAL_METHOD_NAMES);
	        }
        }
        
        return local_method_count;
    }

	public void Name(Context cx, int kind, String name, ObjectValue qualifier)
	{		
		int type = Names.getTypeFromKind(kind);
		
		if(Builder.removeBuilderNames && (type == Names.METHOD_NAMES || type == Names.VAR_NAMES))
			return;
	
		// Add the qualifier to the qualifiers map, and set its value to index.
		getNamesAndCreate().putMask(name, qualifier, type);
	}
	

	public final void CHECK_SLOT_INDEX(int a, int b)
	{
		if (a != -1 && a != b)
		{
			assert(false); // throw "Slot out of sync.";
		}
	}
	
    public void InheritCall(Context cx, ObjectValue ob, String name, ObjectValue ns, Slot explicitSlot, Slot implicitSlot)
    {
    	ob.addSlot(explicitSlot);
    	ob.addSlot(implicitSlot);
    	ob.defineName(cx, GET_TOKEN, name, ns, explicitSlot.id);
    	Name(cx, GET_TOKEN, name, ns);    	
    	Name(cx, EMPTY_TOKEN, name, ns);    	
    }

    public void InheritGet(Context cx, ObjectValue ob, String name, ObjectValue ns, Slot slot)
    {
    	ob.addSlot(slot);
    	ob.defineName(cx, GET_TOKEN, name, ns, slot.id);
    	Name(cx, GET_TOKEN, name, ns);    	
    }

    public void InheritSet(Context cx, ObjectValue ob, String name, ObjectValue ns, Slot slot)
    {
    	ob.addSlot(slot);
    	ob.defineName(cx, SET_TOKEN, name, ns, slot.id);
    	Name(cx, SET_TOKEN, name, ns);    	
    }	

    public void InheritVar(Context cx, ObjectValue ob, String name, ObjectValue ns, Slot slot)
    {
    	ob.addSlot(slot);
    	ob.defineName(cx, GET_TOKEN, name, ns, slot.id);
    	ob.defineName(cx, SET_TOKEN, name, ns, slot.id);    	

		if (slot.getVarIndex() >= 0)
		{
			Name(cx, VAR_TOKEN, name, ns);
		}    	
    }
    
    public boolean hasRegisterOffset() { return true; }
}
