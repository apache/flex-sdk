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

package macromedia.asc.util;

import macromedia.asc.embedding.CompilerHandler;
import macromedia.asc.embedding.avmplus.ByteCodeFactory;
import macromedia.asc.embedding.avmplus.Features;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.semantics.*;
import macromedia.asc.semantics.MetaData;

import java.util.*;

/**
 * @author Clement Wong
 */
public class ContextStatics
{
	// HACK: Flex hack -- setting this to false removes the "[Compiler] Error#..." header from error output.
	public static boolean useVerboseErrors = true;

	/* Used so that shellErrorString() and lint warnings return error strings that are
	     * system/punctuation/language independent. Used with -sanity switch.
	     * Suppresses most unnecesary output (including 'bytes written', etc.).
	     */
	public static boolean useSanityStyleErrors = false;

	// used to trigger individual warning callbacks for each warning via 
	// simpleLogWarnings (as useSanityStyleErrors still does). used by authoring. 
	public static boolean useSimpleLogWarnings = false;

	// used by authoring to omit trace statements
	public static boolean omitTrace = false;

	Emitter emitter;
	NodeFactory nodeFactory;
	ByteCodeFactory bytecodeFactory;
	ObjectList<ObjectValue> scopes = new ObjectList<ObjectValue>();
    IntList versions = new IntList();
    public int withDepth = -1;
	public NamespacesTable internNamespaces = new NamespacesTable();
	public CompilerHandler handler = null;
	String pathspec;
	String scriptname;

	public static final int LANG_EN		= 0;
    public static final int LANG_CN		= 1;
    public static final int LANG_CS		= 2;
	public static final int LANG_DA		= 3;
	public static final int LANG_DE		= 4;
	public static final int LANG_ES		= 5;
	public static final int LANG_FI		= 6;
	public static final int LANG_FR		= 7;
	public static final int LANG_IT		= 8;
	public static final int LANG_JP		= 9;
	public static final int LANG_KR		= 10;
	public static final int LANG_NB		= 11;
	public static final int LANG_NL		= 12;
	public static final int LANG_PL		= 13;
    public static final int LANG_PT		= 14;
    public static final int LANG_RU		= 15;
    public static final int LANG_SV		= 16;
    public static final int LANG_TR		= 17;
    public static final int LANG_TW		= 18;

	ObjectValue global;

	HashMap<String, TypeValue> builtins;
	public Map<String, TypeValue> userDefined;
    HashMap<String, ObjectValue> namespaces;
    HashMap<String, ObjectValue> internal_namespaces;
    HashMap<String, ObjectValue> protected_namespaces;
    HashMap<String, ObjectValue> static_protected_namespaces;
    HashMap<String, ObjectValue> private_namespaces;

	Set<String> validImports;
    // maps ErrorCode to its localized error string.  Must not be static, there may be multiple different langauge contexts in use at the same time
    //  (on the flex server).
	public HashMap<Number,String> errorCodeMap = new HashMap<Number,String>();
    public  int languageID	= 0;

	public ObjectValue globalPrototype;

    private int nextSlotID = 1;
    private int expectedSlotID = -1;

    public int getNextSlotID()
    {
	    if (expectedSlotID != -1)
	    {
		    int id = expectedSlotID;
		    expectedSlotID = -1;
		    return id;
	    }
	    else
	    {
		    return nextSlotID++;
	    }
    }
    public void pushExpectedSlotID(int id)
    {
	    expectedSlotID = id;
    }

	int unresolved_ns_count = 0;
	public int ticket_count = 0;
	public boolean use_static_semantics = false;
    public int dialect = 9;

    public boolean check_version = false;

    /**
     * For use with auto-using namespaces during compilation.
     * You must populate this before Parser.parse() for the side-effect to occur.
     * 
     * Never null, you are always free to clear it.
     */
    public final ObjectList<String> use_namespaces = new ObjectList<String>();
    
    /**
     * Returns a list filled with namespaces that should be automatically
     * opened, based on the current target player, e.g. flash10, AS3.
     *
     * You would add these to ContextStatics.use_namespaces before Parse.parse().
     *
     * This code is not currently used; it was written for 'flash10' which was removed.
     * 
     * @see macromedia.asc.util.ContextStatics.use_namespaces
     */
    public static ObjectList<String> getRequiredUseNamespaces(int targetPlayerMajorVersion)
    {
        final ObjectList<String> use_namespaces = new ObjectList<String>();
        
        /*
        // no longer needed, but this is how you would do it
        if (targetPlayerMajorVersion >= 10)
        {
            use_namespaces.add("flash10");
        }
        */
        
        return use_namespaces;
    }
    
    /**
     * Returns the Features.TARGET_AVM* for a given SWF version. 
     */
    public static int getTargetAVM(int swfVersion)
    {
        if (swfVersion > 9)
        {
            return Features.TARGET_AVM2;
        }
        
        return Features.TARGET_AVM1;
    }

    public void setAbcVersion(int targetAVM)
    {
        switch(targetAVM)
        {
            case Features.TARGET_AVM1:
                es4_numerics = false;
                es4_nullability = false;
                es4_vectors = false;
                break;
            case Features.TARGET_AVM2:
                es4_numerics = false; // Are we supporting decimal for FP10?
                es4_nullability = false;  // Nullability support not in VM yet
                es4_vectors = true;  // Will be supporting vectors for FP10
                break;
            default:
                assert false;
        }
        abc_version = targetAVM;
    }
    int abc_version = 1;
    public boolean es4_numerics = false;
    public boolean es4_nullability = false;
    public boolean es4_vectors = true;

    ObjectValue _publicNamespace;
    ObjectValue _AS3Namespace;
	ObjectValue _anyNamespace;
    TypeValue _noType;
    TypeValue _objectType;
    TypeValue _arrayType;
	TypeValue _voidType;
	TypeValue _nullType;
	TypeValue _booleanType;
	TypeValue _stringType;
	TypeValue _typeType;
	TypeValue _functionType;
	TypeValue _intType;
	TypeValue _uintType;
    TypeValue _doubleType;
    TypeValue _numberType;
    TypeValue _decimalType;
    TypeValue _xmlType;
	TypeValue _xmlListType;
    TypeValue _regExpType;
    TypeValue _vectorType;
    TypeValue _vectorObjType;

    ObjectValue _booleanTrue;
    ObjectValue _booleanFalse;

	public int errCount = 0;

	// C: This is for tracking recursive include path.
	public ObjectList<String> includePaths = new ObjectList<String>();

	public void clear()
	{
		if (builtins != null)
		{
			builtins.clear();
		}

        errorCodeMap.clear();
		_publicNamespace = null;
		_anyNamespace = null;
        _noType = null;
        _objectType = null;
        _arrayType = null;
		_voidType = null;
		_nullType = null;
		_booleanType = null;
		_stringType = null;
		_typeType = null;
		_functionType = null;
		_intType = null;
		_uintType = null;
		_numberType = null;
        _doubleType = null;
        _decimalType = null;
        _xmlType = null;
		_xmlListType = null;
        _regExpType = null;
        _vectorType = null;
        _vectorObjType = null;

        _booleanTrue = null;
        _booleanFalse = null;

        if (namespaces != null)
        {
	        namespaces.clear();
        }
        if (internal_namespaces != null)
        {
	        internal_namespaces.clear();
        }
        if (protected_namespaces != null)
        {
	        protected_namespaces.clear();
        }
        if (static_protected_namespaces != null)
        {
	        static_protected_namespaces.clear();
        }
        if (private_namespaces != null)
        {
	        private_namespaces.clear();
        }
		if (bytecodeFactory != null)
		{
			bytecodeFactory.clear();
		}
        errCount = 0;
		handler = null;

		unresolved_ns_count = 0;
		ticket_count = 0;

		if (validImports != null)
		{
			validImports.clear();
		}
	}

	public void reuse()
	{
		emitter = null;
		nodeFactory = null;

		if (bytecodeFactory != null)
		{
			bytecodeFactory.clear();
			bytecodeFactory = null;
		}

		if (scopes != null)
		{
			scopes.clear();
		}

		if (internNamespaces != null)
		{
			internNamespaces.clear();
		}

		handler = null;
		pathspec = null;
		scriptname = null;
		global = null;

		globalPrototype = null;

        errCount = 0;
		handler = null;

		unresolved_ns_count = 0;
		ticket_count = 0;

		includePaths.clear();

		if (builtins != null)
		{
			cleanSlots(builtins);
		}

		if (userDefined != null)
		{
			cleanSlots(userDefined);
		}

		if (validImports != null)
		{
			validImports.clear();
		}
	}

	private static void cleanSlots(Map<String, TypeValue> types)
	{
		for (Iterator<TypeValue> i = types.values().iterator(); i.hasNext();)
		{
			TypeValue value = i.next();
			for (int j = 0, length = (value.slots != null) ? value.slots.size() : 0; j < length; j++)
			{
				cleanSlot(value.slots.get(j));
			}

			ObjectValue ov = value.prototype;
			for (int j = 0, length = (ov != null && ov.slots != null) ? ov.slots.size() : 0; j < length; j++)
			{
				cleanSlot(ov.slots.get(j));
			}
		}
	}

	public static void cleanSlot(Slot slot)
	{
		if (slot != null)
		{
            slot.setImplNode(null);
		}
	}
	
    public void removeNamespace(String name)
    {
    	// package name: e.g. mx.controls
    	// class name: e.g. mx.controls:Button
    	internal_namespaces.remove(name);
    	private_namespaces.remove(name);
    	protected_namespaces.remove(name);
    	static_protected_namespaces.remove(name);
    	namespaces.remove(name);
    }

    public ObjectValue getNamespace(String name, byte ns_kind)
    {
		name = Context.stripVersion(name);
        assert name == name.intern();
        Map<String, ObjectValue> namespace_map;

        switch( ns_kind )
        {
            case Context.NS_INTERNAL:
                namespace_map = internal_namespaces;
                break;
            case Context.NS_PRIVATE:
                namespace_map = private_namespaces;
                break;
            case Context.NS_PROTECTED:
                namespace_map = protected_namespaces;
                break;
            case Context.NS_STATIC_PROTECTED:
                namespace_map = static_protected_namespaces;
                break;
            default:
                namespace_map = namespaces;
                break;
        }
        ObjectValue val = namespace_map.get(name);
        if (val == null)
        {
            val = new NamespaceValue(ns_kind);
            val.setValue(name);     // to indicate that this is a ct const value
            val.name = name;
			assert name == name.intern();
            namespace_map.put(name,val);
        }
        return val;
    }
}
