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

import java.util.HashMap;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;


import static com.adobe.fxg.FXGConstants.*;

/**
 * Represents the special &lt;Library&gt; section of an FXG document.
 * <p>
 * A Library contains a series of named &lt;Definition&gt; nodes that themselves
 * do not contribute to the visual representation but rather serve as
 * 'templates' that can be referenced by name throughout the document. A
 * reference to a definition is known as an 'instance' and is represented in the
 * tree as a special PlaceObjectNode (the term PlaceObject refers to the SWF tag
 * that places an instance on the stage). Instances can provide their own values
 * that override the defaults from the definition.
 * </p>
 * 
 * @author Peter Farland
 */
public class LibraryNode extends AbstractFXGNode
{
    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    //---------------
    // <Definition>
    //---------------

    /** The definitions. */
    public HashMap<String, DefinitionNode> definitions;

    /**
     * Locates a Definition node in this Library by name.
     * 
     * @param name - the name of the definition
     * @return a Definition for the given name, or null if none exists.
     */
    public DefinitionNode getDefinition(String name)
    {
        if (definitions != null)
            return definitions.get(name);
        else
            return null;
    }

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Adds an FXG child node to this library node. Supported child nodes
     * include DefinitionNode. An exception is thrown if node name is null.
     * 
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     */    
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof DefinitionNode)
        {
            if (definitions == null)
                definitions = new HashMap<String, DefinitionNode>();

            DefinitionNode node = (DefinitionNode)child;
            if (node.name == null)
                throw new FXGException(child.getStartLine(), child.getStartColumn(), "MissingDefinitionName");

            definitions.put(node.name, node);
        }
        else
        {
            super.addChild(child);
        }
    }

    /**
     * @return The unqualified name of a Library node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_LIBRARY_ELEMENT;
    }
}
