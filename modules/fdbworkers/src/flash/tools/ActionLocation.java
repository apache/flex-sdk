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

package flash.tools;

import flash.swf.types.ActionList;
import flash.swf.actions.ConstantPool;
import flash.swf.actions.DefineFunction;

/**
 * ActionLocation record.  Used to contain
 * information regarding a specific location
 * within an action record.  
 * 
 * at and actions are typically guaranteed to 
 * be filled out.  The others are optional.
 * @see SwfActionContainer
 */
public class ActionLocation
{
	public ActionLocation()						{ init(-1, null, null, null, null); }
	public ActionLocation(ActionLocation base)	{ init(base.at, base.actions, base.pool, base.className, base.function); }

	void init(int p1, ActionList p2, ConstantPool p3, String p4, DefineFunction p5)
	{
		at = p1;
		actions = p2;
		pool = p3;
		className = p4;
		function = p5;
	}

	public int				at = -1;
	public ActionList		actions;
	public ConstantPool		pool;
	public String			className;
	public DefineFunction	function;
}

