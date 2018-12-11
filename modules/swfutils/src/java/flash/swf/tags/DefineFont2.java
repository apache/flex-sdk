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
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import flash.swf.Tag;
import flash.swf.TagHandler;
import flash.swf.types.KerningRecord;
import flash.swf.types.Rect;
import flash.swf.types.Shape;

/**
 * DefineFont2 improves on the functionality of the DefineFont tag.
 * Enhancements include:
 * <ul>
 * <li>32-bit entries in the offset table for fonts with more than 65535
 * glyphs.</li>
 * <li>Mapping to device fonts by incorporating all of the functionality of
 * DefineFontInfo.</li>
 * <li>Font metrics for improved layout of dynamic glyph text.</li>
 * </ul>
 * Note that DefineFont2 reserves space for a font bounds table and
 * kerning table. This information is not used through Flash Player 7,
 * though some minimal values must be present for these entries to
 * define a well formed tag.  A minimal Rect can be supplied for the
 * font bounds table and the kerning count can be set to 0 to omit the
 * kerning table. DefineFont2 was introduced in SWF version 3.
 */
public class DefineFont2 extends DefineFont
{
    /**
     * Constructor.
     */
    public DefineFont2()
    {
        this(stagDefineFont2);
    }

    protected DefineFont2(int code)
    {
        super(code);
    }

    //--------------------------------------------------------------------------
    //
    // Fields and Bean Properties
    //
    //--------------------------------------------------------------------------

    public boolean smallText;
    public boolean hasLayout;
    public boolean shiftJIS;
    public boolean ansi;
    public boolean wideOffsets;
    public boolean wideCodes;
    public boolean italic;
    public boolean bold;
    public int langCode;
    public String fontName;

    // U16 if wideOffsets == true, U8 otherwise
    public char[] codeTable;
    public int ascent;
    public int descent;
    public int leading;

    public Shape[] glyphShapeTable;
    public short[] advanceTable;
    public Rect[] boundsTable;
    public int kerningCount;
    public KerningRecord[] kerningTable;

    /**
     * The name of the font. This name is significant for embedded fonts at
     * runtime as it determines how one refers to the font in CSS. In SWF 6 and
     * later, font names are encoded using UTF-8. In SWF 5 and earlier, font
     * names are encoded in a platform specific manner in the codepage of the
     * system they were authored.
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

    /**
     * Find the immediate, first order dependencies.
     * 
     * @return Iterator of immediate references of this DefineFont.
     */
    public Iterator<Tag> getReferences()
    {
        List<Tag> refs = new LinkedList<Tag>();

        for (int i = 0; i < glyphShapeTable.length; i++)
            glyphShapeTable[i].getReferenceList(refs);

        return refs.iterator();
    }

    /**
     * Invokes the defineFont visitor on the given TagHandler.
     * 
     * @param handler The SWF TagHandler.
     */
    public void visit(TagHandler handler)
    {
        if (code == stagDefineFont2)
            handler.defineFont2(this);
    }

    //--------------------------------------------------------------------------
    //
    // Utility Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Tests whether this DefineFont2 tag is equivalent to another DefineFont2
     * tag instance.
     * 
     * @param object Another DefineFont2 instance to test for equality.
     * @return true if the given instance is considered equal to this instance
     */
    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof DefineFont2 && super.equals(object))
        {
            DefineFont2 defineFont = (DefineFont2)object;

            // wideOffsets and wideCodes not considered in the equality check
            // as these are determined at encoding time

            if ((defineFont.hasLayout == this.hasLayout) &&
                    (defineFont.shiftJIS == this.shiftJIS) &&
                    (defineFont.ansi == this.ansi) &&
                    (defineFont.italic == this.italic) &&
                    (defineFont.bold == this.bold) &&
                    (defineFont.langCode == this.langCode) &&
                    (defineFont.ascent == this.ascent) &&
                    (defineFont.descent == this.descent) &&
                    (defineFont.leading == this.leading) &&
                    (defineFont.kerningCount == this.kerningCount) &&
                    equals(defineFont.name, this.name) &&
                    equals(defineFont.fontName, this.fontName) &&
                    Arrays.equals(defineFont.glyphShapeTable, this.glyphShapeTable) &&
                    Arrays.equals(defineFont.codeTable, this.codeTable) &&
                    Arrays.equals(defineFont.advanceTable, this.advanceTable) &&
                    Arrays.equals(defineFont.boundsTable, this.boundsTable) &&
                    Arrays.equals(defineFont.kerningTable, this.kerningTable))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}