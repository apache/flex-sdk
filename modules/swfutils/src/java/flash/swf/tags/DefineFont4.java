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

import java.util.Arrays;

import flash.swf.TagHandler;

/**
 * Represents a DefineFont4 SWF tag.
 * 
 * @author Peter Farland
 */
public class DefineFont4 extends DefineFont implements Cloneable
{
    /**
     * Constructor.
     */
    public DefineFont4()
    {
        super(stagDefineFont4);
    }

    //--------------------------------------------------------------------------
    //
    // Fields and Bean Properties
    //
    //--------------------------------------------------------------------------

    public boolean hasFontData;
    public boolean smallText;
    public boolean italic;
    public boolean bold;
    public int langCode;
    public String fontName;
    public byte[] data;

    /**
     * The name of the font. This name is significant for embedded fonts at
     * runtime as it determines how one refers to the font in CSS. In SWF 6 and
     * later, font names are encoded using UTF-8.
     */
    public String getFontName()
    {
        return fontName;
    }

    /**
     * Reports whether the font face is bold.
     */
    public boolean isBold()
    {
        return bold;
    }

    /**
     * Reports whether the font face is italic.
     */
    public boolean isItalic()
    {
        return italic;
    }

    //--------------------------------------------------------------------------
    //
    // Visitor Methods
    //
    //--------------------------------------------------------------------------

    public void visit(TagHandler handler)
    {
        if (code == stagDefineFont4)
            handler.defineFont4(this);
    }

    //--------------------------------------------------------------------------
    //
    // Utility Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @return a shallow copy of this DefineFont4 instance.
     */
    public Object clone()
    {
        DefineFont4 copy = new DefineFont4();
        copy.hasFontData = hasFontData;
        copy.smallText = smallText;
        copy.italic = italic;
        copy.bold = bold;
        copy.langCode = langCode;
        copy.fontName = fontName;
        copy.data = data;
        return copy;
    }

    /**
     * Tests whether this DefineFont4 tag is equivalent to another DefineFont4
     * tag instance.
     * 
     * @param object Another DefineFont4 instance to test for equality.
     * @return true if the given instance is considered equal to this instance
     */
    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof DefineFont4 && super.equals(object))
        {
            DefineFont4 defineFont = (DefineFont4)object;

            if ((defineFont.hasFontData == this.hasFontData) &&
                    (defineFont.italic == this.italic) &&
                    (defineFont.bold == this.bold) &&
                    (defineFont.langCode == this.langCode) &&
                    (defineFont.smallText == this.smallText) &&
                    equals(defineFont.fontName, this.fontName) &&
                    Arrays.equals(defineFont.data, this.data))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
