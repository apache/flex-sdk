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
 * An abstract implementation of the Light interface.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: AbstractLight.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class AbstractLight implements Light {
    /**
     * Conversion function for light values.
     */
    public static final double sRGBToLsRGB(double value) {
        if(value <= 0.003928)
            return value/12.92;
        return Math.pow((value+0.055)/1.055, 2.4);
    }

    /**
     * Light color in linear sRGB
     */
    private double[] color;

    /**
     * @param  linear if true the color is returned in the Linear sRGB
     *                colorspace otherwise the color is in the gamma
     *                corrected sRGB color space.
     * @return the light's color 
     */
    public double[] getColor(boolean linear){
        double [] ret = new double[3];
        if (linear) {
            ret[0] = sRGBToLsRGB(color[0]);
            ret[1] = sRGBToLsRGB(color[1]);
            ret[2] = sRGBToLsRGB(color[2]);
        } else {
            ret[0] = color[0];
            ret[1] = color[1];
            ret[2] = color[2];
        }
        return ret;
    }

    public AbstractLight(Color color){
        setColor(color);
    }

    /**
     * Sets the new light color, <tt>newColor</tt> should be in sRGB.
     */
    public void setColor(Color newColor){
        color = new double[3];
        color[0] = newColor.getRed()  /255.;
        color[1] = newColor.getGreen()/255.;
        color[2] = newColor.getBlue() /255.;
    }

    /**
     * @return true if the light is constant over the whole surface
     */
    public boolean isConstant(){
        return true;
    }

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
     */
    public double[][][] getLightMap(double x, double y, 
                                    final double dx, final double dy,
                                    final int width, final int height,
                                    final double[][][] z)
    {
        double[][][] L = new double[height][][];

        for(int i=0; i<height; i++){
            L[i] = getLightRow(x, y, dx, width, z[i], null);
            y += dy;
        }

        return L;
    }

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
    public double[][] getLightRow(double x, double y, 
                                  final double dx, final int width,
                                  final double[][] z,
                                  final double[][] lightRow) {
        double [][] ret = lightRow;
        if (ret == null) 
            ret = new double[width][3];

        for(int i=0; i<width; i++){
            getLight(x, y, z[i][3], ret[i]);
            x += dx;
        }

        return ret;
    }
}


