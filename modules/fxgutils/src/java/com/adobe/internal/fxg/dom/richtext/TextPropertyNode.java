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

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.DelegateNode;
import com.adobe.internal.fxg.dom.TextNode;

/**
 * A FXG node represents complex property values.
 * 
 * @since 2.0
 * @author Peter Farland
 * @author Min Punkett
 */
public class TextPropertyNode extends DelegateNode
{
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Add a child node to the text property node. Both the current delegate 
     * node and the child node have to be a TextNode.
     * 
     * @param child a child FXG node.
     * 
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.DelegateNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (!(delegate instanceof TextNode))
        {
            throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidChildNode",  getNodeName(), delegate.getNodeName());                        
        }
        else if (delegate instanceof TextNode && child instanceof TextNode)
        {
            ((TextNode)delegate).addTextProperty(getNodeName(), (TextNode)child);
        }
        else    
        {
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidChildNode",  child.getNodeName(), getNodeName());
        }
    }
}
