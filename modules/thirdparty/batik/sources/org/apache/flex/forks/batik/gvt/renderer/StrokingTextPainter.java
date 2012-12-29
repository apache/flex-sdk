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

package org.apache.flex.forks.batik.gvt.renderer;

import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.Stroke;
import java.awt.font.FontRenderContext;
import java.awt.font.TextAttribute;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;
import java.text.AttributedString;
import java.text.CharacterIterator;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.apache.flex.forks.batik.gvt.TextNode;
import org.apache.flex.forks.batik.gvt.TextPainter;
import org.apache.flex.forks.batik.gvt.font.FontFamilyResolver;
import org.apache.flex.forks.batik.gvt.font.GVTFont;
import org.apache.flex.forks.batik.gvt.font.GVTFontFamily;
import org.apache.flex.forks.batik.gvt.font.GVTGlyphMetrics;
import org.apache.flex.forks.batik.gvt.font.GVTLineMetrics;
import org.apache.flex.forks.batik.gvt.text.AttributedCharacterSpanIterator;
import org.apache.flex.forks.batik.gvt.text.BidiAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.Mark;
import org.apache.flex.forks.batik.gvt.text.TextHit;
import org.apache.flex.forks.batik.gvt.text.TextPaintInfo;
import org.apache.flex.forks.batik.gvt.text.TextPath;
import org.apache.flex.forks.batik.gvt.text.TextSpanLayout;


/**
 * More sophisticated implementation of TextPainter which
 * renders the attributed character iterator of a <tt>TextNode</tt>.
 * <em>StrokingTextPainter includes support for stroke, fill, opacity,
 * text-decoration, and other attributes.</em>
 *
 * @see org.apache.flex.forks.batik.gvt.TextPainter
 * @see org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: StrokingTextPainter.java 579030 2007-09-25 01:50:15Z cam $
 */
public class StrokingTextPainter extends BasicTextPainter {

    public static final
        AttributedCharacterIterator.Attribute PAINT_INFO =
        GVTAttributedCharacterIterator.TextAttribute.PAINT_INFO;

    public static final
        AttributedCharacterIterator.Attribute FLOW_REGIONS =
        GVTAttributedCharacterIterator.TextAttribute.FLOW_REGIONS;

    public static final
        AttributedCharacterIterator.Attribute FLOW_PARAGRAPH =
        GVTAttributedCharacterIterator.TextAttribute.FLOW_PARAGRAPH;

    public static final
        AttributedCharacterIterator.Attribute TEXT_COMPOUND_ID
        = GVTAttributedCharacterIterator.TextAttribute.TEXT_COMPOUND_ID;

    public static final
        AttributedCharacterIterator.Attribute GVT_FONT
        = GVTAttributedCharacterIterator.TextAttribute.GVT_FONT;

    public static final
        AttributedCharacterIterator.Attribute GVT_FONTS
        = GVTAttributedCharacterIterator.TextAttribute.GVT_FONTS;

    public static final
        AttributedCharacterIterator.Attribute BIDI_LEVEL
        = GVTAttributedCharacterIterator.TextAttribute.BIDI_LEVEL;

    public static final
        AttributedCharacterIterator.Attribute XPOS
        = GVTAttributedCharacterIterator.TextAttribute.X;

    public static final
        AttributedCharacterIterator.Attribute YPOS
        = GVTAttributedCharacterIterator.TextAttribute.Y;

    public static final
        AttributedCharacterIterator.Attribute TEXTPATH
        = GVTAttributedCharacterIterator.TextAttribute.TEXTPATH;


    public static final AttributedCharacterIterator.Attribute WRITING_MODE
        = GVTAttributedCharacterIterator.TextAttribute.WRITING_MODE;

    public static final Integer WRITING_MODE_TTB
        = GVTAttributedCharacterIterator.TextAttribute.WRITING_MODE_TTB;

    public static final Integer WRITING_MODE_RTL
        = GVTAttributedCharacterIterator.TextAttribute.WRITING_MODE_RTL;

    public static final
        AttributedCharacterIterator.Attribute ANCHOR_TYPE
        = GVTAttributedCharacterIterator.TextAttribute.ANCHOR_TYPE;

    public static final Integer ADJUST_SPACING =
        GVTAttributedCharacterIterator.TextAttribute.ADJUST_SPACING;
    public static final Integer ADJUST_ALL =
        GVTAttributedCharacterIterator.TextAttribute.ADJUST_ALL;
    public static final GVTAttributedCharacterIterator.TextAttribute ALT_GLYPH_HANDLER =
        GVTAttributedCharacterIterator.TextAttribute.ALT_GLYPH_HANDLER;

    static Set extendedAtts = new HashSet();

    static {
        extendedAtts.add(FLOW_PARAGRAPH);
        extendedAtts.add(TEXT_COMPOUND_ID);
        extendedAtts.add(GVT_FONT);
        // extendedAtts.add(BIDI_LEVEL);
    }

    /**
     * A unique instance of this class.
     */
    protected static TextPainter singleton = new StrokingTextPainter();

    /**
     * Returns a unique instance of this class.
     */
    public static TextPainter getInstance() {
        return singleton;
    }

    /**
     * Paints the specified text node using the specified Graphics2D.
     *
     * @param node the text node to paint
     * @param g2d the Graphics2D to use
     */
    public void paint(TextNode node, Graphics2D g2d) {
        AttributedCharacterIterator aci;
        aci = node.getAttributedCharacterIterator();
        if (aci == null)
            return;

        List textRuns = getTextRuns(node, aci);

        // draw the underline and overline first, then the actual text
        // and finally the strikethrough
        paintDecorations(textRuns, g2d, TextSpanLayout.DECORATION_UNDERLINE);
        paintDecorations(textRuns, g2d, TextSpanLayout.DECORATION_OVERLINE);
        paintTextRuns(textRuns, g2d);
        paintDecorations
            (textRuns, g2d, TextSpanLayout.DECORATION_STRIKETHROUGH);
    }

    protected void printAttrs(AttributedCharacterIterator aci) {
        aci.first();
        int start = aci.getBeginIndex();
        System.out.print("AttrRuns: ");
        while (aci.current() != CharacterIterator.DONE) {
            int end   = aci.getRunLimit();
            System.out.print(""+(end-start)+", ");
            aci.setIndex(end);
            start = end;
        }
        System.out.println("");
    }

    // static long reorderTime, fontMatchingTime, layoutTime;
    public List getTextRuns(TextNode node, AttributedCharacterIterator aci) {
        List textRuns = node.getTextRuns();
        if (textRuns != null) {
            return textRuns;
        }

        AttributedCharacterIterator[] chunkACIs = getTextChunkACIs(aci);
        textRuns = computeTextRuns(node, aci, chunkACIs);

        // t1 = System.currentTimeMillis();
        // layoutTime += t1-t0;
        // System.out.println("Reorder: " + reorderTime + " FontMatching: " + fontMatchingTime + " Layout: " + layoutTime);
        // cache the textRuns so don't need to recalculate
        node.setTextRuns(textRuns);
        return node.getTextRuns();
   }

    public List computeTextRuns(TextNode node,
                                AttributedCharacterIterator aci,
                                AttributedCharacterIterator [] chunkACIs) {
        int [][] chunkCharMaps = new int[chunkACIs.length][];

        // long t0, t1;
        // t0 = System.currentTimeMillis();
        // reorder each chunk ACI for bidi text
        int chunkStart = aci.getBeginIndex();
        for (int i = 0; i < chunkACIs.length; i++) {
            BidiAttributedCharacterIterator iter;
            iter = new BidiAttributedCharacterIterator
                (chunkACIs[i], fontRenderContext, chunkStart);
            chunkACIs    [i] = iter;
            chunkCharMaps[i] = iter.getCharMap();
            // t1 = System.currentTimeMillis();
            // reorderTime += t1-t0;
            // t0=t1;
            chunkACIs    [i] = createModifiedACIForFontMatching
                (chunkACIs[i]);

            chunkStart += (chunkACIs[i].getEndIndex()-
                           chunkACIs[i].getBeginIndex());
            // t1 = System.currentTimeMillis();
            // fontMatchingTime += t1-t0;
            // t0 = t1;
        }

        // create text runs for each chunk and add them to the list
        List textRuns = new ArrayList();
        TextChunk chunk, prevChunk=null;
        int currentChunk = 0;

        Point2D location = node.getLocation();
        do {
            // Text Chunks contain one or more TextRuns, which they
            // create from the ACI.
            chunkACIs[currentChunk].first();

            chunk = getTextChunk(node,
                                 chunkACIs[currentChunk],
                                 chunkCharMaps[currentChunk],
                                 textRuns,
                                 prevChunk);

            // Adjust according to text-anchor property value
            chunkACIs[currentChunk].first();
            if (chunk != null) {
                location = adjustChunkOffsets(location, textRuns, chunk);
            }
            prevChunk = chunk;
            currentChunk++;

        } while (chunk != null && currentChunk < chunkACIs.length);

        return textRuns;
    }

    /**
     * Returns an array of ACIs, one for each text chunk within the given
     * text node.
     */
    protected AttributedCharacterIterator[] getTextChunkACIs
        (AttributedCharacterIterator aci) {

        List aciList = new ArrayList();
        int chunkStartIndex = aci.getBeginIndex();
        aci.first();
        Object writingMode = aci.getAttribute(WRITING_MODE);
        boolean vertical = (writingMode == WRITING_MODE_TTB);

        while (aci.setIndex(chunkStartIndex) != CharacterIterator.DONE) {
            TextPath prevTextPath = null;
            for (int start=chunkStartIndex, end=0;
                 aci.setIndex(start) != CharacterIterator.DONE; start=end) {

                TextPath textPath = (TextPath) aci.getAttribute(TEXTPATH);

                if (start != chunkStartIndex) {
                    // If we aren't the first composite in a chunck see
                    // if we need to form a new TextChunk...
                    // We only create new chunks when given an absolute
                    // location in progression direction [Spec says
                    // to do it for either but this doesn't make sense].
                    if (vertical) {
                        Float runY = (Float) aci.getAttribute(YPOS);
                        // Check for absolute location in layout direction.
                        if ((runY != null) && !runY.isNaN())
                            break; // If so end of chunk...
                    } else {
                        Float runX = (Float) aci.getAttribute(XPOS);
                        // Check for absolute location in layout direction.
                        if ((runX != null) && !runX.isNaN())
                            break; // If so end of chunk...
                    }

                    // Do additional check for the start of a textPath
                    if ((prevTextPath == null) && (textPath != null))
                        break;  // If so end of chunk.

                    // Form a new chunk at the end of a text path.
                    // [ This is not mentioned in the spec but makes
                    //   sense].
                    if ((prevTextPath != null) && (textPath == null))
                        break;
                }

                prevTextPath = textPath;

                // We need to text chunk based on flow paragraphs.
                // This prevents BIDI reordering across paragraphs.
                if (aci.getAttribute(FLOW_PARAGRAPH) != null) {
                    end = aci.getRunLimit(FLOW_PARAGRAPH);
                    // System.out.println("End: " + end);
                    aci.setIndex(end);
                    break;
                }

                // find end of compound.
                end   = aci.getRunLimit(TEXT_COMPOUND_ID);

                if (start != chunkStartIndex)
                    // If we aren't starting a new chunk then we know
                    // we don't have any absolute positioning so there
                    // is no reason to consider spliting the chunk further.
                    continue;

                // We are starting a new chunk
                // So check if we need to split it further...
                TextNode.Anchor anchor;
                anchor = (TextNode.Anchor) aci.getAttribute(ANCHOR_TYPE);
                if (anchor == TextNode.Anchor.START)
                    continue;

                // We need to check if we have a list of X's & Y's if
                // so we need to create TextChunk ACI's for each char
                // (technically we have to do this for
                // text-anchor:start as well but since that is the
                // default layout it doesn't matter in that case.
                if (vertical) {
                    Float runY = (Float) aci.getAttribute(YPOS);
                    // Check for absolute location in layout direction.
                    if ((runY == null) || runY.isNaN())
                        // No absolute positioning in text direction continue
                        continue;
                } else {
                    Float runX = (Float) aci.getAttribute(XPOS);
                    // Check for absolute location in layout direction.
                    if ((runX == null) || runX.isNaN())
                        // No absolute positioning in text direction continue
                        continue;
                }

                // Splitting the compound into one char chunks until
                // we run out of Xs.
                for (int i=start+1; i< end; i++) {
                    aci.setIndex(i);
                    if (vertical) {
                        Float runY = (Float) aci.getAttribute(YPOS);
                        if ((runY == null) || runY.isNaN())
                            break;
                    } else {
                        Float runX = (Float) aci.getAttribute(XPOS);
                        if ((runX == null) || runX.isNaN())
                            break;
                    }
                    aciList.add(new AttributedCharacterSpanIterator
                        (aci, i-1, i));
                    chunkStartIndex = i;
                }
            }

            // found the end of a text chunck
            int chunkEndIndex = aci.getIndex();
            // System.out.println("Bounds: " + chunkStartIndex +
            //                    "," + chunkEndIndex);
            aciList.add(new AttributedCharacterSpanIterator
                (aci, chunkStartIndex, chunkEndIndex));

            chunkStartIndex = chunkEndIndex;
        }

        // copy the text chunks into an array
        AttributedCharacterIterator[] aciArray =
            new AttributedCharacterIterator[aciList.size()];
        Iterator iter = aciList.iterator();
        for (int i=0; iter.hasNext(); ++i) {
            aciArray[i] = (AttributedCharacterIterator)iter.next();
        }
        return aciArray;
    }

    /**
     * Returns a new AttributedCharacterIterator that contains resolved GVTFont
     * attributes. This is then used when creating the text runs so that the
     * text can be split on changes of font as well as tspans and trefs.
     *
     * @param aci The aci to be modified should already be split into
     *            text chunks.
     *
     * @return The new modified aci.
     */
    protected static AttributedCharacterIterator createModifiedACIForFontMatching
        (AttributedCharacterIterator aci) {

        aci.first();
        AttributedString as = null;
        int asOff = 0;
        int begin = aci.getBeginIndex();
        boolean moreChunks = true;
        int start, end   = aci.getRunStart(TEXT_COMPOUND_ID);
        while (moreChunks) {
            start = end;
            end = aci.getRunLimit(TEXT_COMPOUND_ID);
            int aciLength = end-start;

            List fonts;
            fonts = (List)aci.getAttribute(GVT_FONTS);


            float fontSize = 12;
            Float fsFloat = (Float)aci.getAttribute(TextAttribute.SIZE);
            if (fsFloat != null)
                fontSize = fsFloat.floatValue();

            // if could not resolve at least one of the fontFamilies
            // then use the default font
            if (fonts.size() == 0) {
                // create a list of fonts of the correct size
                fonts.add(FontFamilyResolver.defaultFont.deriveFont
                    (fontSize, aci));
            }

            // now for each char or group of chars in the string,
            // find a font that can display it.
            boolean[] fontAssigned = new boolean[aciLength];

            if (as == null)
                as = new AttributedString(aci);

            GVTFont defaultFont = null;
            int numSet=0;
            int firstUnset=start;
            boolean firstUnsetSet;
            for (int i = 0; i < fonts.size(); i++) {
                // assign this font to all characters it can display if it has
                // not already been assigned
                int currentIndex = firstUnset;
                firstUnsetSet = false;
                aci.setIndex(currentIndex);

                GVTFont font = (GVTFont)fonts.get(i);
                if (defaultFont == null)
                    defaultFont = font;

                while (currentIndex < end) {
                    int displayUpToIndex = font.canDisplayUpTo
                        (aci, currentIndex, end);

                    Object altGlyphElement;
                    altGlyphElement = aci.getAttribute(ALT_GLYPH_HANDLER);
                    if ( altGlyphElement != null ){
                        //found all the glyph to be displayed
                        //consider the font matching done
                        displayUpToIndex = -1;
                    }

                    if (displayUpToIndex == -1) {
                        // Can handle the whole thing...
                        displayUpToIndex = end;
                    }

                    if (displayUpToIndex <= currentIndex) {
                        if (!firstUnsetSet) {
                            firstUnset = currentIndex;
                            firstUnsetSet = true;
                        }
                        // couldn't display the current char
                        currentIndex++;
                    } else {
                        // could display some text, so for each
                        // char it can display, if char not already
                        // assigned a font, assign this font to it
                        int runStart = -1;
                        for (int j = currentIndex; j < displayUpToIndex; j++) {
                            if (fontAssigned[j - start]) {
                                if (runStart != -1) {
                                    // System.out.println("Font 1: " + font);
                                    as.addAttribute(GVT_FONT, font,
                                                    runStart-begin, j-begin);
                                    runStart=-1;
                                }
                            } else {
                                if (runStart == -1)
                                    runStart = j;
                            }
                            fontAssigned[j - start] = true;
                            numSet++;
                        }
                        if (runStart != -1) {
                            // System.out.println("Font 2: " + font);
                            as.addAttribute(GVT_FONT, font,
                                            runStart-begin,
                                            displayUpToIndex-begin);
                        }

                        // set currentIndex to be one after the char
                        // that couldn't display
                        currentIndex = displayUpToIndex+1;
                    }
                }

                if (numSet == aciLength) // all chars have font set;
                    break;
            }

            // assign the first font to any chars haven't alreay been assigned
            int           runStart = -1;
            GVTFontFamily prevFF   = null;
            GVTFont       prevF    = defaultFont;
            for (int i = 0; i < aciLength; i++) {
                if (fontAssigned[i]) {
                    if (runStart != -1) {
                        // System.out.println("Font 3: " + prevF);
                        as.addAttribute(GVT_FONT, prevF,
                                        runStart+asOff, i+asOff);
                        runStart = -1;
                        prevF  = null;
                        prevFF = null;
                    }
                } else {
                    char c = aci.setIndex(start+i);
                    GVTFontFamily fontFamily;
                    fontFamily = FontFamilyResolver.getFamilyThatCanDisplay(c);
                    // fontFamily = (GVTFontFamily)resolvedFontFamilies.get(0);

                    if (runStart == -1) {
                        // Starting a new run...
                        runStart = i;
                        prevFF   = fontFamily;
                        if (prevFF == null)
                            prevF = defaultFont;
                        else
                            prevF = fontFamily.deriveFont(fontSize, aci);
                    } else if (prevFF != fontFamily) {
                        // Font family changed...
                        // System.out.println("Font 4: " + prevF);
                        as.addAttribute(GVT_FONT, prevF,
                                        runStart+asOff, i+asOff);

                        runStart = i;
                        prevFF = fontFamily;
                        if (prevFF == null)
                            prevF = defaultFont;
                        else
                            prevF = fontFamily.deriveFont(fontSize, aci);
                    }
                }
            }
            if (runStart != -1) {
                // System.out.println("Font 5: " + prevF);
                as.addAttribute(GVT_FONT, prevF,
                                runStart+asOff, aciLength+asOff);
            }

            asOff += aciLength;
            if (aci.setIndex(end) == AttributedCharacterIterator.DONE) {
                moreChunks = false;
            }
            start = end;
        }
        if (as != null)
            return as.getIterator();

        // Didn't do anything return original ACI
        return aci;
    }


    protected TextChunk getTextChunk(TextNode node,
                                     AttributedCharacterIterator aci,
                                     int [] charMap,
                                     List textRuns,
                                     TextChunk prevChunk) {
        int beginChunk = 0;
        if (prevChunk != null)
            beginChunk = prevChunk.end;
        int endChunk = beginChunk;
        int begin    = aci.getIndex();
        // System.out.println("New Chunk");
        if (aci.current() == CharacterIterator.DONE)
            return null;

        // we now lay all aci's out at 0,0 then move them
        // when we adjust the chunk offsets.
        Point2D.Float offset        = new Point2D.Float(0,0);
        Point2D.Float advance       = new Point2D.Float(0,0);
        boolean isChunkStart  = true;
        TextSpanLayout layout = null;
        do {
            int start = aci.getRunStart(extendedAtts);
            int end   = aci.getRunLimit(extendedAtts);

            AttributedCharacterIterator runaci;
            runaci = new AttributedCharacterSpanIterator(aci, start, end);

            int [] subCharMap = new int[end-start];
            System.arraycopy( charMap, start - begin, subCharMap, 0, subCharMap.length );

            FontRenderContext frc = fontRenderContext;
            RenderingHints rh = node.getRenderingHints();
            // Check for optimizeSpeed, optimizeLegibility
            // in these cases setup hintedFRC
            if ((rh != null) &&
                (rh.get(RenderingHints.KEY_TEXT_ANTIALIASING) ==
                  RenderingHints.VALUE_TEXT_ANTIALIAS_OFF)) {
                // In both these cases we want the non-antialiased
                // font render context.
                frc = aaOffFontRenderContext;
            }

            layout = getTextLayoutFactory().createTextLayout
                (runaci, subCharMap, offset, frc);

            textRuns.add(new TextRun(layout, runaci, isChunkStart));
            // System.out.println("TextRun: " + start +  "->" + end +
            //                    " Start: " + isChunkStart);

            Point2D layoutAdvance = layout.getAdvance2D();
            // System.out.println("layoutAdv: " + layoutAdvance);
            advance.x +=  (float)layoutAdvance.getX();
            advance.y +=  (float)layoutAdvance.getY();

            ++endChunk;
            if (aci.setIndex(end) == CharacterIterator.DONE) break;
            isChunkStart = false;
        } while (true);

        // System.out.println("Adv: " + advance);
        // System.out.println("Chunks: [" + beginChunk + ", " +
        //                    endChunk + "]");
        return new TextChunk(beginChunk, endChunk, advance);
    }



    /**
     * Adjusts the position of the text runs within the specified text chunk
     * to account for any text anchor properties.
     */
    protected Point2D adjustChunkOffsets(Point2D location,
                                         List textRuns,
                                         TextChunk chunk) {
        TextRun r          = (TextRun) textRuns.get(chunk.begin);
        int     anchorType = r.getAnchorType();
        Float   length     = r.getLength();
        Integer lengthAdj  = r.getLengthAdjust();

        boolean doAdjust = true;
        if ((length == null) || length.isNaN())
            doAdjust = false;

        int numChars = 0;
        for (int n=chunk.begin; n<chunk.end; ++n) {
            r = (TextRun) textRuns.get(n);
            AttributedCharacterIterator aci = r.getACI();
            numChars += aci.getEndIndex()-aci.getBeginIndex();
        }
        if ((lengthAdj ==
             GVTAttributedCharacterIterator.TextAttribute.ADJUST_SPACING) &&
            (numChars == 1))
            doAdjust = false;

        float xScale = 1;
        float yScale = 1;

        r = (TextRun)textRuns.get(chunk.end-1);
        TextSpanLayout  layout          = r.getLayout();
        GVTGlyphMetrics lastMetrics =
            layout.getGlyphMetrics(layout.getGlyphCount()-1);
        GVTLineMetrics  lastLineMetrics = layout.getLineMetrics();
        Rectangle2D     lastBounds  = lastMetrics.getBounds2D();
        float halfLeading = (lastMetrics.getVerticalAdvance()-
                               (lastLineMetrics.getAscent() +
                                lastLineMetrics.getDescent()))/2;
        float lastW = (float)(lastBounds.getWidth()  + lastBounds.getX());
        float lastH = (float)(halfLeading + lastLineMetrics.getAscent() +
                              (lastBounds.getHeight() + lastBounds.getY()));
        Point2D visualAdvance;

        if (!doAdjust) {
            // System.err.println("Anchor: " + anchorType);
            // System.err.println("Advance: " + chunk.advance);
            // System.err.println("LastBounds: " + lastBounds);
            // System.err.println("LastMetrics.hadv: " +
            //                    lastMetrics.getHorizontalAdvance());
            // System.err.println("LastMetrics.vadv: " +
            //                    lastMetrics.getVerticalAdvance());

            visualAdvance = new Point2D.Float
            ((float)(chunk.advance.getX() + lastW -
                     lastMetrics.getHorizontalAdvance()),
             (float)(chunk.advance.getY() - lastMetrics.getVerticalAdvance() +
                     lastH));
        } else {
            Point2D advance    = chunk.advance;

            // We have to do this here since textLength needs to be
            // handled at the text chunk level. Otherwise tspans get
            // messed up.
            if (layout.isVertical()) {
                if (lengthAdj == ADJUST_SPACING) {
                    yScale = (float)
                        ((length.floatValue()-lastH)/
                         (advance.getY()-lastMetrics.getVerticalAdvance()));
                } else {
                    double adv =(advance.getY()-
                                 lastMetrics.getVerticalAdvance() + lastH);
                    yScale = (float)(length.floatValue()/adv);
                }
                visualAdvance = new Point2D.Float(0, length.floatValue());
            } else {
                if (lengthAdj == ADJUST_SPACING) {
                    xScale = (float)
                        ((length.floatValue()-lastW)/
                         (advance.getX()-lastMetrics.getHorizontalAdvance()));
                } else {
                    double adv = (advance.getX() + lastW -
                                  lastMetrics.getHorizontalAdvance());
                    xScale = (float)(length.floatValue()/adv);
                }
                visualAdvance = new Point2D.Float(length.floatValue(), 0);
            }

            // System.out.println("Adv: " + advance + " Len: " + length +
            //                    " scale: [" + xScale + ", " + yScale + "]");
            Point2D.Float adv = new Point2D.Float(0,0);
            for (int n=chunk.begin; n<chunk.end; ++n) {
                r = (TextRun) textRuns.get(n);
                layout = r.getLayout();
                layout.setScale(xScale, yScale, lengthAdj==ADJUST_SPACING);
                Point2D lAdv = layout.getAdvance2D();
                adv.x += (float)lAdv.getX();
                adv.y += (float)lAdv.getY();
            }
            chunk.advance = adv;
        }

        float dx = 0f;
        float dy = 0f;
        switch(anchorType){
        case TextNode.Anchor.ANCHOR_MIDDLE:
            dx = (float) (-visualAdvance.getX()/2d);
            dy = (float) (-visualAdvance.getY()/2d);
            break;
        case TextNode.Anchor.ANCHOR_END:
            dx = (float) (-visualAdvance.getX());
            dy = (float) (-visualAdvance.getY());
            break;
        default:
            break;
            // leave untouched
        }

        // System.out.println("DX/DY: [" + dx + ", " + dy + "]");

        r = (TextRun) textRuns.get(chunk.begin);
        layout = r.getLayout();
        AttributedCharacterIterator runaci = r.getACI();
        runaci.first();
        boolean vertical = layout.isVertical();
        Float runX = (Float) runaci.getAttribute(XPOS);
        Float runY = (Float) runaci.getAttribute(YPOS);
        TextPath textPath =  (TextPath) runaci.getAttribute(TEXTPATH);

        // The point that the next peice of normal text should be
        // layed out from, only used for normal text not text on a path.
        float absX = (float)location.getX();
        float absY = (float)location.getY();
        // TextPath Shift used to account for startOffset.
        float tpShiftX = 0;
        float tpShiftY = 0;

        // Of course X and Y override that, but they don't apply for
        // text on a path.
        if ((runX != null) && (!runX.isNaN())) {
            absX = runX.floatValue();
            tpShiftX = absX;
        }

        if ((runY != null) && (!runY.isNaN())) {
            absY = runY.floatValue();
            tpShiftY = absY;
        }

        // Factor in text-anchor in writing direction.
        // Ignore tpShift in non-writing direction.
        if (vertical) {
            absY     += dy;
            tpShiftY += dy;
            tpShiftX  = 0;
        } else {
            absX     += dx;
            tpShiftX += dx;
            tpShiftY  = 0;
        }

        // System.out.println("ABS: [" + absX + "," + absY + "," +
        //                    visualAdvance.getX() + "," +
        //                    visualAdvance.getY() + "]");
        for (int n=chunk.begin; n<chunk.end; ++n) {
            r = (TextRun) textRuns.get(n);
            layout = r.getLayout();
            runaci = r.getACI();
            runaci.first();
            textPath =  (TextPath) runaci.getAttribute(TEXTPATH);
            if (vertical) {
                runX = (Float) runaci.getAttribute(XPOS);
                if ((runX != null) && (!runX.isNaN())) {
                    absX = runX.floatValue();
                }
            } else {
                runY = (Float) runaci.getAttribute(YPOS);
                if ((runY != null) && (!runY.isNaN())) {
                    absY = runY.floatValue();
                }
            }

            if (textPath == null) {
                layout.setOffset(new Point2D.Float(absX, absY));

                Point2D ladv = layout.getAdvance2D();
                absX += ladv.getX();
                absY += ladv.getY();
            } else {
                layout.setOffset(new Point2D.Float(tpShiftX, tpShiftY));

                Point2D ladv = layout.getAdvance2D();
                tpShiftX += (float)ladv.getX();
                tpShiftY += (float)ladv.getY();

                ladv = layout.getTextPathAdvance();
                absX = (float)ladv.getX();
                absY = (float)ladv.getY();
            }
        }
        return new Point2D.Float(absX, absY);
    }

    /**
     * Paints decorations of the specified type.
     */
    protected void paintDecorations(List textRuns,
                                  Graphics2D g2d,
                                  int decorationType) {
        Paint prevPaint = null;
        Paint prevStrokePaint = null;
        Stroke prevStroke = null;
        Rectangle2D decorationRect = null;
        double yLoc = 0, height = 0;

        for (int i = 0; i < textRuns.size(); i++) {
            TextRun textRun = (TextRun)textRuns.get(i);
            AttributedCharacterIterator runaci = textRun.getACI();
            runaci.first();

            TextPaintInfo tpi = (TextPaintInfo)runaci.getAttribute(PAINT_INFO);
            if ((tpi != null) && (tpi.composite != null)) {
                g2d.setComposite(tpi.composite);
            }

            Paint  paint       = null;
            Stroke stroke      = null;
            Paint  strokePaint = null;
            if (tpi != null) {
                switch (decorationType) {
                case TextSpanLayout.DECORATION_UNDERLINE :
                    paint       = tpi.underlinePaint;
                    stroke      = tpi.underlineStroke;
                    strokePaint = tpi.underlineStrokePaint;
                    break;
                case TextSpanLayout.DECORATION_OVERLINE :
                    paint       = tpi.overlinePaint;
                    stroke      = tpi.overlineStroke;
                    strokePaint = tpi.overlineStrokePaint;
                    break;
                case TextSpanLayout.DECORATION_STRIKETHROUGH :
                    paint       = tpi.strikethroughPaint;
                    stroke      = tpi.strikethroughStroke;
                    strokePaint = tpi.strikethroughStrokePaint;
                    break;
                default:
                    // should never get here
                    return;
                }
            }

            if (textRun.isFirstRunInChunk()) {
                Shape s = textRun.getLayout().getDecorationOutline
                    (decorationType);
                Rectangle2D r2d = s.getBounds2D();
                yLoc   = r2d.getY();
                height = r2d.getHeight();
            }

            if (textRun.isFirstRunInChunk() ||
                (paint != prevPaint) ||
                (stroke != prevStroke) ||
                (strokePaint != prevStrokePaint)) {
                // if there is a current decoration, draw it now
                if (decorationRect != null) {

                    if (prevPaint != null) {
                        // fill the decoration
                        g2d.setPaint(prevPaint);
                        g2d.fill(decorationRect);
                    }
                    if (prevStroke != null && prevStrokePaint != null) {
                        // stroke the decoration
                        g2d.setPaint(prevStrokePaint);
                        g2d.setStroke(prevStroke);
                        g2d.draw(decorationRect);
                    }
                    decorationRect = null;
                }
            }

            if ((paint != null || strokePaint != null)
                && !textRun.getLayout().isVertical()
                && !textRun.getLayout().isOnATextPath()) {

                // this text run should be decorated with the
                // specified decoration type
                // NOTE: decorations are only supported for plain
                // horizontal layouts

                Shape decorationShape =
                    textRun.getLayout().getDecorationOutline(decorationType);
                if (decorationRect == null) {
                    // create a new one
                    Rectangle2D r2d = decorationShape.getBounds2D();
                    decorationRect = new Rectangle2D.Double
                        (r2d.getX(), yLoc, r2d.getWidth(), height);
                } else {
                    // extend the current one
                    Rectangle2D bounds = decorationShape.getBounds2D();
                    double minX = Math.min(decorationRect.getX(),
                                           bounds.getX());
                    double maxX = Math.max(decorationRect.getMaxX(),
                                           bounds.getMaxX());
                    decorationRect.setRect(minX, yLoc, maxX-minX, height);
                }
            }
            prevPaint = paint;
            prevStroke = stroke;
            prevStrokePaint = strokePaint;
        }

        // if there is a decoration rect that hasn't been drawn yet, draw it now

        if (decorationRect != null) {

            if (prevPaint != null) {
                // fill the decoration
                g2d.setPaint(prevPaint);
                g2d.fill(decorationRect);
            }
            if (prevStroke != null && prevStrokePaint != null) {
                // stroke the decoration
                g2d.setPaint(prevStrokePaint);
                g2d.setStroke(prevStroke);
                g2d.draw(decorationRect);
            }
        }
    }


    /**
     * Paints the text in each text run. Decorations are not painted here.
     */
    protected void paintTextRuns(List textRuns,
                               Graphics2D g2d) {
        for (int i = 0; i < textRuns.size(); i++) {
            TextRun textRun = (TextRun)textRuns.get(i);
            AttributedCharacterIterator runaci = textRun.getACI();
            runaci.first();

            TextPaintInfo tpi = (TextPaintInfo)runaci.getAttribute(PAINT_INFO);
            if ((tpi != null) && (tpi.composite != null)) {
                g2d.setComposite(tpi.composite);
            }
            textRun.getLayout().draw(g2d);
        }
    }

    /**
     * Get a Shape in userspace coords which defines the textnode glyph outlines.
     * @param node the TextNode to measure
     */
    public Shape getOutline(TextNode node) {

        GeneralPath outline = null;
        AttributedCharacterIterator aci;
        aci = node.getAttributedCharacterIterator();
        if (aci == null)
            return null;

        // get the list of text runs
        List textRuns = getTextRuns(node, aci);

        // for each text run, get its outline and append it to the overall
        // outline

        for (int i = 0; i < textRuns.size(); ++i) {
            TextRun textRun = (TextRun)textRuns.get(i);
            TextSpanLayout textRunLayout = textRun.getLayout();
            GeneralPath textRunOutline =
                new GeneralPath(textRunLayout.getOutline());

            if (outline == null) {
               outline = textRunOutline;
            } else {
                outline.setWindingRule(GeneralPath.WIND_NON_ZERO);
                outline.append(textRunOutline, false);
            }
        }

        // append any decoration outlines
        Shape underline = getDecorationOutline
            (textRuns, TextSpanLayout.DECORATION_UNDERLINE);

        Shape strikeThrough = getDecorationOutline
            (textRuns, TextSpanLayout.DECORATION_STRIKETHROUGH);

        Shape overline = getDecorationOutline
            (textRuns, TextSpanLayout.DECORATION_OVERLINE);

        if (underline != null) {
            if (outline == null) {
                outline = new GeneralPath(underline);
            } else {
                outline.setWindingRule(GeneralPath.WIND_NON_ZERO);
                outline.append(underline, false);
            }
        }
        if (strikeThrough != null) {
            if (outline == null) {
                outline = new GeneralPath(strikeThrough);
            } else {
                outline.setWindingRule(GeneralPath.WIND_NON_ZERO);
                outline.append(strikeThrough, false);
            }
        }
        if (overline != null) {
            if (outline == null) {
                outline = new GeneralPath(overline);
            } else {
                outline.setWindingRule(GeneralPath.WIND_NON_ZERO);
                outline.append(overline, false);
            }
        }

        return outline;
    }


    /**
     * Get a Rectangle2D in userspace coords which encloses the textnode
     * glyphs including stroke etc.
     */
     public Rectangle2D getBounds2D(TextNode node) {
        AttributedCharacterIterator aci;
        aci = node.getAttributedCharacterIterator();
        if (aci == null)
            return null;

        // get the list of text runs
        List textRuns = getTextRuns(node, aci);

        Rectangle2D bounds = null;
        // for each text run, get its stroke outline and append it to
        // the overall outline
        for (int i = 0; i < textRuns.size(); ++i) {
            TextRun textRun = (TextRun)textRuns.get(i);
            TextSpanLayout textRunLayout = textRun.getLayout();
            Rectangle2D runBounds = textRunLayout.getBounds2D();
            if (runBounds != null) {
                if (bounds == null)
                    bounds = runBounds;
                else
                    //bounds = bounds.createUnion(runBounds);
                    bounds.add( runBounds );
            }
        }


        // append any stroked decoration outlines
        Shape underline = getDecorationStrokeOutline
            (textRuns, TextSpanLayout.DECORATION_UNDERLINE);

        if (underline != null) {
            if (bounds == null)
                bounds = underline.getBounds2D();
            else
                //bounds = bounds.createUnion(underline.getBounds2D());
                bounds.add( underline.getBounds2D() );
        }

        Shape strikeThrough = getDecorationStrokeOutline
            (textRuns, TextSpanLayout.DECORATION_STRIKETHROUGH);
        if (strikeThrough != null) {
            if (bounds == null)
                bounds = strikeThrough.getBounds2D();
            else
                //bounds = bounds.createUnion(strikeThrough.getBounds2D());
                bounds.add( strikeThrough.getBounds2D() );
        }

        Shape overline = getDecorationStrokeOutline
            (textRuns, TextSpanLayout.DECORATION_OVERLINE);
        if (overline != null) {
            if (bounds == null)
                bounds = overline.getBounds2D();
            else
                //bounds = bounds.createUnion(overline.getBounds2D());
                bounds.add( overline.getBounds2D() );
        }
        return bounds;
    }


    /**
     * Returns the outline of the specified decoration type.
     *
     * @param textRuns The list of text runs to get the decoration outline for.
     * @param decorationType Indicates the type of decoration required.
     * eg. underline, overline or strikethrough.
     *
     * @return The decoration outline or null if the text is not decorated.
     */
    protected Shape getDecorationOutline(List textRuns, int decorationType) {

        GeneralPath outline = null;

        Paint prevPaint = null;
        Paint prevStrokePaint = null;
        Stroke prevStroke = null;
        Rectangle2D decorationRect = null;
        double yLoc = 0, height = 0;

        for (int i = 0; i < textRuns.size(); i++) {
            TextRun textRun = (TextRun)textRuns.get(i);
            AttributedCharacterIterator runaci = textRun.getACI();
            runaci.first();

            Paint paint = null;
            Stroke stroke = null;
            Paint strokePaint = null;
            TextPaintInfo tpi = (TextPaintInfo)runaci.getAttribute(PAINT_INFO);
            if (tpi != null) {
                switch (decorationType) {
                case TextSpanLayout.DECORATION_UNDERLINE :
                    paint       = tpi.underlinePaint;
                    stroke      = tpi.underlineStroke;
                    strokePaint = tpi.underlineStrokePaint;
                    break;
                case TextSpanLayout.DECORATION_OVERLINE :
                    paint       = tpi.overlinePaint;
                    stroke      = tpi.overlineStroke;
                    strokePaint = tpi.overlineStrokePaint;
                    break;
                case TextSpanLayout.DECORATION_STRIKETHROUGH :
                    paint       = tpi.strikethroughPaint;
                    stroke      = tpi.strikethroughStroke;
                    strokePaint = tpi.strikethroughStrokePaint;
                    break;
                default:
                    // should never get here
                    return null;
                }
            }

            if (textRun.isFirstRunInChunk()) {
                Shape s = textRun.getLayout().getDecorationOutline
                    (decorationType);
                Rectangle2D r2d = s.getBounds2D();
                yLoc   = r2d.getY();
                height = r2d.getHeight();
            }

            if (textRun.isFirstRunInChunk() ||
                paint != prevPaint ||
                stroke != prevStroke ||
                strokePaint != prevStrokePaint) {

                // if there is a current decoration, added it to the overall
                // outline
                if (decorationRect != null) {
                    if (outline == null) {
                        outline = new GeneralPath(decorationRect);
                    } else {
                        outline.append(decorationRect, false);
                    }
                    decorationRect = null;
                }
            }

            if ((paint != null || strokePaint != null)
                && !textRun.getLayout().isVertical()
                && !textRun.getLayout().isOnATextPath()) {

                // this text run should be decorated with the specified
                // decoration type note: decorations are only supported for
                // plain horizontal layouts

                Shape decorationShape =
                    textRun.getLayout().getDecorationOutline(decorationType);
                if (decorationRect == null) {
                    // create a new one
                    Rectangle2D r2d = decorationShape.getBounds2D();
                    decorationRect = new Rectangle2D.Double
                        (r2d.getX(), yLoc, r2d.getWidth(), height);
                } else {
                    // extend the current one
                    Rectangle2D bounds = decorationShape.getBounds2D();
                    double minX = Math.min(decorationRect.getX(),
                                           bounds.getX());
                    double maxX = Math.max(decorationRect.getMaxX(),
                                           bounds.getMaxX());
                    decorationRect.setRect(minX, yLoc, maxX-minX, height);
                }
            }

            prevPaint = paint;
            prevStroke = stroke;
            prevStrokePaint = strokePaint;
        }

        // if there is a decoration rect that hasn't been added to the overall outline
        if (decorationRect != null) {
            if (outline == null) {
                outline = new GeneralPath(decorationRect);
            } else {
                outline.append(decorationRect, false);
            }
        }

        return outline;
    }

    /**
     * Returns the strokeed outline of the specified decoration type.
     * If the decoration has no stroke it will return the fill outline
     *
     * @param textRuns The list of text runs to get the decoration outline for.
     * @param decorationType Indicates the type of decoration required.
     * eg. underline, overline or strikethrough.
     *
     * @return The decoration outline or null if the text is not decorated.
     */
    protected Shape getDecorationStrokeOutline
        (List textRuns, int decorationType) {

        GeneralPath outline = null;

        Paint prevPaint = null;
        Paint prevStrokePaint = null;
        Stroke prevStroke = null;
        Rectangle2D decorationRect = null;
        double yLoc = 0, height = 0;

        for (int i = 0; i < textRuns.size(); i++) {

            TextRun textRun = (TextRun)textRuns.get(i);
            AttributedCharacterIterator runaci = textRun.getACI();
            runaci.first();

            Paint paint = null;
            Stroke stroke = null;
            Paint strokePaint = null;
            TextPaintInfo tpi = (TextPaintInfo)runaci.getAttribute(PAINT_INFO);
            if (tpi != null) {
                switch (decorationType) {
                case TextSpanLayout.DECORATION_UNDERLINE :
                    paint       = tpi.underlinePaint;
                    stroke      = tpi.underlineStroke;
                    strokePaint = tpi.underlineStrokePaint;
                    break;
                case TextSpanLayout.DECORATION_OVERLINE :
                    paint       = tpi.overlinePaint;
                    stroke      = tpi.overlineStroke;
                    strokePaint = tpi.overlineStrokePaint;
                    break;
                case TextSpanLayout.DECORATION_STRIKETHROUGH :
                    paint       = tpi.strikethroughPaint;
                    stroke      = tpi.strikethroughStroke;
                    strokePaint = tpi.strikethroughStrokePaint;
                    break;
                default:
                    // should never get here
                    return null;
                }
            }

            if (textRun.isFirstRunInChunk()) {
                Shape s = textRun.getLayout().getDecorationOutline
                    (decorationType);
                Rectangle2D r2d = s.getBounds2D();
                yLoc   = r2d.getY();
                height = r2d.getHeight();
            }

            if (textRun.isFirstRunInChunk() ||
                paint != prevPaint ||
                stroke != prevStroke ||
                strokePaint != prevStrokePaint) {

                // if there is a current decoration, added it to the overall
                // outline
                if (decorationRect != null) {

                    Shape s = null;
                    if (prevStroke != null &&
                        prevStrokePaint != null)
                        s = prevStroke.createStrokedShape(decorationRect);
                    else if (prevPaint != null)
                        s = decorationRect;
                    if (s != null) {
                        if (outline == null)
                            outline = new GeneralPath(s);
                        else
                            outline.append(s, false);
                    }
                    decorationRect = null;
                }
            }

            if ((paint != null || strokePaint != null)
                && !textRun.getLayout().isVertical()
                && !textRun.getLayout().isOnATextPath()) {

                // this text run should be decorated with the specified
                // decoration type note: decorations are only supported for
                // plain horizontal layouts

                Shape decorationShape =
                    textRun.getLayout().getDecorationOutline(decorationType);

                if (decorationRect == null) {
                    // create a new one
                    Rectangle2D r2d = decorationShape.getBounds2D();
                    decorationRect = new Rectangle2D.Double
                        (r2d.getX(), yLoc, r2d.getWidth(), height);
                } else {
                    // extend the current one
                    Rectangle2D bounds = decorationShape.getBounds2D();
                    double minX = Math.min(decorationRect.getX(),
                                           bounds.getX());
                    double maxX = Math.max(decorationRect.getMaxX(),
                                           bounds.getMaxX());
                    decorationRect.setRect(minX, yLoc, maxX-minX, height);
                }
            }

            prevPaint = paint;
            prevStroke = stroke;
            prevStrokePaint = strokePaint;
        }

        // if there is a decoration rect that hasn't been added to the overall
        // outline
        if (decorationRect != null) {
            Shape s = null;
            if (prevStroke != null &&
                prevStrokePaint != null)
                s = prevStroke.createStrokedShape(decorationRect);
            else if (prevPaint != null)
                s = decorationRect;
            if (s != null) {
                if (outline == null)
                    outline = new GeneralPath(s);
                else
                    outline.append(s, false);
            }
        }

        return outline;
    }


    public Mark getMark(TextNode node, int index, boolean leadingEdge) {
        AttributedCharacterIterator aci;
        aci = node.getAttributedCharacterIterator();
        if (aci == null)
            return null;

        if ((index < aci.getBeginIndex()) ||
            (index > aci.getEndIndex()))
            return null;

        TextHit textHit = new TextHit(index, leadingEdge);
        return new BasicTextPainter.BasicMark(node, textHit);
    }

    protected Mark hitTest(double x, double y, TextNode node) {
        AttributedCharacterIterator aci;
        aci = node.getAttributedCharacterIterator();
        if (aci == null)
            return null;

        // get the list of text runs
        List textRuns = getTextRuns(node, aci);

        // for each text run, see if its been hit
        for (int i = 0; i < textRuns.size(); ++i) {
            TextRun textRun = (TextRun)textRuns.get(i);
            TextSpanLayout layout = textRun.getLayout();
            TextHit textHit = layout.hitTestChar((float) x, (float) y);
            if (textHit != null && layout.getBounds2D().contains(x,y)) {
                return new BasicTextPainter.BasicMark(node, textHit);
            }
        }

        return null;
    }

    /**
     * Selects the first glyph in the text node.
     */
    public Mark selectFirst(TextNode node) {
        AttributedCharacterIterator aci;
        aci = node.getAttributedCharacterIterator();
        if (aci == null)
            return null;

        TextHit textHit = new TextHit(aci.getBeginIndex(), false);
        return new BasicTextPainter.BasicMark(node, textHit);
    }

    /**
     * Selects the last glyph in the text node.
     */
    public Mark selectLast(TextNode node) {
        AttributedCharacterIterator aci;
        aci = node.getAttributedCharacterIterator();
        if (aci == null)
            return null;

        TextHit textHit = new TextHit(aci.getEndIndex()-1, false);
        return  new BasicTextPainter.BasicMark(node, textHit);
    }

    /**
     * Returns an array of ints representing begin/end index pairs into
     * an AttributedCharacterIterator which represents the text
     * selection delineated by two Mark instances.
     * <em>Note: The Mark instances passed must have been instantiated by
     * an instance of this enclosing TextPainter implementation.</em>
     */
    public int[] getSelected(Mark startMark,
                             Mark finishMark) {

        if (startMark == null || finishMark == null) {
            return null;
        }
        BasicTextPainter.BasicMark start;
        BasicTextPainter.BasicMark finish;
        try {
            start = (BasicTextPainter.BasicMark) startMark;
            finish = (BasicTextPainter.BasicMark) finishMark;
        } catch (ClassCastException cce) {
            throw new Error
                ("This Mark was not instantiated by this TextPainter class!");
        }

        TextNode textNode = start.getTextNode();
        if (textNode == null)
            return null;
        if (textNode != finish.getTextNode())
            throw new Error("Markers are from different TextNodes!");

        AttributedCharacterIterator aci;
        aci = textNode.getAttributedCharacterIterator();
        if (aci == null)
            return null;

        int[] result = new int[2];
        result[0] = start.getHit().getCharIndex();
        result[1] = finish.getHit().getCharIndex();

        // get the list of text runs
        List textRuns = getTextRuns(textNode, aci);
        Iterator trI = textRuns.iterator();
        int startGlyphIndex = -1;
        int endGlyphIndex = -1;
        TextSpanLayout startLayout=null, endLayout=null;
        while (trI.hasNext()) {
            TextRun tr = (TextRun)trI.next();
            TextSpanLayout tsl = tr.getLayout();
            if (startGlyphIndex == -1) {
                startGlyphIndex  = tsl.getGlyphIndex(result[0]);
                if (startGlyphIndex != -1)
                    startLayout = tsl;
            }

            if (endGlyphIndex == -1) {
                endGlyphIndex = tsl.getGlyphIndex(result[1]);
                if (endGlyphIndex != -1)
                    endLayout = tsl;
            }
            if ((startGlyphIndex != -1) && (endGlyphIndex != -1))
                break;
        }
        if ((startLayout == null) || (endLayout == null))
            return null;

        int startCharCount = startLayout.getCharacterCount
            (startGlyphIndex, startGlyphIndex);
        int endCharCount = endLayout.getCharacterCount
            (endGlyphIndex, endGlyphIndex);
        if (startCharCount > 1) {
            if (result[0] > result[1] && startLayout.isLeftToRight()) {
                result[0] += startCharCount-1;
            } else if (result[1] > result[0] && !startLayout.isLeftToRight()) {
                result[0] -= startCharCount-1;
            }
        }
        if (endCharCount > 1) {
            if (result[1] > result[0] && endLayout.isLeftToRight()) {
                result[1] += endCharCount-1;
            } else if (result[0] > result[1] && !endLayout.isLeftToRight()) {
                result[1] -= endCharCount-1;
            }
        }

        return result;
    }

   /**
     * Return a Shape, in the coordinate system of the text layout,
     * which encloses the text selection delineated by two Mark instances.
     * <em>Note: The Mark instances passed must have been instantiated by
     * an instance of this enclosing TextPainter implementation.</em>
     */
    public Shape getHighlightShape(Mark beginMark, Mark endMark) {

        if (beginMark == null || endMark == null) {
            return null;
        }

        BasicTextPainter.BasicMark begin;
        BasicTextPainter.BasicMark end;
        try {
            begin = (BasicTextPainter.BasicMark) beginMark;
            end = (BasicTextPainter.BasicMark) endMark;
        } catch (ClassCastException cce) {
            throw new Error
                ("This Mark was not instantiated by this TextPainter class!");
        }

        TextNode textNode = begin.getTextNode();
        if (textNode == null)
            return null;
        if (textNode != end.getTextNode())
            throw new Error("Markers are from different TextNodes!");

        AttributedCharacterIterator aci;
        aci = textNode.getAttributedCharacterIterator();
        if (aci == null)
            return null;

        int beginIndex = begin.getHit().getCharIndex();
        int endIndex   = end.getHit().getCharIndex();
        if (beginIndex > endIndex) {
            // Swap them...
            BasicTextPainter.BasicMark tmpMark = begin;
            begin = end; end = tmpMark;

            int tmpIndex = beginIndex;
            beginIndex = endIndex; endIndex = tmpIndex;
        }

        // get the list of text runs
        List textRuns = getTextRuns(textNode, aci);

        GeneralPath highlightedShape = new GeneralPath();

        // for each text run, append any highlight it may contain for
        // the current selection
        for (int i = 0; i < textRuns.size(); ++i) {
            TextRun textRun = (TextRun)textRuns.get(i);
            TextSpanLayout layout = textRun.getLayout();

            Shape layoutHighlightedShape = layout.getHighlightShape
                (beginIndex, endIndex);

            // append the highlighted shape of this layout to the
            // overall hightlighted shape
            if (( layoutHighlightedShape != null) &&
                (!layoutHighlightedShape.getBounds().isEmpty())) {
                highlightedShape.append(layoutHighlightedShape, false);
            }
        }
        return highlightedShape;
    }

// inner classes

    class TextChunk {

        public int begin;
        public int end;
        public Point2D advance;

        public TextChunk(int begin, int end, Point2D advance) {
            this.begin = begin;
            this.end = end;
            this.advance = new Point2D.Float((float) advance.getX(),
                                             (float) advance.getY());
        }
    }


    /**
     * Inner convenience class for associating a TextLayout for
     * sub-spans, and the ACI which iterates over that subspan.
     */
    public class TextRun {

        protected AttributedCharacterIterator aci;
        protected TextSpanLayout layout;
        protected int anchorType;
        protected boolean firstRunInChunk;
        protected Float length;
        protected Integer lengthAdjust;

        public TextRun(TextSpanLayout layout,
                       AttributedCharacterIterator aci,
                       boolean firstRunInChunk) {

            this.layout = layout;
            this.aci = aci;
            this.aci.first();
            this.firstRunInChunk = firstRunInChunk;
            this.anchorType = TextNode.Anchor.ANCHOR_START;

            TextNode.Anchor anchor = (TextNode.Anchor) aci.getAttribute
                (GVTAttributedCharacterIterator.TextAttribute.ANCHOR_TYPE);
            if (anchor != null) {
                this.anchorType = anchor.getType();
            }

            // if writing mode is right to left, then need to reverse the
            // text anchor positions
            if (aci.getAttribute(WRITING_MODE) == WRITING_MODE_RTL) {
                if (anchorType == TextNode.Anchor.ANCHOR_START) {
                    anchorType = TextNode.Anchor.ANCHOR_END;
                } else if (anchorType == TextNode.Anchor.ANCHOR_END) {
                    anchorType = TextNode.Anchor.ANCHOR_START;
                }
                // leave middle as is
            }

            length = (Float) aci.getAttribute
                (GVTAttributedCharacterIterator.TextAttribute.BBOX_WIDTH);
            lengthAdjust = (Integer) aci.getAttribute
                (GVTAttributedCharacterIterator.TextAttribute.LENGTH_ADJUST);
        }

        public AttributedCharacterIterator getACI() {
            return aci;
        }

        public TextSpanLayout getLayout() {
            return layout;
        }

        public int getAnchorType() {
            return anchorType;
        }

        public Float getLength() {
            return length;
        }

        public Integer getLengthAdjust() {
            return lengthAdjust;
        }

        public boolean isFirstRunInChunk() {
            return firstRunInChunk;
        }

    }
}
