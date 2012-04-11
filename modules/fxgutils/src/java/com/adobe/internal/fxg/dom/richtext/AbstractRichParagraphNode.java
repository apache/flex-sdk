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

package com.adobe.internal.fxg.dom.richtext;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.types.Direction;
import com.adobe.internal.fxg.dom.types.JustificationRule;
import com.adobe.internal.fxg.dom.types.JustificationStyle;
import com.adobe.internal.fxg.dom.types.LeadingModel;
import com.adobe.internal.fxg.dom.types.TextAlign;
import com.adobe.internal.fxg.dom.types.TextJustify;

/**
 * An base class that represents a paragraph text.
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public abstract class AbstractRichParagraphNode extends AbstractRichTextLeafNode
{
    protected static final double PARAGRAPH_INDENT_MIN_INCLUSIVE = 0.0;
    protected static final double PARAGRAPH_INDENT_MAX_INCLUSIVE = 1000.00;    
    protected static final double PARAGRAPH_SPACE_MIN_INCLUSIVE = 0.0;
    protected static final double PARAGRAPH_SPACE_MAX_INCLUSIVE = 1000.00;    
    protected static final double TEXTINDENT_MIN_INCLUSIVE = -1000.0;
    protected static final double TEXTINDENT_MAX_INCLUSIVE = 1000.0; 

    // Paragraph Attributes
    /** The text align ("start", "end", "left", "center", 
     * "right", "justify"): The alignment of the text relative to the text box 
     * edges. "start" is the edge specified by the direction property - left 
     * for direction="ltr", right for direction="rtl". Likewise "end" will be 
     * the right edge if direction="ltr", and the left edge if direction="rtl". 
     * Default is "start". */
    public TextAlign textAlign = TextAlign.START;
    
    /** The text align last ("start", "end", "left", "center", 
     * "right", "justify"): The alignment of the last line of the paragraph, 
     * applies if textAlign is justify. To make a paragraph set all lines 
     * justified, set textAlign and textAlignLast to justify. Default 
     * is "start". */
    public TextAlign textAlignLast = TextAlign.START;
    
    /** The text indent: The indentation of the first line of 
     * text in a paragraph. The indent is relative to the start edge. 
     * Measured in pixels. Default is 0. Can be negative. Minimum/maximum 
     * values are -1000/1000. */
    public double textIndent = 0.0;
    
    /** The paragraph start indent (Number | "inherit"): The indentation 
     * applied to the start edge (left edge if direction is ltr, right edge 
     * otherwise). Measured in pixels. Legal values range from 0 to 1000. 
     * Default is 0. */
    public double paragraphStartIndent = 0.0;
    
    /** The paragraph end indent (Number | "inherit"): The indentation 
     * applied to the end edge (right edge if direction is ltr, left edge 
     * otherwise). Measured in pixels. Legal values range from 0 to 1000. 
     * Default is 0. */
    public double paragraphEndIndent = 0.0;
    
    /** The paragraph space before (Number | "inherit"): This is the 
     * "space before" the paragraph. As in CSS, adjacent vertical space 
     * collapses. For two adjoining paragraphs (A, B), where A has 
     * paragraphSpaceAfter 12 and B has paragraphSpaceBefore 24, the total 
     * space between the paragraphs will be 24, the maximum of the two, and 
     * not 36, the sum. If the paragraph comes at the top of the column, 
     * no extra space is left before it; I think this is different than CSS. 
     * Legal values range from 0 to 1000. Default is 0. Minimum is 0. */
    public double paragraphSpaceBefore = 0.0;
    
    /** The paragraph space after (Number | "inherit"): This is the 
     * "space after" the paragraph. As in CSS, adjacent vertical space 
     * collapses (see note for paragraphSpaceBefore ). No "space after" 
     * is necessary if the paragraph falls at the bottom of the RichText. 
     * Legal values range from 0 to 1000. Default is 0. Minimum is 0. </li>
     * <li><b>justificationRule</b> (String) ("auto", "space", "eastAsian"): 
     * Set up the justifier. EastAsian will turn on justification for Japanese. 
     * Default is "auto". An value of "auto" is resolved based on the 
     * locale of the paragraph. Values for Japanese ("ja") and Chinese 
     * ("zh-XX", "zh_XX", etc) resolve to eastAsian, while all other 
     * locales resolve to space. */
    public double paragraphSpaceAfter = 0.0;
    
    /** The direction ("ltr", "rtl"): Controls the dominant 
     * writing direction for the paragraph (left-to-right or right-to-left), 
     * and how characters with no implicit writing direction, such as 
     * punctuation, are treated. Also controls the direction of the columns, 
     * which are set according to the value of the direction attribute of the 
     * RichText element. Default is "ltr". */
    public Direction direction = Direction.LTR;
    
    /** The justification rule ("auto", "space", "eastAsian"): 
     * Set up the justifier. EastAsian will turn on justification for Japanese. 
     * Default is "auto". An value of "auto" is resolved based on the 
     * locale of the paragraph. Values for Japanese ("ja") and Chinese 
     * ("zh-XX", "zh_XX", etc) resolve to eastAsian, while all other 
     * locales resolve to space. */
    public JustificationRule justificationRule = JustificationRule.AUTO;
    
    /** The justification style ("auto", 
     * "prioritizeLeastAdjustment", "pushInKinsoku", "pushOutOnly"): An value 
     * of "auto" is resolved based on the locale of the paragraph. Currently, 
     * all locales resolve to pushInKinsoku, however, this value is only 
     * used in conjunction with a justificationRule value of eastAsian, so is 
     * only applicable to "ja" and all "zh" locales. PrioritizeLeastAdjustment 
     * bases justification on either expanding or compressing the line, 
     * whichever gives a result closest to the desired width. PushInKinsoku 
     * Bases justification on compressing kinsoku at the end of the line, or 
     * expanding it if there is no kinsoku or if that space is insufficient. 
     * PushOutOnly bases justification on expanding the line. Default 
     * is "auto".*/
    public JustificationStyle justificationStyle = JustificationStyle.PRIORITIZELEASTADJUSTMENT;
    
    /** The text justify ("interWord", "distribute"): Default is 
     * "interWord". Applies when justificationRule is space. interWord 
     * spreads justification space out to spaces in the line. distribute 
     * spreads it out to letters as well as spaces. */
    public TextJustify textJustify = TextJustify.INTERWORD;
    
    /** The leading model: ("auto", "romanUp", "ideographicTopUp", 
     * "ideographicCenterUp", "ascentDescentUp", "ideographicTopDown", 
     * "ideographicCenterDown", "approximateTextField"): Specifies the leading 
     * basis (baseline to which the <code>lineHeight</code> property refers) 
     * and the leading direction (which determines whether lineHeight 
     * property refers to the distance of a line's baseline from that of the 
     * line before it or the line after it). Default is auto which is resolved 
     * based on locale. Locale values of Japanese ("ja") and Chinese 
     * ("zh-XX", "zh_XX", etc) resolve auto to ideographicTopDown and other 
     * locales resolve to romanUp. */
    public LeadingModel leadingModel = LeadingModel.AUTO;
    
    /** The tab stops: Array of tab stops. By default there 
     * are no tabs. Each tab stop has a: position in pixels, relative to the 
     * start of the line; alignment<start, center, end, decimal>; 
     * decimalAlignmentToken(String). Used when you want to align the text 
     * with a particular character or substring within it (for instance, 
     * to a decimal point) */
    public String tabStops = "";
    
    /**
     * This implementation processes paragraph attributes that are relevant to
     * the &lt;p&gt; tag, as well as delegates to the parent class to process
     * text leaf attributes that are also relevant to the &lt;p&gt; tag.
     * 
     * <p>
     * Paragraph attributes include:
     * <ul>
     * <li><b>textAlign</b> (String) ("start", "end", "left", "center", 
     * "right", "justify"): The alignment of the text relative to the text box 
     * edges. "start" is the edge specified by the direction property - left 
     * for direction="ltr", right for direction="rtl". Likewise "end" will be 
     * the right edge if direction="ltr", and the left edge if direction="rtl". 
     * Default is "start". </li>
     * <li><b>textAlignLast </b> (String) ("start", "end", "left", "center", 
     * "right", "justify"): The alignment of the last line of the paragraph, 
     * applies if textAlign is justify. To make a paragraph set all lines 
     * justified, set textAlign and textAlignLast to justify. Default 
     * is "start". </li>
     * <li><b>textIndent</b> (Number): The indentation of the first line of 
     * text in a paragraph. The indent is relative to the start edge. 
     * Measured in pixels. Default is 0. Can be negative. Minimum/maximum 
     * values are -1000/1000. </li>
     * <li><b>paragraphStartIndent</b> (Number | "inherit"): The indentation 
     * applied to the start edge (left edge if direction is ltr, right edge 
     * otherwise). Measured in pixels. Legal values range from 0 to 1000. 
     * Default is 0. </li>
     * <li><b>paragraphEndIndent</b> (Number | "inherit"): The indentation 
     * applied to the end edge (right edge if direction is ltr, left edge 
     * otherwise). Measured in pixels. Legal values range from 0 to 1000. 
     * Default is 0. </li>
     * <li><b>paragraphSpaceBefore</b> (Number | "inherit"): This is the 
     * "space before" the paragraph. As in CSS, adjacent vertical space 
     * collapses. For two adjoining paragraphs (A, B), where A has 
     * paragraphSpaceAfter 12 and B has paragraphSpaceBefore 24, the total 
     * space between the paragraphs will be 24, the maximum of the two, and 
     * not 36, the sum. If the paragraph comes at the top of the column, 
     * no extra space is left before it; I think this is different than CSS. 
     * Legal values range from 0 to 1000. Default is 0. Minimum is 0. </li>
     * <li><b>paragraphSpaceAfter</b> (Number | "inherit"): This is the 
     * "space after" the paragraph. As in CSS, adjacent vertical space 
     * collapses (see note for paragraphSpaceBefore ). No "space after" 
     * is necessary if the paragraph falls at the bottom of the RichText. 
     * Legal values range from 0 to 1000. Default is 0. Minimum is 0. </li>
     * <li><b>justificationRule</b> (String) ("auto", "space", "eastAsian"): 
     * Set up the justifier. EastAsian will turn on justification for Japanese. 
     * Default is "auto". An value of "auto" is resolved based on the 
     * locale of the paragraph. Values for Japanese ("ja") and Chinese 
     * ("zh-XX", "zh_XX", etc) resolve to eastAsian, while all other 
     * locales resolve to space. </li>
     * <li><b>justificationStyle</b> (String) ("auto", 
     * "prioritizeLeastAdjustment", "pushInKinsoku", "pushOutOnly"): An value 
     * of "auto" is resolved based on the locale of the paragraph. Currently, 
     * all locales resolve to pushInKinsoku, however, this value is only 
     * used in conjunction with a justificationRule value of eastAsian, so is 
     * only applicable to "ja" and all "zh" locales. PrioritizeLeastAdjustment 
     * bases justification on either expanding or compressing the line, 
     * whichever gives a result closest to the desired width. PushInKinsoku 
     * Bases justification on compressing kinsoku at the end of the line, or 
     * expanding it if there is no kinsoku or if that space is insufficient. 
     * PushOutOnly bases justification on expanding the line. Default 
     * is "auto". </li>
     * <li><b>textJustify</b> (String) ("interWord", "distribute"): Default is 
     * "interWord". Applies when justificationRule is space. interWord 
     * spreads justification space out to spaces in the line. distribute 
     * spreads it out to letters as well as spaces. </li>
     * <li><b>leadingModel</b> (String) ("auto", "romanUp", "ideographicTopUp", 
     * "ideographicCenterUp", "ascentDescentUp", "ideographicTopDown", 
     * "ideographicCenterDown", "approximateTextField"): Specifies the leading 
     * basis (baseline to which the <code>lineHeight</code> property refers) 
     * and the leading direction (which determines whether lineHeight 
     * property refers to the distance of a line's baseline from that of the 
     * line before it or the line after it). Default is auto which is resolved 
     * based on locale. Locale values of Japanese ("ja") and Chinese 
     * ("zh-XX", "zh_XX", etc) resolve auto to ideographicTopDown and other 
     * locales resolve to romanUp. </li>
     * <li><b>tabStops</b> (Array): Array of tab stops. By default there 
     * are no tabs. Each tab stop has a: position in pixels, relative to the 
     * start of the line; alignment<start, center, end, decimal>; 
     * decimalAlignmentToken(String). Used when you want to align the text 
     * with a particular character or substring within it (for instance, 
     * to a decimal point). </li>
     * <li><b>direction</b> (String) ("ltr", "rtl"): Controls the dominant 
     * writing direction for the paragraph (left-to-right or right-to-left), 
     * and how characters with no implicit writing direction, such as 
     * punctuation, are treated. Also controls the direction of the columns, 
     * which are set according to the value of the direction attribute of the 
     * RichText element. Default is "ltr". </li>
     * </ul>
     * </p>
     * 
     * @param name the attribute name
     * @param value the attribute value
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.richtext.AbstractRichTextNode#setAttribute(String, String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_TEXTALIGN_ATTRIBUTE.equals(name))
        {
            textAlign = TextHelper.getTextAlign(this, value);
        }
        else if (FXG_TEXTALIGNLAST_ATTRIBUTE.equals(name))
        {
            textAlignLast = TextHelper.getTextAlign(this, value);
        }
        else if (FXG_TEXTINDENT_ATTRIBUTE.equals(name))
        {
            textIndent = DOMParserHelper.parseDouble(this, value, name, TEXTINDENT_MIN_INCLUSIVE, TEXTINDENT_MAX_INCLUSIVE, textIndent);
        }
        else if (FXG_PARAGRAPHSTARTINDENT_ATTRIBUTE.equals(name))
        {
            paragraphStartIndent = DOMParserHelper.parseDouble(this, value, name, PARAGRAPH_INDENT_MIN_INCLUSIVE, PARAGRAPH_INDENT_MAX_INCLUSIVE, paragraphStartIndent);
        }
        else if (FXG_PARAGRAPHENDINDENT_ATTRIBUTE.equals(name))
        {
            paragraphEndIndent = DOMParserHelper.parseDouble(this, value, name, PARAGRAPH_INDENT_MIN_INCLUSIVE, PARAGRAPH_INDENT_MAX_INCLUSIVE, paragraphEndIndent);
        }
        else if (FXG_PARAGRAPHSPACEBEFORE_ATTRIBUTE.equals(name))
        {
            paragraphSpaceBefore = DOMParserHelper.parseDouble(this, value, name, PARAGRAPH_SPACE_MIN_INCLUSIVE, PARAGRAPH_SPACE_MAX_INCLUSIVE, paragraphSpaceBefore);
        }
        else if (FXG_PARAGRAPHSPACEAFTER_ATTRIBUTE.equals(name))
        {
            paragraphSpaceAfter = DOMParserHelper.parseDouble(this, value, name, PARAGRAPH_SPACE_MIN_INCLUSIVE, PARAGRAPH_SPACE_MAX_INCLUSIVE, paragraphSpaceAfter);
        }
        else if (FXG_DIRECTION_ATTRIBUTE.equals(name))
        {
            direction = TextHelper.getDirection(this, value);
        }
        else if (FXG_JUSTIFICATIONRULE_ATTRIBUTE.equals(name))
        {
            justificationRule = TextHelper.getJustificationRule(this, value);
        }
        else if (FXG_JUSTIFICATIONSTYLE_ATTRIBUTE.equals(name))
        {
            justificationStyle = TextHelper.getJustificationStyle(this, value);
        }
        else if (FXG_TEXTJUSTIFY_ATTRIBUTE.equals(name))
        {
            textJustify = TextHelper.getTextJustify(this, value);
        }
        else if (FXG_LEADINGMODEL_ATTRIBUTE.equals(name))
        {
            leadingModel = TextHelper.getLeadingModel(this, value);
        }        
        else if (FXG_TABSTOPS_ATTRIBUTE.equals(name))
        {
            tabStops = TextHelper.parseTabStops(this, value);
        } 
        else
        {
            super.setAttribute(name, value);
            return;
        }
        
        // Remember attribute was set on this node.
        rememberAttribute(name, value);        
    }    
}
