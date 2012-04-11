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
import com.adobe.fxg.FXGVersion;
import com.adobe.internal.fxg.dom.types.FillMode;

/**
 * @author Peter Farland
 * @author Sujata Das
 */
public class BitmapGraphicNode extends GraphicContentNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The width of the image rectangle, in the parent coordinate system. */
    public double width = Double.NaN;
    
    /** The height of the image rectangle, in the parent coordinate system. */
    public double height = Double.NaN;
    
    /** An embedded reference to the file defining the image data to render. 
     * Must be a PNG, JPG, or GIF file. Required attribute. */
    public String source;
    
    /** Whether the image data should be tiled to 
     * fill the image rectangle, if necessary. Defaults to true. */
    public boolean repeat = true;
    
    /** Controls how it fills the rectangle defined by the width and height 
     * of the BitmapImage. Defaults to "scale". */
    public FillMode fillMode = FillMode.SCALE;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a BitmapGraphic node, without tag markup.
     */
    public String getNodeName()
    {
    	if (this.getFileVersion().equals(FXGVersion.v1_0) )
    		return FXG_BITMAPGRAPHIC_ELEMENT;
    	else
    		return FXG_BITMAPIMAGE_ELEMENT;
    }

    /**
     * Set a attribute to this BitmapGraphic node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>width</b> (Number): The width of the image rectangle, in the 
     * parent coordinate system. </li>
     * <li><b>height</b> (Number): The height of the image rectangle, in the 
     * parent coordinate system. </li>
     * <li><b>repeat</b> (Boolean): Whether the image data should be tiled to 
     * fill the image rectangle, if necessary. Defaults to true.</li>
     * <li><b>source</b> (String): An embedded reference to the file defining 
     * the image data to render. Must be a PNG, JPG, or GIF file. 
     * Required attribute.</li>
     * <li><b>fillMode</b> (String) ("scale", "clip", "repeat"): Controls how 
     * it fills the rectangle defined by the width and height of the 
     * BitmapImage. Defaults to "scale". </li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.GraphicContentNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_WIDTH_ATTRIBUTE.equals(name))
            width = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_HEIGHT_ATTRIBUTE.equals(name))
            height = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_SOURCE_ATTRIBUTE.equals(name))
            source = value;
        else if ((getFileVersion().equalTo(FXGVersion.v1_0)) && (FXG_REPEAT_ATTRIBUTE.equals(name)))
            repeat = DOMParserHelper.parseBoolean(this, value, name);
        else if (!(getFileVersion().equalTo(FXGVersion.v1_0)) && (FXG_FILLMODE_ATTRIBUTE.equals(name)))
            fillMode = DOMParserHelper.parseFillMode(this, value, name, fillMode);
        else
            super.setAttribute(name, value);
    }
    
}
