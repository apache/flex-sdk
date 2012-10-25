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

/**
 * 
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: DiffuseLightingRed.java 475477 2006-11-15 22:44:28Z cam $
 */
public class DiffuseLightingRed extends AbstractRed{
    /**
     * Diffuse lighting constant
     */
    private double kd;

    /**
     * Light used for diffuse lighting
     */
    private Light light;

    /**
     * BumpMap source
     */
    private BumpMap bumpMap;

    /**
     * Device space to user space scale factors, along
     * each axis
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


    public DiffuseLightingRed(double kd,
                              Light light,
                              BumpMap bumpMap,
                              Rectangle litRegion,
                              double scaleX, double scaleY,
                              boolean linear){
        this.kd = kd;
        this.light = light;
        this.bumpMap = bumpMap;
        this.litRegion = litRegion;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        this.linear = linear;

        ColorModel cm;
        if (linear)
            cm = GraphicsUtil.Linear_sRGB_Pre;
        else
            cm = GraphicsUtil.sRGB_Pre;

        SampleModel sm = 
            cm.createCompatibleSampleModel(litRegion.width,
                                           litRegion.height);
                                             
        init((CachableRed)null, litRegion, cm, sm,
             litRegion.x, litRegion.y, null);
    }

    public WritableRaster copyData(WritableRaster wr){
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

        final int scanStride = sppsm.getScanlineStride();
        final int adjust = scanStride - w;
        int p = offset;
        int r=0, g=0, b=0;
        int i=0, j=0;

        // System.out.println("Getting diffuse red : " + minX + "/" + minY + "/" + w + "/" + h);
        double x = scaleX*minX;
        double y = scaleY*minY;
        double NL = 0;

        // final double[] L = new double[3];
        final double[][][] NA = bumpMap.getNormalArray(minX, minY, w, h);
        if(!light.isConstant()){
            final double[][] LA = new double[w][3];

            for(i=0; i<h; i++){
                final double [][] NR = NA[i];
                light.getLightRow(x, y+i*scaleY, scaleX, w, NR, LA);
                for(j=0; j<w; j++){
                    // Get Normal 
                    final double [] N = NR[j];
                    
                    // Get Light Vector
                    final double [] L = LA[j];
                    
                    NL = 255.*kd*(N[0]*L[0] + N[1]*L[1] + N[2]*L[2]);
                    
                    r = (int)(NL*lightColor[0]);
                    g = (int)(NL*lightColor[1]);
                    b = (int)(NL*lightColor[2]);
                    
                    // If any high bits are set we are not in range.
                    // If the highest bit is set then we are negative so
                    // clamp to zero else we are > 255 so clamp to 255.
                    if ((r & 0xFFFFFF00) != 0)
                        r = ((r & 0x80000000) != 0)?0:255;
                    if ((g & 0xFFFFFF00) != 0)
                        g = ((g & 0x80000000) != 0)?0:255;
                    if ((b & 0xFFFFFF00) != 0)
                        b = ((b & 0x80000000) != 0)?0:255;
                    
                    pixels[p++] = (0xff000000
                                   |
                                   r << 16
                                   |
                                   g << 8
                                   |
                                   b);
                    
                }
                p += adjust;
            }
        }
        else{
            // System.out.println(">>>>>>>> Processing constant light ...");
            // Constant light
            final double[] L = new double[3];
            light.getLight(0, 0, 0, L);

            for(i=0; i<h; i++){
                final double [][] NR = NA[i];
                for(j=0; j<w; j++){
                    // Get Normal 
                    final double[] N = NR[j];
                    
                    NL = 255.*kd*(N[0]*L[0] + N[1]*L[1] + N[2]*L[2]);
                    
                    r = (int)(NL*lightColor[0]);
                    g = (int)(NL*lightColor[1]);
                    b = (int)(NL*lightColor[2]);
                    
                    // If any high bits are set we are not in range.
                    // If the highest bit is set then we are negative so
                    // clamp to zero else we are > 255 so clamp to 255.
                    if ((r & 0xFFFFFF00) != 0)
                        r = ((r & 0x80000000) != 0)?0:255;
                    if ((g & 0xFFFFFF00) != 0)
                        g = ((g & 0x80000000) != 0)?0:255;
                    if ((b & 0xFFFFFF00) != 0)
                        b = ((b & 0x80000000) != 0)?0:255;
                    
                    pixels[p++] = (0xff000000
                                   |
                                   r << 16
                                   |
                                   g << 8
                                   |
                                   b);
                }
                p += adjust;
            }
        }
        
        return wr;
    }

}
