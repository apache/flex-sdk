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
 * A scaling grid is used to calculate the center rectangle that determines
 * how to apply 9-slice scaling to a graphic.
 * 
 * @author Peter Farland
 */
public class ScalingGrid
{    
    /** The scale grid left. Default to 0.0. */
    public double scaleGridLeft = 0.0;
    
    /** The scale grid right. Default to 0.0. */
    public double scaleGridRight = 0.0;
    
    /** The scale grid top. Default to 0.0. */
    public double scaleGridTop = 0.0;
    
    /** The scale grid bottom. Default to 0.0. */
    public double scaleGridBottom = 0.0;
}
