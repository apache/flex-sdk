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

import java.awt.Rectangle;
import java.awt.Shape;
import java.awt.color.ColorSpace;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.rendered.TurbulencePatternRed;

/**
 * Creates a sourceless image from a turbulence function.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: TurbulenceRable8Bit.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public class TurbulenceRable8Bit
    extends    AbstractColorInterpolationRable
    implements TurbulenceRable {

    int     seed          = 0;     // Seed value to pseudo rand num gen.
    int     numOctaves    = 1;     // number of octaves in turbulence function
    double  baseFreqX     = 0;     // Frequency in X/Y directions
    double  baseFreqY     = 0;
    boolean stitched       = false; // True if tiles are stitched
    boolean fractalNoise = false; // True if fractal noise should be used.

    Rectangle2D region;

    public TurbulenceRable8Bit(Rectangle2D region) {
        super();
        this.region = region;
    }

    public TurbulenceRable8Bit(Rectangle2D region,
                                   int         seed,
                                   int         numOctaves,
                                   double      baseFreqX,
                                   double      baseFreqY,
                                   boolean     stitched,
                                   boolean     fractalNoise) {
        super();
        this.seed          = seed;
        this.numOctaves    = numOctaves;
        this.baseFreqX     = baseFreqX;
        this.baseFreqY     = baseFreqY;
        this.stitched      = stitched;
        this.fractalNoise  = fractalNoise;
        this.region        = region;
    }

    /**
     * Get the turbulence region
     */
    public Rectangle2D getTurbulenceRegion() {
        return (Rectangle2D)region.clone();
    }

    /**
     * Get the turbulence region
     */
    public Rectangle2D getBounds2D() {
        return (Rectangle2D)region.clone();
    }

    /**
     * Get the current seed value for the pseudo random number generator.
     * @return The current seed value for the pseudo random number generator.
     */
    public int getSeed() {
        return seed;
    }

    /**
     * Get the current number of octaves for the noise function .
     * @return The current number of octaves for the noise function .
     */
    public int getNumOctaves() {
        return numOctaves;
    }

    /**
     * Get the current base fequency in x direction.
     * @return The current base fequency in x direction.
     */
    public double getBaseFrequencyX() {
        return baseFreqX;
    }

    /**
     * Get the current base fequency in y direction.
     * @return The current base fequency in y direction.
     */
    public double getBaseFrequencyY() {
        return baseFreqY;
    }

    /**
     * Returns true if the turbulence function is currently stitching tiles.
     * @return true if the turbulence function is currently stitching tiles.
     */
    public boolean isStitched() {
        return stitched;
    }

    /**
     * Returns true if the turbulence function is using fractal noise,
     * instead of turbulence noise.
     * @return true if the turbulence function is using fractal noise,
     * instead of turbulence noise.
     */
    public boolean isFractalNoise() {
        return fractalNoise;
    }

    /**
     * Sets the turbulence region
     * @param turbulenceRegion region to fill with turbulence function.
     */
    public void setTurbulenceRegion(Rectangle2D turbulenceRegion) {
        touch();
        this.region = turbulenceRegion;
    }

    /**
     * Set the seed value for the pseudo random number generator.
     * @param seed The new seed value for the pseudo random number generator.
     */
    public void setSeed(int seed) {
        touch();
        this.seed = seed;
    }

    /**
     * Set the number of octaves for the noise function .
     * @param numOctaves The new number of octaves for the noise function .
     */
    public void setNumOctaves(int numOctaves) {
        touch();
        this.numOctaves = numOctaves;
    }

    /**
     * Set the base fequency in x direction.
     * @param baseFreqX The new base fequency in x direction.
     */
    public void setBaseFrequencyX(double baseFreqX) {
        touch();
        this.baseFreqX = baseFreqX;
    }

    /**
     * Set the base fequency in y direction.
     * @param baseFreqY The new base fequency in y direction.
     */
    public void setBaseFrequencyY(double baseFreqY) {
        touch();
        this.baseFreqY = baseFreqY;
    }

    /**
     * Set stitching state for tiles.
     * @param stitched true if the turbulence operator should stitch tiles.
     */
    public void setStitched(boolean stitched) {
        touch();
        this.stitched = stitched;
    }

    /**
     * Turns on/off fractal noise.
     * @param fractalNoise true if fractal noise should be used.
     */
    public void setFractalNoise(boolean fractalNoise) {
        touch();
        this.fractalNoise = fractalNoise;
    }

    public RenderedImage createRendering(RenderContext rc){

        Rectangle2D aoiRect;
        Shape aoi = rc.getAreaOfInterest();
        if(aoi == null){
            aoiRect = getBounds2D();
        } else {
            Rectangle2D rect = getBounds2D();
            aoiRect          = aoi.getBounds2D();
            if ( ! aoiRect.intersects(rect) )
                return null;
            Rectangle2D.intersect(aoiRect, rect, aoiRect);
        }

        AffineTransform usr2dev = rc.getTransform();

        // Compute size of raster image in device space.
        // System.out.println("Turbulence aoi : " + aoi);
        // System.out.println("Scale X : " + usr2dev.getScaleX() + " scaleY : " + usr2dev.getScaleY());
        // System.out.println("Turbulence aoi dev : " + usr2dev.createTransformedShape(aoi).getBounds());
        final Rectangle devRect
            = usr2dev.createTransformedShape(aoiRect).getBounds();

        if ((devRect.width <= 0) ||
            (devRect.height <= 0))
            return null;

        ColorSpace cs = getOperationColorSpace();

        Rectangle2D tile = null;
        if (stitched)
            tile = (Rectangle2D)region.clone();

        AffineTransform patternTxf = new AffineTransform();
        try{
            patternTxf = usr2dev.createInverse();
        }catch(NoninvertibleTransformException e){
        }

        return new TurbulencePatternRed
            (baseFreqX, baseFreqY, numOctaves, seed, fractalNoise,
             tile, patternTxf, devRect, cs, true);
    }
}
