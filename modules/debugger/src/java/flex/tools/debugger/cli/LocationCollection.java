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

import java.util.ArrayList;
import java.util.Iterator;

import flash.tools.debugger.Location;

/**
 * This object is a container for source locations
 * that represent the same underlying file and line
 * number. 
 *
 * The reason we need this is because multiple 
 * swfs each contain their own unique version of
 * a source file and we'd like to be able to 
 * refer to any one location freely 
 * 
 * It is modelled after the Collection interface
 */
public class LocationCollection
{
	private ArrayList<Location> m_locations = new ArrayList<Location>();

	public boolean		add(Location l)			{ return m_locations.add(l); }
	public boolean		contains(Location l)	{ return m_locations.contains(l); }
	public boolean		remove(Location l)		{ return m_locations.remove(l); }
	public boolean		isEmpty()				{ return m_locations.isEmpty(); }
	public Iterator<Location> iterator()		{ return m_locations.iterator(); }

    // Return the first Location object or null
	public Location     first()					{ return ( (m_locations.size() > 0) ? m_locations.get(0) : null ); }

	/**
	 * Removes Locations from the Collection which contain
	 * SourceFiles with Ids in the range [startingId, endingId].
	 */
	public void removeFileIdRange(int startingId, int endingId)
	{
		Iterator<Location> i = iterator();
		while(i.hasNext())
		{
			Location l = i.next();
			int id = (l.getFile() == null) ? -1 : l.getFile().getId();
			if (id >= startingId && id <= endingId)
				i.remove();
		}
	}

	/**
	 * See if the collection contains a Location 
	 * which is identical to the given file id and 
	 * line number
	 */
	public boolean contains(int fileId, int line)
	{
		boolean found = false;
		Iterator<Location> i = iterator();
		while(i.hasNext() && !found)
		{
			Location l = i.next();
			int id = (l.getFile() == null) ? -1 : l.getFile().getId();
			if (id == fileId && l.getLine() == line)
				found = true;
		}
		return found;
	}

	/** for debugging */
	public String toString()
	{
		return m_locations.toString();
	}
}
