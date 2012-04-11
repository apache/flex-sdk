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
 * The JustificationStyle class. An value of "auto" is resolved based on the 
 * locale of the paragraph. Currently, all locales resolve to pushInKinsoku, 
 * however, this value is only used in conjunction with a justificationRule 
 * value of eastAsian, so is only applicable to "ja" and all "zh" locales. 
 * PrioritizeLeastAdjustment bases justification on either expanding or 
 * compressing the line, whichever gives a result closest to the desired 
 * width. PushInKinsoku bases justification on compressing kinsoku at the 
 * end of the line, or expanding it if there is no kinsoku or if that space 
 * is insufficient. PushOutOnly bases justification on expanding the line.
 * 
 * <pre>
 *   0 = auto
 *   1 = prioritizeLeastAdjustment
 *   2 = pushInKinsoku
 *   3 = pushOutOnly
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum JustificationStyle
{
    /**
     * The enum representing an 'auto' JustificationStyle.
     */
    AUTO,

    /**
     * The enum representing an 'prioritizeLeastAdjustment' JustificationStyle.
     */    
    PRIORITIZELEASTADJUSTMENT,

    /**
     * The enum representing an 'pushInKinsoku' JustificationStyle.
     */    
    PUSHINKINSOKU,
    
    /**
     * The enum representing an 'pushOutOnly' JustificationStyle.
     */    
    PUSHOUTONLY;
}
