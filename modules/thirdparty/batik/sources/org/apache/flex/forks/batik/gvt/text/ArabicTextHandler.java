/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.gvt.text;

import java.text.AttributedCharacterIterator;
import java.text.AttributedString;
import java.util.HashMap;
import java.util.Map;


/**
 * Handles the processing of arabic text. In particular it determines the
 * form each arabic char should take. It also contains methods for substituting
 * plain arabic glyphs with their shaped forms. This is needed when the arabic
 * text is rendered using an AWT font.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: ArabicTextHandler.java,v 1.8 2005/03/27 08:58:35 cam Exp $
 */
public class ArabicTextHandler {

    private final static int arabicStart = 0x0600;
    private final static int arabicEnd = 0x06FF;

    private final static Map charMap = new HashMap(54);

    /**
     * If the AttributedString contains any arabic chars, assigns an
     * arabic form attribute, i&#x2e;e&#x2e; initial|medial|terminal|isolated,
     * to each arabic char.
     *
     * @param as The string to attach the arabic form attributes to.
     * @return An attributed string with arabic form attributes.  
     */
    public static AttributedString assignArabicForms(AttributedString as) {

        // first check to see if the string contains any arabic chars
        // if not, then don't need to do anything
        if (!containsArabic(as)) {
            return as;
        }

        // if the string contains any ligatures with transparent chars
        // eg. AtB where AB form a ligature and t is transparent, then
        // reorder that part of the string so that it becomes tAB
        // construct the reordered ACI
        AttributedCharacterIterator aci = as.getIterator();
        boolean didSomeReordering = false;
        int numChars = aci.getEndIndex() - aci.getBeginIndex();
        int charOrder[] = new int[numChars];
        for (int i = 0; i < numChars; i++) {
            charOrder[i] = i + aci.getBeginIndex();
        }
        for (int i = 1; i < numChars-1; i++) {
            char c = aci.setIndex(aci.getBeginIndex() + i);
            if (arabicCharTransparent(c)) {
                char prevChar = aci.setIndex(aci.getBeginIndex() + i-1);
                char nextChar = aci.setIndex(aci.getBeginIndex() + i+1);
                if (charMap.get("" + prevChar + nextChar) != null) {
                    // found a ligature, separated by a transparent char
                    didSomeReordering = true;
                    int temp = charOrder[i];
                    charOrder[i] = charOrder[i-1];
                    charOrder[i-1] = temp;
                }
            }
        }
        if (didSomeReordering) {
            // need to reconstruct the reordered attributed string
            String reorderedString = "";
            char c;
            for (int i = 0; i < numChars; i++) {
                c = aci.setIndex(charOrder[i]);
                reorderedString += c;
            }
            AttributedString reorderedAS = new AttributedString(reorderedString);
            for (int i = 0; i < numChars; i++) {
                aci.setIndex(charOrder[i]);
                Map attributes = aci.getAttributes();
                reorderedAS.addAttributes(attributes, i, i+1);
            }
            if (charOrder[0] == (aci.getBeginIndex()+1) && charOrder[1] == aci.getBeginIndex()) {
                // have swapped the first 2 chars, may need to move any position attributes

                aci.first();
                Float x = (Float) aci.getAttribute(
                    GVTAttributedCharacterIterator.TextAttribute.X);
                Float y = (Float) aci.getAttribute(
                    GVTAttributedCharacterIterator.TextAttribute.Y);

                if (x != null && !x.isNaN()) {
                    reorderedAS.addAttribute(GVTAttributedCharacterIterator.TextAttribute.X,
                        new Float(Float.NaN), 1, 2);
                    reorderedAS.addAttribute(GVTAttributedCharacterIterator.TextAttribute.X, x, 0, 1);
                }
                if (y != null && !y.isNaN()) {
                    reorderedAS.addAttribute(GVTAttributedCharacterIterator.TextAttribute.Y,
                        new Float(Float.NaN), 1, 2);
                    reorderedAS.addAttribute(GVTAttributedCharacterIterator.TextAttribute.Y, y, 0, 1);
                }
            }
            as = reorderedAS;
        }


        // first assign none to all arabic letters
        int c;
        aci = as.getIterator();
        for (int i = aci.getBeginIndex(); i < aci.getEndIndex(); i++) {
            c = aci.setIndex(i);
            if (c >= arabicStart && c <= arabicEnd) {
                as.addAttribute(GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM,
                                GVTAttributedCharacterIterator.TextAttribute.ARABIC_NONE, i, i+1);
            }
        }
        aci.first();

        boolean moreRuns = true;
        // for each run of arabic chars, assign the appropriate form
        while (moreRuns) {
            int start = aci.getRunStart(
                    GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM);
            int end = aci.getRunLimit(
                    GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM);

            aci.setIndex(start);

            if (aci.getAttribute(GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM) != null) {

                // only modify if the chars in the run are arabic

                int currentIndex = start;
                while (currentIndex < end) {

                    char currentChar=  aci.setIndex(currentIndex);
                    char prevChar = currentChar;
                    int prevCharIndex = currentIndex-1;
                    if (currentIndex > start) {  // if not at the start
                        prevChar = aci.setIndex(prevCharIndex);
                    }

                    while (arabicCharTransparent(currentChar) && currentIndex < end) {
                        currentIndex++;
                        currentChar = aci.setIndex(currentIndex);
                    }
                    if (currentIndex >= end) {
                        break;
                    }

                    if (!arabicCharTransparent(currentChar)) { // if current char is not transparent

                        if (prevCharIndex >= start) {  // if not at the start

                            // if prev char right AND current char left
                            if (arabicCharShapesRight(prevChar)
                                && arabicCharShapesLeft(currentChar)) {

                                // then single increment the for of the previous char
                                aci.setIndex(prevCharIndex);
                                Integer prevForm = (Integer)aci.getAttribute(
                                    GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM);
                                prevForm = new Integer(prevForm.intValue()+1);

                                as.addAttribute(GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM,
                                                prevForm, prevCharIndex, prevCharIndex+1);

                                // and set the form of the current char to INITIAL
                                as.addAttribute(GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM,
                                                GVTAttributedCharacterIterator.TextAttribute.ARABIC_INITIAL,
                                                currentIndex, currentIndex+1);
                             }

                            // if not prev char right OR not current char left
                            // AND current char can be shaped
                            if ((!arabicCharShapesRight(prevChar) ||
                                 !arabicCharShapesLeft(currentChar))
                                 && arabicCharShaped(currentChar)) {

                                // set the form of the current char to ISOLATE
                                as.addAttribute(GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM,
                                                GVTAttributedCharacterIterator.TextAttribute.ARABIC_ISOLATED,
                                                currentIndex, currentIndex+1);
                            }

                        // if this is the first arabic char and its shaped, set to ISOLATE
                        } else if (arabicCharShaped(currentChar)) {
                            // set the form of the current char to ISOLATE
                            as.addAttribute(GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM,
                                            GVTAttributedCharacterIterator.TextAttribute.ARABIC_ISOLATED,
                                          currentIndex, currentIndex+1);
                        }
                    }
                    currentIndex++;
                }
            }
            if (aci.setIndex(end) == AttributedCharacterIterator.DONE) {
                moreRuns = false;
            }
        }
        return as;
    }

    /**
     * Returns true if the char is a standard arabic char.
     * (ie. within the range U+0600 - U+6FF)
     *
     * @param c The character to test.
     * @return True if the char is arabic, false otherwise.
     */
    public static boolean arabicChar(char c) {
        if (c >= arabicStart && c <= arabicEnd) {
            return true;
        }
        return false;
    }

    /**
     * Returns true if the string contains any arabic characters.
     *
     * @param as The string to test.
     * @return True if at least one char is arabic, false otherwise.
     */
    public static boolean containsArabic(AttributedString as) {
        return containsArabic(as.getIterator());
    }

    /**
     * Returns true if the ACI contains any arabic characters.
     *
     * @param aci The AttributedCharacterIterator to test.
     * @return True if at least one char is arabic, false otherwise.
     */
    public static boolean containsArabic(AttributedCharacterIterator aci) {
        char c;
        for (int i = aci.getBeginIndex(); i < aci.getEndIndex(); i++) {
            c = aci.setIndex(i);
            if (arabicChar(c)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns true if the char is transparent.
     *
     * @param c The character to test.
     * @return True if the character is transparent, false otherwise.
     */
    public static boolean arabicCharTransparent(char c) {
        int charVal = c;
        if ((charVal >= 0x64B && charVal <= 0x655)
            || (charVal == 0x0670)
            || (charVal >= 0x06D6 && charVal <= 0x06E4)
            || (charVal >= 0x06E7 && charVal <= 0x06E8)
            || (charVal >= 0x06EA && charVal <= 0x06ED)) {
            return true;
        }
        return false;
    }

    /**
     * Returns true if the character shapes to the right. Note that duel
     * shaping characters also shape to the right and so will return true.
     *
     * @param c The character to test.
     * @return True if the character shapes to the right, false otherwise.
     */
    private static boolean arabicCharShapesRight(char c) {
        int charVal = c;
        if ((charVal >= 0x622 && charVal <= 0x625)
         || (charVal == 0x627)
         || (charVal == 0x629)
         || (charVal >= 0x062F && charVal <= 0x0632)
         || (charVal == 0x0648)
         || (charVal >= 0x0671 && charVal <= 0x0673)
         || (charVal >= 0x0675 && charVal <= 0x0677)
         || (charVal >= 0x0688 && charVal <= 0x0699)
         || (charVal == 0x06C0)
         || (charVal >= 0x06C2 && charVal <= 0x06CB)
         || (charVal == 0x06CD)
         || (charVal == 0x06CF)
         || (charVal >= 0x06D2 && charVal <= 0x06D3)
         // check for duel shaping too
         || arabicCharShapesDuel(c)) {
            return true;
        }
        return false;
    }

    /**
     * Returns true if character has duel shaping.
     *
     * @param c The character to test.
     * @return True if the character is duel shaping, false otherwise.
     */
    private static boolean arabicCharShapesDuel(char c) {
        int charVal = c;

        if ((charVal == 0x626)
         || (charVal == 0x628)
         || (charVal >= 0x062A && charVal <= 0x062E)
         || (charVal >= 0x0633 && charVal <= 0x063A)
         || (charVal >= 0x0641 && charVal <= 0x0647)
         || (charVal >= 0x0649 && charVal <= 0x064A)
         || (charVal >= 0x0678 && charVal <= 0x0687)
         || (charVal >= 0x069A && charVal <= 0x06BF)
         || (charVal == 0x6C1)
         || (charVal == 0x6CC)
         || (charVal == 0x6CE)
         || (charVal >= 0x06D0 && charVal <= 0x06D1)
         || (charVal >= 0x06FA && charVal <= 0x06FC)) {
            return true;
        }
        return false;
    }

    /**
     * Returns true if character shapes to the left. Note that duel
     * shaping characters also shape to the left and so will return true.
     *
     * @param c The character to test.
     * @return True if the character shapes to the left, false otherwise.
     */
    private static boolean arabicCharShapesLeft(char c) {
        return arabicCharShapesDuel(c);
    }

    /**
     * Returns true if character is shaped.
     *
     * @param c The character to test.
     * @return True if the character is shaped, false otherwise.
     */
    private static boolean arabicCharShaped(char c) {
        return arabicCharShapesRight(c);
    }


    /**
     * Will try and find a substitute character of the specified form.
     *
     * @param unicode The unicode value of the glyph to try and replace. It
     * may be ligature and so may contain more than one character.
     * @param form Indicates the required arabic form.
     * (isolated = 1, final = 2, initial = 3, medial = 4)
     *
     * @return The unicode value of the substutute char, or -1 if no susbtitue
     * exists.
     */
    public static int getSubstituteChar(String unicode, int form) {
        if (charMap.containsKey(unicode) && form > 0) {
            int chars[] = (int[])charMap.get(unicode);
            if (chars[form-1] > 0) {
                return chars[form-1];
            }
        }
        return -1;
    }

    /**
     * Where possible substitues plain arabic glyphs with their shaped
     * forms.  This is needed when the arabic text is rendered using
     * an AWT font.  Simple arabic ligatures will also be recognised
     * and replaced by a single character so the length of the
     * resulting string may be shorter than the number of characters
     * in the aci.
     *
     * @param aci Contains the text to process. Arabic form attributes
     * should already be assigned to each arabic character.
     * @return A String containing the shaped versions of the arabic characters
     */
    public static String createSubstituteString(AttributedCharacterIterator aci) {

        String substString = "";
        for (int i = aci.getBeginIndex(); i < aci.getEndIndex(); i++) {
            char c = aci.setIndex(i);
            if (arabicChar(c)) {
                Integer form = (Integer)aci.getAttribute(
                    GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM);

                // see if the c is the start of a ligature
                if (charStartsLigature(c) && i < aci.getEndIndex()) {
                    char nextChar = aci.setIndex(i+1);
                    Integer nextForm = (Integer)aci.getAttribute(
                    GVTAttributedCharacterIterator.TextAttribute.ARABIC_FORM);
                    if (form != null && nextForm != null) {
                        if (form.equals(GVTAttributedCharacterIterator.TextAttribute.ARABIC_TERMINAL)
                            && nextForm.equals(GVTAttributedCharacterIterator.TextAttribute.ARABIC_INITIAL)) {
                            // look for an isolated ligature
                            int substChar = ArabicTextHandler.getSubstituteChar("" + c + nextChar,
                                GVTAttributedCharacterIterator.TextAttribute.ARABIC_ISOLATED.intValue());
                            if (substChar > -1) {
                                substString += (char)substChar;
                                i++;
                                continue;
                            }
                        } else if (form.equals(GVTAttributedCharacterIterator.TextAttribute.ARABIC_TERMINAL)) {
                            // look for a terminal ligature
                            int substChar = ArabicTextHandler.getSubstituteChar("" + c + nextChar,
                                GVTAttributedCharacterIterator.TextAttribute.ARABIC_TERMINAL.intValue());
                            if (substChar > -1) {
                                substString += (char)substChar;
                                i++;
                                continue;
                            }
                        } else if (form.equals(GVTAttributedCharacterIterator.TextAttribute.ARABIC_MEDIAL)
                                && nextForm.equals(GVTAttributedCharacterIterator.TextAttribute.ARABIC_MEDIAL)) {
                            // look for a medial ligature
                            int substChar = ArabicTextHandler.getSubstituteChar("" + c + nextChar,
                                GVTAttributedCharacterIterator.TextAttribute.ARABIC_MEDIAL.intValue());
                            if (substChar > -1) {
                                substString += (char)substChar;
                                i++;
                                continue;
                            }
                        }
                    }
                }

                // couln't find a matching ligature so  just look for a simple substitution
                if (form != null && form.intValue() > 0) {
                    int substChar = ArabicTextHandler.getSubstituteChar(""+c, form.intValue());
                    if (substChar > -1) {
                        substString += (char)substChar;
                    } else {
                        substString += c;
                    }
                } else {
                    substString += c;
                }
            } else {
                substString += c;
            }
        }
        return substString;
    }

    /**
     * Returns true if a ligature exists that starts with the
     * specified character.
     *
     * @param c The character to test.
     * @return True if there is a ligature that starts with c, false otherwise.
     */
    public static boolean charStartsLigature(char c) {
        int charVal = c;
        if (charVal == 0x064B || charVal == 0x064C || charVal == 0x064D
         || charVal == 0x064E || charVal == 0x064F || charVal == 0x0650
         || charVal == 0x0651 || charVal == 0x0652 || charVal == 0x0622
         || charVal == 0x0623 || charVal == 0x0625 || charVal == 0x0627) {
            return true;
        }
        return false;
    }

    /**
     * Returns the number of characters the glyph for the specified character
     * represents. If the glyph represents a ligature this will be 2, otherwise 1.
     *
     * @param c The character to test.
     * @return The number of characters the glyph for c represents.
     */
    public static int getNumChars(char c) {
        // if c is a ligature returns 2, else returns 1
        if (isLigature(c)) {
            // at the moment only support ligatures with two chars
            return 2;
        }
        return 1;
    }

    /**
     * Returns true if the glyph for the specified character respresents a ligature.
     *
     * @param c The character to test.
     * @return True if c is a ligature, false otherwise.
     */
    public static boolean isLigature(char c) {
        int charVal = c;
        if ((charVal >= 0xFE70 && charVal <= 0xFE72)
            || (charVal == 0xFE74)
            || (charVal >= 0xFE76 && charVal <= 0xFE7F)
            || (charVal >= 0xFEF5 && charVal <= 0xFEFC)) {
            return true;
        }
        return false;
    }


    static {

        // constructs the character map that maps arabic characters and
        // ligature to their various forms
        // NOTE: the unicode values for ligatures are stored here in
        // visual order (not logical order)

        int chars1[] = {0xFE70, -1, -1, -1};  //    isolated, final, initial, medial
        charMap.put(new String("" + (char)0x064B + (char)0x0020), chars1);

        int chars2[] = {-1, -1, -1, 0xFE71};
        charMap.put(new String("" + (char)0x064B + (char)0x0640), chars2);

        int chars3[] = {0xFE72, -1, -1, -1};
        charMap.put(new String("" + (char)0x064C + (char)0x0020), chars3);

        int chars4[] = {0xFE74, -1, -1, -1};
        charMap.put(new String("" + (char)0x064D + (char)0x0020), chars4);

        int chars5[] = {0xFE76, -1, -1, -1};
        charMap.put(new String("" + (char)0x064E + (char)0x0020), chars5);

        int chars6[] = {-1, -1, -1, 0xFE77};
        charMap.put(new String("" + (char)0x064E + (char)0x0640), chars6);

        int chars7[] = {0xFE78, -1, -1, -1};
        charMap.put(new String("" + (char)0x064F + (char)0x0020), chars7);

        int chars8[] = {-1, -1, -1, 0xFE79};
        charMap.put(new String("" + (char)0x064F + (char)0x0640), chars8);

        int chars9[] = {0xFE7A, -1, -1, -1};
        charMap.put(new String("" + (char)0x0650 + (char)0x0020), chars9);

        int chars10[] = {-1, -1, -1, 0xFE7B};
        charMap.put(new String("" + (char)0x0650 + (char)0x0640), chars10);

        int chars11[] = {0xFE7C, -1, -1, -1};
        charMap.put(new String("" + (char)0x0651 + (char)0x0020), chars11);

        int chars12[] = {-1, -1, -1, 0xFE7D};
        charMap.put(new String("" + (char)0x0651 + (char)0x0640), chars12);

        int chars13[] = {0xFE7E, -1, -1, -1};
        charMap.put(new String("" + (char)0x0652 + (char)0x0020), chars13);

        int chars14[] = {-1, -1, -1, 0xFE7F};
        charMap.put(new String("" + (char)0x0652 + (char)0x0640), chars14);

        int chars15[] = {0xFE80, -1, -1, -1};
        charMap.put(new String("" + (char)0x0621), chars15);

        int chars16[] = {0xFE81, 0xFE82, -1, -1};
        charMap.put(new String("" + (char)0x0622), chars16);

        int chars17[] = {0xFE83, 0xFE84, -1, -1};
        charMap.put(new String("" + (char)0x0623), chars17);

        int chars18[] = {0xFE85, 0xFE86, -1, -1};
        charMap.put(new String("" + (char)0x0624), chars18);

        int chars19[] = {0xFE87, 0xFE88, -1, -1};
        charMap.put(new String("" + (char)0x0625), chars19);

        int chars20[] = {0xFE89, 0xFE8A, 0xFE8B, 0xFE8C};
        charMap.put(new String("" + (char)0x0626), chars20);

        int chars21[] = {0xFE8D, 0xFE8E, -1, -1};
        charMap.put(new String("" + (char)0x0627), chars21);

        int chars22[] = {0xFE8F, 0xFE90, 0xFE91, 0xFE92};
        charMap.put(new String("" + (char)0x0628), chars22);

        int chars23[] = {0xFE93, 0xFE94, -1, -1};
        charMap.put(new String("" + (char)0x0629), chars23);

        int chars24[] = {0xFE95, 0xFE96, 0xFE97, 0xFE98};
        charMap.put(new String("" + (char)0x062A), chars24);

        int chars25[] = {0xFE99, 0xFE9A,  0xFE9B, 0xFE9C};
        charMap.put(new String("" + (char)0x062B), chars25);

        int chars26[] = {0xFE9D, 0xFE9E, 0xFE9F, 0xFEA0};
        charMap.put(new String("" + (char)0x062C), chars26);

        int chars27[] = {0xFEA1, 0xFEA2, 0xFEA3, 0xFEA4};
        charMap.put(new String("" + (char)0x062D), chars27);

        int chars28[] = {0xFEA5,  0xFEA6, 0xFEA7, 0xFEA8};
        charMap.put(new String("" + (char)0x062E), chars28);

        int chars29[] = {0xFEA9, 0xFEAA, -1, -1};
        charMap.put(new String("" + (char)0x062F), chars29);

        int chars30[] = {0xFEAB, 0xFEAC, -1, -1};
        charMap.put(new String("" + (char)0x0630), chars30);

        int chars31[] = {0xFEAD, 0xFEAE, -1, -1};
        charMap.put(new String("" + (char)0x0631), chars31);

        int chars32[] = {0xFEAF,  0xFEB0, -1, -1};
        charMap.put(new String("" + (char)0x0632), chars32);

        int chars33[] = {0xFEB1, 0xFEB2, 0xFEB3, 0xFEB4};
        charMap.put(new String("" + (char)0x0633), chars33);

        int chars34[] = {0xFEB5, 0xFEB6, 0xFEB7, 0xFEB8};
        charMap.put(new String("" + (char)0x0634), chars34);

        int chars35[] = {0xFEB9, 0xFEBA, 0xFEBB, 0xFEBC};
        charMap.put(new String("" + (char)0x0635), chars35);

        int chars36[] = {0xFEBD, 0xFEBE, 0xFEBF, 0xFEC0};
        charMap.put(new String("" + (char)0x0636), chars36);

        int chars37[] = {0xFEC1, 0xFEC2, 0xFEC3, 0xFEC4};
        charMap.put(new String("" + (char)0x0637), chars37);

        int chars38[] = {0xFEC5,  0xFEC6, 0xFEC7, 0xFEC8};
        charMap.put(new String("" + (char)0x0638), chars38);

        int chars39[] = {0xFEC9,  0xFECA, 0xFECB, 0xFECC};
        charMap.put(new String("" + (char)0x0639), chars39);

        int chars40[] = { 0xFECD,  0xFECE, 0xFECF,  0xFED0};
        charMap.put(new String("" + (char)0x063A), chars40);

        int chars41[] = {0xFED1, 0xFED2, 0xFED3, 0xFED4};
        charMap.put(new String("" + (char)0x0641), chars41);

        int chars42[] = {0xFED5, 0xFED6, 0xFED7, 0xFED8};
        charMap.put(new String("" + (char)0x0642), chars42);

        int chars43[] = {0xFED9, 0xFEDA,  0xFEDB, 0xFEDC};
        charMap.put(new String("" + (char)0x0643), chars43);

        int chars44[] = {0xFEDD, 0xFEDE, 0xFEDF, 0xFEE0};
        charMap.put(new String("" + (char)0x0644), chars44);

        int chars45[] = {0xFEE1, 0xFEE2, 0xFEE3, 0xFEE4};
        charMap.put(new String("" + (char)0x0645), chars45);

        int chars46[] = {0xFEE5, 0xFEE6, 0xFEE7, 0xFEE8};
        charMap.put(new String("" + (char)0x0646), chars46);

        int chars47[] = {0xFEE9, 0xFEEA, 0xFEEB, 0xFEEC};
        charMap.put(new String("" + (char)0x0647), chars47);

        int chars48[] = {0xFEED, 0xFEEE, -1, -1};
        charMap.put(new String("" + (char)0x0648), chars48);

        int chars49[] = {0xFEEF, 0xFEF0, -1, -1};
        charMap.put(new String("" + (char)0x0649), chars49);

        int chars50[] = {0xFEF1, 0xFEF2, 0xFEF3, 0xFEF4};
        charMap.put(new String("" + (char)0x064A), chars50);

         int chars51[] = {0xFEF5, 0xFEF6, -1, -1};
        charMap.put(new String("" + (char)0x0622 + (char)0x0644), chars51);

        int chars52[] = {0xFEF7, 0xFEF8, -1, -1};
        charMap.put(new String("" + (char)0x0623 + (char)0x0644), chars52);

        int chars53[] = {0xFEF9, 0xFEFA, -1, -1};
        charMap.put(new String("" + (char)0x0625 + (char)0x0644), chars53);

        int chars54[] = {0xFEFB,  0xFEFC, -1, -1};
        charMap.put(new String("" + (char)0x0627 + (char)0x0644), chars54);

    }


}
