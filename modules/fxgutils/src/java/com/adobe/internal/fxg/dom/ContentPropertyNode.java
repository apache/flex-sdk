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
 * This is a special delegate which special cases content node children for
 * the TextNode and RichTextNode classes.
 * 
 */
public class ContentPropertyNode extends DelegateNode implements PreserveWhiteSpaceNode
{
    
    /**
     * Set delegate. An exception is thrown if the delegate is not a TextNode 
     * or is a RichTextNode but its content has already been defined.
     * @see com.adobe.internal.fxg.dom.DelegateNode#setDelegate(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void setDelegate(FXGNode delegate)
    {
        if (!(delegate instanceof TextNode))
        {
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidChildNode",  getNodeName(), delegate.getNodeName());   
        }
        else if (delegate instanceof RichTextNode && ((RichTextNode)delegate).content != null)
        {
            throw new FXGException(getStartLine(), getStartColumn(), "MultipleContentElements");  
        }
        else
        {
            super.setDelegate(delegate);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Add a child node. Supported child nodes: &lt;TextGraphic&gt;, 
     * &lt;RichText&gt;.
     * 
     * @param child a FXG node
     * 
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.DelegateNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (delegate instanceof TextGraphicNode)
        {
            ((TextGraphicNode)delegate).addContentChild(child);
        }
        else if (delegate instanceof RichTextNode)
        {
            ((RichTextNode)delegate).addContentChild(child);
        }
        else
        {
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidChildNode",  child.getNodeName(), getNodeName());   
        }
    }
}
