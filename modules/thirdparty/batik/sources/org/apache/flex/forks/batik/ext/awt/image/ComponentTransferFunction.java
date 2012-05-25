/*

   Copyright 2001  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.image;

/**
 * Defines the interface expected from a component 
 * transfer function.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ComponentTransferFunction.java,v 1.3 2004/08/18 07:13:48 vhardy Exp $
 */
public interface ComponentTransferFunction {
    /**
     * The various transfer types
     */
    public static final int IDENTITY = 0;
    public static final int TABLE    = 1;
    public static final int DISCRETE = 2;
    public static final int LINEAR   = 3;
    public static final int GAMMA    = 4;

    /**
     * Returns the type of this transfer function
     */
    public int getType();

    /**
     * Returns the slope value for this transfer function
     */
    public float getSlope();

    /**
     * Returns the table values for this transfer function
     */
    public float[] getTableValues();

    /**
     * Returns the intercept value for this transfer function
     */
    public float getIntercept();

    /**
     * Returns the amplitude value for this transfer function
     */
    public float getAmplitude();

    /**
     * Returns the exponent value for this transfer function
     */
    public float getExponent();

    /**
     * Returns the offset value for this transfer function
     */
    public float getOffset();
}

