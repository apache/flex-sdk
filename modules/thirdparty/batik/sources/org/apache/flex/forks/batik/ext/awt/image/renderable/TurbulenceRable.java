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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.geom.Rectangle2D;

/**
 * Creates a sourceless image from a turbulence function.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: TurbulenceRable.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface TurbulenceRable extends FilterColorInterpolation {

    /**
     * Sets the turbulence region
     * @param turbulenceRegion region to fill with turbulence function.
     */
    void setTurbulenceRegion(Rectangle2D turbulenceRegion);

    /**
     * Gets the turbulence region
     */
    Rectangle2D getTurbulenceRegion();

    /**
     * Gets the current seed value for the pseudo random number generator.
     * @return The current seed value for the pseudo random number generator.
     */
    int getSeed();

    /**
     * Gets the current base fequency in x direction.
     * @return The current base fequency in x direction.
     */
    double getBaseFrequencyX();

    /**
     * Gets the current base fequency in y direction.
     * @return The current base fequency in y direction.
     */
    double getBaseFrequencyY();

    /**
     * Gets the current number of octaves for the noise function .
     * @return The current number of octaves for the noise function .
     */
    int getNumOctaves();

    /**
     * Returns true if the turbulence function is currently stitching tiles.
     * @return true if the turbulence function is currently stitching tiles.
     */
    boolean isStitched();

    /**
     * Returns true if the turbulence function is using fractal noise,
     * instead of turbulence noise.
     * @return true if the turbulence function is using fractal noise,
     * instead of turbulence noise.
     */
    boolean isFractalNoise();

    /**
     * Sets the seed value for the pseudo random number generator.
     * @param seed The new seed value for the pseudo random number generator.
     */
    void setSeed(int seed);

    /**
     * Sets the base fequency in x direction.
     * @param xfreq The new base fequency in x direction.
     */
    void setBaseFrequencyX(double xfreq);

    /**
     * Sets the base fequency in y direction.
     * @param yfreq The new base fequency in y direction.
     */
    void setBaseFrequencyY(double yfreq);

    /**
     * Sets the number of octaves for the noise function .
     * @param numOctaves The new number of octaves for the noise function .
     */
    void setNumOctaves(int numOctaves);

    /**
     * Sets stitching state for tiles.
     * @param stitched true if the turbulence operator should stitch tiles.
     */
    void setStitched(boolean stitched);

    /**
     * Turns on/off fractal noise.
     * @param fractalNoise true if fractal noise should be used.
     */
    void setFractalNoise(boolean fractalNoise);
}


