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

import flash.swf.Tag;
import flash.swf.tags.DefineFont;

import java.util.Arrays;
import java.util.List;

/**
 * A value object for text record data.
 *
 * @author Clement Wong
 */
public class TextRecord
{
    private static final int HAS_FONT = 8;
    private static final int HAS_COLOR = 4;
    private static final int HAS_X = 1;
    private static final int HAS_Y = 2;
    private static final int HAS_HEIGHT = 8; // yep, same as HAS_FONT.  see player/core/stags.h
    public int flags = 128;

    /** color as integer 0x00RRGGBB or 0xAARRGGBB */
    public int color;

    public int xOffset;
    public int yOffset;
    public int height;
    public DefineFont font;
    public GlyphEntry[] entries;

    public void getReferenceList( List<Tag> refs )
    {
        if (hasFont() && font != null)
            refs.add( font );
    }

    public boolean hasFont()
    {
        return (flags & HAS_FONT) != 0;
    }

    public boolean hasColor()
    {
        return (flags & HAS_COLOR) != 0;
    }

    public boolean hasX()
    {
        return (flags & HAS_X) != 0;
    }

    public boolean hasY()
    {
        return (flags & HAS_Y) != 0;
    }

    public boolean hasHeight()
    {
        return (flags & HAS_HEIGHT) != 0;
    }

    public void setFont(DefineFont font)
    {
        this.font = font;
        flags |= HAS_FONT;
    }

    public void setHeight(int i)
    {
        this.height = i;
        flags |= HAS_HEIGHT;
    }

    public void setColor(int color)
    {
        flags |= HAS_COLOR;
        this.color = color;
    }

    public void setX(int xOffset)
    {
        this.xOffset = xOffset;
        flags |= HAS_X;
    }

    public void setY(int yOffset)
    {
        this.yOffset = yOffset;
        flags |= HAS_Y;
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof TextRecord)
        {
            TextRecord textRecord = (TextRecord) object;

            if ( (textRecord.flags == this.flags) &&
                 (textRecord.color == this.color) &&
                 (textRecord.xOffset == this.xOffset) &&
                 (textRecord.yOffset == this.yOffset) &&
                 (textRecord.height == this.height) &&
                 (textRecord.font == this.font) &&
                 ( Arrays.equals(textRecord.entries, this.entries) ) )

            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
