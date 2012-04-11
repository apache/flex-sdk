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

package com.adobe.internal.fxg.dom.fills;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.internal.fxg.dom.DOMParserHelper;

/**
 * @author Peter Farland
 */
public class SolidColorFillNode extends AbstractFillNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------
    
    /** An RGB value (in the form #RRGGBB) that 
     * defines the single color value to fill the shape with. 
     * Defaults to black "#000000". */
    public int color = COLOR_BLACK; 
    
    /** A real number value ranging from 0 to 1 
     * specifying the opacity of the fill, with 1 being opaque. 
     * Defaults to 1. */
    public double alpha = 1.0;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a SolidColor node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_SOLIDCOLOR_ELEMENT;
    }

    /**
     * Set solid color fill properties. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>alpha </b> (Number): A real number value ranging from 0 to 1 
     * specifying the opacity of the fill, with 1 being opaque. 
     * Defaults to 1. </li>
     * <li><b>color </b> (String): An RGB value (in the form #RRGGBB) that 
     * defines the single color value to fill the shape with. 
     * Defaults to "#000000". </li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.fills.AbstractFillNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_ALPHA_ATTRIBUTE.equals(name))
            alpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, alpha);
        else if (FXG_COLOR_ATTRIBUTE.equals(name))
            color = DOMParserHelper.parseRGB(this, value, name);
        else
            super.setAttribute(name, value);
    }
}
