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

package com.adobe.internal.fxg.dom.transforms;

import static com.adobe.fxg.FXGConstants.FXG_ID_ATTRIBUTE;
import com.adobe.internal.fxg.dom.AbstractFXGNode;
import com.adobe.internal.fxg.dom.TransformNode;

/**
 * A base class for all FXG nodes that represent a transform.
 * 
 * @author Peter Farland
 */
public abstract class AbstractTransformNode extends AbstractFXGNode implements TransformNode 
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    //------------
    // id
    //------------

    protected String id;

    /**
     * An id attribute provides a well defined name to a content node.
     * 
     * @return id as a string.
     */
    public String getId()
    {
        return id;
    }

    /**
     * Sets the node id.
     * @param value - the node id as a String.
     */
    public void setId(String value)
    {
        id = value;
    }

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Sets an FXG attribute on this transform node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>id</b> (String): Set node identifier. </li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_ID_ATTRIBUTE.equals(name))
            id = value;
        else
            super.setAttribute(name, value);
    }
}
