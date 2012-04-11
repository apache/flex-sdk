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
 * The ScaleMode enumeration represents the type of scaling used painting a
 * stroke for a shape that has a transformation matrix.
 * 
 * The enumeration order is not significant to the SWF specification, but
 * simply matches the order specified for FXG.
 * 
 * <pre>
 *   0 = none
 *   1 = vertical
 *   2 = normal
 *   3 = horizontal
 * </pre>
 * 
 * @author Peter Farland
 */
public enum ScaleMode
{
    /**
     * The enum representing a 'none' stroke scale mode.
     */
    NONE,

    /**
     * The enum representing a 'vertical' stroke scale mode.
     */
    VERTICAL,

    /**
     * The enum representing a 'normal' (both horizontal and vertical) stroke
     * scale mode.
     */
    NORMAL,

    /**
     * The enum representing a 'horizontal' stroke scale mode.
     */
    HORIZONTAL;
}
