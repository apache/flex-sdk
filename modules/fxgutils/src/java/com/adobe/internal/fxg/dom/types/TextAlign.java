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
 * The TextAlign class. The alignment of the text relative to the text box 
 * edges. "start" is the edge specified by the direction property - left 
 * for direction="ltr", right for direction="rtl". Likewise "end" will be 
 * the right edge if direction="ltr", and the left edge if direction="rtl". 
 * Default is "start".
 * 
 * <pre>
 *   0 = start
 *   1 = end
 *   2 = left
 *   3 = center
 *   4 = right
 *   5 = justify
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum TextAlign
{
    /**
     * The enum representing an 'start' TextAlign.
     */
    START,

    /**
     * The enum representing an 'end' TextAlign.
     */    
    END,
    
    /**
     * The enum representing an 'left' TextAlign.
     */
    LEFT,

    /**
     * The enum representing an 'center' TextAlign.
     */
    CENTER,   
    
    /**
     * The enum representing an 'right' TextAlign.
     */
    RIGHT, 
    
    /**
     * The enum representing an 'justify' TextAlign.
     */
    JUSTIFY;
}
