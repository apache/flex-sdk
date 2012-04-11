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

import static com.adobe.fxg.FXGConstants.FXG_ID_ATTRIBUTE;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * A class to determine whether a node constitutes an CData in
 * a text flow.
 * 
 * @author Min Plunkett
 */
public class CDATANode extends AbstractFXGNode implements TextNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------
    /** The content. */
    public String content = null; 
    
    //------------
    // id
    //------------

    protected String id;

    /**
     * An id attribute provides a well defined name to a text node.
     * 
     * @return the id
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

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Gets the node name.
     * 
     * @return null, as character data has no name.
     */
    public String getNodeName()
    {
        return null;
    }
    
    /**
     * Gets the text attributes.
     * 
     * @return A Map recording the attribute names and values set on this
     * text node.
     */
    public Map<String, String> getTextAttributes()
    {
        return null;
    }

    /**
     * Gets the text children.
     * 
     * @return The List of child nodes of this text node.
     */
    public List<TextNode> getTextChildren()
    {
        return null;
    }

    /**
     * Gets the text properties.
     * 
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
     * @param propertyName the property name
     * @param node the node
     */
    public void addTextProperty(String propertyName, TextNode node)
    {
        addChild(node);
    }

    /**
     * Sets an FXG attribute on this text node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_ID_ATTRIBUTE.equals(name))
            id = value;
        else
            super.setAttribute(name, value);
    }
}
