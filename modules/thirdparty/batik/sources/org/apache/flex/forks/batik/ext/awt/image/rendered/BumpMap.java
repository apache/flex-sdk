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
package org.apache.flex.forks.batik.ext.awt.image.rendered;

import java.awt.Rectangle;
import java.awt.image.DataBufferInt;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.SinglePixelPackedSampleModel;

/**
 * Default BumpMap implementation.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: BumpMap.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public final class BumpMap {
    /**
     * Image whose alpha channel is used for the
     * normal calculation
     */
    private RenderedImage texture;

    /**
     * Surface scale used in the normal computation
     */
    private double surfaceScale, surfaceScaleX, surfaceScaleY;

    /**
     * User space to device space scale factors
     */
    private double scaleX, scaleY;

    /**
     * Stores the normals for this bumpMap.
     * scaleX and scaleY are the user space to device
     * space scales.
     */
    public BumpMap(RenderedImage texture,
                   double surfaceScale,
                   double scaleX, double scaleY){
        this.texture = texture;
        this.surfaceScaleX = surfaceScale*scaleX;
        this.surfaceScaleY = surfaceScale*scaleY;
        this.surfaceScale = surfaceScale;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
    }

    /**
     * @return surface scale used by this bump map.
     */
    public double getSurfaceScale(){
        return surfaceScale;
    }

    /**
     * @param x x-axis coordinate for which the normal is computed
     * @param y y-axis coordinate for which the normal is computed
     */
    public double[][][] getNormalArray
        (final int x, final int y,
         final int w, final int h)
    {
        final double[][][] N = new double[h][w][4];

        Rectangle srcRect = new Rectangle(x-1, y-1, w+2, h+2);
        Rectangle srcBound = new Rectangle
            (texture.getMinX(), texture.getMinY(),
             texture.getWidth(), texture.getHeight());

        if ( ! srcRect.intersects(srcBound) )
            return N;

        srcRect = srcRect.intersection(srcBound);
        final Raster r = texture.getData(srcRect);

        srcRect = r.getBounds();

        // System.out.println("SrcRect: " + srcRect);
        // System.out.println("rect: [" +
        //                    x + ", " + y + ", " +
        //                    w + ", " + h + "]");

        final DataBufferInt db = (DataBufferInt)r.getDataBuffer();


        final int[] pixels = db.getBankData()[0];

        final SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)r.getSampleModel();


        final int scanStride = sppsm.getScanlineStride();
        final int scanStridePP = scanStride + 1;
        final int scanStrideMM = scanStride - 1;
        double prpc=0, prcc=0, prnc=0;
        double crpc=0, crcc=0, crnc=0;
        double nrpc=0, nrcc=0, nrnc=0;
        double invNorm;

        final double quarterSurfaceScaleX = surfaceScaleX / 4f;
        final double quarterSurfaceScaleY = surfaceScaleY / 4f;
        final double halfSurfaceScaleX = surfaceScaleX / 2f;
        final double halfSurfaceScaleY = surfaceScaleY /2;
        final double thirdSurfaceScaleX = surfaceScaleX / 3f;
        final double thirdSurfaceScaleY = surfaceScaleY / 3f;
        final double twoThirdSurfaceScaleX = surfaceScaleX * 2 / 3f;
        final double twoThirdSurfaceScaleY = surfaceScaleY * 2 / 3f;

        final double pixelScale = 1.0/255;

        if(w <= 0)
            return N;
        // Process pixels on the border
        if(h <= 0)
            return N;

        final int xEnd   = Math.min(srcRect.x+srcRect.width -1, x+w);
        final int yEnd   = Math.min(srcRect.y+srcRect.height-1, y+h);
        final int offset =
            (db.getOffset() +
             sppsm.getOffset(srcRect.x -r.getSampleModelTranslateX(),
                             srcRect.y -r.getSampleModelTranslateY()));

        int yloc=y;
        if (yloc < srcRect.y) {
            yloc = srcRect.y;
        }

        // Top edge extend filters...
        if (yloc == srcRect.y) {
            if (yloc == yEnd) {
                // Only one row of pixels...
                final double [][] NRow = N[yloc-y];
                int xloc=x;
                if (xloc < srcRect.x)
                    xloc = srcRect.x;
                int p  = (offset + (xloc-srcRect.x) +
                          scanStride*(yloc-srcRect.y));

                crcc = (pixels[p] >>> 24)*pixelScale;

                if (xloc != srcRect.x) {
                    crpc = (pixels[p - 1] >>> 24)*pixelScale;
                }
                else if (xloc < xEnd) {
                    // Top left pixel, in src (0, 0);
                    crnc = (pixels[p+1] >>> 24)*pixelScale;

                    final double [] n = NRow[xloc-x];

                    n[0] = 2*surfaceScaleX*(crcc - crnc);
                    invNorm = 1.0/Math.sqrt(n[0]*n[0] + 1);
                    n[0] *= invNorm;
                    n[1]  = 0;
                    n[2]  = invNorm;
                    n[3]  = crcc*surfaceScale;
                    p++;
                    xloc++;
                    crpc = crcc;
                    crcc = crnc;
                } else {
                    // Single pix.
                    crpc = crcc;
                }

                for (; xloc<xEnd; xloc++) {
                    // Middle Top row...
                    crnc = (pixels[p+1] >>> 24)*pixelScale;
                    final double [] n = NRow[xloc-x];

                    n[0] = surfaceScaleX * (crpc - crnc );
                    invNorm = 1.0/Math.sqrt(n[0]*n[0] + 1);
                    n[0] *= invNorm;
                    n[1]  = 0;
                    n[2]  = invNorm;
                    n[3]  = crcc*surfaceScale;
                    p++;
                    crpc = crcc;
                    crcc = crnc;
                }

                if ((xloc < x+w) &&
                    (xloc == srcRect.x+srcRect.width-1)) {
                    // Last pixel of top row
                    final double [] n = NRow[xloc-x];

                    n[0] = 2*surfaceScaleX*(crpc - crcc);
                    invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                    n[0] *= invNorm;
                    n[1] *= invNorm;
                    n[2]  = invNorm;
                    n[3]  = crcc*surfaceScale;
                }
                return N;
            }

            final double [][] NRow = N[yloc-y];
            int p  = offset + scanStride*(yloc-srcRect.y);
            int xloc=x;
            if (xloc < srcRect.x)
                xloc = srcRect.x;
            p += xloc-srcRect.x;

            crcc = (pixels[p] >>> 24)*pixelScale;
            nrcc = (pixels[p + scanStride] >>> 24)*pixelScale;

            if (xloc != srcRect.x) {
                crpc = (pixels[p - 1] >>> 24)*pixelScale;
                nrpc = (pixels[p + scanStrideMM] >>> 24)*pixelScale;
            }
            else if (xloc < xEnd) {
                // Top left pixel, in src (0, 0);
                crnc = (pixels[p+1] >>> 24)*pixelScale;
                nrnc = (pixels[p + scanStridePP] >>> 24)*pixelScale;

                final double [] n = NRow[xloc-x];

                n[0] = - twoThirdSurfaceScaleX *
                    ((2*crnc + nrnc - 2*crcc - nrcc));
                n[1] = - twoThirdSurfaceScaleY *
                    ((2*nrcc + nrnc - 2*crcc - crnc));
                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;
                p++;
                xloc++;
                crpc = crcc;
                nrpc = nrcc;
                crcc = crnc;
                nrcc = nrnc;
            } else {
                // Single pix
                crpc = crcc;
                nrpc = nrcc;
            }

            for (; xloc<xEnd; xloc++) {
                // Middle Top row...
                crnc = (pixels[p+1] >>> 24)*pixelScale;
                nrnc = (pixels[p + scanStridePP] >>> 24)*pixelScale;

                final double [] n = NRow[xloc-x];

                n[0] = - thirdSurfaceScaleX * (( 2*crnc + nrnc)
                                               - (2*crpc + nrpc));
                n[1] = - halfSurfaceScaleY *(( nrpc + 2*nrcc + nrnc)
                                             - (crpc + 2*crcc + crnc));

                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;
                p++;
                crpc = crcc;
                nrpc = nrcc;
                crcc = crnc;
                nrcc = nrnc;
            }

            if ((xloc < x+w) &&
                (xloc == srcRect.x+srcRect.width-1)) {
                // Last pixel of top row
                final double [] n = NRow[xloc-x];

                n[0] = - twoThirdSurfaceScaleX *(( 2*crcc + nrcc)
                                                 - (2*crpc + nrpc));
                n[1] = - twoThirdSurfaceScaleY *(( 2*nrcc + nrpc)
                                                 - (2*crcc + crpc));

                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;
            }
            yloc++;
        }

        for (; yloc<yEnd; yloc++) {
            final double [][] NRow = N[yloc-y];
            int p  = offset + scanStride*(yloc-srcRect.y);

            int xloc=x;
            if (xloc < srcRect.x)
                xloc = srcRect.x;

            p += xloc-srcRect.x;

            prcc = (pixels[p - scanStride] >>> 24)*pixelScale;
            crcc = (pixels[p] >>> 24)*pixelScale;
            nrcc = (pixels[p + scanStride] >>> 24)*pixelScale;

            if (xloc != srcRect.x) {
                prpc = (pixels[p - scanStridePP] >>> 24)*pixelScale;
                crpc = (pixels[p - 1] >>> 24)*pixelScale;
                nrpc = (pixels[p + scanStrideMM] >>> 24)*pixelScale;
            }
            else if (xloc < xEnd) {
                // Now, process left column, from (0, 1) to (0, h-1)
                crnc = (pixels[p+1] >>> 24)*pixelScale;
                prnc = (pixels[p - scanStrideMM] >>> 24)*pixelScale;
                nrnc = (pixels[p + scanStridePP] >>> 24)*pixelScale;

                final double [] n = NRow[xloc-x];

                n[0] = - halfSurfaceScaleX *(( prnc + 2*crnc + nrnc)
                                             - (prcc + 2*crcc + nrcc));
                n[1] = - thirdSurfaceScaleY *(( 2*prcc + prnc)
                                              - ( 2*crcc + crnc));

                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;

                p++;
                xloc++;

                prpc = prcc;
                crpc = crcc;
                nrpc = nrcc;
                prcc = prnc;
                crcc = crnc;
                nrcc = nrnc;
            } else {
                // Single pix
                prpc = prcc;
                crpc = crcc;
                nrpc = nrcc;
            }

            for (; xloc<xEnd; xloc++) {
                // Middle Middle row...
                prnc = (pixels[p - scanStrideMM] >>> 24)*pixelScale;
                crnc = (pixels[p+1] >>> 24)*pixelScale;
                nrnc = (pixels[p + scanStridePP] >>> 24)*pixelScale;

                final double [] n = NRow[xloc-x];

                n[0] = - quarterSurfaceScaleX *(( prnc + 2*crnc + nrnc)
                                                - (prpc + 2*crpc + nrpc));
                n[1] = - quarterSurfaceScaleY *(( nrpc + 2*nrcc + nrnc)
                                                - (prpc + 2*prcc + prnc));

                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;

                p++;
                prpc = prcc;
                crpc = crcc;
                nrpc = nrcc;
                prcc = prnc;
                crcc = crnc;
                nrcc = nrnc;
            }

            if ((xloc < x+w) &&
                (xloc == srcRect.x+srcRect.width-1)) {
                // Now, proces right column, from (w-1, 1) to (w-1, h-1)
                final double [] n = NRow[xloc-x];

                n[0] = - halfSurfaceScaleX *( (prcc + 2*crcc + nrcc)
                                             -(prpc + 2*crpc + nrpc));
                n[1] = - thirdSurfaceScaleY *(( nrpc + 2*nrcc)
                                              - ( prpc + 2*prcc));

                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;
            }
        }

        if ((yloc < y+h) &&
            (yloc == srcRect.y+srcRect.height-1)) {
            final double [][] NRow = N[yloc-y];
            int p  = offset + scanStride*(yloc-srcRect.y);
            int xloc=x;
            if (xloc < srcRect.x)
                xloc = srcRect.x;

            p += xloc-srcRect.x;

            crcc = (pixels[p] >>> 24)*pixelScale;
            prcc = (pixels[p - scanStride] >>> 24)*pixelScale;

            if (xloc != srcRect.x) {
                prpc = (pixels[p - scanStridePP] >>> 24)*pixelScale;
                crpc = (pixels[p - 1] >>> 24)*pixelScale;
            }
            else if (xloc < xEnd) {
                // Process first pixel of last row
                crnc = (pixels[p + 1] >>> 24)*pixelScale;
                prnc = (pixels[p - scanStrideMM] >>> 24)*pixelScale;

                final double [] n = NRow[xloc-x];

                n[0] = - twoThirdSurfaceScaleX * ((2*crnc + prnc - 2*crcc - prcc));
                n[1] = - twoThirdSurfaceScaleY * ((2*crcc + crnc - 2*prcc - prnc));
                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;

                p++;
                xloc++;
                crpc = crcc;
                prpc = prcc;
                crcc = crnc;
                prcc = prnc;
            } else {
                // Single pix
                crpc = crcc;
                prpc = prcc;
            }

            for (; xloc<xEnd; xloc++) {
                // Middle of Bottom row...
                crnc = (pixels[p + 1] >>> 24)*pixelScale;
                prnc = (pixels[p - scanStrideMM] >>> 24)*pixelScale;

                // System.out.println("Vals: " +
                //                    prpc + "," + prcc + "," + prnc + "  " +
                //                    crpc + "," + crcc + "," + crnc );

                final double [] n = NRow[xloc-x];

                n[0] = - thirdSurfaceScaleX *(( 2*crnc + prnc)
                                              - (2*crpc + prpc));
                n[1] = - halfSurfaceScaleY *(( crpc + 2*crcc + crnc)
                                             - (prpc + 2*prcc + prnc));

                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;

                p++;
                crpc = crcc;
                prpc = prcc;
                crcc = crnc;
                prcc = prnc;
            }

            if ((xloc < x+w) &&
                (xloc == srcRect.x+srcRect.width-1)) {
                // Bottom right corner
                final double [] n = NRow[xloc-x];

                n[0] = - twoThirdSurfaceScaleX *(( 2*crcc + prcc)
                                                 - (2*crpc + prpc));
                n[1] = - twoThirdSurfaceScaleY *(( 2*crcc + crpc)
                                                 - (2*prcc + prpc));

                invNorm = 1.0/Math.sqrt(n[0]*n[0] + n[1]*n[1] + 1);
                n[0] *= invNorm;
                n[1] *= invNorm;
                n[2]  = invNorm;
                n[3]  = crcc*surfaceScale;
            }
        }
        return N;
    }
}

