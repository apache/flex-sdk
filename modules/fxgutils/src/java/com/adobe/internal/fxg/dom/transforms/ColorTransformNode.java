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

package com.adobe.internal.fxg.dom.transforms;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.internal.fxg.dom.DOMParserHelper;

/**
 * The Class ColorTransformNode.
 * 
 * @author Peter Farland
 */
public class ColorTransformNode extends AbstractTransformNode implements Cloneable
{
    private static final double MIN_OFFSET_INCLUSIVE = -255.0;
    private static final double MAX_OFFSET_INCLUSIVE = 255.0;

    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** A decimal value that is multiplied with the alpha transparency channel 
     * value. Defaults to 1. */
    public double alphaMultiplier = 1.0;
    
    /** A decimal value that is multiplied with the red transparency channel 
     * value. Defaults to 1. */
    public double redMultiplier = 1.0;
    
    /** A decimal value that is multiplied with the blue transparency channel 
     * value. Defaults to 1. */
    public double blueMultiplier = 1.0;
    
    /** A decimal value that is multiplied with the green transparency channel 
     * value. Defaults to 1. */
    public double greenMultiplier = 1.0;
    
    /** A number from -255 to 255 that is added to the alpha transparency 
     * channel value after it has been multiplied by the alphaMultiplier value. 
     * Defaults to 0.*/
    public double alphaOffset = 0.0;
    
    /** A number from -255 to 255 that is added to the red transparency 
     * channel value after it has been multiplied by the redMultiplier value. 
     * Defaults to 0. */
    public double redOffset = 0.0;
    
    /** A number from -255 to 255 that is added to the blue transparency 
     * channel value after it has been multiplied by the blueMultiplier value. 
     * Defaults to 0.*/
    public double blueOffset = 0.0;
    
    /** A number from -255 to 255 that is added to the green transparency 
     * channel value after it has been multiplied by the greenMultiplier value. 
     * Defaults to 0.*/
    public double greenOffset = 0.0;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Gets the node name.
     * 
     * @return The unqualified name of a ColorTransform node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_COLORTRANSFORM_ELEMENT;
    }

    /**
     * Set color transform properties. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>alphaMultiplier</b> (Number): A decimal value that is multiplied 
     * with the alpha transparency channel value. Defaults to 1.</li>
     * <li><b>redMultiplier</b> (Number): A decimal value that is multiplied 
     * with the red transparency channel value. Defaults to 1. </li>
     * <li><b>blueMultiplier</b> (Number): A decimal value that is multiplied 
     * with the blue transparency channel value. Defaults to 1. </li>
     * <li><b>greenMultiplier</b> (Number): A decimal value that is multiplied 
     * with the green transparency channel value. Defaults to 1. </li>
     * <li><b>alphaOffset</b> (Number): A number from -255 to 255 that is 
     * added to the alpha transparency channel value after it has been 
     * multiplied by the alphaMultiplier value. Defaults to 0.</li>
     * <li><b>redOffset</b> (Number): A number from -255 to 255 that is added 
     * to the red transparency channel value after it has been multiplied 
     * by the redMultiplier value. Defaults to 0.</li>
     * <li><b>blueOffset</b> (Number): A number from -255 to 255 that is added 
     * to the blue transparency channel value after it has been multiplied 
     * by the blueMultiplier value. Defaults to 0.</li>
     * <li><b>greenOffset</b> (Number): A number from -255 to 255 that is added 
     * to the green transparency channel value after it has been multiplied 
     * by the greenMultiplier value. Defaults to 0.</li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.transforms.AbstractTransformNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_ALPHAMULTIPLIER_ATTRIBUTE.equals(name))
            alphaMultiplier = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_REDMULTIPLIER_ATTRIBUTE.equals(name))
            redMultiplier = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_BLUEMULTIPLIER_ATTRIBUTE.equals(name))
            blueMultiplier = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_GREENMULTIPLIER_ATTRIBUTE.equals(name))
            greenMultiplier = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_ALPHAOFFSET_ATTRIBUTE.equals(name))
            alphaOffset = DOMParserHelper.parseDouble(this, value, name, MIN_OFFSET_INCLUSIVE, MAX_OFFSET_INCLUSIVE, alphaOffset);
        else if (FXG_REDOFFSET_ATTRIBUTE.equals(name))
            redOffset = DOMParserHelper.parseDouble(this, value, name, MIN_OFFSET_INCLUSIVE, MAX_OFFSET_INCLUSIVE, redOffset);
        else if (FXG_BLUEOFFSET_ATTRIBUTE.equals(name))
            blueOffset = DOMParserHelper.parseDouble(this, value, name, MIN_OFFSET_INCLUSIVE, MAX_OFFSET_INCLUSIVE, blueOffset);
        else if (FXG_GREENOFFSET_ATTRIBUTE.equals(name))
            greenOffset = DOMParserHelper.parseDouble(this, value, name, MIN_OFFSET_INCLUSIVE, MAX_OFFSET_INCLUSIVE, greenOffset);
    }

    //--------------------------------------------------------------------------
    //
    // Cloneable Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Get a clone of the current ColorTransform node.
     * 
     * @return cloned object
     */
    public Object clone()
    {
        ColorTransformNode copy = null;
        try
        {
            copy = (ColorTransformNode)super.clone();
            copy.alphaMultiplier = alphaMultiplier;
            copy.redMultiplier = redMultiplier;
            copy.blueMultiplier = blueMultiplier;
            copy.greenMultiplier = greenMultiplier;
            copy.alphaOffset = alphaOffset;
            copy.redOffset = redOffset;
            copy.blueOffset = blueOffset;
            copy.greenOffset = greenOffset;
        }
        catch (CloneNotSupportedException e)
        {
            throw new FXGException(getStartLine(), getStartColumn(), "InternalProcessingError", e);
       }
 
        return copy;
    }
}
