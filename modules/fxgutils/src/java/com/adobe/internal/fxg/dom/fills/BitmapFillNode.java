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
import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.transforms.MatrixNode;
import com.adobe.internal.fxg.dom.types.FillMode;

/**
 * @author Peter Farland
 * @author Sujata Das
 */
public class BitmapFillNode extends AbstractFillNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The horizontal translation of the transform that 
    * defines the horizontal center of the gradient. Default to Double.NaN. */
    public double x = Double.NaN;
    
    /** The vertical translation of the transform that ]
    * defines the vertical center of the gradient. Default to Double.NaN. */
    public double y = Double.NaN;
    
    /** Whether the image data should be tiled to fill the image rectangle, 
     * if necessary. Defaults to true. */
    public boolean repeat = true;
    
    /** The rotation of the transform. */
    public double rotation = 0.0;
    
    /** The horizontal scale of the transform that defines the width of 
     * the (unrotated) gradient. Default to Double.NaN. */
    public double scaleX = Double.NaN;
    
    /** The vertical scale of the transform that defines the width of the 
     * (unrotated) gradient. Default to Double.NaN. */
    public double scaleY = Double.NaN;
    
    /** A reference to the file containing the image data to use as fill. 
     * Required attribute. */
    public String source;
    
    /** Fill mode ("scale", "clip", "repeat") for the rest of pixels. 
     * Default is "scale". */
    public FillMode fillMode = FillMode.SCALE;

    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    /** Child matrix node */
    public MatrixNode matrix;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Add a child node to this BitmapFillNode. Supported child nodes: 
     * MatrixNode.
     * 
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof MatrixNode)
            matrix = (MatrixNode)child;
        else
            super.addChild(child);
    }

    /**
     * @return The unqualified name of a BitmapFill node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_BITMAPFILL_ELEMENT;
    }

    /**
     * Set bitmap fill properties. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>x</b> (Number): The horizontal translation of the transform that 
     * defines the horizontal center of the gradient. </li>
     * <li><b>y</b> (Number): The vertical translation of the transform that ]
     * defines the vertical center of the gradient. </li>
     * <li><b>repeat</b> (Boolean): Whether the image data should be tiled to 
     * fill the image rectangle, if necessary. Defaults to true. FXG Version 1.0.
     * <li><b>scaleX</b> (Number): The horizontal scale of the transform 
     * that defines the width of the (unrotated) gradient. </li>
     * <li><b>scaleY</b> (Number): The vertical scale of the transform that 
     * defines the width of the (unrotated) gradient. </li>
     * <li><b>rotation</b> (Number): The rotation of the transform. </li>
     * <li><b>source</b> (String): A reference to the file containing the image 
     * data to use as fill. Required attribute. </li>
     * <li><b>fillMode</b> (String) ("scale", "clip", "repeat"): Default 
     * is "scale". </li>
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
        if (FXG_X_ATTRIBUTE.equals(name))
            x = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_Y_ATTRIBUTE.equals(name))
            y = DOMParserHelper.parseDouble(this, value, name);
        else if ((getFileVersion().equalTo(FXGVersion.v1_0)) && (FXG_REPEAT_ATTRIBUTE.equals(name)))
            repeat = DOMParserHelper.parseBoolean(this, value, name);
        else if (FXG_ROTATION_ATTRIBUTE.equals(name))
            rotation = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_SCALEX_ATTRIBUTE.equals(name))
            scaleX = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_SCALEY_ATTRIBUTE.equals(name))
            scaleY = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_SOURCE_ATTRIBUTE.equals(name))
            source = value;
        else if (!(getFileVersion().equalTo(FXGVersion.v1_0)) && (FXG_FILLMODE_ATTRIBUTE.equals(name)))
            fillMode = DOMParserHelper.parseFillMode(this, value, name, fillMode);
        else
            super.setAttribute(name, value);
    }
    
}
