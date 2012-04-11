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
 * Represents an AS2 "try" byte code.
 */
public class Try extends Action
{
    public Try()
    {
        super(ActionConstants.sactionTry);
    }

    public void visit(ActionHandler h)
    {
        h.tryAction(this);
    }

    public int flags;

	/** name of variable holding the error object in catch body */
    public String catchName;

	/** register that holds the catch variable */
	public int catchReg;

	/** marks end of body and start of catch handler */
	public Label endTry;
	/** marks end of catch handler and start of finally handler */
	public Label endCatch;
	/** marks end of finally handler */
	public Label endFinally;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof Try))
        {
            Try tryAction = (Try) object;

            if ( (tryAction.flags == this.flags) &&
                 equals(tryAction.catchName, this.catchName) &&
                 (tryAction.catchReg == this.catchReg) &&
                 tryAction.endTry == this.endTry &&
                 tryAction.endCatch == this.endCatch &&
                 tryAction.endFinally == this.endFinally )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

	public boolean hasCatch()
	{
		return (flags & ActionConstants.kTryHasCatchFlag) != 0;
	}

	public boolean hasFinally()
	{
		return (flags & ActionConstants.kTryHasFinallyFlag) != 0;
	}

	public boolean hasRegister()
	{
		return (flags & ActionConstants.kTryCatchRegisterFlag) != 0;
	}
}
