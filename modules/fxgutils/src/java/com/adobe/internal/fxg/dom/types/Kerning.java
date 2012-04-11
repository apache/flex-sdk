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
 * The Kerning enumeration determines whether font based kerning of character
 * pairs is used when rendering text.
 * 
 * If on, pair kerns are honored. If off, there is no font-based kerning 
 * applied. If auto, kerning is applied to all characters except Kanji, 
 * Hiragana or Katakana. The default is auto. Otherwise characters are 
 * drawn with no pair kerning adjustments.
 * 
 * The enumeration order is not significant to the SWF specification, but
 * simply matches the order specified for FXG.
 * 
 * <pre>
 *   0 = on
 *   1 = off
 *   2 = auto
 * </pre>
 * 
 * @author Peter Farland
 */
public enum Kerning
{
    /**
     * The enum representing an 'on' kerning type.
     */
    ON,

    /**
     * The enum representing an 'off' kerning type.
     */
    OFF,

    /**
     * The enum representing an 'auto' kerning type.
     */
    AUTO;
}
