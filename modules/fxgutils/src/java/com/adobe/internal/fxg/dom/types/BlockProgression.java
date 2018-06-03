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
 * The BlockProgression class. Controls the direction in which lines are 
 * stacked. In Latin text, this is tb, because lines start at the top and 
 * proceed downward. In vertical Chinese or Japanese, this is rl, 
 * because lines should start at the right side of the container and 
 * proceed leftward.
 * 
 * <pre>
 *   0 = tb
 *   1 = rl
 * </pre>
 * 
 */
public enum BlockProgression
{
    /**
     * The enum representing an 'tb' BlockProgression.
     */
    TB,

    /**
     * The enum representing an 'rl' BlockProgression.
     */    
    RL;
}