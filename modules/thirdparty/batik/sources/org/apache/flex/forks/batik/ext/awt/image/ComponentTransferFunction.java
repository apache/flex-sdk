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
 * Defines the interface expected from a component
 * transfer function.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ComponentTransferFunction.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public interface ComponentTransferFunction {
    /**
     * The various transfer types
     */
    int IDENTITY = 0;
    int TABLE    = 1;
    int DISCRETE = 2;
    int LINEAR   = 3;
    int GAMMA    = 4;

    /**
     * Returns the type of this transfer function
     */
    int getType();

    /**
     * Returns the slope value for this transfer function
     */
    float getSlope();

    /**
     * Returns the table values for this transfer function
     */
    float[] getTableValues();

    /**
     * Returns the intercept value for this transfer function
     */
    float getIntercept();

    /**
     * Returns the amplitude value for this transfer function
     */
    float getAmplitude();

    /**
     * Returns the exponent value for this transfer function
     */
    float getExponent();

    /**
     * Returns the offset value for this transfer function
     */
    float getOffset();
}

