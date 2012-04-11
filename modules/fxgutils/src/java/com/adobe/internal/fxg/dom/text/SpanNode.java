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

import java.util.ArrayList;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.CDATANode;
import com.adobe.internal.fxg.dom.TextNode;

/**
 * Represents a &lt;span /&gt; child tag of FXG text content. A &lt;span&gt;
 * tag starts a new section of formatting in a paragraph of text content.
 * 
 * @author Peter Farland
 */
public class SpanNode extends AbstractCharacterTextNode
{
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * A &lt;span&gt; allows child &lt;br /&gt; tags, as well as character
     * data (text content).
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof BRNode || child instanceof CDATANode)
        {
            if (content == null)
                content = new ArrayList<TextNode>();

            content.add((TextNode)child);
        }
        else 
        {
            super.addChild(child);
        }
    }

    /**
     * @return The unqualified name of a span node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_SPAN_ELEMENT;
    }
}
