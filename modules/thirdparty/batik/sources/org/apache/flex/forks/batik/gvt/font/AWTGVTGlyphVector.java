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

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.Stroke;
import java.awt.font.FontRenderContext;
import java.awt.font.GlyphJustificationInfo;
import java.awt.font.GlyphMetrics;
import java.awt.font.GlyphVector;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;
import java.text.CharacterIterator;

import org.apache.flex.forks.batik.gvt.text.ArabicTextHandler;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.TextPaintInfo;

/**
 * This is a wrapper class for a java.awt.font.GlyphVector instance.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: AWTGVTGlyphVector.java 479559 2006-11-27 09:46:16Z dvholten $
 */
public class AWTGVTGlyphVector implements GVTGlyphVector {

    public static final AttributedCharacterIterator.Attribute PAINT_INFO
        = GVTAttributedCharacterIterator.TextAttribute.PAINT_INFO;

    private GlyphVector awtGlyphVector;
    private AWTGVTFont gvtFont;
    private CharacterIterator ci;

    // This contains the glyphPostions after doing a performDefaultLayout
    private Point2D      [] defaultGlyphPositions;
    private Point2D.Float[] glyphPositions;

    // need to keep track of the glyphTransforms since GlyphVector doesn't
    // seem to
    private AffineTransform[] glyphTransforms;

    // these are for caching the glyph outlines
    private Shape[] glyphOutlines;
    private Shape[] glyphVisualBounds;
    private Shape[] glyphLogicalBounds;
    private boolean[] glyphVisible;
    private GVTGlyphMetrics [] glyphMetrics;
    private GeneralPath outline;
    private Rectangle2D visualBounds;
    private Rectangle2D logicalBounds;
    private Rectangle2D bounds2D;
    private float scaleFactor;
    private float ascent;
    private float descent;
    private TextPaintInfo cacheTPI;

    /**
     * Creates and new AWTGVTGlyphVector from the specified GlyphVector and
     * AWTGVTFont objects.
     *
     * @param glyphVector The glyph vector that this one will be based upon.
     * @param font The font that is creating this glyph vector.
     * @param scaleFactor The scale factor to apply to the glyph vector.
     * IMPORTANT: This is only required because the GlyphVector class doesn't
     * handle font sizes less than 1 correctly. By using the scale factor we
     * can use a GlyphVector created by a larger font and then scale it down to
     * the correct size.
     * @param ci The character string that this glyph vector represents.
     */
    public AWTGVTGlyphVector(GlyphVector glyphVector,
                             AWTGVTFont font,
                             float scaleFactor,
                             CharacterIterator ci) {

        this.awtGlyphVector = glyphVector;
        this.gvtFont = font;
        this.scaleFactor = scaleFactor;
        this.ci = ci;

        GVTLineMetrics lineMetrics = gvtFont.getLineMetrics
            ("By", awtGlyphVector.getFontRenderContext());

        ascent  = lineMetrics.getAscent();
        descent = lineMetrics.getDescent();

        outline       = null;
        visualBounds  = null;
        logicalBounds = null;
        bounds2D      = null;
        int numGlyphs = glyphVector.getNumGlyphs();
        glyphPositions     = new Point2D.Float  [numGlyphs+1];
        glyphTransforms    = new AffineTransform[numGlyphs];
        glyphOutlines      = new Shape          [numGlyphs];
        glyphVisualBounds  = new Shape          [numGlyphs];
        glyphLogicalBounds = new Shape          [numGlyphs];
        glyphVisible       = new boolean        [numGlyphs];
        glyphMetrics       = new GVTGlyphMetrics[numGlyphs];

        for (int i = 0; i < numGlyphs; i++) {
            glyphVisible[i] = true;
        }
    }

    /**
     * Returns the GVTFont associated with this GVTGlyphVector.
     */
    public GVTFont getFont() {
        return gvtFont;
    }

    /**
     * Returns the FontRenderContext associated with this GlyphVector.
     */
    public FontRenderContext getFontRenderContext() {
        return awtGlyphVector.getFontRenderContext();
    }

    /**
     * Returns the glyphcode of the specified glyph.
     */
    public int getGlyphCode(int glyphIndex) {
        return awtGlyphVector.getGlyphCode(glyphIndex);
    }

    /**
     * Returns an array of glyphcodes for the specified glyphs.
     */
    public int[] getGlyphCodes(int beginGlyphIndex, int numEntries,
                               int[] codeReturn) {
        return awtGlyphVector.getGlyphCodes(beginGlyphIndex, numEntries,
                                            codeReturn);
    }

    /**
     * Returns the justification information for the glyph at the specified
     * index into this GlyphVector.
     */
    public GlyphJustificationInfo getGlyphJustificationInfo(int glyphIndex) {
        return awtGlyphVector.getGlyphJustificationInfo(glyphIndex);
    }

    /**
     * Returns a tight bounds on the GylphVector including stroking.
     */
    public Rectangle2D getBounds2D(AttributedCharacterIterator aci) {
        aci.first();
        TextPaintInfo tpi = (TextPaintInfo)aci.getAttribute(PAINT_INFO);
        if ((bounds2D != null) &&
            TextPaintInfo.equivilent(tpi, cacheTPI))
            return bounds2D;

        if (tpi == null)
            return null;
        if (!tpi.visible)
            return null;

        cacheTPI = new TextPaintInfo(tpi);
        Shape outline = null;
        if (tpi.fillPaint != null) {
            outline = getOutline();
            bounds2D = outline.getBounds2D();
        }

        // check if we need to include the
        // outline of this glyph
        Stroke stroke = tpi.strokeStroke;
        Paint  paint  = tpi.strokePaint;
        if ((stroke != null) && (paint != null)) {
            if (outline == null)
                outline = getOutline();
            Rectangle2D strokeBounds
                = stroke.createStrokedShape(outline).getBounds2D();
            if (bounds2D == null)
                bounds2D = strokeBounds;
            else
                // bounds2D = bounds2D.createUnion(strokeBounds);
                bounds2D.add(strokeBounds);
        }
        if (bounds2D == null)
            return null;

        if ((bounds2D.getWidth()  == 0) ||
            (bounds2D.getHeight() == 0))
            bounds2D = null;

        return bounds2D;
    }

    /**
     * Returns the logical bounds of this GlyphVector.
     * This is a bound useful for hit detection and highlighting.
     */
    public Rectangle2D getLogicalBounds() {
        if (logicalBounds == null) {
            // This fills in logicalBounds...
            computeGlyphLogicalBounds();
        }
        return logicalBounds;
    }

    /**
     * Returns the logical bounds of the specified glyph within this
     * GlyphVector.
     */
    public Shape getGlyphLogicalBounds(int glyphIndex) {
        if (glyphLogicalBounds[glyphIndex] == null &&
            glyphVisible[glyphIndex]) {

            computeGlyphLogicalBounds();
        }
        return glyphLogicalBounds[glyphIndex];
    }

    /**
     * Calculates the logical bounds for each glyph. The logical
     * bounds are what is used for highlighting the glyphs when
     * selected.
     */
    private void computeGlyphLogicalBounds() {

        Shape[] tempLogicalBounds = new Shape[getNumGlyphs()];
        boolean[] rotated  = new boolean[getNumGlyphs()];

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

            float glyphX      = 0;
            float glyphY      = -ascent/scaleFactor;
            float glyphWidth  = (glyphMetrics.getHorizontalAdvance()/
                                 scaleFactor);
            float glyphHeight = (glyphMetrics.getVerticalAdvance()/
                                 scaleFactor);
            Rectangle2D glyphBounds = new Rectangle2D.Double(glyphX,
                                                             glyphY,
                                                             glyphWidth,
                                                             glyphHeight);

            if (glyphBounds.isEmpty()) {
                if (i > 0) {
                    // can't tell if rotated or not, make it the same as
                    // the previous glyph
                    rotated [i] = rotated [i-1];
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
                tr.scale(scaleFactor, scaleFactor);

                tempLogicalBounds[i] = tr.createTransformedShape(glyphBounds);

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

                if (((Math.abs(tdx12) < 0.001) && (Math.abs(tdy13) < 0.001)) ||
                    ((Math.abs(tdx13) < 0.001) && (Math.abs(tdy12) < 0.001))) {
                    // If either of these are zero then it is axially aligned
                    rotated[i] = false;
                } else {
                    rotated [i] = true;
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

        logicalBounds = logicalBoundsPath.getBounds2D();

        if (logicalBounds.getHeight() < maxHeight*1.5) {
            // make all glyphs tops and bottoms the same as the full bounds
            for (int i = 0; i < getNumGlyphs(); i++) {
                // first make sure that the glyph logical bounds are
                // not rotated
                if (rotated[i]) continue;
                if (tempLogicalBounds[i] == null) continue;

                Rectangle2D glyphBounds = tempLogicalBounds[i].getBounds2D();

                double x     = glyphBounds.getMinX();
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
                    (x,     logicalBounds.getMinY(),
                     width, logicalBounds.getHeight());
            }
        } else if (logicalBounds.getWidth() < maxWidth*1.5) {
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
                    (logicalBounds.getMinX(),  y,
                     logicalBounds.getWidth(), height);
            }
        }

        System.arraycopy( tempLogicalBounds, 0, glyphLogicalBounds, 0, getNumGlyphs() );
    }

    /**
     * Returns the metrics of the glyph at the specified index into this
     * GVTGlyphVector.
     */
    public GVTGlyphMetrics getGlyphMetrics(int glyphIndex) {
        if (glyphMetrics[glyphIndex] != null)
            return glyphMetrics[glyphIndex];

        // -- start glyph cache code --
        Point2D glyphPos = defaultGlyphPositions[glyphIndex];
        char c = ci.setIndex(ci.getBeginIndex()+glyphIndex);
        ci.setIndex(ci.getBeginIndex());
        AWTGlyphGeometryCache.Value v = AWTGVTFont.getGlyphGeometry
            (gvtFont, c, awtGlyphVector, glyphIndex, glyphPos);
        Rectangle2D gmB = v.getBounds2D();
        // -- end glyph cache code --

        Rectangle2D bounds = new Rectangle2D.Double
            (gmB.getX()     * scaleFactor, gmB.getY()      * scaleFactor,
             gmB.getWidth() * scaleFactor, gmB.getHeight() * scaleFactor);

        // defaultGlyphPositions has one more entry than glyphs
        // the last entry stores the total advance for the
        // glyphVector.
        float adv = (float)(defaultGlyphPositions[glyphIndex+1].getX()-
                            defaultGlyphPositions[glyphIndex]  .getX());
        glyphMetrics[glyphIndex] =  new GVTGlyphMetrics
            (adv*scaleFactor, (ascent+descent),
             bounds, GlyphMetrics.STANDARD);

        return glyphMetrics[glyphIndex];
    }

    /**
     * Returns a Shape whose interior corresponds to the visual representation
     * of the specified glyph within this GlyphVector.
     */
    public Shape getGlyphOutline(int glyphIndex) {
        if (glyphOutlines[glyphIndex] == null) {
/*
            Shape glyphOutline = awtGlyphVector.getGlyphOutline(glyphIndex);
*/
            // -- start glyph cache code --
            Point2D glyphPos = defaultGlyphPositions[glyphIndex];
            char c = ci.setIndex(ci.getBeginIndex()+glyphIndex);
            ci.setIndex(ci.getBeginIndex());
            AWTGlyphGeometryCache.Value v = AWTGVTFont.getGlyphGeometry
                (gvtFont, c, awtGlyphVector, glyphIndex, glyphPos);
            Shape glyphOutline = v.getOutline();
           // -- end glyph cache code --

            AffineTransform tr = AffineTransform.getTranslateInstance
                (getGlyphPosition(glyphIndex).getX(),
                 getGlyphPosition(glyphIndex).getY());

            AffineTransform glyphTransform = getGlyphTransform(glyphIndex);

            if (glyphTransform != null) {
                tr.concatenate(glyphTransform);
            }
            //
            // <!> HACK
            //
            // GlyphVector.getGlyphOutline behavior changes between 1.3 and 1.4
            //
            // I've looked at this problem a bit more and the incorrect glyph
            // positioning in Batik is definitely due to the change in
            // behavior of GlyphVector.getGlyphOutline(glyphIndex). It used to
            // return the outline of the glyph at position 0,0 which meant
            // that we had to translate it to the actual glyph position before
            // drawing it. Now, it returns the outline which has already been
            // positioned.
            //
            // -- Bella
            //
/*
            if (outlinesPositioned()) {
                Point2D glyphPos = defaultGlyphPositions[glyphIndex];
                tr.translate(-glyphPos.getX(), -glyphPos.getY());
            }
*/
            tr.scale(scaleFactor, scaleFactor);
            glyphOutlines[glyphIndex]=tr.createTransformedShape(glyphOutline);
        }

        return glyphOutlines[glyphIndex];
    }

    // This is true if GlyphVector.getGlyphOutline returns glyph outlines
    // that are positioned (if it is false the outlines are always at 0,0).
    private static final boolean outlinesPositioned;
    // This is true if Graphics2D.drawGlyphVector works for the
    // current JDK/OS combination.
    private static final boolean drawGlyphVectorWorks;
    // This is true if Graphics2D.drawGlyphVector will correctly
    // render Glyph Vectors with per glyph transforms.
    private static final boolean glyphVectorTransformWorks;

    static {
        String s = System.getProperty("java.specification.version");
        if ("1.4".compareTo(s) <= 0) {
            outlinesPositioned = true;
            drawGlyphVectorWorks = true;
            glyphVectorTransformWorks = true;
        } else if ("Mac OS X".equals(System.getProperty("os.name"))) {
            outlinesPositioned = true;
            drawGlyphVectorWorks = false;
            glyphVectorTransformWorks = false;
        } else {
            outlinesPositioned = false;
            drawGlyphVectorWorks = true;
            glyphVectorTransformWorks = false;
        }
    }

    // Returns true if GlyphVector.getGlyphOutlines returns glyph outlines
    // that are positioned (otherwise they are always at 0,0).
    static boolean outlinesPositioned() {
        return outlinesPositioned;
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
        return glyphPositions[glyphIndex];
    }

    /**
     * Returns an array of glyph positions for the specified glyphs
     */
    public float[] getGlyphPositions(int beginGlyphIndex,
                                     int numEntries,
                                     float[] positionReturn) {

        if (positionReturn == null) {
            positionReturn = new float[numEntries*2];
        }

        for (int i = beginGlyphIndex; i < (beginGlyphIndex+numEntries); i++) {
            Point2D glyphPos = getGlyphPosition(i);
            positionReturn[(i-beginGlyphIndex)*2] = (float)glyphPos.getX();
            positionReturn[(i-beginGlyphIndex)*2 + 1] = (float)glyphPos.getY();
        }

        return positionReturn;
    }

    /**
     * Gets the transform of the specified glyph within this GlyphVector.
     */
    public AffineTransform getGlyphTransform(int glyphIndex) {
        return glyphTransforms[glyphIndex];
    }

    /**
     * Returns the visual bounds of the specified glyph within the GlyphVector.
     */
    public Shape getGlyphVisualBounds(int glyphIndex) {
        if (glyphVisualBounds[glyphIndex] == null) {
/*
            Shape glyphOutline = awtGlyphVector.getGlyphOutline(glyphIndex);
            Rectangle2D glyphBounds = glyphOutline.getBounds2D();
*/
            // -- start glyph cache code --
            Point2D glyphPos = defaultGlyphPositions[glyphIndex];
            char c = ci.setIndex(ci.getBeginIndex()+glyphIndex);
            ci.setIndex(ci.getBeginIndex());
            AWTGlyphGeometryCache.Value v = AWTGVTFont.getGlyphGeometry
                (gvtFont, c, awtGlyphVector, glyphIndex, glyphPos);
            Rectangle2D glyphBounds = v.getOutlineBounds2D();
           // -- end glyph cache code --

            AffineTransform tr = AffineTransform.getTranslateInstance
                (getGlyphPosition(glyphIndex).getX(),
                 getGlyphPosition(glyphIndex).getY());

            AffineTransform glyphTransform = getGlyphTransform(glyphIndex);
            if (glyphTransform != null) {
                tr.concatenate(glyphTransform);
            }
            tr.scale(scaleFactor, scaleFactor);
            glyphVisualBounds[glyphIndex] =
                tr.createTransformedShape(glyphBounds);
        }

        return glyphVisualBounds[glyphIndex];
    }

    /**
     * Returns the number of glyphs in this GlyphVector.
     */
    public int getNumGlyphs() {
        return awtGlyphVector.getNumGlyphs();
    }

    /**
     * Returns a Shape whose interior corresponds to the visual representation
     * of this GlyphVector.
     */
    public Shape getOutline() {
        if (outline != null)
            return outline;

        outline = new GeneralPath();
        for (int i = 0; i < getNumGlyphs(); i++) {
            if (glyphVisible[i]) {
                Shape glyphOutline = getGlyphOutline(i);
                outline.append(glyphOutline, false);
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
        outline = tr.createTransformedShape(outline);
        return outline;
    }

    /**
     * Returns the visual bounds of this GlyphVector The visual bounds is the
     * tightest rectangle enclosing all non-background pixels in the rendered
     * representation of this GlyphVector.
     */
    public Rectangle2D getGeometricBounds() {
        if (visualBounds == null) {
            Shape outline = getOutline();
            visualBounds = outline.getBounds2D();
        }
        return visualBounds;
    }

    /**
     * Assigns default positions to each glyph in this GlyphVector.
     */
    public void performDefaultLayout() {
        if (defaultGlyphPositions == null) {
            awtGlyphVector.performDefaultLayout();
            defaultGlyphPositions = new Point2D.Float[getNumGlyphs()+1];
            for (int i = 0; i <= getNumGlyphs(); i++)
                defaultGlyphPositions[i] = awtGlyphVector.getGlyphPosition(i);
        }

        outline       = null;
        visualBounds  = null;
        logicalBounds = null;
        bounds2D      = null;
        float shiftLeft = 0;
        int i=0;
        for (; i < getNumGlyphs(); i++) {
            glyphTransforms   [i] = null;
            glyphVisualBounds [i] = null;
            glyphLogicalBounds[i] = null;
            glyphOutlines     [i] = null;
            glyphMetrics      [i] = null;
            Point2D glyphPos = defaultGlyphPositions[i];
            float x = (float)((glyphPos.getX() * scaleFactor)-shiftLeft);
            float y = (float) (glyphPos.getY() * scaleFactor);

            // if c is a transparent arabic char then need to shift the
            // following glyphs left so that the current glyph is overwritten
            /*char c =*/ ci.setIndex(i + ci.getBeginIndex());
            /*
            if (ArabicTextHandler.arabicCharTransparent(c)) {
                int j;
                shiftLeft += getGlyphMetrics(i).getHorizontalAdvance();
                for (j=i+1; j<getNumGlyphs(); j++) {
                    char c2 = ci.setIndex(j+ci.getBeginIndex());
                    if (!ArabicTextHandler.arabicCharTransparent(c2)) break;
                    shiftLeft += getGlyphMetrics(j).getHorizontalAdvance();
                }
                if (j != getNumGlyphs()) {
                    Point2D glyphPosBase = defaultGlyphPositions[j];
                    double rEdge = glyphPosBase.getX()+getGlyphMetrics(j).getHorizontalAdvance();
                    rEdge -= shiftLeft;
                    for (int k=i; k<j; k++) {
                        glyphTransforms   [k] = null;
                        glyphVisualBounds [k] = null;
                        glyphLogicalBounds[k] = null;
                        glyphOutlines     [k] = null;
                        glyphMetrics      [k] = null;
                        x = (float)rEdge-getGlyphMetrics(k).getHorizontalAdvance();
                        y = (float) (defaultGlyphPositions[k].getY() * scaleFactor);
                        if (glyphPositions[k] == null) {
                            glyphPositions[k] = new Point2D.Float(x,y);
                        } else {
                            glyphPositions[k].x = x;
                            glyphPositions[k].y = y;
                        }
                    }
                    i = j-1;
                }
            } else {
            */
                if (glyphPositions[i] == null) {
                    glyphPositions[i] = new Point2D.Float(x,y);
                } else {
                    glyphPositions[i].x = x;
                    glyphPositions[i].y = y;
                }
                // }

        }

        // Need glyph pos for point after last char...
        Point2D glyphPos = defaultGlyphPositions[i];
        glyphPositions[i] = new Point2D.Float
                ((float)((glyphPos.getX() * scaleFactor)-shiftLeft),
                 (float) (glyphPos.getY() * scaleFactor));
    }

    /**
     * Sets the position of the specified glyph within this GlyphVector.
     */
    public void setGlyphPosition(int glyphIndex, Point2D newPos) {
        glyphPositions[glyphIndex].x = (float)newPos.getX();
        glyphPositions[glyphIndex].y = (float)newPos.getY();
        outline       = null;
        visualBounds  = null;
        logicalBounds = null;
        bounds2D      = null;

        if (glyphIndex != getNumGlyphs()) {
            glyphVisualBounds [glyphIndex] = null;
            glyphLogicalBounds[glyphIndex] = null;
            glyphOutlines     [glyphIndex] = null;
            glyphMetrics      [glyphIndex] = null;
        }
    }

    /**
     * Sets the transform of the specified glyph within this GlyphVector.
     */
    public void setGlyphTransform(int glyphIndex, AffineTransform newTX) {
        glyphTransforms[glyphIndex] = newTX;
        outline       = null;
        visualBounds  = null;
        logicalBounds = null;
        bounds2D      = null;

        glyphVisualBounds [glyphIndex] = null;
        glyphLogicalBounds[glyphIndex] = null;
        glyphOutlines     [glyphIndex] = null;
        glyphMetrics      [glyphIndex] = null;
    }

    /**
     * Tells the glyph vector whether or not to draw the specified glyph.
     */
    public void setGlyphVisible(int glyphIndex, boolean visible) {
        if (visible == glyphVisible[glyphIndex])
            return;
        glyphVisible[glyphIndex] = visible;
        outline       = null;
        visualBounds  = null;
        logicalBounds = null;
        bounds2D      = null;

        glyphVisualBounds [glyphIndex] = null;
        glyphLogicalBounds[glyphIndex] = null;
        glyphOutlines     [glyphIndex] = null;
        glyphMetrics      [glyphIndex] = null;
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
     *
     * @param startGlyphIndex The index of the first glyph in the range.
     * @param endGlyphIndex The index of the last glyph in the range.
     * @return The number of chars.
     */
    public int getCharacterCount(int startGlyphIndex, int endGlyphIndex) {
        if (startGlyphIndex < 0) {
            startGlyphIndex = 0;
        }
        if (endGlyphIndex >= getNumGlyphs()) {
            endGlyphIndex = getNumGlyphs()-1;
        }
        int charCount = 0;
        int start = startGlyphIndex+ci.getBeginIndex();
        int end   = endGlyphIndex+ci.getBeginIndex();

        for (char c = ci.setIndex(start); ci.getIndex() <= end; c=ci.next()) {
            charCount += ArabicTextHandler.getNumChars(c);
        }

        return charCount;
    }

    /**
     * Draws this glyph vector.
     */
    public void draw(Graphics2D graphics2D,
                     AttributedCharacterIterator aci) {
        int numGlyphs = getNumGlyphs();

        aci.first();
        TextPaintInfo tpi = (TextPaintInfo)aci.getAttribute
            (GVTAttributedCharacterIterator.TextAttribute.PAINT_INFO);
        if (tpi == null) return;
        if (!tpi.visible) return;

        Paint  fillPaint   = tpi.fillPaint;
        Stroke stroke      = tpi.strokeStroke;
        Paint  strokePaint = tpi.strokePaint;

        if ((fillPaint == null) && ((strokePaint == null) ||
                                    (stroke == null)))
            return;

        boolean useHinting = drawGlyphVectorWorks;
        if (useHinting && (stroke != null) && (strokePaint != null))
            // Can't stroke with drawGlyphVector.
            useHinting = false;

        if (useHinting &&
            (fillPaint != null) && !(fillPaint instanceof Color))
            // The coordinate system is different for drawGlyphVector.
            // So complex paints aren't positioned properly.
            useHinting = false;

        if (useHinting) {
            Object v1 = graphics2D.getRenderingHint
                (RenderingHints.KEY_TEXT_ANTIALIASING);
            Object v2 = graphics2D.getRenderingHint
                (RenderingHints.KEY_STROKE_CONTROL);
            // text-rendering = geometricPrecision so fill shapes.
            if ((v1 == RenderingHints.VALUE_TEXT_ANTIALIAS_ON) &&
                (v2 == RenderingHints.VALUE_STROKE_PURE))
                useHinting = false;
        }

        final int typeGRot   = AffineTransform.TYPE_GENERAL_ROTATION;
        final int typeGTrans = AffineTransform.TYPE_GENERAL_TRANSFORM;

        if (useHinting) {
            // Check if usr->dev transform has general rotation,
            // or shear..
            AffineTransform at = graphics2D.getTransform();
            int type = at.getType();
            if (((type & typeGTrans) != 0) || ((type & typeGRot)  != 0))
                useHinting = false;
        }

        if (useHinting) {
            for (int i=0; i<numGlyphs; i++) {
                if (!glyphVisible[i]) {
                    useHinting = false;
                    break;
                }
                AffineTransform at = glyphTransforms[i];
                if (at != null) {
                    int type = at.getType();
                    if ((type & ~AffineTransform.TYPE_TRANSLATION) == 0) {
                        // Just translation
                    } else if (glyphVectorTransformWorks &&
                               ((type & typeGTrans) == 0) &&
                               ((type & typeGRot)   == 0)) {
                        // It's a simple 90Deg rotate, and we can put
                        // it into the GlyphVector.
                    } else {
                        // we can't (or it doesn't make sense
                        // to use the GlyphVector.
                        useHinting = false;
                        break;
                    }
                }
            }
        }

        if (useHinting) {
            double sf = scaleFactor;
            double [] mat = new double[6];
            for (int i=0; i< numGlyphs; i++) {
                Point2D         pos = glyphPositions[i];
                double x = pos.getX();
                double y = pos.getY();
                AffineTransform at = glyphTransforms[i];
                if (at != null) {
                    // Scale the translate portion of matrix,
                    // and add it into the position.
                    at.getMatrix(mat);
                    x += mat[4];
                    y += mat[5];
                    if ((mat[0] != 1) || (mat[1] != 0) ||
                        (mat[2] != 0) || (mat[3] != 1)) {
                        // More than just translation.
                        mat[4] = 0; mat[5] = 0;
                        at = new AffineTransform(mat);
                    } else {
                        at = null;
                    }
                }
                pos = new Point2D.Double(x/sf, y/sf);
                awtGlyphVector.setGlyphPosition(i, pos);
                awtGlyphVector.setGlyphTransform(i, at);
            }
            graphics2D.scale(sf, sf);
            graphics2D.setPaint(fillPaint);
            graphics2D.drawGlyphVector(awtGlyphVector, 0, 0);
            graphics2D.scale(1/sf, 1/sf);

            for (int i=0; i< numGlyphs; i++) {
                Point2D         pos = defaultGlyphPositions[i];
                awtGlyphVector.setGlyphPosition(i, pos);
                awtGlyphVector.setGlyphTransform(i, null);
            }

        } else {
            Shape outline = getOutline();

            // check if we need to fill this glyph
            if (fillPaint != null) {
                graphics2D.setPaint(fillPaint);
                graphics2D.fill(outline);
            }

            // check if we need to draw the outline of this glyph
            if (stroke != null && strokePaint != null) {
                graphics2D.setStroke(stroke);
                graphics2D.setPaint(strokePaint);
                graphics2D.draw(outline);
            }
        }
    }
}
