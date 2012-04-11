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
import com.adobe.internal.fxg.dom.types.MaskType;

/**
 * This interface implies that a node may also have a mask.
 * 
 * @author Peter Farland
 */
public interface MaskableNode extends FXGNode
{
    
    /**
     * Gets the mask.
     * 
     * @return the mask
     */
    public MaskingNode getMask();

    /**
     * Gets the mask type.
     * 
     * @return the mask type
     */
    public MaskType getMaskType();
    
    /**
     * Gets the luminosity clip.
     * 
     * @return the luminosity clip
     */
    public boolean getLuminosityClip();
    
    /**
     * Gets the luminosity invert.
     * 
     * @return the luminosity invert
     */
    public boolean getLuminosityInvert();
}
