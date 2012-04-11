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

import java.util.ArrayList;
import java.util.List;

import static com.adobe.fxg.FXGConstants.*;
import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.util.FXGLog;
import com.adobe.fxg.util.FXGLogger;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.GradientEntryNode;
import com.adobe.internal.fxg.dom.ScalableGradientNode;
import com.adobe.internal.fxg.dom.transforms.MatrixNode;
import com.adobe.internal.fxg.dom.types.InterpolationMethod;
import com.adobe.internal.fxg.dom.types.SpreadMethod;

/**
 * @author Peter Farland
 */
public class LinearGradientFillNode extends AbstractFillNode implements ScalableGradientNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------
    
    /** The horizontal translation of the gradient transform. */
    public double x = Double.NaN;
    
    /** The vertical translation of the gradient transform. */
    public double y = Double.NaN;
    
    /** The horizontal scale of the gradient transform that defines the 
     * width of the (unrotated) gradient. */
    public double scaleX = Double.NaN;
    
    private static final double scaleY = Double.NaN;
    
    /** The rotation of the transform. */
    public double rotation = 0.0;
    
    /** How to choose the fill of pixels outside the gradient vector. Default 
     * to "pad". */
    public SpreadMethod spreadMethod = SpreadMethod.PAD;
    
    /** How to interpolate between entries of the gradient. Default to "rgb". */
    public InterpolationMethod interpolationMethod = InterpolationMethod.RGB;

    private boolean translateSet;
    private boolean scaleSet;
    private boolean rotationSet;
    
    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    /** Child matrix node */
    public MatrixNode matrix;
    
    /** List of child gradient entry. */
    public List<GradientEntryNode> entries;

    //--------------------------------------------------------------------------
    //
    // ScalableGradientNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * {@inheritDoc}
     */
    public double getX()
    {
        return x;
    }

    /**
     * {@inheritDoc}
     */
    public double getY()
    {
        return y;
    }

    /**
     * {@inheritDoc}
     */
    public double getScaleX()
    {
         return scaleX;
    }

    /**
     * {@inheritDoc}
     */
    public double getScaleY()
    {
        return scaleY;
    }

    /**
     * {@inheritDoc}
     */
    public double getRotation()
    {
        return rotation;
    }

    /**
     * {@inheritDoc}
     */
    public MatrixNode getMatrixNode()
    {
        return matrix;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isLinear()
    {
        return true;
    }
    
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------
    
    /**
     * Adds a child node to this node. Supported child nodes: 
     * MatrixNode, GradientEntryNode. A warning is logged when more than 
     * 15 GradientEntry node is added. The extra child is ignored.
     * 
     * @param child - a child FXG node to be added to this node.

     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof MatrixNode)
        {
            if (translateSet || scaleSet || rotationSet)
            	//Exception:Cannot supply a matrix child if transformation attributes were provided.
                throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidChildMatrixNode");

            matrix = (MatrixNode)child;
        }
        else if (child instanceof GradientEntryNode)
        {
            if (entries == null)
            {
                entries = new ArrayList<GradientEntryNode>(4);
            }
            else if (entries.size() >= GRADIENT_ENTRIES_MAX_INCLUSIVE)
            {
                //Log warning:A LinearGradient cannot define more than 15 GradientEntry elements - extra elements ignored.
                FXGLog.getLogger().log(FXGLogger.WARN, "InvalidLinearGradientNumElements", null, getDocumentName(), startLine, startColumn);
                return;
            }

            entries.add((GradientEntryNode)child);
        }
        else
        {
            super.addChild(child);
        }
    }

    /**
     * @return The unqualified name of a LinearGradient node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_LINEARGRADIENT_ELEMENT;
    }

    /**
     * Set linear gradient fill properties. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>x</b> (Number): The horizontal translation of the gradient 
     * transform. </li>
     * <li><b>y</b> (Number): The vertical translation of the gradient 
     * transform. </li>
     * <li><b>scaleX</b> (Number): The horizontal scale of the transform 
     * that defines the width of the (unrotated) gradient. </li>
     * <li><b>rotation</b> (Number): The rotation of the transform. </li>
     * <li><b>spreadMethod </b> (String) ("pad", "reflect", "repeat"): How to 
     * choose the fill of pixels outside the gradient vector. </li>
     * <li><b>interpolationMethod </b> (String) ("rgb", "linearRGB"): How to 
     * interpolate between entries of the gradient. </li>
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
        {
            x = DOMParserHelper.parseDouble(this, value, name);
            translateSet = true;
        }
        else if (FXG_Y_ATTRIBUTE.equals(name))
        {
            y = DOMParserHelper.parseDouble(this, value, name);
            translateSet = true;
        }
        else if (FXG_ROTATION_ATTRIBUTE.equals(name))
        {
            rotation = DOMParserHelper.parseDouble(this, value, name);
            rotationSet = true;
        }
        else if (FXG_SCALEX_ATTRIBUTE.equals(name))
        {
            scaleX = DOMParserHelper.parseDouble(this, value, name);
            scaleSet = true;
        }
        else if (FXG_SPREADMETHOD_ATTRIBUTE.equals(name))
        {
            spreadMethod = DOMParserHelper.parseSpreadMethod(this, value, name, spreadMethod);
        }
        else if (FXG_INTERPOLATIONMETHOD_ATTRIBUTE.equals(name))
        {
            interpolationMethod = DOMParserHelper.parseInterpolationMethod(this, value, name, interpolationMethod);
        }
        else
        {
            super.setAttribute(name, value);
        }
    }

}
