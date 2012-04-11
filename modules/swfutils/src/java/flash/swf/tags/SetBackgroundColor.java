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

/**
 * This represents a SetBackgroundColor SWF tag.  It is used to set
 * the background color of the SWF.
 *
 * @author Clement Wong
 */
public class SetBackgroundColor extends Tag
{
	public SetBackgroundColor()
	{
		super(stagSetBackgroundColor);
	}

    public SetBackgroundColor(int color)
    {
        this();
        this.color = color;
    }

    public void visit(TagHandler h)
	{
		h.setBackgroundColor(this);
	}

    /** color as int: 0x00RRGGBB */
    public int color;

    public int hashCode()
    {
        return super.hashCode() ^ color;
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof SetBackgroundColor))
        {
            SetBackgroundColor setBackgroundColor = (SetBackgroundColor) object;

            if (setBackgroundColor.color == this.color)
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
