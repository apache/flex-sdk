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

package com.adobe.internal.fxg.dom.text;

import static com.adobe.fxg.FXGConstants.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.AbstractFXGNode;
import com.adobe.internal.fxg.dom.CDATANode;
import com.adobe.internal.fxg.dom.TextNode;
import com.adobe.internal.fxg.dom.richtext.TextHelper;

/**
 * A base class for all FXG nodes concerned with formatted text.
 * 
 * @author Peter Farland
 */
public abstract class AbstractTextNode extends AbstractFXGNode implements TextNode
{
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
     * @param value - the node id as a String.
     */
    public void setId(String value)
    {
        id = value;
    }

    //--------------------------------------------------------------------------
    //
    // Text Node Attribute Helpers
    //
    //--------------------------------------------------------------------------

    /**
     * The attributes set on this node.
     */
    protected Map<String, String> textAttributes;

    /**
     * @return A Map recording the attribute names and values set on this
     * text node.
     */
    public Map<String, String> getTextAttributes()
    {
        return textAttributes;
    }

    /**
     * This nodes child text nodes.
     */
    protected List<TextNode> content;

    /**
     * @return The List of child nodes of this text node. 
     */
    public List<TextNode> getTextChildren()
    {
        return content;
    }

    /**
     * @return The List of child property nodes of this text node.
     */
    public HashMap<String, TextNode> getTextProperties()
    {
        return null;
    }

    /**
     * A text node may also have special child property nodes that represent
     * complex property values that cannot be set via a simple attribute.
     * 
     * @param propertyName the text property name
     * @param node the FXG node
     */
    public void addTextProperty(String propertyName, TextNode node)
    {
        addChild(node);
    }

    /**
     * Remember that an attribute was set on this node.
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     */
    protected void rememberAttribute(String name, String value)
    {
        if (textAttributes == null)
            textAttributes = new HashMap<String, String>(4);

        textAttributes.put(name, value);
    }

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Check child node to ensure that exception isn't thrown for ignorable 
     * white spaces.
     * 
     * @param child - a child FXG node to be added to this node.
     */
    public void addChild(FXGNode child)
    {
        if (content == null)
        {
        	if (child instanceof CDATANode && TextHelper.ignorableWhitespace(((CDATANode)child).content))
        	{
                /**
                 * Ignorable white spaces don't break content contiguous 
                 * rule and should be ignored if they are at the beginning 
                 * of a element value.
                 */
        		return;
        	}
        }
        else 
        {
            super.addChild(child);
        }           
    }
    
    /**
     * Sets an FXG attribute on this text node. Delegates to the 
     * parent class to process attributes that are not in the list below.
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#addChild(FXGNode)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_ID_ATTRIBUTE.equals(name))
        {
            id = value;
        }
        else
        {
            super.setAttribute(name, value);
            return;
        }

        // Remember attribute was set on this node.
        rememberAttribute(name, value);
    }
}
