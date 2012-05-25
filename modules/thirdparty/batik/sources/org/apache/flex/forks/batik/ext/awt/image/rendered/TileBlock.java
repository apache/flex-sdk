/*

   Copyright 2001,2003  The Apache Software Foundation 

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

import java.util.Iterator;
import java.util.Vector;

/**
 * This class is responsible for breaking up a block of tiles into
 * a set of smaller requests that are a large as possible without
 * rerequesting significant numbers of tiles that are already
 * available 
 */
public class TileBlock {
    int occX, occY, occW, occH;
    int xOff, yOff, w, h, benefit;
    boolean [] occupied;

    /**
     * Construct a tile block this represents a block of contigous
     * tiles.
     * @param xloc The x index of left edge of the tile block.
     * @param yloc The y index of top edge of the tile block.
     * @param w    The number of tiles across in the block
     * @param h    The number of tiles down  the block
     * @param occupied Which entries in the block are already
     *                 computed.
     */
    TileBlock(int occX, int occY, int occW, int occH, boolean [] occupied,
              int xOff, int yOff, int w, int h) {
        this.occX = occX;
        this.occY = occY;
        this.occW = occW;
        this.occH = occH;
        this.xOff = xOff;
        this.yOff = yOff;
        this.w    = w   ;
        this.h    = h   ;
        this.occupied = occupied;



        // System.out.println("Block: [" + 
        //                    xloc + "," + yloc + ","  + 
        //                    w + "," + h + "]");
        for (int y=0; y<h; y++)
            for (int x=0; x<w; x++)                
                if (!occupied[x+xOff+occW*(y+yOff)])
                    benefit++;
    }

    /**
     * Really nice to string that outlines what tiles are filled
     * and what region this block covers.  Really useful for
     * debugging the TileBlock stuff.
     */
    public String toString() {
        String ret = "";
        for (int y=0; y<occH; y++) {
            for (int x=0; x<occW+1; x++) {
                if ((x==xOff) || (x==xOff+w)) {
                    if ((y==yOff) || (y==yOff+h-1))
                        ret += "+";
                    else  if ((y>yOff) && (y<yOff+h-1))
                        ret += "|";
                    else 
                        ret += " ";
                } 
                else if ((y==yOff)     && (x> xOff) && (x < xOff+w))
                    ret += "-";
                else if ((y==yOff+h-1) && (x> xOff) && (x < xOff+w))
                    ret += "_";
                else
                    ret += " ";

                if (x== occW)
                    continue;

                if (occupied[x+y*occW]) 
                    ret += "*";
                else
                    ret += ".";
            }
            ret += "\n";
        }
        return ret;
    }

    /** 
     * Return the x location of this block of tiles
     */
    int getXLoc()    { return occX+xOff; }
    /** 
     * Return the y location of this block of tiles
     */
    int getYLoc()    { return occY+yOff; }
    /** 
     * Return the width of this block of tiles
     */
    int getWidth()   { return w; }
    /** 
     * Return the height of this block of tiles
     */
    int getHeight()  { return h; }

    /** 
     * Return the number of new tiles computed.
     */
    int getBenefit() { return benefit; }
        
    /** 
     * Return the approximate amount of work required to compute
     * those tiles.
     */
    int getWork()    { return w*h+1; }

    /**
     * Returns the total amount of work for the array of tile blocks
     */
    static int getWork(TileBlock [] blocks) { 
        int ret=0;
        for (int i=0; i<blocks.length; i++) 
            ret += blocks[i].getWork();
        return ret;
    }

    /**
     * Returnes an optimized list of TileBlocks to generate that
     * tries to minimize the work to benefit ratio, for the set of
     * blocks defined by this block.
     */
    TileBlock [] getBestSplit() {
        if (simplify())
            return null;
            
        // Optimal split already...
        if (benefit == w*h)
            return new TileBlock [] { this };

        return splitOneGo();
    }

    public TileBlock [] splitOneGo() {
        boolean [] filled = (boolean [])occupied.clone();
        Vector items = new Vector();
        for (int y=yOff; y<yOff+h; y++)
            for (int x=xOff; x<xOff+w; x++) {
                if (!filled[x+y*occW]) {
                    // We have an unfilled tile slot, so first we
                    // figure out how long the slot is in this row.
                    int cw = xOff+w-x;
                    for (int cx=x; cx<x+cw; cx++)
                        if (filled[cx+y*occW])
                            cw = cx-x;
                        else
                            filled[cx+y*occW] = true;  // fill as we go..

                    // Then we check the next rows until we hit
                    // a row that doesn't have this slot all free.
                    // at which point we stop...
                    int ch=1;
                    for (int cy=y+1; cy<yOff+h; cy++) {
                        int cx=x;
                        for (; cx<x+cw; cx++) 
                            if (filled[cx+cy*occW])
                                break;

                        // Partial row so bail (we'll get it later..)
                        if (cx != x+cw)
                            break;

                        // Fill in the slot since we will use it...
                        for (cx=x; cx<x+cw; cx++) 
                            filled[cx+cy*occW] = true;
                        ch++;
                    }
                    items.add(new TileBlock(occX, occY, occW, occH, 
                                            occupied, x, y, cw, ch));
                    x+=(cw-1);
                }
            }

        TileBlock [] ret = new TileBlock[items.size()];
        Iterator iter = items.iterator();
        int i=0;
        while (iter.hasNext())
            ret[i++] = (TileBlock)iter.next();
        return ret;
    }

    public boolean simplify() {
        for (int y=0; y<h; y++) {
            int x;
            for (x=0; x<w; x++)                
                if (!occupied[x+xOff+occW*(y+yOff)])
                    break;
            if (x!=w) break;

            // Fully occupied row so remove it.
            yOff++;
            y--;
            h--;
        }

        // return true if we were simplified out of existance.
        if (h==0) return true;

        // If we make it past here we must have at least one good block.

        for (int y=h-1; y>=0; y--) {
            int x;
            for (x=0; x<w; x++)                
                if (!occupied[x+xOff+occW*(y+yOff)])
                    break;
            if (x!=w) break;

            // Fully occupied row so remove it.
            h--;
        }

        for (int x=0; x<w; x++) {
            int y;
            for (y=0; y<h; y++)
                if (!occupied[x+xOff+occW*(y+yOff)])
                    break;
            if (y!=h) break;

            // Fully occupied Col so remove it. 
            xOff++;
            x--;
            w--;
        }

        for (int x=w-1; x>=0; x--) {
            int y;
            for (y=0; y<h; y++)
                if (!occupied[x+xOff+occW*(y+yOff)])
                    break;
            if (y!=h) break;

            // Fully occupied Col so remove it. 
            w--;
        }

        return false;
    }
}


