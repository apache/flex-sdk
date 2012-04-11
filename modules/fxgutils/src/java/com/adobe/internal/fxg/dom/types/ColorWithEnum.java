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
 * The ColorWithEnum class. Underline value can be either a double or 
 * a ColorWithEnumAsEnum enum.
 * 
 * <pre>
 *   0 = auto
 *   1 = inherit
 * </pre>
 * 
 * @author Min Plunkett
 */
public class ColorWithEnum
{
    private int colorWithEnumAsInt;
    private ColorEnum colorEnum = null;
    
    
    /** The ColorEnum class.
    * 
    * <pre>
    *   0 = transparent
    *   1 = inherit
    * </pre>
    */
    public enum ColorEnum
    {
        /**
         * The enum representing an 'transparent' ColorWithEnum.
         */
        TRANSPARENT,
        
        /**
         * The enum representing an 'inherit' ColorWithEnum.
         */
        INHERIT;
    }
    
    private ColorWithEnum()
    {    
    }
    
    /**
     * Create a new instance of ColorWithEnum with value set as an enum.
     * @param colorEnum - ColorWithEnum value set as enum.
     * @return a new instance of ColorWithEnum.
     */
    public static ColorWithEnum newInstance(ColorEnum colorEnum)
    {
        ColorWithEnum colorWithEnum = new ColorWithEnum();
        colorWithEnum.colorEnum = colorEnum;
        return colorWithEnum;
    }
    
    /**
     * Create a new instance of ColorWithEnum with value set as a integer.
     * @param colorWithEnumAsInt - ColorWithEnum value set as integer.
     * @return a new instance of ColorWithEnum.
     */
    public static ColorWithEnum newInstance(int colorWithEnumAsInt)
    {
        ColorWithEnum colorWithEnum = new ColorWithEnum();
        colorWithEnum.colorWithEnumAsInt = colorWithEnumAsInt;
        return colorWithEnum;
    }  
    
    /**
     * Check whether color is an enumerated value.
     * @return color as an enumerated value.
     */
    public boolean isColorWithEnumAsEnum()
    {
    	if (colorEnum != null)
    		return true;
    	else
    		return false;
    }
    
    /**
     * @return color as an enumerated value.
     */
    public ColorEnum getColorWithEnumAsEnum()
    {
        return this.colorEnum;
    }
    
    /**
     * @return color as a string.
     */
    public int getColorWithEnumAsString()
    {
        return this.colorWithEnumAsInt;
    }
}
