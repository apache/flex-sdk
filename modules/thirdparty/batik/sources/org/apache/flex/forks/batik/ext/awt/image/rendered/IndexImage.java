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
import java.util.List;
import java.util.ArrayList;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;

/**
 * This class implements an adaptive palette generator to reduce images to a
 * specified number of colors.
 *
 * Ideally this would also support a better dither option than just 
 * the JDK's pattern dither.
 *
 * The algorithm used is the 'Median Cut Algorithm' published by
 * Paul Heckbert in early '80s.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @author <a href="mailto:jun@oop-reserch.com">Jun Inamori</a>
 * @version $Id: IndexImage.java 489226 2006-12-21 00:05:36Z cam $ 
 */

public class IndexImage{

    /**
     * Used to track a color and the number of pixels of that colors
     */
    private static class Counter {

        /**
         * contains the 'packed' rgb-color for this point.
         * Must not change after construction!
         */
        final int val;

        /**
         * the number of image-pixels with this color.
         */
        int count=1;

        Counter(int val) {  this.val = val; }

        boolean add(int val) {
            // See if the value matches us...
            if (this.val != val)
                return false;
            count++;
            return true;
        }

        /**
         * convert the color-point of this counter to an rgb-array.
         * To avoid creating lots of arrays, the caller passes the
         * array to store the result.
         *
         * @param rgb an int[ 3 ] to store the result.
         * @return an int-array with rgb-color-values (same as rgb-parameter)
         */
        int[] getRgb( int[] rgb ){
            rgb[ Cube.RED ] = (val&0xFF0000)>>16;
            rgb[ Cube.GRN ] = (val&0x00FF00)>>8;
            rgb[ Cube.BLU ] = (val&0x0000FF);
            return rgb;
        }
   }

    /**
     * Used to define a cube of the colorspace.  The cube can be split
     * approximagely in half to generate two cubes.
     */
    private static class Cube {
        static final byte[] RGB_BLACK= new byte[]{ 0, 0, 0 };

        int[] min = {0, 0, 0}, max={255,255,255};

        boolean done = false;
        

        /**
         * the colors-array is not modified - in fact, all cubes use
         * the same colors-array.  The Counter contains the
         * rgb-color-code and the count of pixels with this color.
         */
        final Counter[][] colors;

        /**
         * the number of color-points in this cube.
         */
        int count=0;

        static final int RED = 0;
        static final int GRN = 1;
        static final int BLU = 2;

        /**
         * Define a new cube.
         * @param colors contains the 3D color histogram to be subdivided
         * @param count the total number of pixels in the 3D histogram.
         */
        Cube( Counter[][] colors, int count) {
            this.colors = colors;
            this.count = count;
        }

        /**
         * If this returns true then the cube can not be subdivided any
         * further
         */
        public boolean isDone() { return done; }

        /**
         * check, if the color defined by val[] is inside this cube.
         *
         * @param val int[ 3 ] containing r,g,b-values
         * @return true when color is inside this cube
         */
        private boolean contains( int[] val ){

            int vRed = val[ RED ]; // just save some array-accesses
            int vGrn = val[ GRN ];
            int vBlu = val[ BLU ];

            return (
                ( ( min[ RED ] <= vRed ) && ( vRed <= max[ RED ]))&&
                ( ( min[ GRN ] <= vGrn ) && ( vGrn <= max[ GRN ]))&&
                ( ( min[ BLU ] <= vBlu ) && ( vBlu <= max[ BLU ])));
        }

        /**
         * Splits the cube into two parts.  This cube is
         * changed to be one half and the returned cube is the other half.
         * This tries to pick the right channel to split on.
         */
        Cube split() {
            int dr = max[ RED ]-min[ RED ]+1;
            int dg = max[ GRN ]-min[ GRN ]+1;
            int db = max[ BLU ]-min[ BLU ]+1;
            int c0, c1, splitChannel;

            // Figure out which axis is the longest and split along
            // that axis (this tries to keep cubes square-ish).
            if (dr >= dg) {
                if (dr >= db) { splitChannel = RED; c0=GRN; c1=BLU; }
                else          { splitChannel = BLU; c0=RED; c1=GRN; }
            } else if (dg >= db) {
                splitChannel = GRN;
                c0=RED;
                c1=BLU;
            } else {
                splitChannel = BLU;
                c0=GRN;
                c1=RED;
            }

//            System.out.println("Red:" + dr
//                    + " Grn:" + dg
//                    + " Blu:" + db
//                    + " Split:" + splitChannel
//                    + " c0:" + c0
//                    + " c1:" + c1 );

            Cube ret;

            // try to split the longest axis
            ret = splitChannel(splitChannel, c0, c1);
            if (ret != null ) return ret;

            // try to split along the 2nd longest axis
            ret = splitChannel(c0, splitChannel, c1);
            if (ret != null ) return ret;

            // only one left
            ret = splitChannel(c1, splitChannel, c0);
            if (ret != null) return ret;

            // so far, no split was possible trying all 3 colors: this
            // cube can't be split further
            done = true;
            return null;
        }

        /**
         * Adjust (normalize) min/max of this cube so that they span
         * the actual content.  This method is called on the two cubes
         * resulting from a split.  <br> We search the counts[] from
         * min to max for the leftmost non-null entry.  That is the
         * new min.  Then we search counts[] from max to min for the
         * rightmost non-null entry.  That is the new max.  <br>This
         * requires, that {@link #computeCounts } really computes
         * <i>all</i> counts-values (and does not stop after the
         * necessary number of points for a split is found, as it was
         * done in the previous version of this class).
         *
         * @param splitChannel the color used for the last split
         * @param counts contains the number of points along the splitChannel
         *        - only counts[ min .. max ] is valid.
         */
        private void normalize( int splitChannel, int[] counts ){

            if ( count == 0 ){
                // empty cube: nothing to normalize
                return;
            }

            int iMin = min[ splitChannel ];
            int iMax = max[ splitChannel ];
            int loBound = -1;
            int hiBound = -1;

            // we search from left to right for the first non-null
            // entry in counts[]
            for( int i = iMin; i <= iMax; i++ ){
                if ( counts[ i ] == 0 ){
                    // this entry is 0: search more
                    continue;
                }

                // we reached a non-null entry: stop looking further
                loBound = i;
                break;
            }

            // we search from right to left for the first non-null
            // entry in counts[]
            for( int i= iMax; i >= iMin; i-- ){
                if ( counts[ i ] == 0 ){
                    // this entry is 0: search more
                    continue;
                }
                // we reached a non-null entry: stop looking further
                hiBound = i;
                break;
            }

            boolean flagChangedLo = (loBound != -1 ) && ( iMin != loBound );
            boolean flagChangedHi = (hiBound != -1 ) && ( iMax != hiBound );
//            if ( flagChangedLo || flagChangedHi ){
//                System.out.println("old min:" + min[ splitChannel ] + "/max:" + max[ splitChannel ]
//                + " new: " + loBound + "/" + hiBound );
//                StringBuffer buff = new StringBuffer( 100 );
//                for( int i= min[ splitChannel ]; i <= max[ splitChannel]; i++ ){
//                    buff.append( counts[ i ] );
//                    buff.append( ',' );
//                }
//                System.out.println("Counts:" + buff );
//            }

            if ( flagChangedLo ){
                min[ splitChannel ]= loBound;
            }
            if ( flagChangedHi ){
                max[ splitChannel ]= hiBound;
            }
        }


        /**
         * Splits the image according to the parameters.  It tries
         * to find a location where half the pixels are on one side
         * and half the pixels are on the other.
         */
        Cube splitChannel(int splitChannel, int c0, int c1) {

            if (min[splitChannel] == max[splitChannel]) {
                // thickness along the splitChannel is only one point: cannot split
                return null;
            }

            if ( count == 0 ){
                // this Cube has no points: cannot split
                return null;
            }

            // System.out.println( toString() );

            int half = count/2;
            // Each entry is the number of pixels that have that value
            // in the split channel within the cube (so pixels
            // that have that value in the split channel aren't counted
            // if they are outside the cube in the other color channels.
            int[] counts = computeCounts( splitChannel, c0, c1 );

            int tcount=0;
            int lastAdd=-1;
            // These indicate what the top value for the low cube and
            // the low value of the high cube should be in the split channel
            // (they may not be one off if there are 'dead' spots in the
            // counts array.
            int splitLo=min[splitChannel];
            int splitHi=max[splitChannel];
            for (int i=min[splitChannel]; i<=max[splitChannel]; i++) {
                int c = counts[i];
                if (c == 0) {
                    // No counts below this so move up bottom of cube.
                    if ((tcount == 0) && (i < max[splitChannel]))
                        min[splitChannel] = i+1;
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
                        if (c == count) {
                            // All pixels are at this value so make min/max
                            // reflect that.
                            max[splitChannel] = i;
                            return null; // no split to make.
                        } else {
                            // There are values about this one so
                            // split above.
                            splitLo = i;
                            splitHi = i+1;
                            tcount += c;    // fix 35683
                            break;
                        }
                    }
                    splitLo = lastAdd;
                    splitHi = i;
                } else {
                    if (i == max[splitChannel]) {
                        if ( c == count) {
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

            // Create the new cube and update everyone's bounds & counts.
            Cube ret = new Cube(colors, tcount);
            count = count-tcount;
            ret.min[splitChannel] = min[splitChannel];
            ret.max[splitChannel] = splitLo;
            min[splitChannel] = splitHi;

            // the cube was split along splitChannel, the other
            // dimensions dont change
            ret.min[c0] = min[c0];
            ret.max[c0] = max[c0];
            ret.min[c1] = min[c1];
            ret.max[c1] = max[c1];

//            if ( count <= 0 ){
//                System.out.println("This cube has no points after split:" + toString() );
//            }
//            if ( ret.count <= 0 ){
//                System.out.println("That cube has no points after split:" + ret.toString() + "    this:" + toString() );
//                System.out.println("SplitLo:"  + splitLo + "  SplitHi:" + splitHi );
//            }

            // after a split we 'normalize' both cubes, so that their
            // min/max reflect the actual bounds of the cube.  comment
            // the next two lines when you want to see the impact of
            // using non-normalized cubes
            normalize( splitChannel, counts );
            ret.normalize( splitChannel, counts );

            return ret;
        }

        /**
         * create an array, which contains the number of pixels for
         * each point along the splitChannel (between min and max of
         * this cube).
         *
         * @param splitChannel one of RED | GRN | BLU
         * @param c0 one of the other channels
         * @param c1 the third channel
         * @return an int[ 255 ] where only int[ min .. max ] contain
         *         valid counts.
         */
        private int[] computeCounts( int splitChannel, int c0, int c1) {

            int splitSh4 = (2-splitChannel)*4;
            int c0Sh4    = (2-c0)*4;
            int c1Sh4    = (2-c1)*4;

            // after split, each half should have half of the cube's points
            int half = count/2;

            // Each entry is the number of pixels that have that value
            // in the split channel within the cube (so pixels
            // that have that value in the split channel aren't counted
            // if they are outside the cube in the other color channels.
            int[] counts = new int[256];
            int tcount = 0;

            int minR=min[0], minG=min[1], minB=min[2];
            int maxR=max[0], maxG=max[1], maxB=max[2];

            int[] minIdx = { minR >> 4, minG >> 4, minB >> 4 };
            int[] maxIdx = { maxR >> 4, maxG >> 4, maxB >> 4 };

            int [] vals = {0, 0, 0};
            for (int i=minIdx[splitChannel]; i<=maxIdx[splitChannel]; i++) {
                int idx1 = i<<splitSh4;
                for (int j=minIdx[c0]; j <=maxIdx[c0]; j++) {
                    int idx2 = idx1 | (j<<c0Sh4);
                    for (int k=minIdx[c1]; k<=maxIdx[c1]; k++) {
                        int idx = idx2 | (k<<c1Sh4);
                        Counter[] v = colors[idx];
                        for( int iColor = 0; iColor < v.length; iColor++ ){
                            Counter c = v[ iColor ];
                            vals = c.getRgb( vals );
                            if ( contains( vals )){
                                // The vals[] lies completly within
                                // this cube so count it.
                                counts[ vals[splitChannel] ] += c.count;
                                tcount += c.count;
                            }
                        }
                    }
                }
                // the next statement-line stops the loop after we
                // found the split-point.  however, we continue to
                // fill the counts[] because that is needed for
                // normalization
//                // We've found the half way point.  Note that the
//                // rest of counts is not filled out.
//                if (( tcount > 0 ) && (tcount >= half)) break;  // fix 35683
            }

            // the result so far is the filled counts[]
            return counts;
        }


        /**
         * convert the cube-content to String-representation for logging.
         * @return the min/max-boundarys of the rgb-channels and
         *         pixel-count of this Cube.
         */
        public String toString() {
            return "Cube: [" +
                    min[ RED ] + '-' + max[ RED ] + "] [" +
                    min[ GRN ] + '-' + max[ GRN ] + "] [" +
                    min[ BLU ] + '-' + max[ BLU ] + "] n:" + count;
        }


        /**
         * Returns the average color for this cube (no alpha).
         */
        public int averageColor() {
            if (count == 0) {
                // cube is empty: return black
                return 0;
            }

            byte[] rgb = averageColorRGB( null );

            return (( rgb[ RED ] << 16 ) & 0x00FF0000)
                 | (( rgb[ GRN ] <<  8 ) & 0x0000FF00)
                 | (( rgb[ BLU ]       ) & 0x000000FF);
        }

        /**
         * Returns the average color for this cube
         */
        public byte[] averageColorRGB( byte[] rgb ) {

            if (count == 0) return RGB_BLACK;

            float red=0, grn=0, blu=0;

            // the boundarys of this cube
            int minR=min[0], minG=min[1], minB=min[2];
            int maxR=max[0], maxG=max[1], maxB=max[2];
            int [] minIdx = {minR>>4, minG>>4, minB>>4};
            int [] maxIdx = {maxR>>4, maxG>>4, maxB>>4};
            int[] vals = new int[3];

            for (int i=minIdx[0]; i<=maxIdx[0]; i++) {
                int idx1 = i<<8;
                for (int j=minIdx[1]; j<=maxIdx[1]; j++) {
                    int idx2 = idx1 | (j<<4);
                    for (int k=minIdx[2]; k<=maxIdx[2]; k++) {
                        int idx = idx2 | k;
                        Counter[] v = colors[idx];
                        for( int iColor = 0; iColor < v.length; iColor++ ){
                            Counter c = v[ iColor ];
                            vals = c.getRgb( vals );
                            if ( contains( vals ) ) {
                                float weight = (c.count/(float)count);
                                red += (vals[0]*weight);
                                grn += (vals[1]*weight);
                                blu += (vals[2]*weight);
                            }
                        }
                    }
                }
            }
            byte[] result = (rgb == null) ? new byte[3] : rgb;
            result[ RED ] = (byte)(red + 0.5f);
            result[ GRN ] = (byte)(grn + 0.5f);
            result[ BLU ] = (byte)(blu + 0.5f);

            return result;
        }

    }

    /**
     * create an array of rgb-colors from the cubes-array.
     * The color of each cube is computed as the sum of all colors in the cube,
     * where each pixel is weighted according to it's count.
     *
     * @param nCubes number of entries to use in cubes
     * @param cubes contains the Cubes resulting from running the split-algorithm.
     * @return a byte[][] which is arranged as [ r|g|b ][ 0..nCubes-1 ]
     */
    static byte[][] computeRGB( int nCubes, Cube[] cubes ){

        byte[] r = new byte[nCubes];
        byte[] g = new byte[nCubes];
        byte[] b = new byte[nCubes];

        byte[] rgb = new byte[3];
        for (int i=0; i<nCubes; i++) {
            rgb = cubes[i].averageColorRGB( rgb );
            r[i] = rgb[ Cube.RED ];
            g[i] = rgb[ Cube.GRN ];
            b[i] = rgb[ Cube.BLU ];
        }

        byte[][] result = new byte[3][];
        result[ Cube.RED ] = r;
        result[ Cube.GRN ] = g;
        result[ Cube.BLU ] = b;

//        logRGB( r, g, b );

        return result;
    }

    /**
     * helper-method to print the complete rgb-arrays.
     * @param r
     * @param g
     * @param b
     */
    static void logRGB( byte[] r, byte[] g, byte[] b ){

        StringBuffer buff = new StringBuffer( 100 );
        int nColors = r.length;
        for( int i= 0; i < nColors; i++ ) {
            String rgbStr= "(" + (r[i]+128) + ',' + (g[i] +128 ) + ',' + (b[i] + 128) + ")," ;
            buff.append( rgbStr );
        }
        System.out.println("RGB:" + nColors + buff );
    }


    /**
     * step 1: fill a data-structure with the count of each color in the image.
     * @param bi input-image
     * @return a List[] where each slot is a List of Counters (or null)
     */
    static List[] createColorList( BufferedImage bi ){

        int w= bi.getWidth();
        int h= bi.getHeight();

        // Using 4 bits from RG & B.
        List[] colors = new ArrayList[1<<12];

        for(int i_w=0; i_w<w; i_w++){
            for(int i_h=0; i_h<h; i_h++){
                int rgb=(bi.getRGB(i_w,i_h) & 0x00FFFFFF);  // mask away alpha
                // Get index from high four bits of each component.
                int idx = (((rgb&0xF00000)>>> 12) |
                           ((rgb&0x00F000)>>>  8) |
                           ((rgb&0x0000F0)>>>  4));

                // Get the 'hash vector' for that key.
                List v = colors[idx];
                if (v == null) {
                    // No colors in this bin yet so create list and
                    // add color.
                    v = new ArrayList();
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

        return colors;
    }


    /**
     * step 2: convert the result of step 1 to an Cube[][] which is
     * more efficient in the following iterations. All slots in the
     * result are filled with at least an empty array - thus we avoid
     * tests for null.  <br>Note: the converted slots in colors are no
     * longer needed and removed.
     *
     * @param colors the data-structure to convert. Note that it is
     * empty after conversion!
     * @return same data as in colors, but Lists are converted to arrays.
     */
    static Counter[][] convertColorList( List[] colors ){

        // used to fill empty slots
        final Counter[] EMPTY_COUNTER = new Counter[0];

        Counter[][] colorTbl= new Counter[ 1<< 12 ][];
        for( int i= 0; i < colors.length; i++ ){
            List cl = colors[ i ];
            if ( cl == null ){
                colorTbl[ i ] = EMPTY_COUNTER;
                continue;
            }
            int nSlots = cl.size();
            colorTbl[i] = (Counter[])cl.toArray( new Counter[ nSlots ] );

            // the colors[ i ] - data is no longer needed: discard
            colors[ i ] = null;
        }

        return colorTbl;
    }

    /**
     * Converts the input image (must be TYPE_INT_RGB or
     * TYPE_INT_ARGB) to an indexed image.  Generating an adaptive
     * palette with number of colors specified.
     * @param bi the image to be processed.
     * @param nColors number of colors in the palette
     */
    public static BufferedImage getIndexedImage( BufferedImage bi, int nColors) {
        int w=bi.getWidth();
        int h=bi.getHeight();

        // Using 4 bits from RG & B.
        List[] colors = createColorList( bi );

        // now we have initialized the colors[] with lists of Counters.
        // from now on, this data-structure is just read, not modified.
        // convert it to Counter[][] for faster iteration
        Counter[][] colorTbl = convertColorList( colors );

        // this is no longer needed: discard
        colors = null;

        int nCubes=1;
        int fCube=0;
        Cube [] cubes = new Cube[nColors];
        cubes[0] = new Cube(colorTbl, w*h);

        while (nCubes < nColors) {
            while (cubes[fCube].isDone()) {
                fCube++;
                if (fCube == nCubes) break;
            }
            if (fCube == nCubes) {
                // System.out.println("fCube == nCubes" + fCube );
                break;
            }
            Cube c = cubes[fCube];
            Cube nc = c.split();
            if (nc != null) {
                // store the cube with less points towards the end of
                // the array, so that fat cubes get more splits
                if (nc.count > c.count) {
                    // new cube has more points: swap
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

        // convert the remaining cubes to the colors they represent
        byte[][] rgbTbl = computeRGB( nCubes, cubes );

        // The JDK doesn't seem to dither the image correctly if I go
        // below 8bits per pixel.  So I dither to an 8bit palette
        // image that only has nCubes colors.  Then I copy the data to
        // a lower bit depth image that I return.
        IndexColorModel icm= new IndexColorModel( 8, nCubes, rgbTbl[0], rgbTbl[1], rgbTbl[2] );

        BufferedImage indexed =new BufferedImage
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
//        System.out.println("Bits: " + bits + " Cubes: " + nCubes);

        if (bits > 4) {
            // 8 bit image we are done...
            return indexed;
        }

        // Create our low bit depth image...
        if (bits ==3) bits = 4;
        ColorModel cm = new IndexColorModel(bits,nCubes, 
                                            rgbTbl[0], rgbTbl[1], rgbTbl[2] );
        SampleModel sm;
        sm = new MultiPixelPackedSampleModel(DataBuffer.TYPE_BYTE, w, h, bits);
        WritableRaster ras = Raster.createWritableRaster( sm, new Point(0,0));

        // Copy the data to the low bitdepth image.
        bi = indexed;
        indexed = new BufferedImage(cm, ras, bi.isAlphaPremultiplied(), null);
        GraphicsUtil.copyData(bi, indexed);
        return indexed;
    }
}
