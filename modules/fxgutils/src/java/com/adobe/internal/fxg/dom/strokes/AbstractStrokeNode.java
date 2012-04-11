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

import static com.adobe.fxg.FXGConstants.*;
import com.adobe.fxg.FXGException;
import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.AbstractFXGNode;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.GraphicNode;
import com.adobe.internal.fxg.dom.StrokeNode;
import com.adobe.internal.fxg.dom.types.Caps;
import com.adobe.internal.fxg.dom.types.Joints;
import com.adobe.internal.fxg.dom.types.ScaleMode;

/**
 * Base class for all FXG stroke nodes.
 * 
 * @author Peter Farland
 */
public abstract class AbstractStrokeNode extends AbstractFXGNode implements StrokeNode
{
    protected static final double MITERLIMIT_MIN_INCLUSIVE = 1.0;
    protected static final double MITERLIMIT_MAX_INCLUSIVE = 255.0;
    protected static final double WEIGHT_MIN_INCLUSIVE = 0.0;
    protected static final double WEIGHT_MAX_INCLUSIVE = 255.0;

    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    //------------
    // id
    //------------

    protected String id;

    /**
     * An id attribute provides a well defined name to a content node.
     * 
     * @return id as a string.
     */
    public String getId()
    {
        return id;
    }

    /**
     * Sets the node id.
     * 
     * @param value - the node id as a String.
     */
    public void setId(String value)
    {
        id = value;
    }

    /** A value that specifies which scale mode to use. Defaults to "normal". */
    public ScaleMode scaleMode = ScaleMode.NORMAL;
    
    /** Specifies the type of caps at the end of lines. Defaults to round. */
    public Caps caps = Caps.ROUND;
    
    /** Specifies whether to hint strokes to full pixels. This value affects 
     * both the position of anchors of a curve and the line stroke size itself. 
     * Defaults to false. */
    public boolean pixelHinting = false;
    
    /** A value that specifies which scale mode to use. Defaults to "normal". */
    public Joints joints = Joints.ROUND;
    
    /** Indicates the limit at which a miter is cut off. Valid values range 
     * from 1 to 255. Defaults to 3.*/
    public double miterLimit = 3.0;
    
    private double weight = Double.NaN;
    protected double weight_v_1 = 0.0;
    protected double weight_v_1_later = 1.0;
    
    /**
     * Stroke weight. Default value is FXG Version specific.
     * FXG 1.0 - default "0.0"
     * FXG 2.0 - default "2.0"
     * 
     * @return the weight
     */
    public double getWeight()
    {
    	if (Double.isNaN(weight))
    	{
        	if (((GraphicNode)this.getDocumentNode()).getVersion().equals(FXGVersion.v1_0))
        		weight = weight_v_1;       
        	else
        		weight = weight_v_1_later;
    	}
    	return weight;
    }
    
    /**
     * Get scaleX.
     * 
     * @return Double.NaN as default.
     */
    public double getScaleX()
    {
        return Double.NaN;
    }

    /**
     * Get scaleY.
     * 
     * @return Double.NaN as default.
     */
    public double getScaleY()
    {
        return Double.NaN;
    }
    
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Sets an FXG attribute on this stroke node. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Stroke attributes include:
     * <ul>
     * <li><b>scaleMode</b> (String): [none, vertical, normal, horizontal] This 
     * is an enumerated value.</li>
     * <li><b>caps</b> (String): [round, square, none] This is an enumerated 
     * value.</li>
     * <li><b>weight</b> (Number): The stroke weight. Defaults to 0.0 for version 
     * 1.0 and 1.0 for version since 2.0. Valid values range from 0 to 255.</li>
     * <li><b>pixelHinting</b> (Boolean): Specifies whether to hint strokes to 
     * full pixels. This value affects both the position of anchors of a curve 
     * and the line stroke size itself. Defaults to false.</li>
     * <li><b>joints</b> (String): [round, miter, bevel] This is an enumerated 
     * value.</li>
     * <li><b>miterLimit</b> (Number): Indicates the limit at which a miter is 
     * cut off. Valid values range from 1 to 255. Defaults to 3.</li>
     * <li><b>id</b> (String): Indicates the limit at which a miter is 
     * cut off. Valid values range from 1 to 255. Defaults to 3.</li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#addChild(FXGNode)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_SCALEMODE_ATTRIBUTE.equals(name))
            scaleMode = getScaleMode(value);
        else if (FXG_CAPS_ATTRIBUTE.equals(name))
            caps = getCaps(value);
        else if (FXG_WEIGHT_ATTRIBUTE.equals(name))
            weight = DOMParserHelper.parseDouble(this, value, name, WEIGHT_MIN_INCLUSIVE, WEIGHT_MAX_INCLUSIVE, weight);
        else if (FXG_PIXELHINTING_ATTRIBUTE.equals(name))
            pixelHinting = DOMParserHelper.parseBoolean(this, value, name);
        else if (FXG_JOINTS_ATTRIBUTE.equals(name))
            joints = getJoints(value);
        else if (FXG_MITERLIMIT_ATTRIBUTE.equals(name))
            miterLimit = DOMParserHelper.parseDouble(this, value, name, MITERLIMIT_MIN_INCLUSIVE, MITERLIMIT_MAX_INCLUSIVE, miterLimit);
        else if (FXG_ID_ATTRIBUTE.equals(name))
            id = value;
        else
            super.setAttribute(name, value);
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Convert an FXG String value to a Caps enumeration.
     * 
     * @param value - the FXG String value.
     * @return the matching Caps type.
     * @throws FXGException if the String did not match a known
     * Caps type.
     */
    protected Caps getCaps(String value)
    {
        if (FXG_CAPS_ROUND_VALUE.equals(value))
            return Caps.ROUND;
        else if (FXG_CAPS_SQUARE_VALUE.equals(value))
            return Caps.SQUARE;
        else if (FXG_CAPS_NONE_VALUE.equals(value))
            return Caps.NONE;
        else
        	//Exception:Unsupported caps setting {0}.
            throw new FXGException(getStartLine(), getStartColumn(), "UnsupportedCapsSetting", value);
    }

    /**
     * Convert an FXG String value to a Joints enumeration.
     * 
     * @param value - the FXG String value.
     * @return the matching Joints type.
     * @throws FXGException if the String did not match a known
     * Joints type.
     */
    protected Joints getJoints(String value)
    {
        if (FXG_JOINTS_ROUND_VALUE.equals(value))
            return Joints.ROUND;
        if (FXG_JOINTS_MITER_VALUE.equals(value))
            return Joints.MITER;
        if (FXG_JOINTS_BEVEL_VALUE.equals(value))
            return Joints.BEVEL;
        else
        	//Exception: Unsupported joints setting: {0}.
            throw new FXGException(getStartLine(), getStartColumn(), "UnsupportedJointsSetting", value);
    }

    /**
     * Convert an FXG String value to a ScaleMode enumeration.
     * 
     * @param value - the FXG String value.
     * @return the matching ScaleMode.
     * @throws FXGException if the String did not match a known
     * ScaleMode.
     */
    protected ScaleMode getScaleMode(String value)
    {
        if (FXG_SCALEMODE_NONE_VALUE.equals(value))
            return ScaleMode.NONE;
        else if (FXG_SCALEMODE_VERTICAL_VALUE.equals(value))
            return ScaleMode.VERTICAL;
        else if (FXG_SCALEMODE_NORMAL_VALUE.equals(value))
            return ScaleMode.NORMAL;
        else if (FXG_SCALEMODE_HORIZONTAL_VALUE.equals(value))
            return ScaleMode.HORIZONTAL;
        else
        	//Exception: Unsupported scaleMode setting: {0}.
            throw new FXGException(getStartLine(), getStartColumn(), "UnsupportedScaleMode", value);
    }
}