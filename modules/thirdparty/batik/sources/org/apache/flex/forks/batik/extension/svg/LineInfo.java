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
package org.apache.flex.forks.batik.extension.svg;

import java.awt.geom.Point2D;
import java.text.AttributedCharacterIterator;

import org.apache.flex.forks.batik.gvt.font.GVTGlyphVector;

/**
 * This class encapsulates the layout information about a single line
 * in a multi-line flow.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: LineInfo.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public class LineInfo {

    Point2D.Float               loc;
    AttributedCharacterIterator aci;
    GVTGlyphVector              gv;
    int                         startIdx;
    int                         endIdx;
    float                       advance;
    float                       visualAdvance;
    float                       lastCharWidth;
    float                       lineWidth;
    boolean                     partial;
    Point2D.Float               verticalAlignOffset;

    /**
     *
     */
    public LineInfo(Point2D.Float loc,
                    AttributedCharacterIterator aci,
                    GVTGlyphVector gv,
                    int startIdx, int endIdx,
                    float advance,
                    float visualAdvance,
                    float lastCharWidth,
                    float lineWidth,
                    boolean partial,
                    Point2D.Float verticalAlignOffset) {
        this.loc           = loc;
        this.aci           = aci;
        this.gv            = gv;
        this.startIdx      = startIdx;
        this.endIdx        = endIdx;
        this.advance       = advance;
        this.visualAdvance = visualAdvance;
        this.lastCharWidth = lastCharWidth;
        this.lineWidth     = lineWidth;
        this.partial       = partial;
        this.verticalAlignOffset = verticalAlignOffset;
    }

    public Point2D.Float  getLocation()         { return loc; }
    public AttributedCharacterIterator getACI() { return aci; }
    public GVTGlyphVector getGlyphVector()      { return gv; }
    public int            getStartIdx()         { return startIdx; }
    public int            getEndIdx()           { return endIdx; }
    public float          getAdvance()          { return advance; }
    public float          getVisualAdvance()    { return visualAdvance; }
    public float          getLastCharWidth()    { return lastCharWidth; }
    public float          getLineWidth()        { return lineWidth; }
    public boolean        isPartialLine()       { return partial; }
    public Point2D.Float  getVerticalAlignOffset()    { return verticalAlignOffset; }

    public String         toString() {
        return "[LineInfo loc: " + loc
                + " [" + startIdx + ',' + endIdx + "] "
                + " LWidth: " + lineWidth
                + " Adv: " + advance
                + " VAdv: " + visualAdvance
                + " LCW: " + lastCharWidth
                + " Partial: " + partial
                + " verticalAlignOffset: " + verticalAlignOffset;
    }

}
