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
import com.adobe.internal.fxg.dom.strokes.AbstractStrokeNode;
import com.adobe.internal.fxg.swf.ShapeHelper;

import flash.swf.types.LineStyle;
import flash.swf.types.Rect;
import flash.swf.types.ShapeRecord;

/**
 * @author Peter Farland
 */
public class LineNode extends AbstractShapeNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The x-axis starting point of the line. Defaults to 0. */
    public double xFrom = 0.0;
    
    /** The y-axis starting point of the line. Defaults to 0. */
    public double yFrom = 0.0;
    
    /** The x-axis ending point of the line. Defaults to 0. */
    public double xTo = 0.0;
    
    /** The y-axis ending point of the line. Defaults to 0. */
    public double yTo = 0.0;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a Line node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_LINE_ELEMENT;
    }

    /**
     * Set a attribute to this line node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>xFrom</b> (Number): The x-axis starting point of the line. 
     * Defaults to 0. </li>
     * <li><b>yFrom</b> (Number): The y-axis starting point of the line. 
     * Defaults to 0. </li>
     * <li><b>xTo</b> (Number): The x-axis ending point of the line. 
     * Defaults to 0. </li>
     * <li><b>yTo</b> (Number): The y-axis ending point of the line. 
     * Defaults to 0. </li>
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
        if (FXG_XFROM_ATTRIBUTE.equals(name))
            xFrom = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_YFROM_ATTRIBUTE.equals(name))
            yFrom = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_XTO_ATTRIBUTE.equals(name))
            xTo = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_YTO_ATTRIBUTE.equals(name))
            yTo = DOMParserHelper.parseDouble(this, value, name);
        else
            super.setAttribute(name, value);
    }
    
    /**
     * Returns the bounds of the line.
     * 
     * @param records the records
     * @param ls the line style
     * 
     * @return the bounds
     */
    public Rect getBounds(List<ShapeRecord> records, LineStyle ls)
    {
    	return ShapeHelper.getBounds(records, ls, (AbstractStrokeNode)stroke);
    }
}
