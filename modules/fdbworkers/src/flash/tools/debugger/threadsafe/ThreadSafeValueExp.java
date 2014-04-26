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

package flash.tools.debugger.threadsafe;

import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.expression.Context;
import flash.tools.debugger.expression.NoSuchVariableException;
import flash.tools.debugger.expression.PlayerFaultException;
import flash.tools.debugger.expression.ValueExp;

/**
 * Thread-safe wrapper for flash.tools.debugger.expression.ValueExp
 * @author Mike Morearty
 */
public class ThreadSafeValueExp extends ThreadSafeDebuggerObject implements ValueExp
{
	private final ValueExp m_valueExp;

	public ThreadSafeValueExp(Object syncObj, ValueExp valueExp)
	{
		super(syncObj);
		m_valueExp = valueExp;
	}

	/**
	 * Wraps a ValueExp inside a ThreadSafeValueExp. If the passed-in
	 * ValueExp is null, then this function returns null.
	 */
	public static ThreadSafeValueExp wrap(Object syncObj, ValueExp valueExp) {
		if (valueExp != null)
			return new ThreadSafeValueExp(syncObj, valueExp);
		else
			return null;
	}

	public Object evaluate(Context context) throws NumberFormatException, NoSuchVariableException, PlayerFaultException, PlayerDebugException
	{
		synchronized (getSyncObject()) {
			return m_valueExp.evaluate(context);
		}
	}

	public boolean containsAssignment()
	{
		synchronized (getSyncObject()) {
			return m_valueExp.containsAssignment();
		}
	}

	public boolean isLookupMembers()
	{
		synchronized (getSyncObject()) {
			return m_valueExp.isLookupMembers();
		}
	}
}
