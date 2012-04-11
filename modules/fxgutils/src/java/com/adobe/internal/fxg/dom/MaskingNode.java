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

import com.adobe.fxg.dom.FXGNode;

/**
 * Marker interface to imply node can be used to create a mask.
 * 
 * @author Peter Farland
 */
public interface MaskingNode extends FXGNode
{
    
    /**
     * Creates the graphic context.
     * 
     * @return the graphic context
     */
    GraphicContext createGraphicContext();

    /**
     * @return the index of a mask in a parent DisplayObject's list of children.
     * This can be used to access the mask programmatically at runtime.
     */
    int getMaskIndex();

    /**
     * Records the index of this mask in the parent DisplayObject's list of
     * children. (Optional).
     * @param index - the child index to the mask  
     */
    void setMaskIndex(int index);
}
