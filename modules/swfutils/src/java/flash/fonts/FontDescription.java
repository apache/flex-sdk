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

package flash.fonts;

/**
 * A FontDescription provides FontManagers a context that describes
 * how to locate a font for embedding, the font style characteristics
 * and any options that may control how it is to be embedded.
 */
public class FontDescription
{
    /**
     * The name to use to register the font with the SWF.
     */
    public String alias;

    /**
     * The source of the font information, typically a URL pointing to a font
     * file.
     * 
     * The source may alternatively be just a String representing the font
     * family name of a font installed locally on the operating system.
     */
    public Object source;

    /**
     * The font style, represented as an int.
     * 
     * Plain is 0, Bold is 1, Italic is 2, and Bold+Italic is 3.
     */
    public int style;

    /**
     * The Unicode characters to include in the DefineFont, or pass null to
     * include all available characters.
     */
    public String unicodeRanges;

    /**
     * Controls whether advanced anti-aliasing information should be included
     * (if it is available).
     */
    public boolean advancedAntiAliasing;

    /**
     * Controls whether the font should be embedded using compact font format
     * (if supported).
     */
    public boolean compactFontFormat;

    /**
     * Tests whether another FontDescription describes the same font.
     * 
     * Note that the alias is not considered in the comparison.
     * 
     * @param value Another FontDescription instance to test for equality.
     * @return
     */
    public boolean equals(Object value)
    {
        if (this == value)
        {
            return true;
        }
        else if (value != null && value instanceof FontDescription)
        {
            FontDescription other = (FontDescription)value;

            if (style != other.style)
                return false;
            
            if (compactFontFormat != other.compactFontFormat)
                return false;

            if (advancedAntiAliasing != other.advancedAntiAliasing)
                return false;

            if (unicodeRanges == null && other.unicodeRanges != null)
                return false;

            if (source == null && other.source != null)
                return false;

            if (unicodeRanges != null && !unicodeRanges.equals(other.unicodeRanges))
                return false;

            if (source != null && !source.equals(other.source))
                return false;

            return true;
        }

        return false;
    }

    /**
     * Computes a hash code for this FontDescription instance. Note that the
     * alias is not considered in calculating a hash code.
     * 
     * @return a hash code based on all fields used to describe the font. 
     */
    public int hashCode()
    {
        int result = style;

        if (source != null)
            result ^= source.hashCode();

        if (unicodeRanges != null)
            result ^= unicodeRanges.hashCode();

        return result;
    }
}
