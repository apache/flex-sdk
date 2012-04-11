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

import flash.swf.tags.ZoneRecord;

/**
 * A value object for glyph entry data.
 *
 * @author Clement Wong
 */
public class GlyphEntry implements Cloneable
{
    private GlyphEntry original;
    private int index;
    public int advance;

    //Utilities for DefineFont
    public char character;
    public Rect bounds;
    public ZoneRecord zoneRecord;
    public Shape shape;

    public Object clone()
    {
        Object clone = null;

        try
        {
            clone = super.clone();
            ((GlyphEntry) clone).original = this;
        }
        catch (CloneNotSupportedException cloneNotSupportedException)
        {
            // preilly: We should never get here, but just in case print a stack trace.
            cloneNotSupportedException.printStackTrace();
        }

        return clone;
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof GlyphEntry)
        {
            GlyphEntry glyphEntry = (GlyphEntry) object;

            if ( (glyphEntry.index == this.index) &&
                 (glyphEntry.advance == this.advance) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int getIndex()
    {
        int result;

        if (original != null)
        {
            result = original.getIndex();
        }
        else
        {
            result = index;
        }

        return result;
    }

    public void setIndex(int index)
    {
        this.index = index;
    }

    // Retained for coldfusion.document.CFFontManager implementation
    public void setShape(Shape s)
    {
        this.shape = s;
    }

    public Shape getShape()
    {
        return this.shape;
    }
}
