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
 * A light source which emits a light of constant intensity in all directions.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SpotLight.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class SpotLight extends AbstractLight {
    /**
     * The light position, in user space
     */
    private double lightX, lightY, lightZ;

    /**
     * Point where the light points to
     */
    private double pointAtX, pointAtY, pointAtZ;

    /**
     * Specular exponent (light focus)
     */
    private double specularExponent;

    /**
     * Limiting cone angle
     */
    private double limitingConeAngle, limitingCos;

    /**
     * Light direction vector
     */
    private final double[] S = new double[3];

    /**
     * @return the light's x position
     */
    public double getLightX(){
        return lightX;
    }

    /**
     * @return the light's y position
     */
    public double getLightY(){
        return lightY;
    }

    /**
     * @return the light's z position
     */
    public double getLightZ(){
        return lightZ;
    }

    /**
     * @return x-axis coordinate where the light points to
     */
    public double getPointAtX(){
        return pointAtX;
    }

    /**
     * @return y-axis coordinate where the light points to
     */
    public double getPointAtY(){
        return pointAtY;
    }

    /**
     * @return z-axis coordinate where the light points to
     */
    public double getPointAtZ(){
        return pointAtZ;
    }

    /**
     * @return light's specular exponent (focus)
     */
    public double getSpecularExponent(){
        return specularExponent;
    }

    /**
     * @return light's limiting cone angle
     */
    public double getLimitingConeAngle(){
        return limitingConeAngle;
    }

    public SpotLight(double lightX, double lightY, double lightZ,
                     double pointAtX, double pointAtY, double pointAtZ,
                     double specularExponent, double limitingConeAngle,
                     Color lightColor){
        super(lightColor);

        this.lightX = lightX;
        this.lightY = lightY;
        this.lightZ = lightZ;
        this.pointAtX = pointAtX;
        this.pointAtY = pointAtY;
        this.pointAtZ = pointAtZ;
        this.specularExponent = specularExponent;
        this.limitingConeAngle = limitingConeAngle;
        this.limitingCos = Math.cos( Math.toRadians( limitingConeAngle ) );

        S[0] = pointAtX - lightX;
        S[1] = pointAtY - lightY;
        S[2] = pointAtZ - lightZ;

        double invNorm = 1/Math.sqrt(S[0]*S[0] + S[1]*S[1] + S[2]*S[2]);

        S[0] *= invNorm;
        S[1] *= invNorm;
        S[2] *= invNorm;
    }

    /**
     * @return true if the light is constant over the whole surface
     */
    public boolean isConstant(){
        return false;
    }

    /**
     * Computes the light vector in (x, y, z)
     *
     * @param x x-axis coordinate where the light should be computed
     * @param y y-axis coordinate where the light should be computed
     * @param z z-axis coordinate where the light should be computed
     * @param L array of length 3 where the result is stored
     * @return the intensity factor for this light vector.
     */
    public final double getLightBase(final double x, final double y,
                                     final double z,
                                     final double[] L){
        // Light Vector, L
        double L0 = lightX - x;
        double L1 = lightY - y;
        double L2 = lightZ - z;

        final double invNorm = 1.0/Math.sqrt( L0*L0 + L1*L1 + L2*L2 );

        L0 *= invNorm;
        L1 *= invNorm;
        L2 *= invNorm;

        double LS = -(L0*S[0] + L1*S[1] + L2*S[2]);

        // copy the work-variables into return-array
        L[0] = L0;
        L[1] = L1;
        L[2] = L2;

        if(LS <= limitingCos){
            return 0;
        } else {
            double Iatt = limitingCos/LS;
            Iatt *= Iatt;
            Iatt *= Iatt;
            Iatt *= Iatt;
            Iatt *= Iatt;
            Iatt *= Iatt;
            Iatt *= Iatt; // akin Math.pow(Iatt, 64)

            Iatt = 1 - Iatt;
            return Iatt*Math.pow(LS, specularExponent);
        }
    }

    /**
     * Computes the light vector in (x, y, z)
     *
     * @param x x-axis coordinate where the light should be computed
     * @param y y-axis coordinate where the light should be computed
     * @param z z-axis coordinate where the light should be computed
     * @param L array of length 3 where the result is stored,
     *          x,y,z are scaled by light intensity.
     */
    public final void getLight(final double x, final double y,
                               final double z,
                               final double[] L){
        final double s = getLightBase(x, y, z, L);
        L[0] *= s;
        L[1] *= s;
        L[2] *= s;
    }

    /**
     * computes light vector in (x, y, z).
     *
     * @param x x-axis coordinate where the light should be computed
     * @param y y-axis coordinate where the light should be computed
     * @param z z-axis coordinate where the light should be computed
     * @param L array of length 4 where result is stored.
     *          0,1,2 are x,y,z respectively of light vector (normalized).
     *          3 is the intensity of the light at this point.
     */
    public final void getLight4(final double x, final double y, final double z,
                               final double[] L){
        L[3] = getLightBase(x, y, z, L);
    }

    public double[][] getLightRow4(double x, double y,
                                  final double dx, final int width,
                                  final double[][] z,
                                  final double[][] lightRow) {
        double [][] ret = lightRow;
        if (ret == null)
            ret = new double[width][4];

        for(int i=0; i<width; i++){
            getLight4(x, y, z[i][3], ret[i]);
            x += dx;
        }

        return ret;
    }

}

