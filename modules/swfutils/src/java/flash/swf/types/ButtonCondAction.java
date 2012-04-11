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

package flash.swf.types;

/**
 * This class represents a AS2 "button conditional action" byte code.
 *
 * @author Clement Wong
 */
public class ButtonCondAction
{
	/**
	 * SWF 4+: key code
		Otherwise: always 0
		Valid key codes:
		1: left arrow
		2: right arrow
		3: home
		4: end
		5: insert
		6: delete
		8: backspace
		13: enter
		14: up arrow
		15: down arrow
		16: page up
		17: page down
		18: tab
		19: escape
		32-126: follows ASCII
	 */
	public int keyPress;

	public boolean overDownToIdle;
	public boolean idleToOverDown;
	public boolean outDownToIdle;
	public boolean outDownToOverDown;
	public boolean overDownToOutDown;
	public boolean overDownToOverUp;
	public boolean overUpToOverDown;
	public boolean overUpToIdle;
	public boolean idleToOverUp;

	/**
	 * actions to perform when this event is detected.
	 */
	public ActionList actionList;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof ButtonCondAction)
        {
            ButtonCondAction buttonCondAction = (ButtonCondAction) object;

            if ( (buttonCondAction.keyPress == this.keyPress) &&
                 (buttonCondAction.overDownToIdle == this.overDownToIdle) &&
                 (buttonCondAction.idleToOverDown == this.idleToOverDown) &&
                 (buttonCondAction.outDownToIdle == this.outDownToIdle) &&
                 (buttonCondAction.outDownToOverDown == this.outDownToOverDown) &&
                 (buttonCondAction.overDownToOutDown == this.overDownToOutDown) &&
                 (buttonCondAction.overDownToOverUp == this.overDownToOverUp) &&
                 (buttonCondAction.overUpToOverDown == this.overUpToOverDown) &&
                 (buttonCondAction.overUpToIdle == this.overUpToIdle) &&
                 (buttonCondAction.idleToOverUp == this.idleToOverUp) &&
                 ( ( (buttonCondAction.actionList == null) && (this.actionList == null) ) ||
                   ( (buttonCondAction.actionList != null) && (this.actionList != null) &&
                     buttonCondAction.actionList.equals(this.actionList) ) ) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

	public String toString()
	{
		// return the flags as a string
		StringBuilder b = new StringBuilder();

        if (keyPress != 0)      b.append("keyPress<"+keyPress+">,");
		if (overDownToIdle)		b.append("overDownToIdle,");
		if (idleToOverDown)		b.append("idleToOverDown,");
		if (outDownToIdle)		b.append("outDownToIdle,");
		if (outDownToOverDown)	b.append("outDownToOverDown,");
		if (overDownToOutDown)	b.append("overDownToOutDown,");
		if (overDownToOverUp)	b.append("overDownToOverUp,");
		if (overUpToOverDown)	b.append("overUpToOverDown,");
		if (overUpToIdle)		b.append("overUpToIdle,");
		if (idleToOverUp)		b.append("idleToOverUp,");

        // trim trailing comma
		if (b.length() > 0)
			b.setLength(b.length()-1);

		return b.toString();
	}
}
