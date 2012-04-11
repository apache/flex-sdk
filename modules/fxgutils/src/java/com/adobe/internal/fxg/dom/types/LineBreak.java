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
 * The LineBreak enumeration determines how line wrapping occurs when rendering
 * text. A value of "toFit" wraps the lines at the edge of the enclosing 
 * RichText. A value of "explicit" breaks the lines only at a Unicode 
 * line end character (such as a newline or line separator). 
 * 
 * The enumeration order is not significant to the SWF specification, but
 * simply matches the order specified for FXG.
 * 
 * <pre>
 *   0 = toFit
 *   1 = explicit
 *   2 = inherit
 * </pre>
 * 
 * @author Peter Farland
 */
public enum LineBreak
{
    /**
     * The enum representing a 'toFit' line break type.
     */
    TOFIT,

    /**
     * The enum representing an 'explicit' line break type.
     */
    EXPLICIT,
    
    /**
     * The enum representing an 'inherit' line break type.
     */
    INHERIT;
}
