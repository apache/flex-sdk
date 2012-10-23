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
package org.apache.flex.forks.batik.gvt.font;

import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.font.FontRenderContext;
import java.awt.font.GlyphJustificationInfo;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;

import org.apache.flex.forks.batik.gvt.text.ArabicTextHandler;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.TextPaintInfo;

/**
 * A GVTGlyphVector class for SVG fonts.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: SVGGVTGlyphVector.java 594379 2007-11-13 01:08:28Z cam $
 */
public final class SVGGVTGlyphVector implements GVTGlyphVector {

    public static final AttributedCharacterIterator.Attribute PAINT_INFO
        = GVTAttributedCharacterIterator.TextAttribute.PAINT_INFO;

    private GVTFont           font;
    private Glyph[]           glyphs;
    private FontRenderContext frc;
    private GeneralPath       outline;
    private Rectangle2D       logicalBounds;
    private Rectangle2D       bounds2D;
    private Shape[]           glyphLogicalBounds;
    private boolean[]         glyphVisible;
    private Point2D           endPos;
    private TextPaintInfo     cacheTPI;

    /**
     * Constructs an SVGGVTGlyphVector.
     *
     * @param font The font that is creating this glyph vector.
     * @param glyphs An array containing the glyphs that form the basis for this
     * glyph vector.
     * @param frc The current font render context.
     */
    public SVGGVTGlyphVector(GVTFont font, Glyph[] glyphs,
                             FontRenderContext frc) {
        this.font = font;
        this.glyphs = glyphs;
        this.frc = frc;
        outline = null;
        bounds2D = null;
        logicalBounds = null;
        glyphLogicalBounds = new Shape[glyphs.length];
        glyphVisible = new boolean[glyphs.length];
        for (int i = 0; i < glyphs.length; i++) {
            glyphVisible[i] = true;
        }

        endPos = glyphs[glyphs.length-1].getPosition();
        endPos = new Point2D.Float
            ((float)(endPos.getX()+glyphs[glyphs.length-1].getHorizAdvX()),
             (float)endPos.getY());
    }

    /**
     * Returns the Font associated with this GlyphVector.
     */
    public GVTFont getFont() {
        return font;
    }

    /**
     * Returns the FontRenderContext associated with this GlyphVector.
     */
    public FontRenderContext getFontRenderContext() {
        return frc;
    }

    /**
     * Returns the glyphcode of the specified glyph.
     */
    public int getGlyphCode(int glyphIndex) throws IndexOutOfBoundsException {
        if (glyphIndex < 0 || glyphIndex > (glyphs.length-1)) {
            throw new IndexOutOfBoundsException("glyphIndex " + glyphIndex
                      + " is out of bounds, should be between 0 and "
                      + (glyphs.length-1));
        }
        return glyphs[glyphIndex].getGlyphCode();
    }

    /**
     * Returns an array of glyphcodes for the specified glyphs.
     */
    public int[] getGlyphCodes(int beginGlyphIndex, int numEntries,
                               int[] codeReturn)
                               throws IndexOutOfBoundsException,
                                       IllegalArgumentException {
        if (numEntries < 0) {
            throw new IllegalArgumentException("numEntries argument value, "
                      + numEntries + ", is illegal. It must be > 0.");
        }
        if (beginGlyphIndex < 0) {
            throw new IndexOutOfBoundsException("beginGlyphIndex " + beginGlyphIndex
                      + " is out of bounds, should be between 0 and "
                      + (glyphs.length-1));
        }
        if ((beginGlyphIndex+numEntries) > glyphs.length) {
             throw new IndexOutOfBoundsException("beginGlyphIndex + numEntries ("
                       + beginGlyphIndex + "+" + numEntries
                       + ") exceeds the number of glpyhs in this GlyphVector");
        }
        if (codeReturn == null) {
            codeReturn = new int[numEntries];
        }
        for (int i = beginGlyphIndex; i < (beginGlyphIndex+numEntries); i++) {
            codeReturn[i-beginGlyphIndex] = glyphs[i].getGlyphCode();
        }
        return codeReturn;
    }

    /**
     * Returns the justification information for the glyph at the specified
     * index into this GlyphVector.
     */
    public GlyphJustificationInfo getGlyphJustificationInfo(int glyphIndex) {
        if (glyphIndex < 0 || (glyphIndex > glyphs.length-1)) {
            throw new IndexOutOfBoundsException("glyphIndex: " + glyphIndex
            + ", is out of bounds. Should be between 0 and " + (glyphs.length-1) + ".");
        }
        return null;
    }

     /**
     *  Returns the logical bounds of the specified glyph within this
     *  GlyphVector.
     */
    public Shape getGlyphLogicalBounds(int glyphIndex) {
        if (glyphLogicalBounds[glyphIndex] == null && glyphVisible[glyphIndex]) {
            computeGlyphLogicalBounds();
        }
        return glyphLogicalBounds[glyphIndex];
    }


    private void computeGlyphLogicalBounds() {

        float ascent = 0;
        float descent = 0;
        if (font != null) {
            // font will only be null if this glyph vector is for an altGlyph
            GVTLineMetrics lineMetrics = font.getLineMetrics("By", frc);
            ascent = lineMetrics.getAscent();
            descent = lineMetrics.getDescent();
            if (descent < 0) {
                // make descent a positive value
                descent = -descent;
            }
        }

        if (ascent == 0) {
            float maxAscent  = 0;
            float maxDescent = 0;
            for (int i = 0; i < getNumGlyphs(); i++) {
                if (!glyphVisible[i]) continue;
                GVTGlyphMetrics glyphMetrics = getGlyphMetrics(i);
                Rectangle2D     glyphBounds  = glyphMetrics.getBounds2D();
                ascent = (float)(-glyphBounds.getMinY());
                descent = (float)(glyphBounds.getHeight()-ascent);
                if (ascent > maxAscent)   maxAscent = ascent;
                if (descent > maxDescent) maxDescent = descent;
            }
            ascent  = maxAscent;
            descent = maxDescent;
        }

        Shape[] tempLogicalBounds = new Shape[getNumGlyphs()];
        boolean[] rotated = new boolean[getNumGlyphs()];

        double maxWidth = -1;
        double maxHeight = -1;

        for (int i = 0; i < getNumGlyphs(); i++) {

            if (!glyphVisible[i]) {
                // the glyph is not drawn
                tempLogicalBounds[i] = null;
                continue;
            }

            AffineTransform glyphTransform = getGlyphTransform(i);
            GVTGlyphMetrics glyphMetrics   = getGlyphMetrics(i);
            Rectangle2D glyphBounds = new Rectangle2D.Double
                (0, -ascent, glyphMetrics.getHorizontalAdvance(),
                 ascent+descent);

            if (glyphBounds.isEmpty()) {
                // can't tell if rotated or not, make it
                // the same as the previous glyph, if we have one...
                if (i > 0) {
                    rotated[i] = rotated[i-1];
                } else {
                    rotated [i] = true;
                }
            } else {
                // get three corner points so we can determine
                // whether the glyph is rotated
                Point2D p1 = new Point2D.Double(glyphBounds.getMinX(),
                                                glyphBounds.getMinY());
                Point2D p2 = new Point2D.Double(glyphBounds.getMaxX(),
                                                glyphBounds.getMinY());
                Point2D p3 = new Point2D.Double(glyphBounds.getMinX(),
                                                glyphBounds.getMaxY());
                Point2D gpos = getGlyphPosition(i);
                AffineTransform tr = AffineTransform.getTranslateInstance
                    (gpos.getX(), gpos.getY());

                if (glyphTransform != null)
                    tr.concatenate(glyphTransform);

                tempLogicalBounds[i] =
                    tr.createTransformedShape(glyphBounds);

                Point2D tp1 = new Point2D.Double();
                Point2D tp2 = new Point2D.Double();
                Point2D tp3 = new Point2D.Double();
                tr.transform(p1, tp1);
                tr.transform(p2, tp2);
                tr.transform(p3, tp3);
                double tdx12 = tp1.getX()-tp2.getX();
                double tdx13 = tp1.getX()-tp3.getX();
                double tdy12 = tp1.getY()-tp2.getY();
                double tdy13 = tp1.getY()-tp3.getY();

                if ((Math.abs(tdx12) < 0.001) &&
                    (Math.abs(tdy13) < 0.001)) {
                    // If these are both zero then it is axially aligned
                    // on it's "side"...
                    rotated[i] = false;
                } else if ((Math.abs(tdx13) < 0.001) &&
                           (Math.abs(tdy12) < 0.001)) {
                    // If these are both zero then it is axially aligned
                    // vertically.
                    rotated[i] = false;
                } else {
                    rotated[i] = true;
                }

                Rectangle2D rectBounds;
                rectBounds = tempLogicalBounds[i].getBounds2D();
                if (rectBounds.getWidth() > maxWidth)
                    maxWidth = rectBounds.getWidth();
                if (rectBounds.getHeight() > maxHeight)
                    maxHeight = rectBounds.getHeight();
            }
        }

        // if appropriate, join adjacent glyph logical bounds
        GeneralPath logicalBoundsPath = new GeneralPath();
        for (int i = 0; i < getNumGlyphs(); i++) {
            if (tempLogicalBounds[i] != null) {
                logicalBoundsPath.append(tempLogicalBounds[i], false);
            }
        }
        Rectangle2D fullBounds = logicalBoundsPath.getBounds2D();

        if (fullBounds.getHeight() < maxHeight*1.5) {
            // make all glyphs tops and bottoms the same as the full bounds
            for (int i = 0; i < getNumGlyphs(); i++) {
                // first make sure that the glyph logical bounds are
                // not rotated
                if (rotated[i]) continue;
                if (tempLogicalBounds[i] == null) continue;

                Rectangle2D glyphBounds = tempLogicalBounds[i].getBounds2D();

                double x = glyphBounds.getMinX();
                double width = glyphBounds.getWidth();

                if ((i < getNumGlyphs()-1) &&
                    (tempLogicalBounds[i+1] != null)) {
                    // make this glyph extend to the start of the next one
                    Rectangle2D ngb = tempLogicalBounds[i+1].getBounds2D();

                    if (ngb.getX() > x) {
                        double nw = ngb.getX() - x;
                        if ((nw < width*1.15) && (nw > width*.85)) {
                            double delta = (nw-width)*.5;
                            width += delta;
                            ngb.setRect(ngb.getX()-delta, ngb.getY(),
                                        ngb.getWidth()+delta, ngb.getHeight());
                        }
                    }
                }
                tempLogicalBounds[i] = new Rectangle2D.Double
                    (x,     fullBounds.getMinY(),
                     width, fullBounds.getHeight());
            }
        } else if (fullBounds.getWidth() < maxWidth*1.5) {
            // make all glyphs left and right edges the same as the full bounds
            for (int i = 0; i < getNumGlyphs(); i++) {
                // first make sure that the glyph logical bounds are
                // not rotated
                if (rotated[i]) continue;
                if (tempLogicalBounds[i] == null) continue;

                Rectangle2D glyphBounds = tempLogicalBounds[i].getBounds2D();
                double      y           = glyphBounds.getMinY();
                double      height      = glyphBounds.getHeight();

                if ((i < getNumGlyphs()-1) &&
                    (tempLogicalBounds[i+1] != null)) {
                    // make this glyph extend to the start of the next one
                    Rectangle2D ngb = tempLogicalBounds[i+1].getBounds2D();
                    if (ngb.getY() > y) { // going top to bottom
                        double nh = ngb.getY() - y;
                        if ((nh < height*1.15) && (nh > height*.85)) {
                            double delta = (nh-height)*.5;
                            height += delta;
                            ngb.setRect(ngb.getX(), ngb.getY()-delta,
                                        ngb.getWidth(), ngb.getHeight()+delta);
                        }
                    }
                }
                tempLogicalBounds[i] = new Rectangle2D.Double
                    (fullBounds.getMinX(),  y,
                     fullBounds.getWidth(), height);
            }
        }

        System.arraycopy( tempLogicalBounds, 0, glyphLogicalBounds, 0, getNumGlyphs() );
    }

    /**
     * Returns the metrics of the glyph at the specified index into this
     * GlyphVector.
     */
    public GVTGlyphMetrics getGlyphMetrics(int idx) {

        if (idx < 0 || (idx > glyphs.length-1))
            throw new IndexOutOfBoundsException
                ("idx: " + idx + ", is out of bounds. Should be between 0 and "
                 + (glyphs.length-1) + '.' );

        // check to see if we should kern this glyph
        // I return the kerning information in the glyph metrics
        // as a first pass at implementation (I don't want to
        // fiddle with layout too much right now).
        if (idx < glyphs.length - 1) {
            // check for kerning
            if (font != null) {
                float hkern = font.getHKern(glyphs[idx].getGlyphCode(),
                                            glyphs[idx+1].getGlyphCode());
                float vkern = font.getVKern(glyphs[idx].getGlyphCode(),
                                            glyphs[idx+1].getGlyphCode());
                return glyphs[idx].getGlyphMetrics(hkern, vkern);
            }
        }

        // get a normal metrics
        return glyphs[idx].getGlyphMetrics();
    }

    /**
     * Returns a Shape whose interior corresponds to the visual representation
     * of the specified glyph within this GlyphVector.
     */
    public Shape getGlyphOutline(int glyphIndex) {
        if (glyphIndex < 0 || (glyphIndex > glyphs.length-1)) {
            throw new IndexOutOfBoundsException("glyphIndex: " + glyphIndex
            + ", is out of bounds. Should be between 0 and " + (glyphs.length-1) + ".");
        }
        return glyphs[glyphIndex].getOutline();
    }

    /**
     * Returns the bounding box of the specified glyph, considering only the
     * glyph's metrics (ascent, descent, advance) rather than the actual glyph
     * shape.
     */
    public Rectangle2D getGlyphCellBounds(int glyphIndex) {
        return getGlyphLogicalBounds(glyphIndex).getBounds2D();
    }

    /**
     * Returns the position of the specified glyph within this GlyphVector.
     */
    public Point2D getGlyphPosition(int glyphIndex) {
        if (glyphIndex == glyphs.length)
            return endPos;

        if (glyphIndex < 0 || (glyphIndex > glyphs.length-1)) {
            throw new IndexOutOfBoundsException("glyphIndex: " + glyphIndex
            + ", is out of bounds. Should be between 0 and " + (glyphs.length-1) + '.' );
        }
        return glyphs[glyphIndex].getPosition();
    }


    /**
     * Returns an array of glyph positions for the specified glyphs
     */
    public float[] getGlyphPositions(int beginGlyphIndex, int numEntries,
                                     float[] positionReturn) {
         if (numEntries < 0) {
            throw new IllegalArgumentException("numEntries argument value, "
                      + numEntries + ", is illegal. It must be > 0.");
        }
        if (beginGlyphIndex < 0) {
            throw new IndexOutOfBoundsException("beginGlyphIndex " + beginGlyphIndex
                      + " is out of bounds, should be between 0 and "
                      + (glyphs.length-1));
        }
        if ((beginGlyphIndex+numEntries) > glyphs.length+1) {
             throw new IndexOutOfBoundsException("beginGlyphIndex + numEntries ("
                       + beginGlyphIndex + '+' + numEntries
                       + ") exceeds the number of glpyhs in this GlyphVector");
        }
        if (positionReturn == null) {
            positionReturn = new float[numEntries*2];
        }
        if ((beginGlyphIndex+numEntries) == glyphs.length+1) {
            numEntries--;
            positionReturn[numEntries*2]   = (float)endPos.getX();
            positionReturn[numEntries*2+1] = (float)endPos.getY();
        }
        for (int i = beginGlyphIndex; i < (beginGlyphIndex+numEntries); i++) {
            Point2D glyphPos;
            glyphPos = glyphs[i].getPosition();
            positionReturn[(i-beginGlyphIndex)*2]     = (float)glyphPos.getX();
            positionReturn[(i-beginGlyphIndex)*2 + 1] = (float)glyphPos.getY();
        }
        return positionReturn;
    }

    /**
     * Gets the transform of the specified glyph within this GlyphVector.
     */
    public AffineTransform getGlyphTransform(int glyphIndex) {
        if (glyphIndex < 0 || (glyphIndex > glyphs.length-1)) {
            throw new IndexOutOfBoundsException("glyphIndex: " + glyphIndex
            + ", is out of bounds. Should be between 0 and " + (glyphs.length-1) + '.' );
        }
        return glyphs[glyphIndex].getTransform();
    }

    /**
     * Returns the visual bounds of the specified glyph within the GlyphVector.
     */
    public Shape getGlyphVisualBounds(int glyphIndex) {
        if (glyphIndex < 0 || (glyphIndex > glyphs.length-1)) {
            throw new IndexOutOfBoundsException("glyphIndex: " + glyphIndex
            + ", is out of bounds. Should be between 0 and " + (glyphs.length-1) + '.' );
        }
        return glyphs[glyphIndex].getOutline();
    }

    /**
     * Returns a tight bounds on the GylphVector including stroking.
     */
    public Rectangle2D getBounds2D(AttributedCharacterIterator aci) {
        // System.out.println("GlyphVector.getBounds2D Called: " + this);
        aci.first();
        TextPaintInfo tpi = (TextPaintInfo)aci.getAttribute(PAINT_INFO);
        if ((bounds2D != null) &&
            TextPaintInfo.equivilent(tpi, cacheTPI))
            return bounds2D;

        Rectangle2D b=null;
        if (tpi.visible) {
            for (int i = 0; i < getNumGlyphs(); i++) {
                if (!glyphVisible[i])  continue;

                Rectangle2D glyphBounds = glyphs[i].getBounds2D();
                // System.out.println("GB["+i+"]: " + glyphBounds);
                if (glyphBounds == null) continue;
                if (b == null) b=glyphBounds;
                //else b = glyphBounds.createUnion(b);
                else b.add( glyphBounds );
            }
        }

        bounds2D = b;
        if ( bounds2D == null ){
            bounds2D = new Rectangle2D.Float();
        }
        cacheTPI = new TextPaintInfo(tpi);
        return bounds2D;
    }

    /**
     *  Returns the logical bounds of this GlyphVector.
     * This is a bound useful for hit detection and highlighting.
     */
    public Rectangle2D getLogicalBounds() {
        if (logicalBounds == null) {
            GeneralPath logicalBoundsPath = new GeneralPath();
            for (int i = 0; i < getNumGlyphs(); i++) {
                Shape glyphLogicalBounds = getGlyphLogicalBounds(i);
                if (glyphLogicalBounds != null) {
                    logicalBoundsPath.append(glyphLogicalBounds, false);
                }
            }
            logicalBounds = logicalBoundsPath.getBounds2D();
        }
        return logicalBounds;
    }

    /**
     * Returns the number of glyphs in this GlyphVector.
     */
    public int getNumGlyphs() {
        if (glyphs != null) {
            return glyphs.length;
        }
        return 0;
    }

    /**
     * Returns a Shape whose interior corresponds to the visual representation
     * of this GlyphVector.
     */
    public Shape getOutline() {
        if (outline == null) {
            outline = new GeneralPath();
            for (int i = 0; i < glyphs.length; i++) {
                if (glyphVisible[i]) {
                    Shape glyphOutline = glyphs[i].getOutline();
                    if (glyphOutline != null) {
                        outline.append(glyphOutline, false);
                    }
                }
            }
        }
        return outline;
    }

    /**
     * Returns a Shape whose interior corresponds to the visual representation
     * of this GlyphVector, offset to x, y.
     */
    public Shape getOutline(float x, float y) {
        Shape outline = getOutline();
        AffineTransform tr = AffineTransform.getTranslateInstance(x,y);
        Shape translatedOutline = tr.createTransformedShape(outline);
        return translatedOutline;
    }

    /**
     * Returns the geometric bounds of this GlyphVector. The geometric
     * bounds is the tightest rectangle enclosing the geometry of the
     * glyph vector (not including stroke).
     */
    public Rectangle2D getGeometricBounds() {
        return getOutline().getBounds2D();
    }

    /**
     * Assigns default positions to each glyph in this GlyphVector. The default
     * layout is horizontal.
     */
    public void performDefaultLayout() {
        logicalBounds = null;
        outline       = null;
        bounds2D      = null;

        float currentX = 0;
        float currentY = 0;
        for (int i = 0; i < glyphs.length; i++) {
            Glyph g = glyphs[i];
            g.setTransform(null);
            glyphLogicalBounds[i] = null;

            String uni = g.getUnicode();
            if ((uni != null)  && (uni.length() != 0) &&
                ArabicTextHandler.arabicCharTransparent(uni.charAt(0))) {
                int j;
                for (j=i+1; j<glyphs.length; j++) {
                    uni = glyphs[j].getUnicode();
                    if ((uni == null)  || (uni.length() == 0)) break;
                    char ch = uni.charAt(0);
                    if (!ArabicTextHandler.arabicCharTransparent(ch))
                        break;
                }
                if (j != glyphs.length) {
                    Glyph bg = glyphs[j];
                    float rEdge = currentX + bg.getHorizAdvX();
                    for (int k=i; k<j; k++) {
                        g = glyphs[k];
                        g.setTransform(null);
                        glyphLogicalBounds[i] = null;
                        g.setPosition(new Point2D.Float(rEdge-g.getHorizAdvX(),
                                                        currentY));
                    }
                    i = j;
                    g = bg;
                }
            }

            g.setPosition(new Point2D.Float(currentX, currentY));
            currentX += g.getHorizAdvX();
        }
        endPos = new Point2D.Float(currentX, currentY);
    }

    /**
     * Sets the position of the specified glyph within this GlyphVector.
     */
    public void setGlyphPosition(int glyphIndex, Point2D newPos)
                                 throws IndexOutOfBoundsException {
        if (glyphIndex == glyphs.length) {
            endPos = (Point2D)newPos.clone();
            return;
        }

        if (glyphIndex < 0 || (glyphIndex > glyphs.length-1)) {
            throw new IndexOutOfBoundsException("glyphIndex: " + glyphIndex
            + ", is out of bounds. Should be between 0 and " + (glyphs.length-1) + '.' );
        }
        glyphs[glyphIndex].setPosition(newPos);
        glyphLogicalBounds[glyphIndex] = null;
        outline = null;
        bounds2D = null;
        logicalBounds = null;
    }

    /**
     * Sets the transform of the specified glyph within this GlyphVector.
     */
    public void setGlyphTransform(int glyphIndex, AffineTransform newTX) {
        if (glyphIndex < 0 || (glyphIndex > glyphs.length-1)) {
            throw new IndexOutOfBoundsException("glyphIndex: " + glyphIndex
            + ", is out of bounds. Should be between 0 and " + (glyphs.length-1) + '.' );
        }
        glyphs[glyphIndex].setTransform(newTX);
        glyphLogicalBounds[glyphIndex] = null;
        outline = null;
        bounds2D = null;
        logicalBounds = null;
    }

    /**
     * Tells the glyph vector whether or not to draw the specified glyph.
     */
    public void setGlyphVisible(int glyphIndex, boolean visible) {
        if (visible == glyphVisible[glyphIndex])
            return;

        glyphVisible[glyphIndex] = visible;
        outline = null;
        bounds2D = null;
        logicalBounds = null;
        glyphLogicalBounds[glyphIndex] = null;
    }

    /**
     * Returns true if specified glyph will be rendered.
     */
    public boolean isGlyphVisible(int glyphIndex) {
        return glyphVisible[glyphIndex];
    }

    /**
     * Returns the number of chars represented by the glyphs within the
     * specified range.
     * @param startGlyphIndex The index of the first glyph in the range.
     * @param endGlyphIndex The index of the last glyph in the range.
     * @return The number of chars.
     */
    public int getCharacterCount(int startGlyphIndex, int endGlyphIndex) {
        int numChars = 0;
        if (startGlyphIndex < 0) {
            startGlyphIndex = 0;
        }
        if (endGlyphIndex > glyphs.length-1) {
            endGlyphIndex = glyphs.length-1;
        }
        for (int i = startGlyphIndex; i <= endGlyphIndex; i++) {
            Glyph glyph = glyphs[i];
            if (glyph.getGlyphCode() == -1) {
                // Missing glyph mapps to just one char...
                numChars++;
            } else {
                String glyphUnicode = glyph.getUnicode();
                numChars += glyphUnicode.length();
            }
        }
        return numChars;
    }

    /**
     * Draws this glyph vector.
     */
    public void draw(Graphics2D graphics2D,
                     AttributedCharacterIterator aci) {
        aci.first();
        TextPaintInfo tpi = (TextPaintInfo)aci.getAttribute(PAINT_INFO);
        if (!tpi.visible) return;

        for (int i = 0; i < glyphs.length; i++) {
            if (glyphVisible[i]) {
                glyphs[i].draw(graphics2D);
            }
        }
    }
}

