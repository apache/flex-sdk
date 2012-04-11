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
 * The NumberAuto class. Underline value can be either a double or 
 * a NumberAutoAsEnum enum.
 * 
 * <pre>
 *   0 = auto
 *   1 = inherit
 * </pre>
 * 
 * @author Min Plunkett
 */
public class NumberAuto
{
    private double numberAutoAsDbl = 0.0;
    private int numberAutoAsInt;
    private NumberAutoAsEnum numberAutoAsEnum = null;
    private Type dataType;
    
    
    /** The NumberAutoAsEnum class.
    * 
    * <pre>
    *   0 = auto
    *   1 = inherit
    * </pre>
    */
    public enum NumberAutoAsEnum
    {
        /**
         * The enum representing an 'auto' NumberAuto.
         */
        AUTO,
        
        /**
         * The enum representing an 'inherit' NumberAuto.
         */
        INHERIT;
    }
    
    /** The Type class.
     * 
     * <pre>
     *   0 = enum
     *   1 = double
     *   2 = integer
     * </pre>
     */
     public enum Type
     {
         /**
          * The enum representing an 'enum' data type.
          */
         ENUM,
         
         /**
          * The enum representing an 'double' data type.
          */
         DOUBLE,

         /**
          * The enum representing an 'integer' data type.
          */
         INTEGER;
     }
    
    private NumberAuto()
    {    
    }
    
    /**
     * Create a new instance of NumberAuto with value set as an enum.
     * @param numberAutoAsEnum - NumberAuto value set as enum.
     * @return a new instance of NumberAuto.
     */
    public static NumberAuto newInstance(NumberAutoAsEnum numberAutoAsEnum)
    {
        NumberAuto numberAuto = new NumberAuto();
        numberAuto.numberAutoAsEnum = numberAutoAsEnum;
        numberAuto.dataType = Type.ENUM;
        return numberAuto;
    }
    
    /**
     * Create a new instance of NumberAuto with value set as a double.
     * @param numberAutoAsDbl - NumberAuto value set as double.
     * @return a new instance of NumberAuto.
     */
    public static NumberAuto newInstance(double numberAutoAsDbl)
    {
        NumberAuto numberAuto = new NumberAuto();
        numberAuto.numberAutoAsDbl = numberAutoAsDbl;
        numberAuto.dataType = Type.DOUBLE;
        return numberAuto;
    }  
    
    /**
     * Create a new instance of NumberAuto with value set as a integer.
     * @param numberAutoAsInt - NumberAuto value set as integer.
     * @return a new instance of NumberAuto.
     */
    public static NumberAuto newInstance(int numberAutoAsInt)
    {
        NumberAuto numberAuto = new NumberAuto();
        numberAuto.numberAutoAsInt = numberAutoAsInt;
        numberAuto.dataType = Type.INTEGER;
        return numberAuto;
    }  
    
    /**
     * Get data type of NumberAuto custom data type.
     * @return data type of NumberAuto custom data type.
     */
    public Type getType()
    {
        return dataType;
    }
    
    /**
     * @return NumberAuto as an enumerated value.
     */
    public NumberAutoAsEnum getNumberAutoAsEnum()
    {
        return this.numberAutoAsEnum;
    }
    
    /**
     * @return NumberAuto as a double value.
     */
    public double getNumberAutoAsDbl()
    {
        return this.numberAutoAsDbl;
    }
    
    /**
     * @return NumberAuto as a integer value.
     */
    public int getNumberAutoAsInt()
    {
        return this.numberAutoAsInt;
    }
}
