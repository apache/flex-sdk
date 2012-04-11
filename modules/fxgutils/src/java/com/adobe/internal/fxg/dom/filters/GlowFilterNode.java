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

/**
 * @author Peter Farland
 */
public class GlowFilterNode extends AbstractFilterNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------    
    /** The transparency of the generated effect. Default to 1.0. */
    public double alpha = 1.0;
    
    /** The amount of blur applied to the rendered content in the horizontal. 
     * Defaults to 4. */
    public double blurX = 4.0;
    
    /** The amount of blur applied to the rendered content in the vertical. 
     * Defaults to 4. */
    public double blurY = 4.0;
    
    /** The color of the glow. Default to red. */
    public int color = COLOR_RED;
        
    /** Specifies whether the glow is an inner glow. */
    public boolean inner = false;
    
    /** Renders the effect only where the value in the original content 
     * was 100% transparent. All other pixels are 100% transparent. 
     * Defaults to false. */
    public boolean knockout = false;
    
    /** The quality of the rendered effect. Defaults to 1. Maximum is 3. */
    public int quality = 1;
    
    /** The strength of the imprint or spread. The higher the value, the 
     * more color is imprinted and the stronger the contrast between the bevel 
     * and the background. Valid values are from 0 to 255.0. 
     * The default is 1.0. */
    public double strength = 1.0;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a GlowFilter node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_GLOWFILTER_ELEMENT;
    }

    /** 
     * Set glow shadow filter properties. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>alpha</b> (Number): The transparency of the generated effect. </li>
     * <li><b>blurX</b> (Number): The amount of blur applied to the rendered 
     * content in the horizontal. </li>
     * <li><b>blurY</b> (Number): The amount of blur applied to the rendered 
     * content in the vertical. </li>
     * <li><b>color</b> (Color): The color of the glow. </li>
     * <li><b>inner</b> (Boolean): Specifies whether the glow is an inner 
     * glow. </li>
     * <li><b>knockout</b> (Boolean): Renders the effect only where the value 
     * in the original content was 100% transparent. All other pixels are 
     * 100% transparent. </li>
     * <li><b>quality</b> (Number): The quality of the rendered effect. 
     * Maximum is 3. </li>
     * <li><b>strength</b> (Number): The strength of the imprint or spread. 
     * The higher the value, the more color is imprinted and the stronger 
     * the contrast between the bevel and the background. Valid values are 
     * from 0 to 255.0. </li>
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
        if (FXG_ALPHA_ATTRIBUTE.equals(name))
            alpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, alpha);
        else if (FXG_BLURX_ATTRIBUTE.equals(name))
            blurX = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_BLURY_ATTRIBUTE.equals(name))
            blurY = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_COLOR_ATTRIBUTE.equals(name))
            color = DOMParserHelper.parseRGB(this, value, name);
        else if (FXG_INNER_ATTRIBUTE.equals(name))
            inner = DOMParserHelper.parseBoolean(this, value, name);
        else if (FXG_KNOCKOUT_ATTRIBUTE.equals(name))
            knockout = DOMParserHelper.parseBoolean(this, value, name);
        else if (FXG_QUALITY_ATTRIBUTE.equals(name))
            quality = DOMParserHelper.parseInt(this, value, name, QUALITY_MIN_INCLUSIVE, QUALITY_MAX_INCLUSIVE, quality);
        else if (FXG_STRENGTH_ATTRIBUTE.equals(name))
            strength = DOMParserHelper.parseDouble(this, value, name);
        else
            super.setAttribute(name, value);
    }

}
