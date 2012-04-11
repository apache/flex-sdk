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
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.types.BaselineOffset;
import com.adobe.internal.fxg.dom.types.BlockProgression;
import com.adobe.internal.fxg.dom.types.LineBreak;
import com.adobe.internal.fxg.dom.types.NumberAuto;
import com.adobe.internal.fxg.dom.types.NumberInherit;
import com.adobe.internal.fxg.dom.types.VerticalAlign;
import com.adobe.internal.fxg.dom.types.BaselineOffset.BaselineOffsetAsEnum;
import com.adobe.internal.fxg.dom.types.NumberAuto.NumberAutoAsEnum;
import com.adobe.internal.fxg.dom.types.NumberInherit.NumberInheritAsEnum;

/**
 * An base class that represents a block text.
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public abstract class AbstractRichBlockTextNode extends AbstractRichParagraphNode
{    
    protected static final double PADDING_MIN_INCLUSIVE = 0.0;
    protected static final double PADDING_MAX_INCLUSIVE = 1000.0;
    protected static final double BASELINEOFFSET_MIN_INCLUSIVE = 0.0;
    protected static final double BASELINEOFFSET_MAX_INCLUSIVE = 1000.0;        
    protected static final int COLUMNCOUNT_MIN_INCLUSIVE = 0;
    protected static final int COLUMNCOUNT_MAX_INCLUSIVE = 50; 
    protected static final double COLUMNGAP_MIN_INCLUSIVE = 0.0;
    protected static final double COLUMNGAP_MAX_INCLUSIVE = 1000.0; 
    protected static final double COLUMNWIDTH_MIN_INCLUSIVE = 0.0;
    protected static final double COLUMNWIDTH_MAX_INCLUSIVE = 8000.0; 

    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

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
    
    /**
     * This implementation processes text flow extra attributes that are
     * relevant to the &lt;div&gt; tag, as well as delegates to the parent class
     * to process text leaf or paragraph attributes that are also relevant to
     * the &lt;div&gt; tag.
     * <p>
     * Container level attributes include:
     * <ul>
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
     * </ul>
     * </p>
     * 
     * @param name the attribute name
     * @param value the attribute value
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.richtext.AbstractRichParagraphNode#setAttribute(String, String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_BLOCKPROGRESSION_ATTRIBUTE.equals(name))
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
     * is out-of-range, the default value is returned.
     * @param node the FXG node
     * 
     * @return the matching BaselineOffset rule.
     * 
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
     * is out-of-range, the default value is returned.
     * @param errorCode - the error code if value is out-of-range.
     * @param node the FXG node
     * 
     * @return the matching NumberAuto rule.
     * 
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
     * is out-of-range, the default value is returned.
     * @param errorCode - the error code if value is out-of-range.
     * @param node the FXG node
     * 
     * @return the matching NumberAuto rule.
     * 
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
     * is out-of-range, the default value is returned.
     * @param errorCode - the error code if value is out-of-range.
     * @param node the FXG node
     * 
     * @return the matching NumberInherit rule.
     * 
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
}
