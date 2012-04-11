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

package com.adobe.internal.fxg.dom.types;


/**
 * The MaskType enumeration controls how a mask layer will behave with respect
 * to the target graphical layers.
 * 
 * The enumeration order is not significant to the SWF specification, but
 * simply matches the order specified for FXG.
 * 
 * <pre>
 *   0 = clip
 *   1 = alpha
 *   2 = luminosity
 * </pre>
 * 
 * 
 * 
 * @author Peter Farland
 * @author Sujata Das
 */
public enum MaskType
{
    /**
     * The enum representing a 'clip' mask type.
     */
    CLIP,

    /**
     * The enum representing an 'alpha' mask type.
     */
    ALPHA,
    
    /**
     * The enum representing an 'luminosity' mask type.
     */
    LUMINOSITY;
    
    
}
