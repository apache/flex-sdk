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

package flex2.compiler.util;

import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;

/**
 * Stores the mappings of name and uri to classname.
 *
 */
public class NameMappings
{
	public NameMappings()
	{
		namespaceMap = new HashMap<String, Map<String,String>>();
        lookupOnly = new HashMap<String, Set<String>>();
	}

    private Map<String, Map<String,String>> namespaceMap;
    private Map<String, Set<String>> lookupOnly;

    public NameMappings copy()
    {
    	NameMappings m = new NameMappings();
    	for (Iterator<String> i = namespaceMap.keySet().iterator(); i.hasNext(); )
    	{
    		String uri = i.next();
    		Map<String, String> classMap = namespaceMap.get(uri);
    		m.namespaceMap.put(uri, new HashMap<String,String>(classMap));
    	}
    	m.lookupOnly.putAll(lookupOnly);
    	return m;
    }
    
	public String lookupPackageName(String nsURI, String localPart)
	{
		String className = lookupClassName(nsURI, localPart);
		if (className == null)
		{
			return null;
		}
		int index = className.indexOf(":");
		return (index == -1) ? "" : className.substring(0, index);
	}

	public String lookupClassName(String nsURI, String localPart)
	{
        Map<String, String> classMap = namespaceMap.get(nsURI);
        return classMap == null ? null : classMap.get(localPart);
	}

	/**
	 * Look up namespace;classname against registered entries, then fault to package-style namespace handling
	 * NOTE: the contract here is that a null return value definitely indicates a missing definition, but a non-null
	 * return value *by no means* ensures that a definition will be available. E.g. an entry in a manifest doesn't mean
	 * that the backing code is correct, defines the specified class or even exists. Also, for package-style namespaces
	 * we simply concatenate the parameters together, since (e.g.) checking the presence or absence of a suitable entry
	 * on the classpath gives a similarly non-definitive answer.
	 */
	public String resolveClassName(String namespaceURI, String localPart)
	{
		String className = lookupClassName(namespaceURI, localPart);

		if (className == null)
		{
			// C: if namespaceURI is in the form of p1.p2...pn.*...
            // HIGHLY recommend handling this as old compiler did.  --rg
			if ("*".equals(namespaceURI))
			{
				className = localPart;
			}
			else if (namespaceURI.length() > 2 && namespaceURI.endsWith(".*"))
			{
				className = namespaceURI.substring(0, namespaceURI.length() - 2) + ':' + localPart;
				className = className.intern();
			}
		}

		return className;
	}

    public Map<String, String> getNamespace(String nsURI)
    {
        return namespaceMap.get(nsURI);
    }

    public Set<String> getNamespaces()
    {
        return namespaceMap.keySet();
    }

    public void addMappings( NameMappings other )
    {
        for (Iterator<Map.Entry<String, Map<String,String>>> nit = other.namespaceMap.entrySet().iterator(); nit.hasNext();)
        {
            Map.Entry<String, Map<String,String>> e = nit.next();
            String namespaceURI = e.getKey();
            Map<String, String> mappings = e.getValue();

            for (Iterator<Map.Entry<String, String>> it = mappings.entrySet().iterator(); it.hasNext();)
            {
                Map.Entry<String, String> lc = it.next();
                String local = lc.getKey();
                String className = lc.getValue();

                addClass( namespaceURI, local, className );
            }
        }
    }

    public boolean addClass(String namespaceURI, String localPart, String className)
    {
        Map<String, String> classMap = null;

        if (namespaceMap.containsKey(namespaceURI))
        {
            classMap = namespaceMap.get(namespaceURI);
        }
        else
        {
            classMap = new HashMap<String, String>();
            namespaceMap.put(namespaceURI.intern(), classMap);
        }

        String current = classMap.get(localPart);
        if (current == null)
        {
            classMap.put(localPart.intern(), className.intern());
        }
        else if (! current.equals(className))
        {
            return false;
        }
        return true;
    }

    public void addLookupOnly(String namespaceURI, String cls)
    {
        Set classes = lookupOnly.get(namespaceURI);

        if (classes == null)
        {
            classes = new HashSet<String>();
            lookupOnly.put(namespaceURI, classes);
    }

        classes.add(cls);
    }

    public boolean isLookupOnly(String namespaceURI, String cls)
    {
        boolean result = false;
        Set classes = lookupOnly.get(namespaceURI);

        if (classes != null)
        {
            result = classes.contains(cls);
    }

        return result;
}
}
