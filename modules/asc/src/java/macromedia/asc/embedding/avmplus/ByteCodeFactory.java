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

package macromedia.asc.embedding.avmplus;

import macromedia.asc.util.*;

import java.io.IOException;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;

import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;

/**
 * ByteCodeFactory.java
 *
 * Emits byte code for a particular component of the classfile.
 *
 * @author Jeff Dyer
 */
public class ByteCodeFactory
{
	private static boolean debug = false;

	public StringPrintWriter cpool_out = new StringPrintWriter();  // ISSUE: this is not thread safe
	public StringPrintWriter defns_out = new StringPrintWriter();
	public boolean show_bytecode;

    private Map<String, ByteList> utfConstants;
	private Map<Integer, ByteList> nsConstants;
    private Map<Integer, ByteList> nsPackageConstants;
    private Map<Integer, ByteList> nsPrivateConstants;
    private Map<Integer, ByteList> nsInternalConstants;
    private Map<Integer, ByteList> nsProtectedConstants;
    private Map<Integer, ByteList> nsStaticProtectedConstants;
	private Map<Integer, ByteList> intConstants;
	private Map<Integer, ByteList> uintConstants;
	private ByteList FALSE;
	private ByteList TRUE;
	private ByteList NULL;

	public ByteCodeFactory()
	{
		utfConstants = new HashMap<String, ByteList>();
		nsConstants = new HashMap<Integer, ByteList>();
        nsPackageConstants = new HashMap<Integer, ByteList>();
        nsPrivateConstants = new HashMap<Integer, ByteList>();
		nsInternalConstants = new HashMap<Integer, ByteList>();
        nsProtectedConstants = new HashMap<Integer, ByteList>();
        nsStaticProtectedConstants = new HashMap<Integer, ByteList>();
        intConstants = new HashMap<Integer, ByteList>();
        uintConstants = new HashMap<Integer, ByteList>();

		FALSE = new ByteList(1);
		Byte(FALSE, CONSTANT_False);
		TRUE = new ByteList(1);
		Byte(TRUE, CONSTANT_True);
		NULL = new ByteList(1);
		Byte(NULL, CONSTANT_Null);
	}

	public void clear()
	{
		utfConstants.clear();
		nsConstants.clear();
        nsPackageConstants.clear();
        nsPrivateConstants.clear();
        nsInternalConstants.clear();
        nsProtectedConstants.clear();
        nsStaticProtectedConstants.clear();
		intConstants.clear();
		uintConstants.clear();
	}

	public static ByteList allocBytes()
	{
		return new ByteList();
	}

	public static ByteList allocBytes(int size)
	{
		return new ByteList(size);
	}

    public ByteList ConstantValue(byte value)
    {
        if( show_bytecode )
        {
            switch(value)
            {
            case CONSTANT_False:
                cpool_out.write("\n      ConstantFalse");
                break;
            case CONSTANT_True:
                cpool_out.write("\n      ConstantTrue");
                break;
            case CONSTANT_Null:
                cpool_out.write("\n      ConstantNull");
                break;
            }
        }

	    switch (value)
	    {
	    case CONSTANT_False:
		    return FALSE;
	    case CONSTANT_True:
		    return TRUE;
	    case CONSTANT_Null:
		    return NULL;
		default:
		    ByteList bytes = allocBytes(1);
		    Byte(bytes, value);
		    return bytes;
	    }
    }

	public ByteList ConstantNamespace(int uri_index)
	{
		if( show_bytecode )
		{
			cpool_out.write("\n      ConstantNamespace " + uri_index);
		}

		Integer num = IntegerPool.getNumber(uri_index);
		if (nsConstants.containsKey(num))
		{
			return nsConstants.get(num);
		}

		ByteList bytes = allocBytes(3);
		bytes = Byte(bytes,CONSTANT_Namespace);
		bytes = Int(bytes,uri_index);

		nsConstants.put(num, bytes);
		return bytes;
	}

    public ByteList ConstantPrivateNamespace(int uri_index)
    {
        if( show_bytecode )
        {
            cpool_out.write("\n      ConstantPrivateNamespace " + uri_index);
        }

        Integer num = IntegerPool.getNumber(uri_index);
		if (nsPrivateConstants.containsKey(num))
		{
			return nsPrivateConstants.get(num);
		}

        ByteList bytes = allocBytes(3);
        bytes = Byte(bytes,CONSTANT_PrivateNamespace);
        bytes = Int(bytes,uri_index);

        nsPrivateConstants.put(num, bytes);
        return bytes;
    }

    public ByteList ConstantPackageNamespace(int uri_index)
    {
        if( show_bytecode )
        {
            cpool_out.write("\n      ConstantPackageNamespace " + uri_index);
        }

        Integer num = IntegerPool.getNumber(uri_index);
		if (nsPackageConstants.containsKey(num))
		{
			return nsPackageConstants.get(num);
		}

        ByteList bytes = allocBytes(3);
        bytes = Byte(bytes,CONSTANT_PackageNamespace);
        bytes = Int(bytes,uri_index);

        nsPackageConstants.put(num, bytes);

        return bytes;
    }

    public ByteList ConstantInternalNamespace(int uri_index)
    {
        if( show_bytecode )
        {
            cpool_out.write("\n      ConstantInternalNamespace " + uri_index);
        }

        Integer num = IntegerPool.getNumber(uri_index);
		if (nsInternalConstants.containsKey(num))
		{
			return nsInternalConstants.get(num);
		}

        ByteList bytes = allocBytes(3);
        bytes = Byte(bytes,CONSTANT_PackageInternalNs);
        bytes = Int(bytes,uri_index);

        nsInternalConstants.put(num, bytes);
        
        return bytes;
    }

    public ByteList ConstantProtectedNamespace(int uri_index)
    {
        if( show_bytecode )
        {
            cpool_out.write("\n      ConstantProtectedNamespace " + uri_index);
        }

        Integer num = IntegerPool.getNumber(uri_index);
		if (nsProtectedConstants.containsKey(num))
		{
			return nsProtectedConstants.get(num);
		}

        ByteList bytes = allocBytes(3);
        bytes = Byte(bytes,CONSTANT_ProtectedNamespace);
        bytes = Int(bytes,uri_index);

        nsProtectedConstants.put(num, bytes);

        return bytes;
    }

    public ByteList ConstantStaticProtectedNamespace(int uri_index)
    {
        if( show_bytecode )
        {
            cpool_out.write("\n      ConstantStaticProtectedNamespace " + uri_index);
        }

        Integer num = IntegerPool.getNumber(uri_index);
		if (nsStaticProtectedConstants.containsKey(num))
		{
			return nsStaticProtectedConstants.get(num);
		}

        ByteList bytes = allocBytes(3);
        bytes = Byte(bytes,CONSTANT_StaticProtectedNs);
        bytes = Int(bytes,uri_index);

        nsStaticProtectedConstants.put(num, bytes);

        return bytes;
    }

    public ByteList ConstantNamespaceSet(Set<Integer> namespaces)
    {
        ByteList bytes = allocBytes(5 + namespaces.size()*2);
        return ConstantNamespaceSet(bytes, namespaces);
    }


    public ByteList ConstantNamespaceSet( ByteList bytes,
            Set<Integer> namespaces)
    {
        if( show_bytecode )
        {
            cpool_out.write("\n      ConstantNamespaceSet " + namespaces.size() + " {");
            for( int ns_id : namespaces )
            {
                if( ns_id == 0 )
                {
                    break;
                }
                cpool_out.write(" " + ns_id );
            }
            cpool_out.write(" }");
        }

        //bytes = Byte(bytes, CONSTANT_Namespace_Set);
        bytes = Int(bytes, namespaces.size());
        for( int ns_id : namespaces )
        {
            bytes = Int(bytes, ns_id);
        }
        return bytes;
    }

    public ByteList ConstantTypeName(ByteList bytes,
            int name_index,
            IntList types )
    {
        if( show_bytecode )
        {
            cpool_out.write("\n     ConstantMultiname " +
                    name_index + " {");
            for( int i = 0; i < types.size(); ++i )
            {
                cpool_out.write(" " + types.at(i) );
            }
            cpool_out.write(" }");
        }
        bytes = Byte(bytes, CONSTANT_TypeName);
        bytes = Int(bytes, name_index);
        bytes = Int(bytes, types.size());
        for( int i = 0; i < types.size(); ++i )
            bytes = Int(bytes, types.at(i) );
        return bytes;
    }

    public ByteList ConstantTypeName(
            int name_index,
            IntList types )
    {
        return ConstantTypeName(allocBytes(3+types.size()*2), name_index, types);
    }

    public ByteList ConstantMultiname(ByteList bytes,
	        int name_index,
	        int namespace_set_index,
	        boolean isAttribute)
	{
		if( show_bytecode )
		{
			cpool_out.write("\n      ConstantMultiname " +
			        (isAttribute ? "@" : "") + name_index + " " + namespace_set_index);
		}

		bytes = Byte(bytes, isAttribute ? CONSTANT_MultinameA : CONSTANT_Multiname);
		bytes = Int(bytes,name_index);
		bytes = Int(bytes,namespace_set_index);
		return bytes;
	}

	public ByteList ConstantMultiname(
			int name_index,
			int namespace_set_index,
			boolean isAttribute)
		{
			return ConstantMultiname(allocBytes(5),name_index,namespace_set_index, isAttribute);
		}

	public ByteList ConstantMultinameLate(ByteList bytes,
	        int namespace_set_index,
	        boolean isAttribute)
	{
		if( show_bytecode )
		{
			cpool_out.write("\n      ConstantMultinameLate " +
			        (isAttribute ? "@" : "") + namespace_set_index);
		}

		bytes = Byte(bytes, isAttribute ? CONSTANT_MultinameLA : CONSTANT_MultinameL);
		bytes = Int(bytes,namespace_set_index);
		return bytes;
	}

	public ByteList ConstantMultinameLate(
			int namespace_set_index,
			boolean isAttribute)
		{
			return ConstantMultinameLate(allocBytes(5),namespace_set_index, isAttribute);
		}
	
	/**
	 * Make a CONSTANT_Utf8_info
	 */

	public ByteList ConstantUtf8Info(String text)
	{
		if (show_bytecode)
		{
			cpool_out.write("\n      ConstantUtf8Info " + text);
		}

        if (utfConstants.containsKey(text))
        {
	        return utfConstants.get(text);
        }

		byte[] utf8Bytes;
		try
		{
			utf8Bytes = text.getBytes("UTF8");
		}
		catch (IOException ex)
		{
			ex.printStackTrace();
			utf8Bytes = new byte[text.length()];
		}
		int text_length = utf8Bytes.length;
		ByteList bytes = allocBytes(text_length + 3);
		//bytes = Byte(bytes, CONSTANT_Utf8);
		bytes = Int(bytes, text_length);
		bytes.addAll(utf8Bytes);

		utfConstants.put(text, bytes);
		return bytes;
	}

	/**
	 * Make a CONSTANT_Integer_info
	 */

	public ByteList ConstantIntegerInfo(int value)
	{
		//       if( show_bytecode ) printf("\n      ConstantIntegerInfo %d",value);
		if (show_bytecode)
		{
			cpool_out.write("\n      ConstantIntegerInfo " + value);
		}

		Integer num = IntegerPool.getNumber(value);
		if (intConstants.containsKey(num))
		{
			return intConstants.get(num);
		}

		ByteList bytes = allocBytes(5);
		//bytes = Byte(bytes, CONSTANT_Integer);
		bytes = Int(bytes, value);

		intConstants.put(num, bytes);
		return bytes;
	}

	/**
	 * Make a CONSTANT_Uint_info
	 */

	public ByteList ConstantUintInfo(long value)
	{
		/* Java doesn't have unsigned ints.  If you cast a double to an int, you
		 * 	don't get the correct bits for uints larger than Integer.MAX_VALUE.
		 * However, if you coerce a long to an int, it just truncates to 32 bits
		 * */
		if (show_bytecode)
		{
			cpool_out.write("\n      ConstantUintInfo " + value);
		}

		// IntegerPool just caches Objects needed for the Map.  We don't need 
		// a separate pool for uints
		Integer num = IntegerPool.getNumber((int)value);
		if (uintConstants.containsKey(num))
		{
			return uintConstants.get(num);
		}

		ByteList bytes = allocBytes(5);
		//bytes = Byte(bytes, CONSTANT_Integer);
		bytes = Int(bytes, value);

		uintConstants.put(num, bytes);
		return bytes;
	}

	/**
	 * Make a CONSTANT_Double_info
	 */

	public ByteList ConstantDoubleInfo(ByteList bytes, double value)
	{
		if (show_bytecode)
		{
			StringBuilder numStr = new StringBuilder();
			IL_FormatDoubleAsString(value,numStr);
            cpool_out.write("\n      ConstantDoubleInfo "+numStr.toString());
		}
		//bytes = Byte(bytes, CONSTANT_Double);
		bytes = Double(bytes, value);
		return bytes;
	}

	public ByteList ConstantDoubleInfo(double value)
	{
		return ConstantDoubleInfo(allocBytes(9), value);
	}

	/**
	 * Make a CONSTANT_Decimal_info
	 */

	public ByteList ConstantDecimalInfo(ByteList bytes, Decimal128 value)
	{
		if (show_bytecode)
		{
            cpool_out.write("\n      ConstantDecimalInfo "+value.toString());
		}
		bytes = value.toByteList(bytes);
		return bytes;
	}

	public ByteList ConstantDecimalInfo(Decimal128 value)
	{
		return ConstantDecimalInfo(allocBytes(16), value);
	}

	/**
	 * Make a CONSTANT_Class_info
	 */

	public ByteList ConstantQualifiedName(ByteList bytes,
											 int name_index, 
											 int namespace_index,
											 boolean isAttribute)
	{
		if (show_bytecode)
		{
			cpool_out.write("\n      ConstantQualifiedName " + 
			        (isAttribute ? "@" : "") + name_index + " " + namespace_index);
		}
		bytes = Byte(bytes, isAttribute ? CONSTANT_QnameA : CONSTANT_Qname);
		bytes = Int(bytes,namespace_index);
		bytes = Int(bytes,name_index);

		return bytes;
	}


	public ByteList ConstantQualifiedName(int name_index, int namespace_index, boolean isAttribute)
	{
		return ConstantQualifiedName(allocBytes(5), name_index, namespace_index, isAttribute);
	}
	
	public ByteList ConstantRuntimeQualifiedName(ByteList bytes, int name_index, boolean isAttribute)
	{
		if (show_bytecode)
		{
			cpool_out.write("\n      ConstantRuntimeQualifiedName " + 
			        (isAttribute ? "@" : "") + name_index);
		}
		bytes = Byte(bytes, isAttribute ? CONSTANT_RTQnameA : CONSTANT_RTQname);
		bytes = Int(bytes,name_index);

		return bytes;
	}

	public ByteList ConstantRuntimeQualifiedName(int name_index, boolean isAttribute)
	{
		return ConstantRuntimeQualifiedName(allocBytes(3), name_index, isAttribute);
	}
	
    public ByteList ConstantRuntimeQualifiedLate(ByteList bytes, boolean isAttribute)
    {
        if (show_bytecode)
        {
            cpool_out.write("\n      ConstantRuntimeQualifiedLate " + 
                (isAttribute ? "@" : ""));
        }
        bytes = Byte(bytes, isAttribute ? CONSTANT_RTQnameLA : CONSTANT_RTQnameL);
        return bytes;
    }

    public ByteList ConstantRuntimeQualifiedLate(boolean isAttribute)
    {
        return ConstantRuntimeQualifiedLate(allocBytes(1), isAttribute);
    }

    /**
	 * Make a Constant Pool
	 */

	public static ByteList ConstantPool(ByteList bytes,
										ObjectList<ByteList> constants)
	{

		for (ByteList list : constants)
		{
			bytes.addAll(list);
		}

		return bytes;
	}

	/**
	 * Make an Namespaces table
	 */

	public static ByteList Namespaces(ByteList bytes, IntList namespaces)
	{

		for( int i=0;i<namespaces.size();i++)
		{
			bytes = Int(bytes,namespaces.get(i));
		}
		return bytes;
	}

	/**
	 * Make an Interfaces table
	 */

	public static ByteList Interfaces(ByteList bytes,
									  IntList interfaces)
	{

		for (int i = 0, n = interfaces.size(); i < n; i++)
		{
			bytes = Int(bytes, interfaces.get(i));
		}
		return bytes;
	}


	/**
	 * Make a trait info
	 */

	public ByteList TraitInfo(ByteList bytes,
									 int name_index,
									 int tag,
									 int id,
									 int info,
									 int other,
                                     byte other2,
                                     IntList metadata)
	{
		if (show_bytecode)
		{
			switch (tag)
			{
            case TRAIT_Var:
                defns_out.write("\n      *Trait name_index=" + name_index + " tag=var" + " slot_id=" + id + " type_index=" + info + " value=" + other + " value_kind=" + other2);
                break;
            case TRAIT_Const:
                defns_out.write("\n      *Trait name_index=" + name_index + " tag=const" + " slot_id=" + id + " type_index=" + info + " value=" + other + " value_kind=" + other2);
                break;
            case TRAIT_Method:
				defns_out.write("\n      *Trait name_index=" + name_index + " tag=method" + " disp_id=" + id + " method_info=" + info + ((other&0x01)!=0?" final":" virtual") + ((other&0x02)!=0?" override":" new"));
				break;
			case TRAIT_Getter:
				defns_out.write("\n      *Trait name_index=" + name_index + " tag=getter" + " disp_id=" + id + " method_info=" + info + ((other&0x01)!=0?" final":" virtual") + ((other&0x02)!=0?" override":" new"));
				break;
			case TRAIT_Setter:
				defns_out.write("\n      *Trait name_index=" + name_index + " tag=setter" + " disp_id=" + id + " method_info=" + info + ((other&0x01)!=0?" final":" virtual") + ((other&0x02)!=0?" override":" new"));
				break;
			case TRAIT_Function:
				defns_out.write("\n      *Trait name_index=" + name_index + " tag=function" + " slot_id=" + id + " method_info=" + info);
				break;
			case TRAIT_Class:
				defns_out.write("\n      *Trait name_index=" + name_index + " tag=class" + " slot_id=" + id + " class_info=" + info);
				break;
			}
		}
        int tag_flags = tag;
        if( metadata != null )
        {
            tag_flags |= (TRAIT_FLAG_metadata << 4);
        }
        if( tag == TRAIT_Method || tag == TRAIT_Getter || tag == TRAIT_Setter)
        {
            // Other for getter/setter/methods are flags that can be placed in the hi bits of the tag
            tag_flags |= (other << 4);
        }
		bytes = Int(bytes, name_index);
		bytes = Byte(bytes, tag_flags);
		switch (tag)
		{
            case TRAIT_Var:
            case TRAIT_Const:
                bytes = Int(bytes,id);
				bytes = Int(bytes,info);
				bytes = Int(bytes,other);
                if( other != 0 )
                    bytes = Byte(bytes, other2);
				break;
			case TRAIT_Class:
			case TRAIT_Function:
				bytes = Int(bytes, id);
				bytes = Int(bytes, info);
				break;
			case TRAIT_Method:
			case TRAIT_Getter:
			case TRAIT_Setter:
				bytes = Int(bytes, id);
				bytes = Int(bytes, info);
				break;
			default:
				// ISSUE: handle internal error
				break;
		}
        if( metadata != null)
        {
            int metadata_size = metadata.size();
            bytes = Int(bytes, metadata_size);
            for( int i = 0; i < metadata_size; ++i )
            {
                bytes = Int(bytes, metadata.get(i) );
            }
        }
		return bytes;
	}

	/**
	 * Make a traits table
	 */

	public static ByteList Traits(ByteList bytes,
								  ObjectList<ByteList> traits)
	{
		for (ByteList list : traits)
		{
			bytes.addAll(list);
		}
		return bytes;
	}

	/**
	 * Make a var info
	 */

/*
	public static ByteList VarInfo(ByteList bytes,
								   int name_index,
								   int value_index,
								   int slot_index,
                                   int var_info)
	{
		return VarInfo(bytes, (int) name_index, (int) value_index, (int) slot_index, var_info);
	}
*/

	public ByteList VarInfo(ByteList bytes,
								   int type_index,
								   int value_index,
								   int slot_index,
                                   int var_info)
	{
		if (show_bytecode)
		{
			defns_out.write("\n      VarInfo type_index=" + type_index + " value_index=" + value_index + " slot_index=" + slot_index + " -> " + var_info);
		}
        bytes = Int(bytes, slot_index);
		bytes = Int(bytes, type_index);
		bytes = Int(bytes, value_index);
		return bytes;
	}

	/**
	 * Make a vars table
	 */

	public static ByteList Vars(ByteList bytes,
								ObjectList<ByteList> vars)
	{

		for (ByteList list : vars)
		{
			bytes.addAll(list);
		}
		return bytes;
	}

	/**
	* Make a Methods table
	*/

	public static ByteList Methods(ByteList bytes,
								   ObjectList<ByteList> methods)
	{

		for (ByteList list : methods)
		{
			bytes.addAll(list);
		}
		return bytes;
	}

    public static ByteList Metadata(ByteList bytes,
                                   ObjectList<ByteList> metadata)
    {

        for (ByteList list : metadata)
        {
            bytes.addAll(list);
        }
        return bytes;
    }

	public static ByteList Bodies(ByteList bytes,
								   ObjectList<ByteList> bodies)
	{

		for (ByteList list : bodies)
		{
			bytes.addAll(list);
		}
		return bytes;
	}

	/**
	 * Make an Instances table
	 */

/*
	public static ByteList InstanceInfo(ByteList bytes,
									 int name_index,
									 int base_index,
									 boolean sealed_flag,
									 int interfaces_count,
									 IntList interfaces,
									 int iinit_index,
									 ObjectList<ByteList> itraits,
									 int class_info)
	{
		return InstanceInfo(bytes, (int) name_index, (int) base_index, sealed_flag, (int) interfaces_count, interfaces,
			 (int) iinit_index, itraits, class_info);
	}
*/

	public ByteList InstanceInfo(ByteList bytes,
									 int name_index,
									 int base_index,
									 int flags,
									 int protected_index,
									 int interfaces_count,
									 IntList interfaces,
									 int iinit_index,
									 ObjectList<ByteList> itraits,
									 int class_info)									 
	{
		if (show_bytecode)
		{
			defns_out.write("\n      InstanceInfo name_index=" + name_index + " base_index=" + base_index + 
			                " interfaces_count="+ interfaces_count + " interfaces={");
            for( int i = 0; i < interfaces.size(); ++i )
            {
                defns_out.write(" " + interfaces.get(i));
            }
            defns_out.write("} flags=" + flags + " iinit_index=" + iinit_index +
			                " itraits_count=" + itraits.size() + " -> " + class_info);
		}

		bytes = Int(bytes, name_index);
		bytes = Int(bytes, base_index);
		bytes = Byte(bytes, flags);
		if (protected_index != 0)
		{
			bytes = Int(bytes, protected_index);
		}
		bytes = Int(bytes, interfaces_count);
		bytes = Interfaces(bytes, interfaces);
		bytes = Int(bytes, iinit_index);
		bytes = Int(bytes, itraits.size());
		bytes = Traits(bytes, itraits);

		return bytes;
	}

	/**
	 * Make a Classes table
	 */

/*
	public static ByteList ClassInfo(ByteList bytes,
									 int cinit_index,
									 ObjectList<ByteList> ctraits,
									 int class_info)
	{
		return ClassInfo(bytes, (int) cinit_index, ctraits, class_info);
	}
*/
	public ByteList ClassInfo(ByteList bytes,
									 int cinit_index,
									 ObjectList<ByteList> ctraits,
									 int class_info)
	{
		if (show_bytecode)
		{
			defns_out.write("\n      ClassInfo  cinit_index=" + cinit_index + " ctraits_count=" + ctraits.size() + " -> " + class_info);
		}

		bytes = Int(bytes, cinit_index);
		bytes = Int(bytes, ctraits.size());
		bytes = Traits(bytes, ctraits);

		return bytes;
	}

    public ByteList ScriptInfo(ByteList bytes,
        int init_index,
        ObjectList<ByteList> traits,
        int pkg_info)
    {
        if (show_bytecode)
        {
            defns_out.write("\n      ScriptInfo" + " init_index=" + init_index + " traits_count=" + traits.size() + " -> " + pkg_info);
        }
        //if( debug ) printf("\n      bytes.size() = %d, code.size() = %d",bytes.size(),code.size());
        Int(bytes, init_index);
        Int(bytes, traits.size());
        Traits(bytes, traits);
        return bytes;
    }

	public static ByteList Classes(ByteList bytes,
								   ObjectList<ByteList> classes)
	{
		for (ByteList list : classes)
		{
			bytes.addAll(list);
		}
		return bytes;
	}

	public static ByteList Instances(ByteList bytes,
								   ObjectList<ByteList> instances)
	{
		for (ByteList list : instances)
		{
			bytes.addAll(list);
		}
		return bytes;
	}

	/**
	 * Make a Packages table
	 */

	public static ByteList Packages(ByteList bytes,
									ObjectList<ByteList> scripts)
	{

		for (ByteList list : scripts)
		{
			bytes.addAll(list);
		}
		return bytes;
	}

	/**
	 * Make an Attributes table
	 */

	public static ByteList Attributes(ByteList bytes,
									  ObjectList<ByteList> attributes)
	{

		for (ByteList list : attributes)
		{
			bytes.addAll(list);
		}
		return bytes;
	}


	/**
	 * Make a MethodInfo
	 */

	public ByteList MethodInfo(ByteList bytes,
                                      int param_count,
                                      int return_type,
                                      IntList param_types,
                                      IntList param_values,
                                      ByteList param_kinds,
                                      IntList param_names,
                                      int debug_name_index,
                                      int flags,
                                      int method_info_index)
	{
        if (show_bytecode)
        {
            defns_out.write("\n      MethodInfo ");
            defns_out.write(" param_count=" + param_count);
            defns_out.write(" return_type=" + return_type + " param_types={ ");
            for (int i = 0, size = param_types == null ? 0 : param_types.size(); i < size; i++)
            {
                defns_out.write(param_types.get(i) + " ");
            }
            defns_out.write("} debug_name_index=" + debug_name_index
                            + " needs_arguments=" + ((flags & METHOD_Arguments) != 0 ? "true" : "false")
                            + " need_rest=" + ((flags & METHOD_Needrest) != 0 ? "true" : "false")
                            + " needs_activation=" + ((flags & METHOD_Activation) != 0 ? "true" : "false")
                            + " has_optional=" + ((flags & METHOD_HasOptional) != 0 ? "true" : "false")
                            + " ignore_rest=" + ((flags & METHOD_IgnoreRest) != 0 ? "true" : "false")
                            + " native=" + ((flags & METHOD_Native) != 0 ? "true" : "false")
                            + " has_param_names =" + ((flags & METHOD_HasParamNames)!=0 ? "true":"false"));
            if ((flags & METHOD_HasOptional) != 0)
            {
                defns_out.write(" optional_count=" + param_values.size());
                defns_out.write(" optional_indexes={ ");
                for (int i = 0, size = param_values == null ? 0 : param_values.size(); i < size; i++)
                {
                    defns_out.write(" " + param_values.get(i));
                }
                defns_out.write(" }");
                defns_out.write(" optional_kinds={ ");
                for (int i = 0, size = param_values == null ? 0 : param_values.size(); i < size; i++)
                {
                    defns_out.write(" " + param_kinds.get(i));
                }
                defns_out.write(" }");
            }
            if( (flags & METHOD_HasParamNames) != 0 )
            {
                defns_out.write(" param_names={ ");
                for (int i = 0, size = param_names == null ? 0 : param_names.size(); i < size; i++)
                {
                    defns_out.write(" " + param_names.get(i));
                }
                defns_out.write(" }");
            }
            defns_out.write(" -> " + method_info_index);
        }

		if (debug)
		{
			System.out.print("\n      bytes.size() = " + bytes.size());
		}
		Int(bytes, param_count);
		Int(bytes, return_type);
		for (int i = 0; i < param_count; i++)
		{
			Int(bytes, param_types.get(i));
		}
		Int(bytes, debug_name_index);
		Byte(bytes, flags/*0x01 = need_arguments | 0x02 = need_activation*/);
        if ((flags&METHOD_HasOptional)!=0)
        {
            Int(bytes, param_values.size());
            for (int i=0, n=param_values.size(); i < n; i++)
            {
                Int(bytes, param_values.get(i));
                bytes.add(param_kinds.get(i));
            }
        }
        if( (flags & METHOD_HasParamNames) != 0 )
        {
            for (int i=0; i < param_count; i++)
            {
                Int(bytes, param_names.get(i));
            }
        }
		return bytes;
	}

	/**
	 * Make a MethodInfo
	 */

/*
public static ByteList MethodBody(ByteList bytes,
									  int max_stack,
									  int max_locals,
                                      int scope_depth,
                                      int max_scope,
									  int code_length,
									  ByteList code,
									  int exception_table_length,
									  ByteList exception_table,
									  ObjectList<ByteList> traits,
									  int method_info_index)
	{
		return MethodBody(bytes, (int) max_stack, (int) max_locals, (int)scope_depth, (int)max_scope,
                          code_length, code, (int) exception_table_length, exception_table, traits, method_info_index);
	}
*/

	public ByteList MethodBody(ByteList bytes,
                                      int max_stack,
                                      int max_locals,
                                      int scope_depth,
                                      int max_scope,
                                      int code_length,
                                      ByteList code,
                                      int exception_table_length,
                                      ByteList exception_table,
                                      ObjectList<ByteList> traits,
                                      int method_info_index)
	{
		          if( show_bytecode )
		          {
		              defns_out.write("\n      MethodBody " + "max_stack=" + max_stack);
		              defns_out.write(" max_locals=" + max_locals );
                      defns_out.write(" scope_depth=" + scope_depth + " max_scope=" + max_scope);
		              defns_out.write(" code_length=" + code_length + " traits_count=" + traits.size() + " -> " + method_info_index);
		          }

		if (debug)
		{
			System.out.print("\n      bytes.size() = " + bytes.size() + ", code.size() = " + code.size());
		}
        Int(bytes, method_info_index);
		Int(bytes, max_stack);
		Int(bytes, max_locals);
        Int(bytes, scope_depth);
        Int(bytes, max_scope);
		Int(bytes, code_length);
		if (code_length != 0)
		{
			bytes.addAll(code);
		}
		Int(bytes, exception_table_length);
		if (exception_table_length != 0)
		{
			bytes.addAll(exception_table);
		}
        Int(bytes, traits.size());
        Traits(bytes, traits);
		return bytes;
	}


    /**
     * Make a MethodInfo
     */

    public ByteList MetadataInfo(ByteList bytes,
                                      int nameIndex,
                                      int valuesCount,
                                      IntList keys,
                                      IntList values,
                                      int metadata_info_index)
    {
        if (show_bytecode)
        {
            defns_out.write("\n      MetadataInfo ");
            defns_out.write(" nameIndex=" + nameIndex);
            defns_out.write(" valuesCount=" + valuesCount + " keys={ ");
            for (int i = 0, size = keys.size(); i < size; i++)
            {
                defns_out.write(keys.get(i) + " ");
            }
            defns_out.write("} values={");
            for (int i = 0, size = values.size(); i < size; i++)
            {
                defns_out.write(values.get(i) + " ");
            }
            defns_out.write(" }");
            defns_out.write(" -> " + metadata_info_index);
        }

        if (debug)
        {
            System.out.print("\n      bytes.size() = " + bytes.size());
        }
        Int(bytes, nameIndex);
        Int(bytes, valuesCount);
        for (int i = 0; i < valuesCount; i++)
        {
            Int(bytes, keys.get(i));
        }
        for (int i = 0; i < valuesCount; i++)
        {
            Int(bytes, values.get(i));
        }
        return bytes;
    }

	/*
	 * Make an action block
	 */

	public ByteList ActionBlock(ByteList bytes,
									   int minor_version,
									   int major_version,
                                       int constant_int_pool_count,
                                       ObjectList<ByteList> constant_int_pool,
                                       int constant_uint_pool_count,
                                       ObjectList<ByteList> constant_uint_pool,
                                       int constant_double_pool_count,
                                       ObjectList<ByteList> constant_double_pool,
                                       int constant_decimal_pool_count,
                                       ObjectList<ByteList> constant_decimal_pool,
                                       int constant_utf8_pool_count,
                                       ObjectList<ByteList> constant_utf8_pool,
                                       int constant_mn_pool_count,
                                       ObjectList<ByteList> constant_mn_pool,
                                       int constant_nss_pool_count,
                                       ObjectList<ByteList> constant_nss_pool,
                                       int constant_ns_pool_count,
                                       ObjectList<ByteList> constant_ns_pool,
									   int methods_count,
									   ObjectList<ByteList> methods,
                                       int metadata_count,
                                       ObjectList<ByteList> metadata,
									   int classes_count,
									   ObjectList<ByteList> instances,
									   ObjectList<ByteList> classes,
									   int scripts_count,
									   ObjectList<ByteList> scripts,
                                       int bodies_count,
                                       ObjectList<ByteList> bodies)
	{
//        if( show_bytecode ) printf("\n      ActionBlock minor_version=%d,major_version=%d,constant_pool_count=%d,",minor_version,major_version,constant_pool_count);
		if (show_bytecode)
		{
			defns_out.write("\n      ActionBlock major_version=" + major_version + " minor_version=" + minor_version + " constant_int_count= " + constant_int_pool_count +
                " constant_uint_count=: " + constant_uint_pool_count + 
                " constant_double_count= " + constant_double_pool_count + " constant_decimal_count= " + constant_decimal_pool_count +
                " constant_utf8_count=" + constant_utf8_pool_count + " constant_namespace_count="+ constant_ns_pool_count +
                " constant_namespaceset_count=" + constant_nss_pool_count  + " constant_multiname_count=" +constant_mn_pool_count
				+ " methods_count=" + methods_count + " metadata_count=" + metadata_count + " classes_count=" + classes_count + " scripts_count=" + scripts_count
                + " bodies_count=" + bodies_count);
		}
		RealShort(bytes, minor_version);
		RealShort(bytes, major_version);
        Int(bytes, constant_int_pool_count);
        if (constant_int_pool_count != 0)
        {
            bytes = ConstantPool(bytes, constant_int_pool);
        }
        Int(bytes, constant_uint_pool_count);
        if (constant_uint_pool_count != 0)
        {
            bytes = ConstantPool(bytes, constant_uint_pool);
        }
        Int(bytes, constant_double_pool_count);
        if (constant_double_pool_count != 0)
        {
            bytes = ConstantPool(bytes, constant_double_pool);
        }
        if (minor_version < MINORwithDECIMAL) {
        	assert(constant_decimal_pool_count == 0);
        } else {
            Int(bytes, constant_decimal_pool_count);
            if (constant_decimal_pool_count != 0)
            {
                bytes = ConstantPool(bytes, constant_decimal_pool);
            }
        	
        }
        Int(bytes, constant_utf8_pool_count);
        if (constant_utf8_pool_count != 0)
        {
            bytes = ConstantPool(bytes, constant_utf8_pool);
        }
        Int(bytes, constant_ns_pool_count);
        if (constant_ns_pool_count != 0)
        {
            bytes = ConstantPool(bytes, constant_ns_pool);
        }
        Int(bytes, constant_nss_pool_count);
        if (constant_nss_pool_count != 0)
        {
            bytes = ConstantPool(bytes, constant_nss_pool);
        }
        Int(bytes, constant_mn_pool_count);
        if (constant_mn_pool_count != 0)
        {
            bytes = ConstantPool(bytes, constant_mn_pool);
        }
		Int(bytes, methods_count);
		if (methods_count != 0)
		{
			bytes = Methods(bytes, methods);
		}
        Int(bytes, metadata_count);
        if (metadata_count != 0)
        {
            bytes = Metadata(bytes, metadata);
        }
		Int(bytes, classes_count);
		if (classes_count != 0)
		{
			bytes = Instances(bytes, instances);
			bytes = Classes(bytes, classes);
		}
		Int(bytes, scripts_count);
		if (scripts_count != 0)
		{
			bytes = Packages(bytes, scripts);
		}
		Int(bytes, bodies_count);
		if (bodies_count != 0)
		{
			bytes = Bodies(bytes, bodies);
		}

		return bytes;
	}

	// static int count = 0;

	/*
	 * Basic types
	 */

	public static ByteList Byte(ByteList bytes, int v)
	{
		// System.out.println(count++ + ": Byte " + v);
		bytes.add((byte) v);
		return bytes;
	}

    public static ByteList RealShort(ByteList bytes, int v)
    {
        bytes.add((byte)v);
        bytes.add((byte)(v>>8));
        return bytes;
    }

	public static ByteList Int24(ByteList bytes, int v)
	{
		// System.out.println(count++ + ": Int24 " + v);
        /*
        etierney 1/16/06 - These temporary vars are important to work around a bug in the jrockit 1.4.2_08 JVM.
        The shifts and casts were inline in the bytes.add() call originally, but that somehow
        tickled some bug in the jrockit vm and it would end up passing the wrong values to bytes.add
        (in this case 0 instead of -1).  Badness ensued.  Assigning the results of shifting and casting to temporary
        variables fixed the problem.  Also only seemed to be a problem with this particular method, as the other Int/Short
        methods all seem to work fine.
        See bug #156441
        */
        byte byte1 = (byte) v;
        byte byte2 = (byte) (v >> 8);
        byte byte3 = (byte) (v >> 16);

		bytes.add(byte1);
		bytes.add(byte2);
		bytes.add(byte3);
		return bytes;
	}

	public static ByteList Int(ByteList bytes, long v)
	{
		// System.out.println(count++ + ": Int " + v);
        if ( v < 128 && v > -1 )
        {
            bytes.add((byte)v);
        }
        else if ( v < 16384 && v > -1)
        {
            bytes.add((byte)((v & 0x7F) | 0x80));
            bytes.add((byte)(((v >> 7) & 0x7F)));
        }
        else if ( v < 2097152 && v > -1)
        {
            bytes.add((byte)((v & 0x7F) | 0x80));
            bytes.add((byte)(v >> 7 | 0x80));
            bytes.add((byte)(((v >> 14)) & 0x7F));
        }
        else if (  v < 268435456 && v > -1)
        {
            bytes.add((byte)((v & 0x7F) | 0x80));
            bytes.add((byte)(v >> 7 | 0x80));
            bytes.add((byte)(v >> 14 | 0x80));
            bytes.add((byte)((v >> 21) & 0x7F) );
        }
        else
        {
            bytes.add((byte)((v & 0x7F) | 0x80));
            bytes.add((byte)(v >> 7 | 0x80));
            bytes.add((byte)(v >> 14 | 0x80));
            bytes.add((byte)(v >> 21 | 0x80));
            bytes.add((byte)((v >> 28) & 0x0F ));
        }
		return bytes;
	}

	public static ByteList Double(ByteList bytes, double v)
	{
		// System.out.println(count++ + ": Double " + v);
		// todo switch for endianness on Mac
		long bits = Double.doubleToLongBits(v);
		bytes.add((byte) bits);
		bytes.add((byte) (bits >> 8));
		bytes.add((byte) (bits >> 16));
		bytes.add((byte) (bits >> 24));
		bytes.add((byte) (bits >> 32));
		bytes.add((byte) (bits >> 40));
		bytes.add((byte) (bits >> 48));
		bytes.add((byte) (bits >> 56));
		return bytes;
	}

	// Java and C++ use different text formats for their default double->string conversion.
	//  This utility is used to write out doubles to .il files in a format which will
	//  be consistent between the c++ and java based compilers.  (which allows diffing
	//  of a java produced .il file vs a c++ produced .il).
	// Only used by PushNumber() when show_instructions is true.
	public static StringBuilder IL_FormatDoubleAsString(double val, StringBuilder buff)
	{
		if (val == 0.0)
		{
			return buff.append("0.0");
		}
		else if (val == Double.POSITIVE_INFINITY) // c++ doesn't have a -Infinity, keep output identical
		{
			return buff.append("Infinity");
		}
		else if (val == Double.NEGATIVE_INFINITY)
		{
			return buff.append("-Infinity");
		}
		else if (Double.isNaN(val))
		{
			return buff.append("NaN");
		}
		else if (val == (int)val)
		{
			return buff.append((int)val);
		}

		boolean neg = false;
		if (val < 0.0)
		{
			val = 0.0 - val;
			neg = true;
		}

		int exp = 0;
		if (val >= 1.0)
		{
			while(val > 10.0)
			{
				val = val / 10.0;
				exp++;
			}
			int truncVal = (int)val;
			buff.append( neg ? "-" : "+" ).append(truncVal).append(".");

			for(int pos = 0; pos < 5; pos++)
			{
				val = val - truncVal;  // cut off int val
				val *= 10; // pop next digit up above the .
				truncVal = (int)val;
				buff.append(truncVal);
			}

			if (exp > 0)
				buff.append("e").append(exp);
			return buff;
		}
		else
		{
			while (val < 1.0)
			{
				val = val * 10.0;
				exp++;
			}
			int truncVal = (int)val;
			buff.append( neg ? "-" : "+" ).append(truncVal).append(".");

			for(int pos = 0; pos < 5; pos++)
			{
				val = val - truncVal;  // cut off int val
				val *= 10; // pop next digit up above the .
				truncVal = (int)val;
				buff.append(truncVal);
			}
			return buff.append("e-").append(exp);
		}
	}


}
