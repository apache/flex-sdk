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
import java.awt.image.ColorModel;
import java.awt.image.DataBufferInt;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.Light;
import org.apache.flex.forks.batik.ext.awt.image.SpotLight;

/**
 * 
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SpecularLightingRed.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SpecularLightingRed extends AbstractTiledRed{
    /**
     * Specular lighting constant
     */
    private double ks;

    /**
     * Specular lighting exponent
     */
    private double specularExponent;

    /**
     * Light used for specular lighting
     */
    private Light light;

    /**
     * BumpMap source
     */
    private BumpMap bumpMap;

    /**
     * Device space to user space scale factors, along
     * each axis.
     */
    private double scaleX, scaleY;

    /**
     * LitRegion
     */
    private Rectangle litRegion;

    /**
     * true if calculations should be performed in linear sRGB
     */
    private boolean linear;
     

    public SpecularLightingRed(double ks,
                               double specularExponent,
                               Light light,
                               BumpMap bumpMap,
                               Rectangle litRegion,
                               double scaleX, double scaleY,
                               boolean linear) {
        this.ks = ks;
        this.specularExponent = specularExponent;
        this.light = light;
        this.bumpMap = bumpMap;
        this.litRegion = litRegion;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        this.linear = linear;

        ColorModel cm;
        if (linear)
            cm = GraphicsUtil.Linear_sRGB_Unpre;
        else
            cm = GraphicsUtil.sRGB_Unpre;

        int tw = litRegion.width;
        int th = litRegion.height;
        int defSz = AbstractTiledRed.getDefaultTileSize();
        if (tw > defSz) tw = defSz;
        if (th > defSz) th = defSz;
        SampleModel sm = cm.createCompatibleSampleModel(tw, th);
                                             
        init((CachableRed)null, litRegion, cm, sm,
             litRegion.x, litRegion.y, null);
    }

    public WritableRaster copyData(WritableRaster wr) {
        copyToRaster(wr);
        return wr;
    }

    public void genRect(WritableRaster wr) {
        // Copy variable on stack for faster access in tight loop
        final double scaleX = this.scaleX;
        final double scaleY = this.scaleY;

        final double[] lightColor = light.getColor(linear);

        final int w = wr.getWidth();
        final int h = wr.getHeight();
        final int minX = wr.getMinX();
        final int minY = wr.getMinY();

        final DataBufferInt db = (DataBufferInt)wr.getDataBuffer();
        final int[] pixels = db.getBankData()[0];

        final SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)wr.getSampleModel();

        final int offset = 
            (db.getOffset() +
             sppsm.getOffset(minX-wr.getSampleModelTranslateX(), 
                             minY-wr.getSampleModelTranslateY()));
        // int offset = db.getOffset();
        final int scanStride = sppsm.getScanlineStride();
        final int adjust = scanStride - w;
        int p = offset;
        int a=0, i=0, j=0;

        // x and y are in user space
        double x = scaleX*minX;
        double y = scaleY*minY;
        double norm = 0;

        int pixel = 0, tmp;
        double mult;
        mult = (lightColor[0]>lightColor[1])?lightColor[0]:lightColor[1];
        mult = (mult>lightColor[2])?mult:lightColor[2];
        
        double scale = 255/mult;
        pixel = (int)(lightColor[0]*scale+0.5);
        tmp   = (int)(lightColor[1]*scale+0.5);
        pixel = pixel<<8 | tmp;
        tmp   = (int)(lightColor[2]*scale+0.5);
        pixel = pixel<<8 | tmp;

        mult*=255*ks;

        // System.out.println("Pixel: 0x" + Integer.toHexString(pixel));

        final double[][][] NA = bumpMap.getNormalArray(minX, minY, w, h);

        // System.out.println("Entering Specular Lighting");
        if (light instanceof SpotLight) {
            SpotLight slight = (SpotLight)light;
            final double[][] LA = new double[w][4];
            for(i=0; i<h; i++){
                // System.out.println("Row: " + i);
                final double [][] NR = NA[i];
                slight.getLightRow4(x, y+i*scaleY, scaleX, w, NR, LA);
                for (j=0; j<w; j++){
                    // Get Normal 
                    final double [] N = NR[j];
                    
                    // Get Light Vector
                    final double [] L = LA[j];
                    double vs = L[3];
                    if (vs == 0) {
                        a = 0;
                    } else {
                        L[2] += 1;
                        norm = L[0]*L[0] + L[1]*L[1] + L[2]*L[2];
                        norm = Math.sqrt(norm);
                        double dot = N[0]*L[0] + N[1]*L[1] + N[2]*L[2];
                        vs = vs*Math.pow(dot/norm, specularExponent);
                        a = (int)(mult*vs + 0.5);
                        if ((a & 0xFFFFFF00) != 0)
                            a = ((a & 0x80000000) != 0)?0:255;
                    }
                    pixels[p++] = (a << 24 | pixel);
                }
                p += adjust;
            }
        } else if(!light.isConstant()){
            final double[][] LA = new double[w][4];
            for(i=0; i<h; i++){
                // System.out.println("Row: " + i);
                final double [][] NR = NA[i];
                light.getLightRow(x, y+i*scaleY, scaleX, w, NR, LA);
                for (j=0; j<w; j++){
                    // Get Normal 
                    final double [] N = NR[j];
                    
                    // Get Light Vector
                    final double [] L = LA[j];
                    L[2] += 1;
                    norm = L[0]*L[0] + L[1]*L[1] + L[2]*L[2];
                    norm = Math.sqrt(norm);
                    double dot = N[0]*L[0] + N[1]*L[1] + N[2]*L[2];
                    // vs = vs/norm;
                    norm = Math.pow(dot/norm, specularExponent);
                    a = (int)(mult*norm + 0.5);
                    if ((a & 0xFFFFFF00) != 0)
                        a = ((a & 0x80000000) != 0)?0:255;
                    pixels[p++] = (a << 24 | pixel);
                }
                p += adjust;
            }
        }
        else{
            // Get constant light vector
            final double[] L = new double[3];
            light.getLight(0, 0, 0, L);

            // Compute Half-way vector
            L[2] += 1;
            norm = Math.sqrt(L[0]*L[0] + L[1]*L[1] + L[2]*L[2]);
            if(norm > 0){
                L[0] /= norm;
                L[1] /= norm;
                L[2] /= norm;
            }

            for(i=0; i<h; i++){
                final double [][] NR = NA[i];
                for(j=0; j<w; j++){
                    // Get Normal 
                    final double [] N = NR[j];
                    
                    a = (int)(mult*Math.pow(N[0]*L[0] + N[1]*L[1] + N[2]*L[2], 
                                            specularExponent) + 0.5);
                    
                    if ((a & 0xFFFFFF00) != 0)
                        a = ((a & 0x80000000) != 0)?0:255;

                    pixels[p++] = (a << 24 | pixel);
                }
                p += adjust;
            }
        }
        // System.out.println("Exiting Specular Lighting");
    }
}
