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

package flash.tools;

import flash.swf.Action;
import flash.swf.Header;
import flash.swf.TagDecoder;
import flash.swf.TagHandler;
import flash.swf.Dictionary;
import flash.swf.ActionConstants;
import flash.swf.MovieMetaData;
import flash.swf.tags.DefineButton;
import flash.swf.tags.DoAction;
import flash.swf.tags.DoInitAction;
import flash.swf.tags.PlaceObject;
import flash.swf.tags.DefineSprite;
import flash.swf.types.ActionList;
import flash.swf.types.ButtonCondAction;
import flash.swf.types.ClipActionRecord;
import flash.swf.actions.DefineFunction;
import flash.swf.actions.ConstantPool;
import flash.util.Trace;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;

/**
 * This class implements the TagHandler interface
 * and provides a mechanism for containing the
 * actions associated with a SWF.
 */
public class SwfActionContainer extends TagHandler
{
	boolean		errorProcessing = true;
	ActionList	m_master;

	// temporaries used while decoding
	Dictionary  m_dictionary; 
	Header		m_header;

    public SwfActionContainer(byte[] swf, byte[] swd)	{ this(new ByteArrayInputStream(swf), new ByteArrayInputStream(swd));	}
    public SwfActionContainer(InputStream swfIn)		{ this(swfIn, null); }

    public SwfActionContainer(InputStream swfIn, InputStream swdIn)
	{
		TagDecoder p = new TagDecoder(swfIn, swdIn);
		try
		{
			process(p);
			errorProcessing = false;
		}
		catch(IOException io)
		{
			if (Trace.error)
				io.printStackTrace();
		}
	}

	// getters 
	public ActionList	getMasterList() { return m_master; }
	public Header		getHeader()		{ return m_header; }
	public Dictionary	getDictionary() { return m_dictionary; }

	// Did we hit an error in processing the swf? 
	public boolean hasErrors() { return errorProcessing; }

	/**
	 * Ask a TagDecoder to do its magic, calling us 
	 * upon each encounter of a new tag.
	 */
	void process(TagDecoder d) throws IOException
	{
		m_master = new ActionList(true);
        d.setKeepOffsets(true);
		d.parse(this);
	}

	/**
	 * Return a path to an ActionList that contains the given offset
	 * if an exact match is not found then return the largest
	 * that does not exceed offset.
	 */
	public ActionLocation locationLessOrEqualTo(int offset)
	{
		ActionLocation l = new ActionLocation();
		locationLessOrEqualTo(l, m_master, offset);
		return l;
	}

    public static ActionLocation locationLessOrEqualTo(ActionLocation location, ActionList list, int offset)
	{
		int at = findLessOrEqualTo(list, offset);
		if (at > -1)
		{
			// we hit so mark it and extract a constant pool if any
			location.at = at;
			location.actions = list;

			Action a = list.getAction(0);
			if (a.code == ActionConstants.sactionConstantPool)
				location.pool = (ConstantPool)a;

			// then see if we need to traverse
			a = list.getAction(at);
			if ( (a.code == ActionConstants.sactionDefineFunction) ||
				 (a.code == ActionConstants.sactionDefineFunction2) )
			{
				location.function = (DefineFunction)a;
				locationLessOrEqualTo(location, ((DefineFunction)a).actionList, offset);
			}
			else if (a instanceof DummyAction)
			{
				// our dummy container, then we drop in
				locationLessOrEqualTo(location, ((DummyAction)a).getActionList(), offset);
			}
		}
		return location;
	}

	// find the index of the largest offset in the list that does not
	// exceed the offset value provided. 
	public static int findLessOrEqualTo(ActionList list, int offset)
	{
		int i = find(list, offset);
		if (i < 0)
		{
			// means we didn't locate it, so get the next closest one
			// which is 1 below the insertion point
			i = (-i - 1) - 1;
		}
		return i;
	}

	// perform a binary search to locate the offset within the sorted
	// list of offsets within the action list.
	// if no match then (-i - 1) provides the index of where an insertion
	// would occur for this offset in the list.
	public static int find(ActionList list, int offset)
	{
        int lo = 0;
        int hi = list.size()-1;

        while (lo <= hi)
        {
            int i = (lo + hi)/2;
            int m = list.getOffset(i);
            if (offset > m)
                lo = i + 1;
            else if (offset < m)
                hi = i - 1;
            else
                return i; // offset found
        }
        return -(lo + 1);  // offset not found, low is the insertion point
	}

	/**
	 * Dummy Action container for housing all of  our
	 * topmost level actionlists in a convenient form
	 */
	public class DummyAction extends Action
	{
		public DummyAction(ActionList list)
		{
			super(ActionConstants.sactionNone);
			m_actionList = list;
		}

		// getters/setters
		public ActionList		getActionList()					{ return m_actionList; }
		public String			getClassName()					{ return m_className; }
		public void				setClassName(String name)		{ m_className = name; }

		private ActionList		m_actionList;
		private String			m_className;
	}

	/**
	 * Store away the ActionLists for later retrieval
	 */
    DummyAction recordActions(ActionList list)
    {
		DummyAction da = null;
		if (list != null && list.size() > 0)
		{
			// use the first offset as our reference point
			int offset = list.getOffset(0);

			// now create a pseudo action for this action list in our master
			da = new DummyAction(list);
			m_master.setActionOffset(offset, da);
		}
		return da;
	}

	/**
	 * -----------------------------------------------
	 * The following APIs override TagHandler.
	 * -----------------------------------------------
	 */
	@Override
	public void doInitAction(DoInitAction tag)
	{
		DummyAction a = recordActions(tag.actionList);

		// now fill in the class name if we can
		if (m_header.version > 6 && tag.sprite != null)
		{
			String __Packages = MovieMetaData.idRef(tag.sprite, m_dictionary);
			String className = (__Packages != null && __Packages.startsWith("__Packages")) ? __Packages.substring(11) : null; //$NON-NLS-1$
			a.setClassName(className);
		}
	}

	@Override
	public void doAction(DoAction tag)
	{
		recordActions(tag.actionList);
	}


	@Override
	public void defineSprite(DefineSprite tag)
	{
		// @todo need to support actions in sprites!!! 
	}

	@Override
	public void placeObject2(PlaceObject tag)
	{
		if (tag.hasClipAction())
		{
            Iterator it = tag.clipActions.clipActionRecords.iterator();
            while (it.hasNext())
            {
    		    ClipActionRecord record = (ClipActionRecord) it.next();
   			    recordActions(record.actionList);
            }
		}
	}

	@Override
	public void defineButton(DefineButton tag)
	{
		recordActions(tag.condActions[0].actionList);
	}

	@Override
	public void defineButton2(DefineButton tag)
	{
        if (tag.condActions.length > 0)
        {
            for (int i=0; i < tag.condActions.length; i++)
            {
                ButtonCondAction cond = tag.condActions[i];
                recordActions(cond.actionList);
            }
		}
	}

	@Override
	public void setDecoderDictionary(Dictionary dict)
	{
		m_dictionary = dict;
	}

	@Override
	public void header(Header h)
	{
		m_header = h;
	}

	/**
	 * -----------------------------------------------
	 * END: override TagHandler.
	 * -----------------------------------------------
	 */
}
