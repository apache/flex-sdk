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

package com.adobe.internal.fxg.dom.filters;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.types.BevelType;

/**
 * The Class BevelFilterNode.
 * 
 * @author Peter Farland
 */
public class BevelFilterNode extends AbstractFilterNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The amount of blur applied to the rendered content in the horizontal. 
     * Defaults to 4. */
    public double blurX = 4.0;
    
    /** The amount of blur applied to the rendered content in the vertical. 
     * Defaults to 4. */
    public double blurY = 4.0;
    
    /** The quality of the rendered effect. Defaults to 1. Maximum is 3. */
    public int quality = 1;
    
    /** The angle of the generated drop shadow. This angle is expressed in 
     * document coordinate space. Defaults to 45. */
    public double angle = 45.0;
    
    /** The distance between each pixel in the source and its corresponding 
     * shadow in the output. Defaults to 4. */
    public double distance = 4.0;
    
    /** The transparency of the generated highlight color. Defaults to 1. */
    public double highlightAlpha = 1.0;
    
    /** The color of the generated highlight color. Defaults to #FFFFFF. */
    public int highlightColor = COLOR_WHITE;
    
    /** Renders the effect only where the value in the original content 
     * was 100% transparent. All other pixels are 100% transparent. 
     * Defaults to false. */
    public boolean knockout = false;
    
    /** The transparency of the generated shadow of the bevel. Defaults to 1. */
    public double shadowAlpha = 1.0;
    
    /** The color of the generated shadow of the bevel. Defaults to #000000. */
    public int shadowColor = COLOR_BLACK;
    
    /** The strength of the imprint or spread. The higher the value, the 
     * more color is imprinted and the stronger the contrast between the bevel 
     * and the background. Valid values are from 0 to 255.0. 
     * The default is 1.0. */
    public double strength = 1.0;
    
    /** The placement of the bevel on the object. Defaults to "inner". */
    public BevelType type = BevelType.INNER;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Gets the node name.
     * 
     * @return The unqualified name of a BevelFilter node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_BEVELFILTER_ELEMENT;
    }

    /** 
     * Set bevel filter properties. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>blurX</b> (Number): The amount of blur applied to the rendered 
     * content in the horizontal. </li>
     * <li><b>blurY</b> (Number): The amount of blur applied to the rendered 
     * content in the vertical. </li>
     * <li><b>quality</b> (Number): The quality of the rendered effect. 
     * Maximum is 3. </li>
     * <li><b>angle</b> (Number): The angle of the generated drop shadow. 
     * This angle is expressed in document coordinate space. </li>
     * <li><b>distance</b> (Number): The distance between each pixel in the 
     * source and its corresponding shadow in the output.<li>
     * <li><b>highlightAlpha</b> (Number): The transparency of the generated 
     * highlight color. </li>
     * <li><b>highlightColor</b> (Color): The color of the generated highlight 
     * color. Defaults to #FFFFFF. </li>
     * <li><b>knockout</b> (Boolean): Renders the effect only where the value 
     * in the original content was 100% transparent. All other pixels are 
     * 100% transparent. </li>
     * <li><b>shadowAlpha</b> (Number): The transparency of the generated 
     * shadow of the bevel. </li>
     * <li><b>shadowColor</b> (Color): The color of the generated shadow of 
     * the bevel. </li>
     * <li><b>strength</b> (Number): The strength of the imprint or spread. 
     * The higher the value, the more color is imprinted and the stronger 
     * the contrast between the bevel and the background. Valid values are 
     * from 0 to 255.0. </li>
     * <li><b>type</b> (String): The placement of the bevel on the object. 
     * Valid values: inner, outer, full. </li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_BLURX_ATTRIBUTE.equals(name))
            blurX = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_BLURY_ATTRIBUTE.equals(name))
            blurY = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_QUALITY_ATTRIBUTE.equals(name))
            quality = DOMParserHelper.parseInt(this, value, name, QUALITY_MIN_INCLUSIVE, QUALITY_MAX_INCLUSIVE, quality);
        else if (FXG_ANGLE_ATTRIBUTE.equals(name))
            angle = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_DISTANCE_ATTRIBUTE.equals(name))
            distance = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_HIGHLIGHTALPHA_ATTRIBUTE.equals(name))
            highlightAlpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, highlightAlpha);
        else if (FXG_HIGHLIGHTCOLOR_ATTRIBUTE.equals(name))
            highlightColor = DOMParserHelper.parseRGB(this, value, name);
        else if (FXG_KNOCKOUT_ATTRIBUTE.equals(name))
            knockout = DOMParserHelper.parseBoolean(this, value, name);
        else if (FXG_SHADOWALPHA_ATTRIBUTE.equals(name))
            shadowAlpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, shadowAlpha);
        else if (FXG_SHADOWCOLOR_ATTRIBUTE.equals(name))
            shadowColor = DOMParserHelper.parseRGB(this, value, name);
        else if (FXG_STRENGTH_ATTRIBUTE.equals(name))
            strength = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_TYPE_ATTRIBUTE.equals(name))
            type = getBevelType(value);
		else
			super.setAttribute(name, value);
    }
}