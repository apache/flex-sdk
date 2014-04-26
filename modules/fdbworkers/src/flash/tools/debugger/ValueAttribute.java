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
 * @author mmorearty
 */
public interface ValueAttribute
{

	/**
	 * Indicates that the value that has been returned for a variable
	 * is actually not its real value; instead, it is the message of
	 * an exception that was thrown while executing the getter for
	 * the variable.
	 */
	public static final int IS_EXCEPTION			= 0x00040000;

	/**
	 * Indicates that an object is actually a Class.  For example, if you have
	 *
	 * <pre>    var someClass:Class = Button;</pre>
	 * 
	 * ... then someClass will have IS_CLASS set to true.
	 */
	public static final int IS_CLASS				= 0x04000000;
}
