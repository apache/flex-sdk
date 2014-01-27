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

package flex.tools.debugger.cli;

import java.util.Vector;
import java.util.Iterator;

import flash.tools.debugger.Location;
import flash.tools.debugger.expression.ValueExp;


/**
 * An object that relates a CLI debugger breakpoint with an associated set
 * of CLI commands to perform.
 * 
 * A breakpoint can be enabled or disabled.  It can be set such
 * that it disabled or deletes itself after being hit N times.
 */
public class BreakAction
{
	// return values for getStatus()
	public final static int		RESOLVED = 1;
	public final static int		UNRESOLVED = 2;
	public final static int		AMBIGUOUS = 3;
	public final static int		NOCODE = 4;	// there is no executable code at the specified line

	/**
	 * This will be null if the user typed in a breakpoint expression which
	 * did not match any currently loaded location, but we have saved it
	 * (with status == UNRESOLVED) in case it gets resolved later when another
	 * SWF or ABC gets loaded.
	 */
	private LocationCollection	m_where;				// may be null

	/**
	 * This will be null if the breakpoint was created via the
	 * <code>BreakAction(String unresolvedLocation)</code> constructor.
	 */
	private String				m_breakpointExpression;	// may be null

	private Vector<String>		m_commands;
	private boolean				m_enabled;
	private boolean				m_autoDelete;
	private boolean				m_autoDisable;
	private boolean				m_silent;
	private boolean				m_singleSwf;			// is breakpoint meant for a single swf only
	private int					m_id;
	private int					m_hits;
	private ValueExp			m_condition;
	private String				m_conditionString;
	private int					m_status;

	public BreakAction(LocationCollection c) throws NullPointerException
	{
		m_where = c;
		m_where.first().getFile();  // force NullPointerException if l == null
		m_status = RESOLVED;
		init();
	}

	public BreakAction(String unresolvedLocation)
	{
		m_breakpointExpression = unresolvedLocation;
		m_status = UNRESOLVED;
		init();
	}

	private void init()
	{
		m_id = BreakIdentifier.next();
		m_commands = new Vector<String>();
	}

	/* getters */
	public int					getCommandCount()				{ return m_commands.size(); }
	public String				commandAt(int i)				{ return m_commands.elementAt(i); }
	public Location				getLocation()					{ return (m_where != null) ? m_where.first() : null; }
    public LocationCollection	getLocations()					{ return m_where; }
	public int					getId()							{ return m_id; }
	public int					getHits()						{ return m_hits; }
	public boolean				isEnabled()						{ return m_enabled; }
	public boolean				isAutoDisable()					{ return m_autoDisable; }
	public boolean				isAutoDelete()					{ return m_autoDelete; }
	public boolean				isSilent()						{ return m_silent; }
	public boolean				isSingleSwf()					{ return m_singleSwf; }
	public ValueExp				getCondition()					{ return m_condition; }
	public String				getConditionString()			{ return m_conditionString; }
	public String				getBreakpointExpression()		{ return m_breakpointExpression; }
	public int					getStatus()						{ return m_status; }

	/* setters */
	public void addCommand(String cmd)					{ m_commands.add(cmd); }
	public void clearCommands()							{ m_commands.clear(); }
	public void addLocation(Location l)					{ m_where.add(l); }
	public void setEnabled(boolean enable)				{ m_enabled = enable; }
	public void setAutoDisable(boolean disable)			{ m_autoDisable = disable; }
	public void setAutoDelete(boolean delete)			{ m_autoDelete = delete; }
	public void setSilent(boolean silent)				{ m_silent = silent; }
	public void setCondition(ValueExp c, String s)		{ m_condition = c;  m_conditionString = s; }
	public void clearCondition()						{ setCondition(null, ""); } //$NON-NLS-1$
	public void hit()									{ m_hits++; }
	public void clearHits()								{ m_hits = 0; }
	public void setSingleSwf(boolean singleSwf)			{ m_singleSwf = singleSwf; }
	public void setBreakpointExpression(String expr)	{ m_breakpointExpression = expr; }
	public void setStatus(int status)					{ m_status = status; }

	public void setLocations(LocationCollection loc)
	{
		m_where = loc;
		if (loc != null)
			setStatus(RESOLVED);
	}

	/*
	 * Check to see if our location matches the requested one
	 */
	public boolean locationMatches(int fileId, int line)
	{
		boolean match = false;
		LocationCollection col = getLocations();
		if (col != null)
		{
			Iterator itr = col.iterator();
		
			// probe all locations looking for a match
			while(!match && itr.hasNext())
			{
				Location l = (Location)itr.next();
				if (l != null && l.getFile().getId() == fileId && l.getLine() == line)
					match = true;
			}
		}
		return match;
	}
}
