/*

   Copyright 1999-2003  The Apache Software Foundation 

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

package org.apache.flex.forks.batik.gvt.text;

import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.gvt.font.GVTGlyphMetrics;
import org.apache.flex.forks.batik.gvt.font.GVTGlyphVector;

/**
 * Class that performs layout of attributed text strings into
 * glyph sets paintable by TextPainter instances.
 * Similar to java.awt.font.TextLayout in function and purpose.
 * Note that while this utility interface is provided for the convenience of
 * <tt>TextPainter</tt> implementations, conforming <tt>TextPainter</tt>s
 * are not required to use this class.
 * @see java.awt.font.TextLayout
 * @see org.apache.flex.forks.batik.gvt.TextPainter
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: TextSpanLayout.java,v 1.18 2005/03/27 08:58:35 cam Exp $
 */
public interface TextSpanLayout {

    public int DECORATION_UNDERLINE = 0x1;
    public int DECORATION_STRIKETHROUGH = 0x2;
    public int DECORATION_OVERLINE = 0x4;
    public int DECORATION_ALL = DECORATION_UNDERLINE |
                                DECORATION_OVERLINE |
                                DECORATION_STRIKETHROUGH;

    /**
     * Paints the specified text layout using the
     * specified Graphics2D and rendering context.
     * @param g2d the Graphics2D to use
     */
    public void draw(Graphics2D g2d);

    /**
     * Returns the outline of the specified decorations on the glyphs,
     * transformed by an AffineTransform.
     * @param decorationType an integer indicating the type(s) of decorations
     *     included in this shape.  May be the result of "OR-ing" several
     *     values together:
     * e.g. <tt>DECORATION_UNDERLINE | DECORATION_STRIKETHROUGH</tt>
     */
    public Shape getDecorationOutline(int decorationType);

    /**
     * Returns the rectangular bounds of the completed glyph layout.
     * This includes stroking information, this does not include
     * deocrations.
     */
    public Rectangle2D getBounds2D();

    /**
     * Returns the bounds of the geometry (this is always the bounds
     * of the outline).
     */
    public Rectangle2D getGeometricBounds();

    /**
     * Returns the outline of the completed glyph layout, transformed
     * by an AffineTransform.
     */
    public Shape getOutline();

    /**
     * Returns the current text position at the completion
     * of glyph layout.
     * (This is the position that should be used for positioning
     * adjacent layouts.)
     */
    public Point2D getAdvance2D();

    /**
     * Returns the advance between each glyph in text progression direction.
     */
    public float [] getGlyphAdvances();

    /**
     * Returns the Metrics for a particular glyph.
     */
    public GVTGlyphMetrics getGlyphMetrics(int glyphIndex);

    public Point2D getTextPathAdvance();

    /**
     * Returns the current text position at the completion beginning
     * of glyph layout, before the application of explicit
     * glyph positioning attributes.
     */
    public Point2D getOffset();

    /**
     * Sets the scaling factor to use for string.  if ajdSpacing is
     * true then only the spacing between glyphs will be adjusted
     * otherwise the glyphs and the spaces between them will be
     * adjusted.
     * @param xScale Scale factor to apply in X direction.
     * @param yScale Scale factor to apply in Y direction.
     * @param adjSpacing True if only spaces should be adjusted.
     */
    public void setScale(float xScale, float yScale, boolean adjSpacing);

    /**
     * Sets the text position used for the implicit origin
     * of glyph layout. Ignored if multiple explicit glyph
     * positioning attributes are present in ACI
     * (e.g. if the aci has multiple X or Y values).
     */
    public void setOffset(Point2D offset);

    /**
     * Returns a Shape which encloses the currently selected glyphs
     * as specified by glyph indices <tt>begin</tt> and <tt>end</tt>.
     * @param beginCharIndex the index of the first glyph in the contiguous
     *                       selection.
     * @param endCharIndex the index of the last glyph in the contiguous
     *                     selection.
     */
     public Shape getHighlightShape(int beginCharIndex, int endCharIndex);

    /**
     * Perform hit testing for coordinate at x, y.
     * @return a TextHit object encapsulating the character index for
     *     successful hits and whether the hit is on the character
     *     leading edge.
     * @param x the x coordinate of the point to be tested.
     * @param y the y coordinate of the point to be tested.
     */
    public TextHit hitTestChar(float x, float y);

    /**
     * Returns true if the advance direction of this text is vertical.
     */
    public boolean isVertical();

    /**
     * Returns true if this layout in on a text path.
     */
    public boolean isOnATextPath();

    /**
     * Returns the number of glyphs in this layout.
     */
    public int getGlyphCount();

    /**
     * Returns the number of chars represented by the glyphs within the
     * specified range.
     * @param startGlyphIndex The index of the first glyph in the range.
     * @param endGlyphIndex The index of the last glyph in the range.
     * @return The number of chars.
     */
    public int getCharacterCount(int startGlyphIndex, int endGlyphIndex);

    /**
     * Returns the glyph index of the glyph that has the specified char index.
     *
     * @param charIndex The original index of the character in the text node's
     * text string.
     * @return The index of the matching glyph in this layout's glyph vector,
     *         or -1 if a matching glyph could not be found.
     */
    public int getGlyphIndex(int charIndex);

    /**
     * Returns true if the text direction in this layout is from left to right.
     */
    public boolean isLeftToRight();

    /**
     * Return true is the character index is represented by glyphs 
     * in this layout.
     *
     * @param index index of the character in the ACI.
     * @return true if the layout represents that character.
     */
    public boolean hasCharacterIndex(int index);


    /**
     * Return the glyph vector asociated to this layout.
     *
     * @return glyph vector
     */
    public GVTGlyphVector getGlyphVector();

    /**
     * Return the rotation angle applied to the
     * character.
     *
     * @param index index of the character in the ACI
     * @return rotation angle
     */
    public double getComputedOrientationAngle(int index);

    /**
     * Return true if this text run represents
     * an alt glyph.
     */
    public boolean isAltGlyph();
}
