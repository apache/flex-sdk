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

package com.adobe.internal.fxg.dom.strokes;

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
 * The Class LinearGradientStrokeNode.
 * 
 * @author Peter Farland
 */
public class LinearGradientStrokeNode extends AbstractStrokeNode implements ScalableGradientNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The horizontal distance to translate the gradient. Default to NaN. */
    public double x = Double.NaN;
    
    /** The vertical distance to translate the gradient. Default to NaN. */
    public double y = Double.NaN;
    
    /** The horizontal distance of the unrotated gradient (that will be
     * compared to the target's width to calculate a scale ratio). */
    public double scaleX = Double.NaN;
    
    /** The vertical distance of the unrotated gradient (that will be
     * compared to the target's width to calculate a scale ratio). */
    private static final double scaleY = Double.NaN;
    
    /** The clockwise rotation angle in degrees. */
    public double rotation = 0.0;
    
    /** Indicate how to fill pixels outside the gradient vector. 
     * Defaults to pad. */
    public SpreadMethod spreadMethod = SpreadMethod.PAD;
    
    /** Indicate how to interpolate between entries of the gradient. 
     * Defaults to rgb. */
    public InterpolationMethod interpolationMethod = InterpolationMethod.RGB;

    private boolean translateSet;
    private boolean scaleSet;
    private boolean rotationSet;

    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    /** A pre-calculated matrix. */
    public MatrixNode matrix;
    
    /** A list of gradient entry nodes. */
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
     * scaleY is irrelevant to linear gradient stroke. Return value as NaN.
     * @return NaN
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
     * Adds an FXG child node to this node. Supported child nodes: 
     * &lt;matrix&gt;, &lt;GradientEntry&gt;. Cannot add a child matrix node if 
     * the discreet transform properties have been set. If there have been 
     * 15 child GradientEntryNode node added, this child node will be 
     * ignored and a message is logged.
     * 
     * @param child a FXG node
     * 
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof MatrixNode)
        {
            if (translateSet || scaleSet || rotationSet)
            	//Exception:Cannot supply a matrix child if transformation 
                //attributes were provided.
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
                //Log warning:A LinearGradientStroke cannot define more than 15 
                // GradientEntry elements - extra elements ignored.
                FXGLog.getLogger().log(FXGLogger.WARN, "InvalidLinearGradientStrokeNumElements", null, getDocumentName(), startLine, startColumn);
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
     * Gets the node name.
     * 
     * @return The unqualified name of a LinearGradientStroke node, without tag
     * markup.
     */
    public String getNodeName()
    {
        return FXG_LINEARGRADIENTSTROKE_ELEMENT;
    }

    /**
     * Set a attribute to this linear gradient stroke node. Delegates to the 
     * parent class to process attributes that are not in the list below.
     * <p>Stroke attributes include:
     * <ul>
     * <li><b>x</b> (Number): The horizontal translation of the gradient 
     * transform that defines the horizontal center of the gradient.</li>
     * <li><b>y</b> (Number): The horizontal translation of the gradient 
     * transform that defines the horizontal center of the gradient.</li>
     * <li><b>rotation</b> (Number): The rotation of the gradient transform.</li>
     * <li><b>scaleX</b> (Number): The horizontal scale of the gradient 
     * transform that defines the width of the (unrotated) gradient.</li>
     * <li><b>scaleY</b> (Number): The vertical scale of the gradient transform 
     * that defines the width of the (unrotated) gradient.</li>
     * <li><b>spreadMethod</b> (String): [pad, reflect, repeat]. How to choose 
     * the fill of pixels outside the gradient vector. Defaults to pad.</li>
     * <li><b>interpolationMethod</b> (String): [rgb, linearRGB): How to 
     * interpolate between entries of the gradient. Defaults to rgb.</li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.strokes.AbstractStrokeNode#setAttribute(java.lang.String, java.lang.String)
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
