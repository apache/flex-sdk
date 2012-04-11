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

package flash.swf;

import flash.swf.tags.DefineTag;
import flash.swf.tags.DefineFont;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

/**
 * Represents the collection of definitions in a SWF.
 */
public class Dictionary
{
    private static DefineTag INVALID_TAG = new DefineTag(Tag.stagEnd) { public void visit(TagHandler t) {} };
    Map<Integer, DefineTag> ids = new HashMap<Integer, DefineTag>();
    Map<DefineTag, Integer> tags = new HashMap<DefineTag, Integer>();
    Map<String, DefineTag> names = new HashMap<String, DefineTag>();
    Map<String, DefineFont> fonts = new HashMap<String, DefineFont>();
    private int nextId = 1;

    public boolean contains(int id)
    {
        return ids.containsKey(new Integer(id));
    }

    public boolean contains(DefineTag tag)
    {
        return tags.containsKey(tag);
    }

    public int getId(DefineTag tag)
    {
        if (tag == null || tag == INVALID_TAG)
        {
            return -1;//throw new NullPointerException("no ids for null tags");
        }
        else
        {
            // when we're encoding, we should definitely find the tag here.
            Object idobj = tags.get(tag);

            if (idobj == null)
            {
                // When we're decoding, we don't fill in the tags map, and so we'll have
                // to search for the tag to see what it had when we read it in.

                Iterator iterator = ids.entrySet().iterator();
                while (iterator.hasNext())
                {
                    Entry entry = (Entry) iterator.next();

                    // [ets 1/14/04] we use an exact comparison here instead of equals() because this point
                    // should only be reached during *decoding*, by tools that want to report the id
                    // that is only stored in the ids map.  Since each DefineTag from a single swf will
                    // be a unique object, this should be safe.  During encoding, we will find ID's stored
                    // in the tags map, and the ids map should be empty.  if we use equals(), it is possible
                    // for tools to report the wrong ID, because the defineTags may not be fully decoded yet,
                    // for example the ExportAssets may not have been reached, so the tag might not have its
                    // name yet, and therefore compare equal to another unique but yet-unnamed tag.

                    if (entry.getValue() == tag)
                    {
                        idobj = entry.getKey();
                        break;
                    }
                }
            }

			if (idobj == null)
			{
            	assert false : ("encoding error, " + tag.name + " not in dictionary");
			}

            return ((Integer) idobj).intValue();
        }
    }

    /**
     * This is the method used during encoding.
     */
    public int add(DefineTag tag)
    {
        assert (tag != null);
        Integer obj = tags.get(tag);
        if (obj!=null)
        {
            //throw new IllegalArgumentException("symbol " +tag+ " redefined");
            return obj.intValue();
        }
        else
        {
            Integer key = new Integer(nextId++);
            tags.put(tag, key);
            ids.put(key, tag);
            return key.intValue();
        }
    }

    /**
     * This is method used during decoding.
     *
     * @param id
     * @param s
     * @throws IllegalArgumentException if the dictionary already has that id
     */
    public void add(int id, DefineTag s)
        throws IllegalArgumentException
    {
        Integer key = new Integer(id);
        Tag t = ids.get(key);
        if (t == null)
        {
            ids.put(key, s);
            // This DefineTag is potentially very generic, for example
            // it's name is most likely null, so don't bother adding
            // it to the tags Map.
        }
        else
        {
            if (t.equals(s))
                throw new IllegalArgumentException("symbol " + id + " redefined by identical tag");
            else
                throw new IllegalArgumentException("symbol " + id + " redefined by different tag");
        }
    }

    public void addName(DefineTag s, String name)
    {
        names.put(name, s);
    }

    private static String makeFontKey( String name, boolean bold, boolean italic )
    {
        return name + (bold? "_bold_" : "_normal_") + (italic? "_italic" : "_regular");
    }
    public void addFontFace(DefineFont defineFont)
    {
        fonts.put( makeFontKey(defineFont.getFontName(), defineFont.isBold(), defineFont.isItalic() ), defineFont );
    }
    public DefineFont getFontFace(String name, boolean bold, boolean italic)
    {
        return fonts.get( makeFontKey( name, bold, italic ) );
    }

    public boolean contains(String name)
    {
        return names.containsKey(name);
    }

    public DefineTag getTag(String name)
    {
        return names.get(name);
    }

    /**
     * @throws IllegalArgumentException if the id is not defined
     * @param idref
     * @return
     */
    public DefineTag getTag(int idref)
            throws IllegalArgumentException
    {
        Integer key = new Integer(idref);
        DefineTag t = ids.get(key);
        if (t == null)
        {
			// [tpr 7/6/04] work around authoring tool bug of bogus 65535 ids
			if(idref != 65535)
				throw new IllegalArgumentException("symbol " + idref + " not defined");
			else
				return INVALID_TAG;
        }
        return t;
    }

	// method added to support Flash Authoring - jkamerer 2007.07.30
	public void setNextId(int nextId)
	{
		this.nextId = nextId;
	}

	// method added to support Flash Authoring - jkamerer 2007.07.30
	public int getNextId()
	{
		return nextId;
	}
}
