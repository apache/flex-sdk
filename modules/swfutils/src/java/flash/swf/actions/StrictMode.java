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
 * Represents an AS2 "strict mode" byte code.
 */
public class StrictMode extends Action
{
	public StrictMode(boolean mode)
	{
		super(ActionConstants.sactionStrictMode);
		this.mode = mode;
	}

	public void visit(ActionHandler h)
	{
		h.strictMode(this);
	}

    public boolean mode;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof StrictMode))
        {
            StrictMode strictMode = (StrictMode) object;

            if (strictMode.mode == this.mode)
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
