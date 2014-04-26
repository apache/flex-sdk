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

/**
 * Flags to the OutGetVariable and OutGetVariableWhichInvokesGetter commands
 * which are sent from the debugger to the player.
 * 
 * These values must be kept in sync with 'enum OutGetVariableFlags' in
 * the player's playerdebugger.h file.
 *
 * @author mmorearty
 */
public interface GetVariableFlag
{
	/**
	 * Indicates that if the variable which is being retrieved is a
	 * getter, then the player should invoke the getter and return
	 * the result.  If this flag is *not* set, then the player will
	 * simply return the address of the getter itself.
	 */
	public static final int INVOKE_GETTER			= 0x00000001;

	/**
	 * Indicates that if the variable which is being retrieved is a
	 * compound object (e.g. an instance of a class, as opposed to
	 * a string or int or something like that), then the player
	 * should also return all of the child members of the object.
	 */
	public static final int ALSO_GET_CHILDREN		= 0x00000002;
	
	/**
	 * Indicates that when retrieving children, we only want fields
	 * and getters -- we are not interested in regular functions.
	 * This is an optimization to decrease the amount of network
	 * traffic.
	 */
	public static final int DONT_GET_FUNCTIONS		= 0x00000004;

	/**
	 * Indicates that when retrieving children, we also want to
	 * know exactly which class each child was defined in.  For
	 * example, if the variable is of class Foo which extends
	 * class Bar, we want to know which member fields came from
	 * Foo and which ones came from Bar.
	 */
	public static final int GET_CLASS_HIERARCHY		= 0x00000008;
}
