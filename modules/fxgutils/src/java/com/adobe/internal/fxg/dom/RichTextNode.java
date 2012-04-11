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

package com.adobe.internal.fxg.dom;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.richtext.AbstractRichTextNode;
import com.adobe.internal.fxg.dom.richtext.BRNode;
import com.adobe.internal.fxg.dom.richtext.DivNode;
import com.adobe.internal.fxg.dom.richtext.ImgNode;
import com.adobe.internal.fxg.dom.richtext.LinkNode;
import com.adobe.internal.fxg.dom.richtext.ParagraphNode;
import com.adobe.internal.fxg.dom.richtext.SpanNode;
import com.adobe.internal.fxg.dom.richtext.TCYNode;
import com.adobe.internal.fxg.dom.richtext.TabNode;
import com.adobe.internal.fxg.dom.richtext.TextHelper;
import com.adobe.internal.fxg.dom.richtext.TextLayoutFormatNode;
import com.adobe.internal.fxg.dom.types.AlignmentBaseline;
import com.adobe.internal.fxg.dom.types.BaselineOffset;
import com.adobe.internal.fxg.dom.types.BaselineShift;
import com.adobe.internal.fxg.dom.types.BlockProgression;
import com.adobe.internal.fxg.dom.types.BreakOpportunity;
import com.adobe.internal.fxg.dom.types.ColorWithEnum;
import com.adobe.internal.fxg.dom.types.DigitCase;
import com.adobe.internal.fxg.dom.types.DigitWidth;
import com.adobe.internal.fxg.dom.types.Direction;
import com.adobe.internal.fxg.dom.types.DominantBaseline;
import com.adobe.internal.fxg.dom.types.FontStyle;
import com.adobe.internal.fxg.dom.types.FontWeight;
import com.adobe.internal.fxg.dom.types.JustificationRule;
import com.adobe.internal.fxg.dom.types.JustificationStyle;
import com.adobe.internal.fxg.dom.types.Kerning;
import com.adobe.internal.fxg.dom.types.LeadingModel;
import com.adobe.internal.fxg.dom.types.LigatureLevel;
import com.adobe.internal.fxg.dom.types.LineBreak;
import com.adobe.internal.fxg.dom.types.NumberAuto;
import com.adobe.internal.fxg.dom.types.NumberInherit;
import com.adobe.internal.fxg.dom.types.TextAlign;
import com.adobe.internal.fxg.dom.types.TextDecoration;
import com.adobe.internal.fxg.dom.types.TextJustify;
import com.adobe.internal.fxg.dom.types.TextRotation;
import com.adobe.internal.fxg.dom.types.TypographicCase;
import com.adobe.internal.fxg.dom.types.VerticalAlign;
import com.adobe.internal.fxg.dom.types.WhiteSpaceCollapse;
import com.adobe.internal.fxg.dom.types.BaselineOffset.BaselineOffsetAsEnum;
import com.adobe.internal.fxg.dom.types.BaselineShift.BaselineShiftAsEnum;
import com.adobe.internal.fxg.dom.types.ColorWithEnum.ColorEnum;
import com.adobe.internal.fxg.dom.types.NumberAuto.NumberAutoAsEnum;
import com.adobe.internal.fxg.dom.types.NumberInherit.NumberInheritAsEnum;

/**
 * Represents a &lt;RichText&gt; element of an FXG Document.
 *
 * @since 2.0
 * @author Min Plunkett
 */
public class RichTextNode extends GraphicContentNode implements TextNode
{
    protected static final double FONTSIZE_MIN_INCLUSIVE = 1.0;
    protected static final double FONTSIZE_MAX_INCLUSIVE = 720.0;
    protected static final double PADDING_MIN_INCLUSIVE = 0.0;
    protected static final double PADDING_MAX_INCLUSIVE = 1000.0;    
    protected static final double BASELINEOFFSET_MIN_INCLUSIVE = 0.0;
    protected static final double BASELINEOFFSET_MAX_INCLUSIVE = 1000.0; 
    protected static final double BASELINESHIFT_MIN_INCLUSIVE = -1000.0;
    protected static final double BASELINESHIFT_MAX_INCLUSIVE = 1000.0; 
    protected static final int COLUMNCOUNT_MIN_INCLUSIVE = 0;
    protected static final int COLUMNCOUNT_MAX_INCLUSIVE = 50; 
    protected static final double COLUMNGAP_MIN_INCLUSIVE = 0.0;
    protected static final double COLUMNGAP_MAX_INCLUSIVE = 1000.0; 
    protected static final double COLUMNWIDTH_MIN_INCLUSIVE = 0.0;
    protected static final double COLUMNWIDTH_MAX_INCLUSIVE = 8000.0; 
    protected static final double LINEHEIGHT_PERCENT_MIN_INCLUSIVE = -1000.0;
    protected static final double LINEHEIGHT_PERCENT_MAX_INCLUSIVE = 1000.0; 
    protected static final double LINEHEIGHT_PIXEL_MIN_INCLUSIVE = -720.0;
    protected static final double LINEHEIGHT_PIXEL_MAX_INCLUSIVE = 720.0; 
    protected static final double PARAGRAPH_INDENT_MIN_INCLUSIVE = 0.0;
    protected static final double PARAGRAPH_INDENT_MAX_INCLUSIVE = 1000.00;    
    protected static final double PARAGRAPH_SPACE_MIN_INCLUSIVE = 0.0;
    protected static final double PARAGRAPH_SPACE_MAX_INCLUSIVE = 1000.00;    
    protected static final double TEXTINDENT_MIN_INCLUSIVE = -1000.0;
    protected static final double TEXTINDENT_MAX_INCLUSIVE = 1000.0; 
    protected static final double TRACKING_MIN_INCLUSIVE = -1000.0;
    protected static final double TRACKING_MAX_INCLUSIVE = 1000.0;     
    
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The width. */
    public double width = 0.0;
    
    /** The height. */
    public double height = 0.0;

    // Text Flow Attributes
    /** The block progression: Controls the direction in which lines are 
     * stacked. In Latin text, this is tb, because lines start at the top and 
     * proceed downward. In vertical Chinese or Japanese, this is rl, 
     * because lines should start at the right side of the container and 
     * proceed leftward. Default to "tb".*/
    public BlockProgression blockProgression = BlockProgression.TB;
    
    /** The padding left: Inset from left edge to content area. Units in 
     * pixels, defaults to 0. Minumum/maximum values 0/1000. Non-inheriting. */
    public NumberInherit paddingLeft = NumberInherit.newInstance(0.0);
    
    /** The padding right: Inset from right edge to content area. Units in 
     * pixels, defaults to 0. Minumum/maximum values 0/1000. Non-inheriting. */
    public NumberInherit paddingRight = NumberInherit.newInstance(0.0);
    
    /** The padding top: Inset from top edge to content area. Units in 
     * pixels, defaults to 0. Minumum/maximum values 0/1000. Non-inheriting. */
    public NumberInherit paddingTop = NumberInherit.newInstance(0.0);
    
    /** The padding bottom: Inset from bottom edge to content area. Units in 
     * pixels, defaults to 0. Minumum/maximum values 0/1000. Non-inheriting. */
    public NumberInherit paddingBottom = NumberInherit.newInstance(0.0);
    
    /** The line break: This is an enumeration. "toFit" is the default. 
     * Non-inheriting. */
    public LineBreak lineBreak = LineBreak.TOFIT;
    
    /** The column gap: Space between columns in pixels. Does not include 
     * space before the first column or after the last column - that is 
     * padding. Legal values range from 0 to 1000. Default value is 0. 
     * Non-inheriting. */
    public NumberInherit columnGap = NumberInherit.newInstance(20.0);
    
    /** The column count ("auto" | integer): Number of columns. The 
     * column number overrides the other column settings. Value is an Integer, 
     * or auto if unspecified. If it's an integer, the range of legal values 
     * is 0 to 50. If columnCount is not specified, but columnWidth is, then 
     * columnWidth is used to create as many columns as can fit in the 
     * container. Non-inheriting. Default is "auto". */
    public NumberAuto columnCount = NumberAuto.newInstance(NumberAutoAsEnum.AUTO);
    
    /** The column width ("auto" | Number): Width of columns in pixels. 
     * If you specify the width of the columns, but not the count, 
     * TextLayout will create as many columns of that width as possible given 
     * the the container width and columnGap settings. Any remainder space 
     * is left after the last column. Legal values are 0 to 8000. Default 
     * is "auto". Non-inheriting. */
    public NumberAuto columnWidth = NumberAuto.newInstance(NumberAutoAsEnum.AUTO);
    
    /** The first baseline offset ("auto", "ascent", "lineHeight" 
     * | Number): Specifies the position of the first line of text in the 
     * container (first in each column) relative to the top of the container. 
     * The first line may appear at the position of the line's ascent, or below 
     * by the lineHeight of the first line. Or it may be offset by a pixel 
     * amount. The default value (auto) specifies that the line top be 
     * aligned to the container top inset. The baseline that this property 
     * refers to is deduced from the container's locale as follows: 
     * ideographicBottom for Chinese and Japanese locales, roman otherwise. 
     * Minumum/maximum values 0/1000. Default is "auto". */
    public BaselineOffset firstBaselineOffset = BaselineOffset.newInstance(BaselineOffsetAsEnum.AUTO);
    
    /** The vertical align ("top", "middle", "bottom", 
     * "justify", "inherit"): Vertical alignment of the lines within the 
     * container. The lines may appear at the top of the container, centered 
     * within the container, at the bottom, or evenly spread out across the 
     * depth of the container. Default is "top". Non-inheriting. */
    public VerticalAlign verticalAlign = VerticalAlign.TOP;

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
    
    // Text Leaf Attributes
    /** The font family: The font family name used to render 
     * the text. The font family name may also be a comma-delimited list of 
     * font families, in which case the client should evaluate them in order. 
     * If no font is supplied, the client will pick one that is a variant of 
     * the Arial family, dependent on platform. Which font is used for 
     * rendering the text is up to the client and also depends on the glyphs 
     * that are being rendered and the fonts that are available. 
     * Default value is Arial. */
    public String fontFamily = "Arial";
    
    /** The font size: The size of the glyphs that is used to 
     * render the text, specified in pixels. Default is 12. Minimum 1 pixel. 
     * Maximum 720 pixels. */
    public double fontSize = 12.0;
    
    /** The font style: The style of the glyphs that is used to 
     * render the text. Legal values are "normal" and "italic". Default is 
     * "normal". */
    public FontStyle fontStyle = FontStyle.NORMAL;
    
    /** The font weight: The boldness or lightness of the glyphs 
     * that is used to render the text. Legal values are "normal" and "bold". 
     * Default is "normal". */
    public FontWeight fontWeight = FontWeight.NORMAL;
    
    /** The kerning ("on", "off", "auto"): If on, pair kerns are 
     * honored. If off, there is no font-based kerning applied. If auto, 
     * kerning is applied to all characters except Kanji, Hiragana or Katakana. 
     * The default is auto. Otherwise characters are drawn with no pair kerning 
     * adjustments. */
    public Kerning kerning = Kerning.AUTO;
    
    /** The line height: (Percent) | (Number): The distance from the 
     * baseline of the previous or the next line to the baseline of the 
     * current line is equal to the maximum amount of the leading applied to 
     * any character in the line. This is either a number or a percent. This 
     * can be specified in absolute pixels, or as a percentage. Default is 
     * 120%. Minimum/maximum value for number is -720/720, Minimum/maximum 
     * value percent is -1000%/1000%. */
    public double lineHeight = 120.0;
    
    /** The text decoration ("none", "underline"): The decoration 
     * to apply to the text. Default is "none".  */
    public TextDecoration textDecoration = TextDecoration.NONE;
    
    /** The line through: true if text has strikethrough 
     * applied, false otherwise. Default is false. */
    public boolean lineThrough = false;
    
    /** The text color: The color of the text. Default is #000000. */
    public int color = AbstractFXGNode.COLOR_BLACK;
    
    /** The text alpha: The alpha value applied to the text. 
     * Default is 1.0. */
    public double textAlpha = 1.0;
    
    /** The white space collapse ("preserve", "collapse"): This 
     * is an enumerated value. A value of "collapse" converts line feeds, 
     * newlines, and tabs to spaces and collapses adjacent spaces to one. 
     * Leading and trailing whitespace is trimmed. A value of "preserve" 
     * passes whitespace through unchanged, except hen the whitespace would 
     * result in an implied <p> and <span> that is all whitespace, in which 
     * case the whitespace is removed. Default is "collapse". */
    public WhiteSpaceCollapse whiteSpaceCollapse = WhiteSpaceCollapse.COLLAPSE;
    
    /** The background alpha: Alpha (transparency) value for the 
     * background. A value of 0 is fully transparent, and a value of 1 is 
     * fully opaque. Default value is 1. Non-inheriting. */
    public NumberInherit backgroundAlpha = NumberInherit.newInstance(1.0);;
    
    /** Text Leaf Attribute: The background color. */
    public ColorWithEnum backgroundColor = ColorWithEnum.newInstance(ColorEnum.TRANSPARENT);
    
    /** The baseline shift: (Number, Percent, "superscript", "subscript"):
     * Indicates the baseline shift for the element in pixels. The element is 
     * shifted perpendicular to the baseline by this amount. In horizontal 
     * text, a positive baseline shift moves the element up and a negative 
     * baseline shift moves the element down. The default value is 0.0, 
     * indicating no shift. A value of "superscript" shifts the text up by 
     * an amount specified in the font, and applies a transform to the 
     * fontSize also based on preferences in the font. A value of "subscript" 
     * shifts the text down by an amount specified in the font, and also 
     * transforms the fontSize. Percent shifts the text by a percentage of 
     * the fontSize. Minimum/maximum are -1000/1000, min/max percentage values 
     * are -1000%/1000%. */
    public BaselineShift baselineShift = BaselineShift.newInstance(0.0);
    
    /** The break opportunity ("auto", "any", "none", "all"): 
     * Controls where a line can legally break. "auto" means line breaking 
     * opportunities are based on standard Unicode character properties, 
     * such as breaking between words and on hyphens. Any indicates that the 
     * line may end at any character. This value is typically used when Roman 
     * text is embedded in Asian text and it is desirable for breaks to 
     * happen in the middle of words. None means that no characters in the 
     * range are treated as line break opportunities. All means that all 
     * characters in the range are treated as mandatory line break 
     * opportunities, so you get one character per line. Useful for creating 
     * effects like text on a path. Default is "auto". */
    public BreakOpportunity breakOpportunity = BreakOpportunity.AUTO;
    
    /** The digit case ("default", "lining", "oldStyle"): "default" 
     * uses the normal digit case from the font. "lining" uses the lining digit 
     * case from the font. "oldStyle" uses the old style digit case from the 
     * font. Default is "default". */
    public DigitCase digitCase = DigitCase.DEFAULT;
    
    /** The digit width ("default", "proportional", "tabular"): 
     * Specifies how wide digits will be when the text is set. 
     * Proportional means that the proportional widths from the font are 
     * used, and different digits will have different widths. Tabular means 
     * that every digits has the same width. Default means that the normal 
     * width from the font is used. Default is "default". */
    public DigitWidth digitWidth = DigitWidth.DEFAULT;
    
    /** The dominant baseline ("auto", "roman", "ascent", 
     * "descent", "ideographicTop", "ideographicCenter", "ideographicBottom"): 
     * Specifies which of the baselines of the element snaps to the 
     * alignmentBaseline to determine the vertical position of the element 
     * on the line. A value of "auto" gets resolved based on the textRotation 
     * of the span and the locale of the parent paragraph. A textRotation of 
     * "rotate270" resolves to ideographicCenter. A locale of Japanese ("ja") 
     * or Chinese ("zh-XX", "zh_XX", etc), resolves to ideographicCenter, 
     * whereas all others are resolved to roman. Default is auto.  */
    public DominantBaseline dominantBaseline = DominantBaseline.AUTO;
    
    /** The alignment baseline ("roman", "ascent", "descent", 
     * "ideographicTop", "ideographicCenter", "ideographicBottom", 
     * "useDominantBaseline"): Specifies which of the baselines of the line 
     * containing the element the dominantBaseline snaps to, thus determining 
     * the vertical position of the element in the line. Default is 
     * "useDominantBaseline". */
    public AlignmentBaseline alignmentBaseline = AlignmentBaseline.USEDOMINANTBASELINE;
    
    /** The ligature level ("minimum", "common", "uncommon", 
     * "exotic"): The ligature level used for this text. Controls which 
     * ligatures in the font will be used. Minimum turns on rlig, common is 
     * rlig + clig + liga, uncommon is rlig + clig + liga + dlig, exotic is 
     * rlig + clig + liga + dlig + hlig. There is no way to turn the various 
     * ligature features on independently. Default is "common". </li>
     * <li><b>locale</b> (String): The locale of the text. Controls case 
     * transformations and shaping. Standard locale identifiers as described 
     * in Unicode Technical Standard #35 are used. For example en, 
     * en_US and en-US are all English, ja is Japanese. Locale applied at 
     * the paragraph and higher level impacts resolution of "auto" values 
     * for dominantBaseline, justificationRule, justificationStyle and 
     * leadingModel. See individual attributes for resolution values. */
    public LigatureLevel ligatureLevel = LigatureLevel.COMMON;
    
    /** The locale: The locale of the text. Controls case 
     * transformations and shaping. Standard locale identifiers as described 
     * in Unicode Technical Standard #35 are used. For example en, 
     * en_US and en-US are all English, ja is Japanese. Locale applied at 
     * the paragraph and higher level impacts resolution of "auto" values 
     * for dominantBaseline, justificationRule, justificationStyle and 
     * leadingModel. See individual attributes for resolution values. */
    public String locale = "en";
    
    /** The typographic case ("default", "capsToSmallCaps", 
     * "uppercase", "lowercase", "lowercaseToSmallCaps": Controls the case in 
     * which the text will appear. "default" for the font that's 
     * chosen - i.e., its what you get without applying any features or case 
     * changes. smallCaps converts all characters to uppercase and applies c2sc.
     * uppercase and lowercase are case conversions. caps turns on case. 
     * lowercaseToSmallCaps converts all characters to uppercase, and for 
     * those characters which have been converted, applies c2sc. 
     * Default is "default". */
    public TypographicCase typographicCase = TypographicCase.DEFAULT;
    
    /** The tracking left: Space added to the left of 
     * each character. A Number tracks by a pixel amount, minimum/maximum 
     * values -1000/1000. Percent is a percent of the current fontSize, 
     * and may be negative, to bring characters closer together. Legal values 
     * for percentages are -1000% to 1000%. Default is 0. */
    public double trackingLeft = 0.0;
    
    /** The tracking right: Space added to the right of 
     * each character. A Number tracks by a pixel amount, minimum/maximum 
     * values -1000/1000. Percent is a percent of the current fontSize, 
     * and may be negative, to bring characters closer together. Legal values 
     * for percentages are -1000% to 1000%. Default is 0.*/
    public double trackingRight = 0.0;
    
    /** The text rotation ("auto", "rotate0", "rotate90", "rotate180", 
     * "rotate270"): The rotation of the text, in ninety degree increments. 
     * Default is "auto". */
    public TextRotation textRotation = TextRotation.AUTO;

    // Link format properties
    /** The link normal format. */
    public TextLayoutFormatNode linkNormalFormat = null;
    
    /** The link hover format. */
    public TextLayoutFormatNode linkHoverFormat = null;
    
    /** The link active format. */
    public TextLayoutFormatNode linkActiveFormat = null;    
    
    private boolean contiguous = false;
    
    //--------------------------------------------------------------------------
    //
    // TextNode Helpers
    //
    //--------------------------------------------------------------------------

    /**
     * The attributes set on this node.
     */
    protected Map<String, String> textAttributes;

    /**
     * @return A Map recording the attribute names and values set on this
     * text node.
     */
    public Map<String, String> getTextAttributes()
    {
        return textAttributes;
    }

    /**
     * This node's child text nodes.
     */
    protected List<TextNode> content;

    /**
     * @return The List of child nodes of this text node. 
     */
    public List<TextNode> getTextChildren()
    {
        return content;
    }

    /**
     * This node's child property nodes.
     */
    protected Map<String, TextNode> properties;

    /**
     * @return The List of child property nodes of this text node.
     */
    public Map<String, TextNode> getTextProperties()
    {
        return properties;
    }

    /**
     * A RichText node can also have special child property nodes that represent
     * complex property values that cannot be set via a simple attribute.
     * 
     * @param propertyName the property name
     * @param node the node
     */
    public void addTextProperty(String propertyName, TextNode node)
    {
        if (node instanceof TextLayoutFormatNode)
        {
            if (FXG_LINKACTIVEFORMAT_PROPERTY_ELEMENT.equals(propertyName))
            {
                if (linkActiveFormat == null)
                {
                    linkActiveFormat = (TextLayoutFormatNode)node;
                    linkActiveFormat.setParent(this);

                    if (properties == null)
                        properties = new HashMap<String, TextNode>(3);
                    properties.put(propertyName, linkActiveFormat);
                }
                else
                {
                    // Exception: Multiple LinkFormat elements are not allowed.
                    throw new FXGException(getStartLine(), getStartColumn(), "MultipleLinkFormatElements");
                }
            }
            else if (FXG_LINKHOVERFORMAT_PROPERTY_ELEMENT.equals(propertyName))
            {
                if (linkHoverFormat == null)
                {
                    linkHoverFormat = (TextLayoutFormatNode)node;
                    linkHoverFormat.setParent(this);

                    if (properties == null)
                        properties = new HashMap<String, TextNode>(3);
                    properties.put(propertyName, linkHoverFormat);
                }
                else
                {
                    // Exception: Multiple LinkFormat elements are not allowed.
                    throw new FXGException(getStartLine(), getStartColumn(), "MultipleLinkFormatElements");
                }
            }
            else if (FXG_LINKNORMALFORMAT_PROPERTY_ELEMENT.equals(propertyName))
            {
                if (linkNormalFormat == null)
                {
                    linkNormalFormat = (TextLayoutFormatNode)node;
                    linkNormalFormat.setParent(this);

                    if (properties == null)
                        properties = new HashMap<String, TextNode>(3);
                    properties.put(propertyName, linkNormalFormat);
                }
                else
                {
                    // Exception: Multiple LinkFormat elements are not allowed. 
                    throw new FXGException(getStartLine(), getStartColumn(), "MultipleLinkFormatElements");
                }
            }
            else
            {
                // Exception: Unknown LinkFormat element. 
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownLinkFormat", propertyName);
            }
        }
        else
        {
            addChild(node);
        }
    }

    /**
     * &lt;RichText&gt; content allows child &lt;p&gt;, &lt;span&gt; and
     * &lt;br /&gt; tags, as well as character data (text content).
     * 
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     */
    public void addContentChild(FXGNode child)
    {
        if (child instanceof ParagraphNode
                || child instanceof DivNode
                || child instanceof SpanNode
                || child instanceof BRNode
                || child instanceof TabNode
                || child instanceof TCYNode
                || child instanceof LinkNode
                || child instanceof ImgNode
                || child instanceof CDATANode)
        {
            if (child instanceof LinkNode && (((LinkNode)child).href == null))
            {
                // Exception: Missing href attribute in <a> element.
                throw new FXGException(getStartLine(), getStartColumn(), "MissingHref");                
            }   
            
            if (content == null)
            {
                content = new ArrayList<TextNode>();
                contiguous = true;
            }
            
            if (!contiguous)
            {
            	throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidRichTextContent");            	
            }

            content.add((TextNode)child);
        }
        else
        {
            throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidChildNode",  child.getNodeName(), getNodeName());                        
        }

        if (child instanceof AbstractRichTextNode)
            ((AbstractRichTextNode)child).setParent(this);       
    }

    /**
     * Remember that an attribute was set on this node.
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     */
    protected void rememberAttribute(String name, String value)
    {
        if (textAttributes == null)
            textAttributes = new HashMap<String, String>(4);

        textAttributes.put(name, value);
    }

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * This method is invoked for only non-content children. Supported child 
     * node: CDATANode. Content needs to be contigous.
     * 
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof CDATANode)
        {
            if (TextHelper.ignorableWhitespace(((CDATANode)child).content))
            {
            	/**
            	 * Ignorable white spaces don't break content contiguous 
            	 * rule and should be ignored.
            	 */
            	return;
            }
            else
            {
            	throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidRichTextContent");
            }
        }
        else 
        {
            super.addChild(child);
            contiguous = false;
            return;
        }
    }

    /**
     * @return The unqualified name of a RichText node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_RICHTEXT_ELEMENT;
    }

    /**
     * Sets an FXG attribute on this RichText node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * 
     * In addition to the attributes supported by all graphic content nodes,
     * RichText supports the following attributes.
     * 
     * <p>
     * <ul>
     * <li><b>width</b> (Number): The width of the text box to render text
     * in.</li>
     * <li><b>height</b> (Number): The height of the text box to render text
     * in.</li>
     * <li><b>blockProgression</b> (String) ("tb", "rl"): Controls the 
     * direction in which lines are stacked. In Latin text, this is tb, 
     * because lines start at the top and proceed downward. In vertical 
     * Chinese or Japanese, this is rl, because lines should start at the 
     * right side of the container and proceed leftward.  Default to "tb". </li>
     * <li><b>paddingLeft</b> (Number): Inset from left edge to content area. 
     * Units in pixels, defaults to 0. Minumum/maximum values 0/1000. 
     * Non-inheriting. </li>
     * <li><b>paddingRight</b> (Number): Inset from right edge to content 
     * area. Units in pixels, defaults to 0. Minumum/maximum values 0/1000. 
     * Non-inheriting. </li>
     * <li><b>paddingTop</b> (Number): Inset from top edge to content area. 
     * Units in pixels, defaults to 0. Minumum/maximum values 0/1000. 
     * Non-inheriting. </li>
     * <li><b>paddingBottom</b> (Number): Inset from bottom edge to content 
     * area. Units in pixels, defaults to 0. Minumum/maximum values 0/1000. 
     * Non-inheriting. </li>
     * <li><b>columnGap</b> (Number): Space between columns in pixels. Does 
     * not include space before the first column or after the last column - 
     * that is padding. Legal values range from 0 to 1000. Default value is 0. 
     * columnGap is non-inheriting. </li>
     * <li><b>columnCount</b> ("auto" | integer): Number of columns. The 
     * column number overrides the other column settings. Value is an Integer, 
     * or auto if unspecified. If it's an integer, the range of legal values 
     * is 0 to 50. If columnCount is not specified, but columnWidth is, then 
     * columnWidth is used to create as many columns as can fit in the 
     * container. columnCount is non-inheriting. Default is "auto". </li>
     * <li><b>columnWidth</b> ("auto" | Number): Width of columns in pixels. 
     * If you specify the width of the columns, but not the count, 
     * TextLayout will create as many columns of that width as possible given 
     * the the container width and columnGap settings. Any remainder space 
     * is left after the last column. Legal values are 0 to 8000. Default 
     * is "auto". columnWidth is non-inheriting. </li>
     * <li><b>firstBaselineOffset</b> (String) ("auto", "ascent", "lineHeight" 
     * | Number): Specifies the position of the first line of text in the 
     * container (first in each column) relative to the top of the container. 
     * The first line may appear at the position of the line's ascent, or below 
     * by the lineHeight of the first line. Or it may be offset by a pixel 
     * amount. The default value (auto) specifies that the line top be 
     * aligned to the container top inset. The baseline that this property 
     * refers to is deduced from the container's locale as follows: 
     * ideographicBottom for Chinese and Japanese locales, roman otherwise. 
     * Minumum/maximum values 0/1000. Default is "auto". </li>
     * <li><b>verticalAlign</b> (String) ("top", "middle", "bottom", 
     * "justify", "inherit"): Vertical alignment of the lines within the 
     * container. The lines may appear at the top of the container, centered 
     * within the container, at the bottom, or evenly spread out across the 
     * depth of the container. Default is "top". verticalAlign is 
     * non-inheriting.  </li>
     * <li><b>lineBreak</b> (String) ("toFit", "explicit"): This is an 
     * enumeration. A value of "toFit" wraps the lines at the edge of the 
     * enclosing RichText. A value of "explicit" breaks the lines only at a 
     * Unicode line end character (such as a newline or line separator). 
     * "toFit" is the default. lineBreak is a non-inheriting attribute. </li>
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
     * <li><b>fontFamily</b> (String): The font family name used to render 
     * the text. The font family name may also be a comma-delimited list of 
     * font families, in which case the client should evaluate them in order. 
     * If no font is supplied, the client will pick one that is a variant of 
     * the Arial family, dependent on platform. Which font is used for 
     * rendering the text is up to the client and also depends on the glyphs 
     * that are being rendered and the fonts that are available. 
     * Default value is Arial. </li>
     * <li><b>fontSize</b> (Number): The size of the glyphs that is used to 
     * render the text, specified in pixels. Default is 12. Minimum 1 pixel. 
     * Maximum 720 pixels. </li>
     * <li><b>fontStyle</b> (String): The style of the glyphs that is used to 
     * render the text. Legal values are "normal" and "italic". Default is 
     * "normal". </li>
     * <li><b>fontWeight</b> (String): The boldness or lightness of the glyphs 
     * that is used to render the text. Legal values are "normal" and "bold". 
     * Default is "normal". </li>
     * <li><b>lineHeight</b> (Percent) | (Number): The distance from the 
     * baseline of the previous or the next line to the baseline of the 
     * current line is equal to the maximum amount of the leading applied to 
     * any character in the line. This is either a number or a percent. This 
     * can be specified in absolute pixels, or as a percentage. Default is 
     * 120%. Minimum/maximum value for number is -720/720, Minimum/maximum 
     * value percent is -1000%/1000%. </li>
     * <li><b>textDecoration</b> (String) ("none", "underline"): The decoration 
     * to apply to the text. Default is "none". </li>
     * <li><b>lineThrough</b> (Boolean): true if text has strikethrough 
     * applied, false otherwise. Default is false. </li>
     * <li><b>color</b> (Color): The color of the text. Default is #000000.</li>
     * <li><b>textAlpha</b> (Number): The alpha value applied to the text. 
     * Default is 1.0. </li>
     * <li><b>whiteSpaceCollapse</b> (String) ("preserve", "collapse"): This 
     * is an enumerated value. A value of "collapse" converts line feeds, 
     * newlines, and tabs to spaces and collapses adjacent spaces to one. 
     * Leading and trailing whitespace is trimmed. A value of "preserve" 
     * passes whitespace through unchanged, except hen the whitespace would 
     * result in an implied <p> and <span> that is all whitespace, in which 
     * case the whitespace is removed. Default is "collapse". </li>
     * <li><b>kerning</b> (String) ("on", "off", "auto"): If on, pair kerns are 
     * honored. If off, there is no font-based kerning applied. If auto, 
     * kerning is applied to all characters except Kanji, Hiragana or Katakana. 
     * The default is auto. Otherwise characters are drawn with no pair kerning 
     * adjustments. </li>
     * <li><b>backgroundAlpha</b> (Number): Alpha (transparency) value for the 
     * background. A value of 0 is fully transparent, and a value of 1 is 
     * fully opaque. Default value is 1. backgroundAlpha is non-inheriting.</li>
     * <li><b>backgroundColor</b> (color, "transparent"): Background color of 
     * the text. Can be either transparent, or an integer containing three 8-bit 
     * RGB components. Default is transparent. BackgroundColor is 
     * non-inheriting. </li>
     * <li><b>baselineShift</b> (Number, Percent, "superscript", "subscript"):
     * Indicates the baseline shift for the element in pixels. The element is 
     * shifted perpendicular to the baseline by this amount. In horizontal 
     * text, a positive baseline shift moves the element up and a negative 
     * baseline shift moves the element down. The default value is 0.0, 
     * indicating no shift. A value of "superscript" shifts the text up by 
     * an amount specified in the font, and applies a transform to the 
     * fontSize also based on preferences in the font. A value of "subscript" 
     * shifts the text down by an amount specified in the font, and also 
     * transforms the fontSize. Percent shifts the text by a percentage of 
     * the fontSize. Minimum/maximum are -1000/1000, min/max percentage values 
     * are -1000%/1000%. </li>
     * <li><b>breakOpportunity</b> (String) ("auto", "any", "none", "all"): 
     * Controls where a line can legally break. Auto means line breaking 
     * opportunities are based on standard Unicode character properties, 
     * such as breaking between words and on hyphens. Any indicates that the 
     * line may end at any character. This value is typically used when Roman 
     * text is embedded in Asian text and it is desirable for breaks to 
     * happen in the middle of words. None means that no characters in the 
     * range are treated as line break opportunities. All means that all 
     * characters in the range are treated as mandatory line break 
     * opportunities, so you get one character per line. Useful for creating 
     * effects like text on a path. Default is auto. </li>
     * <li><b>digitCase</b> (String) ("default", "lining", "oldStyle"). Default 
     * uses the normal digit case from the font. Lining uses the lining digit 
     * case from the font. oldStyle uses the old style digit case from the 
     * font. Default is "default". </li>
     * <li><b>digitWidth</b> (String) ("default", "proportional", "tabular"): 
     * Specifies how wide digits will be when the text is set. 
     * Proportional means that the proportional widths from the font are 
     * used, and different digits will have different widths. Tabular means 
     * that every digits has the same width. Default means that the normal 
     * width from the font is used. Default is "default". </li>
     * <li><b>dominantBaseline</b> (String) ("auto", "roman", "ascent", 
     * "descent", "ideographicTop", "ideographicCenter", "ideographicBottom"): 
     * Specifies which of the baselines of the element snaps to the 
     * alignmentBaseline to determine the vertical position of the element 
     * on the line. A value of "auto" gets resolved based on the textRotation 
     * of the span and the locale of the parent paragraph. A textRotation of 
     * "rotate270" resolves to ideographicCenter. A locale of Japanese ("ja") 
     * or Chinese ("zh-XX", "zh_XX", etc), resolves to ideographicCenter, 
     * whereas all others are resolved to roman. Default is auto. </li>
     * <li><b>alignmentBaseline</b> (String) ("roman", "ascent", "descent", 
     * "ideographicTop", "ideographicCenter", "ideographicBottom", 
     * "useDominantBaseline"): Specifies which of the baselines of the line 
     * containing the element the dominantBaseline snaps to, thus determining 
     * the vertical position of the element in the line. Default is 
     * "useDominantBaseline". </li>
     * <li><b>ligatureLevel</b> (String) ("minimum", "common", "uncommon", 
     * "exotic"): The ligature level used for this text. Controls which 
     * ligatures in the font will be used. Minimum turns on rlig, common is 
     * rlig + clig + liga, uncommon is rlig + clig + liga + dlig, exotic is 
     * rlig + clig + liga + dlig + hlig. There is no way to turn the various 
     * ligature features on independently. Default is "common". </li>
     * <li><b>locale</b> (String): The locale of the text. Controls case 
     * transformations and shaping. Standard locale identifiers as described 
     * in Unicode Technical Standard #35 are used. For example en, 
     * en_US and en-US are all English, ja is Japanese. Locale applied at 
     * the paragraph and higher level impacts resolution of "auto" values 
     * for dominantBaseline, justificationRule, justificationStyle and 
     * leadingModel. See individual attributes for resolution values. </li>
     * <li><b>typographicCase</b> (String) ("default", "capsToSmallCaps", 
     * "uppercase", "lowercase", "lowercaseToSmallCaps": Controls the case in 
     * which the text will appear. "default" is for the font that's 
     * chosen - i.e., its what you get without applying any features or case 
     * changes. smallCaps converts all characters to uppercase and applies c2sc.
     * uppercase and lowercase are case conversions. caps turns on case. 
     * lowercaseToSmallCaps converts all characters to uppercase, and for 
     * those characters which have been converted, applies c2sc. 
     * Default is "default". </li>
     * <li><b>textRotation(String) ("auto", "rotate0", "rotate90", "rotate180", 
     * "rotate270"): The rotation of the text, in ninety degree increments. 
     * Default is "auto". </li>
     * <li><b>trackingLeft (Number | Percent): Space added to the left of 
     * each character. A Number tracks by a pixel amount, minimum/maximum 
     * values -1000/1000. Percent is a percent of the current fontSize, 
     * and may be negative, to bring characters closer together. Legal values 
     * for percentages are -1000% to 1000%. Default is 0. </li>
     * <li><b>trackingRight (Number | Percent): Space added to the right of 
     * each character. A Number tracks by a pixel amount, minimum/maximum 
     * values -1000/1000. Percent is a percent of the current fontSize, 
     * and may be negative, to bring characters closer together. Legal values 
     * for percentages are -1000% to 1000%. Default is 0. </li>
     * </ul>
     * </p>
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.GraphicContentNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name,  String value)
    {
        if (FXG_WIDTH_ATTRIBUTE.equals(name))
        {
            width = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_HEIGHT_ATTRIBUTE.equals(name))
        {
            height = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_BLOCKPROGRESSION_ATTRIBUTE.equals(name))
        {
            blockProgression = TextHelper.getBlockProgression(this, value);
        }
        else if (FXG_PADDINGLEFT_ATTRIBUTE.equals(name))
        {
            paddingLeft = getNumberInherit(this, name, value, PADDING_MIN_INCLUSIVE, PADDING_MAX_INCLUSIVE, paddingLeft.getNumberInheritAsDbl(), "UnknownPaddingLeft");
        }
        else if (FXG_PADDINGRIGHT_ATTRIBUTE.equals(name))
        {
            paddingRight = getNumberInherit(this, name, value, PADDING_MIN_INCLUSIVE, PADDING_MAX_INCLUSIVE, paddingRight.getNumberInheritAsDbl(), "UnknownPaddingRight");
        }
        else if (FXG_PADDINGTOP_ATTRIBUTE.equals(name))
        {
            paddingTop = getNumberInherit(this, name, value, PADDING_MIN_INCLUSIVE, PADDING_MAX_INCLUSIVE, paddingTop.getNumberInheritAsDbl(), "UnknownPaddingTop");
        }
        else if (FXG_PADDINGBOTTOM_ATTRIBUTE.equals(name))
        {
            paddingBottom = getNumberInherit(this, name, value, PADDING_MIN_INCLUSIVE, PADDING_MAX_INCLUSIVE, paddingBottom.getNumberInheritAsDbl(), "UnknownPaddingBottom");
        }
        else if (FXG_LINEBREAK_ATTRIBUTE.equals(name))
        {
            lineBreak = TextHelper.getLineBreak(this, value);
        }        
        else if (FXG_COLUMNGAP_ATTRIBUTE.equals(name))
        {
            columnGap = getNumberInherit(this, name, value, COLUMNGAP_MIN_INCLUSIVE, COLUMNGAP_MAX_INCLUSIVE, columnGap.getNumberInheritAsDbl(), "UnknownColumnGap");
        }
        else if (FXG_COLUMNCOUNT_ATTRIBUTE.equals(name))
        {
            columnCount = getNumberAutoInt(this, name, value, COLUMNCOUNT_MIN_INCLUSIVE, COLUMNCOUNT_MAX_INCLUSIVE, columnCount.getNumberAutoAsInt(), "UnknownColumnCount");
        }
        else if (FXG_COLUMNWIDTH_ATTRIBUTE.equals(name))
        {
            columnWidth = getNumberAutoDbl(this, name, value, COLUMNWIDTH_MIN_INCLUSIVE, COLUMNWIDTH_MAX_INCLUSIVE, columnWidth.getNumberAutoAsDbl(), "UnknownColumnWidth");
        }
        else if (FXG_FIRSTBASELINEOFFSET_ATTRIBUTE.equals(name))
        {
            firstBaselineOffset = getFirstBaselineOffset(this, name, value, BASELINEOFFSET_MIN_INCLUSIVE, BASELINEOFFSET_MAX_INCLUSIVE, firstBaselineOffset.getBaselineOffsetAsDbl());
        }
        else if (FXG_VERTICALALIGN_ATTRIBUTE.equals(name))
        {
            verticalAlign = TextHelper.getVerticalAlign(this, value);
        } 
        else if (FXG_TEXTALIGN_ATTRIBUTE.equals(name))
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
        else if (FXG_FONTFAMILY_ATTRIBUTE.equals(name))
        {
            fontFamily = value;
        }
        else if (FXG_FONTSIZE_ATTRIBUTE.equals(name))
        {
            fontSize = DOMParserHelper.parseDouble(this, value, name, FONTSIZE_MIN_INCLUSIVE, FONTSIZE_MAX_INCLUSIVE, fontSize);
        }
        else if (FXG_FONTSTYLE_ATTRIBUTE.equals(name))
        {
            fontStyle = TextHelper.getFontStyle(this, value);
        }
        else if (FXG_FONTWEIGHT_ATTRIBUTE.equals(name))
        {
            fontWeight = TextHelper.getFontWeight(this, value);
        }
        else if (FXG_KERNING_ATTRIBUTE.equals(name))
        {
            kerning = TextHelper.getKerning(this, value);
        }        
        else if (FXG_LINEHEIGHT_ATTRIBUTE.equals(name))
        {
            lineHeight = DOMParserHelper.parseNumberPercentWithSeparateRange(this, value, name, 
                    LINEHEIGHT_PIXEL_MIN_INCLUSIVE, LINEHEIGHT_PIXEL_MAX_INCLUSIVE,
                    LINEHEIGHT_PERCENT_MIN_INCLUSIVE, LINEHEIGHT_PERCENT_MAX_INCLUSIVE, lineHeight); 
        }
        else if (FXG_TEXTDECORATION_ATTRIBUTE.equals(name))
        {
            textDecoration = TextHelper.getTextDecoration(this, value);
        }
        else if ( FXG_LINETHROUGH_ATTRIBUTE.equals(name))
        {
            lineThrough = DOMParserHelper.parseBoolean(this, value, name);
        }                   
        else if (FXG_COLOR_ATTRIBUTE.equals(name))
        {
            color = DOMParserHelper.parseRGB(this, value, name);
        }
        else if (FXG_TEXTALPHA_ATTRIBUTE.equals(name))
        {
            textAlpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, textAlpha);
        }
        else if (FXG_WHITESPACECOLLAPSE_ATTRIBUTE.equals(name))
        {
            whiteSpaceCollapse = TextHelper.getWhiteSpaceCollapse(this, value);
        }
        else if (FXG_BACKGROUNDALPHA_ATTRIBUTE.equals(name))
        {
        	backgroundAlpha = getAlphaInherit(this, name, value, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, backgroundAlpha.getNumberInheritAsDbl(), "UnknownBackgroundAlpha");
        }
        else if (FXG_BACKGROUNDCOLOR_ATTRIBUTE.equals(name))
        {
            backgroundColor = getColorWithEnum(this, name, value);
        }
        else if (FXG_BASELINESHIFT_ATTRIBUTE.equals(name))
        {
            baselineShift = getBaselineShift(this, name, value, BASELINESHIFT_MIN_INCLUSIVE, BASELINESHIFT_MAX_INCLUSIVE, baselineShift.getBaselineShiftAsDbl());
        }
        else if (FXG_BREAKOPPORTUNITY_ATTRIBUTE.equals(name))
        {
            breakOpportunity = TextHelper.getBreakOpportunity(this, value);
        }
        else if (FXG_DIGITCASE_ATTRIBUTE.equals(name))
        {
            digitCase = TextHelper.getDigitCase(this, value);
        }
        else if (FXG_DIGITWIDTH_ATTRIBUTE.equals(name))
        {
            digitWidth = TextHelper.getDigitWidth(this, value);
        }
        else if (FXG_DOMINANTBASELINE_ATTRIBUTE.equals(name))
        {
            dominantBaseline = TextHelper.getDominantBaseline(this, value);
        }
        else if (FXG_ALIGNMENTBASELINE_ATTRIBUTE.equals(name))
        {
            alignmentBaseline = TextHelper.getAlignmentBaseline(this, value);
        }
        else if (FXG_LIGATURELEVEL_ATTRIBUTE.equals(name))
        {
            ligatureLevel = TextHelper.getLigatureLevel(this, value);
        }
        else if (FXG_LOCALE_ATTRIBUTE.equals(name))
        {
            locale = value;
        }
        else if (FXG_TYPOGRAPHICCASE_ATTRIBUTE.equals(name))
        {
            typographicCase = TextHelper.getTypographicCase(this, value);
        }        
        else if (FXG_TRACKINGLEFT_ATTRIBUTE.equals(name))
        {
            trackingLeft = DOMParserHelper.parseNumberPercent(this, value, name, TRACKING_MIN_INCLUSIVE, TRACKING_MAX_INCLUSIVE, trackingLeft);
        }
        else if (FXG_TRACKINGRIGHT_ATTRIBUTE.equals(name))
        {
            trackingRight = DOMParserHelper.parseNumberPercent(this, value, name, TRACKING_MIN_INCLUSIVE, TRACKING_MAX_INCLUSIVE, trackingRight);
        } 
        else if (FXG_TEXTROTATION_ATTRIBUTE.equals(name))
        {
        	textRotation = TextHelper.getTextRotation(this, value);
        }
        else if (FXG_ID_ATTRIBUTE.equals(name))
        {
            //id = value;
        }        
        else
        {
        	super.setAttribute(name, value);
        }

        // Remember that this attribute was set on this node.
        rememberAttribute(name, value);
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * Convert an FXG String value to a BaselineOffset object.
     * 
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest double value that the result must be greater
     * or equal to.
     * @param max - the largest double value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default double value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @return the matching BaselineOffset rule.
     * @throws FXGException if the String did not match a known
     * BaselineOffset rule or the value falls out of the specified range 
     * (inclusive).
     */
    private BaselineOffset getFirstBaselineOffset(FXGNode node, String name, String value, double min, double max, double defaultValue)
    {
        if (FXG_BASELINEOFFSET_AUTO_VALUE.equals(value))
        {
            return BaselineOffset.newInstance(BaselineOffsetAsEnum.AUTO);
        }
        else if (FXG_BASELINEOFFSET_ASCENT_VALUE.equals(value))
        {
            return BaselineOffset.newInstance(BaselineOffsetAsEnum.ASCENT);
        }
        else if (FXG_BASELINEOFFSET_LINEHEIGHT_VALUE.equals(value))
        {
            return BaselineOffset.newInstance(BaselineOffsetAsEnum.LINEHEIGHT);
        }
        else
        {
        	try
        	{
        		return BaselineOffset.newInstance(DOMParserHelper.parseDouble(this, value, name, min, max, defaultValue));
        	}
        	catch(FXGException e)
        	{
	            //Exception: Unknown first baseline offset: {0}
	            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownFirstBaselineOffset", value);
        	}
        }
    }
    
    /**
     * Convert an FXG String value to a NumberAuto object.
     * 
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest double value that the result must be greater
     * or equal to.
     * @param max - the largest double value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default double value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @param errorCode - the error code if value is out-of-range.
     * @return the matching NumberAuto rule.
     * @throws FXGException if the String did not match a known
     * NumberAuto rule.
     */
    private NumberAuto getNumberAutoDbl(FXGNode node, String name, String value, double min, double max, double defaultValue, String errorCode)
    {
        try
        {
            return NumberAuto.newInstance(DOMParserHelper.parseDouble(this, value, name, min, max, defaultValue));            
        }catch(FXGException e)
        {
            if (FXG_NUMBERAUTO_AUTO_VALUE.equals(value))
                return NumberAuto.newInstance(NumberAutoAsEnum.AUTO);
            else if (FXG_INHERIT_VALUE.equals(value))
            	return NumberAuto.newInstance(NumberAutoAsEnum.INHERIT);
            else
                //Exception: Unknown number auto: {0}
                throw new FXGException(node.getStartLine(), node.getStartColumn(), errorCode, value);            
        }
    }
    
    /**
     * Convert an FXG String value to a NumberAuto object.
     * 
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest int value that the result must be greater
     * or equal to.
     * @param max - the largest int value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default int value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @param errorCode - the error code if value is out-of-range.
     * @return the matching NumberAuto rule.
     * @throws FXGException if the String did not match a known
     * NumberAuto rule.
     */
    private NumberAuto getNumberAutoInt(FXGNode node, String name, String value, int min, int max, int defaultValue, String errorCode)
    {
        try
        {
            return NumberAuto.newInstance(DOMParserHelper.parseInt(this, value, name, min, max, defaultValue));            
        }catch(FXGException e)
        {
            if (FXG_NUMBERAUTO_AUTO_VALUE.equals(value))
                return NumberAuto.newInstance(NumberAutoAsEnum.AUTO);
            else if (FXG_INHERIT_VALUE.equals(value))
            	return NumberAuto.newInstance(NumberAutoAsEnum.INHERIT);
            else
                //Exception: Unknown number auto: {0}
                throw new FXGException(node.getStartLine(), node.getStartColumn(), errorCode, value);            
        }
    }
    
    /**
     * Convert an FXG String value to a NumberInherit enumeration.
     * 
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest double value that the result must be greater
     * or equal to.
     * @param max - the largest double value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default double value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @param errorCode - the error code if value is out-of-range.
     * @return the matching NumberInherit rule.
     * @throws FXGException if the String did not match a known
     * NumberInherit rule or the value falls out of the specified range 
     * (inclusive).
     */
    private NumberInherit getNumberInherit(FXGNode node, String name, String value, double min, double max, double defaultValue, String errorCode)
    {
        try
        {
            return NumberInherit.newInstance(DOMParserHelper.parseDouble(this, value, name, min, max, defaultValue));            
        }catch(FXGException e)
        {
            if (FXG_INHERIT_VALUE.equals(value))
                return NumberInherit.newInstance(NumberInheritAsEnum.INHERIT);
            else
                //Exception: Unknown number inherit: {0}
                throw new FXGException(node.getStartLine(), node.getStartColumn(), errorCode, value);            
        }
    }
    
    /**
     * Convert an FXG String value to a BaselineShift enumeration.
     * 
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest double value that the result must be greater
     * or equal to.
     * @param max - the largest double value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default double value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @return the matching BaselineShift rule.
     * @throws FXGException if the String did not match a known
     * BaselineShift rule or the value falls out of the specified range 
     * (inclusive).
     */
    private BaselineShift getBaselineShift(FXGNode node, String name, String value, double min, double max, double defaultValue)
    {
        try
        {
        	
            return BaselineShift.newInstance(DOMParserHelper.parseNumberPercent(this, value, name, min, max, defaultValue));            
        }
        catch(FXGException e)
        {
            if (FXG_BASELINESHIFT_SUPERSCRIPT_VALUE.equals(value))
            {
                return BaselineShift.newInstance(BaselineShiftAsEnum.SUPERSCRIPT);
            }
            else if (FXG_BASELINESHIFT_SUBSCRIPT_VALUE.equals(value))
            {
                return BaselineShift.newInstance(BaselineShiftAsEnum.SUBSCRIPT);
            }
            else
            {
                //Exception: Unknown baseline shift: {0}
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownBaselineShift", value);            
            }
        }
    }
    
    /**
     * Convert an FXG String value to a NumberInherit object.
     * 
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest double value that the result must be greater
     * or equal to.
     * @param max - the largest double value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default double value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @param errorCode - the error code if value is out-of-range.
     * @return the matching NumberInherit rule.
     * @throws FXGException if the String did not match a known
     * NumberInherit rule.
     */
    private NumberInherit getAlphaInherit(FXGNode node, String name, String value, double min, double max, double defaultValue, String errorCode)        
    {
        try
        {
            return NumberInherit.newInstance(DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, defaultValue));           
        }catch(FXGException e)
        {
            if (FXG_INHERIT_VALUE.equals(value))
            {
                return NumberInherit.newInstance(NumberInheritAsEnum.INHERIT);
            }
            else
            {
                //Exception: Unknown number inherit: {0}
                throw new FXGException(node.getStartLine(), node.getStartColumn(), errorCode, value);            
            }
        }
    }
    
    /**
     * Convert an FXG String value to a NumberInherit object.
     * 
     * @param node - the FXG node.
     * @param attribute - the FXG attribute name.
     * @param value - the FXG String value.
     * @return the matching NumberInherit rule.
     * @throws FXGException if the String did not match a known
     * NumberInherit rule.
     */
    private ColorWithEnum getColorWithEnum(FXGNode node, String attribute, String value)        
    {
        if (FXG_COLORWITHENUM_TRANSPARENT_VALUE.equals(value))
        {
            return ColorWithEnum.newInstance(ColorEnum.TRANSPARENT);
        }
        else if (FXG_INHERIT_VALUE.equals(value))
        {
            return ColorWithEnum.newInstance(ColorEnum.INHERIT);
        }
        else
        {
            return ColorWithEnum.newInstance(DOMParserHelper.parseRGB(this, value, attribute));           
        }
    }
}

