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

import java.awt.Font;
import java.awt.Shape;
import java.awt.font.FontRenderContext;
import java.awt.font.GlyphMetrics;
import java.awt.font.GlyphVector;
import java.awt.font.TextAttribute;
import java.awt.geom.AffineTransform;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;
import java.text.CharacterIterator;
import java.text.StringCharacterIterator;
import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.gvt.text.ArabicTextHandler;


/**
 * This is a wrapper class for a java.awt.Font instance.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: AWTGVTFont.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AWTGVTFont implements GVTFont {

    protected Font  awtFont;
    protected float size;
    protected float scale;

    /**
     * Creates a new AWTGVTFont that wraps the given Font.
     *
     * @param font The font object to wrap.
     */
    public AWTGVTFont(Font font) {
        this.size = font.getSize2D();
        this.awtFont = font.deriveFont(FONT_SIZE);
        this.scale = size/awtFont.getSize2D();
        initializeFontCache(awtFont);
    }

    /**
     * Creates a new AWTGVTFont that wraps the given Font.
     *
     * @param font The font object to wrap.
     * @param scale The scale factor to apply to font...
     */
    public AWTGVTFont(Font font, float scale) {
        this.size = font.getSize2D()*scale;
        this.awtFont = font.deriveFont(FONT_SIZE);
        this.scale = size/awtFont.getSize2D();
        initializeFontCache(awtFont);
    }

    /**
     * Creates a new AWTGVTFont with the specified attributes.
     *
     * @param attributes Contains attributes of the font to create.
     */
    public AWTGVTFont(Map attributes) {
        Float sz = (Float)attributes.get(TextAttribute.SIZE);
        if (sz != null) {
            this.size = sz.floatValue();
            attributes.put(TextAttribute.SIZE, new Float(FONT_SIZE));
            this.awtFont = new Font(attributes);
        } else {
            this.awtFont = new Font(attributes);
            this.size = awtFont.getSize2D();
        }
        this.scale = size/awtFont.getSize2D();
        initializeFontCache(awtFont);
    }

    /**
     * Creates a new AWTGVTFont from the specified name, style and point size.
     *
     * @param name The name of the new font.
     * @param style The required font style.
     * @param size The required font size.
     */
    public AWTGVTFont(String name, int style, int size) {
        this.awtFont = new Font(name, style, (int)FONT_SIZE);
        this.size  = size;
        this.scale = size/awtFont.getSize2D();
        initializeFontCache(awtFont);
    }

    /**
     * Checks if this font can display the specified character.
     *
     * @param c The character to check.
     * @return Whether or not the character can be displayed.
     */
    public boolean canDisplay(char c) {
        return awtFont.canDisplay(c);
    }

    /**
     * Indicates whether or not this font can display the characters in the
     * specified text starting at start and ending at limit.
     *
     * @param text An array containing the characters to check.
     * @param start The index of the first character to check.
     * @param limit The index of the last character to check.
     *
     * @return The index of the first char this font cannot display. Will be
     * -1 if it can display all characters in the specified range.
     */
    public int canDisplayUpTo(char[] text, int start, int limit) {
        return awtFont.canDisplayUpTo(text, start, limit);
    }

    /**
     *  Indicates whether or not this font can display the the characters in
     *  the specified CharacterIterator starting at start and ending at limit.
     */
    public int canDisplayUpTo(CharacterIterator iter, int start, int limit) {
        return awtFont.canDisplayUpTo(iter, start, limit);
    }

    /**
     *  Indicates whether or not this font can display a specified String.
     */
    public int canDisplayUpTo(String str) {
        return awtFont.canDisplayUpTo(str);
    }

    /**
     *  Returns a new GlyphVector object created with the specified array of
     *  characters and the specified FontRenderContext.
     */
    public GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            char[] chars) {

        StringCharacterIterator sci =
            new StringCharacterIterator(new String(chars));
        GlyphVector gv = awtFont.createGlyphVector(frc, chars);
        return new AWTGVTGlyphVector(gv, this, scale, sci);
    }

    /**
     * Returns a new GlyphVector object created with the specified
     * CharacterIterator and the specified FontRenderContext.
     */
    public GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            CharacterIterator ci) {

        if (ci instanceof AttributedCharacterIterator) {
            AttributedCharacterIterator aci = (AttributedCharacterIterator)ci;
            if (ArabicTextHandler.containsArabic(aci)) {
                String str = ArabicTextHandler.createSubstituteString(aci);

                return createGlyphVector(frc, str);
            }
        }
        GlyphVector gv = awtFont.createGlyphVector(frc, ci);
        return new AWTGVTGlyphVector(gv, this, scale, ci);
    }

    /**
     *  Returns a new GlyphVector object created with the specified integer
     *  array and the specified FontRenderContext.
     */
    public GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            int[] glyphCodes,
                                            CharacterIterator ci) {
        return new AWTGVTGlyphVector
            (awtFont.createGlyphVector(frc, glyphCodes),
             this, scale, ci);
    }

    /**
     * Returns a new GlyphVector object created with the specified String and
     * the specified FontRenderContext.
     */
    public GVTGlyphVector createGlyphVector(FontRenderContext frc, String str)
    {

        StringCharacterIterator sci = new StringCharacterIterator(str);

        return new AWTGVTGlyphVector
            (awtFont.createGlyphVector(frc, str), this, scale, sci);
    }

    /**
     * Creates a new Font object by replicating the current Font object and
     * applying a new size to it.
     */
    public GVTFont deriveFont(float size) {
        return new AWTGVTFont(awtFont, size/this.size);
    }

    public String getFamilyName() {
        return awtFont.getFamily();
    }

    /**
     *  Returns a LineMetrics object created with the specified arguments.
     */
    public GVTLineMetrics getLineMetrics(char[] chars,
                                         int beginIndex,
                                         int limit,
                                         FontRenderContext frc) {
        return new GVTLineMetrics
            (awtFont.getLineMetrics(chars, beginIndex, limit, frc), scale);
    }

    /**
     * Returns a GVTLineMetrics object created with the specified arguments.
     */
    public GVTLineMetrics getLineMetrics(CharacterIterator ci,
                                         int beginIndex,
                                         int limit,
                                         FontRenderContext frc) {
        return new GVTLineMetrics
            (awtFont.getLineMetrics(ci, beginIndex, limit, frc), scale);
    }

    /**
     *  Returns a GVTLineMetrics object created with the specified String and
     *  FontRenderContext.
     */
    public GVTLineMetrics getLineMetrics(String str, FontRenderContext frc) {
        return new GVTLineMetrics(awtFont.getLineMetrics(str, frc), scale);
    }

    /**
     * Returns a GVTLineMetrics object created with the specified arguments.
     */
    public GVTLineMetrics getLineMetrics(String str,
                                         int beginIndex,
                                         int limit,
                                         FontRenderContext frc) {
        return new GVTLineMetrics
            (awtFont.getLineMetrics(str, beginIndex, limit, frc), scale);
    }

    /**
     * Returns the size of this font.
     */
    public float getSize() {
        return size;
    }

    /**
     * Returns the horizontal kerning value for this glyph pair.
     */
    public float getHKern(int glyphCode1, int glyphCode2) {
        return 0f;
    }

    /**
     * Returns the vertical kerning value for this glyph pair.
     */
    public float getVKern(int glyphCode1, int glyphCode2) {
        return 0f;
    }

    /////////////////////////////////////////////////////////////////////////

    public static final float FONT_SIZE = 48f;

    /**
     * Returns the geometry of the specified character. This method also put
     * the in cache the geometry associated to the specified character if
     * needed.
     */
    public static
        AWTGlyphGeometryCache.Value getGlyphGeometry(AWTGVTFont font,
                                                     char c,
                                                     GlyphVector gv,
                                                     int glyphIndex,
                                                     Point2D glyphPos) {

        AWTGlyphGeometryCache glyphCache =
            (AWTGlyphGeometryCache)fontCache.get(font.awtFont);

        AWTGlyphGeometryCache.Value v = glyphCache.get(c);
        if (v == null) {
            Shape outline = gv.getGlyphOutline(glyphIndex);
            GlyphMetrics metrics = gv.getGlyphMetrics(glyphIndex);
            Rectangle2D gmB = metrics.getBounds2D();
            if (AWTGVTGlyphVector.outlinesPositioned()) {
                AffineTransform tr = AffineTransform.getTranslateInstance
                    (-glyphPos.getX(), -glyphPos.getY());
                outline = tr.createTransformedShape(outline);
            }
            v = new AWTGlyphGeometryCache.Value(outline, gmB);
            //System.out.println("put "+font.awtFont+" "+c);
            glyphCache.put(c, v);
        }
        return v;
    }

    //
    // static cache for AWTGVTFont
    //

    static Map fontCache = new HashMap(11);

    static void initializeFontCache(Font awtFont) {
        if (!fontCache.containsKey(awtFont)) {
            fontCache.put(awtFont, new AWTGlyphGeometryCache());
        }
    }

    static void putAWTGVTFont(AWTGVTFont font) {
        fontCache.put(font.awtFont, font);
    }

    static AWTGVTFont getAWTGVTFont(Font awtFont) {
        return (AWTGVTFont)fontCache.get(awtFont);
    }

}

