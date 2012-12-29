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

import org.apache.flex.forks.batik.gvt.font.GVTGlyphVector;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: GlyphGroupInfo.java 475477 2006-11-15 22:44:28Z cam $
 */
class GlyphGroupInfo {
    int start, end;
    int glyphCount, lastGlyphCount;
    boolean hideLast;
    float advance, lastAdvance;
    int range;
    GVTGlyphVector gv;
    boolean [] hide;

    public GlyphGroupInfo(GVTGlyphVector gv, 
                          int start,
                          int end,
                          boolean  [] glyphHide,
                          boolean glyphGroupHideLast,
                          float   [] glyphPos,
                          float   [] advAdj,
                          float   [] lastAdvAdj,
                          boolean [] space) {
        this.gv             = gv;
        this.start          = start;
        this.end            = end;
        this.hide           = new boolean[this.end-this.start+1];
        this.hideLast       = glyphGroupHideLast;
        System.arraycopy(glyphHide, this.start, this.hide, 0, 
                         this.hide.length);

        float adv  = glyphPos[2*end+2]-glyphPos[2*start];
        float ladv = adv;
        adv += advAdj[end];
        int glyphCount = end-start+1;
        for (int g=start; g<end; g++) {
            if (glyphHide[g]) glyphCount--;
        }
        int lastGlyphCount = glyphCount;
        for (int g=end; g>=start; g--) {
            ladv += lastAdvAdj[g];
            if (!space[g]) break;
            lastGlyphCount--;
        }
        if (hideLast) lastGlyphCount--;

        this.glyphCount     = glyphCount;
        this.lastGlyphCount = lastGlyphCount;
        this.advance        = adv;
        this.lastAdvance    = ladv;
    }

    /**
     * Get the GlyphVector for this GlyphGroup.
     */
    public GVTGlyphVector getGlyphVector() { return gv; }

    /** get the start glyph index for this glyph group. */
    public int     getStart() { return start; }
    /** get the end glyph index for this glyph group. */
    public int     getEnd() { return end; }

    /** get the number of glyphs that count when it's not the
     *   last in the line (basically end-start+1-sum(hide) ). 
     */
    public int     getGlyphCount() { return glyphCount; }
    /** get the number of glyphs that 'cout' when it is the
     *  last in the line. This is glyphCount minus any
     * trailing spaces, and minus the last glyph if hideLast
     * is true.
     */
    public int     getLastGlyphCount() { return lastGlyphCount; }

    public boolean [] getHide() { return hide; }

    /** return true if 'end' glyph should be hidden in cases
     *  where this is not the last glyph group in a span */
    public boolean getHideLast() { return hideLast; }
    /**
     * returns the advance to use when this glyphGroup is
     * not the last glyph group in a span.
     */
    public float   getAdvance() { return advance; }
    /**
     * returns the advance to use when this glyphGroup is
     * the last glyph group in a span.  This generally includes
     * the width of the last glyph if 'HideLast' is true.  Also
     * in Japanese some glyphs should not be counted for line
     * width (they may go outside the flow area).
     */
    public float   getLastAdvance() { return lastAdvance; }

    public void setRange(int range) { this.range = range; }
    public int getRange() { return this.range; }
}

