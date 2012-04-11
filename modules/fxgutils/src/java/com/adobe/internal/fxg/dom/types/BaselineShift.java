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
 * The BaselineShift class. Underline value can be either a double or 
 * a BaselineShiftAsEnum enum.
 *
 * Indicates the baseline shift for the element in pixels. The element is 
 * shifted perpendicular to the baseline by this amount. In horizontal 
 * text, a positive baseline shift moves the element up and a negative 
 * baseline shift moves the element down. The default value is 0.0, 
 * indicating no shift. A value of "superscript" shifts the text up by 
 * an amount specified in the font, and applies a transform to the 
 * fontSize also based on preferences in the font. A value of "subscript" 
 * shifts the text down by an amount specified in the font, and also 
 * transforms the fontSize. Percent shifts the text by a percentage of 
 * the fontSize.
 * 
 * <pre>
 *   0 = superscript
 *   1 = subscript
 * </pre>
 * 
 * @author Min Plunkett
 */
public class BaselineShift
{
    private double baselineShiftAsDbl = 0.0;
    private BaselineShiftAsEnum baselineShiftAsEnum = null;
    
    /** The BaselineShiftAsEnum class.
    * 
    * <pre>
    *   0 = superscript
    *   1 = subscript
    * </pre>
    */
    public enum BaselineShiftAsEnum
    {
        /**
         * The enum representing an 'superscript' BaselineShift.
         */
        SUPERSCRIPT,

        /**
         * The enum representing an 'subscript' BaselineShift.
         */
        SUBSCRIPT;
    }
    
    private BaselineShift()
    {    
    }
    
    /**
     * Create a new instance of BaselineShift with value set as an enum.
     * @param baselineShiftAsEnum - BaselineShift value set as enum.
     * @return a new instance of BaselineShift.
     */
    public static BaselineShift newInstance(BaselineShiftAsEnum baselineShiftAsEnum)
    {
        BaselineShift baselineShift = new BaselineShift();
        baselineShift.baselineShiftAsEnum = baselineShiftAsEnum;
        return baselineShift;
    }
    
    /**
     * Create a new instance of BaselineShift with value set as a double.
     * @param baselineShiftAsDbl - BaselineShift value set as double.
     * @return a new instance of BaselineShift.
     */
    public static BaselineShift newInstance(double baselineShiftAsDbl)
    {
        BaselineShift baselineShift = new BaselineShift();
        baselineShift.baselineShiftAsDbl = baselineShiftAsDbl;
        return baselineShift;
    }  
    
    /**
     * Check whether BaselineShift is an enumerated value.
     * @return true if BaselineShift is an enumerated value, otherwise return 
     * false.
     */
    public boolean isBaselineShiftAsEnum()
    {
        if (this.baselineShiftAsEnum != null)
            return true;
        else
            return false;
    }
    
    /**
     * @return BaselineShift as an enumerated value.
     */
    public BaselineShiftAsEnum getBaselineShiftAsEnum()
    {
        return this.baselineShiftAsEnum;
    }
    
    /**
     * @return BaselineShift as a double value.
     */
    public double getBaselineShiftAsDbl()
    {
        return this.baselineShiftAsDbl;
    }
}
