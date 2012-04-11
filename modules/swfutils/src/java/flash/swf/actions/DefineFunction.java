/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.swf.actions;

import java.util.Arrays;

import flash.swf.Action;
import flash.swf.ActionHandler;
import flash.swf.ActionConstants;
import flash.swf.types.ActionList;

/**
 * Represents an AS2 "define function" byte code.
 *
 * @author Clement Wong
 */
public class DefineFunction extends Action
{
	public static final int kPreloadThis		= 0x0001;
	public static final int kSuppressThis		= 0x0002;
	public static final int kPreloadArguments	= 0x0004;
	public static final int kSuppressArguments	= 0x0008;
	public static final int kPreloadSuper		= 0x0010;
	public static final int kSuppressSuper		= 0x0020;
	public static final int kPreloadRoot		= 0x0040;
	public static final int kPreloadParent		= 0x0080;
	public static final int kPreloadGlobal		= 0x0100;

	public DefineFunction(int code)
	{
		super(code);
	}

	public void visit(ActionHandler h)
	{
		if (code == ActionConstants.sactionDefineFunction)
			h.defineFunction(this);
		else
		{
			h.defineFunction2(this);
		}
	}

	public String name;
	public String[] params;
	public ActionList actionList;

	// defineFunction2 only
	public int[] paramReg;
	public int regCount;
	public int flags;

	// C: I want to expose the code size to MovieMetaData so that the profiler can output the
	//    function code size vs. performance... ActionEncoder should not use this value.
	//    ActionDecoder should set this value.
	public int codeSize;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineFunction))
        {
            DefineFunction defineFunction = (DefineFunction) object;

            if ( equals(defineFunction.name, this.name) &&
                 Arrays.equals(defineFunction.params, this.params) &&
                 equals(defineFunction.actionList, this.actionList) &&
                 Arrays.equals(defineFunction.paramReg, this.paramReg) &&
                 (defineFunction.regCount == this.regCount) &&
                 (defineFunction.flags == this.flags) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
