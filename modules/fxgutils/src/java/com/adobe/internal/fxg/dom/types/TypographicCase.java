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
 * The TypographicCase class.
 * 
 * Controls the case in which the text will appear. "default" is for the font 
 * that's chosen - i.e., its what you get without applying any features or case 
 * changes. smallCaps converts all characters to uppercase and applies c2sc.
 * uppercase and lowercase are case conversions. caps turns on case. 
 * lowercaseToSmallCaps converts all characters to uppercase, and for 
 * those characters which have been converted, applies c2sc.
 * 
 * <pre>
 *   0 = default
 *   1 = capsToSmallCaps
 *   2 = uppercase
 *   3 = lowercase
 *   4 = lowercaseToSmallCaps
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum TypographicCase
{
    /**
     * The enum representing an 'default' TypographicCase.
     */
    DEFAULT,

    /**
     * The enum representing an 'capsToSmallCaps' TypographicCase.
     */    
    CAPSTOSMALLCAPS,
    
    /**
     * The enum representing an 'uppercase' TypographicCase.
     */
    UPPERCASE,

    /**
     * The enum representing an 'lowercase' TypographicCase.
     */
    LOWERCASE,   
    
    /**
     * The enum representing an 'lowercaseToSmallCaps' TypographicCase.
     */
    LOWERCASETOSMALLCAPS;
}
