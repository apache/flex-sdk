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

import java.net.URL;
import java.util.List;
import java.util.Properties;
import java.util.Map;
import java.util.StringTokenizer;

import flash.swf.tags.DefineFont;
import flash.util.Trace;

/**
 * The FontManager provides a common interface to locating fonts from
 * either locally (i.e. from the Operating System) or externally
 * (i.e. from URL locations).
 * 
 * @author Peter Farland
 */
@SuppressWarnings("unchecked")
public abstract class FontManager
{
    public static final String LOCAL_FONT_PATHS = "local-font-paths";

    public static final int PLAIN   = 0;
    public static final int BOLD    = 1;
    public static final int ITALIC  = 2;

    protected Properties languageRanges;
    protected FontManager parent;

    protected int majorCompatibilityVersion = 4;

    /**
     * Constructor
     */
    protected FontManager()
    {
    }

    /**
     * Initialization properties can be provided as name/value pairs.
     * 
     * @param map
     */
    public void initialize(Map map)
    {
        if (map != null)
        {
            String compatVersion = (String)map.get(CachedFontManager.COMPATIBILITY_VERSION);
            if (compatVersion != null)
            {
                String[] parts = compatVersion.split("\\.");
                if (parts.length > 0)
                {
                    try
                    {
                        int major = Integer.parseInt(parts[0]);
                        majorCompatibilityVersion = major;
                    }
                    catch (Throwable t)
                    {
                    }
                }
            }
        }
    }

    /**
     * Provides the ability to chain managers.
     * 
     * @param parent
     */
    public void setParent(FontManager parent)
    {
        this.parent = parent;
    }

    public void setLanguageRange(Properties languageRanges)
    {
        this.languageRanges = languageRanges;
    }

    /**
     * If a given language token is registered, the corresponding unicode range
     * (specified as a CSS-2 formatted string) is returned.
     * 
     * @param lang
     */
    public String getLanguageRange(String lang)
    {
        String range = null;

        if (languageRanges != null && lang != null)
            range = languageRanges.getProperty(lang);

        return range;
    }

    /**
     * Create a SWF DefineFont tag from a font file location specified as a URL.
     * 
     * @param tagCode Specifies the version of the DefineFont SWF tag to create.
     * @return A DefineFont tag
     */
    public DefineFont createDefineFont(int tagCode, FontDescription desc)
    {
        // No op
        return null;
    }

    /**
     * Attempts to load a font from the cache by location or from disk if it is
     * the first request at this address. The location is bound to a font family
     * name and defineFont type after the initial loading, and the relationship
     * exists for the lifetime of the cache.
     * 
     * @param location
     * @param style
     * @return FontSet.FontFace
     */
    public abstract FontFace getEntryFromLocation(URL location, int style,
            boolean useTwips);

    /**
     * Attempts to locate a font by family name, style, and defineFont type from
     * the runtime's list of fonts, which are primarily operating system
     * registered fonts.
     * 
     * @param familyName
     * @param style either FontFace.PLAIN, FontFace.BOLD, FontFace.ITALIC or
     *        FontFace.BOLD+FontFace.ITALIC
     * @return FontFace
     */
    public abstract FontFace getEntryFromSystem(String familyName, int style,
            boolean useTwips);

    /**
     * Allows a DefineFont SWF tag to be the basis of a FontFace.
     * 
     * @param tag The DefineFont tag
     * @param location The original location of the asset that created the
     *        DefineFont SWF tag.
     */
    public void loadDefineFont(DefineFont tag, Object location)
    {
        // No-op
    }

    /**
     * Allows a DefineFont SWF tag to be the basis of a FontFace.
     * 
     * @param tag The DefineFont tag.
     */
    public void loadDefineFont(DefineFont tag)
    {
        loadDefineFont(tag, null);
    }

    /**
     * Parses a String representation of Unicode character ranges into an array
     * of int arrays. e.g. U+0020-U+007F,U+20345. Note that int is used to
     * support code points beyond the BMP.
     * 
     * @param value String representation of unicode character ranges
     * @return int[][] Array of an array of ints representing code points of
     * the specified ranges.
     * @see http://www.w3.org/TR/REC-CSS2/fonts.html#descdef-unicode-range
     */
    public int[][] getUnicodeRanges(String value)
    {
        int[][] ranges = null;

        // Check if it's a registered language name
        String langRange = getLanguageRange(value);
        if (langRange != null)
            value = langRange;

        if (value != null)
        {
            // Remove extraneous formatting first
            value = value.replace(';', ' ').replace('\n', ' ').replace('\r', ' ').replace('\f', ' ');

            StringTokenizer st = new StringTokenizer(value, ",");

            int count = st.countTokens();
            ranges = new int[count][2];
            parseRanges(st, ranges);
        }

        return ranges;
    }

    public static boolean isItalic(int style)
    {
        return style == ITALIC || style == (BOLD + ITALIC);
    }

    public static boolean isBold(int style)
    {
        return style == BOLD || style == (BOLD + ITALIC);
    }

    /**
     * Given a list of class names, this utility method attempts to construct a
     * chain of FontManagers. The class must extend FontManager and have a
     * public no-args constructor. Invalid classes are skipped.
     * 
     * @param managerClasses
     * @return the last FontManager in the chain
     * @deprecated
     */
    public static FontManager create(List managerClasses, Map map)
    {
        return FontManager.create(managerClasses, map, null);
    }

    /**
     * Given a list of class names, this utility method attempts to construct a
     * chain of FontManagers. The class must extend FontManager and have a
     * public no-args constructor. Invalid classes are skipped.
     * 
     * @param managerClasses List of class names representing FontManager
     * implementations.
     * @param map A Map of settings to be passed to the FontManager instance
     * during initialization.
     * @param languageRanges List of unicode character ranges for a given
     * language.
     * @return the last FontManager in the chain
     */
    public static FontManager create(List managerClasses, Map map, Properties languageRanges)
    {
        FontManager manager = null;

        if (managerClasses != null)
        {
            for (int i = 0; i < managerClasses.size(); i++)
            {
                try
                {
                    Object className = managerClasses.get(i);
                    if (className != null)
                    {
                        Class clazz = Class.forName(className.toString());
                        Object obj = clazz.newInstance();
                        if (obj instanceof FontManager)
                        {
                            FontManager fm = (FontManager)obj;
                            fm.initialize(map);

                            if (manager != null)
                                fm.setParent(manager);

                            if (languageRanges != null)
                                fm.setLanguageRange(languageRanges);

                            manager = fm;
                        }
                    }
                }
                catch (Throwable t)
                {
                    if (Trace.font)
                    {
                        Trace.trace(t.getMessage());
                    }
                }
            }
        }

        return manager;
    }


    public static void throwFontNotFound(String alias, String fontFamily, int style, String location)
    {
        StringBuilder message = new StringBuilder("Font for alias '");
        message.append(alias).append("' ");
        if (style == FontFace.BOLD)
        {
            message.append("with bold weight ");
        }
        else if (style == FontFace.ITALIC)
        {
            message.append("with italic style ");
        }
        else if (style == (FontFace.BOLD + FontFace.ITALIC))
        {
            message.append("with bold weight and italic style ");
        }
        else
        {
            message.append("with plain weight and style ");
        }

        if (location != null)
        {
            message.append("was not found at: ").append(location.toString());
        }
        else
        {
            message.append("was not found by family name '").append(fontFamily).append("'");
        }
        throw new FontNotFoundException(message.toString());
    }

    /**
     * Values are expressed as hexadecimal numbers, prefixed with
     * &quot;U+&quot;. For single numbers, the character '?' is assumed to mean
     * 'any value' which creates a range of character positions. Otherwise, the
     * range can be specified explicitly using a hyphen, e.g. U+00A0-U+00FF
     * 
     * @param st
     * @param ranges
     */
    private static void parseRanges(StringTokenizer st, int[][] ranges)
    {
        int i = 0;
        while (st.hasMoreElements())
        {
            String element = ((String)st.nextElement()).trim().toUpperCase();

            if (element.startsWith("U+"))
            {
                String range = element.substring(2).trim();
                String low;
                String high;

                if (range.indexOf('?') > 0) // Wild-Card Range, e.g. U+00??
                {
                    low = range.replace('?', '0');
                    high = range.replace('?', 'F');
                }
                else if (range.indexOf('-') > 0) // Basic Range, e.g. U+0020-007E
                {
                    low = range.substring(0, range.indexOf('-'));
                    String temp = range.substring(range.indexOf('-') + 1).trim();

                    // Support Flex's legacy additional U+ prefix on the
                    // high range (but not part of the CSS-2 specification).
                    if (temp.startsWith("U+"))
                    {
                        high = temp.substring(2).trim();
                    }
                    else
                    {
                        high = temp;
                    }
                }
                else if (range.length() <= 8) // Single Char, e.g. U+0041
                {
                    low = range;
                    high = range;
                }
                else
                {
                    throw new InvalidUnicodeRangeException(range);
                }

                try
                {
                    ranges[i][0] = Integer.parseInt(low, 16);
                    ranges[i][1] = Integer.parseInt(high, 16);
                }
                catch (Exception ex)
                {
                    throw new InvalidUnicodeRangeException(range);
                }

                i++;
            }
            else if (element.length() == 0)
            {
                continue;
            }
            else
            {
                throw new InvalidUnicodeRangeException(element);
            }
        }
    }

    public static final class FontNotFoundException extends RuntimeException
    {
        private static final long serialVersionUID = -2385779348825570473L;

        public FontNotFoundException(String message)
        {
            super(message);
        }
    }

    public static final class InvalidUnicodeRangeException extends
            RuntimeException
    {
        private static final long serialVersionUID = 3173208110428813980L;

        public InvalidUnicodeRangeException(String range)
        {
            this.range = range;
        }

        public String range;
    }
}
