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
 * The DigitWidth class.
 * 
 * Specifies how wide digits will be when the text is set. 
 * Proportional means that the proportional widths from the font are 
 * used, and different digits will have different widths. Tabular means 
 * that every digits has the same width. Default means that the normal 
 * width from the font is used.
 * <pre>
 *   0 = default
 *   1 = proportional
 *   2 = tabular
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum DigitWidth
{
    /**
     * The enum representing an 'default' DigitWidth.
     */
    DEFAULT,

    /**
     * The enum representing an 'proportional' DigitWidth.
     */    
    PROPORTIONAL,
    
    /**
     * The enum representing an 'tabular' DigitWidth.
     */
    TABULAR;
}
