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

import java.awt.font.FontRenderContext;
import java.awt.font.TextAttribute;
import java.text.AttributedCharacterIterator;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.Arrays;

import org.apache.flex.forks.batik.gvt.TextNode;
import org.apache.flex.forks.batik.gvt.TextPainter;
import org.apache.flex.forks.batik.gvt.font.GVTFont;
import org.apache.flex.forks.batik.gvt.font.GVTGlyphVector;
import org.apache.flex.forks.batik.gvt.font.GVTLineMetrics;
import org.apache.flex.forks.batik.gvt.font.MultiGlyphVector;
import org.apache.flex.forks.batik.gvt.renderer.StrokingTextPainter;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.GlyphLayout;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: FlowTextPainter.java 503369 2007-02-04 07:25:21Z cam $
 */
public class FlowTextPainter extends StrokingTextPainter {
    /**
     * A unique instance of this class.
     */
    protected static TextPainter singleton = new FlowTextPainter();

    /**
     * Returns a unique instance of this class.
     */
    public static TextPainter getInstance() {
        return singleton;
    }

    public List getTextRuns(TextNode node, AttributedCharacterIterator aci) {
        List textRuns = node.getTextRuns();
        if (textRuns != null) {
            return textRuns;
        }

        AttributedCharacterIterator[] chunkACIs = getTextChunkACIs(aci);
        textRuns = computeTextRuns(node, aci, chunkACIs);

        aci.first();
        List rgns = (List)aci.getAttribute(FLOW_REGIONS);

        if (rgns != null) {
            Iterator i = textRuns.iterator();
            List chunkLayouts = new ArrayList();
            TextRun tr = (TextRun)i.next();
            List layouts = new ArrayList();
            chunkLayouts.add(layouts);
            layouts.add(tr.getLayout());
            while (i.hasNext()) {
                tr = (TextRun)i.next();
                if (tr.isFirstRunInChunk()) {
                    layouts = new ArrayList();
                    chunkLayouts.add(layouts);
                }
                layouts.add(tr.getLayout());
            }

            textWrap(chunkACIs, chunkLayouts, rgns, fontRenderContext);
        }


        node.setTextRuns(textRuns);
        return node.getTextRuns();
    }

    public static final char SOFT_HYPHEN       = 0x00AD;
    public static final char ZERO_WIDTH_SPACE  = 0x200B;
    public static final char ZERO_WIDTH_JOINER = 0x200D;
    public static final char SPACE             = ' ';

    public static final AttributedCharacterIterator.Attribute WORD_LIMIT =
        TextLineBreaks.WORD_LIMIT;

    public static final AttributedCharacterIterator.Attribute FLOW_REGIONS =
        GVTAttributedCharacterIterator.TextAttribute.FLOW_REGIONS;

    public static final AttributedCharacterIterator.Attribute FLOW_LINE_BREAK
        = GVTAttributedCharacterIterator.TextAttribute.FLOW_LINE_BREAK;
    public static final AttributedCharacterIterator.Attribute LINE_HEIGHT
        = GVTAttributedCharacterIterator.TextAttribute.LINE_HEIGHT;

    public static final AttributedCharacterIterator.Attribute GVT_FONT
        = GVTAttributedCharacterIterator.TextAttribute.GVT_FONT;

    protected static Set szAtts = new HashSet();

    static {
        szAtts.add(TextAttribute.SIZE);
        szAtts.add(GVT_FONT);
        szAtts.add(LINE_HEIGHT);
    }

    public static boolean textWrap(AttributedCharacterIterator [] acis,
                                   List chunkLayouts,
                                   List flowRects,
                                   FontRenderContext frc) {

        // System.out.println("Len: " + acis.length + " Size: " +
        //                     chunkLayouts.size());

        // Make a list of the GlyphVectors so we can construct a
        // multiGlyphVector that makes them all look like one big
        // glyphVector
        GVTGlyphVector [] gvs            = new GVTGlyphVector[acis.length];
        WordInfo       [][] wordInfos    = new WordInfo[acis.length][];
        Iterator clIter = chunkLayouts.iterator();

        float prevBotMargin = 0;
        int numWords = 0;
        BlockInfo [] blockInfos = new BlockInfo[acis.length];
        float      [] topSkip   = new float[acis.length];
        for (int chunk=0; clIter.hasNext(); chunk++) {
            // System.err.print("Chunk: " + chunk + " Str: '");
            AttributedCharacterIterator aci = acis[chunk];
            List gvl = new LinkedList();
            List layouts = (List)clIter.next();
            Iterator iter = layouts.iterator();
            while (iter.hasNext()) {
                GlyphLayout gl = (GlyphLayout)iter.next();
                gvl.add(gl.getGlyphVector());
            }
            GVTGlyphVector gv = new MultiGlyphVector(gvl);
            gvs[chunk] = gv;
            wordInfos[chunk] = doWordAnalysis(gv, aci, numWords, frc);
            aci.first();
            BlockInfo bi = (BlockInfo)aci.getAttribute(FLOW_PARAGRAPH);
            bi.initLineInfo(frc);
            blockInfos[chunk] = bi;
            if (prevBotMargin > bi.getTopMargin())
                topSkip[chunk] = prevBotMargin;
            else
                topSkip[chunk] = bi.getTopMargin();
            prevBotMargin = bi.getBottomMargin();
            numWords += wordInfos[chunk].length;
        }

        Iterator frIter = flowRects.iterator();
        RegionInfo currentRegion = null;
        int currWord = 0;
        int chunk = 0;
        List lineInfos = new LinkedList();
        while(frIter.hasNext()) {
            currentRegion = (RegionInfo) frIter.next();
            FlowRegions fr = new FlowRegions(currentRegion.getShape());

            while (chunk < wordInfos.length) {
                WordInfo [] chunkInfo = wordInfos[chunk];
                BlockInfo bi = blockInfos[chunk];
                WordInfo  wi = chunkInfo[currWord];
                Object    flowLine = wi.getFlowLine();
                double    lh = Math.max(wi.getLineHeight(),bi.getLineHeight());
                LineInfo li = new LineInfo(fr, bi, true);
                double newY = li.getCurrentY()+topSkip[chunk];
                topSkip[chunk] = 0;
                if (li.gotoY(newY)) break;

                while (!li.addWord(wi)) {
                    // step down 1/10 of a line height and try again.
                    newY = li.getCurrentY()+lh*.1;
                    if (li.gotoY(newY)) break;
                }
                if (fr.done()) break;

                currWord++;
                for (;currWord < chunkInfo.length;currWord++) {
                    wi = chunkInfo[currWord];
                    if ((wi.getFlowLine() == flowLine) && (li.addWord(wi)))
                        continue;

                    // Word didn't fit or we hit end of flowLine elem,
                    // go to a new line.
                    li.layout();
                    lineInfos.add(li);
                    li = null;

                    flowLine = wi.getFlowLine();
                    lh  = Math.max(wi.getLineHeight(),bi.getLineHeight());
                    if (!fr.newLine(lh)) break; // region is done

                    li = new LineInfo(fr, bi, false);
                    while (!li.addWord(wi)) {
                        newY =li.getCurrentY()+lh*.1;
                        if (li.gotoY(newY)) break;
                    }
                    if (fr.done()) break;
                }
                if (li != null) {
                    li.setParaEnd(true);
                    li.layout();
                }

                if (fr.done()) break;

                chunk++;
                currWord = 0;

                if (bi.isFlowRegionBreak())
                    break;

                if (!fr.newLine(lh)) // Region is done.
                    break;
            }
            if (chunk == wordInfos.length)
                break;
        }

        boolean overflow = (chunk < wordInfos.length);

        while (chunk < wordInfos.length) {
            WordInfo [] chunkInfo = wordInfos[chunk];
            while (currWord < chunkInfo.length) {
                WordInfo wi = chunkInfo[currWord];
                int numGG = wi.getNumGlyphGroups();
                for (int gg=0; gg<numGG; gg++) {
                    GlyphGroupInfo ggi = wi.getGlyphGroup(gg);
                    GVTGlyphVector gv = ggi.getGlyphVector();
                    int end = ggi.getEnd();
                    for (int g=ggi.getStart(); g <= end; g++) {
                        gv.setGlyphVisible(g, false);
                    }
                }
                currWord++;
            }
            chunk++;
            currWord = 0;
        }

        return overflow;
    }

    static int[] allocWordMap(int[] wordMap, int sz) {
        if (wordMap != null) {
            if (sz <= wordMap.length) {
                return wordMap;
            }
            if (sz < wordMap.length * 2) {
                sz = wordMap.length * 2;
            }
        }

        // we have a problem when wordMap actually IS null....
        int[] ret = new int[sz];
        int ext = wordMap != null ? wordMap.length : 0;
        if (sz < ext) {
            ext = sz;
        }
        if (ext != 0) {
            System.arraycopy(wordMap, 0, ret, 0, ext);
        }
        Arrays.fill(ret, ext, sz, -1);

        return ret;
    }

    /**
     * This returns an array of glyphs numbers for each glyph
     * group in each word: ret[word][glyphGroup][glyphNum].
     */
    static WordInfo[] doWordAnalysis(GVTGlyphVector gv,
                                    AttributedCharacterIterator aci,
                                    int numWords,
                                    FontRenderContext frc) {
        int numGlyphs = gv.getNumGlyphs();
        int [] glyphWords = new int[numGlyphs];
        int [] wordMap = allocWordMap(null, 10);
        int maxWord = 0;
        int aciIdx = aci.getBeginIndex();
        // First we go through the glyphs seeing if any two ajacent
        // words need to be collapsed because of a ligature.  This
        // would be an odd case.  If it happens we consider the
        // two words to be one.
        for (int i=0; i<numGlyphs; i++) {
            int cnt = gv.getCharacterCount(i,i);
            aci.setIndex(aciIdx);
            Integer integer = (Integer)aci.getAttribute(WORD_LIMIT);
            int minWord = integer.intValue()-numWords;
            if (minWord > maxWord) {
                maxWord = minWord;
                wordMap = allocWordMap(wordMap, maxWord+1);
            }
            aciIdx++;
            for (int c=1; c<cnt; c++) {
                aci.setIndex(aciIdx);
                integer = (Integer)aci.getAttribute(WORD_LIMIT);
                int cWord = integer.intValue()-numWords;
                if (cWord > maxWord) {
                    maxWord = cWord;
                    wordMap = allocWordMap(wordMap, maxWord+1);
                }
                // We always want to use the min word as the main
                // index for the new composite word.
                if (cWord < minWord) {
                    wordMap[minWord] = cWord;
                    minWord = cWord;
                } else if (cWord > minWord) {
                    wordMap[cWord] = minWord;
                }
                aciIdx++;
            }
            glyphWords[i] = minWord;
        }
        int words=0;
        WordInfo [] cWordMap = new WordInfo[maxWord+1];
        for (int i=0; i<=maxWord; i++) {
            int nw = wordMap[i];
            if (nw == -1) {
                // new word so give it a number.
                cWordMap[i] = new WordInfo(words++);
            } else {
                int word = nw;
                nw = wordMap[i];
                while (nw != -1) {
                    word = nw;
                    nw = wordMap[word];
                }
                wordMap[i] = word; // help the next guy out
                cWordMap[i] = cWordMap[word];
            }
        }
        wordMap = null;
        WordInfo [] wordInfos = new WordInfo[words];
        for (int i=0; i<=maxWord; i++) {
            WordInfo wi = cWordMap[i];
            wordInfos[wi.getIndex()] = cWordMap[i];
        }

        aciIdx = aci.getBeginIndex();
        int aciEnd = aci.getEndIndex();
        char ch = aci.setIndex(aciIdx);

        int aciWordStart = aciIdx;
        GVTFont gvtFont = (GVTFont)aci.getAttribute(GVT_FONT);
        float lineHeight = 1.0f;
        Float lineHeightFloat = (Float)aci.getAttribute(LINE_HEIGHT);
        if (lineHeightFloat != null)
            lineHeight = lineHeightFloat.floatValue();
        int runLimit = aci.getRunLimit(szAtts);
        WordInfo prevWI = null;
        float   [] lastAdvAdj = new float  [numGlyphs];
        float   [] advAdj     = new float  [numGlyphs];
        boolean [] hideLast   = new boolean[numGlyphs];
        boolean [] hide       = new boolean[numGlyphs];
        boolean [] space      = new boolean[numGlyphs];
        float   [] glyphPos = gv.getGlyphPositions(0, numGlyphs+1, null);
        for (int i=0; i<numGlyphs; i++) {
            char pch = ch;
            ch = aci.setIndex(aciIdx);
            Integer integer = (Integer)aci.getAttribute(WORD_LIMIT);
            WordInfo theWI = cWordMap[integer.intValue()-numWords];
            if (theWI.getFlowLine() == null)
                theWI.setFlowLine(aci.getAttribute(FLOW_LINE_BREAK));

            if (prevWI == null) {
                prevWI = theWI;
            } else if (prevWI != theWI) {
                GVTLineMetrics lm = gvtFont.getLineMetrics
                    (aci, aciWordStart, aciIdx, frc);
                prevWI.addLineMetrics(gvtFont, lm);
                prevWI.addLineHeight(lineHeight);
                aciWordStart = aciIdx;
                prevWI = theWI;
            }

            int chCnt = gv.getCharacterCount(i,i);
            if (chCnt == 1) {
                char nch;
                float kern;
                switch(ch) {
                case SOFT_HYPHEN:
                    hideLast[i] = true;
                    nch = aci.next(); aci.previous();
                    kern = gvtFont.getHKern(pch, nch);
                    advAdj[i] = -(glyphPos[2*i+2]-glyphPos[2*i]+kern);
                    break;
                case ZERO_WIDTH_JOINER:
                    hide[i] = true;
                    break;
                case ZERO_WIDTH_SPACE:
                    hide[i] = true;
                    break;
                case SPACE:
                    space[i] = true;
                    nch = aci.next(); aci.previous();
                    kern = gvtFont.getHKern(pch, nch);
                    lastAdvAdj[i] = -(glyphPos[2*i+2]-glyphPos[2*i]+kern);
                default:
                }
            }

            aciIdx += chCnt;
            if ((aciIdx > runLimit) && (aciIdx < aciEnd)) {
                // Possible font size/style change so record current
                // line metrics and start fresh.
                GVTLineMetrics lm = gvtFont.getLineMetrics
                    (aci,aciWordStart, runLimit, frc);
                prevWI.addLineMetrics(gvtFont, lm);
                prevWI.addLineHeight(lineHeight);
                prevWI = null;
                aciWordStart = aciIdx;
                aci.setIndex(aciIdx);
                gvtFont = (GVTFont)aci.getAttribute(GVT_FONT);
                Float f = (Float)aci.getAttribute(LINE_HEIGHT);
                lineHeight = f.floatValue();
                runLimit = aci.getRunLimit(szAtts);
            }
        }
        GVTLineMetrics lm = gvtFont.getLineMetrics
            (aci,aciWordStart, runLimit, frc);
        prevWI.addLineMetrics(gvtFont, lm);
        prevWI.addLineHeight(lineHeight);

        int [] wordGlyphCounts = new int[words];
        // Build a mapping from words to glyphs.
        for (int i=0; i<numGlyphs; i++) {
            int word = glyphWords[i];
            int cWord = cWordMap[word].getIndex();
            glyphWords[i] = cWord;
            wordGlyphCounts[cWord]++;
        }

        cWordMap = null;
        int [][]wordGlyphs = new int [words][];
        int []wordGlyphGroupsCounts = new int [words];
        for (int i=0; i<numGlyphs; i++) {
            int cWord = glyphWords[i];
            // System.err.println("CW: " + cWord);
            int [] wgs = wordGlyphs[cWord];
            if (wgs == null) {
                wgs = wordGlyphs[cWord]
                    = new int[wordGlyphCounts[cWord]];
                // We use this to track where the next
                // glyph should go in wordGlyphs
                // by the time we are done it should be correct again.
                wordGlyphCounts[cWord] =0;
            }
            int cnt = wordGlyphCounts[cWord];
            wgs[cnt] = i;
            // Track the number of glyph groups in this word.
            if (cnt==0) {
                wordGlyphGroupsCounts[cWord]++;
            } else {
                if (wgs[cnt-1] != i-1)
                    wordGlyphGroupsCounts[cWord]++;
            }
            wordGlyphCounts[cWord]++;
        }

        for (int i=0; i<words; i++) {
            int cnt = wordGlyphGroupsCounts[i];
            // System.err.println("WGGC: " + cnt);
            GlyphGroupInfo []wordGlyphGroups = new GlyphGroupInfo[cnt];
            if (cnt == 1) {
                int [] glyphs = wordGlyphs[i];
                int start  = glyphs[0];
                int end    = glyphs[glyphs.length-1];
                wordGlyphGroups[0] = new GlyphGroupInfo
                    (gv, start, end, hide, hideLast[end],
                     glyphPos, advAdj, lastAdvAdj, space);
            } else {
                int glyphGroup = 0;
                int []glyphs = wordGlyphs[i];
                int prev = glyphs[0];
                int start = prev;
                for (int j=1; j<glyphs.length; j++) {
                    if (prev+1 != glyphs[j]) {
                        int end = glyphs[j-1];
                        wordGlyphGroups[glyphGroup] = new GlyphGroupInfo
                            (gv, start, end, hide, hideLast[end],
                             glyphPos, advAdj, lastAdvAdj, space);
                        start = glyphs[j];
                        glyphGroup++;
                    }
                    prev = glyphs[j];
                }
                int end = glyphs[glyphs.length-1];
                wordGlyphGroups[glyphGroup] = new GlyphGroupInfo
                    (gv, start, end, hide, hideLast[end],
                     glyphPos, advAdj, lastAdvAdj, space);
            }
            wordInfos[i].setGlyphGroups(wordGlyphGroups);
        }
        return wordInfos;
    }

}
