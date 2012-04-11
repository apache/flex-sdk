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
public class BlurFilterNode extends AbstractFilterNode
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

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a BlurFilter node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_BLURFILTER_ELEMENT;
    }

    /** 
     * Set blur filter properties. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>blurX</b> (Number): The amount of blur applied to the rendered 
     * content in the horizontal. </li>
     * <li><b>blurY</b> (Number): The amount of blur applied to the rendered 
     * content in the vertical. </li>
     * <li><b>quality</b> (Number): The quality of the rendered effect. 
     * Maximum is 3. </li>
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
		else
            super.setAttribute(name, value);
    }
}
