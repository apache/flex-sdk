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
package org.apache.flex.forks.batik.gvt.text;

import java.awt.font.FontRenderContext;
import java.awt.font.TextLayout;
import java.text.AttributedCharacterIterator;
import java.text.AttributedString;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * An attributed character iterator that does the reordering of the characters
 * for bidirectional text. It reorders the characters so they are in visual order.
 * It also assigns a BIDI_LEVEL attribute to each character which can be used
 * to split the reordered ACI into text runs based on direction. ie. characters
 * in a text run will all have the same bidi level.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: BidiAttributedCharacterIterator.java 522271 2007-03-25 14:42:45Z dvholten $
 */
public class BidiAttributedCharacterIterator implements AttributedCharacterIterator {

    private AttributedCharacterIterator reorderedACI;
    private FontRenderContext frc;
    private int chunkStart;
    private int [] newCharOrder;
    private static final Float FLOAT_NAN = new Float(Float.NaN);


    protected BidiAttributedCharacterIterator
        (AttributedCharacterIterator reorderedACI,
         FontRenderContext frc,
         int chunkStart,
         int [] newCharOrder) {
        this.reorderedACI = reorderedACI;
        this.frc = frc;
        this.chunkStart = chunkStart;
        this.newCharOrder = newCharOrder;
    }


    /**
     * Constructs a character iterator that represents the visual display order
     * of characters within bidirectional text.
     *
     * @param aci The character iterator containing the characters in logical
     * order.
     * @param frc The current font render context
     */
    public BidiAttributedCharacterIterator(AttributedCharacterIterator aci,
                                           FontRenderContext           frc,
                                           int chunkStart) {

        this.frc = frc;
        this.chunkStart = chunkStart;
        aci.first();
        int   numChars    = aci.getEndIndex()-aci.getBeginIndex();
        AttributedString as;

         // Ideally we would do a 'quick' check on chars and
         // attributes to decide if we really need to do bidi or not.
        if (false) {
            // Believe it or not this is much slower than the else case
            // but the two are exactly equivalent (including the stripping
            // of null keys/values).
            as = new AttributedString(aci);
        } else {
            StringBuffer strB = new StringBuffer( numChars );
            char c = aci.first();
            for (int i = 0; i < numChars; i++) {
                strB.append(c);
                c = aci.next();
            }
            as = new AttributedString(strB.toString());
            int start=aci.getBeginIndex();
            int end  =aci.getEndIndex();
            int index = start;
            while (index < end) {
                aci.setIndex(index);
                Map attrMap = aci.getAttributes();
                int extent  = aci.getRunLimit();
                Map destMap = new HashMap(attrMap.size());
                Iterator it  = attrMap.entrySet().iterator();
                while (it.hasNext()) {
                    // Font doesn't like getting attribute sets with
                    // null keys or values so we strip them here.
                    Map.Entry e = (Map.Entry)it.next();
                    Object key = e.getKey();
                    if (key == null) continue;
                    Object value = e.getValue();
                    if (value == null) continue;
                    destMap.put(key, value);
                }
                // System.out.println("Run: " + (index-start) + "->" +
                //                    (extent-start) + " of " + numChars);
                as.addAttributes (destMap, index-start, extent-start);
                index = extent;
            }
        }

        // We Just want it to do BIDI for us...
        // In 1.4 we might be able to use the BIDI class...
        TextLayout tl = new TextLayout(as.getIterator(), frc);

        int[] charIndices = new int[numChars];
        int[] charLevels  = new int[numChars];

        int runStart   = 0;
        int currBiDi   = tl.getCharacterLevel(0);
        charIndices[0] = 0;
        charLevels [0] = currBiDi;
        int maxBiDi    = currBiDi;

        for (int i = 1; i < numChars; i++) {
            int newBiDi = tl.getCharacterLevel(i);
            charIndices[i] = i;
            charLevels [i] = newBiDi;

            if (newBiDi != currBiDi) {
                as.addAttribute
                    (GVTAttributedCharacterIterator.TextAttribute.BIDI_LEVEL,
                     new Integer(currBiDi), runStart, i);
                runStart = i;
                currBiDi  = newBiDi;
                if (newBiDi > maxBiDi) maxBiDi = newBiDi;
            }
        }
        as.addAttribute
            (GVTAttributedCharacterIterator.TextAttribute.BIDI_LEVEL,
             new Integer(currBiDi), runStart, numChars);

        aci = as.getIterator();

        if ((runStart == 0) && (currBiDi==0)) {
            // This avoids all the mucking about we need to do when
            // bidi is actually performed for cases where it
            // is not actually needed.
            this.reorderedACI = aci;
            newCharOrder = new int[numChars];
            for (int i=0; i<numChars; i++)
                newCharOrder[i] = chunkStart+i;
            return;
        }

        //  work out the new character order
        newCharOrder = doBidiReorder(charIndices, charLevels,
                                     numChars, maxBiDi);

        // construct the string in the new order
        StringBuffer reorderedString = new StringBuffer( numChars );
        int reorderedFirstChar = 0;
        for (int i = 0; i < numChars; i++) {
            int srcIdx = newCharOrder[i];
            char c = aci.setIndex(srcIdx);
            if (srcIdx == 0) reorderedFirstChar = i;

            // check for mirrored char
            int bidiLevel = tl.getCharacterLevel(srcIdx);
            if ((bidiLevel & 0x01) != 0) {
                // bidi level is odd so writing dir is right to left
                // So get the mirror version of the char if there
                // is one.
                c = (char)mirrorChar(c);
            }

            reorderedString.append(c);
        }

        // construct the reordered ACI
        AttributedString reorderedAS
            = new AttributedString(reorderedString.toString());
        Map [] attrs = new Map[numChars];
        int start=aci.getBeginIndex();
        int end  =aci.getEndIndex();
        int index = start;
        while (index < end) {
            aci.setIndex(index);
            Map attrMap = aci.getAttributes();
            int extent  = aci.getRunLimit();
            for (int i=index; i<extent; i++)
                attrs[i-start] = attrMap;
            index = extent;
        }

        runStart=0;
        Map prevAttrMap = attrs[newCharOrder[0]];
        for (int i = 1; i < numChars; i++) {
            Map attrMap = attrs[newCharOrder[i]];
            if (attrMap != prevAttrMap) {
                // Change in attrs set last run...
                reorderedAS.addAttributes(prevAttrMap, runStart, i);
                prevAttrMap = attrMap;
                runStart = i;
            }
        }
        reorderedAS.addAttributes(prevAttrMap, runStart, numChars);

        // transfer any position atttributes to the new first char
        aci.first();
        Float x = (Float) aci.getAttribute
            (GVTAttributedCharacterIterator.TextAttribute.X);
        if (x != null && !x.isNaN()) {
            reorderedAS.addAttribute
                (GVTAttributedCharacterIterator.TextAttribute.X,
                 FLOAT_NAN, reorderedFirstChar, reorderedFirstChar+1);
            reorderedAS.addAttribute
                (GVTAttributedCharacterIterator.TextAttribute.X, x, 0, 1);
        }

        Float y = (Float) aci.getAttribute
            (GVTAttributedCharacterIterator.TextAttribute.Y);
        if (y != null && !y.isNaN()) {
            reorderedAS.addAttribute
                (GVTAttributedCharacterIterator.TextAttribute.Y,
                 FLOAT_NAN, reorderedFirstChar, reorderedFirstChar+1);
            reorderedAS.addAttribute
                (GVTAttributedCharacterIterator.TextAttribute.Y, y, 0, 1);
        }


        Float dx = (Float) aci.getAttribute
            (GVTAttributedCharacterIterator.TextAttribute.DX);
        if (dx != null && !dx.isNaN()) {
            reorderedAS.addAttribute
                (GVTAttributedCharacterIterator.TextAttribute.DX,
                 FLOAT_NAN, reorderedFirstChar, reorderedFirstChar+1);
            reorderedAS.addAttribute
                (GVTAttributedCharacterIterator.TextAttribute.DX, dx, 0, 1);
        }
        Float dy = (Float) aci.getAttribute
            (GVTAttributedCharacterIterator.TextAttribute.DY);
        if (dy != null && !dy.isNaN()) {
            reorderedAS.addAttribute
                (GVTAttributedCharacterIterator.TextAttribute.DY,
                 FLOAT_NAN, reorderedFirstChar, reorderedFirstChar+1);
            reorderedAS.addAttribute
                (GVTAttributedCharacterIterator.TextAttribute.DY, dy, 0, 1);
        }

        // assign arabic form attributes to any arabic chars in the string
        reorderedAS = ArabicTextHandler.assignArabicForms(reorderedAS);

        // Shift the values to match the source text string...
        for (int i=0; i<newCharOrder.length; i++) {
            newCharOrder[i] += chunkStart;
        }
        reorderedACI = reorderedAS.getIterator();
    }

    // Returns an array that give the character index in the source ACI for
    // each character in this ACI.
    public int[] getCharMap() { return newCharOrder; }

    /**
     * Calculates the display order of the characters based on the specified
     * character levels. This method is recursive.
     *
     * @param charIndices An array contianing the original indices of each char.
     * @param charLevels An array containing the current levels of each char.
     * @param numChars The number of chars to reorder.
     *
     * @return An array contianing the reordered character indices.
     */
    private int[] doBidiReorder(int[] charIndices, int[] charLevels,
                                int numChars, int highestLevel) {
        if (highestLevel == 0) return charIndices;

        // find all groups of chars at the highest level and reverse
        // their order
        int currentIndex = 0;
        while (currentIndex < numChars) {

            // find the first char at the highest index
            while ((currentIndex < numChars) &&
                   (charLevels[currentIndex] < highestLevel)) {
                currentIndex++;
            }
            if (currentIndex == numChars) {
                // have reached the end of the string
                break;
            }
            int startIndex = currentIndex;

            currentIndex++;
            // now find the index where the run at the highestLevel end
            while ((currentIndex < numChars) &&
                   (charLevels[currentIndex] == highestLevel)) {
                currentIndex++;
            }
            int endIndex = currentIndex-1;

            // now reverse the chars between startIndex and endIndex

            // Calculate the middle of the swap region, we include
            // the middle char when region is an odd number of
            // chars wide so we properly decrement it's charLevel.
            int middle = ((endIndex-startIndex)>>1)+1;
            for (int i = 0; i<middle; i++) {
                int tmp = charIndices[startIndex+i];
                charIndices[startIndex+i] = charIndices[endIndex-i];
                charIndices[endIndex  -i] = tmp;

                charLevels [startIndex+i] = highestLevel-1;
                charLevels [endIndex  -i] = highestLevel-1;
            }
        }
        return doBidiReorder(charIndices, charLevels, numChars, highestLevel-1);
    }



    /**
     * Get the keys of all attributes defined on the iterator's text range.
     */
    public Set getAllAttributeKeys() {
        return reorderedACI.getAllAttributeKeys();
    }

    /**
     * Get the value of the named attribute for the current
     *     character.
     */
    public Object getAttribute(AttributedCharacterIterator.Attribute attribute) {
        return reorderedACI.getAttribute(attribute);
    }

    /**
     * Returns a map with the attributes defined on the current
     * character.
     */
    public Map getAttributes() {
        return reorderedACI.getAttributes();
    }

    /**
     * Get the index of the first character following the
     *     run with respect to all attributes containing the current
     *     character.
     */
    public int getRunLimit() {
        return reorderedACI.getRunLimit();
    }

    /**
     * Get the index of the first character following the
     *      run with respect to the given attribute containing the current
     *      character.
     */
    public int getRunLimit(AttributedCharacterIterator.Attribute attribute) {
        return reorderedACI.getRunLimit(attribute);
    }

    /**
     * Get the index of the first character following the
     *     run with respect to the given attributes containing the current
     *     character.
     */
    public int getRunLimit(Set attributes) {
        return reorderedACI.getRunLimit(attributes);
    }

    /**
     * Get the index of the first character of the run with
     *    respect to all attributes containing the current character.
     */
    public int getRunStart() {
        return reorderedACI.getRunStart();
    }

    /**
     * Get the index of the first character of the run with
     *      respect to the given attribute containing the current character.
     * @param attribute The attribute for whose appearance the first offset
     *      is requested.
     */
    public int getRunStart(AttributedCharacterIterator.Attribute attribute) {
        return reorderedACI.getRunStart(attribute);
    }

    /**
     * Get the index of the first character of the run with
     *      respect to the given attributes containing the current character.
     * @param attributes the Set of attributes which begins at the returned index.
     */
    public int getRunStart(Set attributes) {
        return reorderedACI.getRunStart(attributes);
    }

    /**
     * Creates a copy of this iterator.
     */
    public Object clone() {
        return new BidiAttributedCharacterIterator
            ((AttributedCharacterIterator)reorderedACI.clone(),
             frc, chunkStart, (int [])newCharOrder.clone());
    }

    /**
     * Gets the character at the current position (as returned by getIndex()).
     */
    public char current() {
        return reorderedACI.current();
    }

    /**
     * Sets the position to getBeginIndex() and returns the character at
     * that position.
     */
    public char first() {
        return reorderedACI.first();
    }

    /**
     * Returns the start index of the text.
     */
    public int getBeginIndex() {
        return reorderedACI.getBeginIndex();
    }

    /**
     * Returns the end index of the text.
     */
    public int getEndIndex() {
        return reorderedACI.getEndIndex();
    }

    /**
     * Returns the current index.
     */
    public int getIndex() {
        return reorderedACI.getIndex();
    }

    /**
     * Sets the position to getEndIndex()-1 (getEndIndex() if the text is empty)
     * and returns the character at that position.
     */
    public char last() {
        return reorderedACI.last();
    }

    /**
     * Increments the iterator's index by one and returns the character at
     * the new index.
     */
    public char next() {
        return reorderedACI.next();
    }

    /**
     * Decrements the iterator's index by one and returns the character at the new index.
     */
    public char previous() {
        return reorderedACI.previous();
    }

    /**
     * Sets the position to the specified position in the text and returns that character.
     */
    public char setIndex(int position) {
       return reorderedACI.setIndex(position);
    }

    /**
     * @param c the character to 'mirror'
     * @return either the 'mirror'-character for c or c itself
     */
    public static int mirrorChar(int c) {

        // note: the switch-statement is compiled to a tableswitch,
        // which is evaluated by doing a binary search through the sorted case-list.
        // the ca 130 cases are searched with max 8 compares

        switch(c) {
            // set up the mirrored glyph case statement;
        case 0x0028: return 0x0029;  //LEFT PARENTHESIS
        case 0x0029: return 0x0028;  //RIGHT PARENTHESIS
        case 0x003C: return 0x003E;  //LESS-THAN SIGN
        case 0x003E: return 0x003C;  //GREATER-THAN SIGN
        case 0x005B: return 0x005D;  //LEFT SQUARE BRACKET
        case 0x005D: return 0x005B;  //RIGHT SQUARE BRACKET
        case 0x007B: return 0x007D;  //LEFT CURLY BRACKET
        case 0x007D: return 0x007B;  //RIGHT CURLY BRACKET
        case 0x00AB: return 0x00BB;  //LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
        case 0x00BB: return 0x00AB;  //RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
        case 0x2039: return 0x203A;  //SINGLE LEFT-POINTING ANGLE QUOTATION MARK
        case 0x203A: return 0x2039;  //SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
        case 0x2045: return 0x2046;  //LEFT SQUARE BRACKET WITH QUILL
        case 0x2046: return 0x2045;  //RIGHT SQUARE BRACKET WITH QUILL
        case 0x207D: return 0x207E;  //SUPERSCRIPT LEFT PARENTHESIS
        case 0x207E: return 0x207D;  //SUPERSCRIPT RIGHT PARENTHESIS
        case 0x208D: return 0x208E;  //SUBSCRIPT LEFT PARENTHESIS
        case 0x208E: return 0x208D;  //SUBSCRIPT RIGHT PARENTHESIS
        case 0x2208: return 0x220B;  //ELEMENT OF
        case 0x2209: return 0x220C;  //NOT AN ELEMENT OF
        case 0x220A: return 0x220D;  //SMALL ELEMENT OF
        case 0x220B: return 0x2208;  //CONTAINS AS MEMBER
        case 0x220C: return 0x2209;  //DOES NOT CONTAIN AS MEMBER
        case 0x220D: return 0x220A;  //SMALL CONTAINS AS MEMBER
        case 0x223C: return 0x223D;  //TILDE OPERATOR
        case 0x223D: return 0x223C;  //REVERSED TILDE
        case 0x2243: return 0x22CD;  //ASYMPTOTICALLY EQUAL TO
        case 0x2252: return 0x2253;  //APPROXIMATELY EQUAL TO OR THE IMAGE OF
        case 0x2253: return 0x2252;  //IMAGE OF OR APPROXIMATELY EQUAL TO
        case 0x2254: return 0x2255;  //COLON EQUALS
        case 0x2255: return 0x2254;  //EQUALS COLON
        case 0x2264: return 0x2265;  //LESS-THAN OR EQUAL TO
        case 0x2265: return 0x2264;  //GREATER-THAN OR EQUAL TO
        case 0x2266: return 0x2267;  //LESS-THAN OVER EQUAL TO
        case 0x2267: return 0x2266;  //GREATER-THAN OVER EQUAL TO
        case 0x2268: return 0x2269;  //[BEST FIT] LESS-THAN BUT NOT EQUAL TO
        case 0x2269: return 0x2268;  //[BEST FIT] GREATER-THAN BUT NOT EQUAL TO
        case 0x226A: return 0x226B;  //MUCH LESS-THAN
        case 0x226B: return 0x226A;  //MUCH GREATER-THAN
        case 0x226E: return 0x226F;  //[BEST FIT] NOT LESS-THAN
        case 0x226F: return 0x226E;  //[BEST FIT] NOT GREATER-THAN
        case 0x2270: return 0x2271;  //[BEST FIT] NEITHER LESS-THAN NOR EQUAL TO
        case 0x2271: return 0x2270;  //[BEST FIT] NEITHER GREATER-THAN NOR EQUAL TO
        case 0x2272: return 0x2273;  //[BEST FIT] LESS-THAN OR EQUIVALENT TO
        case 0x2273: return 0x2272;  //[BEST FIT] GREATER-THAN OR EQUIVALENT TO
        case 0x2274: return 0x2275;  //[BEST FIT] NEITHER LESS-THAN NOR EQUIVALENT TO
        case 0x2275: return 0x2274;  //[BEST FIT] NEITHER GREATER-THAN NOR EQUIVALENT TO
        case 0x2276: return 0x2277;  //LESS-THAN OR GREATER-THAN
        case 0x2277: return 0x2276;  //GREATER-THAN OR LESS-THAN
        case 0x2278: return 0x2279;  //NEITHER LESS-THAN NOR GREATER-THAN
        case 0x2279: return 0x2278;  //NEITHER GREATER-THAN NOR LESS-THAN
        case 0x227A: return 0x227B;  //PRECEDES
        case 0x227B: return 0x227A;  //SUCCEEDS
        case 0x227C: return 0x227D;  //PRECEDES OR EQUAL TO
        case 0x227D: return 0x227C;  //SUCCEEDS OR EQUAL TO
        case 0x227E: return 0x227F;  //[BEST FIT] PRECEDES OR EQUIVALENT TO
        case 0x227F: return 0x227E;  //[BEST FIT] SUCCEEDS OR EQUIVALENT TO
        case 0x2280: return 0x2281;  //[BEST FIT] DOES NOT PRECEDE
        case 0x2281: return 0x2280;  //[BEST FIT] DOES NOT SUCCEED
        case 0x2282: return 0x2283;  //SUBSET OF
        case 0x2283: return 0x2282;  //SUPERSET OF
        case 0x2284: return 0x2285;  //[BEST FIT] NOT A SUBSET OF
        case 0x2285: return 0x2284;  //[BEST FIT] NOT A SUPERSET OF
        case 0x2286: return 0x2287;  //SUBSET OF OR EQUAL TO
        case 0x2287: return 0x2286;  //SUPERSET OF OR EQUAL TO
        case 0x2288: return 0x2289;  //[BEST FIT] NEITHER A SUBSET OF NOR EQUAL TO
        case 0x2289: return 0x2288;  //[BEST FIT] NEITHER A SUPERSET OF NOR EQUAL TO
        case 0x228A: return 0x228B;  //[BEST FIT] SUBSET OF WITH NOT EQUAL TO
        case 0x228B: return 0x228A;  //[BEST FIT] SUPERSET OF WITH NOT EQUAL TO
        case 0x228F: return 0x2290;  //SQUARE IMAGE OF
        case 0x2290: return 0x228F;  //SQUARE ORIGINAL OF
        case 0x2291: return 0x2292;  //SQUARE IMAGE OF OR EQUAL TO
        case 0x2292: return 0x2291;  //SQUARE ORIGINAL OF OR EQUAL TO
        case 0x22A2: return 0x22A3;  //RIGHT TACK
        case 0x22A3: return 0x22A2;  //LEFT TACK
        case 0x22B0: return 0x22B1;  //PRECEDES UNDER RELATION
        case 0x22B1: return 0x22B0;  //SUCCEEDS UNDER RELATION
        case 0x22B2: return 0x22B3;  //NORMAL SUBGROUP OF
        case 0x22B3: return 0x22B2;  //CONTAINS AS NORMAL SUBGROUP
        case 0x22B4: return 0x22B5;  //NORMAL SUBGROUP OF OR EQUAL TO
        case 0x22B5: return 0x22B4;  //CONTAINS AS NORMAL SUBGROUP OR EQUAL TO
        case 0x22B6: return 0x22B7;  //ORIGINAL OF
        case 0x22B7: return 0x22B6;  //IMAGE OF
        case 0x22C9: return 0x22CA;  //LEFT NORMAL FACTOR SEMIDIRECT PRODUCT
        case 0x22CA: return 0x22C9;  //RIGHT NORMAL FACTOR SEMIDIRECT PRODUCT
        case 0x22CB: return 0x22CC;  //LEFT SEMIDIRECT PRODUCT
        case 0x22CC: return 0x22CB;  //RIGHT SEMIDIRECT PRODUCT
        case 0x22CD: return 0x2243;  //REVERSED TILDE EQUALS
        case 0x22D0: return 0x22D1;  //DOUBLE SUBSET
        case 0x22D1: return 0x22D0;  //DOUBLE SUPERSET
        case 0x22D6: return 0x22D7;  //LESS-THAN WITH DOT
        case 0x22D7: return 0x22D6;  //GREATER-THAN WITH DOT
        case 0x22D8: return 0x22D9;  //VERY MUCH LESS-THAN
        case 0x22D9: return 0x22D8;  //VERY MUCH GREATER-THAN
        case 0x22DA: return 0x22DB;  //LESS-THAN EQUAL TO OR GREATER-THAN
        case 0x22DB: return 0x22DA;  //GREATER-THAN EQUAL TO OR LESS-THAN
        case 0x22DC: return 0x22DD;  //EQUAL TO OR LESS-THAN
        case 0x22DD: return 0x22DC;  //EQUAL TO OR GREATER-THAN
        case 0x22DE: return 0x22DF;  //EQUAL TO OR PRECEDES
        case 0x22DF: return 0x22DE;  //EQUAL TO OR SUCCEEDS
        case 0x22E0: return 0x22E1;  //[BEST FIT] DOES NOT PRECEDE OR EQUAL
        case 0x22E1: return 0x22E0;  //[BEST FIT] DOES NOT SUCCEED OR EQUAL
        case 0x22E2: return 0x22E3;  //[BEST FIT] NOT SQUARE IMAGE OF OR EQUAL TO
        case 0x22E3: return 0x22E2;  //[BEST FIT] NOT SQUARE ORIGINAL OF OR EQUAL TO
        case 0x22E4: return 0x22E5;  //[BEST FIT] SQUARE IMAGE OF OR NOT EQUAL TO
        case 0x22E5: return 0x22E4;  //[BEST FIT] SQUARE ORIGINAL OF OR NOT EQUAL TO
        case 0x22E6: return 0x22E7;  //[BEST FIT] LESS-THAN BUT NOT EQUIVALENT TO
        case 0x22E7: return 0x22E6;  //[BEST FIT] GREATER-THAN BUT NOT EQUIVALENT TO
        case 0x22E8: return 0x22E9;  //[BEST FIT] PRECEDES BUT NOT EQUIVALENT TO
        case 0x22E9: return 0x22E8;  //[BEST FIT] SUCCEEDS BUT NOT EQUIVALENT TO
        case 0x22EA: return 0x22EB;  //[BEST FIT] NOT NORMAL SUBGROUP OF
        case 0x22EB: return 0x22EA;  //[BEST FIT] DOES NOT CONTAIN AS NORMAL SUBGROUP
        case 0x22EC: return 0x22ED;  //[BEST FIT] NOT NORMAL SUBGROUP OF OR EQUAL TO
        case 0x22ED: return 0x22EC;  //[BEST FIT] DOES NOT CONTAIN AS NORMAL SUBGROUP OR EQUAL
        case 0x22F0: return 0x22F1;  //UP RIGHT DIAGONAL ELLIPSIS
        case 0x22F1: return 0x22F0;  //DOWN RIGHT DIAGONAL ELLIPSIS
        case 0x2308: return 0x2309;  //LEFT CEILING
        case 0x2309: return 0x2308;  //RIGHT CEILING
        case 0x230A: return 0x230B;  //LEFT FLOOR
        case 0x230B: return 0x230A;  //RIGHT FLOOR
        case 0x2329: return 0x232A;  //LEFT-POINTING ANGLE BRACKET
        case 0x232A: return 0x2329;  //RIGHT-POINTING ANGLE BRACKET
        case 0x3008: return 0x3009;  //LEFT ANGLE BRACKET
        case 0x3009: return 0x3008;  //RIGHT ANGLE BRACKET
        case 0x300A: return 0x300B;  //LEFT DOUBLE ANGLE BRACKET
        case 0x300B: return 0x300A;  //RIGHT DOUBLE ANGLE BRACKET
        case 0x300C: return 0x300D;  //[BEST FIT] LEFT CORNER BRACKET
        case 0x300D: return 0x300C;  //[BEST FIT] RIGHT CORNER BRACKET
        case 0x300E: return 0x300F;  //[BEST FIT] LEFT WHITE CORNER BRACKET
        case 0x300F: return 0x300E;  //[BEST FIT] RIGHT WHITE CORNER BRACKET
        case 0x3010: return 0x3011;  //LEFT BLACK LENTICULAR BRACKET
        case 0x3011: return 0x3010;  //RIGHT BLACK LENTICULAR BRACKET
        case 0x3014: return 0x3015;  //[BEST FIT] LEFT TORTOISE SHELL BRACKET
        case 0x3015: return 0x3014;  //[BEST FIT] RIGHT TORTOISE SHELL BRACKET
        case 0x3016: return 0x3017;  //LEFT WHITE LENTICULAR BRACKET
        case 0x3017: return 0x3016;  //RIGHT WHITE LENTICULAR BRACKET
        case 0x3018: return 0x3019;  //LEFT WHITE TORTOISE SHELL BRACKET
        case 0x3019: return 0x3018;  //RIGHT WHITE TORTOISE SHELL BRACKET
        case 0x301A: return 0x301B;  //LEFT WHITE SQUARE BRACKET
        case 0x301B: return 0x301A;  //RIGHT WHITE SQUARE BRACKET
        default: break;
        }
        return  c;
    }
}
