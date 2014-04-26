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

package flash.tools.debugger;

/**
 * Reasons for which the Flash Player will suspend itself
 */
public interface SuspendReason
{
	public static final int Unknown			= 0;
	
	/** We hit a breakpoint */
	public static final int Breakpoint  	= 1;
	
	/** A watchpoint was triggered */
	public static final int Watch			= 2;
	
	/** A fault occurred */
	public static final int Fault			= 3;

	public static final int StopRequest		= 4;

	/** A step completed */
	public static final int Step			= 5;

	public static final int HaltOpcode		= 6;
	
	/**
	 * Either a new SWF was loaded, or else one or more scripts (ABCs)
	 * from an existing SWF were loaded.
	 */
	public static final int ScriptLoaded	= 7;
}
