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

import org.apache.flex.forks.batik.util.SVGConstants;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: GVTFontFace.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GVTFontFace implements SVGConstants {
    protected String familyName;
    protected float unitsPerEm;
    protected String fontWeight;
    protected String fontStyle;
    protected String fontVariant;
    protected String fontStretch;
    protected float slope;
    protected String panose1;
    protected float ascent;
    protected float descent;
    protected float strikethroughPosition;
    protected float strikethroughThickness;
    protected float underlinePosition;
    protected float underlineThickness;
    protected float overlinePosition;
    protected float overlineThickness;

    /**
     * Constructes an GVTFontFace with the specfied font-face attributes.
     */
    public GVTFontFace
        (String familyName, float unitsPerEm, String fontWeight,
         String fontStyle, String fontVariant, String fontStretch,
         float slope, String panose1, float ascent, float descent,
         float strikethroughPosition, float strikethroughThickness,
         float underlinePosition,     float underlineThickness,
         float overlinePosition,      float overlineThickness) {
        this.familyName = familyName;
        this.unitsPerEm = unitsPerEm;
        this.fontWeight = fontWeight;
        this.fontStyle = fontStyle;
        this.fontVariant = fontVariant;
        this.fontStretch = fontStretch;
        this.slope = slope;
        this.panose1 = panose1;
        this.ascent = ascent;
        this.descent = descent;
        this.strikethroughPosition = strikethroughPosition;
        this.strikethroughThickness = strikethroughThickness;
        this.underlinePosition = underlinePosition;
        this.underlineThickness = underlineThickness;
        this.overlinePosition = overlinePosition;
        this.overlineThickness = overlineThickness;
    }

    /**
     * Constructs an SVGFontFace with default values for all the
     * font-face attributes other than familyName
     */
    public GVTFontFace(String familyName) {
        this(familyName, 1000, 
             SVG_FONT_FACE_FONT_WEIGHT_DEFAULT_VALUE,
             SVG_FONT_FACE_FONT_STYLE_DEFAULT_VALUE,
             SVG_FONT_FACE_FONT_VARIANT_DEFAULT_VALUE,
             SVG_FONT_FACE_FONT_STRETCH_DEFAULT_VALUE,
             0, SVG_FONT_FACE_PANOSE_1_DEFAULT_VALUE, 
             800, 200, 300, 50, -75, 50, 800, 50);
    }

    /**
     * Returns the family name of this font, it may contain more than one.
     */
    public String getFamilyName() {
        return familyName;
    }

    public boolean hasFamilyName(String family) {
        String ffname = familyName;
        if (ffname.length() < family.length()) {
            return false;
        }

        ffname = ffname.toLowerCase();

        int idx = ffname.indexOf(family.toLowerCase());

        if (idx == -1) {
            return false;
        }

        // see if the family name is not the part of a bigger family name.
        if (ffname.length() > family.length()) {
            boolean quote = false;
            if (idx > 0) {
                char c = ffname.charAt(idx - 1);
                switch (c) {
                default:
                    return false;
                case ' ':
                    loop: for (int i = idx - 2; i >= 0; --i) {
                        switch (ffname.charAt(i)) {
                        default:
                            return false;
                        case ' ':
                            continue;
                        case '"':
                        case '\'':
                            quote = true;
                            break loop;
                        }
                    }
                    break;
                case '"':
                case '\'':
                    quote = true;
                case ',':
                }
            }
            if (idx + family.length() < ffname.length()) {
                char c = ffname.charAt(idx + family.length());
                switch (c) {
                default:
                    return false;
                case ' ':
                    loop: for (int i = idx + family.length() + 1;
                         i < ffname.length(); i++) {
                        switch (ffname.charAt(i)) {
                        default:
                            return false;
                        case ' ':
                            continue;
                        case '"':
                        case '\'':
                            if (!quote) {
                                return false;
                            }
                            break loop;
                        }
                    }
                    break;
                case '"':
                case '\'':
                    if (!quote) {
                        return false;
                    }
                case ',':
                }
            }
        }
        return true;
    }

    /**
     * Returns the font-weight.
     */
    public String getFontWeight() {
        return fontWeight;
    }

    /**
     * Returns the font-style.
     */
    public String getFontStyle() {
        return fontStyle;
    }

    /**
     * The number of coordinate units on the em square for this font.
     */
    public float getUnitsPerEm() {
        return unitsPerEm;
    }

    /**
     * Returns the maximum unaccented height of the font within the font
     * coordinate system.
     */
    public float getAscent() {
        return ascent;
    }

    /**
     * Returns the maximum unaccented depth of the font within the font
     * coordinate system.
     */
    public float getDescent() {
        return descent;
    }

    /**
     * Returns the position of the strikethrough decoration.
     */
    public float getStrikethroughPosition() {
        return strikethroughPosition;
    }

    /**
     * Returns the stroke thickness to use when drawing a strikethrough.
     */
    public float getStrikethroughThickness() {
        return strikethroughThickness;
    }

    /**
     * Returns the position of the underline decoration.
     */
    public float getUnderlinePosition() {
        return underlinePosition;
    }

    /**
     * Returns the stroke thickness to use when drawing a underline.
     */
    public float getUnderlineThickness() {
        return underlineThickness;
    }

    /**
     * Returns the position of the overline decoration.
     */
    public float getOverlinePosition() {
        return overlinePosition;
    }

    /**
     * Returns the stroke thickness to use when drawing a overline.
     */
    public float getOverlineThickness() {
        return overlineThickness;
    }
}
