/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.fonts;

import flash.swf.TagValues;
import flash.swf.builder.tags.FontBuilder;
import flash.swf.tags.DefineFont;
import flash.swf.tags.DefineFont3;
import flash.swf.types.GlyphEntry;
import flash.util.LRUCache;

import java.net.URL;
import java.util.Map;

/**
 * Provides a simple LRU caching mechanism for Font Manager implementations.
 *
 * A manager's caches and cache's members should be thread safe.
 *
 * @author Peter Farland
 */
@SuppressWarnings("unchecked")
public abstract class CachedFontManager extends FontManager
{
    public static final short PURGE_SIZE = 2;
    public static final float DEFAULT_FONT_SIZE = 240f; //12pt * 20 - authoring tool multiplies size by 20 to increase granularity in twips
    public static final Float DEFAULT_FONT_SIZE_OBJECT = new Float(DEFAULT_FONT_SIZE);
    public static final String DEFAULT_FONT_SIZE_STRING = "240";
	public static final String COMPATIBILITY_VERSION = "CompatibilityVersion";

    public static final String MAX_CACHED_FONTS_KEY = "max-cached-fonts";
    public static final String MAX_GLYPHS_PER_FACE_KEY = "max-glyphs-per-face";

    public short maxEntries = 20;
    public short maxGlyphsPerFace = 1000;
    public short maxFacesPerFont = 4; // Note that Flash only supports PLAIN, BOLD, ITALIC, and BOLD+ITALIC

    private FontCache fontCache;
    private FontFileCache fontFileCache;

    protected CachedFontManager()
    {
        super();
    }

    public void initialize(Map map)
    {
        super.initialize(map);

        if (map != null)
        {
            String prop = (String)map.get(MAX_CACHED_FONTS_KEY);
            if (prop != null)
            {
                try
                {
                    maxEntries = Short.parseShort(prop);
                }
                catch (Throwable t)
                {
                }
            }

            prop = (String)map.get(MAX_GLYPHS_PER_FACE_KEY);
            if (prop != null)
            {
                try
                {
                    maxGlyphsPerFace = Short.parseShort(prop);
                }
                catch (Throwable t)
                {
                }
            }
        }

        fontCache = new FontCache(this);
        fontFileCache = new FontFileCache(this);
    }

    public DefineFont createDefineFont(int tagCode, FontDescription font)
    {
        FontFace fontFace;
        boolean useTwips = (tagCode == TagValues.stagDefineFont3);
        if (font.source instanceof URL)
        {
            URL location = (URL)font.source;
            fontFace = getEntryFromLocation(location, font.style, useTwips);
            if (font.alias == null)
                font.alias = fontFace.getFamily();

            if (fontFace == null)
                FontManager.throwFontNotFound(font.alias, null, font.style, location.toString());
        }
        else
        {
            String fontFamily = font.source.toString();
            fontFace = getEntryFromSystem(fontFamily, font.style, useTwips);
            if (font.alias == null)
                font.alias = fontFace.getFamily();

            if (fontFace == null)
                FontManager.throwFontNotFound(font.alias, fontFamily, font.style, null);
        }

        FontBuilder builder = new FontBuilder(tagCode, fontFace, font.alias, font.advancedAntiAliasing);

        // Add characters for unicode-range
        int[][] ranges = getUnicodeRanges(font.unicodeRanges);
        if (ranges != null)
        {
            for (int i = 0; i < ranges.length; i++)
            {
                int[] range = ranges[i];
                if (range != null && range.length == 2)
                {
                    int count = range[1] - range[0] + 1; // Inclusive range
                    builder.addCharset(range[0], count);
                }
            }
        }
        else
        {
            builder.addAllChars();
        }

        return (DefineFont)builder.build();
    }

    public void loadDefineFont(DefineFont tag, Object location)
    {
        if (tag instanceof DefineFont3)
        {
            loadDefineFont3((DefineFont3)tag, location);
        }
    }

    protected void loadDefineFont3(DefineFont3 tag, Object location)
    {
        String family = null;
        String locationKey = null;

        if (location != null)
        {
            if (location instanceof URL)
                locationKey = ((URL)location).toExternalForm();
            else
                locationKey = location.toString();

            family = (String)getFontFileCache().get(locationKey);
        }

        if (family == null)
        {
            family = DefineFont3Face.getFamily(tag);

            if (locationKey != null)
                getFontFileCache().put(locationKey, family);
        }

        int style = DefineFont3Face.getStyle(tag);

        // Look for whether we've got a FontSet for this family...
        FontSet fontSet = (FontSet)getFontCache().get(family);
        if (fontSet == null)
        {
            fontSet = new FontSet(maxFacesPerFont);
            getFontCache().put(family, fontSet);
        }

        // Look to see whether we've got a FontFace for this style....
        FontFace face = fontSet.get(style);
        if (face == null)
        {
            face = new DefineFont3Face(tag);
            fontSet.put(style, face);
        }
        else
        {
            // We already have a FontFace for this style, if it's a
            // CachedFontFace, try to update the existing cache with any
            // extra glyphs present on this tag...
            if (face instanceof CachedFontFace)
            {
                CachedFontFace cachedFontFace = (CachedFontFace)face;
                char[] codepoints = tag.codeTable;
                if (codepoints != null)
                {
                    for (char i = 0; i < codepoints.length; i++)
                    {
                        char c = codepoints[i];
                        GlyphEntry ge = cachedFontFace.getGlyphEntry(c);
                        if (ge == null)
                        {
                            ge = DefineFont3Face.createGlyphEntryFromDefineFont(c, i, tag);
                            cachedFontFace.glyphCache.put(c, ge);
                        }
                    }
                }
            }
        }
    }
    
    protected FontCache getFontCache()
    {
        if (fontCache == null)
            initialize(null);

        return fontCache;
    }

    protected FontFileCache getFontFileCache()
    {
        if (fontFileCache == null)
            initialize(null);

        return fontFileCache;
    }

    protected abstract String createFontFromLocation(Object location, int style, boolean useTwips);
	protected abstract FontSet createSetForSystemFont(String family, int style, boolean useTwips);

    /**
     * A cache that maps font family names to a <code>FontSet</code> - a set
     * of derived styles from the base family font.
     */
    static class FontCache extends LRUCache
    {
        private static final long serialVersionUID = -2402480346505475961L;

        FontCache(CachedFontManager manager)
        {
            super(manager.maxEntries / 2, manager.maxEntries, PURGE_SIZE);
        }

        /**
         * We don't know whether we're looking by location or os family name, so
         * we fail fast and don't attempt to fetch.
         *
         * @param key the font family name
         * @return null
         */
        protected Object fetch(Object key)
        {
            return null;
        }
    }

    /**
     * A cache mapping a font file location to a family name. If the location
     * new, it will load the file to determine the family name and create an
     * entry in the main fontCache.
     */
    static class FontFileCache extends LRUCache
    {
        private static final long serialVersionUID = 5379979428987581921L;

        FontFileCache(CachedFontManager manager)
        {
            super(manager.maxEntries / 2, manager.maxEntries, PURGE_SIZE);
        }

        /**
         * We fail fast if we've not seen this location because
         * we don't know whether the location will match
         * requested style...
         *
         * @param key the location of the font file
         */
        protected Object fetch(Object key)
        {
            return null;
        }
    }
}
