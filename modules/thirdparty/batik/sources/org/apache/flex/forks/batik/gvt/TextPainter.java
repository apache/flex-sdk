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
package org.apache.flex.forks.batik.gvt;

import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.gvt.text.Mark;

/**
 * Renders the attributed character iterator of a <tt>TextNode</tt>.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: TextPainter.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface TextPainter {

    /**
     * Paints the specified attributed character iterator using the specified
     * Graphics2D and context and font context.
     *
     * @param node the TextNode to paint
     * @param g2d the Graphics2D to use
     */
    void paint(TextNode node, Graphics2D g2d);

    /**
     * Initiates a text selection on a particular AttributedCharacterIterator,
     * using the text/font metrics employed by this TextPainter instance.
     */
    Mark selectAt(double x, double y, TextNode node);

    /**
     * Continues a text selection on a particular AttributedCharacterIterator,
     * using the text/font metrics employed by this TextPainter instance.
     */
    Mark selectTo(double x, double y, Mark beginMark);

    /**
     * Selects the first glyph in the text node.
     */
    Mark selectFirst(TextNode node);


    /**
     * Selects the last glyph in the text node.
     */
    Mark selectLast(TextNode node);

    /**
     * Returns a mark for the char at index in node's
     * AttributedCharacterIterator.  Leading edge indicates if the 
     * mark should be considered immediately 'before' glyph or
     * after
     */
     Mark getMark(TextNode node, int index, boolean beforeGlyph);

    /**
     * Get an array of index pairs corresponding to the indices within an
     * AttributedCharacterIterator regions bounded by two Marks.
     *
     * Note that the instances of Mark passed to this function <em>must
     * come</em> from the same TextPainter that generated them via selectAt()
     * and selectTo(), since the TextPainter implementation may rely on hidden
     * implementation details of its own Mark implementation.  */
    int[] getSelected(Mark start, Mark finish);
    

    /**
     * Get a Shape in userspace coords which encloses the textnode
     * glyphs bounded by two Marks.
     * Note that the instances of Mark passed to this function
     * <em>must come</em>
     * from the same TextPainter that generated them via selectAt() and
     * selectTo(), since the TextPainter implementation may rely on hidden
     * implementation details of its own Mark implementation.
     */
    Shape getHighlightShape(Mark beginMark, Mark endMark);

    /**
     * Get a Shape in userspace coords which defines the textnode 
     * glyph outlines.
     * @param node the TextNode to measure
     */
    Shape getOutline(TextNode node);

    /**
     * Get a Rectangle2D in userspace coords which encloses the textnode
     * glyphs rendered bounds (includes stroke etc).
     * @param node the TextNode to measure
     */
    Rectangle2D getBounds2D(TextNode node);

    /**
     * Get a Rectangle2D in userspace coords which encloses the textnode
     * glyphs just including the geometry info.
     * @param node the TextNode to measure
     */
    Rectangle2D getGeometryBounds(TextNode node);
}

