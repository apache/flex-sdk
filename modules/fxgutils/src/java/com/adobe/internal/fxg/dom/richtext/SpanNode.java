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

import java.util.ArrayList;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.CDATANode;
import com.adobe.internal.fxg.dom.TextNode;

/**
 * Represents a &lt;p /&gt; child tag of FXG &lt;RichText&gt; content. A
 * &lt;p&gt; tag starts a new span in text content.
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public class SpanNode extends AbstractRichTextLeafNode
{    
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a span node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_SPAN_ELEMENT;
    }
    
    /**
     * Add a FXG child node to this span node. Supported child nodes
     * include text content nodes: &lt;br&gt;, &lt;tab&gt;, and CDATANode. 
     * Number of instances: unbounded.
     * 
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.richtext.AbstractRichTextNode#addChild(FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof BRNode
                || child instanceof TabNode
                || child instanceof CDATANode)
        {
            if (content == null)
            {
                content = new ArrayList<TextNode>();
            }
            content.add((TextNode)child);
        }
        else 
        {
            super.addChild(child);
            return;
        }
        if (child instanceof AbstractRichTextNode)
        	((AbstractRichTextNode)child).setParent(this);                
    }
}
