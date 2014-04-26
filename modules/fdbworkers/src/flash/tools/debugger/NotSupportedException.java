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
 * Indicates that a debugger feature is not supported by the Flash
 * player that is being targeted.  For example, newer players
 * support the ability to have the debugger call arbitrary
 * functions, but older ones do not.
 * 
 * @author Mike Morearty
 */
public class NotSupportedException extends PlayerDebugException {
	private static final long serialVersionUID = -8873935118857320824L;

	/**
	 * @param s an error message, e.g. "Target player does not support
	 * function calls," or "Target player does not support watchpoints".
	 */
	public NotSupportedException(String s)
	{
		super(s);
	}
}
