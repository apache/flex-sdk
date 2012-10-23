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

import java.awt.font.FontRenderContext;
import java.awt.geom.Point2D;
import java.text.AttributedCharacterIterator;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.gvt.font.GVTGlyphVector;
import org.apache.flex.forks.batik.gvt.font.MultiGlyphVector;
import org.apache.flex.forks.batik.gvt.text.GlyphLayout;

/**
 * A GlyphLayout class for SVG 1.2 flowing text.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: FlowExtGlyphLayout.java 475477 2006-11-15 22:44:28Z cam $
 */
public class FlowExtGlyphLayout extends GlyphLayout {

    public FlowExtGlyphLayout(AttributedCharacterIterator aci,
                           int [] charMap,
                           Point2D offset,
                           FontRenderContext frc) {
        super(aci, charMap, offset, frc);
    }


    // Issues: 
    //   Should the font size of non-printing chars affect line spacing?
    //   Does line breaking get done before/after ligatures?
    //   What should be done if the next glyph does not fit in the
    //   flow rect (very narrow flow rect).
    //      Print the one char anyway.
    //      Go to the next flow rect.
    //   Should dy be considered for line offsets? (super scripts)
    //   Should p's & br's carry over from flow rect to flow rect if
    //   so how much????

    // In cases where 1/2 leading is negative (lineBox is smaller than
    // lineAscent+lineDescent) do we use the lineBox (some glyphs will
    // go outside flowRegion) or the visual box.  My feeling is that
    // we should use the larger of the two.

    // We stated that for empty para elements it moves to the new flow
    // region if the zero-height line is outside the flow region.  In
    // this case the para elements top-margin is used in the new flow
    // region (and it's bottom-margin is collapsed with the next
    // flowPara element if any).  What happens when the first line of
    // a non-empty flowPara doesn't fit (so the top margin does fit
    // but the first line of text doesn't).  I think the para should
    // move to the next flow region and the top margin should apply in
    // the new flow region.  The top margin does not apply if
    // subsequint lines move to a new flow region.

    // Note that line wrapping is done on visual bounds of glyph
    // not the glyph advance (which often includes some whitespace
    // after the right edge of the glyph char).

    //
    //   How are Margins done?  Can't figure out Box size until
    //   after we know the margins.
    //   Should 'A' element be allowed in 'flowPara'.
    //   
    //   For Full justification:
    //       Streach glyphs to fill line? (attribute?)
    //       What to do with partial line (last line in 'p', 'line'
    //       element, or 'div' element), still full justify, just left 
    //       justify, attribute?
    //       What to do when only one glyph on line? left or center or stretch?
    //       For full to look good I think the line must be able to squeeze a
    //         bit as well as grow (pretty easy to add).
    //
    // This Only does horizontal languages.
    // Supports Zero Width Spaces (0x200B) Zero Width Joiner( 0x200D), 
    // and soft hyphens (0x00AD).
    // 
    // Does not properly handle Bi-DI languages (does text wrapping on
    // display order not logical order).

    /**
     * This will wrap the text associated with <tt>aci</tt> and
     * <tt>layouts</tt>.
     * @param acis An array of Attributed Charater Iterators containing the 
     *             text to wrap.  There is one aci per text chunk
     *             (which maps to flowPara elements. Used to access
     *             font, paragraph, and line break info.
     * @param chunkLayouts A List of List of GlyphLayout objects.  There
     *                     is a List of GlyphLayout objects for each
     *                     flowPara element.  There is a GlyphLayout
     *                     for approximately each sub element in the 
     *                     flowPara element.
     * @param flowRects A List of Rectangle2D representing the regions
     *                  to flow text into.
     */
    public static void textWrapTextChunk(AttributedCharacterIterator [] acis,
                                         List chunkLayouts,
                                         List flowRects) {
        // System.out.println("Len: " + acis.length + " Size: " + 
        //                    chunkLayouts.size());

        // Make a list of the GlyphVectors so we can construct a
        // multiGlyphVector that makes them all look like one big
        // glyphVector
        GVTGlyphVector [] gvs            = new GVTGlyphVector[acis.length];
        List           [] chunkLineInfos = new List          [acis.length];
        GlyphIterator  [] gis            = new GlyphIterator [acis.length];
        Iterator clIter = chunkLayouts.iterator();

        // Get an iterator for the flow rects.
        Iterator flowRectsIter = flowRects.iterator();
        // Get info for new flow rect.
        RegionInfo currentRegion = null;
        float y0, x0, width, height=0;
        if (flowRectsIter.hasNext()) {
            currentRegion = (RegionInfo) flowRectsIter.next();
            height = (float) currentRegion.getHeight();
        }

        boolean lineHeightRelative = true;
        float lineHeight           = 1.0f;
        float nextLineMult         = 0.0f;
        float dy                   = 0.0f;

        //
        Point2D.Float verticalAlignOffset = new Point2D.Float(0,0);

        //System.out.println("Chunks: " + numChunks);
        
        float prevBotMargin = 0;
        for (int chunk=0; clIter.hasNext(); chunk++) {
            // System.out.println("Chunk: " + chunk);
            AttributedCharacterIterator aci = acis[chunk];
            if (currentRegion != null)
            {
                List extraP = (List)aci.getAttribute(FLOW_EMPTY_PARAGRAPH);
                if (extraP != null) {
                    Iterator epi = extraP.iterator();
                    while (epi.hasNext()) {
                        MarginInfo emi = (MarginInfo)epi.next();
                        float inc = ((prevBotMargin > emi.getTopMargin()) 
                                     ? prevBotMargin 
                                     : emi.getTopMargin());
                        if ((dy + inc <= height) &&
                            !emi.isFlowRegionBreak()) {
                            dy += inc;
                            prevBotMargin = emi.getBottomMargin();
                        } else {
                            // Move to next flow region..
                            if (!flowRectsIter.hasNext()) {
                                currentRegion = null;
                                break; // No flow rect stop layout here...
                            }

                            // NEXT FLOW REGION
                            currentRegion = (RegionInfo) flowRectsIter.next();
                            height = (float) currentRegion.getHeight();
                            // start a new alignment offset for this flow rect.
                            verticalAlignOffset = new Point2D.Float(0,0);

                            // Don't use this paragraph info in next
                            // flow region!
                            dy            = 0;
                            prevBotMargin = 0;
                        }
                    }

                    if (currentRegion == null) break;
                }
            }

            List gvl = new LinkedList();
            List layouts = (List)clIter.next();
            Iterator iter = layouts.iterator();
            while (iter.hasNext()) {
                GlyphLayout gl = (GlyphLayout)iter.next();
                gvl.add(gl.getGlyphVector());
            }
            GVTGlyphVector gv = new MultiGlyphVector(gvl);
            gvs[chunk] = gv;
            int numGlyphs = gv.getNumGlyphs();

            // System.out.println("Glyphs: " + numGlyphs);

            aci.first();
            MarginInfo mi = (MarginInfo)aci.getAttribute(FLOW_PARAGRAPH);
            if (mi == null) {
              continue;
            }
            // int justification = mi.getJustification();

            if (currentRegion == null) {
                for(int idx=0; idx <numGlyphs; idx++) 
                    gv.setGlyphVisible(idx, false);
                continue;
            }

            float inc = ((prevBotMargin > mi.getTopMargin()) 
                         ? prevBotMargin : mi.getTopMargin());
            if (dy + inc <= height) {
                dy += inc;
            } else {
                // Move to next flow region..
                // NEXT FLOW REGION
                if (!flowRectsIter.hasNext()) {
                    currentRegion = null;
                    break; // No flow rect stop layout here...
                }

                // NEXT FLOW REGION
                currentRegion = (RegionInfo) flowRectsIter.next();
                height = (float) currentRegion.getHeight();
                // start a new alignment offset for this flow rect..
                verticalAlignOffset = new Point2D.Float(0,0);

                // New rect so no previous row to consider...
                dy        = mi.getTopMargin();
            }
            prevBotMargin = mi.getBottomMargin();

            float leftMargin = mi.getLeftMargin();
            float rightMargin = mi.getRightMargin();
            if (((GlyphLayout)layouts.get(0)).isLeftToRight()) {
                leftMargin += mi.getIndent();
            } else {
                rightMargin += mi.getIndent();
            }

            x0 = (float) currentRegion.getX() + leftMargin;
            y0 = (float) currentRegion.getY();
            width = (float) (currentRegion.getWidth() - 
                             (leftMargin + rightMargin));
            height = (float) currentRegion.getHeight();
            
            List lineInfos = new LinkedList();
            chunkLineInfos[chunk] = lineInfos;

            float prevDesc = 0.0f;
            GlyphIterator gi = new GlyphIterator(aci, gv);
            gis[chunk] = gi;

            GlyphIterator breakGI  = null, newBreakGI = null;

            if (!gi.done() && !gi.isPrinting()) {
                // This will place any preceeding whitespace on an
                // imaginary line that preceeds the real first line of
                // the paragraph, also calculate the vertical
                // alignment offset, this will be repeated until the
                // last line in the flow rect.
               updateVerticalAlignOffset(verticalAlignOffset, 
                                         currentRegion, dy);
               lineInfos.add(gi.newLine
                             (new Point2D.Float(x0, y0+dy), 
                              width, true, verticalAlignOffset));
            }


            GlyphIterator lineGI   =  gi.copy();
            boolean firstLine = true;
            while (!gi.done()) {
                boolean doBreak = false;
                boolean partial = false;

                if (gi.isPrinting() && (gi.getAdv() > width)) {
                    if (breakGI == null) {
                        // first char on line didn't fit.
                        // move to next flow rect.
                        if (!flowRectsIter.hasNext()) {
                            currentRegion = null;
                            gi = lineGI.copy(gi);
                            break; // No flow rect stop layout here...
                        }

                        // NEXT FLOW REGION
                        currentRegion = (RegionInfo) flowRectsIter.next();
                        x0 = (float) currentRegion.getX() + leftMargin;
                        y0 = (float) currentRegion.getY();
                        width = (float) (currentRegion.getWidth() -
                                        (leftMargin+rightMargin));
                        height = (float) currentRegion.getHeight();
                        // start a new alignment offset for this flow rect..
                        verticalAlignOffset = new Point2D.Float(0,0);

                        // New rect so no previous row to consider...
                        dy = firstLine ? mi.getTopMargin() : 0;
                        prevDesc  = 0;
                        gi = lineGI.copy(gi);
                        continue;
                    }

                    gi = breakGI.copy(gi);  // Back up to break loc...

                    nextLineMult = 1;
                    doBreak = true;
                    partial = false;
                } else if (gi.isLastChar()) {
                    nextLineMult = 1;
                    doBreak = true;
                    partial = true;
                } 
                int lnBreaks = gi.getLineBreaks();
                if (lnBreaks != 0) {
                    if (doBreak)
                        nextLineMult -= 1;
                    nextLineMult += lnBreaks;
                    doBreak = true;
                    partial = true;
                }

                if (!doBreak) {
                    // System.out.println("No Brk Adv: " + gi.getAdv());
                    // We don't need to break the line because of this glyph
                    // So we just check if we need to update our break loc.
                    if ((gi.isBreakChar()) ||
                        (breakGI == null)  ||
                        (!breakGI.isBreakChar())) {
                        // Make this the new break if curr char is a
                        // break char or we don't have any break chars
                        // yet, or our current break char is also not
                        // a break char.
                        newBreakGI = gi.copy(newBreakGI);
                        gi.nextChar();
                        if (gi.getChar() != GlyphIterator.ZERO_WIDTH_JOINER) {
                            GlyphIterator tmpGI = breakGI;
                            breakGI = newBreakGI;
                            newBreakGI = tmpGI;
                        }
                    } else {
                        gi.nextChar();
                    }
                    continue;
                }

                // System.out.println("   Brk Adv: " + gi.getAdv());

                // We will now attempt to break the line just
                // after 'gi'.

                // Note we are trying to figure out where the current
                // line is going to be placed (not the next line).  We
                // must wait until we have a potential line break so
                // we know how tall the line is.

                // Get the nomial line advance based on the
                // largest font we encountered on line...
                float lineSize = gi.getMaxAscent()+gi.getMaxDescent(); 
                float lineBoxHeight;
                if (lineHeightRelative) 
                    lineBoxHeight = gi.getMaxFontSize()*lineHeight;
                else
                    lineBoxHeight = lineHeight;
                float halfLeading = (lineBoxHeight-lineSize)/2;

                float ladv = prevDesc + halfLeading + gi.getMaxAscent();
                float newDesc = halfLeading + gi.getMaxDescent();

                dy += ladv;
                float bottomEdge = newDesc;
                if (newDesc < gi.getMaxDescent()) 
                    bottomEdge = gi.getMaxDescent();

                if ((dy + bottomEdge) > height)  {
                    // The current Line doesn't fit in the
                    // current flow rectangle so we need to
                    // move line to the next flow rect.

                    // System.out.println("Doesn't Fit: " + dy);

                    if (!flowRectsIter.hasNext()) {
                        currentRegion = null;
                        gi = lineGI.copy(gi);
                        break; // No flow rect stop layout here...
                    }

                        // Remember how wide this rectangle is...
                    float oldWidth = width;

                    // Get info for new flow rect.
                    currentRegion = (RegionInfo) flowRectsIter.next();
                    x0     = (float) currentRegion.getX() + leftMargin;
                    y0     = (float) currentRegion.getY();
                    width  = (float)(currentRegion.getWidth() -
                                     (leftMargin+rightMargin));
                    height = (float) currentRegion.getHeight();
                    // start a new alignment offset for this flow rect..
                    verticalAlignOffset = new Point2D.Float(0,0);

                    // New rect so no previous row to consider...
                    dy = firstLine ? mi.getTopMargin() : 0;
                    prevDesc  = 0;
                    // previous flows?

                    if ((oldWidth > width) || (lnBreaks != 0)) {
                        // need to back up to start of line...
                        gi = lineGI.copy(gi);
                    }
                    continue;
                }

                prevDesc = newDesc + (nextLineMult-1)*lineBoxHeight;
                nextLineMult = 0f;
                updateVerticalAlignOffset(verticalAlignOffset, 
                                          currentRegion, dy + bottomEdge);
                lineInfos.add(gi.newLine
                              (new Point2D.Float(x0, y0 + dy), width, partial, 
                               verticalAlignOffset));

                // System.out.println("Fit: " + dy);
                x0    -= leftMargin;
                width += leftMargin+rightMargin;

                leftMargin  = mi.getLeftMargin();
                rightMargin = mi.getRightMargin();
                x0    += leftMargin;
                width -= leftMargin+rightMargin;

                firstLine = false;
                // The line fits in the current flow rectangle.
                lineGI  = gi.copy(lineGI);
                breakGI = null;
            }
            dy += prevDesc;

            int idx = gi.getGlyphIndex();
            while(idx <numGlyphs) 
                gv.setGlyphVisible(idx++, false);

            if (mi.isFlowRegionBreak()) {
                // Move to next flow region..
                currentRegion = null;
                if (flowRectsIter.hasNext()) {
                    currentRegion = (RegionInfo) flowRectsIter.next();
                    height = (float) currentRegion.getHeight();

                    // Don't use this paragraph's info in next
                    // flow region!
                    dy            = 0;
                    prevBotMargin = 0;
                    verticalAlignOffset = new Point2D.Float(0,0);
                }
            }
        }

        for (int chunk=0; chunk < acis.length; chunk++) {
            List lineInfos = chunkLineInfos[chunk];
            if (lineInfos == null) continue;

            AttributedCharacterIterator aci = acis[chunk];
            aci.first();
            MarginInfo mi = (MarginInfo)aci.getAttribute(FLOW_PARAGRAPH);
            if (mi == null) {
              continue;
            }
            int justification = mi.getJustification();
            
            GVTGlyphVector gv = gvs[chunk];
            if (gv == null) break;

            GlyphIterator gi = gis[chunk];
            
            layoutChunk(gv, gi.getOrigin(), justification, lineInfos);
        }
    }


    /**
     * Updates the specified verticalAlignmentOffset using the current
     * alignment rule and the heights of the flow rect and the maximum
     * descent of the text.  This method gets for called every line,
     * but only the value that is calculated for the last line of the
     * flow rect is used by the glyph rendering.  This is achieved by
     * creating a new verticalAlignOffset object everytime a new flow
     * rect is encountered, thus a single verticalAlignmentOffset is
     * shared for all {@link LineInfo} objects created for a given
     * flow rect.  The value is calculated by determining the left
     * over space in the flow rect and scaling that value by 1.0 to
     * align to the bottom, 0.5 for middle and 0.0 for top.
     *
     * @param verticalAlignOffset the {@link java.awt.geom.Point2D.Float}
     *        object that is storing the alignment offset.
     * @param region the {@link RegionInfo} object that we are rendering into.
     * @param maxDescent the very lowest point this line reaches.
     */
    public static void updateVerticalAlignOffset
        (Point2D.Float verticalAlignOffset,
         RegionInfo region, float maxDescent)
        {
            float freeSpace = (float)region.getHeight() - maxDescent;
            verticalAlignOffset.setLocation
                (0, region.getVerticalAlignment() * freeSpace);
        }

    public static void layoutChunk(GVTGlyphVector gv, Point2D origin,
                                   int justification,
                                   List lineInfos) {
        Iterator lInfoIter = lineInfos.iterator();
        int numGlyphs      = gv.getNumGlyphs();
        float [] gp        = gv.getGlyphPositions(0, numGlyphs+1, null);
        Point2D.Float lineLoc  = null;
        float         lineAdv  = 0;
        float         lineVAdv = 0;

        float xOrig=(float)origin.getX();
        float yOrig=(float)origin.getY();

        float xScale=1;
        float xAdj=0;
        float charW=0;
        float lineWidth=0;
        boolean partial = false;
        float verticalAlignOffset = 0;

        // This loop goes through and puts glyphs where they belong
        // based on info collected in first trip through glyphVector...
        int lineEnd = 0;
        int i;
        Point2D.Float pos = new Point2D.Float();
        for (i =0; i<numGlyphs; i++) {
            if (i == lineEnd) {
                // Always comes through here on first char...

                // Update offset for new line based on last line length
                xOrig += lineAdv;

                // Get new values for everything...
                if (!lInfoIter.hasNext())
                    break;
                LineInfo li = (LineInfo)lInfoIter.next();
                // System.out.println(li.toString());

                lineEnd   = li.getEndIdx();
                lineLoc   = li.getLocation();
                lineAdv   = li.getAdvance();
                lineVAdv  = li.getVisualAdvance();
                charW     = li.getLastCharWidth();
                lineWidth = li.getLineWidth();
                partial   = li.isPartialLine();
                verticalAlignOffset = li.getVerticalAlignOffset().y;

                xAdj = 0;
                xScale = 1;
                // Recalc justification info.
                switch (justification) {
                case 0: default: break;                  // Left
                case 1:                                  // Center
                    xAdj = (lineWidth - lineVAdv) / 2;
                    break;
                case 2:                                  // Right
                    xAdj = lineWidth - lineVAdv;
                    break;
                case 3:                                  // Full
                    if ((!partial) && (lineEnd != i+1)) {
                        // More than one char on line...
                        // Scale char spacing to fill line.
                        xScale = (lineWidth-charW)/(lineVAdv-charW);
                    }
                    break;
                }
            }
            pos.x = lineLoc.x + (gp[2*i]  -xOrig)*xScale+xAdj;
            pos.y = lineLoc.y + ((gp[2 * i + 1] - yOrig) + 
                                 verticalAlignOffset);
            gv.setGlyphPosition(i, pos);
        }

        pos.x = xOrig;
        pos.y = yOrig;
        if (lineLoc != null) {
          pos.x = lineLoc.x + (gp[2*i]  -xOrig)*xScale+xAdj;
          pos.y = lineLoc.y + (gp[2 * i + 1] - yOrig) + verticalAlignOffset;
        }
        gv.setGlyphPosition(i, pos);
    }
}
