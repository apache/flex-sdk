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

import static com.adobe.fxg.FXGConstants.*;
import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;

/**
 * A &lt;Definition&gt; is a special template node that is not itself rendered
 * but rather can be referenced by name in an FXG document.
 * 
 * @author Peter Farland
 */
public class DefinitionNode extends AbstractFXGNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The group definition name. */
    public String name;

    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    /** The group definition. */
    public GroupDefinitionNode groupDefinition;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Add a child node. Supported child nodes: &lt;group&gt;. Cannot 
     * add more than one group definition.
     * 
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#addChild(com.adobe.fxg.dom.FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof GroupDefinitionNode)
        {
            if (groupDefinition != null)
            	//Exception:Definitions must define a single Group child node.
                throw new FXGException(child.getStartLine(), child.getStartColumn(), "MissingGroupChildNode");

            groupDefinition = (GroupDefinitionNode)child;
        }
        else
        {
            super.addChild(child);
        }
    }

    /**
     * @return The unqualified name of a Definition node, without tag markup.
     * i.e. literally 'Definition'. To retrieve the Definition name attribute,
     * refer to the name attribute itself.
     */
    public String getNodeName()
    {
        return FXG_DEFINITION_ELEMENT;
    }

    /**
     * Set definition properties. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>name</b> (String): The name of the symbol that is used to 
     * reference it when declaring an instance in the file, and is 
     * required. The string must match pattern "[a-zA-Z_][a-zA-Z_0-9]*".</li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_NAME_ATTRIBUTE.equals(name))
        {
            this.name = DOMParserHelper.parseIdentifier(this, value, name, this.name);
            if (((GraphicNode)this.getDocumentNode()).reservedNodes.containsKey(value))
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidDefinitionName", value);
        }
        else
        {
            super.setAttribute(name, value);
        }
    }
}
