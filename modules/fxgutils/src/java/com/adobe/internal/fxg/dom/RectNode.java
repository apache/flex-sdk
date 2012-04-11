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
public class RectNode extends AbstractShapeNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The width of the rectangle. A negative 
     * value is an error. Defaults to 0. */
    public double width = 0.0;
    
    /** The height of the rectangle. A negative 
     * value is an error. Defaults to 0. */
    public double height = 0.0;
    
    /** For rounded rectangles, a convenience 
     * property that sets the x-axis radius of the ellipse used to round off 
     * all four corners of the rectangle. A negative value is an error. 
     * Default to 0. */
    public double radiusX = 0.0;
    
    /** For rounded rectangles, a convenience 
    * property that sets the y-axis radius of the ellipse used to round off 
    * all four corners of the rectangle. A negative value is an error. 
    * Default to 0. */
    public double radiusY = 0.0;
    
    /** For rounded rectangles, set 
     * the x-axis radius of the top left corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). */
    public double topLeftRadiusX = Double.NaN;
    
    /** For rounded rectangles, set 
     * the y-axis radius of the top left corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). */
    public double topLeftRadiusY = Double.NaN;
    
    /** For rounded rectangles, set 
     * the x-axis radius of the top right corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). */    
    public double topRightRadiusY = Double.NaN;
    
    /** For rounded rectangles, set 
     * the y-axis radius of the top right corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). */
    public double topRightRadiusX = Double.NaN;
    
    /** For rounded rectangles, set 
     * the x-axis radius of the bottom right corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). */
    public double bottomRightRadiusX = Double.NaN;
    
    /** For rounded rectangles, set 
     * the y-axis radius of the bottom right corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). */
    public double bottomRightRadiusY = Double.NaN;
    
    /** For rounded rectangles, set 
     * the x-axis radius of the bottom left corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). */
    public double bottomLeftRadiusX = Double.NaN;
    
    /** For rounded rectangles, set 
     * the y-axis radius of the bottom left corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). */
    public double bottomLeftRadiusY = Double.NaN;    

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a Rect node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_RECT_ELEMENT;
    }

    /**
     * Set a attribute to this rect node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>width</b> (Number): The width of the rectangle. A negative 
     * value is an error. Defaults to 0. </li>
     * <li><b>height</b> (Number): The height of the rectangle. A negative 
     * value is an error. Defaults to 0. </li>
     * <li><b>radiusX</b> (Number): For rounded rectangles, a convenience 
     * property that sets the x-axis radius of the ellipse used to round off 
     * all four corners of the rectangle. A negative value is an error. 
     * Default to 0.</li>
     * <li><b>radiusY</b> (Number): For rounded rectangles, a convenience 
     * property that sets the y-axis radius of the ellipse used to round off 
     * all four corners of the rectangle. A negative value is an error. 
     * Default to 0.</li>
     * <li><b>topLeftRadiusX</b> (Number): For rounded rectangles, set 
     * the x-axis radius of the top left corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). </li>
     * <li><b>topLeftRadiusY</b> (Number): For rounded rectangles, set 
     * the y-axis radius of the top left corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). </li>
     * <li><b>topRightRadiusX</b> (Number): For rounded rectangles, set 
     * the x-axis radius of the top right corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). </li>
     * <li><b>topRightRadiusY</b> (Number): For rounded rectangles, set 
     * the y-axis radius of the top right corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). </li>
     * <li><b>bottomLeftRadiusX</b> (Number): For rounded rectangles, set 
     * the x-axis radius of the bottom left corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). </li>
     * <li><b>bottomLeftRadiusY</b> (Number): For rounded rectangles, set 
     * the y-axis radius of the bottom left corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). </li>
     * <li><b>bottomRightRadiusX</b> (Number): For rounded rectangles, set 
     * the x-axis radius of the bottom right corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). </li>
     * <li><b>bottomRightRadiusY</b> (Number): For rounded rectangles, set 
     * the y-axis radius of the bottom right corner. A negative value is 
     * an error. See the notes below about what happens if the attribute 
     * is not specified. Defaults to undefined (NaN). </li>
     * <li><b>data</b> (String): The definition of the outline of a shape. </li>
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
        {
            width = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_HEIGHT_ATTRIBUTE.equals(name))
        {
            height = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_RADIUSX_ATTRIBUTE.equals(name))
        {
            radiusX = DOMParserHelper.parseDouble(this, value, name);
            if (radiusX < 0) 
                // RadiusX, RadiusY, TopLeftRadiusX, TopLeftRadiusY, 
            	// TopRightRadiusX, TopRightRadiusY, BottomRightRadiusX, 
            	// BottomRightRadiusY, BottomLeftRadiusX, BottomLeftRadiusX 
            	// must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_RADIUSY_ATTRIBUTE.equals(name))
        {
            radiusY = DOMParserHelper.parseDouble(this, value, name);
            if (radiusY < 0)
                // RadiusX, RadiusY, TopLeftRadiusX, TopLeftRadiusY, 
            	// TopRightRadiusX, TopRightRadiusY, BottomRightRadiusX, 
            	// BottomRightRadiusY, BottomLeftRadiusX, BottomLeftRadiusX 
            	// must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_TOPLEFTRADIUSX_ATTRIBUTE.equals(name))
        {
        	topLeftRadiusX = DOMParserHelper.parseDouble(this, value, name);
            if (topLeftRadiusX < 0) 
                // RadiusX and RadiusY must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_TOPLEFTRADIUSY_ATTRIBUTE.equals(name))
        {
        	topLeftRadiusY = DOMParserHelper.parseDouble(this, value, name);
            if (topLeftRadiusY < 0)
                // RadiusX and RadiusY must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_TOPRIGHTRADIUSX_ATTRIBUTE.equals(name))
        {
        	topRightRadiusX = DOMParserHelper.parseDouble(this, value, name);
            if (topRightRadiusX < 0) 
                // RadiusX and RadiusY must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_TOPRIGHTRADIUSY_ATTRIBUTE.equals(name))
        {
        	topRightRadiusY = DOMParserHelper.parseDouble(this, value, name);
            if (topRightRadiusY < 0)
                // RadiusX and RadiusY must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_BOTTOMLEFTRADIUSX_ATTRIBUTE.equals(name))
        {
        	bottomLeftRadiusX = DOMParserHelper.parseDouble(this, value, name);
            if (bottomLeftRadiusX < 0) 
                // RadiusX and RadiusY must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_BOTTOMLEFTRADIUSY_ATTRIBUTE.equals(name))
        {
        	bottomLeftRadiusY = DOMParserHelper.parseDouble(this, value, name);
            if (bottomLeftRadiusY < 0)
                // RadiusX and RadiusY must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_BOTTOMRIGHTRADIUSX_ATTRIBUTE.equals(name))
        {
        	bottomRightRadiusX = DOMParserHelper.parseDouble(this, value, name);
            if (bottomRightRadiusX < 0) 
                // RadiusX and RadiusY must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else if (FXG_BOTTOMRIGHTRADIUSY_ATTRIBUTE.equals(name))
        {
            bottomRightRadiusY = DOMParserHelper.parseDouble(this, value, name);
            if (bottomRightRadiusY < 0)
                // RadiusX and RadiusY must be greater than 0.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidRectRadiusXRadiusYAttribute");
        }
        else
        {
            super.setAttribute(name, value);
        }
    }
    
    /**
     * Returns the bounds of the path.
     * 
     * @param records the records
     * @param ls the line style
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
