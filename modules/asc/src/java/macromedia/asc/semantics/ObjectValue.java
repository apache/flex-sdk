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

import macromedia.asc.util.Context;
import macromedia.asc.util.IntList;
import macromedia.asc.util.Names;
import macromedia.asc.util.Namespaces;
import macromedia.asc.util.ObjectList;
import macromedia.asc.util.Qualifiers;
import macromedia.asc.util.Slots;
import macromedia.asc.util.NumberUsage;
import macromedia.asc.parser.ClassDefinitionNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.Tokens;
import macromedia.asc.embedding.avmplus.ClassBuilder;
import macromedia.asc.embedding.avmplus.InstanceBuilder;

import java.util.HashMap;
import java.util.Comparator;

/*
 * This class is the building block for all ECMA values. Object values
 * are a sequence of instances linked through the [[Prototype]] slot.
 * Classes are a sequence of instances of the sub-class TypeValue, also
 * linked through the [[Prototype]] slot. Lookup of class and instance
 * properties uses the same algorithm to find a name. Names are bound
 * to slots. Slots contain values that are methods for accessing or
 * computing program values (i.e running code.)
 *
 * An object consists of a table of names, and a vector of slots. The
 * slots hold methods for accessing and computing values. An object
 * also has a private data accessible to the methods and accessors of
 * the object.
 *
 * All symbolic references to the properties of an object are bound
 * to the method of a slot. Constant references to fixed, final prop-
 * erties can be compiled to direct access of the data value. This
 * is the case with access to private, final or global variables.
 *
 * The instance and class hierarchies built at compile-time can be
 * compressed into a single instance prototype and class object for
 * faster lookup and dispatch.
 */

public class ObjectValue extends Value implements Comparable
{
    static final String EMPTY_STRING = "".intern();

    public static void NamespacesFromQualifiers(Qualifiers quals,Namespaces namespaces)
    {
        namespaces.clear();
        for (ObjectValue it : quals.keySet())
        {
            namespaces.push_back(it);
        }
    }

    public static ObjectValue undefinedValue;
    public static ObjectValue nullValue;
    public static ObjectValue enumerableNamespace;
    public static ObjectValue labelNamespace;
    public static ObjectValue loopLabelNamespace;
    public static ObjectValue objectPrototype;
    public static ObjectValue internalNamespace;
    public static ObjectValue intrinsicAttribute;
    public static ObjectValue intrinsicNamespace;
    public static ObjectValue staticAttribute;
    public static ObjectValue dynamicAttribute;
    public static ObjectValue finalAttribute;
    public static ObjectValue virtualAttribute;
    public static ObjectValue overrideAttribute;
    public static ObjectValue nativeAttribute;


    /* Initialize and finalize the class.
     */
    public static void init()
    {
        if (undefinedValue == null)
        {
            undefinedValue = new ObjectValue();
            nullValue = new ObjectValue();
            enumerableNamespace = new ObjectValue();

            labelNamespace = new NamespaceValue(Context.NS_PRIVATE);
            labelNamespace.name = "label namespace";
            loopLabelNamespace = new NamespaceValue(Context.NS_PRIVATE);
            loopLabelNamespace.name = "loop label namespace name";

            objectPrototype = new ObjectValue();
            internalNamespace = new ObjectValue();
            intrinsicAttribute = new ObjectValue();
            intrinsicNamespace = new ObjectValue();
            staticAttribute = new ObjectValue();
            dynamicAttribute = new ObjectValue();
            finalAttribute = new ObjectValue();
            virtualAttribute = new ObjectValue();
            overrideAttribute = new ObjectValue();
            nativeAttribute = new ObjectValue();
        }
    }

    public static void clear()
    {
        if (undefinedValue != null)
        {
            // static singleton used insurance
            if(nullSlot.getType() != null || nullSlot.getVarIndex() != -1)
                throw new Error();
            undefinedValue = null;
            nullValue = null;
            enumerableNamespace = null;
            labelNamespace = null;
            loopLabelNamespace = null;
            objectPrototype = null;
            internalNamespace = null;
            intrinsicAttribute = null;
            intrinsicNamespace = null;
            staticAttribute = null;
            dynamicAttribute = null;
            finalAttribute = null;
            virtualAttribute = null;
            overrideAttribute = null;
            nativeAttribute = null;
        }
    }

    public Builder builder;
    public TypeInfo type;
    private String value = EMPTY_STRING;
    private NumberUsage numberUsage;

    private Names names;  // Names table
    public Slots slots;         // Slots table, null=empty
//    private Values values;       // Values table, null=empty
    public ObjectValue _proto_;
    public String name = EMPTY_STRING;
    
    ObjectList<ObjectValue> base_objs; // can be interfaces, or base class
    private ObjectValue protected_ns;
    private ObjectValue base_protected_ns;

    private SlotIDCache slot_ids = null;
//    public Names baseMethodNames;

    public int method_info;   // index of the method info that implements this function
    // not set until FinishMethod is called for this function
    public int var_count; // The number of variables stored in this object

    public ObjectValue activation;    // for function objects. This represents
    // the compile-time model of the
    // activation object.

    public ObjectValue()
    {
        builder = null;
        type = null;
        _proto_ = null;
        var_count = 0;
        activation = null;
        numberUsage = null;
        method_info = -1;
        initInstance(null, null);
    }

    public ObjectValue(TypeValue type)
    {
        builder = null;
        _proto_ = null;
        var_count = 0;
        numberUsage = null;
        activation = null;
        this.type = type != null ? type.getDefaultTypeInfo() : null ;
        method_info = -1;
        initInstance(null, type);
    }

    public ObjectValue(String value, TypeValue type)
    {
        setValue(value);
        builder = null;
        _proto_ = null;
        var_count = 0;
        numberUsage = null;
        activation = null;
        this.type = type != null ? type.getDefaultTypeInfo() : null ;
        method_info = -1;
        initInstance(null, type);
    }

    public ObjectValue(String value, TypeInfo type)
    {
        setValue(value);
        builder = null;
        _proto_ = null;
        var_count = 0;
        numberUsage = null;
        activation = null;
        this.type = type;
        method_info = -1;
        initInstance(null, type.getTypeValue());
    }

    public ObjectValue(Context cx, Builder builder, TypeValue type)
    {
        clearInstance(cx, builder, type, EMPTY_STRING, false);
    }

    /**
     * Only used by flex's symbol table - creates a copy of an ObjectValue
     * This can go away once flex's symbol table doesn't require keeping temporary
     * ObjectValue copies around anymore
     * @param ov - the ObjectValue to copy.
     */
    protected ObjectValue(ObjectValue ov)
    {
        builder = ov.builder;
        _proto_ = ov._proto_;
        var_count = ov.var_count;
        numberUsage = ov.numberUsage;
        activation = ov.activation;
        this.type = ov.type;
        method_info = ov.method_info;

        flags = ov.flags;
        value = ov.value;
        names = ov.names;
        slots = ov.slots;

        base_objs = ov.base_objs;
        protected_ns = ov.protected_ns;
        base_protected_ns = ov.base_protected_ns;

    }
    public void clearInstance(Context cx, Builder builder, TypeValue type, String name, boolean save_slot_ids)
    {
        flags = 0;
        value = EMPTY_STRING;
        names = null;
        if( save_slot_ids && slots != null && slots.size() > 0)
        {
        	slot_ids = new SlotIDCache(slots);
        }
        slots = null;
//        values = null;
//        baseMethodNames = null;
        deferredClassMap = null;
        base_objs = null;
        protected_ns = null;
        base_protected_ns = null;

        this.builder = builder;
        this.type = type != null ? type.getDefaultTypeInfo() : null ;
        _proto_ = null;
        var_count = 0;
        numberUsage = null;
        activation = null;
        method_info = -1;
        initInstance(null, type);
        builder.build(cx, this);
        assert name.intern() == name;
        this.name = name;
    }

    static Slot nullSlot = new MethodSlot((TypeValue)null, 0);
    public void initInstance(ObjectValue protoObject, TypeValue classObject)
    {
        // Context cx = new Context(null);

        _proto_ = protoObject;

        // Call the class object's builder method to initialize
        // this instance.

        /* C: TypeValue.build() doesn't do anything. comment it out so that we don't have to create extra
              Context objects...
        if (classObject != null)
        {
            classObject.build(cx, this);
        }
        */
    }

    /*
     * Scope methods
     */

    /*
     * Look for a property name in the object.
     * {pmd} Note that this comment is incorrect and that the following function uses "put" to "remove" a name...
     * {pmd} Also that the arguments cx and qualifier are unused.
     * TODO: Clean this up
     */

    public boolean removeName(Context cx, int kind, String name, ObjectValue qualifier)
    {
        if (names != null)
        {
            names.put(name, qualifier, Names.getTypeFromKind(kind), -1);
        }
        return true;
    }

    /*
     * Look for a property name in the object.
     */

    public boolean hasName(Context cx, int kind, String name, ObjectValue qualifier)
    {
    	if( init_only_view && kind != Tokens.SET_TOKEN )
    	{
    		return false;
    	}

    	boolean ret = false;
    	ret = names == null ? false : names.containsKey(name, qualifier, Names.getTypeFromKind(kind));
        
        // When in init only mode, only set slots defined in this object should be visible.
        // Any slots defined in the base class should not be visible.  
        if( !init_only_view && !ret && base_objs != null )
        {
        	if( qualifier == protected_ns )
        		qualifier = base_protected_ns;
        	for( int i = 0; i < base_objs.size() && !ret; ++i)
        	{
        		ret = base_objs.at(i).hasName(cx, kind, name, qualifier);
        	}
        }
        
        return ret;
    }

    public boolean hasNameUnqualified(Context cx,  String name, int kind)
    {
    	if( init_only_view && kind != Tokens.SET_TOKEN )
    	{
    		return false;
    	}
    	boolean ret = false;
    	ret = names == null ? false : (names.exist(name, Names.getTypeFromKind(kind)));

        // When in init only mode, only set slots defined in this object should be visible.
        // Any slots defined in the base class should not be visible.  
    	if( !init_only_view && !ret && base_objs != null )
    	{
        	for( int i = 0; i < base_objs.size() && !ret; ++i)
        	{
        		ret = base_objs.at(i).hasNameUnqualified(cx, name, kind);
        	}
    	}

        return ret;
    }

    /* Check for names that consist of an id and one of multiple
     * namespaces. Return a vector of namespaces that match. This
     * method is used for lookup of unqualified names.
     */

    public Namespaces hasNames(Context cx, int kind, String name, Namespaces namespaces)
    {
        return hasNames(cx, kind, name, namespaces, true);
    }

    public Namespaces hasNames(Context cx, int kind, String name, Namespaces namespaces, boolean search_base_objs)
    {
    	if( init_only_view && kind != Tokens.SET_TOKEN )
    	{
    		return null;
    	}
    	
    	Namespaces hasNamespaces = null;
    	int protected_index = -1;
    	boolean searched_protected = false;
    	boolean matched_protected = false;
        if(names != null)
        {
	        int type = Names.getTypeFromKind(kind);
	
	        // fail fast for more than one namespace case
	        if( !(namespaces.size() > 1 && !names.containsKey(name, type) ) )
	        {
	        	searched_protected = true;
		        // For each member of namespaces, see if there is a matching qualifier.
		        for (int i = 0, size = namespaces.size(); i < size; ++i)
		        {
		            ObjectValue qual = namespaces.get(i);
		            if (names.containsKey(name, qual, type))
		            {
		                if(hasNamespaces == null) { hasNamespaces = new Namespaces(); }
		                hasNamespaces.add(qual);
		                if( qual == this.protected_ns )
		                {
		                	matched_protected = true;
		                }
		                	
		            }
		            if( qual == this.protected_ns )
		            {
		            	protected_index = i;
		            }
		        }
	        }
        }
        // When in init only mode, only set slots defined in this object should be visible.
        // Any slots defined in the base class should not be visible.  
    	if( !init_only_view && base_objs != null && search_base_objs)
    	{
    		Namespaces temp = null;
    		if( !searched_protected && protected_ns != null && !matched_protected)
    		{
		        for (int i = 0, size = namespaces.size(); i < size; ++i)
		        {
		            if( protected_ns == namespaces.get(i))
		            {
		            	protected_index = i;
		            	break;
		            }
		        }
    		}
    		// Replace the protected namespace with the protected namespace of the base class
    		if( protected_index != -1 && !matched_protected)
    		{
    			// Replace the protected namespace only if it wasn't matched.
    			// If it was matched, then the slot in this object overrides
    			// the slots in any of the base classes, so we don't want
    			// to find those because we will get ambiguous reference errors
    			namespaces.set(protected_index, base_protected_ns);
    		}
    		try
    		{
	    		for( int i = 0; i < base_objs.size(); ++i )
	    		{
	    			temp = base_objs.at(i).hasNames(cx, kind, name, namespaces);
	    			if( temp != null)
	    			{
		                if(hasNamespaces == null) { hasNamespaces = temp; }
		                else { hasNamespaces.addAll(temp); }
	    			}
	    		}
    		}
    		finally
    		{
    			// Restore the protected namespace back to its original value so that namespaces
    			// is not changed when this method exits.
	    		if( protected_index != -1 && !matched_protected )
	    		{
	    			namespaces.set(protected_index, protected_ns);
	    		}
    		}
    	}

        return hasNamespaces;
    }

    /*
     * Get the slot for a property.
     *
     * WARNING:
     * Before calling this method you must call hasName to ensure that
     * the requested property exists.
     */

    public Slot get(Context cx, String name, ObjectValue qualifier)
    {
        return getSlot(cx, get(name, qualifier, Names.GET_NAMES));
    }

    private int get(String name, ObjectValue qualifier, int type)
    {
    	int ret = names != null ? names.get(name, qualifier, type) : -1;
    	if ( ret == -1 )
    	{
    		if( base_objs != null )
    		{
    			if( qualifier == protected_ns )
    				qualifier = base_protected_ns;
    			for(int i = 0; i < base_objs.size() && ret == -1; ++i)
    				ret = base_objs.at(i).get(name, qualifier, type);
    		}
    	}
    	return ret;
    }
    /*
     * Set the var
     *
     */
/* Unused
    public void setVar(Context cx, int var_index, Value val)
    {
        if (var_index >= 0)
        {
            if (values == null)
                values = new Values();
            while (var_index >= values.size())
            {
                values.add(null);
            }
            values.add(var_index, val);
        }
    }
*/
    /*
     * Get the var
     *
     */
/* Unused
    // C: var_index used to be unsigned int...
    public Value getVar(Context cx, int var_index)
    {
        if (values != null && var_index >= 0 && var_index < values.size())
        {
            return values.get(var_index);
        }
        else
        {
            return null;
        }
    }
*/
    /* Define a property and associate it with slot_index. Four forms:
     * - maps a getter and setter name to a slot. This only works if
     *   the contents of the slot is an actual var index.
     * - maps a getter name to a slot. The contents of the slot needs
     *   to be a code block that implements a getter.
     * - maps a setter name to a slot. The contents of the slot needs
     *   to be a code blcok that implements a setter.
     * - maps a method name to a slot. The contents of the slot needs
     *   to be a code block that implements a method.
     */

    /*
     * Set the value of a property.
     */

    public int defineName(Context cx, int kind, String name, ObjectValue qualifier, int slot_index)
    {
        // C: Trace.debug??
        // if( debug ) printf("ObjectValue::defineName() name = %s, kind = %s, slot_index = %d\n",name.c_str(),Token::getTokenClassName(kind).c_str(),slot_index);

        if (names == null)
        {
            names = new Names();
        }

        if (this.hasName(cx, kind, name, qualifier) )
        {
            return 0;
        }
        else
        {
            names.put(name, qualifier, Names.getTypeFromKind(kind), slot_index);
            return 1;
        }
    }

	public Names getNamesAndCreate()
	{
		if(names == null)
			names = new Names();
		return names;
	}

    public boolean defineNames(Context cx, int kind, String name, Namespaces namespaces, int slot_index)
    {
        // if( debug ) printf("ObjectValue::defineName() name = %s, kind = %s, slot_index = %d\n",name.c_str(),Token::getTokenClassName(kind).c_str(),slot_index);

        if (names == null)
        {
            names = new Names();
        }
	
        // for each namespace, add a qualifier with the given slot index
        for (int i = 0, size = namespaces.size(); i < size; i++)
        {
            ObjectValue it = namespaces.get(i);
            names.put(name, it, Names.getTypeFromKind(kind), slot_index);
        }

        return true;
    }

    /*
     * Add a slot to this object. This object's fixed slots
     * (that is, all slots added before freezeSlots is called)
     * begin where the [[Prototype]] indexes end.
     *
     * If [[Prototype]] object has not been frozen or this
     * object has been frozen, then addSlot allocates the
     * slot in the dynamic slot space.
     */

    final public int addVariableSlot(Context cx, TypeValue type, int var_index)
    {
        if (slots == null) {
            slots = new Slots();
            // reserve first slot
            //slots.put(nullSlot.id,nullSlot);
        }
        Slot newSlot = new VariableSlot(type, nextSlotID(cx), var_index);
        newSlot.declaredBy = this;
        slots.put(newSlot);
        return newSlot.id;
    }

    final public int addMethodSlot(Context cx, TypeValue type)
    {
        if (slots == null) {
            slots = new Slots();
            // reserve first slot
            //slots.put(nullSlot.id,nullSlot);
        }
        Slot newSlot = new MethodSlot(type, nextSlotID(cx));
        newSlot.declaredBy = this;
        slots.put(newSlot);
        return newSlot.id;
    }

    final private int nextSlotID(Context cx)
    {
    	int slot_id;
    	if( slot_ids != null )
    		slot_id = slot_ids.getNextSlotID(cx);
    	else
    		slot_id = cx.statics.getNextSlotID();
    	return slot_id;
    }
    
    final public void addSlot(Slot slot)
    {
        if (slots == null)
        {
            slots = new Slots();
        }
        slots.put(slot);
    }

    final public int addSlotImplicit(Context cx, int slot_index, int kind, TypeValue type)
    {
        final int index = addMethodSlot(cx, type);
        getSlot(cx, slot_index).implicit(kind, index);
        // Set the expected type of the operands.
        return index;
    }

    final public int addSlotOverload(Context cx, int slot_index, TypeValue type, TypeValue t1)
    {
        int index = addMethodSlot(cx, type);
        getSlot(cx, slot_index).overload(t1, index);
        // Set the expected type of the operands.
        Slot slot = getSlot(cx, index);
        slot.addType(t1.getDefaultTypeInfo());
        return index;
    }

    final public int addSlotOverload(Context cx, int slot_index, TypeValue type, TypeValue t1, TypeValue t2)
    {
        int index = addMethodSlot(cx, type);
        getSlot(cx, slot_index).overload(t1, t2, index);
        // Set the expected types of the operands.
        Slot slot = getSlot(cx, index);
        slot.addType(t1.getDefaultTypeInfo());
        slot.addType(t2.getDefaultTypeInfo());
        return index;
    }

    /*
     * Get the slot for an index. If it is a fixed slot
     * it will have a positive value. dynamic slots have
     * negative values. zero is unused.
     */

    // C: index used to be unsigned int
    public Slot getSlot(Context cx, int index)
    {
    	Slot ret = null;
        if (slots != null)
        {
            ret = slots.getByID(index);
        }
        if (ret == null)
        {
        	if( base_objs != null)
        	{
        		for( int i = 0; i < base_objs.size() && ret == null; ++i)
        			ret = base_objs.at(i).getSlot(cx, index);
        	}
        }
        return ret;
    }

    /*
     * Get the slot index of a named property.
     *
     * Before calling this method you must call hasName to ensure that
     * the requested property exists.
     */

    public int getSlotIndex(Context cx, int kind, String name, ObjectValue qualifier)
    {
        int index = -1;

        qualifier = qualifier != null ? qualifier : cx.publicNamespace();

        int type = Names.getTypeFromKind(kind);

        if (!this.hasNameUnqualified(cx, name, kind))
        {
            if (proto() != null)
            {
                index = proto().getSlotIndex(cx, kind, name, qualifier);
            }
        }
        else
        {
            index = this.get(name, qualifier, type);
            // TPR: this seems wrong, commenting out for now, if you put it back 
            // say why
            /*
            if (index == -1)
            {
                index = 0;
            }*/
        }

        return index;
    }

    public int getImplicitIndex(Context cx, int slot_index, int kind)
    {
        Slot slot = getSlot(cx,slot_index);
        int index = (slot != null) ? slot.implies(cx,kind) : 0;
        return index != 0 ? index : slot_index;
    }

    public int getOverloadIndex(Context cx, int slot_index, TypeValue t1)
    {
        int index = getSlot(cx, slot_index).dispatch(cx, t1);
        return index != 0 ? index : slot_index;
    }

    public int getOverloadIndex(Context cx, int slot_index, TypeValue t1, TypeValue t2)
    {
        // If there is no overload for these types, then return the original slot_index

        t1 = t1==null?cx.noType():t1;
        t2 = t2==null?cx.noType():t2;
        int index = getSlot(cx, slot_index).dispatch(cx, t1, t2);
        return index != 0 ? index : slot_index;
    }

    /*
     * Add a value slot to this object
     */
    public int addVar(Context cx)
    {
        return var_count++;
    }

    /*
    Add a method slot to this object
    */

    public ObjectValue proto()
    {
        return _proto_;
    }

    public TypeInfo getType(Context cx)
    {
        if (type != null)
        {
            return type;
        }
        return cx.noType().getDefaultTypeInfo();
    }

    public boolean isDynamic() { return (builder != null ? builder.is_dynamic : false); }
    public boolean isFinal() { return (builder != null ? builder.is_final : false); }

    public boolean equals(Object o)
    {
        return this == o;
    }

    public int compareTo(Object o)
    {
        if (o instanceof ObjectValue)
        {
            return name.compareTo(((ObjectValue) o).name);
        }
        else
        {
            return -1;
        }
    }

    private HashMap<TypeValue,ClassDefinitionNode> deferredClassMap;

    public HashMap<TypeValue,ClassDefinitionNode> getDeferredClassMap()
    {
        if (deferredClassMap == null)
        {
            deferredClassMap = new HashMap<TypeValue,ClassDefinitionNode>();
        }
        return deferredClassMap;
    }

    public String toString() {
       if(Node.useDebugToStrings)
          return ("ObjVal: <" + type + "> " + (name != null ? name.toString() : EMPTY_STRING)
              + ((names != null && names.size()>0) ? "\nmethods: " + names.toString() : EMPTY_STRING));
       else
          return getValue();
    }

    public boolean isInterface()
    {
        return builder instanceof ClassBuilder && ((ClassBuilder)builder).is_interface;
    }

    public boolean canEarlyBind()
    {
        boolean ret = true;
        if( builder instanceof InstanceBuilder )
        {
            ret = ((InstanceBuilder)builder).canEarlyBind;
        }
        return ret;
    }

    public Names getNames()
    {
        return names;
    }
    
    public void setNumberUsage(NumberUsage usage) {
    	numberUsage = usage;
    }
    
    public NumberUsage getNumberUsage() {
    	return numberUsage;
    }

    public String getValue()
    {
        return value;
    }

    public void setValue(String value)
    {
        flags |= HAS_VALUE_Flag;
        this.value = value;
    }

    public boolean hasValue()
    {
        return (flags&HAS_VALUE_Flag)!=0;
    }

    public boolean booleanValue()
    {
        return getValue().equals("true") ? true : false;
    }

    public void setPackage(boolean package_flag)
    {
        flags = package_flag ? (flags|IS_PACKAGE_Flag) : (flags&~IS_PACKAGE_Flag);
    }

    public boolean isPackage()
    {
        return (flags&IS_PACKAGE_Flag)!=0;
    }

    private boolean init_only_view = false;
    public void setInitOnly(boolean b)
    {
    	init_only_view = b;
    }
    public boolean isInitOnly()
    {
    	return init_only_view;
    }
    // Namespace specific methods, these are only implemented in NamespaceValue.
    public boolean isInternal()
    {
        return false;
    }

    public boolean isProtected()
    {
        return false;
    }

    public boolean isPrivate()
    {
        return false;
    }

    public byte getNamespaceKind()
    {
        return Context.NS_PUBLIC;
    }

    public boolean isConfigNS()
    {
        return false;
    }
    
    /**
     * Use this to add base ObjectValues to this OV.  This includes base classes, or interfaces.
     */
    public void addBaseObj(ObjectValue base)
    {
    	if( base_objs == null)
    		base_objs = new ObjectList<ObjectValue>(1);
    	if( !base_objs.contains(base) )
    		base_objs.add(base);
    }
    
    /**
     * Set the protected namespace and the protected namespace of the base class of this object value.
     * This is neccessary so that the correct protected namespace can be used when walking up the inheritance
     * chain.
     * @param protected_ns		The protected namespace for this class
     * @param base_protected	The protected namespace for the base class of this class
     */
    public void setProtectedNamespaces(ObjectValue protected_ns, ObjectValue base_protected)
    {
    	this.protected_ns = protected_ns;
    	this.base_protected_ns = base_protected;
    }
    /**
     * Provides a simple comparator that can be used with collections to compar ObjectValue pointers.  Use
     * this when order is important, especially when the C++ and java orderings much match.
     */
    public static class ObjectValueCompare implements Comparator<ObjectValue>
    {
        public int compare(ObjectValue o1, ObjectValue o2)
        {
            int result = o2.name.compareTo(o1.name);
            // namespaces with the same name, but different types are not equal
            if( result == 0 )
                result += o2.getNamespaceKind()-o1.getNamespaceKind();
            return result;
        }

        public boolean equals(Object obj)
        {
            return obj == this;
        }
    }
    
    private static class SlotIDCache
    {
    	private IntList slot_id_boundaries;
    	private int cur_range_index = 0;
    	private int cur_slot_id = -1;
    	
    	public SlotIDCache(Slots slots)
    	{
    		init(slots);
    	}
    	void init(Slots slots)
    	{
    		cur_range_index = 0;
    		cur_slot_id = -1;
    		if ( slots != null && slots.size() > 0 )
    		{
    			int lo_id = slots.at(0).id;
    			int hi_id = slots.at(slots.size()-1).id;
	    		if( slots.size() -1 == hi_id - lo_id)
	    		{
	    			// Contiguous slot ids
		    		slot_id_boundaries = new IntList(2);
		    		slot_id_boundaries.add(lo_id);
		    		slot_id_boundaries.add(hi_id);
	    		}
	    		else
	    		{
	    			// Some non contiguous slot ids.  Should be just a few blocks of contiguous id's though
	    			slot_id_boundaries = new IntList(6);
	    			int last_id = lo_id;
	    			int start_id = lo_id;
	    			for( int i = 1, size = slots.size(); i < size; ++i )
	    			{
	    				int id = slots.at(i).id;
	    				if( id != last_id + 1 )
	    				{
	    					slot_id_boundaries.add(start_id);
	    					slot_id_boundaries.add(last_id);
	    					
	    					start_id = id;
	    				}
	    				last_id = id;
	    			}
	    			slot_id_boundaries.add(start_id);
	    			slot_id_boundaries.add(last_id);
	    		}
	    		cur_slot_id = slot_id_boundaries.at(0);
    		}
    	}
    	
    	public int getNextSlotID(Context cx)
    	{
    		int slot_id = -1;
    		
    		if( cur_slot_id > slot_id_boundaries.last() )
    		{
    			slot_id = cx.statics.getNextSlotID();
    		}

    		while( slot_id == -1 && cur_range_index < slot_id_boundaries.size()-1 )
    		{
	    		int hi = slot_id_boundaries.at(cur_range_index+1);
    			if ( cur_slot_id > hi )
    			{
    				cur_range_index += 2;
    				cur_slot_id = cur_range_index < (slot_id_boundaries.size()-1) ? slot_id_boundaries.at(cur_range_index) : cur_slot_id;
    			}
    			else
    			{
    				slot_id = cur_slot_id++;
    			}
    		}
    		if( slot_id == -1)
    		{
    			slot_id = cx.statics.getNextSlotID();
    		}
    		
    		return slot_id;
    	}
    }


}
