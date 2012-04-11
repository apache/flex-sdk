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
 * The AlignmentBaseline class.
 * 
 * Specifies which of the baselines of the line 
 * containing the element the dominantBaseline snaps to, thus determining 
 * the vertical position of the element in the line.
 * 
 * <pre>
 *   0 = useDominantBaseline
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
public enum AlignmentBaseline
{
    /**
     * The enum representing an 'useDominantBaseline' AlignmentBaseline.
     */
    USEDOMINANTBASELINE,

    /**
     * The enum representing an 'roman' AlignmentBaseline.
     */    
    ROMAN,
    
    /**
     * The enum representing an 'ascent' AlignmentBaseline.
     */
    ASCENT, 
    
    /**
     * The enum representing an 'descent' AlignmentBaseline.
     */
    DESCENT,  
    
    /**
     * The enum representing an 'ideographicTop' AlignmentBaseline.
     */
    IDEOGRAPHICTOP,  
    
    /**
     * The enum representing an 'ideographicCenter' AlignmentBaseline.
     */
    IDEOGRAPHICCENTER,      
    
    /**
     * The enum representing an 'ideographicBottom' AlignmentBaseline.
     */
    IDEOGRAPHICBOTTOM;       
    
}
