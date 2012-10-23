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

import java.awt.font.LineMetrics;

/**
 * GVTLineMetrics is a GVT version of java.awt.font.LineMetrics.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: GVTLineMetrics.java 475685 2006-11-16 11:16:05Z cam $
 */
public class GVTLineMetrics {

    protected float ascent;
    protected int baselineIndex;
    protected float[] baselineOffsets;
    protected float descent;
    protected float height;
    protected float leading;
    protected int numChars;
    protected float strikethroughOffset;
    protected float strikethroughThickness;
    protected float underlineOffset;
    protected float underlineThickness;
    protected float overlineOffset;
    protected float overlineThickness;

    /**
     * Constructs a GVTLineMetrics object based on the specified line metrics.
     *
     * @param lineMetrics The lineMetrics object that this metrics object will
     * be based upon.
     */
    public GVTLineMetrics(LineMetrics lineMetrics) {
        this.ascent = lineMetrics.getAscent();
        this.baselineIndex = lineMetrics.getBaselineIndex();
        this.baselineOffsets = lineMetrics.getBaselineOffsets();
        this.descent = lineMetrics.getDescent();
        this.height = lineMetrics.getHeight();
        this.leading = lineMetrics.getLeading();
        this.numChars = lineMetrics.getNumChars();
        this.strikethroughOffset = lineMetrics.getStrikethroughOffset();
        this.strikethroughThickness = lineMetrics.getStrikethroughThickness();
        this.underlineOffset = lineMetrics.getUnderlineOffset();
        this.underlineThickness = lineMetrics.getUnderlineThickness();
        this.overlineOffset = -this.ascent;
        this.overlineThickness = this.underlineThickness;
    }


    /**
     * Constructs a GVTLineMetrics object based on the specified line metrics
     * with a scale factor applied.
     *
     * @param lineMetrics The lineMetrics object that this metrics object will
     * be based upon.
     * @param scaleFactor The scale factor to apply to all metrics.
     */
    public GVTLineMetrics(LineMetrics lineMetrics, float scaleFactor) {
        this.ascent = lineMetrics.getAscent() * scaleFactor;
        this.baselineIndex = lineMetrics.getBaselineIndex();
        this.baselineOffsets = lineMetrics.getBaselineOffsets();
        for (int i=0; i<baselineOffsets.length; i++) {
            this.baselineOffsets[i] *= scaleFactor;
        }
        this.descent = lineMetrics.getDescent() * scaleFactor;
        this.height = lineMetrics.getHeight() * scaleFactor;
        this.leading = lineMetrics.getLeading();
        this.numChars = lineMetrics.getNumChars();
        this.strikethroughOffset = 
            lineMetrics.getStrikethroughOffset() * scaleFactor;
        this.strikethroughThickness = 
            lineMetrics.getStrikethroughThickness() * scaleFactor;
        this.underlineOffset = lineMetrics.getUnderlineOffset() * scaleFactor;
        this.underlineThickness = 
            lineMetrics.getUnderlineThickness() * scaleFactor;
        this.overlineOffset = -this.ascent;
        this.overlineThickness = this.underlineThickness;
    }


    /**
     * Constructs a GVTLineMetrics object with the specified attributes.
     */
    public GVTLineMetrics(float ascent, 
                          int baselineIndex, 
                          float[] baselineOffsets,
                          float descent, 
                          float height, 
                          float leading, int numChars,
                          float strikethroughOffset, 
                          float strikethroughThickness,
                          float underlineOffset, 
                          float underlineThickness,
                          float overlineOffset, 
                          float overlineThickness) {

        this.ascent = ascent;
        this.baselineIndex = baselineIndex;
        this.baselineOffsets = baselineOffsets;
        this.descent = descent;
        this.height = height;
        this.leading = leading;
        this.numChars = numChars;
        this.strikethroughOffset = strikethroughOffset;
        this.strikethroughThickness = strikethroughThickness;
        this.underlineOffset = underlineOffset;
        this.underlineThickness = underlineThickness;
        this.overlineOffset = overlineOffset;
        this.overlineThickness = overlineThickness;
    }

    /**
     * Returns the ascent of the text.
     */
    public float getAscent() {
        return ascent;
    }

    /**
     * Returns the baseline index of the text.
     */
    public int getBaselineIndex() {
        return baselineIndex;
    }

    /**
     * Returns the baseline offsets of the text, relative to the baseline of
     * the text.
     */
    public float[] getBaselineOffsets() {
        return baselineOffsets;
    }

    /**
     * Returns the descent of the text.
     */
    public float getDescent() {
        return descent;
    }

    /**
     * Returns the height of the text.
     */
    public float getHeight() {
        return height;
    }

    /**
     * Returns the leading of the text.
     */
    public float getLeading() {
        return leading;
    }

    /**
     * Returns the number of characters in the text whose metrics are
     * encapsulated by this LineMetrics object.
     */
    public int getNumChars() {
        return numChars;
    }

    /**
     * Returns the position of the strike-through line relative to the baseline.
     */
    public float getStrikethroughOffset() {
        return strikethroughOffset;
    }

    /**
     * Returns the thickness of the strike-through line.
     */
    public float getStrikethroughThickness() {
        return strikethroughThickness;
    }

    /**
     * Returns the position of the underline relative to the baseline.
     */
    public float getUnderlineOffset() {
        return underlineOffset;
    }

    /**
     * Returns the thickness of the underline.
     */
    public float getUnderlineThickness() {
        return underlineThickness;
    }

    /**
     * Returns the position of the overline relative to the baseline.
     */
    public float getOverlineOffset() {
        return overlineOffset;
    }

    /**
     * Returns the thickness of the overline.
     */
    public float getOverlineThickness() {
        return overlineThickness;
    }

}
