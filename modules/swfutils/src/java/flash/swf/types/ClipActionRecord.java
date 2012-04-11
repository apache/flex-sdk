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
 * A value object for clip action record data.
 *
 * @author Clement Wong
 */
public class ClipActionRecord
{
    public static final int unused31 = 0x80000000;
    public static final int unused30 = 0x40000000;
    public static final int unused29 = 0x20000000;
    public static final int unused28 = 0x10000000;
    public static final int unused27 = 0x08000000;
    public static final int unused26 = 0x04000000;
    public static final int unused25 = 0x02000000;
    public static final int unused24 = 0x01000000;

    public static final int unused23 = 0x00800000;
    public static final int unused22 = 0x00400000;
    public static final int unused21 = 0x00200000;
    public static final int unused20 = 0x00100000;
    public static final int unused19 = 0x00080000;
    public static final int construct = 0x00040000;
    public static final int keyPress = 0x00020000;
    public static final int dragOut = 0x00010000;

    public static final int dragOver = 0x00008000;
    public static final int rollOut = 0x00004000;
    public static final int rollOver = 0x00002000;
    public static final int releaseOutside = 0x00001000;
    public static final int release = 0x00000800;
    public static final int press = 0x00000400;
    public static final int initialize = 0x00000200;
    public static final int data = 0x00000100;

    public static final int keyUp = 0x00000080;
    public static final int keyDown = 0x00000040;
    public static final int mouseUp = 0x00000020;
    public static final int mouseDown = 0x00000010;
    public static final int mouseMove = 0x00000008;
    public static final int unload = 0x00000004;
    public static final int enterFrame = 0x00000002;
    public static final int load =  0x00000001;

    /**
     * event(s) to which this handler applies
     */
	public int eventFlags;

    /**
     * if eventFlags.press is true, contains the key code to trap
     * @see ButtonCondAction
     */
	public int keyCode;

    /**
     * actions to perform
     */
	public ActionList actionList;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof ClipActionRecord)
        {
            ClipActionRecord clipActionRecord = (ClipActionRecord) object;

            if ( (clipActionRecord.eventFlags == this.eventFlags) &&
                 (clipActionRecord.keyCode == this.keyCode) &&
                 ( ( (clipActionRecord.actionList == null) && (this.actionList == null) ) ||
                   ( (clipActionRecord.actionList != null) && (this.actionList != null) &&
                     clipActionRecord.actionList.equals(this.actionList) ) ) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public boolean hasKeyPress()
    {
        return (eventFlags & keyPress) != 0;
    }
}
