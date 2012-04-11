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
 * A GroupDefinition represents the special use of Group as the basis for an
 * FXG Library Definition. It acts as the base graphic context for a symbol
 * definition. A GroupDefinition differs from a Group instance in that it
 * cannot define a transform, filters or have an id attribute.
 * 
 * @author Peter Farland
 */
public class GroupDefinitionNode extends AbstractFXGNode
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
     * Add a child node. An exception is thrown if the child node is not  
     * a GraphicContentNode or a child is a group and the current group 
     * has scale grid defined.
     * 
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof GraphicContentNode)
        {
            if (child instanceof TextGraphicNode)
                textCount++;

            if (children == null)
                children = new ArrayList<GraphicContentNode>();

            children.add((GraphicContentNode)child);
        
            if (child instanceof GroupNode)
            {
                if (definesScaleGrid())
                {
                    // Exception:A child Group cannot exist in a Group that
                    // defines the scale grid
                    throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidScaleGridGroupChild");
                }
            }
        }
        else
        {
            super.addChild(child);
        }
    }

    /**
     * {@inheritDoc}
     */
    public String getNodeName()
    {
        return FXG_GROUP_ELEMENT;
    }

    /**
     * Set a attribute to this group definition node. Delegates to the parent 
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
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
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
        else if (FXG_ID_ATTRIBUTE.equals(name))
        {
        	//Exception:The id attribute is not allowed on the Group child a Definition.
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidGroupIDAttribute");
        }
        else
        {
            super.setAttribute(name, value);
        }
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Gets the scaling grid.
     * 
     * @return the scaling grid
     */
    public ScalingGrid getScalingGrid()
    {
        ScalingGrid scalingGrid = null;

        if (definesScaleGrid())
        {
            scalingGrid = new ScalingGrid();
            scalingGrid.scaleGridLeft = scaleGridLeft;
            scalingGrid.scaleGridTop = scaleGridTop;
            scalingGrid.scaleGridRight = scaleGridRight;
            scalingGrid.scaleGridBottom = scaleGridBottom;
        }

        return scalingGrid;
    }

    /**
     * Check whether a scaling grid is defined.
     * 
     * @return true, if a scaling grid is defined
     */
    public boolean definesScaleGrid()
    {
        return definesScaleGrid;
    }

    /**
     * Gets the text node count.
     * 
     * @return the text count
     */
    public int getTextCount()
    {
        return textCount;
    }

    private boolean definesScaleGrid;
    private int textCount;}
