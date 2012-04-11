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

package flash.swf.tags;

import flash.swf.Tag;
import flash.swf.TagHandler;
import flash.swf.types.ButtonCondAction;
import flash.swf.types.ButtonRecord;
import java.util.Arrays;
import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * This class represents a DefineButton SWF tag.
 *
 * @author Clement Wong
 */
public class DefineButton extends DefineTag
{
    public DefineButton(int code)
    {
        super(code);
    }

    public void visit(TagHandler h)
	{
        if (code == stagDefineButton)
    		h.defineButton(this);
        else
            h.defineButton2(this);
	}

	public Iterator<Tag> getReferences()
    {
        return new Iterator<Tag>()
        {
            private int record = 0;

            public boolean hasNext()
            {
				// skip null entries
				while (record < buttonRecords.length && buttonRecords[record].characterRef == null)
					record++;
                return record < buttonRecords.length;
            }
            public Tag next()
            {
                if ( !hasNext() )
                    throw new NoSuchElementException();
                return buttonRecords[record++].characterRef;
            }
            public void remove()
            {
                throw new UnsupportedOperationException();
            }
        };
    }

	public ButtonRecord[] buttonRecords;
    public DefineButtonSound sounds;
    public DefineButtonCxform cxform;
    public DefineScalingGrid scalingGrid;

    /**
     * false = track as normal button
     * true = track as menu button
     */
    public boolean trackAsMenu;

    /**
     * actions to execute at particular button events.  For defineButton
     * this will only have one entry.  For defineButton2 it could have more
     * than one entry for different conditions.
     */
    public ButtonCondAction[] condActions;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineButton))
        {
            DefineButton defineButton = (DefineButton) object;

            if ( Arrays.equals(defineButton.buttonRecords, this.buttonRecords) &&
                 equals(defineButton.sounds, this.sounds) &&
                 equals(defineButton.cxform, this.cxform) &&
                 (defineButton.trackAsMenu == this.trackAsMenu) &&
                 Arrays.equals(defineButton.condActions, this.condActions) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
