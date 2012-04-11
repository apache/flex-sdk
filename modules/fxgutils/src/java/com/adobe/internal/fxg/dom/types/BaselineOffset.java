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
 * The BaselineOffset class. Underline value can be either a double or 
 * a BaselineOffsetAsEnum enum.
 * 
 * <pre>
 *   0 = auto
 *   1 = ascent
 *   2 = lineHeight 
 * </pre>
 * 
 * @author Min Plunkett
 */
public class BaselineOffset
{
    private double baselineOffsetAsDbl = 0.0;
    private BaselineOffsetAsEnum baselineOffsetAsEnum = null;
    
    /** The BaselineOffsetAsEnum class.
    * 
    * <pre>
    *   0 = auto
    *   1 = ascent
    *   2 = lineHeight
    * </pre>
    */
    public enum BaselineOffsetAsEnum
    {
        /**
         * The enum representing an 'auto' BaselineOffset.
         */
    	AUTO,

        /**
         * The enum representing an 'ascent' BaselineOffset.
         */
        ASCENT,
        
        /**
         * The enum representing an 'lineHeight' BaselineOffset.
         */
        LINEHEIGHT
    }
    
    private BaselineOffset()
    {    
    }
    
    /**
     * Create a new instance of BaselineOffset with value set as an enum.
     * @param baselineOffsetAsEnum - BaselineOffset value set as enum.
     * @return a new instance of BaselineOffset.
     */
    public static BaselineOffset newInstance(BaselineOffsetAsEnum baselineOffsetAsEnum)
    {
        BaselineOffset baselineOffset = new BaselineOffset();
        baselineOffset.baselineOffsetAsEnum = baselineOffsetAsEnum;
        return baselineOffset;
    }
    
    /**
     * Create a new instance of BaselineOffset with value set as a double.
     * @param baselineOffsetAsDbl - BaselineOffset value set as double.
     * @return a new instance of BaselineOffset.
     */
    public static BaselineOffset newInstance(double baselineOffsetAsDbl)
    {
        BaselineOffset baselineOffset = new BaselineOffset();
        baselineOffset.baselineOffsetAsDbl = baselineOffsetAsDbl;
        return baselineOffset;
    }  
    
    /**
     * Check whether BaselineOffset is an enumerated value.
     * @return true if BaselineOffset is an enumerated value, otherwise return 
     * false.
     */
    public boolean isBaselineOffsetAsEnum()
    {
        if (this.baselineOffsetAsEnum != null)
            return true;
        else
            return false;
    }
    
    /**
     * @return BaselineOffset as an enumerated value.
     */
    public BaselineOffsetAsEnum getBaselineOffsetAsEnum()
    {
        return this.baselineOffsetAsEnum;
    }
    
    /**
     * @return BaselineOffset as a double value.
     */
    public double getBaselineOffsetAsDbl()
    {
        return this.baselineOffsetAsDbl;
    }
}
