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

package com.adobe.internal.fxg.dom.text;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.types.Kerning;
import com.adobe.internal.fxg.dom.types.LineBreak;
import com.adobe.internal.fxg.dom.types.WhiteSpaceCollapse;

/**
 * A base class for text nodes that have character formatting.
 * 
 * @author Peter Farland
 */
public abstract class AbstractCharacterTextNode extends AbstractTextNode
{
    protected static final double FONTSIZE_MIN_INCLUSIVE = 1.0;
    protected static final double FONTSIZE_MAX_INCLUSIVE = 720.0;

    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    // Character Attributes
    /** Character Attribute: The font family. */
    public String fontFamily = "Times New Roman";
    
    /** Character Attribute: The font size. */
    public double fontSize = 12.0;
    
    /** Character Attribute: The font style. */
    public String fontStyle = "normal";
    
    /** Character Attribute: The font weight. */
    public String fontWeight = "normal";
    
    /** Character Attribute: The line height. */
    public double lineHeight = 120.0;
    
    /** Character Attribute: The text decoration. */
    public String textDecoration = "none";
    
    /** Character Attribute: The white space collapse. */
    public WhiteSpaceCollapse whiteSpaceCollapse = WhiteSpaceCollapse.PRESERVE;
    
    /** Character Attribute: The line break. */
    public LineBreak lineBreak = LineBreak.TOFIT;
    
    /** Character Attribute: The tracking. */
    public double tracking = 0.0;
    
    /** Character Attribute: The kerning. */
    public Kerning kerning = Kerning.AUTO;
    
    /** Character Attribute: The text alpha. */
    public double textAlpha = 1.0;
    
    /** Character Attribute: The color. */
    public int color = COLOR_BLACK;
    
    /** Character Attribute: The line through. */
    public boolean lineThrough = false;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * This implementation processes character attributes that are common to
     * &lt;TextGraphic&gt;, &lt;p&gt;, and &lt;span&gt;. Delegates to the 
     * parent class to process attributes that are not in the list below.
     * <p>
     * The right hand side of an ActionScript assignment is generated for
     * each property based on the expected type of the attribute.
     * </p>
     * <p>
     * Character attributes include:
     * <ul>
     * <li><b>fontFamily</b> (String): The font family name used to render the
     * text. Default value is Times New Roman (Times on Mac OS X).</li>
     * <li><b>fontSize</b> (Number): The size of the glyphs that is used to
     * render the text, specified in point sizes. Default is 12. Minimum 1
     * point. Maximum 500 points.</li>
     * <li><b>fontStyle</b> (String): [normal, italic] The style of the glyphs
     * that is used to render the text. Legal values are 'normal' and 'italic'.
     * Default is normal.</li>
     * <li><b>fontWeight</b> (String): [normal, bold] The boldness or lightness
     * of the glyphs that is used to render the text. Default is normal.</li>
     * <li><b>lineHeight</b> (Percent | Number): The leading, or the distance
     * from the previous line's baseline to this one, in points. Default is
     * 120%. Minimum value for percent or number is 0.</li>
     * <li><b>tracking</b> (Percent): Space added to the advance after each
     * character, as a percentage of the current point size. Percentages can be
     * negative, to bring characters closer together. Default is 0.</li>
     * <li><b>textDecoration</b> (String): [none, underline]: The decoration to
     * apply to the text. Default is none.</li>
     * <li><b>lineThrough</b> (Boolean): true if text has strikethrough applied,
     * false otherwise. Default is false.</li>
     * <li><b>color</b> (Color): The color of the text. Default is 0x000000.</li>
     * <li><b>textAlpha</b> (alpha): The alpha value applied to the text.
     * Default is 1.0.</li>
     * <li><b>whiteSpaceCollapse</b> (String): [preserve, collapse] This is an
     * enumerated value. A value of "collapse" converts line feeds, newlines,
     * and tabs to spaces and collapses adjacent spaces to one. Leading and
     * trailing whitespace is trimmed. A value of "preserve" passes whitespace
     * through unchanged.</li>
     * <li><b>lineBreak</b> (String): [toFit, explicit] This is an enumeration.
     * A value of "toFit" wraps the lines at the edge of the enclosing
     * TextGraphic. A value of "explicit" breaks the lines only at a Unicode
     * line end character (such as a newline or line separator). toFit is the
     * default.</li>
     * <li><b>kerning</b> (String): [on, off, auto] If on, pair kerns are
     * honored. If off, there is no font-based kerning applied. If auto,
     * kerning is applied to all characters except Kanji, Hiragana or Katakana.
     * The default is auto.</li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name
     * @param value - the attribute value
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.text.AbstractTextNode#addChild(FXGNode)
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
            fontStyle = value;
        }
        else if (FXG_FONTWEIGHT_ATTRIBUTE.equals(name))
        {
            fontWeight = value;
        }
        else if (FXG_LINEHEIGHT_ATTRIBUTE.equals(name))
        {
            lineHeight = DOMParserHelper.parsePercent(this, value, name);
        }
        else if (FXG_TEXTDECORATION_ATTRIBUTE.equals(name))
        {
            textDecoration = value;
        }
        else if (FXG_WHITESPACECOLLAPSE_ATTRIBUTE.equals(name))
        {
            whiteSpaceCollapse = getWhiteSpaceCollapse(this, value);
        }
        else if (FXG_LINEBREAK_ATTRIBUTE.equals(name))
        {
            lineBreak = getLineBreak(this, value);
        }
        else if (FXG_TRACKING_ATTRIBUTE.equals(name))
        {
            tracking = DOMParserHelper.parsePercent(this, value, name);
        }
        else if (FXG_KERNING_ATTRIBUTE.equals(name))
        {
            kerning = getKerning(this, value);
        }
        else if (FXG_TEXTALPHA_ATTRIBUTE.equals(name))
        {
            textAlpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, textAlpha);
         }
        else if (FXG_COLOR_ATTRIBUTE.equals(name))
        {
            color = DOMParserHelper.parseRGB(this, value, name);
        }
        else if (FXG_LINETHROUGH_ATTRIBUTE.equals(name))
        {
            lineThrough = DOMParserHelper.parseBoolean(this, value, name);
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
     * Convert an FXG String value to a Kerning enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching Kerning value.
     * 
     * @throws FXGException if the String did not match a known
     * Kerning value.
     */
    public static Kerning getKerning(FXGNode node, String value)
    {
        if (FXG_KERNING_AUTO_VALUE.equals(value))
            return Kerning.AUTO;
        else if (FXG_KERNING_ON_VALUE.equals(value))
            return Kerning.ON;
        else if (FXG_KERNING_OFF_VALUE.equals(value))
            return Kerning.OFF;
        else
        	//Exception: Unknown kerning: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownKerning", value);
    }

    /**
     * Convert an FXG String value to a LineBreak enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching LineBreak rule.
     * 
     * @throws FXGException if the String did not match a known
     * LineBreak rule.
     */
    public static LineBreak getLineBreak(FXGNode node, String value)
    {
        if (FXG_LINEBREAK_TOFIT_VALUE.equals(value))
            return LineBreak.TOFIT;
        else if (FXG_LINEBREAK_EXPLICIT_VALUE.equals(value))
            return LineBreak.EXPLICIT;
        else
        	//Exception:Unknown line break: {0}.
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownLineBreak", value);
    }

    /**
     * Convert an FXG String value to a WhiteSpaceCollapse enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching WhiteSpaceCollapse rule.
     * 
     * @throws FXGException if the String did not match a known
     * WhiteSpaceCollapse rule.
     */
    public static WhiteSpaceCollapse getWhiteSpaceCollapse(FXGNode node, String value)
    {
        if (FXG_WHITESPACE_PRESERVE_VALUE.equals(value))
            return WhiteSpaceCollapse.PRESERVE;
        else if (FXG_WHITESPACE_COLLAPSE_VALUE.equals(value))
            return WhiteSpaceCollapse.COLLAPSE;
        else
        	//Exception: Unknown white space collapse: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownWhiteSpaceCollapse", value);
    }

}
