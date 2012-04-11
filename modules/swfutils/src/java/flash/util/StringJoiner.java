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

package flash.util;

import java.util.Collection;
import java.util.Iterator;
import java.util.Map;

/**
 * A utility for joining strings.
 *
 * @author Gordon Smith
 */
public class StringJoiner
{
	public static String join(Object[] array, String separator,
    						  ItemStringer itemStringer)
    {
    	StringBuilder sb = new StringBuilder();
    	
    	int n = array.length;
    	for (int i = 0; i < n; i++)
    	{
    		Object itemObj = array[i];
    		String itemStr = itemStringer != null ?
    				   		 itemStringer.itemToString(itemObj) :
    				   		 itemObj.toString();
    		sb.append(itemStr);
    		if (separator != null && i < n - 1)
    		{
    			sb.append(separator);
    		}
    	}
    	
    	return sb.toString();
    }
    
    public static String join(Object[] array, String separator)
    {
    	return join(array, separator, null);
    }
    
    public static String join(Collection collection, String separator,
    						  ItemStringer itemStringer)
    {
    	StringBuilder sb = new StringBuilder();
    	
     	for (Iterator iter = collection.iterator(); iter.hasNext(); )
    	{
    		Object itemObj = iter.next();
    		String itemStr = itemStringer != null ?
    				   		 itemStringer.itemToString(itemObj) :
    				   		 itemObj.toString();
    		sb.append(itemStr);
    		if (separator != null && iter.hasNext())
    		{
    			sb.append(separator);
    		}
    	}
    	
    	return sb.toString();
    }
    
    public static String join(Collection collection, String separator)
    {
    	return join(collection, separator, null);
    }
    
    public interface ItemStringer
    {
    	public String itemToString(Object obj);
    }
    
    public static class ItemQuoter implements ItemStringer
    {
    	public String itemToString(Object obj)
    	{
    		return "\"" + obj.toString() + "\"";
    	}
    }
    
    public static class MapEntryItemWithColon implements ItemStringer
    {
    	public String itemToString(Object obj)
    	{
    		Map.Entry e = (Map.Entry)obj;
    		String key = e.getKey().toString();
    		String value = e.getValue().toString();
    		return key + ": " + value;
    	}
    }
    
    public static class MapEntryItemWithEquals implements ItemStringer
    {
    	public String itemToString(Object obj)
    	{
    		Map.Entry e = (Map.Entry)obj;
    		String key = e.getKey().toString();
    		String value = e.getValue().toString();
    		return key + "=\"" + value + "\"";
    	}
    }
}
