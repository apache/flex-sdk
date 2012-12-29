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

import java.awt.font.FontRenderContext;
import java.text.CharacterIterator;

/**
 * An interface for all GVT font classes.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: GVTFont.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public interface GVTFont {

    /**
     * Checks if this Font has a glyph for the specified character.
     */
    boolean canDisplay(char c);

    /**
     *  Indicates whether or not this Font can display the characters in the
     *  specified text starting at start and ending at limit.
     */
    int canDisplayUpTo(char[] text, int start, int limit);

    /**
     *  Indicates whether or not this Font can display the the characters in
     *  the specified CharacterIterator starting at start and ending at limit.
     */
    int canDisplayUpTo(CharacterIterator iter, int start, int limit);

    /**
     *  Indicates whether or not this Font can display a specified String.
     */
    int canDisplayUpTo(String str);

    /**
     *  Returns a new GlyphVector object created with the specified array of
     *  characters and the specified FontRenderContext.
     */
    GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            char[] chars);
    /**
     * Returns a new GlyphVector object created with the specified
     * CharacterIterator and the specified FontRenderContext.
     */
    GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            CharacterIterator ci);
    /**
     *  Returns a new GlyphVector object created with the specified integer
     *  array and the specified FontRenderContext.
     */
    GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            int[] glyphCodes,
                                            CharacterIterator ci);
    /**
     * Returns a new GlyphVector object created with the specified String and
     * the specified FontRenderContext.
     */
    GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            String str);

    /**
     * Creates a new Font object by replicating the current Font object and
     * applying a new size to it.
     */
    GVTFont deriveFont(float size);

    /**
     * Returns the font family name of this font.
     */
    String getFamilyName();

    /**
     *  Returns a GVTLineMetrics object created with the specified arguments.
     */
    GVTLineMetrics getLineMetrics(char[] chars, int beginIndex,
                                         int limit, FontRenderContext frc);

    /**
     * Returns a GVTLineMetrics object created with the specified arguments.
     */
    GVTLineMetrics getLineMetrics(CharacterIterator ci, int beginIndex,
                                         int limit, FontRenderContext frc);

    /**
     *  Returns a GVTLineMetrics object created with the specified String and
     *  FontRenderContext.
     */
    GVTLineMetrics getLineMetrics(String str, FontRenderContext frc);

    /**
     * Returns a GVTLineMetrics object created with the specified arguments.
     */
    GVTLineMetrics getLineMetrics(String str, int beginIndex, int limit,
                                         FontRenderContext frc);

    /**
     * Returns the size of this font.
     */
    float getSize();

    /**
     * Returns the horizontal kerning value of this glyph pair.
     */
    float getVKern(int glyphCode1, int glyphCode2);

    /**
     * Returns the vertical kerning value of this glyph pair.
     */
    float getHKern(int glyphCode1, int glyphCode2);

    String toString();
}
