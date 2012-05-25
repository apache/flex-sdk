/*

   Copyright 2002-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.image.rendered;

import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.IndexColorModel;
import java.awt.image.MultiPixelPackedSampleModel;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.util.Iterator;
import java.util.Vector;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;

/**
 * This implements an adaptive pallete generator to reduce images to a
 * specified number of colors.
 *
 * Ideally this would also support a better dither option than just 
 * the JDK's pattern dither.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @author <a href="mailto:jun@oop-reserch.com">Jun Inamori</a>
 * @version $Id: IndexImage.java,v 1.7 2004/08/18 07:14:08 vhardy Exp $ */
public class IndexImage{

    /**
     * Used to track a color and the number of pixels of that colors
     */
    private static class Counter {
        public int val;
        public int count=1;
        public Counter(int val) {  this.val = val; }
        public boolean add(int val) {
            // See if the value matches us...
            if (this.val != val)
                return false;
            count++;
            return true;
        }
    }

    /**
     * Used to define a cube of the colorspace.  The cube can be split
     * approximagely in half to generate two cubes.  
     */
    private static class Cube {
        int []min={0, 0, 0}, max={255,255,255};

        boolean done = false;
        
        Vector []colors = null;
        int count=0;
        static final int RED = 0;
        static final int GRN = 1;
        static final int BLU = 2;

        /**
         * Define a new cube.
         * @param colors contains the 3D color histogram to be subdivided
         * @param count the total number of pixels in the 3D histogram.
         */
        public Cube(Vector []colors, int count) {
            this.colors = colors;
            this.count = count;
        }

        /**
         * If this returns true then the cube can not be subdivided any
         * further
         */
        public boolean isDone() { return done; }
        /**
         * Splits the cube into two parts.  This cube is
         * changed to be one half and the returned cube is the other half.
         * This tries to pick the right channel to split on.
         */
        public Cube split() {
            int dr = max[0]-min[0]+1;
            int dg = max[1]-min[1]+1;
            int db = max[2]-min[2]+1;
            int c0, c1, splitChannel;

            // Figure out which axis is the longest and split along
            // that axis (this tries to keep cubes square-ish).
            if (dr >= dg) {
                c0 = GRN;
                if (dr >= db) { splitChannel = RED; c1=BLU; }
                else          { splitChannel = BLU; c1=RED; }
            } else if (dg >= db) {
                splitChannel = GRN;
                c0=RED;
                c1=BLU;
            } else {
                splitChannel = BLU;
                c0=RED;
                c1=GRN;
            }

            Cube ret;
            ret = splitChannel(splitChannel, c0, c1);
            if (ret != null ) return ret;

            ret = splitChannel(c0, splitChannel, c1);
            if (ret != null ) return ret;

            ret = splitChannel(c1, splitChannel, c0);
            if (ret != null) return ret;
            
            done = true;
            return null;
        }

        /**
         * Splits the image according to the parameters.  It tries
         * to find a location where half the pixels are on one side
         * and half the pixels are on the other.
         */
        public Cube splitChannel(int splitChannel, int c0, int c1) {
            if (min[splitChannel] == max[splitChannel]) return null;
            
            int splitSh4 = (2-splitChannel)*4;
            int c0Sh4    = (2-c0)*4;
            int c1Sh4    = (2-c1)*4;

            int half = count/2;
            // Each entry is the number of pixels that have that value
            // in the split channel within the cube (so pixels
            // that have that value in the split channel aren't counted
            // if they are outside the cube in the other color channels.
            int counts [] = new int[256];
            int tcount = 0;

            // System.out.println("Cube: [" + 
            //                    min[0] + "-" + max[0] + "] [" +
            //                    min[1] + "-" + max[1] + "] [" +
            //                    min[2] + "-" + max[2] + "]");

            int [] minIdx = {min[0]>>4, min[1]>>4, min[2]>>4};
            int [] maxIdx = {max[0]>>4, max[1]>>4, max[2]>>4};
            int minR=min[0], minG=min[1], minB=min[2];
            int maxR=max[0], maxG=max[1], maxB=max[2];
            int val = 0;
            int [] vals = {0, 0, 0};
            for (int i=minIdx[splitChannel]; i<=maxIdx[splitChannel]; i++) {
                int idx1 = i<<splitSh4;
                for (int j=minIdx[c0]; j<=maxIdx[c0]; j++) {
                    int idx2 = idx1 | (j<<c0Sh4);
                    for (int k=minIdx[c1]; k<=maxIdx[c1]; k++) {
                        int idx = idx2 | (k<<c1Sh4);
                        Vector v = colors[idx];
                        if (v==null) continue;
                        Iterator itr = v.iterator();
                        Counter c;
                        while (itr.hasNext()) {
                            c = (Counter)itr.next();
                            val = c.val;
                            vals[0] = (val&0xFF0000)>>16;
                            vals[1] = (val&0xFF00)>>8;
                            vals[2] = (val&0xFF);
                            if (((vals[0] >= minR) && (vals[0] <= maxR))&&
                                ((vals[1] >= minG) && (vals[1] <= maxG))&&
                                ((vals[2] >= minB) && (vals[2] <= maxB))) {
                                // The val lies within this cube so count it.
                                counts[vals[splitChannel]] += c.count;
                                tcount += c.count;
                            }
                        }
                    }
                }
                // We've found the half way point.  Note that the
                // rest of counts is not filled out.
                if (tcount >= half) break;
            }

            tcount=0;
            int lastAdd=-1;
            // These indicate what the top value for the low cube and
            // the low value of the high cube should be in the split channel
            // (they may not be one off if there are 'dead' spots in the
            // counts array.
            int splitLo=min[splitChannel], splitHi=max[splitChannel];
            for (int i=min[splitChannel]; i<=max[splitChannel]; i++) {
                int c = counts[i];
                if (c == 0) {
                    // No counts below this so move up bottom of cube.
                    if ((tcount == 0) && (i < max[splitChannel]))
                        this.min[splitChannel] = i+1;
                    continue;
                }

                if (tcount+c < half) {
                    lastAdd = i;
                    tcount+=c;
                    continue;
                }
                if ((half-tcount) <= ((tcount+c)-half)) {
                    // Then lastAdd is a better top idx for this then i.
                    if (lastAdd == -1) {
                        // No lower place to break.
                        if (c == this.count) {
                            // All pixels are at this value so make min/max
                            // reflect that.
                            this.max[splitChannel] = i;
                            return null; // no split to make.
                        } else {
                            // There are values about this one so
                            // split above.
                            splitLo = i;
                            splitHi = i+1;
                            break;
                        }
                    }
                    splitLo = lastAdd;
                    splitHi = i;
                } else {
                    if (i == this.max[splitChannel]) {
                        if ( c == this.count) {
                            // would move min up but that should
                            // have happened already.
                            return null; // no split to make.
                        } else {
                            // Would like to break between i and i+1
                            // but no i+1 so use lastAdd and i;
                            splitLo = lastAdd;
                            splitHi = i;
                            break;
                        }
                    }
                    // Include c in counts
                    tcount += c;
                    splitLo = i;
                    splitHi = i+1;
                }
                break;
            }

            // System.out.println("Split: " + splitChannel + "@" 
            //                    + splitLo + "-"+splitHi + 
            //                    " Count: " + tcount  + " of " + count +
            //                    " LA: " + lastAdd);

            // Create the new cube and update everone's bounds & counts.
            Cube ret = new Cube(colors, tcount);
            this.count = this.count-tcount;
            ret.min[splitChannel] = this.min[splitChannel];
            ret.max[splitChannel] = splitLo;
            this.min[splitChannel] = splitHi;
            ret.min[c0] = this.min[c0];
            ret.max[c0] = this.max[c0];
            ret.min[c1] = this.min[c1];
            ret.max[c1] = this.max[c1];
            return ret;
        }

        /**
         * Returns the average color for this cube
         */
        public int averageColor() {
            if (this.count == 0) return 0;

            float red=0, grn=0, blu=0;

            int minR=min[0], minG=min[1], minB=min[2];
            int maxR=max[0], maxG=max[1], maxB=max[2];
            int [] minIdx = {minR>>4, minG>>4, minB>>4};
            int [] maxIdx = {maxR>>4, maxG>>4, maxB>>4};
            int val, ired, igrn, iblu;
            float weight;
            for (int i=minIdx[0]; i<=maxIdx[0]; i++) {
                int idx1 = i<<8;
                for (int j=minIdx[1]; j<=maxIdx[1]; j++) {
                    int idx2 = idx1 | (j<<4);
                    for (int k=minIdx[2]; k<=maxIdx[2]; k++) {
                        int idx = idx2 | k;
                        Vector v = colors[idx];
                        if (v==null) continue;
                        Iterator itr = v.iterator();
                        Counter c;
                        while (itr.hasNext()) {
                            c = (Counter)itr.next();
                            val = c.val;
                            ired = (val&0xFF0000)>>16;
                            igrn = (val&0x00FF00)>>8;
                            iblu = (val&0x0000FF);
                            if (((ired >= minR) && (ired <= maxR))&&
                                ((igrn >= minG) && (igrn <= maxG))&&
                                ((iblu >= minB) && (iblu <= maxB))) {
                                weight = (c.count/(float)this.count);
                                red += (ired*weight);
                                grn += (igrn*weight);
                                blu += (iblu*weight);
                            }
                        }
                    }
                }
            }
            // System.out.println("RGB: [" + red + ", " + 
            //                    grn + ", " + blu + "]");
            return (((int)(red+0.5))<<16 |
                    ((int)(grn+0.5))<<8  | 
                    ((int)(blu+0.5)));
        }
    }

    /**
     * Converts the input image (must be TYPE_INT_RGB or
     * TYPE_INT_ARGB) to an indexed image.  Generating an adaptive
     * palette with number of colors specified.
     * @param bi the image to be processed.
     * @param nColors number of colors in the palette
     */
    static public BufferedImage getIndexedImage
        (BufferedImage bi, int nColors) {
        int w=bi.getWidth();
        int h=bi.getHeight();

        // Using 4 bits from RG & B.
        Vector [] colors = new Vector[1<<12]; 

        int rgb=0;
        for(int i_w=0; i_w<w; i_w++){
            for(int i_h=0; i_h<h; i_h++){
                rgb=(bi.getRGB(i_w,i_h) & 0xFFFFFF);
                // Get index from high four bits of each component.
                int idx = (((rgb&0xF00000)>>> 12) |
                           ((rgb&0x00F000)>>>  8) |
                           ((rgb&0x0000F0)>>>  4));

                    // Get the 'hash vector' for that key.
                Vector v = colors[idx];
                if (v == null) {
                    // No colors in this bin yet so create vector and
                    // add color.
                    v = new Vector();
                    v.add(new Counter(rgb));
                    colors[idx] = v;
                } else {
                    // find our color in the bin or create a counter for it.
                    Iterator i = v.iterator();
                    while (true) {
                        if (i.hasNext()) {
                            // try adding our color to each counter...
                            if (((Counter)i.next()).add(rgb)) break;
                        } else {
                            v.add(new Counter(rgb));
                            break;
                        }
                    }
                }
            }
        }

        int nCubes=1;
        int fCube=0;
        Cube [] cubes = new Cube[nColors];
        cubes[0] = new Cube(colors, w*h);
        
        while (nCubes < nColors) {
            while (cubes[fCube].isDone()) {
                fCube++;
                if (fCube == nCubes) break;
            }
            if (fCube == nCubes) break;
            Cube c = cubes[fCube];
            Cube nc = c.split();
            if (nc != null) {
                if (nc.count > c.count) {
                    Cube tmp = c; c= nc; nc = tmp;
                }
                int j = fCube;
                int cnt = c.count;
                for (int i=fCube+1; i<nCubes; i++) {
                    if (cubes[i].count < cnt) 
                        break;
                    cubes[j++] = cubes[i];
                }
                cubes[j++] = c;

                cnt = nc.count;
                while (j<nCubes) {
                    if (cubes[j].count < cnt) 
                        break;
                    j++;
                }
                for (int i=nCubes; i>j; i--)
                    cubes[i] = cubes[i-1];
                cubes[j++] = nc;
                nCubes++;
            }
        }

        byte [] r = new byte[nCubes];
        byte [] g = new byte[nCubes]; 
        byte [] b = new byte[nCubes]; 
        for (int i=0; i<nCubes; i++) {
            int val = cubes[i].averageColor();
            r[i] = (byte)((val>>16)&0xFF);
            g[i] = (byte)((val>> 8)&0xFF);
            b[i] = (byte)((val    )&0xFF);

            // System.out.println("Color [" + i + "]: #" + 
            //                    (((val>>16)<16)?"0":"") +
            //                    Integer.toHexString(val));
        }
        BufferedImage indexed;


        // The JDK doesn't seem to dither the image correctly if I go
        // below 8bits per pixel.  So I dither to an 8bit pallete
        // image that only has nCubes colors.  Then I copy the data to
        // a lower bit depth image that I return.
        IndexColorModel icm=new IndexColorModel(8,nCubes,r,g,b);
        indexed =new BufferedImage
            (w, h, BufferedImage.TYPE_BYTE_INDEXED, icm);
        Graphics2D g2d=indexed.createGraphics();
        g2d.setRenderingHint
            (RenderingHints.KEY_DITHERING,
             RenderingHints.VALUE_DITHER_ENABLE);
        g2d.drawImage(bi, 0, 0, null);
        g2d.dispose();


        int bits;
        for (bits=1; bits <=8; bits++) {
            if ((1<<bits) >= nCubes) break;
        }
        // System.out.println("Bits: " + bits + " Cubes: " + nCubes);

        if (bits > 4)
            // 8 bit image we are done...
            return indexed;

        // Create our low bit depth image...
        if (bits ==3) bits = 4;
        ColorModel cm=new IndexColorModel(bits,nCubes,r,g,b);
        SampleModel sm = new MultiPixelPackedSampleModel
            (DataBuffer.TYPE_BYTE, w, h, bits);
        WritableRaster ras = Raster.createWritableRaster
            (sm, new Point(0,0));

        // Copy the data to the low bitdepth image.
        bi = indexed;
        indexed = new BufferedImage(cm, ras, 
                                    bi.isAlphaPremultiplied(), null);
        GraphicsUtil.copyData(bi, indexed);
        return indexed;
    }
}
