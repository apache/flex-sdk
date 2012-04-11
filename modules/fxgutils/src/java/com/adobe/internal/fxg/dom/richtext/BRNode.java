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

/**
 * Represents a &lt;br /&gt; child tag of FXG &lt;RichText&gt; content. A
 * &lt;br /&gt; tag acts as a line separator for text content.
 * <p>
 * This is an empty tag - text content or child tags are not expected.
 * </p>
 * @since 2.0
 * @author Min Plunkett
 */
public class BRNode extends AbstractRichTextLeafNode
{    
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a br node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_BR_ELEMENT;
    }
    
    /**
     * BR node doesn't allow any children.
     *
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.richtext.AbstractRichTextNode#addChild(FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        super.addChild(child);       
    }    
}