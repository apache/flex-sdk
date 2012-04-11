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
 * The Joints enumeration represents the type of joint to use when painting
 * two connecting segments of a stroke.
 * 
 * The enumeration order is significant and matches the SWF specification for
 * the JoinStyle property of the LINESTYLE2 structure.
 * 
 * <pre>
 *   0 = round
 *   1 = bevel
 *   2 = miter
 * </pre>
 * 
 * @author Peter Farland
 */
public enum Joints
{
    /**
     * The enum representing a 'round' joint type.
     */
    ROUND,

    /**
     * The enum representing a 'bevel' joint type.
     */
    BEVEL,

    /**
     * The enum representing a 'miter' joint type.
     */
    MITER;
}
