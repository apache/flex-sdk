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

/**
 * A PlaceObject node does not appear itself in an FXG document but rather
 * represents an instance of a DefinitionNode. An instance may redefine
 * attributes that override the defaults of the definition.
 * 
 * @author Peter Farland
 */
public class PlaceObjectNode extends GraphicContentNode implements MaskingNode
{
    /**
     * The Definition referenced by this instance.
     */
    public DefinitionNode definition;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of an instance of a definition (also known
     * as a 'PlaceObject' node), without tag markup.
     */
    public String getNodeName()
    {
        return definition != null ? definition.name : null;
    }

    //--------------------------------------------------------------------------
    //
    // MaskingNode Implementation
    //
    //--------------------------------------------------------------------------

    private int maskIndex;

    /**
     * @return the index of a mask in a parent DisplayObject's list of children.
     * This can be used to access the mask programmatically at runtime.
     */
    public int getMaskIndex()
    {
        return maskIndex;
    }

    /**
     * Records the index of this mask in the parent DisplayObject's list of
     * children. (Optional).
     * @param index - the child index to the mask  
     */
    public void setMaskIndex(int index)
    {
        maskIndex = index;
    }

}
