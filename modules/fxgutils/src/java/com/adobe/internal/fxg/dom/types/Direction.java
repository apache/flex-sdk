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
 * The Direction class. Controls the dominant writing direction for the 
 * paragraph (left-to-right or right-to-left), and how characters with no 
 * implicit writing direction, such as punctuation, are treated. Also 
 * controls the direction of the columns, which are set according to the 
 * value of the direction attribute of the RichText element.
 * 
 * <pre>
 *   0 = ltr
 *   1 = rtl
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum Direction
{
    /**
     * The enum representing an 'ltr' Direction.
     */
    LTR,

    /**
     * The enum representing an 'rtl' Direction.
     */    
    RTL;
}
