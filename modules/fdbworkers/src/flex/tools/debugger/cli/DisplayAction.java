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

import flash.tools.debugger.expression.ValueExp;

/**
 * An object that relates a CLI debugger 'display' command
 * with the contents of the display 
 */
public class DisplayAction
{
	private static int s_uniqueIdentifier  = 1;

	boolean		m_enabled;
	int			m_id;
	ValueExp	m_expression;
	String		m_content;
	int m_isolateId;

	public DisplayAction(ValueExp expr, String content, int isolateId)
	{
		init();
		m_expression = expr;
		m_content = content;
		m_isolateId = isolateId;
	}

	void init()
	{
		m_enabled = true;
		m_id = s_uniqueIdentifier++;
	}

	/* getters */
	public String		getContent()					{ return m_content; }
	public int			getId()							{ return m_id; }
	
	public int getIsolateId() {
		return m_isolateId;
	}
	public boolean		isEnabled()						{ return m_enabled; }
	public ValueExp		getExpression()					{ return m_expression; }

	/* setters */
	public void setEnabled(boolean enable)				{ m_enabled = enable; }
}
