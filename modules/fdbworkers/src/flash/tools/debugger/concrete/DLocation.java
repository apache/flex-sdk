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

import flash.tools.debugger.Location;
import flash.tools.debugger.SourceFile;

public class DLocation implements Location
{
	SourceFile	m_source;
	int			m_line;
	int m_isolateId;
	boolean     m_removed;

	DLocation(SourceFile src, int line, int isolateId)
	{
		m_source = src;
		m_line = line;
		m_removed = false;
		m_isolateId = isolateId;
	}

	/* getters/setters */
	public SourceFile	getFile()						{ return m_source; }
    public int		    getLine()						{ return m_line; }
	public boolean		isRemoved()						{ return m_removed; }
	public void			setRemoved(boolean removed)		{ m_removed = removed; }

	public int			getId() { return encodeId(getFile().getId(), getLine()); }

	/* encode /decode */
	public static final int encodeId(int fileId, int line)
	{
		return ( (line << 16) | fileId );
	}
	
	public static final int decodeFile(long id)
	{
		return (int)(id & 0xffff);
	}

	public static final int decodeLine(long id)
	{
		return (int)(id >> 16 & 0xffff);
	}
	
	/** for debugging */
	@Override
	public String toString()
	{
		return m_source.toString() + ":" + m_line; //$NON-NLS-1$
	}

	@Override
	public int getIsolateId() {
		return m_isolateId;
	}
}
