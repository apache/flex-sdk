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

import java.util.List;

import com.adobe.fxg.FXGException;

import flash.swf.SwfConstants;
import flash.swf.types.LineStyle;
import flash.swf.types.Rect;
import flash.swf.types.ShapeRecord;

/**
 * @author Peter Farland
 * @author Sujata Das
 */
public class EllipseNode extends AbstractShapeNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The x-axis length of the ellipse path bounding rectangle. 
     * Defaults to 0.
     */
    public double width = 0.0;
    
    /** The y-axis length of the ellipse path 
     * bounding rectangle. Defaults to 0. */
    public double height = 0.0;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of an Ellipse node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_ELLIPSE_ELEMENT;
    }

    /**
     * Set definition properties. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>width</b> (Number): The x-axis length of the ellipse path 
     * bounding rectangle. Defaults to 0.</li>
     * <li><b>height</b> (Number): The y-axis length of the ellipse path 
     * bounding rectangle. Defaults to 0.</li>
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
        else
            super.setAttribute(name, value);
    }
    
    /**
     * Returns the bounds of the ellipse.
     * 
     * @param records the records
     * @param ls the ls
     * 
     * @return the bounds
     */
    public Rect getBounds(List<ShapeRecord> records, LineStyle ls)
    {
        int x1 = 0;
        int y1 = 0;
        int x2 = (int) (width*SwfConstants.TWIPS_PER_PIXEL);
        int y2 = (int) (height*SwfConstants.TWIPS_PER_PIXEL);
        if (ls != null)
        {
            int width = SwfConstants.TWIPS_PER_PIXEL;
            if (width < ls.width)
            	width = ls.width;
            int stroke = (int)Math.rint(width / 2.0);
            x1 = x1 - stroke;
            y1 = y1 - stroke;
            x2 = x2 + stroke;
            y2 = y2 + stroke;
        }
 
        return new Rect(x1, x2, y1, y2);
    }
}
