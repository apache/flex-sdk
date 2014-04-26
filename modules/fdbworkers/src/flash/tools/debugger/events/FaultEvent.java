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

import flash.tools.debugger.Isolate;

/**
 * An event type that signals a problem situation within the Player.
 * Under normal conditions the Player will suspend execution, resulting
 * in a following BreakEvent to be fired.  However, if this occurs
 * while a getter or setter is executing, then the player will *not*
 * suspend execution.
 */
public abstract class FaultEvent extends DebugEvent
{
	private String stackTrace = ""; //$NON-NLS-1$
	public int isolateId = Isolate.DEFAULT_ID; 
	
	
	public FaultEvent(String info, int isolateId)
	{
		super(getFirstLine(info));
		this.isolateId = isolateId;
		int newline = info.indexOf('\n');
		if (newline != -1)
			stackTrace = info.substring(newline+1);
	}

//	public FaultEvent()
//	{
//		super();
//	}
	
	public FaultEvent(int isolateId)
	{
		super();
		this.isolateId = isolateId;
	}

	public abstract String name();

	private static String getFirstLine(String s) {
		int newline = s.indexOf('\n');
		if (newline == -1)
			return s;
		else
			return s.substring(0, newline);
	}

	/**
	 * Returns the callstack in exactly the format that it came back
	 * from the player.  That is, as a single string of the following
	 * form:
	 *
	 * <pre>
	 *		at functionName()[filename:lineNumber]
	 *		at functionName()[filename:lineNumber]
	 *		...
	 * </pre>
	 *
	 * Each line has a leading tab character.
	 *
	 * @return callstack, or an empty string; never <code>null</code>
	 */
	public String stackTrace()
	{
		return stackTrace;
	}
}
