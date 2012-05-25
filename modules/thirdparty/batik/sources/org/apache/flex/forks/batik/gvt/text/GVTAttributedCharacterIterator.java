/*

   Copyright 2000-2003  The Apache Software Foundation 

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
 * @version $Id: GVTAttributedCharacterIterator.java,v 1.25 2004/11/18 01:47:00 deweese Exp $
 */

public interface GVTAttributedCharacterIterator extends AttributedCharacterIterator {

    /**
     * Sets this iterator's contents to an unattributed copy of String s.
     */
    public void setString(String s);

    /**
     * Assigns this iterator's contents to be equivalent to AttributedString s.
     */
    public void setString(AttributedString s);

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
    public void setAttributeArray(TextAttribute attr,
                        Object[] attValues, int beginIndex, int endIndex);

    //From java.text.AttributedCharacterIterator

    /**
     * Get the keys of all attributes defined on the iterator's text range.
     */
    public Set getAllAttributeKeys();

    /**
     * Get the value of the named attribute for the current
     *     character.
     */
    public Object getAttribute(AttributedCharacterIterator.Attribute attribute);

    /**
     * Returns a map with the attributes defined on the current
     * character.
     */
    public Map getAttributes();

    /**
     * Get the index of the first character following the
     *     run with respect to all attributes containing the current
     *     character.
     */
    public int getRunLimit();

    /**
     * Get the index of the first character following the
     *      run with respect to the given attribute containing the current
     *      character.
     */
    public int getRunLimit(AttributedCharacterIterator.Attribute attribute);

    /**
     * Get the index of the first character following the
     *     run with respect to the given attributes containing the current
     *     character.
     */
    public int getRunLimit(Set attributes);

    /**
     * Get the index of the first character of the run with
     *    respect to all attributes containing the current character.
     */
    public int getRunStart();

    /**
     * Get the index of the first character of the run with
     *      respect to the given attribute containing the current character.
     * @param attribute The attribute for whose appearance the first offset
     *      is requested.
     */
    public int getRunStart(AttributedCharacterIterator.Attribute attribute);

    /**
     * Get the index of the first character of the run with
     *      respect to the given attributes containing the current character.
     * @param attributes the Set of attributes which begins at the returned index.
     */
    public int getRunStart(Set attributes);

    //From CharacterIterator

    /**
     * Create a copy of this iterator
     */
    public Object clone();

    /**
     * Get the character at the current position (as returned
     *      by getIndex()).
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char current();

    /**
     * Sets the position to getBeginIndex().
     * @return the character at the start index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char first();

    /**
     * Get the start index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public int getBeginIndex();

    /**
     * Get the end index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public int getEndIndex();

    /**
     * Get the current index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public int getIndex();

    /**
     * Sets the position to getEndIndex()-1 (getEndIndex() if
     * the text is empty) and returns the character at that position.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char last();

    /**
     * Increments the iterator's index by one, returning the next character.
     * @return the character at the new index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char next();

    /**
     * Decrements the iterator's index by one and returns
     * the character at the new index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char previous();

    /**
     * Sets the position to the specified position in the text.
     * @param position The new (current) index into the text.
     * @return the character at new index <em>position</em>.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char setIndex(int position);

    //Inner classes:

    /**
     * Attribute keys that identify SVG text attributes.  Anchor point for
     * attribute values of X, Y, and ROTATION is determined by the character's
     * font and other attributes.
     * We duplicate the features of java.awt.font.TextAttribute rather than
     * subclassing because java.awt.font.TextAttribute is <em>final</em>.
     */
    public static class TextAttribute extends AttributedCharacterIterator.Attribute {

        /** Construct a TextAttribute key with name s */
        public TextAttribute(String s) {
            super(s);
        }

        public final static TextAttribute FLOW_PARAGRAPH =
            new TextAttribute("FLOW_PARAGRAPH");

        public final static TextAttribute FLOW_EMPTY_PARAGRAPH =
            new TextAttribute("FLOW_EMPTY_PARAGRAPH");

        public final static TextAttribute FLOW_LINE_BREAK =
            new TextAttribute("FLOW_LINE_BREAK");

        public final static TextAttribute FLOW_REGIONS =
            new TextAttribute("FLOW_REGIONS");

        public final static TextAttribute LINE_HEIGHT =
            new TextAttribute("LINE_HEIGHT");

        public final static TextAttribute PREFORMATTED =
            new TextAttribute("PREFORMATTED");

        /** Attribute span delimiter - new tspan, tref, or textelement.*/
        public final static TextAttribute TEXT_COMPOUND_DELIMITER =
                              new TextAttribute("TEXT_COMPOUND_DELIMITER");

        /** Anchor type.*/
        public final static TextAttribute ANCHOR_TYPE =
                              new TextAttribute("ANCHOR_TYPE");

        /** Marker attribute indicating explicit glyph layout.*/
        public final static TextAttribute EXPLICIT_LAYOUT =
                              new TextAttribute("EXPLICIT_LAYOUT");

        /** User-space X coordinate for character.*/
        public final static TextAttribute X = new TextAttribute("X");

        /** User-space Y coordinate for character.*/
        public final static TextAttribute Y = new TextAttribute("Y");

        /** User-space relative X coordinate for character.*/
        public final static TextAttribute DX = new TextAttribute("DX");

        /** User-space relative Y coordinate for character.*/
        public final static TextAttribute DY = new TextAttribute("DY");

        /** Rotation for character, in degrees.*/
        public final static TextAttribute ROTATION =
                                          new TextAttribute("ROTATION");

        /** All the paint attributes for the text.*/
        public final static TextAttribute PAINT_INFO =
                                          new TextAttribute("PAINT_INFO");

        /** Author-expected width for bounding box containing
         *  all text string glyphs.
         */
        public final static TextAttribute BBOX_WIDTH =
                                          new TextAttribute("BBOX_WIDTH");

        /** Method specified for adjusting text element layout size.
         */
        public final static TextAttribute LENGTH_ADJUST =
                                          new TextAttribute("LENGTH_ADJUST");

        /** Convenience flag indicating that non-default glyph spacing is needed.
         */
        public final static TextAttribute CUSTOM_SPACING =
                                          new TextAttribute("CUSTOM_SPACING");

        /** User-specified inter-glyph kerning value.
         */
        public final static TextAttribute KERNING =
                                          new TextAttribute("KERNING");

        /** User-specified inter-glyph spacing value.
         */
        public final static TextAttribute LETTER_SPACING =
                                          new TextAttribute("LETTER_SPACING");

        /** User-specified width for whitespace characters.
         */
        public final static TextAttribute WORD_SPACING =
                                          new TextAttribute("WORD_SPACING");

        /** Path along which text is to be laid out */
        public final static TextAttribute TEXTPATH =
                                          new TextAttribute("TEXTPATH");

        /** Font variant to be used for this character span.
         * @see org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator.TextAttribute#SMALL_CAPS
         */
        public final static TextAttribute FONT_VARIANT =
                                          new TextAttribute("FONT_VARIANT");

        /** Baseline adjustment to be applied to this character span.
         */
        public final static TextAttribute BASELINE_SHIFT =
                                          new TextAttribute("BASELINE_SHIFT");

        /** Directional writing mode applied to this character span.
         */
        public final static TextAttribute WRITING_MODE =
                                          new TextAttribute("WRITING_MODE");

        public final static TextAttribute VERTICAL_ORIENTATION =
                                          new TextAttribute("VERTICAL_ORIENTATION");

        public final static TextAttribute VERTICAL_ORIENTATION_ANGLE =
                                          new TextAttribute("VERTICAL_ORIENTATION_ANGLE");

        public final static TextAttribute HORIZONTAL_ORIENTATION_ANGLE =
                                          new TextAttribute("HORIZONTAL_ORIENTATION_ANGLE");

        public final static TextAttribute GVT_FONT_FAMILIES =
                                          new TextAttribute("GVT_FONT_FAMILIES");

        public final static TextAttribute GVT_FONT =
                                          new TextAttribute("GVT_FONT");

        public final static TextAttribute ALT_GLYPH_HANDLER =
                                          new TextAttribute("ALT_GLYPH_HANDLER");

        public final static TextAttribute BIDI_LEVEL =
                                          new TextAttribute("BIDI_LEVEL");

        public final static TextAttribute CHAR_INDEX =
                                          new TextAttribute("CHAR_INDEX");

        public final static TextAttribute ARABIC_FORM =
                                          new TextAttribute("ARABIC_FORM");

        // VALUES

        /** Value for WRITING_MODE indicating left-to-right */
        public final static Integer WRITING_MODE_LTR = new Integer(0x1);

        /** Value for WRITING_MODE indicating right-to-left */
        public final static Integer WRITING_MODE_RTL = new Integer(0x2);

        /** Value for WRITING_MODE indicating top-to-botton */
        public final static Integer WRITING_MODE_TTB = new Integer(0x3);

        /** Value for VERTICAL_ORIENTATION indicating an angle */
        public final static Integer ORIENTATION_ANGLE = new Integer(0x1);

        /** Value for VERTICAL_ORIENTATION indicating auto */
        public final static Integer ORIENTATION_AUTO = new Integer(0x2);

        /** Value for FONT_VARIANT specifying small caps */
        public final static Integer SMALL_CAPS = new Integer(0x10);

        /** Value for UNDERLINE specifying underlining-on */
        public final static Integer UNDERLINE_ON =
                            java.awt.font.TextAttribute.UNDERLINE_ON;

        /** Value for OVERLINE specifying overlining-on */
        public final static Boolean OVERLINE_ON = new Boolean(true);

        /** Value for STRIKETHROUGH specifying strikethrough-on */
        public final static Boolean STRIKETHROUGH_ON =
                            java.awt.font.TextAttribute.STRIKETHROUGH_ON;

        /** Value for LENGTH_ADJUST specifying adjustment to inter-glyph spacing */
        public final static Integer ADJUST_SPACING =
                            new Integer(0x0);

        /** Value for LENGTH_ADJUST specifying overall scaling of layout outlines */
        public final static Integer ADJUST_ALL =
                            new Integer(0x01);

        // constant values for the arabic glyph forms
        public final static Integer ARABIC_NONE = new Integer(0x0);
        public final static Integer ARABIC_ISOLATED = new Integer(0x1);
        public final static Integer ARABIC_TERMINAL = new Integer(0x2);
        public final static Integer ARABIC_INITIAL = new Integer(0x3);
        public final static Integer ARABIC_MEDIAL = new Integer(0x4);

    }

    /**
     * Interface for helper class which mutates the attributes of an
     * AttributedCharacterIterator.
     * Typically used to convert location and rotation attributes to
     * TextAttribute.TRANSFORM attributes, or convert between implementations
     * of AttributedCharacterIterator.Attribute.
     */
    public interface AttributeFilter {

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
        public AttributedCharacterIterator
            mutateAttributes(AttributedCharacterIterator aci);

    }
}









