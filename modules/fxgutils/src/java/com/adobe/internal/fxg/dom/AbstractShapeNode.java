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

import java.util.List;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;

import flash.swf.types.LineStyle;
import flash.swf.types.Rect;
import flash.swf.types.ShapeRecord;

/**
 * A base class for all FXG nodes that represent a stroke.
 * 
 * @author Peter Farland
 * @author Sujata Das
 */
public abstract class AbstractShapeNode extends GraphicContentNode
{
    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    /** Child fill node */
    public FillNode fill;
    
    /** Child stroke node */
    public StrokeNode stroke;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Add a child node to this shape node. Supported child nodes: 
     * &lt;fill&gt;, &lt;stroke&gt;.
     * 
     * @param child a FXG node
     * 
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.GraphicContentNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof FillNode)
            fill = (FillNode)child;
        else if (child instanceof StrokeNode)
            stroke = (StrokeNode)child;
        else
            super.addChild(child);
    }
    
    /**
     * Returns the bounds of the shapes.
     * Default implementation - to be overridden by individual classes.
     * 
     * @param records the records
     * @param ls the ls
     * 
     * @return the bounds
     */
    public Rect getBounds(List<ShapeRecord> records, LineStyle ls)
    {
    	return null;
    }
}
