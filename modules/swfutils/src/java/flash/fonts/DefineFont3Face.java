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

import flash.swf.tags.DefineFont3;
import flash.swf.types.GlyphEntry;

/**
 * A wrapper to make a DefineFont3 SWF Tag behave like a
 * CachedFontFace for use in the general Flex SDK FontManager
 * subsystem.
 */
public class DefineFont3Face extends CachedFontFace
{
    private final DefineFont3 tag;
    private final char[] indicies;
    private char firstChar;

    /**
     * Constructor.
     * @param tag The DefineFont. Must not be null and tag.codeTable must not
     * be null.
     */
    public DefineFont3Face(DefineFont3 tag)
    {
        super(tag.codeTable.length + 1);
        this.tag = tag;
        style = getStyle(tag);

        // Transpose the Array of chars into an Array of indicies into the 
        // other tables in the DefineFont tag...
        firstChar = tag.codeTable[0];
        int charCount = tag.codeTable.length;
        char lastChar = tag.codeTable[charCount - 1];
        indicies = new char[lastChar + 1];
        for (char i = 0; i < charCount; i++)
        {
            char c = tag.codeTable[i]; 
            indicies[c] = i;
        }

        if (tag.license != null)
        {
            copyright = tag.license.copyright;
        }

        if (tag.zones != null && tag.zones.zoneTable != null)
        {
            useTwips = true;
        }
    }

    //--------------------------------------------------------------------------
    // 
    // FontFace implementation
    //
    //--------------------------------------------------------------------------

    public boolean canDisplay(char c)
    {
        if (c < indicies.length)
        {
            int index = indicies[c];
            if (c == firstChar || index > 0)
                return true;
        }
        return false;
    }

    public int getAdvance(char c)
    {
        int index = indicies[c];
        return tag.advanceTable[index];
    }

    public int getAscent()
    {
        return tag.ascent;
    }

    public int getDescent()
    {
        return tag.descent;
    }

    public double getEmScale()
    {
        return 1.0;
    }

    public String getFamily()
    {
        return getFamily(tag);
    }

    public int getFirstChar()
    {
        return firstChar;
    }
    
    public GlyphEntry getGlyphEntry(char c)
    {
        return (GlyphEntry)glyphCache.get(c);
    }

    public int getLineGap()
    {
        return tag.leading;
    }

    public int getMissingGlyphCode()
    {
        return 0;
    }

    public int getNumGlyphs()
    {
        return tag.codeTable.length;
    }

    public double getPointSize()
    {
        return 1.0f;
    }

    public String getPostscriptName()
    {
        return getFamily(tag);
    }

    public static String getFamily(DefineFont3 tag)
    {
        String family = tag.fontName;
        if (tag.license != null)
        {
            String fontName = tag.license.fontName;
            if (fontName != null && !"".equals(fontName))
                family = tag.license.fontName;
        }
        return family;
    }
    
    public static int getStyle(DefineFont3 tag)
    {
        int style = 0;
        if (tag.bold)
            style += FontFace.BOLD;
        if (tag.italic)
            style += FontFace.ITALIC;
        return style;
    }

    public static GlyphEntry createGlyphEntryFromDefineFont(char c, char index, DefineFont3 tag)
    {
        GlyphEntry ge = new GlyphEntry();
        ge.character = c;
        ge.setIndex(index);

        if (tag.glyphShapeTable != null)
            ge.shape = tag.glyphShapeTable[index];

        if (tag.advanceTable != null)
            ge.advance = tag.advanceTable[index];

        if (tag.boundsTable != null)
            ge.bounds = tag.boundsTable[index];

        if (tag.zones != null && tag.zones.zoneTable != null)
            ge.zoneRecord = tag.zones.zoneTable[index];

        return ge;
    }

    //--------------------------------------------------------------------------
    // 
    // CachedFontFace implementation
    //
    //--------------------------------------------------------------------------

    protected GlyphEntry createGlyphEntry(char c)
    {
        char index = indicies[c];
        return createGlyphEntryFromDefineFont(c, index, tag);
    }

    protected GlyphEntry createGlyphEntry(char c, char referenceChar)
    {
        // We don't use any glyph index offsets based on a reference char.
        return createGlyphEntry(c);
    }

}
