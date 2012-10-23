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

import java.text.AttributedCharacterIterator;
import java.text.AttributedString;
import java.util.Map;
import java.util.Set;

/**
 * GVTAttributedCharacterIterator
 *
 * Used to implement SVG &lt;tspan&gt; and &lt;text&gt;
 * attributes.  This implementation is designed for efficient support
 * of per-character attributes (i.e. single character attribute spans).
 * It supports an extended set of TextAttributes, via inner class
 * SVGAttributedCharacterIterator.TextAttributes.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: GVTAttributedCharacterIterator.java 489226 2006-12-21 00:05:36Z cam $
 */

public interface GVTAttributedCharacterIterator extends AttributedCharacterIterator {

    /**
     * Sets this iterator's contents to an unattributed copy of String s.
     */
    void setString(String s);

    /**
     * Assigns this iterator's contents to be equivalent to AttributedString s.
     */
    void setString(AttributedString s);

    /**
     * Sets values of a per-character attribute associated with the content
     *     string.
     * Characters from <tt>beginIndex</tt> to <tt>endIndex</tt>
     *     (zero-offset) are assigned values for attribute key <tt>attr</tt>
     *     from the array <tt>attValues.</tt>
     * If the length of attValues is less than character span
     *     <tt>(endIndex-beginIndex)</tt> the last value is duplicated;
     *     if attValues is longer than the character span
     *     the extra values are ignored.
     * Note that if either beginIndex or endIndex are outside the bounds
     *     of the current character array they are clipped accordingly.
     */
    void setAttributeArray(TextAttribute attr,
                        Object[] attValues, int beginIndex, int endIndex);

    //From java.text.AttributedCharacterIterator

    /**
     * Get the keys of all attributes defined on the iterator's text range.
     */
    Set getAllAttributeKeys();

    /**
     * Get the value of the named attribute for the current
     *     character.
     */
    Object getAttribute(AttributedCharacterIterator.Attribute attribute);

    /**
     * Returns a map with the attributes defined on the current
     * character.
     */
    Map getAttributes();

    /**
     * Get the index of the first character following the
     *     run with respect to all attributes containing the current
     *     character.
     */
    int getRunLimit();

    /**
     * Get the index of the first character following the
     *      run with respect to the given attribute containing the current
     *      character.
     */
    int getRunLimit(AttributedCharacterIterator.Attribute attribute);

    /**
     * Get the index of the first character following the
     *     run with respect to the given attributes containing the current
     *     character.
     */
    int getRunLimit(Set attributes);

    /**
     * Get the index of the first character of the run with
     *    respect to all attributes containing the current character.
     */
    int getRunStart();

    /**
     * Get the index of the first character of the run with
     *      respect to the given attribute containing the current character.
     * @param attribute The attribute for whose appearance the first offset
     *      is requested.
     */
    int getRunStart(AttributedCharacterIterator.Attribute attribute);

    /**
     * Get the index of the first character of the run with
     *      respect to the given attributes containing the current character.
     * @param attributes the Set of attributes which begins at the returned index.
     */
    int getRunStart(Set attributes);

    //From CharacterIterator

    /**
     * Create a copy of this iterator
     */
    Object clone();

    /**
     * Get the character at the current position (as returned
     *      by getIndex()).
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    char current();

    /**
     * Sets the position to getBeginIndex().
     * @return the character at the start index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    char first();

    /**
     * Get the start index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    int getBeginIndex();

    /**
     * Get the end index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    int getEndIndex();

    /**
     * Get the current index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    int getIndex();

    /**
     * Sets the position to getEndIndex()-1 (getEndIndex() if
     * the text is empty) and returns the character at that position.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    char last();

    /**
     * Increments the iterator's index by one, returning the next character.
     * @return the character at the new index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    char next();

    /**
     * Decrements the iterator's index by one and returns
     * the character at the new index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    char previous();

    /**
     * Sets the position to the specified position in the text.
     * @param position The new (current) index into the text.
     * @return the character at new index <em>position</em>.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    char setIndex(int position);

    //Inner classes:

    /**
     * Attribute keys that identify SVG text attributes.  Anchor point for
     * attribute values of X, Y, and ROTATION is determined by the character's
     * font and other attributes.
     * We duplicate the features of java.awt.font.TextAttribute rather than
     * subclassing because java.awt.font.TextAttribute is <em>final</em>.
     */
    class TextAttribute extends AttributedCharacterIterator.Attribute {

        /** Construct a TextAttribute key with name s */
        public TextAttribute(String s) {
            super(s);
        }

        public static final TextAttribute FLOW_PARAGRAPH =
            new TextAttribute("FLOW_PARAGRAPH");

        public static final TextAttribute FLOW_EMPTY_PARAGRAPH =
            new TextAttribute("FLOW_EMPTY_PARAGRAPH");

        public static final TextAttribute FLOW_LINE_BREAK =
            new TextAttribute("FLOW_LINE_BREAK");

        public static final TextAttribute FLOW_REGIONS =
            new TextAttribute("FLOW_REGIONS");

        public static final TextAttribute LINE_HEIGHT =
            new TextAttribute("LINE_HEIGHT");

        public static final TextAttribute PREFORMATTED =
            new TextAttribute("PREFORMATTED");

        /** Attribute span delimiter - new tspan, tref, or textelement.*/
        public static final TextAttribute TEXT_COMPOUND_DELIMITER =
                              new TextAttribute("TEXT_COMPOUND_DELIMITER");

        /** Element identifier all chars from same element will share an
         *  ID. */
        public static final TextAttribute TEXT_COMPOUND_ID =
                              new TextAttribute("TEXT_COMPOUND_ID");

        /** Anchor type.*/
        public static final TextAttribute ANCHOR_TYPE =
                              new TextAttribute("ANCHOR_TYPE");

        /** Marker attribute indicating explicit glyph layout.*/
        public static final TextAttribute EXPLICIT_LAYOUT =
                              new TextAttribute("EXPLICIT_LAYOUT");

        /** User-space X coordinate for character.*/
        public static final TextAttribute X = new TextAttribute("X");

        /** User-space Y coordinate for character.*/
        public static final TextAttribute Y = new TextAttribute("Y");

        /** User-space relative X coordinate for character.*/
        public static final TextAttribute DX = new TextAttribute("DX");

        /** User-space relative Y coordinate for character.*/
        public static final TextAttribute DY = new TextAttribute("DY");

        /** Rotation for character, in degrees.*/
        public static final TextAttribute ROTATION =
                                          new TextAttribute("ROTATION");

        /** All the paint attributes for the text.*/
        public static final TextAttribute PAINT_INFO =
                                          new TextAttribute("PAINT_INFO");

        /** Author-expected width for bounding box containing
         *  all text string glyphs.
         */
        public static final TextAttribute BBOX_WIDTH =
                                          new TextAttribute("BBOX_WIDTH");

        /** Method specified for adjusting text element layout size.
         */
        public static final TextAttribute LENGTH_ADJUST =
                                          new TextAttribute("LENGTH_ADJUST");

        /** Convenience flag indicating that non-default glyph spacing is needed.
         */
        public static final TextAttribute CUSTOM_SPACING =
                                          new TextAttribute("CUSTOM_SPACING");

        /** User-specified inter-glyph kerning value.
         */
        public static final TextAttribute KERNING =
                                          new TextAttribute("KERNING");

        /** User-specified inter-glyph spacing value.
         */
        public static final TextAttribute LETTER_SPACING =
                                          new TextAttribute("LETTER_SPACING");

        /** User-specified width for whitespace characters.
         */
        public static final TextAttribute WORD_SPACING =
                                          new TextAttribute("WORD_SPACING");

        /** Path along which text is to be laid out */
        public static final TextAttribute TEXTPATH =
                                          new TextAttribute("TEXTPATH");

        /** Font variant to be used for this character span.
         * @see org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator.TextAttribute#SMALL_CAPS
         */
        public static final TextAttribute FONT_VARIANT =
                                          new TextAttribute("FONT_VARIANT");

        /** Baseline adjustment to be applied to this character span.
         */
        public static final TextAttribute BASELINE_SHIFT =
                                          new TextAttribute("BASELINE_SHIFT");

        /** Directional writing mode applied to this character span.
         */
        public static final TextAttribute WRITING_MODE =
                                          new TextAttribute("WRITING_MODE");

        public static final TextAttribute VERTICAL_ORIENTATION =
                                          new TextAttribute("VERTICAL_ORIENTATION");

        public static final TextAttribute VERTICAL_ORIENTATION_ANGLE =
                                          new TextAttribute("VERTICAL_ORIENTATION_ANGLE");

        public static final TextAttribute HORIZONTAL_ORIENTATION_ANGLE =
                                          new TextAttribute("HORIZONTAL_ORIENTATION_ANGLE");

        public static final TextAttribute GVT_FONT_FAMILIES =
                       new TextAttribute("GVT_FONT_FAMILIES");

        public static final TextAttribute GVT_FONTS =
                                          new TextAttribute("GVT_FONTS");

        public static final TextAttribute GVT_FONT =
                                          new TextAttribute("GVT_FONT");

        public static final TextAttribute ALT_GLYPH_HANDLER =
                                          new TextAttribute("ALT_GLYPH_HANDLER");

        public static final TextAttribute BIDI_LEVEL =
                                          new TextAttribute("BIDI_LEVEL");

        public static final TextAttribute CHAR_INDEX =
                                          new TextAttribute("CHAR_INDEX");

        public static final TextAttribute ARABIC_FORM =
                                          new TextAttribute("ARABIC_FORM");

        // VALUES

        /** Value for WRITING_MODE indicating left-to-right */
        public static final Integer WRITING_MODE_LTR = new Integer(0x1);

        /** Value for WRITING_MODE indicating right-to-left */
        public static final Integer WRITING_MODE_RTL = new Integer(0x2);

        /** Value for WRITING_MODE indicating top-to-botton */
        public static final Integer WRITING_MODE_TTB = new Integer(0x3);

        /** Value for VERTICAL_ORIENTATION indicating an angle */
        public static final Integer ORIENTATION_ANGLE = new Integer(0x1);

        /** Value for VERTICAL_ORIENTATION indicating auto */
        public static final Integer ORIENTATION_AUTO = new Integer(0x2);

        /** Value for FONT_VARIANT specifying small caps */
        public static final Integer SMALL_CAPS = new Integer(0x10);

        /** Value for UNDERLINE specifying underlining-on */
        public static final Integer UNDERLINE_ON =
                            java.awt.font.TextAttribute.UNDERLINE_ON;

        /** Value for OVERLINE specifying overlining-on */
        public static final Boolean OVERLINE_ON = Boolean.TRUE;

        /** Value for STRIKETHROUGH specifying strikethrough-on */
        public static final Boolean STRIKETHROUGH_ON =
                            java.awt.font.TextAttribute.STRIKETHROUGH_ON;

        /** Value for LENGTH_ADJUST specifying adjustment to inter-glyph spacing */
        public static final Integer ADJUST_SPACING =
                            new Integer(0x0);

        /** Value for LENGTH_ADJUST specifying overall scaling of layout outlines */
        public static final Integer ADJUST_ALL =
                            new Integer(0x01);

        // constant values for the arabic glyph forms
        public static final Integer ARABIC_NONE = new Integer(0x0);
        public static final Integer ARABIC_ISOLATED = new Integer(0x1);
        public static final Integer ARABIC_TERMINAL = new Integer(0x2);
        public static final Integer ARABIC_INITIAL = new Integer(0x3);
        public static final Integer ARABIC_MEDIAL = new Integer(0x4);

    }

    /**
     * Interface for helper class which mutates the attributes of an
     * AttributedCharacterIterator.
     * Typically used to convert location and rotation attributes to
     * TextAttribute.TRANSFORM attributes, or convert between implementations
     * of AttributedCharacterIterator.Attribute.
     */
    interface AttributeFilter {

        /**
         * Modify an AttributedCharacterIterator's attributes systematically.
         * Usually returns a copy since AttributedCharacterIterator instances
         * are often immutable.  The effect of the attribute modification
         * is implementation dependent.
         * @param aci an AttributedCharacterIterator whose attributes are
         *     to be modified.
         * @return an instance of AttributedCharacterIterator with mutated
         *     attributes.
         */
        AttributedCharacterIterator
            mutateAttributes(AttributedCharacterIterator aci);

    }
}









