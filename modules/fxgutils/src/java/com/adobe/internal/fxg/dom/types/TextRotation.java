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
 * The TextRotation class.
 * 
 * The rotation of the text, in ninety degree increments.
 * 
 * <pre>
 *   0 = auto
 *   1 = rotate0
 *   2 = rotate90
 *   3 = rotate180
 *   4 = rotate270
 * </pre>
 * 
 * @author Min Plunkett
 */
public enum TextRotation
{
    /**
     * The enum representing an 'auto' TextRotation.
     */
    AUTO,

    /**
     * The enum representing an 'rotate0' TextRotation.
     */    
    ROTATE_0,
    
    /**
     * The enum representing an 'rotate90' TextRotation.
     */    
    ROTATE_90,
    
    /**
     * The enum representing an 'rotate180' TextRotation.
     */    
    ROTATE_180,
    
    /**
     * The enum representing an 'rotate270' TextRotation.
     */    
    ROTATE_270;
}
