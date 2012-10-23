/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.gvt.font;

import java.util.Arrays;

/**
 * The Kern class describes an entry in the "kerning table". It provides
 * a kerning value to be used when laying out characters side
 * by side. It may be used for either horizontal or vertical kerning.
 *
 * @author <a href="mailto:dean.jackson@cmis.csiro.au">Dean Jackson</a>
 * @version $Id: Kern.java 475685 2006-11-16 11:16:05Z cam $
 */
public class Kern {

    private int[] firstGlyphCodes;
    private int[] secondGlyphCodes;
    private UnicodeRange[] firstUnicodeRanges;
    private UnicodeRange[] secondUnicodeRanges;
    private float kerningAdjust;

    /**
     * Creates a Kern object with the given glyph arrays
     * and kerning value. The first and second sets of glyphs for this kerning
     * entry consist of the union of glyphs in the glyph code arrays and the
     * unicode ranges.
     *
     * @param firstGlyphCodes An array of glyph codes that are part of the first
     * set of glyphs in this kerning entry.
     * @param secondGlyphCodes An array of glyph codes that are part of the
     * second set of glyphs in this kerning entry.
     * @param firstUnicodeRanges An array of unicode ranges that are part of the
     * first set of glyphs in this kerning entry.
     * @param secondUnicodeRanges An array of unicode ranges that are part of
     * the second set of glyphs in this kerning entry.
     * @param adjustValue The kerning adjustment (positive value means the space
     * between glyphs should decrease).  
     */
    public Kern(int[] firstGlyphCodes, 
                int[] secondGlyphCodes,
                UnicodeRange[] firstUnicodeRanges,
                UnicodeRange[] secondUnicodeRanges,
                float adjustValue) {
        this.firstGlyphCodes = firstGlyphCodes;
        this.secondGlyphCodes = secondGlyphCodes;
        this.firstUnicodeRanges = firstUnicodeRanges;
        this.secondUnicodeRanges = secondUnicodeRanges;
        this.kerningAdjust = adjustValue;

        if (firstGlyphCodes != null) 
            Arrays.sort(this.firstGlyphCodes);
        if (secondGlyphCodes != null) 
            Arrays.sort(this.secondGlyphCodes);
    }

    /**
     * Returns true if the specified glyph is one of the glyphs considered
     * as first by this kerning entry. Returns false otherwise.
     *
     * @param glyphCode The id of the glyph to test.
     * @param glyphUnicode The unicode value of the glyph to test.
     * @return True if this glyph is in the list of first glyphs for
     * the kerning entry
     */
    public boolean matchesFirstGlyph(int glyphCode, String glyphUnicode) {
        if (firstGlyphCodes != null) {
            int pt = Arrays.binarySearch(firstGlyphCodes, glyphCode);
            if (pt >= 0) return true;
        }
        if (glyphUnicode.length() < 1) return false;
        char glyphChar = glyphUnicode.charAt(0);
        for (int i = 0; i < firstUnicodeRanges.length; i++) {
            if (firstUnicodeRanges[i].contains(glyphChar))
                return true;
        }
        return false;
    }

    /**
     * Returns true if the specified glyph is one of the glyphs considered
     * as first by this kerning entry. Returns false otherwise.
     *
     * @param glyphCode The id of the glyph to test.
     * @param glyphUnicode The unicode value of the glyph to test.
     * @return True if this glyph is in the list of first glyphs for
     *         the kerning entry
     */
    public boolean matchesFirstGlyph(int glyphCode, char glyphUnicode) {
        if (firstGlyphCodes != null) {
            int pt = Arrays.binarySearch(firstGlyphCodes, glyphCode);
            if (pt >= 0) return true;
        }
        for (int i = 0; i < firstUnicodeRanges.length; i++) {
            if (firstUnicodeRanges[i].contains(glyphUnicode))
                return true;
        }
        return false;
    }

    /**
     * Returns true if the specified glyph is one of the glyphs considered
     * as second by this kerning entry. Returns false otherwise.
     *
     * @param glyphCode The id of the glyph to test.
     * @param glyphUnicode The unicode value of the glyph to test.

     * @return True if this glyph is in the list of second glyphs for the
     * kerning entry 
     */
    public boolean matchesSecondGlyph(int glyphCode, String glyphUnicode) {
        if (secondGlyphCodes != null) {
            int pt = Arrays.binarySearch(secondGlyphCodes, glyphCode);
            if (pt >= 0) return true;
        }
        if (glyphUnicode.length() < 1) return false;
        char glyphChar = glyphUnicode.charAt(0);
        for (int i = 0; i < secondUnicodeRanges.length; i++) {
            if (secondUnicodeRanges[i].contains(glyphChar))
                return true;
        }
        return false;
    }

    /**
     * Returns true if the specified glyph is one of the glyphs considered
     * as second by this kerning entry. Returns false otherwise.
     *
     * @param glyphCode The id of the glyph to test.
     * @param glyphUnicode The unicode value of the glyph to test.

     * @return True if this glyph is in the list of second glyphs for the
     * kerning entry 
     */
    public boolean matchesSecondGlyph(int glyphCode, char glyphUnicode) {
        if (secondGlyphCodes != null) {
            int pt = Arrays.binarySearch(secondGlyphCodes, glyphCode);
            if (pt >= 0) return true;
        }
        for (int i = 0; i < secondUnicodeRanges.length; i++) {
            if (secondUnicodeRanges[i].contains(glyphUnicode))
                return true;
        }
        return false;
    }

    /**
     * Returns the kerning adjustment value for this kerning entry (a positive
     * value means the space between characters should decrease).
     *
     * @return The kerning adjustment for this kerning entry.
     */
    public float getAdjustValue() {
        return kerningAdjust;
    }

}
