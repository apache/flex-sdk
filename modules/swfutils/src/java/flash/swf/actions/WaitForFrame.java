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
 * Represents an AS2 "wait for frame" byte code.
 *
 * @author Clement Wong
 */
public class WaitForFrame extends Action
{
	public WaitForFrame(int code)
	{
		super(code);
	}

    public void visit(ActionHandler h)
	{
		if (code == ActionConstants.sactionWaitForFrame)
			h.waitForFrame(this);
		else
			h.waitForFrame2(this);
	}

    /**
	 * Frame number to wait for (WaitForFrame only).  WaitForFrame2 takes
     * its frame argument from the stack.
	 */
	public int frame;

	/**
	 *  label marking the number of actions to skip if frame is not loaded
	 */
	public Label skipTarget;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof WaitForFrame))
        {
            WaitForFrame waitForFrame = (WaitForFrame) object;

            if ( (waitForFrame.frame == this.frame) && 
                 (waitForFrame.skipTarget == this.skipTarget) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
