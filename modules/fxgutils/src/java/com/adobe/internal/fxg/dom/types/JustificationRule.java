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
 * The JustificationRule class. Set up the justifier. EastAsian will turn on 
 * justification for Japanese. An value of "auto" is resolved based on the 
 * locale of the paragraph. Values for Japanese ("ja") and Chinese 
 * ("zh-XX", "zh_XX", etc) resolve to eastAsian, while all other 
 * locales resolve to space.
 * 
 * <pre>
 *   0 = auto
 *   1 = space
 *   2 = eastAsian
 * </pre>
 * 
 */
public enum JustificationRule
{
    /**
     * The enum representing an 'auto' JustificationRule.
     */
    AUTO,

    /**
     * The enum representing an 'space' JustificationRule.
     */    
    SPACE,

    /**
     * The enum representing an 'eastAsian' JustificationRule.
     */    
    EASTASIAN;
}
