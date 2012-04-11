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
 * The NumberPercentAuto class. Underline value can be either a double or 
 * a NumberPercentAutoAsEnum enum.
 * 
 * <pre>
 *   0 = auto
 * </pre>
 * 
 * @author Min Plunkett
 */
public class NumberPercentAuto
{
    private double numberPercentAutoAsDbl = 0.0;
    private NumberPercentAutoAsEnum numberPercentAutoAsEnum = null;
    
    
    /** The NumberPercentAutoAsEnum class.
    * 
    * <pre>
    *   0 = auto
    * </pre>
    */
    public enum NumberPercentAutoAsEnum
    {
        /**
         * The enum representing an 'auto' NumberPercentAuto.
         */
        AUTO;
    }
    
    private NumberPercentAuto()
    {    
    }
    
    /**
     * Create a new instance of NumberPercentAuto with value set as an enum.
     * @param numberPercentAutoAsEnum - NumberPercentAuto value set as enum.
     * @return a new instance of NumberPercentAuto.
     */
    public static NumberPercentAuto newInstance(NumberPercentAutoAsEnum numberPercentAutoAsEnum)
    {
        NumberPercentAuto numberPercentAuto = new NumberPercentAuto();
        numberPercentAuto.numberPercentAutoAsEnum = numberPercentAutoAsEnum;
        return numberPercentAuto;
    }
    
    /**
     * Create a new instance of NumberPercentAuto with value set as a double.
     * @param numberPercentAutoAsDbl - NumberPercentAuto value set as double.
     * @return a new instance of NumberPercentAuto.
     */
    public static NumberPercentAuto newInstance(double numberPercentAutoAsDbl)
    {
        NumberPercentAuto numberPercentAuto = new NumberPercentAuto();
        numberPercentAuto.numberPercentAutoAsDbl = numberPercentAutoAsDbl;
        return numberPercentAuto;
    }  
    
    /**
     * Check whether NumberPercentAuto is an enumerated value.
     * @return true if NumberPercentAuto is an enumerated value, otherwise 
     * return false.
     */
    public boolean isNumberPercentAutoAsEnum()
    {
    	if (numberPercentAutoAsEnum != null)
    		return true;
    	else
    		return false;
    }
    
    /**
     * @return NumberPercentAuto as an enumerated value.
     */
    public NumberPercentAutoAsEnum getNumberPercentAutoAsEnum()
    {
        return this.numberPercentAutoAsEnum;
    }
    
    /**
     * @return NumberPercentAuto as a double value.
     */
    public double getNumberPercentAutoAsDbl()
    {
        return this.numberPercentAutoAsDbl;
    }
}
