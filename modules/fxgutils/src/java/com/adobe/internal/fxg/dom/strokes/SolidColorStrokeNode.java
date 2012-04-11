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

package com.adobe.internal.fxg.dom.strokes;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.internal.fxg.dom.DOMParserHelper;

/**
 * The Class SolidColorStrokeNode.
 * 
 * @author Peter Farland
 */
public class SolidColorStrokeNode extends AbstractStrokeNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------
    
    /** An RGB value (in the form #RRGGBB) that defines the single color value 
     * to fill the shape with. Defaults to black #000000.*/
    public int color = COLOR_BLACK; 
    
    /** A real number value ranging from 0 to 1 specifying the opacity of 
     * the fill, with 1 being opaque. Defaults to 1.*/
    public double alpha = 1.0;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------
    
    /**
     * Gets the node name.
     * 
     * @return The unqualified name of a SolidColorStroke node, without tag
     * markup.
     */
    public String getNodeName()
    {
        return FXG_SOLIDCOLORSTROKE_ELEMENT;
    }

    /**
     * Set a attribute to this solid color stroke node. Delegates to the 
     * parent class to process attributes that are not in the list below.
     * <p>Stroke attributes include:
     * <ul>
     * <li><b>color</b> (Color): An RGB hexadecimal value (in the form #rrggbb) 
     * that defines the single color value to stroke the shape with. 
     * Defaults to #000000.</li>
     * <li><b>alpha</b> (Number): A number value ranging from 0 to 1 
     * specifying the opacity of the stroke, with 1 being opaque. 
     * Defaults to 1.</li>
     * </ul>
     * </p>
     * 
     * @param name the name
     * @param value the value
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.strokes.AbstractStrokeNode#setAttribute(java.lang.String, java.lang.String)
    */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_COLOR_ATTRIBUTE.equals(name))
            color = DOMParserHelper.parseRGB(this, value, name);
        else if (FXG_ALPHA_ATTRIBUTE.equals(name))
            alpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, alpha);
        else
            super.setAttribute(name, value);
    }
}