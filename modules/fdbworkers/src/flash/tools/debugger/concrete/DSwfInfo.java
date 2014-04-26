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

package flash.tools.debugger.concrete;

import java.util.Map;

import flash.swf.debug.DebugModule;
import flash.swf.debug.LineRecord;
import flash.tools.ActionLocation;
import flash.tools.debugger.InProgressException;
import flash.tools.debugger.Isolate;
import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.Session;
import flash.tools.debugger.SourceFile;
import flash.tools.debugger.SwfInfo;
import flash.tools.debugger.events.FunctionMetaDataAvailableEvent;
import flash.util.IntMap;

public class DSwfInfo implements SwfInfo
{
	private int			m_index;
	private long		m_id;
	private IntMap		m_source;
	private String		m_path;
	private String		m_url;
	private String		m_host;
	private int			m_port;
	private boolean		m_swdLoading;
	private int			m_swfSize;
	private int			m_swdSize;
	private int			m_bpCount;
	private int			m_offsetCount;
	private int			m_scriptsExpected;
	private int			m_minId;		// first script id in the swf
	private int			m_maxId;		// last script id in this swf
	private byte[]		m_swf;			// actual swf contents
	private byte[]		m_swd;			// actual swd contents
	private boolean		m_unloaded;		// set if the player has unloaded this swf
	private Map<Long,Integer> m_local2Global; // local script id to global script id mapping table
	private int			m_numRefreshes; // number of refreshes we have taken
	private int         m_vmVersion;    // version of the vm

	private boolean						m_populated;	// set if we have already tried to load swf/swd for this info
	private LineFunctionContainer		m_container;	// used for pulling out detailed info about the swf

	private final static String UNKNOWN = PlayerSessionManager.getLocalizationManager().getLocalizedTextString("unknown"); //$NON-NLS-1$

	public DSwfInfo(int index, int isolateId)	
	{	
		// defaults values of zero
		m_id = 0;
		m_index = index;
		m_source = new IntMap();
		m_path = UNKNOWN;
		m_url = UNKNOWN;
		m_host = UNKNOWN;
		m_port = 0;
		m_swdLoading = true;
		m_scriptsExpected = -1;  // means not yet set by anyone!
		m_isolateId = isolateId;
		// rest default to null, 0 or false
	}

	/** SwfInfo interface */
	public String		getPath()												{ return m_path; }
	public String		getUrl()												{ return m_url; }
	public int			getSwfSize()											{ return m_swfSize; }
	public int			getSwdSize(Session s) throws InProgressException		{ swdLoaded(s); return m_swdSize; } 
	public boolean		isUnloaded()											{ return m_unloaded; }
	public boolean		isProcessingComplete()									{ return isPopulated(); } 
	public boolean		containsSource(SourceFile f)							{ return m_source.contains(f.getId()); }

	/* getters */
	public long			getId()					{ return m_id; }
	public String		getHost()				{ return m_host; }
	public int			getPort()				{ return m_port; }
	public int			getSwdSize() 			{ return m_swdSize; }
	public int			getRefreshCount()		{ return m_numRefreshes; }
	public boolean		isSwdLoading()			{ return m_swdLoading; }
	public boolean		isPopulated()			{ return m_populated; }
	public byte[]		getSwf()				{ return m_swf; }
	public byte[]		getSwd()				{ return m_swd; }
	public int			getSourceExpectedCount()	{ return m_scriptsExpected; }
    public int          getVmVersion()          { return m_vmVersion;  }

//	public int			getBreakpointCount() throws InProgressException	{ swdLoading(); return m_bpCount; }
//	public int			getOffsetCount() 		{ swdLoading(); return m_offsetCount; }
	public int			getSourceCount() 	{ return m_source.size(); }
	public int			getFirstSourceId() 	{ return m_minId; }
	public int			getLastSourceId() 	{ return m_maxId; }

    public void         setVmVersion(int vmVersion) { m_vmVersion = vmVersion;  }
	public void			setUnloaded()			{ m_unloaded = true; }
	public void			setSwf(byte[] swf)		{ m_swf = swf; }
	public void			setSwd(byte[] swd)		{ m_swd = swd; }
	public void			setPopulated()			{ m_swdLoading = false; m_populated = true; }  // no more waiting for swd, we're done
	public void			setSourceExpectedCount(int c) { m_scriptsExpected = c; }

	public void			addSource(int i, DModule m) { m_source.put(i, m); }

	/**
	 * Return the number of sources that we have
	 */
	public int getSourceCount(Session s) throws InProgressException	
	{ 
		// only if we don't have it all yet
		// then try to force a load
		if (!hasAllSource())
			swdLoaded(s); 

		return getSourceCount(); 
	}

	/**
	 * Return a list of our sources
	 */
	public SourceFile[] getSourceList(Session s) throws InProgressException		
	{
		// only if we don't have it all yet
		// then try to force a load
		if (!hasAllSource())
			swdLoaded(s); 

		return (SourceFile[])m_source.valuesToArray( new SourceFile[m_source.size()] ); 
	}

	/**
	 * Make sure that the player has loaded our swd.  If not
	 * we continue InProgressException to query the player for when its complete.
	 * At some point we give up and finally admit that
	 * we don't have a swd associated with this swf.
	 */
	void swdLoaded(Session s) throws InProgressException
	{
		if (isSwdLoading() && !isUnloaded())
		{
			// make the request 
//			System.out.println("Swdloaded " + m_isolateId);
			try { ((PlayerSession)s).requestSwfInfo(m_index, m_isolateId); } catch(NoResponseException nre) {}

			// I should now be complete
			if (!m_swdLoading)
				;  // done!
			else if (getSourceExpectedCount() > -1 && m_numRefreshes > 10)
				setPopulated();  // tried too many times, so bail big time, no swd available (only if we already have our expected count)
			else
				throw new InProgressException(); // still loading!!!
		}
	}

	/**
	 * This method returns true once we have all the scripts
	 * that we expect to ever have.  We can get the information about
	 * how many scripts we should get from two sources, 1) we may
	 * get an InSwfInfo message from the player which contains
	 * this value and 2) we may get a InNumScript message which
	 * contains a script count.  A small caveat of course, is that
	 * in case 1. we may also not get the a value if the swd has
	 * not been fully processed by the player yet. 
	 */
	public boolean hasAllSource()
	{
		boolean yes = false;
		int expect = getSourceExpectedCount();
		int have = getSourceCount();

		// if they are equal we are done, unless
		// our expectation has not been set and have not yet loaded our swd
		if (expect == -1 && isSwdLoading())
			yes = false;
		else if (expect == have)
			yes = true;
		else
			yes = false;

		return yes;
	}

	public void freshen(long id, String path, String url, String host, long port, boolean swdLoading, long swfSize, long swdSize, long bpCount, long offsetCount, long scriptCount, Map<Long,Integer> map, int minId, int maxId)
	{
		m_id = (int)id;
		m_path = path;
		m_url = url;
		m_host = host;
		m_port = (int)port;
		m_swfSize = (int)swfSize;
		m_swdSize = (int)swdSize;
		m_bpCount = (int)bpCount;
		m_offsetCount = (int)offsetCount;
		m_local2Global = map;
		m_minId = (swdSize > 0) ? minId : 0;
		m_maxId = (swdSize > 0) ? maxId : 0;
		m_swdLoading = swdLoading;
		m_numRefreshes++;

		// only touch expected count if swd already loaded
		if (!swdLoading)
			m_scriptsExpected = (int)scriptCount;
	}

	/**
	 * Locate the given offset within the swf
	 */
	public ActionLocation locate(int offset)
	{
		return m_container.locationLessOrEqualTo(offset);
	}

	/**
	 * Ask the container to locate the next line
	 * record following the location specified in the 
	 * location, without spilling over into the next
	 * action list
	 */
	public ActionLocation locateSourceLineEnd(ActionLocation l)
	{
		return locateSourceLineEnd(l, -1);
	}

	public ActionLocation locateSourceLineEnd(ActionLocation l, int stopAt)
	{
		ActionLocation end = m_container.endOfSourceLine(l);
		if (stopAt > -1 && end.at > stopAt)
			end.at = stopAt;
		return end;
	}

	/**
	 * Use the local2global script id map that was provided by the
	 * Player, so that we can take the local id contained in the swd
	 * and convert it to a global one that the player has annointed
	 * to this script.
	 */
	int local2Global(long id)
	{
		Integer g = m_local2Global.get(id);
		if (g != null)
			id = g.intValue();

		return (int) id;
	}

	/**
	 * Freshen the contents of this object with the given swf info
	 * The items that we touch are all swd related, as everything else
	 * has arrriave
	 */

	// temporary while we parse
	DManager m_manager;
	private int m_isolateId = Isolate.DEFAULT_ID;

	/**
	 * Extracts information out of the SWF/SWD in order to populate
	 * function line number tables in SourceFile variabels.
	 */
	public void parseSwfSwd(DManager manager)
	{
		m_manager = manager;

		// suck in the swf/swd into action lists and then walk the lists
		// looking for LineRecords
		m_container = new LineFunctionContainer(m_swf, m_swd);
		m_container.combForLineRecords(this);

		// we are done, sucess or no
		setPopulated();

		// log event that we have complete done
		manager.addEvent(new FunctionMetaDataAvailableEvent());
		m_manager = null;
	}

	/**
	 * This is a callback function from LineFunctionContainer.combForLineRecords()
	 * We extract what we want and then update the associated module
	 */
	public void processLineRecord(ActionLocation where, LineRecord r)
	{
		int line = r.lineno;
		String func = (where.function == null) ? null : where.function.name;
		DebugModule dm = r.module;

		// locate the source file
		int id = -1;
		DModule module;

		if (dm == null || where.at == -1)
			;
		else if ( (id = local2Global(dm.id)) < 0 )
			;
		else if ( (module = m_manager.getSource(id, Isolate.DEFAULT_ID)) == null )
			;
		else
			module.addLineFunctionInfo(where.actions.getOffset(where.at), line, func);
	}

	/* for debugging */
	@Override
	public String toString() {
		return m_path;
	}

	@Override
	public int getIsolateId() {
		return m_isolateId;
	}
}
