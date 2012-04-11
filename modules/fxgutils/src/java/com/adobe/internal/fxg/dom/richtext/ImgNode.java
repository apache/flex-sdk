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

package com.adobe.internal.fxg.dom.richtext;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.types.NumberPercentAuto;
import com.adobe.internal.fxg.dom.types.NumberPercentAuto.NumberPercentAutoAsEnum;

/**
 * Represents a &lt;p /&gt; FXG image node.
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public class ImgNode extends AbstractRichTextLeafNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    // Image attributes
    /** Image attribute: The width. Default to "auto".*/
    public NumberPercentAuto width = NumberPercentAuto.newInstance(NumberPercentAutoAsEnum.AUTO);
    
    /** Image attribute: The height. Default to "auto".*/
    public NumberPercentAuto height = NumberPercentAuto.newInstance(NumberPercentAutoAsEnum.AUTO);
    
    /** Image attribute: The source. Default to "".*/
    public String source = "";
        
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /** 
     * Gets the node name.
     * @return The unqualified name of a image node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_IMG_ELEMENT;
    }

    /**
     * This implementation processes image attributes that are relevant to
     * the &lt;img&gt; tag, as well as delegates to the parent class to process
     * attributes that are also relevant to the &lt;img&gt; tag.
     * 
     * @param name the attribute name
     * @param value the attribute value
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.richtext.AbstractRichTextLeafNode#setAttribute(String, String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_WIDTH_ATTRIBUTE.equals(name))
        {
            width = getNumberPercentAuto(this, name, value, "UnknownImgWidth");
        }
        else if(FXG_HEIGHT_ATTRIBUTE.equals(name))
        {
            height = getNumberPercentAuto(this, name, value, "UnknownImgHeight");
        }
        else if(FXG_SOURCE_ATTRIBUTE.equals(name))
        {
            source = value;
        }
        else
        {
            super.setAttribute(name, value);
            return;
        }
        
        // Remember attribute was set on this node.
        rememberAttribute(name, value);        
    }
    
    /**
     * 
     * @param node - the FXG node.
     * @param name - the FXG attribute.
     * @param errorCode - the error code when value is out-of-range.
	 * @param value - the FXG String value.
	 * 
     */
    private NumberPercentAuto getNumberPercentAuto(FXGNode node, String name, String value, String errorCode)
    {
    	try
    	{
    		double valueDbl = DOMParserHelper.parsePercent(this, value, name);
    		return NumberPercentAuto.newInstance(valueDbl);
    	}
    	catch (FXGException e)
    	{
    		if (FXG_NUMBERPERCENAUTO_AUTO_VALUE.equals(value))
    		{
    			return NumberPercentAuto.newInstance(NumberPercentAutoAsEnum.AUTO);
            }
            else
            {
                //Exception: Unknown number percent auto: {0}
                throw new FXGException(node.getStartLine(), node.getStartColumn(), errorCode, value);            
            }
    	}
    }
}
