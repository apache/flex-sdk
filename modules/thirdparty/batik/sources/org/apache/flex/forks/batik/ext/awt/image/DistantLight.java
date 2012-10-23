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
 * A light source placed at the infinity, such that the light angle is
 * constant over the whole surface.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: DistantLight.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class DistantLight extends AbstractLight {
    /**
     * The azimuth of the distant light, i.e., the angle of the light vector
     * on the (X, Y) plane
     */
    private double azimuth;

    /**
     * The elevation of the distant light, i.e., the angle of the light
     * vector on the (X, Z) plane.
     */
    private double elevation;

    /**
     * Light vector
     */
    private double Lx, Ly, Lz;

    /**
     * @return the DistantLight's azimuth
     */
    public double getAzimuth(){
        return azimuth;
    }

    /**
     * @return the DistantLight's elevation
     */
    public double getElevation(){
        return elevation;
    }

    public DistantLight(double azimuth, double elevation, Color color){
        super(color);

        this.azimuth = azimuth;
        this.elevation = elevation;

        Lx = Math.cos( Math.toRadians( azimuth ) ) * Math.cos( Math.toRadians( elevation ) );
        Ly = Math.sin( Math.toRadians( azimuth ) ) * Math.cos( Math.toRadians( elevation ) );
        Lz = Math.sin( Math.toRadians( elevation ));
    }

    /**
     * @return true if the light is constant over the whole surface
     */
    public boolean isConstant(){
        return true;
    }

    /**
     * Computes the light vector in (x, y)
     *
     * @param x x-axis coordinate where the light should be computed
     * @param y y-axis coordinate where the light should be computed
     * @param L array of length 3 where the result is stored
     */
    public void getLight(final double x, final double y, final double z,
                         final double[] L){
        L[0] = Lx;
        L[1] = Ly;
        L[2] = Lz;
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

        if (ret == null) {
            // If we are allocating then use the same light vector for
            // all entries.
            ret = new double[width][];

            double[] CL = new double[3];
            CL[0]=Lx;
            CL[1]=Ly;
            CL[2]=Lz;

            for(int i=0; i<width; i++){
                ret[i] = CL;
            }
        } else {
            final double lx = Lx;
            final double ly = Ly;
            final double lz = Lz;

            for(int i=0; i<width; i++){
                ret[i][0] = lx;
                ret[i][1] = ly;
                ret[i][2] = lz;
            }
        }

        return ret;
    }
}

