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

import flash.swf.Action;
import flash.swf.ActionHandler;
import flash.swf.ActionConstants;

/**
 * Represents an AS2 "branch" byte code.
 */
public class Branch extends Action
{
	public Branch(int code)
	{
		super(code);
	}

    public void visit(ActionHandler h)
	{
        if (code == ActionConstants.sactionJump)
    		h.jump(this);
        else
            h.ifAction(this);
	}

    /**
	 * branch offset relative to the next instruction after the JUMP
	 */
    public Label target;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof Branch))
        {
            Branch branch = (Branch) object;
            
            if ( branch.target == this.target )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
