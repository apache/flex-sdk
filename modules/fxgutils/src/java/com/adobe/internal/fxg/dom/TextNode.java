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
import java.util.Map;

import com.adobe.fxg.dom.FXGNode;

/**
 * A marker interface to determine whether a node constitutes an element
 * of a text flow.
 * 
 * @author Peter Farland
 */
public interface TextNode extends FXGNode, PreserveWhiteSpaceNode
{
    /**
     * An id attribute provides a well defined name to a text node.
     * @return the node id.
     */
    public String getId();

    /**
     * Sets the node id.
     * @param value - the node id as a String.
     */
    public void setId(String value);
    
    /**
     * @return A Map that records the attribute names and values set on this
     * text node.
     */
    public Map<String, String> getTextAttributes();

    /**
     * @return The List of child nodes of this text node. 
     */
    public List<TextNode> getTextChildren();

    /**
     * @return The list of child property nodes of this text node.
     */
    public Map<String, TextNode> getTextProperties();

    /**
     * Add a child property to this text node.
     * @param propertyName - the property's local name
     * @param node - the value node
     */
    public void addTextProperty(String propertyName, TextNode node);
}
