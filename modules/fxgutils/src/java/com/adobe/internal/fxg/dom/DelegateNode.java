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

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;

/**
 * A special kind of relationship node that delegates the addition of child
 * nodes to another parent node (instead of adding them to itself). An example
 * of a delegate node is the fill child of a Rect component. In the snippet
 * below, a SolidColor fill is added directly to the Rect - the parent of the
 * fill property node.
 * 
 * <pre>
 * &lt;Rect width="20" height="20"&gt;
 *     &lt;fill&gt;
 *         &lt;SolidColor color="#FFCC00" /&gt;
 *     &lt;/fill&gt;
 * &lt;/Rect&gt;
 * </pre>
 * 
 * @author Peter Farland
 */
public class DelegateNode implements FXGNode
{
    protected String name;
    protected FXGNode delegate;
    protected FXGNode documentNode;
    protected String uri;
    protected int startLine;
    protected int startColumn;
    protected int endLine;
    protected int endColumn;

    /**
     * Sets the name.
     * 
     * @param name the new name
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * {@inheritDoc}
     */
    public String getNodeName()
    {
        return name;
    }

    /**
     * Sets the delegate.
     * 
     * @param delegate the new delegate
     */
    public void setDelegate(FXGNode delegate)
    {
        this.delegate = delegate;
    }

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Adds an FXG child node to the delegate node.
     * 
     * @param child - a child FXG node to be added to the delegate node.
     * @throws FXGException if the child is not supported by the delegate node.
     */
    public void addChild(FXGNode child)
    {
        delegate.addChild(child);
    }

    /**
     * Sets an FXG attribute on the delegate node.
     * 
     * @param name - the unqualified attribute name
     * @param value - the attribute value
     * @throws FXGException if the attribute name is not supported by the
     * delegate node.
     */
    public void setAttribute(String name, String value)
    {
        //Exception: Attribute {0} not supported by node {1}
        throw new FXGException(getStartLine(), getStartColumn(), "InvalidNodeAttribute", name, getNodeName());
    }

    /**
     * {@inheritDoc}
     */
    public FXGNode getDocumentNode()
    {
        return documentNode;
    }

    /**
     * {@inheritDoc}
     */
    public void setDocumentNode(FXGNode root)
    {
        documentNode = root;
    }

    /**
     * {@inheritDoc}
     */
    public String getNodeURI()
    {
        return uri;
    }

    /**
     * Sets the namespace URI.
     * 
     * @param uri - the namespace URI of this node.
     */
    public void setNodeURI(String uri)
    {
        this.uri = uri;
    }

    /**
     * {@inheritDoc}
     */
    public int getStartLine()
    {
        return startLine;
    }

    /**
     * {@inheritDoc}
     */
    public void setStartLine(int line)
    {
        startLine = line;
    }

    /**
     * {@inheritDoc}
     */
    public int getStartColumn()
    {
        return startColumn;
    }

    /**
     * {@inheritDoc}
     */
    public void setStartColumn(int column)
    {
        startColumn = column;
    }

    /**
     * {@inheritDoc}
     */
    public int getEndLine()
    {
        return endLine;
    }

    /**
     * {@inheritDoc}
     */    
    public void setEndLine(int line)
    {
        endLine = line;
    }

    /**
     * {@inheritDoc}
     */    
    public int getEndColumn()
    {
        return endColumn;
    }

    /**
     * {@inheritDoc}
     */
    public void setEndColumn(int column)
    {
        endColumn = column;
    }
}
