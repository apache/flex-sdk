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
package macromedia.abc;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import macromedia.asc.embedding.avmplus.ActionBlockConstants;
import macromedia.asc.parser.MetaDataEvaluator;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.semantics.MetaData;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Decimal128;

@SuppressWarnings("nls")
public class AbcData implements java.io.Externalizable
{	
	/**
	 * Attempt to read the cache from the persistent store when set.
	 */
	static boolean readCache = true;
	
	/**
	 * Attempt to write the cache to persistent store when set.
	 */
	static boolean saveCache = true;
	
	/**
	 * Object used to serialize access to the cache.
	 */
	static final Object serializationLock = new Object();
	
	public static boolean contains(String src_name)
	{
		return getCache().cache.containsKey(src_name);
	}
	
	public static AbcData getCacheEntry(String src_name)
	{
		return getCache().get(src_name);
	}
	
	public void finish()
	{
		if ( !( dirty && saveCache) )
		{
			getCache().remove(this);
		}
	}

	private boolean dirty = false;
	private String scriptName;
		
	private static AbcDataCache instance;
	
	/**
	 * @return the singleton instance of the cache.
	 */
	private static AbcDataCache getCache()
	{
		synchronized(serializationLock)
		{
			if ( null == instance )
				deserializeCache (new File("/tmp/AbcDataCache.ser"));
			return instance;
		}
	}
	
	/**
	 * Deserialize the AbcDataCache if feasible.
	 * @param input - the File that holds the serialized cache.
	 * @post The instance field holds a deserialized or new cache.
	 * @throws nothing -- errors dealt with here.
	 */
	private static void deserializeCache(File input)
	{
		{
			if ( null == instance && readCache && input.canRead() )
			{
				try
				{
					ObjectInputStream objIn = new ObjectInputStream(new FileInputStream(input));
					instance = (AbcDataCache)objIn.readObject();
					objIn.close();
					
					instance.file = input;
				}
				catch ( java.io.InvalidClassException incompatible_serialized_class )
				{
					//  Previously serialized class can't be deserialized,
				    //  start a new cache.
				}
				catch ( Exception ex)
				{
					// TODO: Better reporting.
					ex.printStackTrace();
				}
			}
			
			if ( null == instance )
				instance = new AbcDataCache(input);
		}
	}
	
	public static void preload()
	{
		new Thread() {
			@Override
            public void run() {
				getCache();
			}
		}.start();
	}

	private static class AbcDataCache implements java.io.Externalizable
	{	
		private Map<String, AbcData> cache;
		private boolean dirty;
		
		private File file;
		
		AbcDataCache(File f)
		{
			cache = new HashMap<String,AbcData>();
			file  = f;
			dirty = false;
			
			if ( saveCache )
			{
				Runtime.getRuntime().addShutdownHook(
					new Thread() {
						@Override
						public void run()
						{
							// TODO: This shutdown hook should be a last resort!
							AbcData.instance.flush();
						}
					}
				);
			}
		}
		
		
		public void flush()
		{
			if ( this.dirty )
			{
				try
				{
					ObjectOutputStream objOut = new ObjectOutputStream(new FileOutputStream(this.file));
					objOut.writeObject(this);
					objOut.close();
					this.dirty = false;
					System.out.println("Serialized AbcDataCache to " + this.file.getCanonicalPath()); //$NON-NLS-1$
				}
				catch ( Exception ex)
				{
					// Better logging would be nice, but a shutdown
				    // hook can't depend on any facilities but the
				    // most basic.
					ex.printStackTrace();
				}
			}
		}
		
		/**
		 * Retrieve or create cached AbcData for a script.
		 * @param script_name - the script name.
		 * @return the script's AbcData entry.
		 * @post this.dirty set if the AbcData was created.
		 */
		AbcData get(String script_name)
		{
			if ( !cache.containsKey(script_name) )
			{
				setDirty();
				cache.put(script_name, new AbcData(script_name));
				cache.get(script_name).dirty  = true;
			}
			
			return cache.get(script_name);
		}
		
		/**
		 * Set the cache's dirty bit.
		 * @param is_dirty
		 * @post static maps cleared.
		 */
		private void setDirty()
		{
			this.dirty = true;
		}
		
		void remove(AbcData data)
		{
			if ( !(dirty && saveCache) )
			{
				cache.remove(data.scriptName);
			}
				
		}


		@SuppressWarnings("unchecked")
		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			cache = (Map<String,AbcData>)in.readObject();
			dirty = false;
			file = new File(in.readObject().toString());
		}


		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeObject(cache);
			out.writeObject(file.getCanonicalPath());
		}
	}

	/*
	 *   Housekeeping functions
	 */
	public AbcData(String script_name)
	{
		this.scriptName = script_name;
		//  see deserialization code,
		//  which resets the dirty bit.
		this.dirty = true;
	}

	public boolean isBuilding()
	{
		return this.dirty;
	}
	
	/*
	 * Traits
	 */
	public class Trait implements java.io.Externalizable
	{
		int nameIndex;
        int kind;
        int [] data;
        int[] metadata;
        
        
		public Trait(int name_index, int kind, int[] data)
		{
			this.nameIndex = name_index;
			this.kind = kind;
			this.data = data;
		}
		
		public void addMetadata(int[] metadata)
		{
			this.metadata = metadata;
		}
		
		public int getNameIndex() {
			return this.nameIndex;
		}
		
		public int getAttrs()
		{
			return kind >> 4;
		}
		
		public int getTag()
		{
			return kind & 0xf;
		}
		
		public boolean hasMetadata() {
			return ( getAttrs() & ActionBlockConstants.TRAIT_FLAG_metadata) != 0;
		}
		
		public boolean isConstTrait() {
			return (getTag() == ActionBlockConstants.TRAIT_Const);
		}
		
		public int[] getMetadata()
		{
			return this.metadata;
		}
		
		public int getSlotId() {
			assert(getTag() == ActionBlockConstants.TRAIT_Var || getTag() == ActionBlockConstants.TRAIT_Const || getTag() == ActionBlockConstants.TRAIT_Class);
			return data[0];
		}
		
		public int getTypeName() {
			assert(getTag() == ActionBlockConstants.TRAIT_Var || getTag() == ActionBlockConstants.TRAIT_Const);
			return data[1];
		}
		
		public int getValueIndex() {
			assert(getTag() == ActionBlockConstants.TRAIT_Var || getTag() == ActionBlockConstants.TRAIT_Const);
			return data[2];
		}
		
		public int getValueKind() {
			assert(getTag() == ActionBlockConstants.TRAIT_Var || getTag() == ActionBlockConstants.TRAIT_Const);
			return data[3];
		}
		
		public int getDispId() {
			assert(getTag() == ActionBlockConstants.TRAIT_Method || getTag() == ActionBlockConstants.TRAIT_Getter || getTag() == ActionBlockConstants.TRAIT_Setter);
			return data[0];
		}
		
		public int getMethodId() {
			assert(getTag() == ActionBlockConstants.TRAIT_Method || getTag() == ActionBlockConstants.TRAIT_Getter || getTag() == ActionBlockConstants.TRAIT_Setter);
			return data[1];
		}
		
		public int getClassId() {
			assert(getTag() == ActionBlockConstants.TRAIT_Class);
			return data[1];
		}

		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			nameIndex = in.readInt();
	        kind = in.readByte();
	        data = (int[]) in.readObject();
	        metadata = (int[]) in.readObject();
		}

		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeInt(nameIndex);
			out.writeByte(kind);
			out.writeObject(data);
			out.writeObject(metadata);
		}
	}
	
	/*
	 * NameData is an unstructured view of deserialized name data.
	 */
	public class NameData implements java.io.Externalizable
    {
		int kind = 0;
        
        int[] params;
        
        NameData(int kind, int[] params)
        {
        	this.kind = kind;
        	this.params = params;
        }
        
        public int getKind()
        {
        	return this.kind;
        }
        
        
        public int[] getParams()
        {
        	return this.params;
        }

		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			kind = in.readByte();
			params = (int[])in.readObject();
		}

		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeByte(kind);
			out.writeObject(params);
		}
		
		Set<Integer> getVersions()
		{
			Namespace ns = null;
			
			// If the name's a multiname, get the first namespace
			// since they all share the same base URI.
			if ( ActionBlockConstants.CONSTANT_Multiname == kind || ActionBlockConstants.CONSTANT_MultinameA == kind )
			{
				int[] nss = AbcData.this.namespaceSets[this.params[1]].namespaceIds;
				ns = (nss.length > 0)? namespaces[nss[0]]: null;
			}
			else
				ns = namespaces[params[0]];
			
			switch ( kind )
    		{
            case ActionBlockConstants.CONSTANT_Qname:
            case ActionBlockConstants.CONSTANT_QnameA:
                ns = namespaces[params[0]];
                break;
            case ActionBlockConstants.CONSTANT_Multiname:
            case ActionBlockConstants.CONSTANT_MultinameA:
            	int[] nss = AbcData.this.namespaceSets[this.params[1]].namespaceIds;
				ns = (nss.length > 0)? namespaces[nss[0]]: null;
                break;
            default:
            	ns = null;
            }
		
			if ( ns != null )
			{
				String uri = strings[ns.nameOffset];
				return getVersion(uri);
			}
			return null;
		}
		
		Set<Integer> getVersion(String uri)
	    {
			if (uri.length() == 0) 
				return null;
			
			int last = uri.codePointAt(uri.length()-1);
			if(last >= 0xE000 && last <= 0xF000)
			{
				Set<Integer> result = new TreeSet<Integer>();
				result.add(last-0xE000);
				return result;
			}

			return null;
		}
    }
    
    /**
     * Names defined in this script.
     */
    private NameData[] nameData;
    
    /**
     * Temporary holder for names read from abc files.
     * Types are:
     * QName: namespace id,name id
     * Typename: QName reference (base), type parameter list of QName references
     * Multiname: name, namespaceset id
     */
    public class BinaryMN
    {
        public int kind = 0;           // MultiName type
        public int nameID = 0;         // name CPool string index (not used for CONSTANT_Typename)
        public int nsID = 0;           // namespace or namespaceset id
        public boolean nsIsSet = false;
        
        public int baseMN;             // CONSTANT_Typename: base name CPool MN index (e.g. 'Vector'
        public int[] params;           // CONSTANT_TypeName: parameter type CPool MN index (e.g. Vector<'int'>)
        
        public Set<Integer> versions;  // optional: supports version gather
        
        /**
         * Construct a non-parameterized name.
         * @param name_index
         * @param name_space
         * @param ns_is_set
         * @param versions
         */
        BinaryMN(int kind, int name_index, int name_space, boolean ns_is_set, Set<Integer>versions)
        {
            this.kind = kind;
            this.nameID = name_index;
            this.nsID = name_space;
            this.nsIsSet = ns_is_set;
            this.versions = versions;
        }
        
        /**
         * Construct a parameterized name.
         */
        BinaryMN(int kind, int base_name, int[] plist)
        {
            this.kind = kind;
            this.baseMN = base_name;
            this.params = plist;
        }
        
    }
    
    private transient BinaryMN[] binaryMultinames;
    
    public BinaryMN getName(int idx)
    {
        if ( null == this.binaryMultinames[idx] )
        {
            NameData nd = this.nameData[idx];
            int name_index = 0;
            int name_space = 0;
            boolean ns_is_set = false;
            
            switch ( nd.kind )
            {
            case ActionBlockConstants.CONSTANT_Qname:
            case ActionBlockConstants.CONSTANT_QnameA:
                name_space = nd.params[0];
                name_index = nd.params[1];
                ns_is_set  = false;
                this.binaryMultinames[idx] = new BinaryMN(nd.kind, name_index, name_space, ns_is_set, nd.getVersions());
                break;
            case ActionBlockConstants.CONSTANT_TypeName:
                name_index = nd.params[0];
                int count = nd.params.length - 2;
                assert( count == nd.params[1]);
                int[] plist = new int[count];
                for( int i = 0; i < count; ++i )
                    plist[i] = nd.params[i+2];
                this.binaryMultinames[idx] = new BinaryMN(nd.kind, name_index, plist);
                break;
            case ActionBlockConstants.CONSTANT_Multiname:
            case ActionBlockConstants.CONSTANT_MultinameA:
                    name_index = nd.params[0];
                    name_space = nd.params[1];
                    ns_is_set  = true;
                    this.binaryMultinames[idx] = new BinaryMN(nd.kind, name_index, name_space, ns_is_set, nd.getVersions());
                break;
            default:
                throw new IllegalArgumentException("Unexpected multiname type: " + nd.kind); //$NON-NLS-1$
            }
        }
        
        return this.binaryMultinames[idx];

    }
    
    AbcParser parser;
    public void setParser(AbcParser parser)
    {
    	this.parser = parser;
    }
    
	
	/*
	 * Namespace is an ABC-centric view of a namespace.
	 */
	public class Namespace implements java.io.Externalizable
	{
	
		int nameOffset;
		public byte nsKind;
		
		Namespace(int name_offset, int ns_kind)
		{
			this.nameOffset = name_offset;
			this.nsKind = (byte)ns_kind;
		}
		
		public String getName()
		{
			assert(nameOffset < strings.length);
			return strings[nameOffset];
		}

		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			nameOffset = in.readInt();
			nsKind = in.readByte();
		}

		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeInt(nameOffset);
			out.writeByte(nsKind);
		}
	}
	
	Namespace[] namespaces;
	
	public Namespace getNamespace(int i)
	{
		return this.namespaces[i];
	}
	
	/*
	 * Namespace sets
	 */
	public class NamespaceSet implements java.io.Externalizable
	{
		int[] namespaceIds;
		
		NamespaceSet(int[] nss_ids)
		{
			this.namespaceIds = nss_ids;
		}

		public int[] getNamespaceIds()
		{
			return this.namespaceIds;
		}

		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			namespaceIds = (int[])in.readObject();
		}

		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeObject(namespaceIds);
		}
	}
	
	NamespaceSet[] namespaceSets;
	
	public void addNamespaceSet(int nss_id, int[] namespaces)
	{
		if ( !isBuilding() )
			return;
	
		assert(this.namespaceSets != null && nss_id < this.namespaceSets.length && null == this.namespaceSets[nss_id]);
		NamespaceSet nss = new NamespaceSet(namespaces);
		this.namespaceSets[nss_id] = nss;
	}
	
	public NamespaceSet getNamespaceSet(int id)
	{
		assert(id < this.namespaceSets.length);
		return this.namespaceSets[id];
	}

	/*
	 * Strings
	 */
	String[] strings;
	
	public String getString(int i)
	{
		return this.strings[i];
	}
    
	/*
	 * Ints
	 */
	int[] ints;
	
	public int getInt(int i)
	{
		return this.ints[i];
	}
	
	/*
	 * Uints
	 */
	long[] uints;
	
	public long getUint(int i)
	{
		return uints[i];
	}
	
	/*
	 * Doubles
	 */
	double[] doubles;
	
	public double getDouble(int i)
	{
		return doubles[i];
	}
	
	/*
	 * Decimals
	 */
	private Decimal128[] decimals;
	
	public Decimal128 getDecimal(int i)
	{
	    return decimals[i];
	}
	
	/*
	 *  Methods
	 */
	public class Method  implements java.io.Externalizable
	{
		private int returnType;
		int[] paramTypes;
		private int nameIndex; 
		int flags;
		int[] optionalParamTypes;
		int[] optionalParamKinds; 
		int[] paramNames;
		
		public Method(int return_type, int[] param_types,
			int name_index, int flags, int[] optional_param_types,
			int[] optional_param_kinds, int[] param_names)
		{
			this.returnType = return_type;
			this.paramTypes = param_types;
			this.nameIndex = name_index; 
			this.flags = flags;
			this.optionalParamTypes = optional_param_types;
			this.optionalParamKinds = optional_param_kinds; 
			this.paramNames = param_names;
		}


		public int getReturnType() {
			return returnType;
		}
		public int[] getParamTypes() {
			return this.paramTypes;
		}
		public int getNameIndex() {
			return nameIndex;
		}
		public int getFlags() {
			return this.flags;
		}
		public int[] getOptionalParamTypes() {
			return optionalParamTypes;
		}
		public int[] getOptionalParamKinds() {
			return optionalParamKinds;
		}
		public String[] getParamNames() {
			String[] result = new String[paramNames.length];
			
			for ( int i = 0; i < paramNames.length; i++ )
				result[i] = strings[paramNames[i]];
			return result;
		}
		
		public boolean getNeedsRest() {
			return (flags & ActionBlockConstants.METHOD_Needrest) != 0 || (flags & ActionBlockConstants.METHOD_IgnoreRest) != 0;
		}
        public boolean getHasOptional() {
        	return (flags & ActionBlockConstants.METHOD_HasOptional) != 0;
        }
        public boolean getHasParamNames() {
        	return (flags & ActionBlockConstants.METHOD_HasParamNames) != 0;
        }


		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			returnType = in.readInt();
			paramTypes = (int[])in.readObject();
			nameIndex = in.readInt(); 
			flags = in.readInt();
			optionalParamTypes = (int[])in.readObject();
			optionalParamKinds = (int[])in.readObject(); 
			paramNames = (int[])in.readObject();
		}


		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeInt(returnType);
			out.writeObject(paramTypes);
			out.writeInt(nameIndex); 
			out.writeInt(flags);
			out.writeObject(optionalParamTypes);
			out.writeObject(optionalParamKinds); 
			out.writeObject(paramNames);
		}
	}
	
	private Method[] methods;
	
	public Method getMethod(int index)
	{
		assert(index >= 0 && index < this.methods.length);
		return this.methods[index];
	}

	/*
	 *  Metadata
	 */
	public class Metadata implements java.io.Externalizable
	{
		int nameIndex;
		int[] keys;
		int[] values;
		
		Metadata(int name_index, int[] keys, int[] values)
		{
			this.nameIndex = name_index;
			this.keys = keys;
			this.values = values;
			assert(keys.length == values.length);
		}
		
		public int getDataCount() {
			return keys.length;
		}
		
		public String getName()
		{
			return getString(this.nameIndex);
		}
		
		public String getKey(int idx)
		{
			assert(idx >= 0 && idx < keys.length);
			return getString(keys[idx]);
		}
		
		public String getValue(int idx)
		{
			assert(idx >= 0 && idx < values.length);
			return getString(values[idx]);
		}

		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			nameIndex = in.readInt();
			keys = (int[]) in.readObject();
			values = (int[]) in.readObject();
		}

		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeInt(nameIndex);
			out.writeObject(keys);
			out.writeObject(values);
		}
		
	}
	
	private Metadata[] raw_metadata;
	private transient MetaData[] semantic_metadata;
	
	public MetaData getMetadata(int idx, MetaDataNode metaNode )
	{
	    if ( null == this.semantic_metadata[idx] )
	    {
	        Metadata m = this.raw_metadata[idx];
	        metaNode.setId(m.getName());

            int[] keys = m.keys;
            int[] raw_values = m.values;
            
            Value[] vals = new Value[keys.length];
            for(int i = 0; i < keys.length; ++i )
            {
                String value = strings[raw_values[i]];
                vals[i] = ( keys[i] == 0 )
                    ? new MetaDataEvaluator.KeylessValue(value)
                    : new MetaDataEvaluator.KeyValuePair( strings[keys[i]], value);
            }
            
            metaNode.setValues(vals);
           semantic_metadata[idx] = metaNode.getMetadata();
	    }
		return this.semantic_metadata[idx];
	}
	
	
	/*
	 * InstanceInfo
	 */
	public class InstanceInfo implements java.io.Externalizable
	{
		int nameIndex;
		int superIndex; 
		int flags; 
		int protectedNs;
		int[] interfaces;
		int initIndex;
		Trait[] iTraits;
		
		InstanceInfo(int nameIndex, int superIndex, int flags, int protected_ns, int[] interfaces, int init_index, Trait[] itraits)
		{
			this.nameIndex = nameIndex;
			this.superIndex = superIndex;
			this.flags = flags;
			this.protectedNs = protected_ns;
			this.interfaces = interfaces;
			this.initIndex = init_index;
			this.iTraits = itraits;
		}

		public int getInstanceNameID() {
			return nameIndex;
		}
		
		public int getSuperID() {
			return superIndex;
		}
		
		public int getFlags() {
			return flags;
		}
		
		public int getProtectedNs() {
			return protectedNs;
		}
		
		public int[] getInterfaces() {
			return interfaces;
		}
		
		public int getInitIndex() {
			return initIndex;
		}
		
		public Trait[] getITraits() {
			return iTraits;
		}

		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			nameIndex = in.readInt();
			superIndex  = in.readInt(); 
			flags  = in.readInt(); 
			protectedNs  = in.readInt();
			interfaces = (int[]) in.readObject();
			initIndex = in.readInt();
			iTraits = (Trait[])in.readObject();
		}

		public void writeExternal(ObjectOutput out) throws IOException
		{
			 out.writeInt(nameIndex);
			 out.writeInt(superIndex); 
			 out.writeInt(flags); 
			 out.writeInt(protectedNs);
			 out.writeObject(interfaces);
			 out.writeInt(initIndex);
			 out.writeObject(iTraits);
		}
	}
	
	private InstanceInfo[] instanceInfos;
	
	public InstanceInfo getInstanceInfo(int i)
	{
		return this.instanceInfos[i];
	}
	
	/*
	 * ClassInfo
	 */
	public class ClassInfo implements java.io.Externalizable
	{
		int clinitIndex;
		Trait[] cTraits;
		
		ClassInfo(int clinit_index, Trait[] ctraits)
		{
			this.clinitIndex = clinit_index;
			this.cTraits = ctraits;
		}
		
		public int getClinitIndex() {
			return clinitIndex;
		}
		
		public Trait[] getCTraits() {
			return cTraits;
		}

		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			clinitIndex = in.readInt();
			cTraits = (Trait[]) in.readObject();
		}

		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeInt(clinitIndex);
			out.writeObject(cTraits);
		}
	}
	
	private ClassInfo[] classInfos;
	
	public int getClassInfoSize() {
		return this.classInfos.length;
	}
	
	public ClassInfo getClassInfo(int idx)
	{
		assert(this.classInfos != null && idx >= 0 && idx <= this.classInfos.length);
		return this.classInfos[idx];
	}
	
	/*
	 * ScriptInfo
	 */
	public class ScriptInfo implements java.io.Externalizable
	{
		int initIndex;
		Trait[] scriptTraits;
		
		ScriptInfo(int init_index, Trait[] script_traits)
		{
			this.initIndex = init_index;
			this.scriptTraits = script_traits;
		}
		
		public int getInitIndex() {
			return this.initIndex;
		}
		
		public Trait[] getScriptTraits() {
			return this.scriptTraits;
		}

		public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException
		{
			initIndex = in.readInt();
			scriptTraits = (Trait[]) in.readObject();
		}

		public void writeExternal(ObjectOutput out) throws IOException
		{
			out.writeInt(initIndex);
			out.writeObject(scriptTraits);
		}
	}
	
	ScriptInfo[] scriptInfos;
	
	public int getScriptInfoSize()
	{
		return this.scriptInfos.length;
	}
	
	public ScriptInfo getScriptInfo(int idx)
	{
		assert(this.scriptInfos != null && idx >= 0  && idx < this.scriptInfos.length);
		return this.scriptInfos[idx];
	}

	/**
	 *   Serialize the AbcData to an ObjectOutput stream.
	 */
	public void writeExternal(ObjectOutput out) throws IOException
	{
		out.writeObject(classInfos);
		out.writeObject(doubles);
		out.writeObject(instanceInfos);
		out.writeObject(ints);
		out.writeObject(raw_metadata);
		out.writeObject(methods);
		out.writeObject(namespaces);
		out.writeObject(namespaceSets);
		out.writeObject(nameData);
		out.writeObject(scriptInfos);
		out.writeObject(scriptName);
		out.writeObject(strings);
		out.writeObject(uints);
	}
	
	/**
	 * Deserialize the AbcData.
	 */
	public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException 
	{
		classInfos = (ClassInfo[])in.readObject();
		doubles = (double[]) in.readObject();
		instanceInfos = (InstanceInfo[])in.readObject();
		ints = (int[])in.readObject();
		raw_metadata = (Metadata[])in.readObject();
		semantic_metadata = new MetaData[raw_metadata.length];
		methods = (Method[]) in.readObject();
		namespaces = (Namespace[]) in.readObject();
		namespaceSets = (NamespaceSet[])in.readObject();
		nameData = (NameData[])in.readObject();
		scriptInfos = (ScriptInfo[])in.readObject();
		scriptName = (String)in.readObject();
		strings = (String[])in.readObject();
		uints = (long[]) in.readObject();
		
		dirty = false;
	}
	
	public void readAbc(byte[] raw_abc)
	{
	    if (!this.isBuilding() )
	        return;

	    readAbc(new BytecodeBuffer(raw_abc));
	}
	   
	public void readAbc(BytecodeBuffer buf)
	{
	    if (!this.isBuilding() )
            return;
	    
        int minor_version = buf.readU16();
        /*int major_version =*/ buf.readU16();

        // Scan the bytecode for the stuff we care about
        scanCpool(buf, minor_version >= ActionBlockConstants.MINORwithDECIMAL);
        scanMethods(buf);
        scanMetadata(buf);
        scanClasses(buf);
        scanScripts(buf);
	}

	void scanCpool(BytecodeBuffer buf, boolean hasDecimal)
    {
        int size;
        
        size = buf.readU32();   
        this.ints = new int[size];
        for (int i = 1; i < size; i++)
        {
            this.ints[i] = buf.readU32();
        }
        
        size = buf.readU32();
        this.uints = new long[size];
        for (int i = 1; i < size; i++)
        {
            this.uints[i] = buf.readU32() & 0xFFFFFFFFL;
        }
        
        size = buf.readU32();
        this.doubles = new double[size];
        for (int i = 1; i < size; i++)
        {
            this.doubles[i] = buf.readDouble();
        }
        
        if (hasDecimal)
        {
            size = buf.readU32();
            this.decimals = new Decimal128[size];

            for (int i = 1; i < size; i++)
            {
               byte[] rep = buf.readBytes(16);
               decimals[i] = new Decimal128(rep);
            }
        }

        size = buf.readU32();
        this.strings = new String[size];
        this.strings[0] = "".intern();
        for (int i = 1; i < size; i++)
        {
            int length = buf.readU32();
            this.strings[i] = buf.readString(length).intern();
            buf.skip(length);   //  readString() doesn't reset pos pointer.
        }
        
        size = buf.readU32();
        this.namespaces = new Namespace[size];
        for (int i = 1; i < size; i++)
        {
            int ns_kind = buf.readU8(); // kind byte
            int name_offset = buf.readU32();
            this.namespaces[i] = new Namespace(name_offset, ns_kind);
        }
        
        size = buf.readU32();
        this.namespaceSets = new NamespaceSet[size];
        for (int i = 1; i < size; i++)
        {
            int count = buf.readU32(); // count
            int[] ns_ids = new int[count];
            for(int q =0; q < count; ++q)
            {
                ns_ids[q] = buf.readU32();
            }
            this.namespaceSets[i] = new NamespaceSet(ns_ids);
        }
        
        size = buf.readU32();
        this.nameData = new NameData[size];
        this.binaryMultinames = new BinaryMN[size];
              
        for (int i = 1; i < size; i++)
        {
            int kind = buf.readU8();
            switch (kind)
            {
                case ActionBlockConstants.CONSTANT_Qname:
                case ActionBlockConstants.CONSTANT_QnameA:
                    this.nameData[i] = new NameData(kind, new int[] {buf.readU32(), buf.readU32()});
                    break;
                case ActionBlockConstants.CONSTANT_RTQname:
                case ActionBlockConstants.CONSTANT_RTQnameA:
                    this.nameData[i] = new NameData(kind, new int[] {buf.readU32()});
                    break;
                case ActionBlockConstants.CONSTANT_Multiname:
                case ActionBlockConstants.CONSTANT_MultinameA:
                    this.nameData[i] = new NameData(kind, new int[] {buf.readU32(), buf.readU32()} );
                    break;
                case ActionBlockConstants.CONSTANT_MultinameL:
                case ActionBlockConstants.CONSTANT_MultinameLA:
                    this.nameData[i] = new NameData(kind, new int[] {buf.readU32()});
                    break;
                case ActionBlockConstants.CONSTANT_TypeName:
                    int name_index = buf.readU32(); // name index
                    int count = buf.readU32(); // param count;
                    int[] entries = new int[count+2];
                    entries[0] = name_index;
                    entries[1] = count;
                    for ( int k = 0; k < count; k++)
                        entries[k+2] = buf.readU32();
                    this.nameData[i] = new NameData(kind, entries);
                    break;
                case ActionBlockConstants.CONSTANT_RTQnameL:
                case ActionBlockConstants.CONSTANT_RTQnameLA:
                    this.nameData[i] = new NameData(kind, null);
                    break;
                default:
                    throw new RuntimeException("bad multiname type: " + kind);

            }
        }
    }

    void scanMethods(BytecodeBuffer buf)
    {
        int methodEntries = buf.readU32();
        this.methods = new Method[methodEntries];
        
        for (int i = 0; i < methodEntries; i++)
        {
            int param_count = buf.readU32();
            int return_type = buf.readU32();
            int[] param_types = new int[param_count];
            for ( int j = 0; j < param_count; j++ )
                param_types[j] = buf.readU32();
            int name_index = buf.readU32();
            int flags = buf.readU8();   
            
            int optional_param_count = ((flags & ActionBlockConstants.METHOD_HasOptional) != 0)? buf.readU32(): 0;
            int[] optional_param_types = new int[optional_param_count];
            int[] optional_param_kinds = new int[optional_param_count];
            
            for( int q = 0; q < optional_param_count; ++q )
            {
                optional_param_types[q] = buf.readU32(); 
                optional_param_kinds[q] = buf.readU8();
            }

            int param_name_count = ((flags & ActionBlockConstants.METHOD_HasParamNames)!=0) ? param_count : 0;
            int[] param_names = new int[param_name_count];
            for( int q = 0; q < param_name_count; ++q )
            {
                param_names[q] = buf.readU32();
            }
            
            this.methods[i] = new Method(return_type, param_types, name_index, flags, optional_param_types, optional_param_kinds, param_names);
        }
    }

    void scanMetadata(BytecodeBuffer buf)
    {
        int metadataEntries = buf.readU32();
        
        this.raw_metadata = new Metadata[metadataEntries];
        this.semantic_metadata = new MetaData[metadataEntries];
        
        for (int i = 0; i < metadataEntries; i++)
        {
            int name_index  = buf.readU32();
            int value_count = buf.readU32(); //returnType
            
            int[] keys   = new int[value_count];
            int[] values = new int[value_count];
            
            for ( int j = 0; j < value_count; j++ )
            {
                keys[j] = buf.readU32();
            }
            for(int j = 0; j < value_count; j++ )
            {
                values[j] = buf.readU32();
            }
            
            this.raw_metadata[i] = new Metadata( name_index, keys, values );
        }
    }

    void scanClasses(BytecodeBuffer buf)
    {
        int classEntries = buf.readU32();

        this.classInfos = new ClassInfo[classEntries];
        this.instanceInfos = new InstanceInfo[classEntries];
        
        // InstanceInfos
        for(int i = 0; i < classEntries; ++i)
        {
            int name_index = buf.readU32();
            int super_index = buf.readU32(); //super_index
            int flags = buf.readU8();
            int protected_ns = 0;
            if ((flags & ActionBlockConstants.CLASS_FLAG_protected) != 0)
            {
                protected_ns = buf.readU32();
            }
               
            int interface_count = buf.readU32();
            int[] interfaces = new int[interface_count];
            for ( int j = 0; j < interface_count; j++ )
                interfaces[j] = buf.readU32();
            int init_index = buf.readU32();
            AbcData.Trait[] itraits = scanTraits(buf);
            
            this.instanceInfos[i] = new InstanceInfo(name_index, super_index, flags, protected_ns, interfaces, init_index, itraits);
        }

        // ClassInfos
        for(int i = 0; i < classEntries; ++i)
        {
            int clinit_index = buf.readU32();
            AbcData.Trait[] ctraits = scanTraits(buf);
            
            this.classInfos[i] = new ClassInfo(clinit_index, ctraits);
        }

    }

    void scanScripts(BytecodeBuffer buf)
    {
        int script_count = buf.readU32();
        this.scriptInfos = new ScriptInfo[script_count];
        for(int i = 0 ; i < script_count; ++i )
        { 
            this.scriptInfos[i] = new ScriptInfo(buf.readU32(), scanTraits(buf));
        }
    }

    /**
     * Read traits from the bytecode into AbcData cache form
     * @return the deserialized traits.
     */
    AbcData.Trait[] scanTraits(BytecodeBuffer buf)
    {
        int count = buf.readU32();
        
        AbcData.Trait[] result = new AbcData.Trait[count];

        for (int i = 0; i < count; i++)
        {
            int name_index = buf.readU32();
            int kind = buf.readU8();
            int tag = kind & 0x0f;
            
            AbcData.Trait new_trait = null;
            
            switch (tag)
            {
            case ActionBlockConstants.TRAIT_Var:
            case ActionBlockConstants.TRAIT_Const:
            {
                int slot_id = buf.readU32();
                int trait_type = buf.readU32();
                int value_index = buf.readU32();
                int value_kind = 0;
                if( value_index > 0 )
                    value_kind = buf.readU8(); 
            
                new_trait = this.new Trait(name_index, kind, new int[] { slot_id, trait_type, value_index, value_kind});
                break;
            }
            case ActionBlockConstants.TRAIT_Method:
            case ActionBlockConstants.TRAIT_Getter:
            case ActionBlockConstants.TRAIT_Setter:
            {
                int disp_id = buf.readU32();
                int method = buf.readU32();
                new_trait = this.new Trait(name_index, kind, new int[] {disp_id, method} );
                break;
            }
            case ActionBlockConstants.TRAIT_Class:
            case ActionBlockConstants.TRAIT_Function:
            {
                int slot_id  = buf.readU32();
                int class_id = buf.readU32();
                new_trait = this.new Trait(name_index, kind, new int[] { slot_id, class_id } );
                break;
            }
            default:
                break;
                //throw new DecoderException("Invalid trait kind: " + kind);
            }
            
            assert(new_trait != null);
            result[i] = new_trait;
            
            if( new_trait.hasMetadata() )
            {
                int metadata_count = buf.readU32();
                int[] metadata = new int[metadata_count];
                for ( int j = 0; j < metadata_count; j++)
                    metadata[j] = buf.readU32();
                new_trait.addMetadata(metadata);
            }
        }
        
        return result;
    }

	
	
}
