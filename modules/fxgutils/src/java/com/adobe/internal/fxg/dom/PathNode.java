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
import com.adobe.internal.fxg.dom.types.Winding;
import com.adobe.internal.fxg.swf.ShapeHelper;

import flash.swf.types.LineStyle;
import flash.swf.types.Rect;
import flash.swf.types.ShapeRecord;

/**
 * @author Peter Farland
 * @author Sujata Das
 * @author Min Plunkett
 */
public class PathNode extends AbstractShapeNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** Fill rule for intersecting or overlapping path segments. 
     * Valid values: "nonZero", "evenOdd". Defaults to "evenOdd". */
    public Winding winding = Winding.EVEN_ODD;
    
    /** The definition of the outline of a shape. */
    public String data = "";

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Set a attribute to this path node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>winding</b> (String): Fill rule for intersecting or overlapping 
     * path segments. Valid values: "nonZero", "evenOdd". 
     * Defaults to "evenOdd".</li>
     * <li><b>data</b> (String): The definition of the outline of a shape. </li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of valid range.
     * @see com.adobe.internal.fxg.dom.GraphicContentNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_WINDING_ATTRIBUTE.equals(name))
            winding = getWinding(value);
        else if (FXG_DATA_ATTRIBUTE.equals(name))
            data = value;
        else
            super.setAttribute(name, value);
    }

    /**
     * @return The unqualified name of a Path node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_PATH_ELEMENT;
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods
    //
    //--------------------------------------------------------------------------
    
    protected Winding getWinding(String value)
    {
        if (FXG_WINDING_EVENODD_VALUE.equals(value))
            return Winding.EVEN_ODD;
        else if (FXG_WINDING_NONZERO_VALUE.equals(value))
            return Winding.NON_ZERO;
        else
        	//Exception:Unknown winding value: {0}.
            throw new FXGException(getStartLine(), getStartColumn(), "UnknownWindingValue", value);
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
    	return ShapeHelper.getBounds(records, ls, (AbstractStrokeNode)stroke);
    }
}
