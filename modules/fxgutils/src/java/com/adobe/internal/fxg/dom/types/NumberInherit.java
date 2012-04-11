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
 * The NumberInherit class. Underline value can be either a double or 
 * a NumberInheritAsEnum enum.
 * 
 * <pre>
 *   0 = inherit
 * </pre>
 * 
 * @author Min Plunkett
 */
public class NumberInherit
{
    private double numberInheritAsDbl = 0.0;
    private NumberInheritAsEnum numberInheritAsEnum = null;
    
    /** The NumberInheritAsEnum class.
    * 
    * <pre>
    *   0 = inherit
    * </pre>
    */
    public enum NumberInheritAsEnum
    {
        /**
         * The enum representing an 'inherit' NumberInherit.
         */
        INHERIT;
    }
    
    protected NumberInherit()
    {    
    }
    
    /**
     * Create a new instance of NumberInherit with value set as an enum.
     * @param numberInheritAsEnum - NumberInherit value set as enum.
     * @return a new instance of NumberInherit.
     */
    public static NumberInherit newInstance(NumberInheritAsEnum numberInheritAsEnum)
    {
        NumberInherit numberInherit = new NumberInherit();
        numberInherit.numberInheritAsEnum = numberInheritAsEnum;
        return numberInherit;
    }
    
    /**
     * Create a new instance of NumberInherit with value set as a double.
     * @param numberInheritAsDbl - NumberInherit value set as double.
     * @return a new instance of NumberInherit.
     */
    public static NumberInherit newInstance(double numberInheritAsDbl)
    {
        NumberInherit numberInherit = new NumberInherit();
        numberInherit.numberInheritAsDbl = numberInheritAsDbl;
        return numberInherit;
    }  
    
    /**
     * Check whether NumberInherit is an enumerated value.
     * @return true if NumberInherit is an enumerated value, otherwise return 
     * false.
     */
    public boolean isNumberInheritAsEnum()
    {
        if (this.numberInheritAsEnum != null)
            return true;
        else
            return false;
    }
    
    /**
     * @return NumberInherit as an enumerated value.
     */
    public NumberInheritAsEnum getNumberInheritAsEnum()
    {
        return this.numberInheritAsEnum;
    }
    
    /**
     * @return NumberInherit as a double value.
     */
    public double getNumberInheritAsDbl()
    {
        return this.numberInheritAsDbl;
    }
}
