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

package flex.tools.debugger.cli;

import flash.tools.debugger.Watch;

/**
 * An object that relates a CLI debugger watchpoint with the
 * actual Watch obtained from the Session
 */
public class WatchAction
{
	Watch		m_watch;
	int			m_id;             

	public WatchAction(Watch w) 
	{
		init(w);
	}

	void init(Watch w)
	{
		m_watch = w;
		m_id = BreakIdentifier.next();
	}

	/* getters */
	public int			getId()					{ return m_id; }
	public long			getVariableId()			{ return m_watch.getValueId(); }
	public int			getKind()				{ return m_watch.getKind(); }
	public Watch		getWatch()				{ return m_watch; }

	public String		getExpr()
	{
		String memberName = m_watch.getMemberName();
		int namespaceSeparator = memberName.indexOf("::"); //$NON-NLS-1$
		if (namespaceSeparator != -1)
			memberName = memberName.substring(namespaceSeparator + 2);
		return "#"+getVariableId()+"."+memberName; //$NON-NLS-1$ //$NON-NLS-2$
	}

	/* setters */
	public void			resetWatch(Watch w)		{ m_watch = w; }
}
