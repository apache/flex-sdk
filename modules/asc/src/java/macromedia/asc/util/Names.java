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

import java.util.Set;
import java.util.Map;
import java.util.TreeMap;

import macromedia.asc.semantics.ObjectValue;
import static macromedia.asc.parser.Tokens.*;

/**
 * @author Jeff Dyer
 */
public final class Names
{   
    
    // Some counters that help in evaluating performance (only used if profile is true)
    private static int tables;
    private static int lookups;
    private static int misses;
    private static int collisions;
    private static int named_collisions;
    private static int entries;
    private static int grows;
    private static boolean profile = false;
    
    // The name structure is represented as 5 primitive arrays for efficiency
    
    private String [] name;
    private ObjectValue [] namespace;
    private int [] slot;
    private byte[] type;
    private int [] next; // hash bucket linked list via array...welcome to FORTRAN
    
    private int namesUsed;
    
    private int[] hashTable;
    private int hashTableMask; // mod value for hash, currently must be a power of two
    
	public static final int GET_NAMES          =  0x0;
	public static final int SET_NAMES          =  0x1;
	public static final int VAR_NAMES          =  0x2;
	public static final int METHOD_NAMES       =  0x3;
	public static final int LOCAL_METHOD_NAMES =  0x4;
	
	private static final int INITIAL_CAPACITY = 8;
	public static final Names EMPTY_NAMES = new Names();
    
	public Names()
	{
        if (profile) tables++;
	}

	public void dump() {
		for (int i = 0; i < name.length; ++i) {
			System.out.println (name[i] + " '" + (namespace[i]==null?"":namespace[i].name+"' "+namespace[i].getNamespaceKind()));
		}
	}



    /**
     * The hash function must be based on the name only, 
     * so that searches for {name,type} entries can be found in the same bucket.
     */
	private int hash(String name)
	{
		assert name.intern() == name;
		return name.hashCode() & (hashTableMask);
	}
	
	private int find(String name, int ty)
	{
        int i = hash(name);
        
        if (profile) lookups++;
        
        for (int id = hashTable[i]; id != -1; id = next[id])
        {
            if (this.name[id] == name && type[id] == ty)
                return id;
            
            if (profile) {collisions++; if (this.name[id] == name) named_collisions++;}
        }
        
        if (profile) {misses++; collisions--;}
        
        return -1;
	}
	
    private int enter(String name, ObjectValue namespace, int type, int hash)
    {
        if (profile) entries++;
        
        int id = namesUsed;
        
        if ( namesUsed >= this.name.length)
            growNames();
        
        this.name[id] = name;
        this.namespace[id] = namespace;
        next[id] = hashTable[hash];
        this.type[id] = (byte) type;
        slot[id] = -1;
        hashTable[hash] = id;
        
        namesUsed++;
        
        return id;
    }
    
	private int find(String name, ObjectValue namespace, int type, boolean enter)
	{
	    int hv = hash(name);
        int id = hashTable[hv];

        if (profile) lookups++;
        
        if ( id == -1 )
        {
            if ( enter )
            {
                return enter(name,namespace,type,hv);
            }
            if (profile) misses++;
            return -1;
        }
        
        String namespaceName = namespace.name;
        byte namespaceKind = namespace.getNamespaceKind();
        assert namespaceName == namespaceName.intern();
        
        do {   
            if (this.name[id] == name && this.type[id] == type &&  
                namespaceName == this.namespace[id].name && 
                namespaceKind == this.namespace[id].getNamespaceKind() )
            {
                return id;
            }  
            if (profile) {collisions++;if (this.name[id] == name) named_collisions++;}
            id = next[id];
		} while (id != -1);
        
        if ( enter )
        {
            return enter(name,namespace,type,hv);
        }
        if (profile) misses++;
        return -1;
	}

	public int size()
	{
		if(this == EMPTY_NAMES)
			return 0;
		return namesUsed;
	}
	
	private boolean isFull()
	{ 
		// 0.80 load factor
		return 5*(namesUsed+1) >= capacity()*4;
	}
	
	private final int capacity()
	{
		return (hashTable != null) ? hashTable.length : 0;
	}

	private int put(String name, ObjectValue namespace, int type)
	{
		if (hashTable == null || isFull())
		{
            grow();
		}
		
		return find(name, namespace, type, true);
	}
	
	public void putMask(String name, ObjectValue namespace, int type)
	{		
		//int id = 
            put(name, namespace, type);
        //type[id] |= (byte) ty; // ??? this accumulates type bits...which cant be right (types are 0..4, not a bitmask)
	}
	
	public void put(String name, ObjectValue namespace, int type, int slot)
	{		
		int id = put(name, namespace, type);
        this.slot[id] = slot;
	}	

	public boolean containsKey(String name, int type)
	{
		if (this == EMPTY_NAMES || hashTable == null)
		{
			return false;
		}
		
		int id = find(name, type);

		boolean hasIt = id != -1 && slot[id] != -1;
		return hasIt;
	}

	public int get(String name, ObjectValue namespace, int type)
	{
		if (this == EMPTY_NAMES || hashTable == null)
		{
			return -1;
		}
		
		int id = find(name, namespace, type, false);
		int slot = (id != -1) ? this.slot[id] : -1;
		return slot;
	}

	public Set<Map.Entry<String, Qualifiers>> entrySet(int type)
	{
		// ISSUE This method is going to be a performance hit
		// since it creates a copy of the entire map.
		// Callers should be adjusted to no longer use this method.
        
        //FIXME --this is called in one place and should be restructured as a single iteration over the name table, except that it's really not used...
        // It would get used if Builder.removeBuilderNames == false --which is currently hardwired true...
        
		TreeMap<String, Qualifiers> map = new TreeMap<String, Qualifiers>();
		for (int i=0; i<namesUsed; i++)
		{
            String n = name[i];
			if (n != null && this.type[i] == type)
			{
				Qualifiers q = map.get(n);
				if (q == null)
				{
					q = new Qualifiers();
					map.put(n, q);
				}
				q.put(namespace[i], slot[i]);
			}
		}
		return map.entrySet();
	}
	
    public boolean exist(String name, int type)
    {
        if (this == EMPTY_NAMES)
        {
            return false;
        }
        int hv = hash(name);

        for (int id=hashTable[hv]; id != -1; id = next[id])
        {
            if (this.name[id] == name && this.type[id] == type)
                return true;
        }
        return false;
    }
    
	public Qualifiers get(String name, int type)
	{
		if (this == EMPTY_NAMES)
		{
			return null;
		}
		
		Qualifiers q = null;
        int hv = hash(name);
        int id;
        
        // ??? for all entries {name,type} put {namespace,slot} => q
        // ??? FOR ALL ENTRIES ??? --simplified to just chase this bucket.
        // ??? could be better, if we chained names, but it costs a word.

        for (id=hashTable[hv]; id != -1; id = next[id])
        {
        	if (this.name[id] == name && this.type[id] == type)
        	{
        		if (q == null)
        		{
        			q = new Qualifiers();
        		}  
        		q.put(namespace[id], slot[id]);
                if (profile) lookups++;
        	}
            else if (profile) {collisions++;if (this.name[id] == name) named_collisions++;}
		}
        if (profile) {if (q==null) misses++;}
		return q;
	}

	public void putAll(Names names)
	{
		for (int i=0; i<names.namesUsed; i++)
		{
            put(names.name[i], names.namespace[i], names.type[i], names.slot[i]);
		}	
	}
	
	public boolean containsKey(String name, ObjectValue namespace, int type)
	{
		if (this == EMPTY_NAMES || hashTable == null)
		{			
			return false;
		}
		
		int id = find(name, namespace, type, false);
		boolean hasIt = id != -1 && slot[id] != -1;
		return hasIt;
	}

    private void newHashTable(int size)
    {
        hashTable = new int[size];
        hashTableMask = hashTable.length - 1;
        
        for(int i = 0; i < hashTable.length; i++)
            hashTable[i] = -1;
    }
    
    private void growNames()
    {
       if (name == null)
       {
           name = new String[INITIAL_CAPACITY];
           namespace = new ObjectValue[INITIAL_CAPACITY];
           slot = new int[INITIAL_CAPACITY];
           next = new int[INITIAL_CAPACITY];
           type = new byte[INITIAL_CAPACITY]; 
           return;
       }
       
       int l = name.length < 256 ? name.length*2: name.length+256;
       String[] newName = new String[l];
       ObjectValue[] newNamespace = new ObjectValue[l];
       int[] newSlot = new int[l];
       int[] newNext = new int[l];
       byte[] newType = new byte[l];
       
       for (int i=0; i < namesUsed; i++)
       {
           newName[i] = name[i];
           newNamespace[i] = namespace[i];
           newSlot[i] = slot[i];
           newType[i] = type[i];
           newNext[i] = next[i];
       }
       
       name = newName;
       namespace = newNamespace;
       slot = newSlot;
       type = newType;
       next = newNext;
    }
    
	private void grow()
	{   
        if ( hashTable == null )
        {
            newHashTable(INITIAL_CAPACITY);
            growNames();
            return;
        }
        
		// double our table size (its all we can do, since the hashmod function is a simple mask)

        newHashTable(capacity()*2);
        	
        if (profile) grows++;
        
        for (int i=0; i < namesUsed; i++)
        {
            int hv = hash(name[i]);
            next[i] = hashTable[hv];
            hashTable[hv] = i;
        }
	}
	
	public static int getTypeFromKind(int kind)	
	{
		switch (kind)
		{
		case GET_TOKEN:
			return GET_NAMES;
		case SET_TOKEN:
			return SET_NAMES;
		case VAR_TOKEN:
			return VAR_NAMES;
		default:
			return METHOD_NAMES;
		}	
	}

	public String getName(int i)
	{
		return name[i];
	}

	public ObjectValue getNamespace(int i)
	{
		return namespace[i];
	}

	public int getSlot(int i)
	{
		return slot[i];
	}

	public int getType(int i)
	{
		return type[i];
	}

	public int hasNext(int index)
	{
        if ( index < namesUsed )
            return index;
        
        return -1;
    }
}
