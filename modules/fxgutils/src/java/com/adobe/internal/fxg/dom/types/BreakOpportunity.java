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
 * The BreakOpportunity class.
 *
 * Controls where a line can legally break. "auto" means line breaking 
 * opportunities are based on standard Unicode character properties, 
 * such as breaking between words and on hyphens. Any indicates that the 
 * line may end at any character. This value is typically used when Roman 
 * text is embedded in Asian text and it is desirable for breaks to 
 * happen in the middle of words. None means that no characters in the 
 * range are treated as line break opportunities. All means that all 
 * characters in the range are treated as mandatory line break 
 * opportunities, so you get one character per line. Useful for creating 
 * effects like text on a path.
 * <pre>
 *   0 = auto
 *   1 = any
 *   2 = none
 *   3 = all
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum BreakOpportunity
{
    /**
     * The enum representing an 'auto' BreakOpportunity.
     */
    AUTO,

    /**
     * The enum representing an 'any' BreakOpportunity.
     */    
    ANY,
    
    /**
     * The enum representing an 'none' BreakOpportunity.
     */
    NONE,

    /**
     * The enum representing an 'all' BreakOpportunity.
     */
    ALL;    
}
