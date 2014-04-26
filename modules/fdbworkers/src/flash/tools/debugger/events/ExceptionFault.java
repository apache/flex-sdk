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

package flash.tools.debugger.events;

import flash.tools.debugger.Value;

/**
 * Signals that a user exception has been thrown.
 */
public class ExceptionFault extends FaultEvent
{
	public final static String name = "exception"; //$NON-NLS-1$
	private final boolean m_willExceptionBeCaught;
	private final Value m_thrownValue;

	public ExceptionFault(String message, boolean willExceptionBeCaught, Value thrownValue, int isolateId)
	{
		super(message, isolateId);
		m_willExceptionBeCaught = willExceptionBeCaught;
		m_thrownValue = thrownValue;
	}

	@Override
	public String name()
	{
		return name;
	}

	/**
	 * Returns true if there is a "catch" block that is going to catch
	 * this exception, false if not.
	 */
	public boolean willExceptionBeCaught()
	{
		return m_willExceptionBeCaught;
	}

	/**
	 * The value that was thrown; may be null, because there are times when we
	 * cannot determine the value that was thrown.
	 */
	public Value getThrownValue()
	{
		return m_thrownValue;
	}
}
