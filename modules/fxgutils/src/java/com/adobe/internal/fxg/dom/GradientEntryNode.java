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

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;

/**
 * @author Peter Farland
 */
public class GradientEntryNode extends AbstractFXGNode
{
    private static final double RATIO_MIN_INCLUSIVE = 0.0;
    private static final double RATIO_MAX_INCLUSIVE = 1.0;

    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** An RGB value specifying the color that 
     * should be used at that point in the gradient. Defaults to #000000. */
    public int color = COLOR_BLACK;
    
    /** A number from 0-1 specifying the opacity 
     * that should be used at that point in the gradient. Defaults to 1. */
    public double alpha = 1.0;
    
    /** A value from 0-1 specifying where on the gradient the entry 
     * should be pinned. This attribute is required. */
    public double ratio = Double.NaN;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a GradientEntry node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_GRADIENTENTRY_ELEMENT;
    }

    /**
     * Set gradient entry properties. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>color</b> (String): An RGB value specifying the color that 
     * should be used at that point in the gradient. Defaults to #000000. </li>
     * <li><b>alpha</b> (Number): A number from 0-1 specifying the opacity 
     * that should be used at that point in the gradient. Defaults to 1.</li>
     * <li><b>A value from 0-1 specifying where on the gradient the entry 
     * should be pinned. This attribute is required.</li>
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
        if (FXG_COLOR_ATTRIBUTE.equals(name))
            color = DOMParserHelper.parseRGB(this, value, name);
        else if (FXG_ALPHA_ATTRIBUTE.equals(name))
            alpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, alpha);
        else if (FXG_RATIO_ATTRIBUTE.equals(name))
            ratio = DOMParserHelper.parseDouble(this, value, name, RATIO_MIN_INCLUSIVE, RATIO_MAX_INCLUSIVE, ratio);
        else
            super.setAttribute(name, value);
    }
}
