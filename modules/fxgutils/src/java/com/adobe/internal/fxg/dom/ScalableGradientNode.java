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

package com.adobe.internal.fxg.dom;

import com.adobe.internal.fxg.dom.transforms.MatrixNode;

/**
 * A marker interface to denote that an FXG node represents a type of 
 * scalable gradient. 
 * 
 * @author Peter Farland
 */
public interface ScalableGradientNode
{
    /**
     * Get x.
     * @return The horizontal distance to translate the gradient.
     */
    double getX();
    
    /**
     * Get y.
     * @return The vertical distance to translate the gradient.
     */
    double getY();

    /**
     * Get scaleX.
     * @return The horizontal distance of the unrotated gradient (that will be
     * compared to the target's width to calculate a scale ratio). Note this
     * is different from a shape transform scale.
     */
    double getScaleX();

    /**
     * Get scaleY.
     * @return The horizontal distance of the unrotated gradient (that will be
     * compared to the target's width to calculate a scale ratio). Note this
     * is different from a shape transform scale.
     */
    double getScaleY();

    /**
     * Get rotation.
     * @return The clockwise rotation angle in degrees. 
     */
    double getRotation();

    /**
     * Get matrix.
     * @return A pre-calculated matrix to be used instead of the individual
     * transform properties.
     */
    MatrixNode getMatrixNode();

    /**
     * Check is the gradient is linear.
     * @return true if this gradient is linear.
     */
    boolean isLinear();
}
