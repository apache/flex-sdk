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

package org.apache.flex.forks.batik.gvt.flow;

import java.awt.geom.Point2D;
import org.apache.flex.forks.batik.gvt.font.GVTGlyphVector;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: LineInfo.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public class LineInfo {
    FlowRegions fr;
    double lineHeight = -1;
    double ascent = -1;
    double descent = -1;
    double hLeading = -1;
    double baseline;
    int numGlyphs;
    int words = 0;

    int size=0;
    GlyphGroupInfo [] ggis=null;
    int newSize=0;
    GlyphGroupInfo [] newGGIS=null;

    int       numRanges;
    double [] ranges;
    double [] rangeAdv;

    BlockInfo bi = null;
    boolean paraStart;
    boolean paraEnd;

    protected static final int FULL_WORD   = 0;
    protected static final int FULL_ADV    = 1;


    public LineInfo(FlowRegions fr, BlockInfo bi, boolean paraStart) {
        this.fr = fr;
        this.bi = bi;
        this.lineHeight = bi.getLineHeight();
        this.ascent     = bi.getAscent();
        this.descent    = bi.getDescent();
        this.hLeading   = (lineHeight-(ascent+descent))/2;
        this.baseline   = (float)(fr.getCurrentY()+hLeading+ascent);
        this.paraStart  = paraStart;
        this.paraEnd    = false;
        if (lineHeight > 0) {
            fr.newLineHeight(lineHeight);
            updateRangeInfo();
        }

    }

    public void setParaEnd(boolean paraEnd) {
        this.paraEnd = paraEnd;
    }

    public boolean addWord(WordInfo wi) {
        double nlh = wi.getLineHeight();
        if (nlh <= lineHeight)
            return insertWord(wi);
        fr.newLineHeight(nlh);

        if (!updateRangeInfo()) {
            if (lineHeight > 0) // restore old LH
                fr.newLineHeight(lineHeight);
            return false;
        }

        if (!insertWord(wi)) {
            if (lineHeight > 0) // Failure, restore old line Height.
                setLineHeight(lineHeight);
            return false;
        }

        // Success, word fits on line.
        lineHeight = nlh;
        if (wi.getAscent() > ascent)
            ascent = wi.getAscent();
        if (wi.getDescent() > descent)
            descent = wi.getDescent();
        hLeading = (nlh-(ascent+descent))/2;
        baseline = (float)(fr.getCurrentY()+hLeading+ascent);
        return true;
    }

    public boolean insertWord(WordInfo wi) {
        // Merge wi's glyph groups into the current GGI's.
        // This puts them into newGGIS, so if it fails we can
        // retain to the old ggis array.
        mergeGlyphGroups(wi);

        if (!assignGlyphGroupRanges(newSize, newGGIS))
            return false;

        // Swap in to GG info.
        swapGlyphGroupInfo();

        return true;
    }
    static final float MAX_COMPRESS=0.1f;
    static final float COMRESS_SCALE=3;

    public boolean assignGlyphGroupRanges(int ggSz, GlyphGroupInfo []ggis) {
        int i=0, r=0;
        while (r<numRanges) {
            double range = ranges[2*r+1]-ranges[2*r];
            float adv=0;
            float rangeAdvance = 0;

            while (i<ggSz) {
                GlyphGroupInfo ggi = ggis[i];
                ggi.setRange(r);
                adv = ggi.getAdvance();
                double delta = range-(rangeAdvance + adv);
                if (delta < 0) break;

                i++;
                rangeAdvance += adv;
            }

            // Check last glyphGroup anyways...
            if (i == ggSz) {
                i--;
                rangeAdvance -= adv;
            }

            GlyphGroupInfo ggi = ggis[i];
            float ladv = ggi.getLastAdvance();
            while (rangeAdvance + ladv > range) {
                // "i" can't fit in this region see if "i-1" can.
                i--;
                ladv = 0;
                if (i < 0) break;
                ggi = ggis[i];
                if (r != ggi.getRange()) // Not from this range nothing fits.
                    break;

                rangeAdvance -= ggi.getAdvance();
                ladv = ggi.getLastAdvance();
            }

            i++;
            rangeAdv[r] = rangeAdvance + ladv;
            r++;
            if (i == ggSz) return true;
        }
        return false;
    }

    /**
     * This method updates the line height and recalculates
     * the available flow ranges for the line.
     */
    public  boolean setLineHeight(double lh) {
        fr.newLineHeight(lh);

        if (updateRangeInfo()) {
            lineHeight = lh;
            return true;
        }

        // restore line height.
        if (lineHeight > 0)
            fr.newLineHeight(lineHeight);
        return false;
    }

    public double getCurrentY() {
        return fr.getCurrentY();
    }

    public boolean gotoY(double y) {
        if (fr.gotoY(y))
            return true;
        if (lineHeight > 0)
            updateRangeInfo();
        this.baseline = (float)(fr.getCurrentY()+hLeading+ascent);
        return false;
    }

    protected boolean updateRangeInfo() {
        fr.resetRange();
        int nr = fr.getNumRangeOnLine();
        if (nr == 0)
            return false;

        numRanges = nr;

        if (ranges == null) {
            rangeAdv          = new double[numRanges];
            ranges            = new double[2*numRanges];
        } else  if (numRanges > rangeAdv.length) {
            int sz = 2*rangeAdv.length;
            if (sz < numRanges) sz = numRanges;
            rangeAdv          = new double[sz];
            ranges            = new double[2*sz];
        }

        for (int r=0; r<numRanges; r++) {
            double [] rangeBounds = fr.nextRange();
            // System.err.println("RG["+r+"]: [" +
            //                    rangeBounds[0] + "," + rangeBounds[1] +"]");
            double r0 = rangeBounds[0];
            if (r == 0) {
                double delta = bi.getLeftMargin();
                if (paraStart) {
                    double indent = bi.getIndent();
                    // Limit indent to the amount of margin we have.
                    if (delta < -indent) delta = 0;
                    else                 delta += indent;
                }
                r0 += delta;
            }

            double r1 = rangeBounds[1];
            if (r == numRanges-1)
                r1 -= bi.getRightMargin();
            ranges[2*r]   = r0;
            ranges[2*r+1] = r1;
        }

        return true;
    }

    protected void swapGlyphGroupInfo() {
        GlyphGroupInfo [] tmp = ggis;
        ggis = newGGIS;
        newGGIS = tmp;

        size = newSize;
        newSize = 0;
    }

    /**
     * This function merges the glyph groups from <tt>wi<tt/>
     * into the glyph groups that are already on this line.
     * It does no fit checking, just adds them in the
     * proper place in the <tt>newGGIS</tt> data member.
     */
    protected void mergeGlyphGroups(WordInfo wi) {
        int numGG = wi.getNumGlyphGroups();
        newSize = 0;
        if (ggis == null) {
            // first glyph group on line just add them.
            newSize = numGG;
            newGGIS = new GlyphGroupInfo[numGG];
            for (int i=0; i< numGG; i++)
                newGGIS[i] = wi.getGlyphGroup(i);
        } else {
            // We need to merge the new glyph groups with the
            // existing glyph Groups.
            int s = 0;
            int i = 0;
            GlyphGroupInfo nggi = wi.getGlyphGroup(i);
            int nStart = nggi.getStart();

            GlyphGroupInfo oggi = ggis[size-1];
            int oStart = oggi.getStart();

            newGGIS = assureSize(newGGIS, size+numGG);
            if (nStart < oStart) {
                oggi = ggis[s];
                oStart = oggi.getStart();
                while((s<size)&&(i<numGG)) {
                    if (nStart < oStart) {
                        newGGIS[newSize++] = nggi;
                        i++;
                        if (i<numGG) {
                            nggi = wi.getGlyphGroup(i);
                            nStart = nggi.getStart();
                        }
                    } else {
                        newGGIS[newSize++] = oggi;
                        s++;
                        if (s<size) {
                            oggi = ggis[s];
                            oStart = oggi.getStart();
                        }
                    }
                }
            }
            while(s<size) {
                newGGIS[newSize++] = ggis[s++];
            }
            while(i<numGG) {
                newGGIS[newSize++] = wi.getGlyphGroup(i++);
            }
        }
        // for (int i=0; i<newSize; i++) {
        //     System.err.println("GGIS["+i+"]: " + newGGIS[i].start + " -> " +
        //                        newGGIS[i].end);
        // }
    }


    public void layout() {
        if (size == 0) return;

        // This is needed because we know that in most cases
        // the addition of the last word failed.  In the case of
        // BIDI this will mess up region assignments.
        // If one wanted to you could check on BIDI, and/or
        // lastPara.
        assignGlyphGroupRanges(size, ggis);

        GVTGlyphVector gv     = ggis[0].getGlyphVector();
        int            justType = FULL_WORD;
        double         ggAdv  = 0;
        double         gAdv   = 0;

        // Calculate the number of Glyph Groups and the number
        // of glpyhs in each range for use with full justification.
        int []rangeGG = new int[numRanges];
        int []rangeG  = new int[numRanges];
        GlyphGroupInfo []rangeLastGGI = new GlyphGroupInfo[numRanges];
        GlyphGroupInfo ggi  = ggis[0];
        int r = ggi.getRange();
        rangeGG[r]++;
        rangeG [r] += ggi.getGlyphCount();
        for (int i=1; i<size; i++) {
            ggi  = ggis[i];
            r = ggi.getRange();
            if ((rangeLastGGI[r]==null) || !rangeLastGGI[r].getHideLast())
                rangeGG[r]++;
            rangeLastGGI[r] = ggi;

            rangeG [r] += ggi.getGlyphCount();

            GlyphGroupInfo pggi = ggis[i-1];
            int pr = pggi.getRange();
            if (r != pr)
                rangeG[pr]+= pggi.getLastGlyphCount()-pggi.getGlyphCount();
        }
        rangeG[r]+= ggi.getLastGlyphCount()-ggi.getGlyphCount();

        int currRange = -1;
        double         locX=0, range=0, rAdv=0;
        r=-1;
        ggi = null;
        for (int i=0; i<size; i++) {
            GlyphGroupInfo pggi = ggi;
            int prevRange = currRange;

            ggi       = ggis[i];
            currRange = ggi.getRange();

            if (currRange != prevRange) {
                locX   = ranges[2*currRange];
                range  = ranges[2*currRange+1]-locX;
                rAdv   = rangeAdv[currRange];
                int textAlign = bi.getTextAlignment();
                if ((paraEnd) && (textAlign == BlockInfo.ALIGN_FULL))
                    textAlign = BlockInfo.ALIGN_START;

                switch (textAlign) {
                default:
                case BlockInfo.ALIGN_FULL: {
                    double delta = range-rAdv;
                    if (justType == FULL_WORD) {
                        int numSp = rangeGG[currRange]-1;
                        if (numSp >= 1)
                            ggAdv = delta/numSp;
                    } else {
                        int numSp = rangeG[currRange]-1;
                        if (numSp >= 1) gAdv  = delta/numSp;
                    }
                } break;
                case BlockInfo.ALIGN_START:  break;
                case BlockInfo.ALIGN_MIDDLE: locX += (range-rAdv)/2; break;
                case BlockInfo.ALIGN_END:    locX += (range-rAdv);   break;
                }
            } else if ((pggi!= null) && pggi.getHideLast()) {
                // Hide last glyph from prev glyph group (soft hyphen etc).
                gv.setGlyphVisible(pggi.getEnd(), false);
           }

            int        start  = ggi.getStart();
            int        end    = ggi.getEnd();
            boolean [] hide   = ggi.getHide();
            Point2D    p2d    = gv.getGlyphPosition(start);
            double     deltaX = p2d.getX();
            double     advAdj = 0;
            for (int g=start; g<=end; g++) {
                Point2D np2d = gv.getGlyphPosition(g+1);
                if (hide[g-start]) {
                    gv.setGlyphVisible(g, false);
                    advAdj += np2d.getX()-p2d.getX();
                } else {
                    gv.setGlyphVisible(g, true);
                }
                p2d.setLocation(p2d.getX()-deltaX-advAdj+locX,
                                p2d.getY()+baseline);
                gv.setGlyphPosition(g, p2d);
                p2d = np2d;
                advAdj -= gAdv;
            }
            if (ggi.getHideLast())
                locX += ggi.getAdvance()-advAdj;
            else
                locX += ggi.getAdvance()-advAdj+ggAdv;
        }
    }

    public static GlyphGroupInfo [] assureSize
        (GlyphGroupInfo [] ggis, int sz) {
        if (ggis == null) {
            if (sz < 10) sz = 10;
            return new GlyphGroupInfo[sz];
        }
        if (sz <= ggis.length)
            return ggis;

        int nsz = ggis.length*2;
        if (nsz < sz) nsz = sz;
        return new GlyphGroupInfo[nsz];
    }
}
