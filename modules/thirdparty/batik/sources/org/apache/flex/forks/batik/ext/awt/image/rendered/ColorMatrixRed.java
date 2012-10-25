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

import java.awt.color.ColorSpace;
import java.awt.image.ColorModel;
import java.awt.image.DataBufferInt;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;

/**
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ColorMatrixRed.java 479564 2006-11-27 09:56:57Z dvholten $
 */
public class ColorMatrixRed extends AbstractRed{
    /**
     * Matrix to apply to color components
     */
    private float[][] matrix;

    public float[][] getMatrix(){
        return copyMatrix(matrix);
    }

    public void setMatrix(float[][] matrix){
        float[][] tmp = copyMatrix(matrix);

        if(tmp == null){
            throw new IllegalArgumentException();
        }

        if(tmp.length != 4){
            throw new IllegalArgumentException();
        }

        for(int i=0; i<4; i++){
            if(tmp[i].length != 5){
                throw new IllegalArgumentException( String.valueOf( i ) + " : " + tmp[i].length);
            }
        }
        this.matrix = matrix;
    }

    private float[][] copyMatrix(float[][] m){
        if(m == null){
            return null;
        }

        float[][] cm = new float[m.length][];
        for(int i=0; i<m.length; i++){
            if(m[i] != null){
                cm[i] = new float[m[i].length];
                System.arraycopy(m[i], 0, cm[i], 0, m[i].length);
            }
        }

        return cm;
    }

    public ColorMatrixRed(CachableRed src, float[][] matrix){
        setMatrix(matrix);

        ColorModel srcCM = src.getColorModel();
        ColorSpace srcCS = null;
        if (srcCM != null)
            srcCS = srcCM.getColorSpace();
        ColorModel cm;
        if (srcCS == null)
            cm = GraphicsUtil.Linear_sRGB_Unpre;
        else {
            if (srcCS == ColorSpace.getInstance(ColorSpace.CS_LINEAR_RGB))
                cm = GraphicsUtil.Linear_sRGB_Unpre;
            else
                cm = GraphicsUtil.sRGB_Unpre;
        }

        SampleModel sm =
            cm.createCompatibleSampleModel(src.getWidth(),
                                           src.getHeight());

        init(src, src.getBounds(), cm, sm,
             src.getTileGridXOffset(), src.getTileGridYOffset(), null);
    }


    public WritableRaster copyData(WritableRaster wr){
        //System.out.println("Getting data for : " + wr.getWidth() + "/" + wr.getHeight() + "/" + wr.getMinX() + "/" + wr.getMinY());

        //
        // First, get source data
        //
        CachableRed src = (CachableRed)getSources().get(0);
        // System.out.println("Hello");
        // System.out.println("src class : " + src.getClass().getName());
        // System.out.println("this : " + this);
        wr = src.copyData(wr);
        // System.out.println("Hi");
        //System.out.println("Source was : " + wr.getWidth() + "/" + wr.getHeight()+ "/" + wr.getMinX() + "/" + wr.getMinY());

        // Unpremultiply data if required
        ColorModel cm = src.getColorModel();
        GraphicsUtil.coerceData(wr, cm, false);

        //
        // Now, process pixel values
        //
        final int minX = wr.getMinX();
        final int minY = wr.getMinY();
        final int w = wr.getWidth();
        final int h = wr.getHeight();
        DataBufferInt dbf = (DataBufferInt)wr.getDataBuffer();
        final int[] pixels = dbf.getBankData()[0];

        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)wr.getSampleModel();

        final int offset =
            (dbf.getOffset() +
             sppsm.getOffset(minX-wr.getSampleModelTranslateX(),
                             minY-wr.getSampleModelTranslateY()));

        // final int offset = dbf.getOffset();

        final int scanStride =
            ((SinglePixelPackedSampleModel)wr.getSampleModel())
            .getScanlineStride();
        final int adjust = scanStride - w;
        int p = offset;
        int i=0, j=0;

        final float a00=matrix[0][0]/255f, a01=matrix[0][1]/255f, a02=matrix[0][2]/255f, a03=matrix[0][3]/255f, a04=matrix[0][4]/255f;
        final float a10=matrix[1][0]/255f, a11=matrix[1][1]/255f, a12=matrix[1][2]/255f, a13=matrix[1][3]/255f, a14=matrix[1][4]/255f;
        final float a20=matrix[2][0]/255f, a21=matrix[2][1]/255f, a22=matrix[2][2]/255f, a23=matrix[2][3]/255f, a24=matrix[2][4]/255f;
        final float a30=matrix[3][0]/255f, a31=matrix[3][1]/255f, a32=matrix[3][2]/255f, a33=matrix[3][3]/255f, a34=matrix[3][4]/255f;

        for(i=0; i<h; i++){
            for(j=0; j<w; j++){
                int pel = pixels[p];

                int a = pel >>> 24;
                int r = (pel >> 16) & 0xff;
                int g = (pel >> 8 ) & 0xff;
                int b =  pel        & 0xff;

                int dr = (int)((a00*r + a01*g + a02*b + a03*a + a04)*255.0f);
                int dg = (int)((a10*r + a11*g + a12*b + a13*a + a14)*255.0f);
                int db = (int)((a20*r + a21*g + a22*b + a23*a + a24)*255.0f);
                int da = (int)((a30*r + a31*g + a32*b + a33*a + a34)*255.0f);

                /*dr = dr > 255 ? 255 : dr < 0 ? 0 : dr;
                dg = dg > 255 ? 255 : dg < 0 ? 0 : dg;
                db = db > 255 ? 255 : db < 0 ? 0 : db;
                da = da > 255 ? 255 : da < 0 ? 0 : da;*/


                // If any high bits are set we are not in range.
                // If the highest bit is set then we are negative so
                // clamp to zero else we are > 255 so clamp to 255.
                if ((dr & 0xFFFFFF00) != 0)
                    dr = ((dr & 0x80000000) != 0)?0:255;
                if ((dg & 0xFFFFFF00) != 0)
                    dg = ((dg & 0x80000000) != 0)?0:255;
                if ((db & 0xFFFFFF00) != 0)
                    db = ((db & 0x80000000) != 0)?0:255;
                if ((da & 0xFFFFFF00) != 0)
                    da = ((da & 0x80000000) != 0)?0:255;

                pixels[p++] = (da << 24
                               |
                               dr << 16
                               |
                               dg << 8
                               |
                               db);

            }
            p += adjust;
        }

        //System.out.println("Result is : " + wr.getWidth() + "/" + wr.getHeight()+ "/" + wr.getMinX() + "/" + wr.getMinY());
        return wr;
    }

}
