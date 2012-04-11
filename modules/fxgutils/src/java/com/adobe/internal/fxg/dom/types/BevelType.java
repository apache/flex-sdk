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
 * The BevelType enumeration determines where on an object a bevel should be
 * placed.
 * 
 * The enumeration order is not significant to the SWF specification, but
 * simply matches the order specified for FXG.
 * 
 * <pre>
 *   0 = inner
 *   1 = outer
 *   2 = full
 * </pre>
 * 
 * @author Peter Farland
 */
public enum BevelType
{
    /**
     * The enum representing an 'inner' bevel type.
     */
    INNER,

    /**
     * The enum representing an 'outer' bevel type.
     */
    OUTER,

    /**
     * The enum representing a 'full' bevel type.
     */
    FULL;
}