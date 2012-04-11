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

package com.adobe.internal.fxg.dom.filters;

import static com.adobe.fxg.FXGConstants.*;

import java.util.ArrayList;
import java.util.List;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.util.FXGLog;
import com.adobe.fxg.util.FXGLogger;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.GradientEntryNode;
import com.adobe.internal.fxg.dom.types.BevelType;

/**
 * @author Peter Farland
 */
public class GradientBevelFilterNode extends AbstractFilterNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The angle of the generated drop shadow. This angle is expressed in 
     * document coordinate space. Defaults to 45. */
    public double angle = 45.0;
    
    /** The amount of blur applied to the rendered content in the horizontal. 
     * Defaults to 4. */
    public double blurX = 4.0;
    
    /** The amount of blur applied to the rendered content in the vertical. 
     * Defaults to 4. */
    public double blurY = 4.0;
    
    /** The quality of the rendered effect. Defaults to 1. Maximum is 3. */
    public int quality = 1;
    
    /** The distance between each pixel in the source and its corresponding 
     * shadow in the output. Defaults to 4. */
    public double distance = 4.0;
    
    /** Renders the effect only where the value in the original content 
     * was 100% transparent. All other pixels are 100% transparent. 
     * Defaults to false. */
    public boolean knockout = false;
    
    /** The strength of the imprint or spread. The higher the value, the 
     * more color is imprinted and the stronger the contrast between the bevel 
     * and the background. Valid values are from 0 to 255.0. 
     * The default is 1.0. */
    public double strength = 1.0;
    
    /**The placement of the bevel on the object. Defaults to "inner". */
    public BevelType type = BevelType.INNER;

    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    /** List of child Gradient entry. */
    public List<GradientEntryNode> entries;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Adds a gradient entry child node to this node. Supported child nodes: 
     * GradientEntryNode. A warning is logged when 
     * more than 15 GradientEntry node is added. The extra child is ignored.
     * 
     * @param child - a child FXG node to be added to this node.
     * 
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof GradientEntryNode)
        {
            if (entries == null)
            {
                entries = new ArrayList<GradientEntryNode>(4);
            }
            else if (entries.size() >= GRADIENT_ENTRIES_MAX_INCLUSIVE)
            {
            	//Log warning:A GradientBevelFilter cannot define more than 15 GradientEntry elements - extra elements ignored.
                FXGLog.getLogger().log(FXGLogger.WARN, "InvalidGradientBevelFilterNumElements", null, getDocumentName(), startLine, startColumn);
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
     * @return The unqualified name of a GradientBevelFilter node, without tag
     * markup.
     */
    public String getNodeName()
    {
        return FXG_GRADIENTBEVELFILTER_ELEMENT;
    }

    /** 
     * Set gradient bevel filter properties. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>angle</b> (Number): The angle of the generated drop shadow. 
     * This angle is expressed in document coordinate space. Defaults to 45.</li> 
     * <li><b>blurX</b> (Number): The amount of blur applied to the rendered 
     * content in the horizontal. Defaults to 4. </li>
     * <li><b>blurY</b> (Number): The amount of blur applied to the rendered 
     * content in the vertical. Defaults to 4. </li>
     * <li><b>distance</b> (Number): The distance between each pixel in the 
     * source and its corresponding shadow in the output. Defaults to 4.</li>
     * <li><b>knockout</b> (Boolean): Renders the effect only where the value 
     * in the original content was 100% transparent. All other pixels are 
     * 100% transparent. Default to false. </li>
     * <li><b>quality</b> (Number): The quality of the rendered effect. 
     * Maximum is 3. Defaults to 1. </li>
     * <li><b>strength</b> (Number): The strength of the imprint or spread. 
     * The higher the value, the more color is imprinted and the stronger 
     * the contrast between the bevel and the background. Valid values are 
     * from 0 to 255.0. The default is 1. </li>
     * <li><b>type</b> (String) ("inner", "outer", "full"): The placement 
     * of the bevel on the object. Defaults to "inner". </li>
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
        if (FXG_ANGLE_ATTRIBUTE.equals(name))
            angle = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_BLURX_ATTRIBUTE.equals(name))
            blurX = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_BLURY_ATTRIBUTE.equals(name))
            blurY = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_QUALITY_ATTRIBUTE.equals(name))
            quality = DOMParserHelper.parseInt(this, value, name, QUALITY_MIN_INCLUSIVE, QUALITY_MAX_INCLUSIVE, quality);
        else if (FXG_DISTANCE_ATTRIBUTE.equals(name))
            distance = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_KNOCKOUT_ATTRIBUTE.equals(name))
            knockout = DOMParserHelper.parseBoolean(this, value, name);
        else if (FXG_STRENGTH_ATTRIBUTE.equals(name))
            strength = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_TYPE_ATTRIBUTE.equals(name))
            type = getBevelType(value);
        else
            super.setAttribute(name, value);
    }
}
