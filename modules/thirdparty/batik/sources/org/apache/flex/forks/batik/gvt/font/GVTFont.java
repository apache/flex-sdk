/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.gvt.font;

import java.awt.font.FontRenderContext;
import java.text.CharacterIterator;

/**
 * An interface for all GVT font classes.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: GVTFont.java,v 1.9 2004/08/18 07:14:35 vhardy Exp $
 */
public interface GVTFont {

    /**
     * Checks if this Font has a glyph for the specified character.
     */
    public boolean canDisplay(char c);

    /**
     *  Indicates whether or not this Font can display the characters in the
     *  specified text starting at start and ending at limit.
     */
    public int canDisplayUpTo(char[] text, int start, int limit);

    /**
     *  Indicates whether or not this Font can display the the characters in
     *  the specified CharacterIterator starting at start and ending at limit.
     */
    public int canDisplayUpTo(CharacterIterator iter, int start, int limit);

    /**
     *  Indicates whether or not this Font can display a specified String.
     */
    public int canDisplayUpTo(String str);

    /**
     *  Returns a new GlyphVector object created with the specified array of
     *  characters and the specified FontRenderContext.
     */
    public GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            char[] chars);
    /**
     * Returns a new GlyphVector object created with the specified
     * CharacterIterator and the specified FontRenderContext.
     */
    public GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            CharacterIterator ci);
    /**
     *  Returns a new GlyphVector object created with the specified integer
     *  array and the specified FontRenderContext.
     */
    public GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            int[] glyphCodes,
                                            CharacterIterator ci);
    /**
     * Returns a new GlyphVector object created with the specified String and
     * the specified FontRenderContext.
     */
    public GVTGlyphVector createGlyphVector(FontRenderContext frc,
                                            String str);

    /**
     * Creates a new Font object by replicating the current Font object and
     * applying a new size to it.
     */
    public GVTFont deriveFont(float size);

    /**
     *  Returns a GVTLineMetrics object created with the specified arguments.
     */
    public GVTLineMetrics getLineMetrics(char[] chars, int beginIndex,
                                         int limit, FontRenderContext frc);

    /**
     * Returns a GVTLineMetrics object created with the specified arguments.
     */
    public GVTLineMetrics getLineMetrics(CharacterIterator ci, int beginIndex,
                                         int limit, FontRenderContext frc);

    /**
     *  Returns a GVTLineMetrics object created with the specified String and
     *  FontRenderContext.
     */
    public GVTLineMetrics getLineMetrics(String str, FontRenderContext frc);

    /**
     * Returns a GVTLineMetrics object created with the specified arguments.
     */
    public GVTLineMetrics getLineMetrics(String str, int beginIndex, int limit,
                                         FontRenderContext frc);

    /**
     * Returns the size of this font.
     */
    public float getSize();

    /**
     * Returns the horizontal kerning value of this glyph pair.
     */
    public float getVKern(int glyphCode1, int glyphCode2);

    /**
     * Returns the vertical kerning value of this glyph pair.
     */
    public float getHKern(int glyphCode1, int glyphCode2);

    public String toString();
}
