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

import macromedia.asc.embedding.avmplus.ClassBuilder;
import macromedia.asc.embedding.avmplus.InstanceBuilder;
import macromedia.asc.util.*;

import java.util.HashMap;
import java.util.Map;

import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_object;

/**
 * The interface for all types.
 *
 * @author Jeff Dyer
 */
public final class TypeValue extends ObjectValue
{
    public static void init()
    {
    }

    public static void clear()
    {
    }

    /**
     * Create a new TypeValue, or reuse an existing TypeValue if one already exists
     * This is neccessary so that when we recompile a type, we don't have to patch up all
     * pointers to that type.
     * @param cx Context we're using
     * @param builder The builder to use while we're rebuilding the type
     * @param name The classname we want the TypeValue for
     * @param type_id
     * @return a re-inited TypeValue
     */
    public static TypeValue defineTypeValue(Context cx, Builder builder, QName name, int type_id)
    {
        String fullname = name.toString();
 
        TypeValue type = cx.userDefined(fullname);
        if (type == null)
        {
            type = new TypeValue(cx, builder, name, type_id);
            cx.setUserDefined(fullname, type);
            type.resolved = true;
        }
        else
        {
            // Need to set this early, as clearInstance will call Builder.build
            // which can call back into this TypeVal.  Setting this now avoids some
            // infinite recursion.
            type.resolved = true;

            type.clearInstance(cx, builder, null, fullname.intern(), false);
            type.type_id = type_id;
            // Don't clear the prototype, we can reuse the object value
//			type.prototype.clearInstance() = null;
            type.name = name;
            type.type = null;
            type.baseclass = null;

            if( type.default_typeinfo != null )
            {
                type.default_typeinfo.clearInstance();
            }
            if( type.explicit_nonnullable_typeinfo != null )
            {
                type.explicit_nonnullable_typeinfo.clearInstance();
            }
            if( type.explicit_nullable_typeinfo != null )
            {
                type.explicit_nullable_typeinfo.clearInstance();
            }
        }
        return type;
    }

    /**
     * Return the TypeValue for a given name.  If the TypeValue does not exist yet, then a dummy
     * TypeValue is created and returned.  The dummy type value serves as a place holder, and will
     * be filled in later when that type is actually processed (from an ABC, or .as, or where ever).
     * This is used by AbcParser, since it needs to set up references to Types that may not have been
     * compiled yet.
     * @param cx Context we're using
     * @param name Name of the type we want
     * @return the TypeValue for the name
     */
    public static TypeValue getTypeValue(Context cx, QName name)
    {
        String fullname = name.toString();

        TypeValue type = cx.userDefined(fullname);

        if (type == null)
        {
            if( "Vector" == name.name && name instanceof ParameterizedName )
            {
                ParameterizedName pname = (ParameterizedName) name;
                QName indexed_name = pname.type_params.at(0);
                TypeValue indexed_type;

                if (cx.isBuiltin(indexed_name.toString()))
                {
                    indexed_type = cx.builtin(indexed_name.toString());
                }
                else
                {
                    indexed_type = getTypeValue(cx, indexed_name);
                }

                type = indexed_type.getParameterizedType(fullname);

                if (type == null)
                {
                    type = new TypeValue(cx, name);
                    type.indexed_type = indexed_type;
                    indexed_type.addParameterizedType(fullname, type);
                }
            }

            if (type == null)
            {
                type = new TypeValue(cx, name);
            }
            
            cx.setUserDefined(fullname, type);
        }

        return type;
    }

    public ObjectValue prototype;
    public TypeValue baseclass;
    public boolean is_parameterized;
    public TypeValue indexed_type;

    public QName name;

    public TypeValue(Context cx, Builder builder, QName name, int type_id)
    {
        super(cx, builder, null);
        this.type_id = type_id;
        this.prototype = null;
        this.name = name;
        this.type = null;
        this.baseclass = null;
        super.name = this.name.toString();
        this.resolved = false;
    }

    private TypeValue(Context cx, QName name)
    {
        super((TypeValue)null);
        this.name = name;
        this.resolved = false;
    }

    public TypeInfo getType(Context cx)
    {
        return cx.typeType().getDefaultTypeInfo();
    }

    public int type_id;

    // Whether this TypeValue has been compiled for real yet
    // AbcParser needs to set up dummy, place holder TypeValues - this gets set to true
    // once the actual type is processed (by FA, or AbcParser)
    public boolean resolved;

    public int getTypeId()
    {
        return type_id;
    }

    public String toString()
    {
        return name!=null?name.toString():"";
    }

    public boolean includes(Context cx, TypeValue type)
    {
        if (this == cx.noType())
        {
            return true;
        }

        if( !resolved )
            resolve(cx);

        if (!isInterface())
        {
            while (type != null)
            {
                if( this == type )
                {
                    return true;
                }
                type = type.baseclass;
            }
        }
        else
        if (type != null) // type == null -> * type
        {
            InterfaceWalker interfaceWalker = new InterfaceWalker(type);
            while (interfaceWalker.hasNext())
            {
                if (interfaceWalker.next().type.getTypeValue() == this)
                {
                    return true;
                }
            }
        }

        return false;
    }

    public void build(Context cx, ObjectValue ob)
    {
    }

    public ObjectValue proto()
    {
           return null;
    }

    public String getPrintableName() {
        return name.name;
    }

    public boolean isNumeric(Context cx) {
        return ((this == cx.intType()) || (this == cx.uintType()) || (this == cx.doubleType()) ||
                (this == cx.numberType()) || (cx.statics.es4_numerics && (this == cx.decimalType())));
    }

    public boolean isDynamic() { return false; }

    private TypeInfo default_typeinfo = null;
    private TypeInfo explicit_nullable_typeinfo = null;
    private TypeInfo explicit_nonnullable_typeinfo = null;

    public boolean is_nullable = true;

    public TypeInfo getDefaultTypeInfo()
    {
        if( default_typeinfo == null )
            default_typeinfo = new TypeInfo(this, this.is_nullable, true);
        return default_typeinfo;
    }

    public TypeInfo getTypeInfo(boolean nullable)
    {
        TypeInfo ti = nullable ? explicit_nullable_typeinfo : explicit_nonnullable_typeinfo;

        if( ti == null)
        {
            if( nullable )
            {
                ti = explicit_nullable_typeinfo = new TypeInfo(this, nullable, false);
            }
            else
            {
                ti = explicit_nonnullable_typeinfo = new TypeInfo(this, nullable, false);
            }
        }
        if( ti.getPrototype() == this.prototype )
        {
            // Create a dummy prototype object that the new TypeInfo can point too.
            ObjectValue nullable_proto = new ObjectValueWrapper(prototype);
            nullable_proto.builder = prototype.builder;
            nullable_proto.type = ti;
            ti.setPrototype(nullable_proto);
        }
        return ti;
    }

    private Map<String, TypeValue> parameterizedTypes;

    public void addParameterizedType(String name, TypeValue typeValue)
    {
        if (parameterizedTypes == null)
        {
            parameterizedTypes = new HashMap<String, TypeValue>();
        }

        parameterizedTypes.put(name, typeValue);
    }

    public TypeValue getParameterizedType(String name)
    {
        TypeValue result = null;

        if (parameterizedTypes != null)
        {
            result = parameterizedTypes.get(name);
        }

        return result;
    }
    
    /**
     *  Propagate type data from an uinstantiated parameterized type (e.g., Vector)
     *  to a specialized instantiation (e.g., Vector&lt;int&gt;
     *  @param this - the specialized, instantiated type.
     *  @param uninstantiated_type - the "parent" uninstantiated type.
     */
    public void copyInstantiationData(TypeValue uninstantiated_type)
    {
    	this.builder.is_final = uninstantiated_type.builder.is_final;
    }

    /**
     * copy a typevalue
     */
    protected TypeValue(TypeValue type)
    {
        super((ObjectValue)type);
        this.type_id = type.type_id;
        this.prototype = new ObjectValue(type.prototype);
        this.name = type.name;
        this.type = type.type;
        this.baseclass = type.baseclass;
    }

    /**
     * Creates a new TypeValue, identical to this.
     * Also copies prototype.
     * This is needed by the Flex Symbol Table, but this will hopefully go away once flex's
     * need to copy TypeValues is fixed.
     * @return a new TypeValue, copied from this.
     */
    public TypeValue copyType()
    {
        return new TypeValue(this);
    }

    /**
     * Resolve an "unresolved" type.  Currently this only affects parameterized types that come from AbcParser.
     * This could be extended to a more general resolve on demand, with the data only living in an ABC, or .AS,
     * or wherever until needed.
     * @param cx    Context
     * @return      whether or not the type was resolved.
     */
    private boolean resolve(Context cx)
    {
        if( resolved )
            return true;

        if( this.indexed_type != null )
        {
            ParameterizedName pname = name instanceof ParameterizedName ? (ParameterizedName)name : null;
            if( pname != null )
            {
                instantiateParameterizedType(cx, pname);
                assert resolved ;
            }
        }
        return resolved;
    }

    /**
     * Instantiate a parameterized type.  If the TypeValue representing pname is already resolved,
     * then it is returned.  If it is not resolved then the parameterized type specififed by pname is
     * initialized - new type is set up, slots copied from base type. etc.
     * i.e. this will create a specific instantiation of Vector.
     * @param cx    Context used to initialize the type
     * @param pname The name of the parameterized type
     * @return      TypeValue representing the type specified by pname
     */
    static TypeValue instantiateParameterizedType(Context cx, ParameterizedName pname)
    {
        TypeValue cframe = getTypeValue(cx, pname);
        if( cframe.resolved )
            return cframe;

        ObjectValue prot_ns = cx.getNamespace(pname.toString(), Context.NS_PROTECTED);
        ObjectValue static_prot_ns = cx.getNamespace(pname.toString(), Context.NS_STATIC_PROTECTED);

        // This should fill in this type
        cframe = TypeValue.defineTypeValue(cx, new ClassBuilder(pname, prot_ns, static_prot_ns), pname, TYPE_object);

        cframe.type = cx.typeType().getDefaultTypeInfo();
        ObjectValue iframe = new ObjectValue(cx,new InstanceBuilder(pname),cframe);
        cframe.prototype = iframe;

        //  TODO: Allow for other parameterized types some day.
        TypeValue uninstantiated_generic = cx.vectorObjType();

        FlowAnalyzer.inheritClassSlotsStatic(cframe, iframe, uninstantiated_generic, cx);
        cframe.copyInstantiationData(uninstantiated_generic);

        return cframe;
    }

    public boolean hasName(Context cx, int kind, String name, ObjectValue qualifier)
    {
        if( !resolved )
            resolve(cx);
        
        return super.hasName(cx, kind, name, qualifier);
    }

    public boolean hasNameUnqualified(Context cx,  String name, int kind)
    {
        if( !resolved )
            resolve(cx);

        return super.hasNameUnqualified(cx, name, kind);
    }
    
    public Namespaces hasNames(Context cx, int kind, String name, Namespaces namespaces, boolean search_base_objs)
    {
        if( !resolved )
            resolve(cx);

        return super.hasNames(cx, kind, name, namespaces, search_base_objs);
    }
}
