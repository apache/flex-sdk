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
 * @version $Id: PointLight.java 478363 2006-11-22 23:01:13Z dvholten $
 */
public class PointLight extends AbstractLight {
    /**
     * The light position, in user space
     */
    private double lightX, lightY, lightZ;

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

    public PointLight(double lightX, double lightY, double lightZ,
                      Color lightColor){
        super(lightColor);
        this.lightX = lightX;
        this.lightY = lightY;
        this.lightZ = lightZ;
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
     */
    public final void getLight(final double x, final double y, final double z,
                               final double[] L){

        double L0 = lightX - x;
        double L1 = lightY - y;
        double L2 = lightZ - z;

        final double norm = Math.sqrt( L0*L0 + L1*L1 + L2*L2 );

        if(norm > 0){
            final double invNorm = 1.0/norm;
            L0 *= invNorm;
            L1 *= invNorm;
            L2 *= invNorm;
        }

        // copy the work-variables into return-array
        L[ 0 ] = L0;
        L[ 1 ] = L1;
        L[ 2 ] = L2;
    }
}

