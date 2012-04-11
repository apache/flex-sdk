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
 * The DominantBaseline class.
 *
 * Specifies which of the baselines of the element snaps to the 
 * alignmentBaseline to determine the vertical position of the element 
 * on the line. A value of "auto" gets resolved based on the textRotation 
 * of the span and the locale of the parent paragraph. A textRotation of 
 * "rotate270" resolves to ideographicCenter. A locale of Japanese ("ja") 
 * or Chinese ("zh-XX", "zh_XX", etc), resolves to ideographicCenter, 
 * whereas all others are resolved to roman.
 * 
 * <pre>
 *   0 = auto
 *   1 = roman
 *   2 = ascent
 *   3 = descent
 *   4 = ideographicTop
 *   5 = ideographicCenter
 *   6 = ideographicBottom
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum DominantBaseline
{
    /**
     * The enum representing an 'auto' DominantBaseline.
     */
    AUTO,

    /**
     * The enum representing an 'roman' DominantBaseline.
     */    
    ROMAN,
    
    /**
     * The enum representing an 'ascent' DominantBaseline.
     */
    ASCENT, 
    
    /**
     * The enum representing an 'descent' DominantBaseline.
     */
    DESCENT,  
    
    /**
     * The enum representing an 'ideographicTop' DominantBaseline.
     */
    IDEOGRAPHICTOP,  
    
    /**
     * The enum representing an 'ideographicCenter' DominantBaseline.
     */
    IDEOGRAPHICCENTER,      
    
    /**
     * The enum representing an 'ideographicBottom' DominantBaseline.
     */
    IDEOGRAPHICBOTTOM;       
    
}
