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
 * The SpreadMethod enumeration determines how linear gradients control the
 * colors for points that lie outside of the gradient vector.
 * 
 * The enumeration order is significant and matches the SWF specification for
 * the SpreadMode property of the GRADIENT structure.
 * 
 * <pre>
 *   0 = Pad Mode
 *   1 = Reflect Mode
 *   2 = Repeat Mode
 * </pre>
 * 
 * @author Peter Farland
 */
public enum SpreadMethod
{
    /**
     * The enum representing a 'pad' spread method.
     */
    PAD,

    /**
     * The enum representing a 'reflect' spread method.
     */
    REFLECT,

    /**
     * The enum representing a 'repeat' spread method.
     */
    REPEAT;
}
