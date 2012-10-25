/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.image;



/**
 * This class implements the interface expected from a component
 * transfer function.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ConcreteComponentTransferFunction.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public class ConcreteComponentTransferFunction implements ComponentTransferFunction {
    private int type;
    private float slope;
    private float[] tableValues;
    private float intercept;
    private float amplitude;
    private float exponent;
    private float offset;

    /**
     * Instances should be created through the various
     * factory methods.
     */
    private ConcreteComponentTransferFunction(){
    }

    /**
     * Returns an instance initialized as an identity
     * transfer function
     */
    public static ComponentTransferFunction getIdentityTransfer(){
        ConcreteComponentTransferFunction f = new ConcreteComponentTransferFunction();
        f.type = IDENTITY;
        return f;
    }

    /**
     * Returns a table transfer function
     */
    public static ComponentTransferFunction
        getTableTransfer(float[] tableValues){
        ConcreteComponentTransferFunction f = new ConcreteComponentTransferFunction();
        f.type = TABLE;

        if(tableValues == null){
            throw new IllegalArgumentException();
        }

        if(tableValues.length < 2){
            throw new IllegalArgumentException();
        }

        f.tableValues = new float[tableValues.length];
        System.arraycopy(tableValues, 0,
                         f.tableValues, 0,
                         tableValues.length);

        return f;
    }

    /**
     * Returns a discrete transfer function
     */
    public static ComponentTransferFunction
        getDiscreteTransfer(float[] tableValues){
        ConcreteComponentTransferFunction f = new ConcreteComponentTransferFunction();
        f.type = DISCRETE;

        if(tableValues == null){
            throw new IllegalArgumentException();
        }

        if(tableValues.length < 2){
            throw new IllegalArgumentException();
        }

        f.tableValues = new float[tableValues.length];
        System.arraycopy(tableValues, 0,
                         f.tableValues, 0,
                         tableValues.length);

        return f;
    }

    /**
     * Returns a linear transfer function
     */
    public static ComponentTransferFunction
        getLinearTransfer(float slope, float intercept){
        ConcreteComponentTransferFunction f = new ConcreteComponentTransferFunction();
        f.type = LINEAR;
        f.slope = slope;
        f.intercept = intercept;

        return f;
    }

    /**
     * Returns a gamma function
     */
    public static ComponentTransferFunction
        getGammaTransfer(float amplitude,
                         float exponent,
                         float offset){
        ConcreteComponentTransferFunction f = new ConcreteComponentTransferFunction();
        f.type = GAMMA;
        f.amplitude = amplitude;
        f.exponent = exponent;
        f.offset = offset;

        return f;
    }

    /**
     * Returns the type of this transfer function
     */
    public int getType(){
        return type;
    }

    /**
     * Returns the slope value for this transfer function
     */
    public float getSlope(){
        return slope;
    }

    /**
     * Returns the table values for this transfer function
     */
    public float[] getTableValues(){
        return tableValues;
    }

    /**
     * Returns the intercept value for this transfer function
     */
    public float getIntercept(){
        return intercept;
    }

    /**
     * Returns the amplitude value for this transfer function
     */
    public float getAmplitude(){
        return amplitude;
    }

    /**
     * Returns the exponent value for this transfer function
     */
    public float getExponent(){
        return exponent;
    }

    /**
     * Returns the offset value for this transfer function
     */
    public float getOffset(){
        return offset;
    }
}

