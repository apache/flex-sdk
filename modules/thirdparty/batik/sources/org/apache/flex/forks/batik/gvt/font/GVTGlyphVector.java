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
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;

/**
 * An interface for all GVT GlyphVector classes.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: GVTGlyphVector.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public interface GVTGlyphVector {

    /**
     * Returns the Font associated with this GlyphVector.
     */
    GVTFont getFont();

    /**
     * Returns the FontRenderContext associated with this GlyphVector.
     */
    FontRenderContext getFontRenderContext();

    /**
     * Returns the glyphcode of the specified glyph.
     */
    int getGlyphCode(int glyphIndex);

    /**
     * Returns an array of glyphcodes for the specified glyphs.
     */
    int[] getGlyphCodes(int beginGlyphIndex, int numEntries, int[] codeReturn);

    /**
     * Returns the justification information for the glyph at the specified
     * index into this GlyphVector.
     */
    GlyphJustificationInfo getGlyphJustificationInfo(int glyphIndex);

    /**
     *  Returns the logical bounds of the specified glyph within this
     *  GlyphVector.  This is a good bound for hit detection and
     *  highlighting it is not tight in any sense, and in some (rare)
     * cases may exclude parts of the glyph.
     */
    Shape getGlyphLogicalBounds(int glyphIndex);

    /**
     * Returns the metrics of the glyph at the specified index into this
     * GlyphVector.
     */
    GVTGlyphMetrics getGlyphMetrics(int glyphIndex);

    /**
     * Returns a Shape whose interior corresponds to the visual representation
     * of the specified glyph within this GlyphVector.
     */
    Shape getGlyphOutline(int glyphIndex);

    /**
     * Returns the bounding box of the specified glyph, considering only the
     * glyph's metrics (ascent, descent, advance) rather than the actual glyph
     * shape.
     */
    Rectangle2D getGlyphCellBounds(int glyphIndex);

    /**
     * Returns the position of the specified glyph within this GlyphVector.
     */
    Point2D getGlyphPosition(int glyphIndex);

    /**
     * Returns an array of glyph positions for the specified glyphs
     */
    float[] getGlyphPositions(int beginGlyphIndex,
                              int numEntries,
                              float[] positionReturn);

    /**
     * Gets the transform of the specified glyph within this GlyphVector.
     */
    AffineTransform getGlyphTransform(int glyphIndex);

    /**
     * Returns the visual bounds of the specified glyph within the GlyphVector.
     */
    Shape getGlyphVisualBounds(int glyphIndex);

    /**
     * Returns the logical bounds of this GlyphVector.  This is a
     * good bound for hit detection and highlighting it is not tight
     * in any sense, and in some (rare) cases may exclude parts of
     * the glyph.
     */
    Rectangle2D getLogicalBounds();

    /**
     * Returns the number of glyphs in this GlyphVector.
     */
    int getNumGlyphs();

    /**
     * Returns a Shape whose interior corresponds to the visual representation
     * of this GlyphVector.
     */
    Shape getOutline();

    /**
     * Returns a Shape whose interior corresponds to the visual representation
     * of this GlyphVector, offset to x, y.
     */
    Shape getOutline(float x, float y);

    /**
     * Returns the visual bounds of this GlyphVector The visual bounds is the
     * tightest rectangle enclosing all non-background pixels in the rendered
     * representation of this GlyphVector.
     */
    Rectangle2D getGeometricBounds();

    /**
     * Returns a tight bounds on the GylphVector including stroking.
     * @param aci Required to get painting attributes of glyphVector.
     */
    Rectangle2D getBounds2D(AttributedCharacterIterator aci);

    /**
     * Assigns default positions to each glyph in this GlyphVector.
     */
    void performDefaultLayout();

    /**
     * Sets the position of the specified glyph within this GlyphVector.
     */
    void setGlyphPosition(int glyphIndex, Point2D newPos);

    /**
     * Sets the transform of the specified glyph within this GlyphVector.
     */
    void setGlyphTransform(int glyphIndex, AffineTransform newTX);

    /**
     * Tells the glyph vector whether or not to draw the specified glyph.
     */
    void setGlyphVisible(int glyphIndex, boolean visible);

    /**
     * Returns true if specified glyph will be drawn.
     */
    boolean isGlyphVisible(int glyphIndex);

    /**
     * Returns the number of chars represented by the glyphs within the
     * specified range.
     *
     * @param startGlyphIndex The index of the first glyph in the range.
     * @param endGlyphIndex The index of the last glyph in the range.
     * @return The number of chars.
     */
    int getCharacterCount(int startGlyphIndex, int endGlyphIndex);

    /**
     * Draws the glyph vector.
     */
    void draw(Graphics2D graphics2D,
              AttributedCharacterIterator aci);
}
