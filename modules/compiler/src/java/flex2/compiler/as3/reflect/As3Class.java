/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.as3.reflect;

import flex2.compiler.SymbolTable;
import flex2.compiler.abc.*;
import macromedia.asc.embedding.avmplus.InstanceBuilder;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.*;
import macromedia.asc.util.*;

import java.util.*;

/**
 * TypeTable implementation based on type information extracted from
 * ASC's ClassDefinitionNode.
 *
 * @author Clement Wong
 */
public final class As3Class implements AbcClass
{
	public As3Class(ClassDefinitionNode clsdef, TypeTable typeTable)
	{

		cframe = clsdef.cframe;
        access_ns = new Namespaces(4);

		access_ns.add(clsdef.public_namespace);
        access_ns.add(clsdef.default_namespace);
		access_ns.add(clsdef.private_namespace);
		access_ns.add(clsdef.protected_namespace);

        cx_statics = clsdef.cx.statics;
		
		this.metadata = TypeTable.createMetaData(clsdef);
		this.typeTable = typeTable;

	}

	private String[] interfaceNames;
	private List<flex2.compiler.abc.MetaData> metadata;
    private TypeTable typeTable;

	private TypeValue cframe;
    private ContextStatics cx_statics;

    private Namespaces access_ns;

    /**
     * Copy the underlying data structures, so that type info can still be looked up, even
     * if the original data structure changes.  This is needed to successfully compile mxml
     * files which go through multiple passes, and build up type info for the same symbols multiple
     * times.
     */
    public void freeze()
    {
        this.cframe = cframe.copyType();        
    }

	public flex2.compiler.abc.Variable getVariable(String[] namespaces, String name, boolean inherited)
	{
        flex2.compiler.abc.Variable variable = null;
        Namespaces nsset = convertNamespaces(namespaces);

        name = name.intern();

        int kind = Tokens.GET_TOKEN;

        variable = getVariable(name, inherited, nsset, kind);

		return variable;
	}

    public flex2.compiler.abc.Variable getVariable(Namespaces namespaces, String name, boolean inherited)
    {
        return getVariable(name, inherited, namespaces, Tokens.GET_TOKEN);
    }
    private flex2.compiler.abc.Variable getVariable(String name, boolean inherited, Namespaces nsset, int kind)
    {
        Slot slot = null;

        flex2.compiler.abc.Variable variable = null;

        ObjectValue iframe = cframe.prototype;

        Namespaces matching = iframe.hasNames(null, kind, name, nsset, inherited);

        if( matching != null && matching.size() > 0 )
        {
        	// Should we validate every entry points to the same slot?
        	// Probably not - ASC handles that already so we shouldn't get here
        	// if thats the case
            int slot_index = iframe.getSlotIndex(null, kind, name, matching.back());
            slot = iframe.getSlot(null, slot_index);
        }
        if( slot == null )
        {
        	// Check for static
            matching = cframe.hasNames(null, kind, name, nsset, inherited);

            if( matching != null && matching.size() > 0 )
            {
                int slot_index = cframe.getSlotIndex(null, kind, name, matching.back());
                slot = cframe.getSlot(null, slot_index);
            }

        }
        if( slot != null && slot instanceof VariableSlot)
        {
        	variable = new Variable(slot, matching.back(), name);
        }
        return variable;
    }

    private Namespaces convertNamespaces(String[] namespaces)
    {
        if( namespaces == SymbolTable.VISIBILITY_NAMESPACES )
            return access_ns;

        Namespaces nsset = new Namespaces(namespaces.length);

        int i = 0;

        while (i < namespaces.length)
        {
        	String ns = namespaces[i];
        	ObjectValue qual;
        	if ( ns == SymbolTable.publicNamespace )
        		qual = access_ns.at(Context.NS_PUBLIC);
        	else if ( ns == SymbolTable.internalNamespace )
        		qual = access_ns.at(Context.NS_INTERNAL);
        	else if ( ns == SymbolTable.protectedNamespace )
        		qual = access_ns.at(Context.NS_PROTECTED);
            else if ( ns == SymbolTable.privateNamespace )
                qual = access_ns.at(Context.NS_PRIVATE);
            else
                qual = cx_statics.getNamespace(ns, Context.NS_PUBLIC);

        	if( qual != null )
        		nsset.add(qual);

        	++i;
        }
        return nsset;
    }

    public flex2.compiler.abc.Method getMethod(String[] namespaces, String name, boolean inherited)
	{
        flex2.compiler.abc.Method method;
        Namespaces nsset = convertNamespaces(namespaces);

        name = name.intern();

        int kind = Tokens.EMPTY_TOKEN;

        method = getMethod(name, inherited, nsset, kind);

		return method;
	}

    public flex2.compiler.abc.Method getMethod(Namespaces namespaces, String name, boolean inherited)
    {
        return getMethod(name, inherited, namespaces, Tokens.EMPTY_TOKEN);
    }

    private flex2.compiler.abc.Method getMethod(String name, boolean inherited, Namespaces nsset, int kind)
    {
        Slot slot = null;

        flex2.compiler.abc.Method method = null;

        // If we are looking for the method, then we get the GET slot, and ask it
        // for the implied(EMPTY_TOKEN) slot.
        // If we're looking for the actual getter, then we just lookup the GET slot
        boolean want_call_slot = false;
        if( kind == Tokens.EMPTY_TOKEN )
        {
            want_call_slot = true;
            kind = Tokens.GET_TOKEN;
        }

        ObjectValue iframe = cframe.prototype;
        Namespaces matching = iframe.hasNames(null, kind, name, nsset, inherited);

        if( matching != null && matching.size() > 0 )
        {
        	// Should we validate every entry points to the same slot?
        	// Probably not - ASC handles that already so we shouldn't get here
        	// if thats the case
            int slot_index = iframe.getSlotIndex(null, kind, name, matching.back());
            slot = iframe.getSlot(null, slot_index);

            if( slot != null )
            {
                if( want_call_slot )
                {
                    int implied_id = slot.implies(null, Tokens.EMPTY_TOKEN);
                    slot = iframe.getSlot(null, implied_id);
                }
                else if( kind == Tokens.GET_TOKEN )
                {
                    // If we're looking for a getter, make sure the slot is
                    // actually a getter, and not just the GET slot for a method
                    if( !slot.isGetter() )
                        slot = null;
                }
            }
        }
        if( slot == null )
        {
        	// Check for static
            matching = cframe.hasNames(null, kind, name, nsset, inherited);

            if( matching != null && matching.size() > 0 )
            {
                int slot_index = cframe.getSlotIndex(null, kind, name, matching.back());
                slot = cframe.getSlot(null, slot_index);

                if( slot != null )
                {
                    if( want_call_slot )
                    {
                        int implied_id = slot.implies(null, Tokens.EMPTY_TOKEN);
                        slot = cframe.getSlot(null, implied_id);
                    }
                    else if( kind == Tokens.GET_TOKEN )
                    {
                        // If we're looking for a getter, make sure the slot is
                        // actually a getter, and not just the GET slot for a method
                        if( !slot.isGetter() )
                            slot = null;
                    }
                }
            }

        }
        if( slot != null && slot instanceof MethodSlot)
        {
        	method = new Method(slot, matching.back(), name);
        }
        return method;
    }

    public flex2.compiler.abc.Method getGetter(String[] namespaces, String name, boolean inherited)
	{
        flex2.compiler.abc.Method method = null;
        Namespaces nsset = convertNamespaces(namespaces);

        name = name.intern();

        int kind = Tokens.GET_TOKEN;

        method = getMethod(name, inherited, nsset, kind);

		return method;
	}

    public flex2.compiler.abc.Method getGetter(Namespaces namespaces, String name, boolean inherited)
    {
        return getMethod(name, inherited, namespaces, Tokens.GET_TOKEN);
    }

	public flex2.compiler.abc.Method getSetter(String[] namespaces, String name, boolean inherited)
	{
        flex2.compiler.abc.Method method = null;
        Namespaces nsset = convertNamespaces(namespaces);

        name = name.intern();

        int kind = Tokens.SET_TOKEN;

        method = getMethod(name, inherited, nsset, kind);

		return method;
	}
    public flex2.compiler.abc.Method getSetter(Namespaces namespaces, String name, boolean inherited)
    {
        return getMethod(name, inherited, namespaces, Tokens.SET_TOKEN);
    }

	public String getName()
	{
        return cframe.builder.classname.toString();
	}

	public String getSuperTypeName()
	{
        if( cframe.baseclass != null )
            return cframe.baseclass.name.toString();
        else
            return null;
	}

	public String[] getInterfaceNames()
	{
        if( interfaceNames == null )
        {
            InstanceBuilder bui = (InstanceBuilder)cframe.prototype.builder;
            int size = bui.interface_refs.size();
            interfaceNames = new String[size];
            for( int i = 0; i < size; ++i)
            {
                ReferenceValue referenceValue = bui.interface_refs.at(i);
                TypeValue typeValue = (TypeValue) referenceValue.slot.getValue();
                if (typeValue != null)
                {
                    interfaceNames[i] = typeValue.name.toString() ;
                }
                else
                {
	                assert false : "There is an interface without a TypeValue...";
                }
            }
        }
		return interfaceNames.length == 0 ? null : interfaceNames;
	}

    public List<flex2.compiler.abc.MetaData> getMetaData(String id, boolean inherited)
	{
		return getMetaData(id, inherited, new ArrayList<flex2.compiler.abc.MetaData>(inherited ? 10 : (metadata != null) ? metadata.size() : 1));
	}

	private List<flex2.compiler.abc.MetaData> getMetaData(String id, boolean inherited, List<flex2.compiler.abc.MetaData> list)
	{
		if (metadata != null)
		{
			for (int i = 0, length = metadata.size(); i < length; i++)
			{
				if (id.equals(metadata.get(i).getID()))
				{
					list.add(metadata.get(i));
				}
			}
		}

		if (inherited)
		{
			AbcClass superType = typeTable.getClass(getSuperTypeName());

			if (superType != null)
			{
				if (superType instanceof As3Class)
				{
					((As3Class)superType).getMetaData(id, true, list);
				}
				else
				{
					list.addAll(superType.getMetaData(id, true));
				}
			}
		}

		return list;
	}

	public boolean implementsInterface(String interfaceName)
	{
	    boolean result = false;

	    if (interfaceNames != null)
	    {
	        int size = interfaceNames.length;

	        for (int i = 0; i < size; i++)
	        {
	            if (interfaceName.equals(interfaceNames[i]))
	            {
	                result = true;
	            }
	            else
	            {
	                As3Class interfaceType = (As3Class) typeTable.getClass(interfaceNames[i]);

	                if (interfaceType.isAssignableTo(interfaceName))
	                {
	                    result = true;
	                }
	            }
	        }
	    }

	    if (!result)
	    {
	        AbcClass superType = typeTable.getClass(getSuperTypeName());

	        if (superType != null)
	        {
	            result = superType.implementsInterface(interfaceName);
	        }
	    }

	    return result;
	}

	public boolean isSubclassOf(String baseName)
	{
		if (SymbolTable.NOTYPE.equals(baseName))
		{
			return false;
		}
		else
		{
			return isAssignableTo(baseName);
		}
	}

	public boolean isInterface()
	{
		return cframe.isInterface();
	}

    public boolean isPublic()
    {
        return cframe.name.ns.getNamespaceKind() == Context.NS_PUBLIC;
    }

    public boolean isDynamic()
    {
        return cframe.prototype.isDynamic();
    }
    public boolean isAssignableTo(String baseName)
    {
        if (SymbolTable.NOTYPE.equals(baseName) || getName().equals(baseName))
        {
            return true;
        }

        String superTypeName = getSuperTypeName();

        if (superTypeName != null && superTypeName.equals(baseName))
        {
            return true;
        }

        String[] interfaceNames = getInterfaceNames();

        for (int i = 0, length = (interfaceNames == null) ? 0 : interfaceNames.length; i < length; i++)
        {
            if (baseName != null && baseName.equals(interfaceNames[i]))
            {
                return true;
            }
        }

        if (superTypeName != null)
        {
            As3Class superType = (As3Class) typeTable.getClass(superTypeName);

            if ( superType.isAssignableTo(baseName) )
            {
                return true;
            }
        }

        for (int i = 0, length = (interfaceNames == null) ? 0 : interfaceNames.length; i < length; i++)
        {
            if (interfaceNames[i] != null)
            {
                As3Class interfaceType = (As3Class) typeTable.getClass(interfaceNames[i]);

                if (interfaceType.isAssignableTo(baseName))
                {
                    return true;
                }
            }
        }

        return false;
    }

	public void setTypeTable(Object typeTable)
	{
		this.typeTable = (TypeTable) typeTable;
	}

    public Iterator<flex2.compiler.abc.Variable> getVarIterator()
    {
        return new VarIterator();
    }

    public Iterator<flex2.compiler.abc.Method> getMethodIterator()
    {
        return new MethodIterator(Names.METHOD_NAMES);
    }

    public Iterator<flex2.compiler.abc.Method> getGetterIterator()
    {
        return new MethodIterator(Names.GET_NAMES);
    }

    public Iterator<flex2.compiler.abc.Method> getSetterIterator()
    {
        return new MethodIterator(Names.SET_NAMES);
    }

    class VarIterator implements Iterator<flex2.compiler.abc.Variable>
    {
        private int cur_idx;
        private ObjectValue frame;
        private Variable next_var;

        VarIterator()
        {
            cur_idx = 0;
            frame = cframe;
        }

        public boolean hasNext()
        {
            if( next_var != null )
                return true;

            next_var = advanceNext();

            return next_var != null;
        }

        private Variable advanceNext()
        {
            int kind = Names.GET_NAMES;

            Names names = frame.builder.getNames();
            for (int i = cur_idx; (i = names.hasNext(i)) != -1; i++) {
                if (names.getType(i) == kind) {
                    Slot s = frame.getSlot(null, names.getSlot(i));
                    if( s instanceof VariableSlot )
                    {
                        cur_idx = i+1;
                        return new Variable(s, names.getNamespace(i), names.getName(i));
                    }
                }
            }
            if( frame == cframe )
            {
                // If we get here, then we have gone through all the class members,
                // so now do the instance members
                frame = cframe.prototype;
                cur_idx = 0;
                return advanceNext();
            }
            return null;
        }

        public flex2.compiler.abc.Variable next()
        {
            Variable var;
            if( next_var != null)
            {
                var = next_var;
                next_var = null;
            }
            else
            {
                var = advanceNext();
            }

            if ( var == null )
                throw new NoSuchElementException();

            return var ;
        }

        public void remove()
        {

        }
    }

    class MethodIterator implements Iterator<flex2.compiler.abc.Method>
    {
        private int cur_idx;
        private ObjectValue frame;
        private Method next_meth;
        private int kind;

        MethodIterator(int kind)
        {
            cur_idx = 0;
            frame = cframe;
            this.kind = kind;
        }

        public boolean hasNext()
        {
            if( next_meth != null )
                return true;

            next_meth = advanceNext();

            return next_meth != null;
        }

        private Method advanceNext()
        {
            boolean getters = false;
            int kind = this.kind;

            if( kind == Names.METHOD_NAMES )
            {
                getters = false;
                kind = Names.GET_NAMES;
            }
            else if(kind == Names.GET_NAMES)
            {
                getters = true;
            }
            else if (kind == Names.SET_NAMES )
            {
                getters = false;
            }

            Names names = frame.builder.getNames();
            for (int i = cur_idx; (i = names.hasNext(i)) != -1; i++) {
                if (names.getType(i) == kind) {
                    Slot s = frame.getSlot(null, names.getSlot(i));
                    if( s instanceof MethodSlot && (getters == s.isGetter()) )
                    {
                        cur_idx = i+1;
                        return new Method(s, names.getNamespace(i), names.getName(i));
                    }
                }
            }
            if( frame == cframe )
            {
                // If we get here, then we have gone through all the class members,
                // so now do the instance members
                frame = cframe.prototype;
                cur_idx = 0;
                return advanceNext();
            }
            return null;
        }

        public flex2.compiler.abc.Method next()
        {
            Method meth;
            if( next_meth != null)
            {
                meth = next_meth;
                next_meth = null;
            }
            else
            {
                meth = advanceNext();
            }

            if ( meth == null )
                throw new NoSuchElementException();

            return meth ;
        }

        public void remove()
        {

        }
    }
}
