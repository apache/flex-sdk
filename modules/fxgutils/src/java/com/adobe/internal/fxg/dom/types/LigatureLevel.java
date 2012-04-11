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
 * The LigatureLevel class.
 * 
 * Controls which 
 * ligatures in the font will be used. Minimum turns on rlig, common is 
 * rlig + clig + liga, uncommon is rlig + clig + liga + dlig, exotic is 
 * rlig + clig + liga + dlig + hlig. There is no way to turn the various 
 * ligature features on independently. Default is "common". </li>
 * <li><b>locale</b> (String): The locale of the text. Controls case 
 * transformations and shaping. Standard locale identifiers as described 
 * in Unicode Technical Standard #35 are used. For example en, 
 * en_US and en-US are all English, ja is Japanese. Locale applied at 
 * the paragraph and higher level impacts resolution of "auto" values 
 * for dominantBaseline, justificationRule, justificationStyle and 
 * leadingModel.
 * 
 * <pre>
 *   0 = minimum
 *   1 = common
 *   2 = uncommon
 *   3 = exotic
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum LigatureLevel
{
    /**
     * The enum representing an 'minimum' LigatureLevel.
     */
    MINIMUM,

    /**
     * The enum representing an 'common' LigatureLevel.
     */    
    COMMON,
    
    /**
     * The enum representing an 'uncommon' LigatureLevel.
     */
    UNCOMMON,

    /**
     * The enum representing an 'exotic' LigatureLevel.
     */
    EXOTIC;    
}
