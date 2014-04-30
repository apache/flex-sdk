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

import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.NotConnectedException;
import flash.tools.debugger.NotSuspendedException;
import flash.tools.debugger.Session;
import flash.tools.debugger.Value;
import flash.tools.debugger.Variable;
import flash.tools.debugger.concrete.PlayerSession;
import flash.tools.debugger.events.FaultEvent;

/**
 * A VariableFacade provides a wrapper around a Variable object
 * that provides a convenient way of storing parent information.
 * 
 * Don't ask me why we didn't just add a parent member to 
 * Variable and be done with it.
 */
public class VariableFacade implements Variable
{
	Variable	m_var;
	long		m_context;
	String		m_name;
	String		m_path;
	int m_isolateId;

	public VariableFacade(Variable v, long context, int m_isolateId)		{ init(context, v, null, m_isolateId); }
	public VariableFacade(long context, String name, int m_isolateId)	{ init(context, null, name, m_isolateId); }

	void init(long context, Variable v, String name, int isolateId)
	{
		m_var = v;
		m_context = context;
		m_name = name;
		m_isolateId = isolateId;
	}

	/**
	 * The variable interface 
	 */
	public String		getName()								{ return (m_var == null) ? m_name : m_var.getName(); }
	public String		getQualifiedName()						{ return (m_var == null) ? m_name : m_var.getQualifiedName(); }
	public String		getNamespace()							{ return m_var.getNamespace(); }
	public int			getLevel()								{ return m_var.getLevel(); }
	public String		getDefiningClass()						{ return m_var.getDefiningClass(); }
	public int			getAttributes()							{ return m_var.getAttributes(); }
	public int			getScope()								{ return m_var.getScope(); }
	public boolean		isAttributeSet(int variableAttribute)	{ return m_var.isAttributeSet(variableAttribute); }
	public Value		getValue()								{ return m_var.getValue(); }
	public boolean		hasValueChanged(Session s)				{ return m_var.hasValueChanged(s); }
	public FaultEvent setValue(Session s, int type, String value) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		return ((PlayerSession)s).setScalarMember(m_context, getQualifiedName(), type, value, m_var.getIsolateId());
	}
	@Override
	public String		toString()								{ return (m_var == null) ? m_name : m_var.toString(); }
	public String		getPath()								{ return m_path; }
	public void			setPath(String path)					{ m_path = path; }
	public boolean needsToInvokeGetter()						{ return m_var.needsToInvokeGetter(); }
	public void invokeGetter(Session s) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		m_var.invokeGetter(s);
	}

	/**
	 * Our lone get context (i.e. parent) interface 
	 */
	public long			getContext()									{ return m_context; }
	public Variable		getVariable()									{ return m_var; }
	@Override
	public int getIsolateId() {
		return m_isolateId;
	}
}
