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

import java.awt.Color;

/**
 * Top level interface to model a light element. A light is responsible for
 * computing the light vector on a given point of a surface. A light is
 * typically in a 3 dimensional space and the methods assumes the surface
 * is at elevation 0.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Light.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public interface Light {
    /**
     * @return true if the light is constant over the whole surface
     */
    boolean isConstant();

    /**
     * Computes the light vector in (x, y)
     *
     * @param x x-axis coordinate where the light should be computed
     * @param y y-axis coordinate where the light should be computed
     * @param z z-axis coordinate where the light should be computed
     * @param L array of length 3 where the result is stored
     */
    void getLight(final double x, final double y, final double z, final double[] L);

    /**
     * Returns a light map, starting in (x, y) with dx, dy increments, a given
     * width and height, and z elevations stored in the fourth component on the
     * N array.
     *
     * @param x x-axis coordinate where the light should be computed
     * @param y y-axis coordinate where the light should be computed
     * @param dx delta x for computing light vectors in user space
     * @param dy delta y for computing light vectors in user space
     * @param width number of samples to compute on the x axis
     * @param height number of samples to compute on the y axis
     * @param z array containing the z elevation for all the points
     *
     * @return an array of height rows, width columns where each element
     *         is an array of three components representing the x, y and z
     *         components of the light vector.
     */
    double[][][] getLightMap(double x, double y,
                                  final double dx, final double dy,
                                  final int width, final int height,
                                  final double[][][] z);

    /**
     * Returns a row of the light map, starting at (x, y) with dx
     * increments, a given width, and z elevations stored in the
     * fourth component on the N array.
     *
     * @param x x-axis coordinate where the light should be computed
     * @param y y-axis coordinate where the light should be computed
     * @param dx delta x for computing light vectors in user space
     * @param width number of samples to compute on the x axis
     * @param z array containing the z elevation for all the points
     * @param lightRow array to store the light info to, if null it will
     *                 be allocated for you and returned.
     *
     * @return an array width columns where each element
     *         is an array of three components representing the x, y and z
     *         components of the light vector.  */
    double[][] getLightRow(double x, double y,
                                  final double dx, final int width,
                                  final double[][] z,
                                  final double[][] lightRow);

    /**
     * @param  linear if true the color is returned in the Linear sRGB
     *                colorspace otherwise the color is in the gamma
     *                corrected sRGB color space.
     * @return the light's color
     */
    double[] getColor(boolean linear);

    /**
     * Sets the light color to a new value
     */
    void setColor(Color color);
}

