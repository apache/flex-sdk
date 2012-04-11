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
 * The WhiteSpaceCollapse enumeration determines how whitespace is handled
 * in text formatting.
 * 
 * A value of "collapse" converts line feeds, newlines, and tabs to spaces 
 * and collapses adjacent spaces to one. Leading and trailing whitespace is 
 * trimmed. A value of "preserve" passes whitespace through unchanged, 
 * except hen the whitespace would result in an implied <p> and <span> 
 * that is all whitespace, in which case the whitespace is removed.
 * 
 * <pre>
 *   0 = preserve
 *   1 = collapse
 * </pre>
 * 
 * @author Peter Farland
 */
public enum WhiteSpaceCollapse
{
    /**
     * The enum representing 'preserve' whitespace.
     */
    PRESERVE,

    /**
     * The enum representing 'collapse' whitespace.
     */
    COLLAPSE;
}
