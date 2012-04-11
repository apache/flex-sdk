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
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.AbstractFXGNode;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.types.AlignmentBaseline;
import com.adobe.internal.fxg.dom.types.BaselineShift;
import com.adobe.internal.fxg.dom.types.BreakOpportunity;
import com.adobe.internal.fxg.dom.types.ColorWithEnum;
import com.adobe.internal.fxg.dom.types.DigitCase;
import com.adobe.internal.fxg.dom.types.DigitWidth;
import com.adobe.internal.fxg.dom.types.DominantBaseline;
import com.adobe.internal.fxg.dom.types.FontStyle;
import com.adobe.internal.fxg.dom.types.FontWeight;
import com.adobe.internal.fxg.dom.types.Kerning;
import com.adobe.internal.fxg.dom.types.LigatureLevel;
import com.adobe.internal.fxg.dom.types.NumberInherit;
import com.adobe.internal.fxg.dom.types.TextDecoration;
import com.adobe.internal.fxg.dom.types.TextRotation;
import com.adobe.internal.fxg.dom.types.TypographicCase;
import com.adobe.internal.fxg.dom.types.WhiteSpaceCollapse;
import com.adobe.internal.fxg.dom.types.BaselineShift.BaselineShiftAsEnum;
import com.adobe.internal.fxg.dom.types.ColorWithEnum.ColorEnum;
import com.adobe.internal.fxg.dom.types.NumberInherit.NumberInheritAsEnum;

/**
 * A base text left node class that have character formatting.
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public abstract class AbstractRichTextLeafNode extends AbstractRichTextNode
{
    protected static final double FONTSIZE_MIN_INCLUSIVE = 1.0;
    protected static final double FONTSIZE_MAX_INCLUSIVE = 720.0;
    protected static final double BASELINESHIFT_MIN_INCLUSIVE = -1000.0;
    protected static final double BASELINESHIFT_MAX_INCLUSIVE = 1000.0; 
    protected static final double LINEHEIGHT_PERCENT_MIN_INCLUSIVE = -1000.0;
    protected static final double LINEHEIGHT_PERCENT_MAX_INCLUSIVE = 1000.0; 
    protected static final double LINEHEIGHT_PIXEL_MIN_INCLUSIVE = -720.0;
    protected static final double LINEHEIGHT_PIXEL_MAX_INCLUSIVE = 720.0; 
    protected static final double TRACKING_MIN_INCLUSIVE = -1000.0;
    protected static final double TRACKING_MAX_INCLUSIVE = 1000.0;     

    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

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
    
    /**
     * This implementation processes text leaf attributes that are common to
     * &lt;RichText&gt;, &lt;p&gt;, and &lt;span&gt;.
     * <p>
     * The right hand side of an ActionScript assignment is generated for
     * each property based on the expected type of the attribute.
     * </p>
     * <p>
     * Text leaf attributes include:
     * <ul>
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
     * 
     * @param name - the unqualified attribute name
     * @param value - the attribute value
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.richtext.AbstractRichTextNode#addChild(FXGNode)
     */
    @Override
    public void setAttribute(String name, String value)
    {
    	if (FXG_FONTFAMILY_ATTRIBUTE.equals(name))
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
        else
        {
            super.setAttribute(name, value);
            return;
        }
        
        // Remember attribute was set on this node.
        rememberAttribute(name, value);
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods
    //
    //--------------------------------------------------------------------------

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
