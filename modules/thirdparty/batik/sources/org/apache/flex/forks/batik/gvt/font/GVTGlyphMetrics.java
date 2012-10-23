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

import java.awt.font.GlyphMetrics;
import java.awt.geom.Rectangle2D;

/**
 * GVTGlyphMetrics is essentially a wrapper class for java.awt.font.GlyphMetrics
 * with the addition of horizontal and vertical advance values.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: GVTGlyphMetrics.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GVTGlyphMetrics {

    private GlyphMetrics gm;
    private float verticalAdvance;

    /**
     * Constructs a new GVTGlyphMetrics object based upon the specified
     * GlyphMetrics object and an additional vertical advance value.
     *
     * @param gm The glyph metrics.
     * @param verticalAdvance The vertical advance of the glyph.
     */
    public GVTGlyphMetrics(GlyphMetrics gm, float verticalAdvance) {
        this.gm = gm;
        this.verticalAdvance = verticalAdvance;
    }

    /**
     * Constructs a new GVTGlyphMetrics object using the specified parameters.
     *
     * @param horizontalAdvance The horizontal advance of the glyph.
     * @param verticalAdvance The vertical advance of the glyph.
     * @param bounds The black box bounds of the glyph.
     * @param glyphType The type of the glyph.
     */
    public GVTGlyphMetrics(float horizontalAdvance, 
                           float verticalAdvance,
                           Rectangle2D bounds, 
                           byte glyphType) {
        this.gm = new GlyphMetrics(horizontalAdvance, bounds, glyphType);
        this.verticalAdvance = verticalAdvance;
    }

    /**
     * Returns the horizontal advance of the glyph.
     */
    public float getHorizontalAdvance() {
        return gm.getAdvance();
    }

    /**
     * Returns the vertical advance of the glyph.
     */
    public float getVerticalAdvance() {
        return verticalAdvance;
    }

    /**
     * Returns the black box bounds of the glyph.
     */
    public Rectangle2D getBounds2D() {
        return gm.getBounds2D();
    }

    /**
     * Returns the left (top) side bearing of the glyph.
     */
    public float getLSB() {
        return gm.getLSB();
    }

    /**
     * Returns the right (bottom) side bearing of the glyph.
     */
    public float getRSB() {
        return gm.getRSB();
    }

    /**
     * Returns the raw glyph type code.
     */
    public int getType() {
        return gm.getType();
    }

    /**
     * Returns true if this is a combining glyph.
     */
    public boolean isCombining() {
        return gm.isCombining();
    }

    /**
     * Returns true if this is a component glyph.
     */
    public boolean isComponent() {
        return gm.isComponent();
    }

    /**
     * Returns true if this is a ligature glyph.
     */
    public boolean isLigature() {
        return gm.isLigature();
    }

    /**
     * Returns true if this is a standard glyph.
     */
    public boolean isStandard() {
        return gm.isStandard();
    }

    /**
     * Returns true if this is a whitespace glyph.
     */
    public boolean isWhitespace() {
        return gm.isWhitespace();
    }

}
