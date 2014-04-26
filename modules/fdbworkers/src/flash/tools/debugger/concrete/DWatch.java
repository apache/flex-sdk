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

import flash.tools.debugger.Watch;

/**
 * Holder of Watchpoint information
 */
public class DWatch implements Watch
{
	long		m_parentValueId;
	String		m_rawMemberName; // corresponds to Variable.getRawName()
	int			m_kind;
	int			m_tag;
	int m_isolateId;

	public DWatch(long id, String name, int kind, int tag, int isolateId)
	{
		m_parentValueId = id;
		m_rawMemberName = name;
		m_kind = kind;
		m_tag = tag;
		m_isolateId = isolateId;
	}

    public long			getValueId()	{ return m_parentValueId; }
	public String		getMemberName()	{ return m_rawMemberName; }
    public int			getKind()		{ return m_kind; }
    public int			getTag()		{ return m_tag; }
    
    public int getIsolateId() {
    	return m_isolateId;
    }
}
