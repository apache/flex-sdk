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
import flash.swf.tags.DoABC;
import flash.swf.tags.FrameLabel;
import flash.swf.tags.ImportAssets;
import flash.swf.tags.SymbolClass;
import flash.swf.tags.DefineFont;
import flash.swf.types.ActionList;

import java.util.*;

/**
 * Represents one SWF frame.  Each frame runs its initActions,
 * doActions, and control tags in a specific order, so we group them
 * this way while forming the movie.
 *
 * @author Edwin Smith
 */
public class Frame
{
	public List<ActionList> doActions;
	public List<Tag> controlTags;
	public FrameLabel label;
	public List<ImportAssets> imports;
	public int pos = 1;	

	private Map<String, DefineTag> exports;
	private List<DefineTag> exportDefs;

	public List<DoABC> doABCs;

	public SymbolClass symbolClass;

	public List<DefineFont> fonts;

	public Frame()
	{
		exports = new HashMap<String, DefineTag>();
		exportDefs = new ArrayList<DefineTag>();
		doActions = new ArrayList<ActionList>();
		controlTags = new ArrayList<Tag>();
		imports = new ArrayList<ImportAssets>();
		fonts = new ArrayList<DefineFont>();

		doABCs = new ArrayList<DoABC>();
		symbolClass = new SymbolClass();
	}

	public Iterator<Tag> getReferences()
	{
		ArrayList<Tag> list = new ArrayList<Tag>();

		// exported symbols
		for (Iterator<DefineTag> j = exportDefs.iterator(); j.hasNext();)
		{
			DefineTag def = j.next();
			list.add(def);
		}

        list.addAll( symbolClass.class2tag.values() );

		// definitions for control tags
		for (Iterator<Tag> j = controlTags.iterator(); j.hasNext();)
		{
			Tag tag = j.next();
			for (Iterator k = tag.getReferences(); k.hasNext();)
			{
				DefineTag def = (DefineTag) k.next();
				list.add(def);
			}
		}

		return list.iterator();
	}

    public void mergeSymbolClass(SymbolClass symbolClass)
    {
        this.symbolClass.class2tag.putAll( symbolClass.class2tag );
    }
	public void addSymbolClass(String className, DefineTag symbol)
	{      
        // FIXME: error below should be possible... need to figure out why it is happening when running 'ant frameworks'
		//DefineTag tag = (DefineTag)symbolClass.class2tag.get(className);
        //if (tag != null && ! tag.equals(symbol))
        //{
        //    throw new IllegalStateException("Attempted to define SymbolClass for " + className + " as both " +
        //            symbol + " and " + tag);
        //}
        this.symbolClass.class2tag.put( className, symbol );
	}

	public boolean hasSymbolClasses()
	{
		return !symbolClass.class2tag.isEmpty();
	}

	public void addExport(DefineTag def)
	{
		Object old = exports.put(def.name, def);
		if (old != null)
		{
			exportDefs.remove(old);
		}
		exportDefs.add(def);
	}

	public boolean hasExports()
	{
		return !exports.isEmpty();
	}

	public Iterator<DefineTag> exportIterator()
	{
		return exportDefs.iterator();
	}

	public void removeExport(String name)
	{
		Object d = exports.remove(name);
		if (d != null)
		{
			exportDefs.remove(d);
		}
	}

	public void setExports(Map definitions)
	{
		for (Iterator i = definitions.entrySet().iterator(); i.hasNext();)
		{
			Map.Entry entry = (Map.Entry) i.next();
			DefineTag def = (DefineTag) entry.getValue();
			addExport(def);
		}
	}

	public boolean hasFonts()
	{
		return !fonts.isEmpty();
	}

	public void addFont(DefineFont tag)
	{
		fonts.add(tag);
	}

	public Iterator<DefineFont> fontsIterator()
	{
		return fonts.iterator();
	}
}
