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
 * The Caps enumeration represents the type of line cap to use when painting
 * strokes.
 * 
 * The enumeration order is significant and matches the SWF specification for
 * the StartCapStyle and EndCapStyle properties of the LINESTYLE2 structure.
 * 
 * <pre>
 *   0 = round
 *   1 = none
 *   2 = square
 * </pre>
 * 
 * @author Peter Farland
 */
public enum Caps
{
    /**
     * The enum representing a 'round' cap type.
     */
    ROUND,

    /**
     * The enum representing a 'none' cap type. No caps are drawn for the ends
     * of a stroke.
     */
    NONE,

    /**
     * The enum representing a 'square' cap type.
     */
    SQUARE;
}
