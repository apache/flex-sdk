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

import macromedia.asc.parser.Node;
import macromedia.asc.parser.Tokens;
import macromedia.asc.util.BitSet;
import macromedia.asc.util.Context;
import macromedia.asc.util.Namespaces;
import macromedia.asc.util.ObjectList;
import macromedia.asc.embedding.ErrorConstants;
import macromedia.asc.embedding.avmplus.ClassBuilder;
import macromedia.asc.embedding.avmplus.InstanceBuilder;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_object;
import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.util.BitSet.*;
import static macromedia.asc.semantics.Slot.CALL_Method;

/**
 * ReferenceValue
 *
 * @author Jeff Dyer
 */
public final class ReferenceValue extends Value implements ErrorConstants
{
    private ObjectValue base;
    private int get_slot_index;
    private int set_method_slot_index;
    private BitSet ud_bits;
    private TypeInfo type;
    private int src_position;
    public Slot slot;
    public String name;
    public Namespaces namespaces;
    public ObjectList<ReferenceValue> type_params;

    public boolean is_nullable = true;
    public boolean has_nullable_anno = false;

    public void setPosition(int pos) { src_position = pos; }
    public int getPosition() { return src_position; }

    public ReferenceValue(Context cx, ObjectValue base, String name, ObjectValue qualifier)
    {
        this(cx, base, name, qualifier, GET_TOKEN);
    }

    public ReferenceValue(Context cx, ObjectValue base, String name, ObjectValue qualifier, int kind)
    {
        this.setKind(kind);
        this.base = base;
        assert name.intern() == name;
        this.name = name;
        setQualified(qualifier != null);
        setGetSlotIndex(-1);
        setSetSlotIndex(-1);
        setScopeIndex(-1);

        this.namespaces = cx.statics.internNamespaces.intern(qualifier);

        /* Redundant
        slot = null;
        block = 0;
        ud_bits = null;
        type = null;
        */
    }

    public ReferenceValue(Context cx, ObjectValue base, String name, Namespaces namespaces)
    {
        this(cx, base, name, namespaces, GET_TOKEN);
    }

    public ReferenceValue(Context cx, ObjectValue base, String name, Namespaces namespaces, int kind)
    {
        this.setKind(kind);
        this.base = base;
        assert name.intern() == name;
        this.name = name;

        this.namespaces = cx.statics.internNamespaces.intern(namespaces);

        slot = null;
        setGetSlotIndex(-1);
        setSetSlotIndex(-1);
        setScopeIndex(-1);
        ud_bits = null;
        type = null;
    }

    public void setIsAttributeIdentifier(boolean is_attrid)
    {
        flags = is_attrid ? (flags|IS_ATTRID_Flag) : (flags&~IS_ATTRID_Flag);
    }

    public boolean isAttributeIdentifier()
    {
        return (flags&IS_ATTRID_Flag)!=0;
    }

    public Value getValue(Context cx)
    {
        Slot s = getSlot(cx, getKind());

        if (s != null && s.getMethodID() < 0 /*else its an accessor*/)
        {
            return s.getValue();
        }
        else
        {
            return null;
        }

    }
    // The slot type is the type that is determined by the
    // declaration of the slot (e.g. var a : A, would have
    // the type "instance of A"

    // The definition type is the type derived through data
    // flow analysis to be the most specific type computable
    // given the definitions (assignments) that might determine
    // its value

    // The definition type will always be a proper subtype of
    // the slot type

    // ISSUE: references have no idea of the parameter types of
    //        the thing they refer too

    public TypeInfo getType(Context cx)
    {
        return getType(cx,this.getKind());
    }

    public TypeInfo getType(Context cx, int kind)
    {
        if (this.type == null)
        {
            TypeInfo deftype;
            TypeInfo slottype = null;
            deftype = cx.getDefType(this.ud_bits);
            Slot s = this.getSlot(cx,kind);
            if (s != null)
            {
                slottype  = s.getType();
            }

            if( slottype == null )
            {
                slottype = cx.noType().getDefaultTypeInfo();
            }

            // If the slot type includes the def type (is more generic
            // than the def type), then use the def type as the type of
            // this reference

            // [ed] ISSUE this needs to follow the same rules as coersion.
            // upcasts and downcasts must be assumed to be incompatible

            if( slottype.getTypeValue().includes(cx,deftype != null ? deftype.getTypeValue() : null))
            {
            	TypeValue tv = slottype.getTypeValue();
            	// RES I'm not sure whether isNumber is right since old code didn't do this for int
                if (tv.isNumeric(cx) || (tv == cx.noType())) // exception for number & object
                    this.type = slottype;
                else
                    this.type = deftype;
            }
            else
            {
                this.type = slottype;
            }

            if( this.type == null)
            {
                this.type = cx.noType().getDefaultTypeInfo();
            }
        }

        return this.type;
    }

    public Slot getSlot(Context cx)
    {
        return getSlot(cx, GET_TOKEN);
    }

    /** if you use the flag GET_SLOT_DONT_BIND, it will get the slot without rebinding */
    public Slot getSlot(Context cx, int kind)
    {
        // this.kind is the directly referencable slot's kind.
        // If kind is empty_token or new_token, then this.kind
        // will be get_token. After the get slot is found, the
        // implicit call or construct slot will be found.

        if (this.slot == null)
        {
            if( this.isAttributeIdentifier() )
            {
                return null;  // never bind attribute references at ct
            }

            this.setKind(kind == SET_TOKEN ? SET_TOKEN : GET_TOKEN);

            if (lookup(cx, flags))
            {
                // lookup has the side-effect of binding
                // this reference to its defining slot.

                if( kind == this.getKind() )
                {
                    return this.slot;
                }   // Otherwise, continue below
            }
            else if(Builder.removeBuilderNames && kind != GET_TOKEN)
            {
                return null;
            }
        }

        Slot slot = this.slot;

        // If the current slot is the wrong kind, get the desired slot
        // in the current frame/object. Always get the slot if it is not
        // a get or set slot.

        if( this.getKind() != kind )
        {
            ObjectValue base;
            if (this.base != null)
            {
                base = this.base;
                // This base must be an object since
                // we already have found a slot.
            }
            else if (getScopeIndex() >= 0 &&
                     getScopeIndex() < cx.getScopes().size())  
                     // FIXME the second condition is a targeted fix for ASC-3734
                     // the evaluator for FunctionCommonNode isn't managing scopes
                     // properly with nested scopes, and it shows when there is an
                     // reference to a named function expression
            {
                base = cx.getScopes().get(getScopeIndex());
            }
            else
            {
                return null;  // This means that this is a lexical reference
                           // with no binding
            }

            switch (kind)
            {
                case SET_TOKEN:
                    slot = base.getSlot(cx, this.getSetSlotIndex());
                    this.slot = slot;
                    this.setKind(SET_TOKEN);
                    break;
                case GET_TOKEN:
                    slot = base.getSlot(cx, this.getGetSlotIndex());
                    this.slot = slot;
                    this.setKind(GET_TOKEN);
                    break;
                default:
                    // 1/Get the getter slot
                    // 2/Make it the current slot
                    // 3/Get the implied slot index
                    // 4/Get the implied slot
                    slot = base.getSlot(cx, this.getGetSlotIndex());
                    this.slot = slot;
                    this.setKind(GET_TOKEN);
                    int index;
                    if( slot != null)
                    {
                        index = slot.implies(cx,kind);
                        slot  = base.getSlot(cx,index);
                    }
                    break;
            }
            if( slot != null && cx.checkVersion() && slot.getVersion() > cx.version() )
                cx.error(this.src_position, kError_WrongVersion, this.name, String.valueOf(slot.getVersion()), String.valueOf(cx.version()));
        }
        return slot;

    }

    /*
     * Lookup qualified name in the given context.
     */

    public boolean lookup(Context cx, final int flags)
    {
        boolean is_found = false;

        if( this.base == null )
        {
            // If there is no base reference, search for the
            // binding from the inside to the outside of the
            // scope chain. Fix up this reference's base member
            // and recurse.
        	
            ObjectList<ObjectValue> scopes = cx.getScopes();
            int lowestScope = isTypeAnnotation() ? 0 : (cx.statics.withDepth+1);
            for(int i=scopes.size() - 1; i >= lowestScope; i--)
            {
                this.base = scopes.at(i); // Set the base value
                is_found = lookupWithBase(cx, flags);
                if(is_found)
                {
                    // Found one. Clear the temporary base value
                    // and set the scope index.
                    setScopeIndex(i);
                    break;
                }
            }

            this.base = null; // clear temporary base, in case of later lookup of differnt kind
        }
        else
        {
            // If there is a base reference, search for the
            // binding in this object and then up the proto
            // chain.

            is_found = lookupWithBase(cx, flags);

        }

        return is_found;
    }

    public boolean lookupWithBase(Context cx, final int flags)
    {
        if (!isQualified())
        {
            return this.findUnqualified(cx, flags);
        }
        else
        {
            return this.findQualified(cx, flags);
        }
    }

    public boolean findQualified(Context cx, final int flags)
    {
        for (int i = 0, size = namespaces.size(); i < size; i++)
        {
            ObjectValue qualifier = namespaces.get(i);
            // this is a qualified reference with a base object
            for (ObjectValue obj = this.base; obj != null; obj = obj.proto())
            {
                if (obj.hasName(cx,getKind(),name,qualifier))
                {
                    if( type_params != null ) {
                        int index = obj.getSlotIndex(cx,getKind(),name,qualifier);
                        Slot slot = obj.getSlot(cx,index);
                        bindToTypeParamSlot(cx, obj, qualifier, slot);
                    }
                    else
                        bindToSlot(cx, obj, qualifier);

                    return true;
                }
            }
        }

        return false;
    }


    public boolean findUnqualified(Context cx, final int flags)
    {
        Namespaces hasNamespaces = null;

        // walk over each ObjectValue and look for our name
        for (ObjectValue obj = this.base; obj != null; obj = obj.proto())
        {
            hasNamespaces = obj.hasNames(cx,getKind(),name,namespaces);

            if (hasNamespaces != null)
            {

                ObjectValue localQualifier = null;
                boolean error_reported = false;

                if( getKind() == SET_TOKEN || getKind() == GET_TOKEN )
                {
                    // If this is a getter or setter verify that there are no corresponding getter/setter
                    // in another of the open namespaces, which would cause an ambiguous reference error at runtime.
                    int opposite_kind = getKind() == SET_TOKEN ? GET_TOKEN : SET_TOKEN;
                    Namespaces hasNamespaces2 = obj.hasNames(cx,opposite_kind,name,namespaces);
                    if (hasNamespaces2 != null)
                    {
                        boolean isOnlyProtected = hasNamespaces.size() == 1 ? hasNamespaces.at(0).isProtected() : false;
                        for( int i = 0; i < hasNamespaces2.size(); i++ )
                        {
                            localQualifier = hasNamespaces2.at(i);
                            // NOTE ignore protected namespaces if hasNamespaces has a protected namespace only
                            if( !error_reported && !(isOnlyProtected && localQualifier.isProtected()) && !hasNamespaces.contains(localQualifier) )
                            {
                                // this will trigger an error below
                                hasNamespaces.add(localQualifier);
                                break;
                            }
                        }
                    }
                }

                // Verify that all matched names point to a single slot.
                int last_index = 0;
                Slot slot = null;
                for( int i = 0; i < hasNamespaces.size(); i++ )
                {
                    localQualifier = hasNamespaces.at(i);
                    int index = obj.getSlotIndex(cx,getKind(),name,localQualifier);
                    slot = obj.getSlot(cx,index);
                    if( slot == null )
                    {
                        //cx.error("internal error: null reference to " + name,this.src_position);
                        //   this only seems to happen after an override not found error. ignore for now
                    }
                    else
                    if( slot.getBaseNode() == null ) // only count the non-imported bindings
                    {
                        if( last_index!=0 && index!=last_index && !error_reported )
                        { // if we found a definition at two different indices, then it's ambiguous
                            cx.error(this.src_position, kError_AmbiguousReference, name);
                            error_reported = true; // only report the error once, since there could be more than 2 matches
                        }
                        last_index = index;
                    }
                }

                if( type_params != null )
                {
                    bindToTypeParamSlot(cx, obj, localQualifier, slot);
                }
                else
                {
                    bindToSlot(cx, obj, localQualifier);
                }
                hasNamespaces.clear();
                return true;
            }
        }

        return false;
    }

    private void bindToTypeParamSlot(Context cx, ObjectValue obj, ObjectValue qualifier, Slot s)
    {
        if( s.getValue() instanceof TypeValue )
        {
            TypeValue factory = (TypeValue)s.getValue();

            ObjectList<TypeValue> types = new ObjectList<TypeValue>(type_params.size());
            for( int i = 0, limit = type_params.size(); i < limit; ++i)
            {
                ReferenceValue r = type_params.at(i);
                Slot type_slot = r.getSlot(cx);
                if( type_slot != null )
                {
                    Value v = type_slot.getValue();
                    if( v instanceof TypeValue )
                    {
                        types.add((TypeValue)v);
                    }
                }
                else if( "*".equals(r.name) && r.namespaces.contains(cx.publicNamespace()))
                {
                    types.add(cx.noType());
                }
                if( types.size() != i+1 )
                {
                    // Couldn't resolve type parameter, so whole type is unkown
                    this.slot = null;
                    return;
                    //cx.error(r.getPosition(), kError_UnknownType, r.name);
                }
            }

            Slot slot;
            if( factory.is_parameterized )
            {
                ParameterizedName fullname = new ParameterizedName(qualifier, name, types);

                String name = fullname.getNamePart();
                int slot_id;

                if( !obj.hasName(cx, Tokens.GET_TOKEN, name, qualifier) )
                {
                    slot_id = obj.builder.ImplicitVar(cx,obj,name,qualifier,cx.typeType(),-1,-1,-1);

                    TypeValue cframe = types.at(0).getParameterizedType(name);

                    if (cframe == null)
                    {
                        cframe = TypeValue.instantiateParameterizedType(cx, fullname);
                        types.at(0).addParameterizedType(name, cframe);
                    }

                    slot = obj.getSlot(cx, slot_id);
                    slot.setValue(cframe);
                    slot.setConst(true);
                    slot.declaredBy = null;
                    obj.builder.ImplicitCall(cx,obj,slot_id,cframe,CALL_Method,-1,-1);
                    obj.builder.ImplicitConstruct(cx,obj,slot_id,cframe,CALL_Method,-1,-1);

                    if( factory == cx.vectorType() )
                    {
                        cframe.indexed_type = types.at(0);
                    }
                }
                else
                {
                    slot_id = obj.getSlotIndex(cx, Tokens.GET_TOKEN, name, qualifier);
                    slot = obj.getSlot(cx, slot_id);
                }

                bindToSlot(cx, name, obj, fullname.ns);
            }
            else
            {
                cx.internalError("type parameters with a non-parameterized type");
            }
        }
    }

    private void bindToSlot(Context cx, ObjectValue obj, ObjectValue qualifier)
    {
        bindToSlot(cx, name, obj, qualifier);
    }

    private void bindToSlot(Context cx, String name, ObjectValue obj, ObjectValue qualifier)
    {
        int set_slot_index    = obj.getSlotIndex(cx,SET_TOKEN,  name,qualifier);
        int get_slot_index    = obj.getSlotIndex(cx,GET_TOKEN,  name,qualifier);
        int method_slot_index = obj.getSlotIndex(cx,EMPTY_TOKEN,name,qualifier);

        this.setGetSlotIndex(get_slot_index);
        if (method_slot_index != -1)
        {
            this.setMethodSlotIndex(method_slot_index);
        }
        else
        {
            this.setSetSlotIndex(set_slot_index);
        }
        this.slot = obj.getSlot(cx,obj.getSlotIndex(cx,getKind(),name,qualifier));

        if( cx.checkVersion() )
        {
            if( this.slot.getVersion() > cx.version() )
            {
                cx.error(this.src_position, kError_WrongVersion, this.name, String.valueOf(this.slot.getVersion()), String.valueOf(cx.version()));
                //new Exception().printStackTrace();
            }
        }
        /* don't early bind to xml properties.  XML tag values show up as dynamic properties which trump any predefined properties
        /*  by the same name (i.e. an xml tag named "name" should trump the XML method named "name").  It's not safe to bind to any
        /*  declared xml property at compile time. */
        boolean isXMLProperty = this.slot != null && this.slot.declaredBy != null &&
                                (this.slot.declaredBy.type != null && (this.slot.declaredBy.type.getTypeValue() == cx.xmlType() || this.slot.declaredBy.type.getTypeValue() == cx.xmlListType()) );

        if (cx.useStaticSemantics() && !isXMLProperty && type_params == null)
        {
            this.setQualifier(cx, qualifier);
        }
    }

    /*
     * Lookup a name that has one of the used namespaces.
     *
     * 1 Traverse to root of proto chain, pushing all objects
     *   onto a temporary stack.
     * 2 In lifo order, see if one or more of the qualified
     *   names represented by the name and the used qualfiers
     *   is in the top object on the stack. Repeat for all
     *   objects on the stack until one object with at least
     *   one match is found, or all objects have been searched.
     * 3 Create a new set of namespaces that inclues all
     *   the qualifiers of all the names that matched in the
     *   previous step.
     * 4 Starting with the most derived object, search to
     *   proto chain for one or more of the qualified names
     *   represented by the name and the new set of used
     *   qualifiers.
     * 5 If the found set represents more than one slot, throw
     *   and error exception. Otherwise, return true.
     * 6 If no matching names are found, return false.
     */


    public void calcUseDefinitions(Context cx, BitSet rch_bits)
    {
        Slot slot;

        getSlot(cx,GET_TOKEN);  // find the slot

        if (getGetSlotIndex() < 0)
            return;

        if (base != null && base.getType(cx).getTypeValue() == cx.noType() && getGetSlotIndex() >= 0)
        {
            slot = base.getSlot(cx, this.getGetSlotIndex());
        }
        else if (getScopeIndex() == 0 && getGetSlotIndex() >= 0)
        {
            slot = cx.globalScope().getSlot(cx, getGetSlotIndex());
        }
        else if (getScopeIndex() == cx.getScopes().size() - 1)
        {
            slot = cx.scope().getSlot(cx, getGetSlotIndex());
        }
        else
        {
            return;
        }

        // If a slot was found, then compute the use - definition
        // bits for this reference.

        if (slot != null)
        {
            this.ud_bits = and(rch_bits, slot.getDefBits());
        }
    }

    public boolean usedBeforeInitialized()
    {
        return BitSet.isEmpty(this.ud_bits);
    }

    public int getSlotIndex(int kind)
    {
        if (kind == GET_TOKEN)
        {
            return getGetSlotIndex();
        }
        if (kind == SET_TOKEN)
        {
            return getSetSlotIndex();
        }
        if (kind == EMPTY_TOKEN)
        {
            return getMethodSlotIndex();
        }
        assert(false);
        return -1; // throw "some other kind of token";
    }


    public int getScopeIndex(int kind)
    {
        return getScopeIndex();
    }

    public ReferenceValue setBase(ObjectValue base)
    {
        this.base = base;
        return this;
    }

    public ObjectValue getBase()
    {
        return this.base;
    }

    public boolean isReference()
    {
        return true;
    }

    public void setQualifier(Context cx, ObjectValue qual)
    {
        setQualified(qual != null);
        this.namespaces = cx.statics.internNamespaces.intern(qual);
    }

    public String toMultiName()
    {
        return namespaces.toString() + "::" + name;
    }

    public boolean isQualified()
    {
        return (flags&HAS_QUALIFIER_Flag)!=0;
    }

    private void setQualified(boolean qualified)
    {
        flags = qualified ? (flags|HAS_QUALIFIER_Flag) : (flags&~HAS_QUALIFIER_Flag);
    }

    public String toString()
    {
        if(Node.useDebugToStrings)
            return "RefValue: <" + type + "> " + (name!=null?name+"::":"") + namespaces.toString();
        else
            return super.toString();
    }

    public void setImmutableNamespaces(Namespaces namespaces)
    {
        this.namespaces = namespaces;
    }

    // The name is "getImmutableNamespaces" to serve as a reminder to
    // the caller that the returned Namespaces must NOT be modified!
    public Namespaces getImmutableNamespaces()
    {
        return namespaces;
    }

    public void setScopeIndex(int scope_index)
    {
        flags &= ~SCOPE_INDEX_Mask;
        flags |= ((scope_index<<SCOPE_INDEX_Shift)&SCOPE_INDEX_Mask);
    }

    public int getScopeIndex()
    {
        short i = (short)((flags&SCOPE_INDEX_Mask)>>SCOPE_INDEX_Shift);
        return i; 
    }

    public void setKind(int kind)
    {
        flags &= ~KIND_Mask;
        flags |= ((kind<<KIND_Shift)&KIND_Mask);
    }

    public int getKind()
    {
        byte b = (byte)((flags&KIND_Mask)>>KIND_Shift);
        return b; 
    }

    private void setGetSlotIndex(int get_slot_index)
    {
        this.get_slot_index = get_slot_index;
    }

    private int getGetSlotIndex()
    {
        return get_slot_index;
    }

    private void setMethodSlotIndex(int method_slot_index)
    {
        flags |= HAS_METHOD_INDEX_Flag;
        this.set_method_slot_index = method_slot_index;
    }

    private int getMethodSlotIndex()
    {
        return ((flags&HAS_METHOD_INDEX_Flag)!=0) ? set_method_slot_index : -1;
    }

    private void setSetSlotIndex(int set_slot_index)
    {
        flags &= ~HAS_METHOD_INDEX_Flag;
        this.set_method_slot_index = set_slot_index;
    }

    private int getSetSlotIndex()
    {
        return ((flags&HAS_METHOD_INDEX_Flag)!=0) ? -1 : set_method_slot_index;
    }

    public void setTypeAnnotation(boolean isTypeAnnotation)
    {
        flags = isTypeAnnotation ? (flags|TYPE_ANNOTATION_Flag) : (flags&~TYPE_ANNOTATION_Flag);
    }

    public boolean isTypeAnnotation()
    {
        return (flags&TYPE_ANNOTATION_Flag) != 0;
    }

    public void setNullableAnnotation(boolean is_explicit, boolean is_nullable)
    {
        this.has_nullable_anno = is_explicit;
        this.is_nullable = is_nullable;
    }

    public boolean isConfigRef()
    {
        return this.getImmutableNamespaces() != null && this.getImmutableNamespaces().size() == 1 &&
                this.getImmutableNamespaces().at(0).isConfigNS();
    }

    public void addTypeParam(ReferenceValue type)
    {
        if( type_params == null )
        {
            type_params = new ObjectList<ReferenceValue>(1);
        }
        type_params.add(type);
    }
    
    /**
     * Get the name of the type for use in a diagnostic.
     * @return The type name if the type's not parameterized.
     * @return The name of the type's parameter, if it is.
     * @note Assumes there's only one type parameter, and
     *   that the parameterized type name is noise.  These
     *   assumptions hold for Vector use cases.
     */
    public String getDiagnosticTypeName()
    {
    	if ( null == type_params || type_params.size() == 0)
    		return name;
    	else
    		return type_params.at(0).getDiagnosticTypeName();
    }
}
