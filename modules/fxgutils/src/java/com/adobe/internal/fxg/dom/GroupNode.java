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

import java.util.ArrayList;
import java.util.List;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.types.ScalingGrid;

import static com.adobe.fxg.FXGConstants.*;

/**
 * @author Peter Farland
 */
public class GroupNode extends GraphicContentNode implements MaskingNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The distance from the origin of the left edge of the scale grid, 
     * in the group's own coordinate system. */
    public double scaleGridLeft = 0.0;
    
    /** The distance from the origin of the top edge of the scale grid, 
     * in the group's own coordinate system. */
    public double scaleGridTop = 0.0;

    /** The distance from the origin of the right edge of the scale grid, 
     * in the group's own coordinate system. */
    public double scaleGridRight = 0.0;
    
    /** The distance from the origin of the bottom edge of the scale grid, 
     * in the group's own coordinate system. */
    public double scaleGridBottom = 0.0;

    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    /** The children. */
    public List<GraphicContentNode> children;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Adds an FXG child node to this Group node.
     * 
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof GraphicContentNode)
        {
            if (children == null)
                children = new ArrayList<GraphicContentNode>();

            GraphicContentNode graphicContent = (GraphicContentNode)child;
            graphicContent.setParentGraphicContext(createGraphicContext());

            if (child instanceof GroupNode)
            {
                if (isInsideScaleGrid())
                {
                    // Exception:A child Group cannot exist in a Group that
                    // defines the scale grid
                    throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidScaleGridGroupChild");
                }
            }

            children.add(graphicContent);
        }
        else
        {
            super.addChild(child);
        }
    }

    /**
     * @return The unqualified name of a Group node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_GROUP_ELEMENT;
    }

    /**
     * Sets an FXG attribute on this Group node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>scaleGridLeft</b> (Number): The distance from the origin of the 
     * left edge of the scale grid, in the group's own coordinate system.</li>
     * <li><b>scaleGridTop</b> (Number): The distance from the origin of the 
     * top edge of the scale grid, in the group's own coordinate system.</li>
     * <li><b>scaleGridRight</b> (Number): The distance from the origin of the 
     * right edge of the scale grid, in the group's own coordinate system.</li>
     * <li><b>scaleGridBottom</b> (Number): The distance from the origin of the 
     * bottom edge of the scale grid, in the group's own coordinate system.</li>
     *  
     * @param name - the unqualified attribute name
     * @param value - the attribute value
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_SCALEGRIDLEFT_ATTRIBUTE.equals(name))
        {
            scaleGridLeft = DOMParserHelper.parseDouble(this, value, name);
            definesScaleGrid = true;
        }
        else if (FXG_SCALEGRIDTOP_ATTRIBUTE.equals(name))
        {
            scaleGridTop = DOMParserHelper.parseDouble(this, value, name);
            definesScaleGrid = true;
        }
        else if (FXG_SCALEGRIDRIGHT_ATTRIBUTE.equals(name))
        {
            scaleGridRight = DOMParserHelper.parseDouble(this, value, name);
            definesScaleGrid = true;
        }
        else if (FXG_SCALEGRIDBOTTOM_ATTRIBUTE.equals(name))
        {
            scaleGridBottom = DOMParserHelper.parseDouble(this, value, name);
            definesScaleGrid = true;
        }
        else
        {
            super.setAttribute(name, value);
        }

        if ((definesScaleGrid) && (this.rotationSet))
        {
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidScaleGridRotationAttribute");
        }

    }

    /**
     * Create graphic context. If a scale grid is defined, set it on the 
     * context.
     * 
     * @see com.adobe.internal.fxg.dom.GraphicContentNode#createGraphicContext()
     */
    @Override
    public GraphicContext createGraphicContext()
    {
        GraphicContext context = super.createGraphicContext();

        if (definesScaleGrid())
        {
            ScalingGrid scalingGrid = new ScalingGrid();
            scalingGrid.scaleGridLeft = scaleGridLeft;
            scalingGrid.scaleGridTop = scaleGridTop;
            scalingGrid.scaleGridRight = scaleGridRight;
            scalingGrid.scaleGridBottom = scaleGridBottom;
            context.scalingGrid = scalingGrid;
        }

        return context;
    }

    /**
     * Check whether a scaling grid is defined.
     * 
     * @return true, if a scaling grid is defined.
     */
    public boolean definesScaleGrid()
    {
        return definesScaleGrid;
    }

    /**
     * Check whether the current group is inside a scale grid or has a 
     * scale grid defined.
     * 
     * @return true, if inside a scale grid or has a scale grid defined.
     */
    public boolean isInsideScaleGrid()
    {
        return insideScaleGrid || definesScaleGrid;
    }

    /**
     * Sets the inside scale grid.
     * 
     * @param value the new inside scale grid
     */
    public void setInsideScaleGrid(boolean value)
    {
        insideScaleGrid = value;
    }

    private boolean definesScaleGrid;
    private boolean insideScaleGrid;

    //--------------------------------------------------------------------------
    //
    // MaskingNode Implementation
    //
    //--------------------------------------------------------------------------

    private int maskIndex;

    /**
     * @return the index of a mask in a parent DisplayObject's list of children.
     * This can be used to access the mask programmatically at runtime.
     */
    public int getMaskIndex()
    {
        return maskIndex;
    }

    /**
     * Records the index of this mask in the parent DisplayObject's list of
     * children. (Optional).
     * @param index - the child index to the mask  
     */
    public void setMaskIndex(int index)
    {
        maskIndex = index;
    }
}
