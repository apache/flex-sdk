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

package flash.css;

import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.Transcoder;
import flex2.compiler.media.FontTranscoder;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.ThreadLocalToolkit;
import flash.fonts.FontFace;
import flash.util.Trace;
import org.w3c.css.sac.CSSException;
import org.w3c.css.sac.LexicalUnit;

import java.util.*;

/**
 * Represents an @font-face {} CSS rule. These rules are used to embed
 * font definitions into SWFs.
 *
 * The rule must be initialized with a StyleParser before it can be
 * used to turn the Rule into a DefineFont2 SWF tag.
 *
 * @author Peter Farland
 */
public class FontFaceRule extends Rule
{
    private String family = null;
    private int style = -1;
    
    /**
     * List<{LocalSource,URLSource}>
     */
    private List<Object> locations = null;
    
    /**
     * String->{String, List<URLSource>, List<LocalSource>}
     */
    private Map<String, Object> embedParams = null;

    public FontFaceRule(String path, int lineNumber)
    {
        super(Rule.FONT_FACE_RULE, path, lineNumber);
        this.declaration = new StyleDeclaration(path, lineNumber);
    }

    public Map<String, Object> getEmbedParams()
    {
        return embedParams;
    }

    /**
     * This method validates the specified family and style information and
     * attempts to pre-load the font before the DefineFont2 tag can be built.
     *
     * @param parser The current style parser.  This is only used to report a warning for
     *               any ignored descriptors.  See checkForIgnoredDescriptors().
     */
    public void initialize(StyleParser parser)
    {
        String alias = getFamily();
        List<Object> locations = getLocations();

        embedParams = new HashMap<String, Object>();
        embedParams.put(Transcoder.MIMETYPE, "application/x-font");
        if (locations == null && alias != null)
        {
            embedParams.put( FontTranscoder.FONTNAME, alias );
	        // systemfont change, remove below
            embedParams.put( FontTranscoder.SYSTEMFONT, alias );
        }
        else if (alias != null)
        {
            embedParams.put( FontTranscoder.FONTNAME, alias );
            if (locations.size() == 1)
            {
                Object source = locations.get(0);
                if (source instanceof URLSource)
                {
                    URLSource urlSource = (URLSource) source;
                    embedParams.put( Transcoder.SOURCE, urlSource.getValue() );
                    if (urlSource.getValue().toLowerCase().endsWith( ".swf" ))
                    {
                        embedParams.put( Transcoder.MIMETYPE, MimeMappings.FLASH );
                    }
                }
                else // if (locations.get(0) instanceof LocalSource)
                {
                    LocalSource localSource = (LocalSource) source;
                    embedParams.put( FontTranscoder.SYSTEMFONT, localSource.getValue() );
                }
            }
            else
            {
                embedParams.put( FontTranscoder.SOURCELIST, locations );
            }
        }

        String unicodeRange = getUnicodeRange();

        if (unicodeRange != null)
        {
            embedParams.put( FontTranscoder.UNICODERANGE, unicodeRange );
        }

	    String flashType = getFlashType();
	    if (flashType != null)
	    {
		    embedParams.put(FontTranscoder.ADVANTIALIASING, flashType);
	    }

	    String cff = getCompactFontFormat();
	    if (cff != null)
	    {
	        embedParams.put(FontTranscoder.EMBEDASCFF, cff);
	    }

        checkForIgnoredDescriptors(parser);

        if (isBold())
            embedParams.put( FontTranscoder.FONTWEIGHT, "bold" );
        if (isItalic())
            embedParams.put( FontTranscoder.FONTSTYLE,  "italic" );

        if (Trace.font)
            Trace.trace("@fontface rule parsed for family '" + alias + "'");

        // todo - Record FILE and LINE?
    }

	/**
     * The font-family is used as an alias to bind the embedded DefineFont2 tag with a
     * corresponding DefineEditText. This binding may be applied at runtime via
     * deferred instantiation using the ActionScript TextFormat API.
     */
    public String getFamily()
    {
        if (family == null)
        {
            Descriptor f = declaration.getDescriptorValue("font-family");

            if (f == null)
            {
                // [preilly] This is required to be consistent with the other descriptor
                // names which we allow to be hyphenated or camel case.
                f = declaration.getDescriptorValue("fontFamily");
            }

            if (f != null)
                family = f.getIdentAsString(); //TODO: This MUST NOT be null.
        }

        return family;
    }

    /**
     * This class parses the values for the src descriptor in a font-face rule.
     * It is required for referencing actual font data, whether downloadable or
     * locally installed.
     * <p>
     *
     * <code>
     * src: local("T-26 Typeka Mix"), url("fonts/magda-extra")
     * </code>
     * </p>
     *
     * @return List<{LocalSource,URLSource}>, a list of locations to search for font data
     */
    public List<Object> getLocations()
    {
        if (locations == null)
        {
            Descriptor src = declaration.getDescriptorValue("src");
            List<Object> result = null;

            if (src != null)
            {
                LexicalUnit lu = src.getValue();
                result = new ArrayList<Object>(2);

                while (lu != null)
                {
                    if (lu.getLexicalUnitType() == LexicalUnit.SAC_FUNCTION) //local("...")
                    {
                        result.add(new LocalSource(lu.getParameters().getStringValue().trim()));
                    }
                    else if (lu.getLexicalUnitType() == LexicalUnit.SAC_URI) //url("...")
                    {
                        result.add(new URLSource(lu.getStringValue()));
                    }

                    lu = lu.getNextLexicalUnit();
                }
            }

            locations = result;
        }

        return locations;
    }

    /**
     * This method attempts to map CSS font-styles and font-weights to java.awt.Font styles.
     * Only the first style and weight in a list is considered as java will always
     * attempt to derive a style in a font, even if it is not supported.
     *
     * The default style will be plain, which is equivalent to &quot;normal&quot; in CSS.
     */
    public String formatFontStyle()
    {
        Descriptor s = declaration.getDescriptorValue("font-style");

        if (s == null)
        {
            s = declaration.getDescriptorValue("fontStyle");
        }

        return (s == null)? "" : "fontStyle='" + s + "'";
    }

    public String formatFontWeight()
    {
        Descriptor w = declaration.getDescriptorValue("font-weight");

        if (w == null)
        {
            w = declaration.getDescriptorValue("fontWeight");
        }

        return (w == null)? "" : "fontWeight='" + w + "'";
    }

    public int getFontStyle()
    {
        if (style < 0)
        {
            style = FontFace.PLAIN; //Default to plain

            Descriptor s = declaration.getDescriptorValue("font-style");

            if (s == null)
            {
                s = declaration.getDescriptorValue("fontStyle");
            }

            Descriptor w = declaration.getDescriptorValue("font-weight");

            if (w == null)
            {
                w = declaration.getDescriptorValue("fontWeight");
            }

            if (s != null)
            {
                StringTokenizer styles = new StringTokenizer(s.getIdentAsString(), ",");

                //Examine the first token only, as Java matches any style
                String thisStyle = ((String)styles.nextElement()).trim().toLowerCase();

                if (isItalic(thisStyle))
                    style += FontFace.ITALIC;
            }

            if (w != null)
            {
                StringTokenizer weights = new StringTokenizer(w.getIdentAsString(), ",");

                //Examine the first token only, as Java matches any style
                String thisWeight = ((String)weights.nextElement()).trim().toLowerCase();

                if (isBold(thisWeight))
                    style += FontFace.BOLD;
            }
        }

        return style;
    }

    public boolean isBold()
    {
        if (style < 0)
            getFontStyle();

        return style == FontFace.BOLD || style == (FontFace.BOLD + FontFace.ITALIC);
    }

    public boolean isItalic()
    {
        if (style < 0)
            getFontStyle();

        return style == FontFace.ITALIC || style == (FontFace.BOLD + FontFace.ITALIC);
    }

    /**
     * Determines whether a CSS font-style descriptor is specifying an ITALIC font.
     * Styles specified as &quot;italic&quot; or &quot;oblique&quot; will be
     * interpreted as true.
     *
     * @param value
     */
    public static boolean isItalic(String value)
    {
        boolean italic = false;

        if (value != null)
        {
            String ital = value.trim().toLowerCase();
            if (ital.startsWith( "\"" ))
            {
                ital = ital.substring( 1 );
                if (ital.endsWith( "\"" ))
                    ital = ital.substring( 0, ital.length() - 1 );
            }
            if (ital.equals("italic") || ital.equals("oblique"))
                italic = true;
        }

        return italic;
    }

    /**
     * Determines whether a CSS font-weight descriptor is specifying a BOLD font.
     * Weights specified as integers will be interpreted as bold for values equal to or
     * greater than 700.
     *
     * @param value
     */
    public static boolean isBold(String value)
    {
        boolean bold = false;

        if (value != null)
        {
            String b = value.trim().toLowerCase();
            if (b.startsWith( "\"" ))
            {
                b = b.substring( 1 );
                if (b.endsWith( "\"" ))
                    b = b.substring( 0, b.length() - 1 );
            }

            if (b.startsWith("bold"))
            {
                bold = true;
            }
            else
            {
                try
                {
                    int w = Integer.parseInt(b);
                    if (w >= 700)
                        bold = true;
                }
                catch (Throwable t)
                {
                }
            }
        }

        return bold;
    }

    /**
     * Unicode ranges allow the user to specify ranges of characters to embed for a given Font.
     * The range is restricted to the Basic Multilingual Plane (BMP), which sets character codepoints
     * between U+0000 and U+FFFF, because a Java char primitive is restricted to this range.
     *
     * <p>
     * <code>
     * unicode-range: U+AC00-U+D7FF
     * </code>
     * </p>
     */
    public String getUnicodeRange()
    {
        Descriptor property = declaration.getDescriptorValue("unicode-range");
        if (property == null)
        {
	        property = declaration.getDescriptorValue("unicodeRange");
        }

	    if (property != null)
	    {
            String unicodeRange = property.getIdentAsString();

            // A single unicode character makes Batik freak out.  Work around it:
            unicodeRange = unicodeRange.trim();
            int semicolon = unicodeRange.indexOf(";");
            if (semicolon != -1)
            {
                unicodeRange = unicodeRange.substring( 0, semicolon );
            }
            return unicodeRange;
        }
        return null;
    }


    private String getFlashType()
    {
        String flashType = null;
        Descriptor flashTypeDesc = declaration.getDescriptorValue("advanced-anti-aliasing");
        
        if (flashTypeDesc == null)
        {
            flashTypeDesc = declaration.getDescriptorValue("advancedAntiAliasing");
        }
        
        if (flashTypeDesc == null)
        {
            flashTypeDesc = declaration.getDescriptorValue("flash-type");
        }
        
        if (flashTypeDesc == null)
        {
            flashTypeDesc = declaration.getDescriptorValue("flashType");
        }

        if (flashTypeDesc != null)
        {
            flashType = flashTypeDesc.getIdentAsString();
        }
        return flashType;
    }

    private String getCompactFontFormat()
    {
        String cff = null;

        Descriptor cffDesc = declaration.getDescriptorValue(FontTranscoder.EMBEDASCFF);
        // Check for alternate CSS-like form 'embed-as-cff'
        if (cffDesc == null)
            cffDesc = declaration.getDescriptorValue("embed-as-cff");

        if (cffDesc != null)
            cff = cffDesc.getIdentAsString();

        return cff;
    }
    
    
    private void checkForIgnoredDescriptors(StyleParser parser)
    {
        String descriptor = null;

        if (declaration.getDescriptorValue("font-size") != null)
        {
            descriptor = "font-size";
        }
        else if (declaration.getDescriptorValue("fontSize") != null)
        {
            descriptor = "fontSize";
        }
        else if (declaration.getDescriptorValue("panose-1") != null)
        {
            descriptor = "panose-1";
        }
        else if (declaration.getDescriptorValue("stemv") != null)
        {
            descriptor = "stemv";
        }
        else if (declaration.getDescriptorValue("stemh") != null)
        {
            descriptor = "stemh";
        }
        else if (declaration.getDescriptorValue("slope") != null)
        {
            descriptor = "slope";
        }
        else if (declaration.getDescriptorValue("cap-height") != null)
        {
            descriptor = "cap-height";
        }
        else if (declaration.getDescriptorValue("capHeight") != null)
        {
            descriptor = "capHeight";
        }
        else if (declaration.getDescriptorValue("x-height") != null)
        {
            descriptor = "x-height";
        }
        else if (declaration.getDescriptorValue("xHeight") != null)
        {
            descriptor = "xHeight";
        }
        else if (declaration.getDescriptorValue("ascent") != null)
        {
            descriptor = "ascent";
        }
        else if (declaration.getDescriptorValue("descent") != null)
        {
            descriptor = "descent";
        }
        else if (declaration.getDescriptorValue("widths") != null)
        {
            descriptor = "widths";
        }
        else if (declaration.getDescriptorValue("bbox") != null)
        {
            descriptor = "bbox";
        }
        else if (declaration.getDescriptorValue("definition-src") != null)
        {
            descriptor = "definition-src";
        }
        else if (declaration.getDescriptorValue("definitionSrc") != null)
        {
            descriptor = "definitionSrc";
        }
        else if (declaration.getDescriptorValue("baseline") != null)
        {
            descriptor = "baseline";
        }
        else if (declaration.getDescriptorValue("centerline") != null)
        {
            descriptor = "centerline";
        }
        else if (declaration.getDescriptorValue("mathline") != null)
        {
            descriptor = "mathline";
        }
        else if (declaration.getDescriptorValue("topline") != null)
        {
            descriptor = "topline";
        }

        if (descriptor != null)
        {
            IgnoredDescriptor ignoredDescriptor = new IgnoredDescriptor(descriptor);

            String text = ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString(ignoredDescriptor);

            parser.warning(new CSSException(CSSException.SAC_UNSPECIFIED_ERR, text, null));
        }
    }

	/**
	 *
	 */
	public static FontFaceRule getRule(Collection<FontFaceRule> rules, String family, boolean bold, boolean italic)
	{
		Iterator<FontFaceRule> it = rules.iterator();
		while (it.hasNext())
		{
			FontFaceRule ffr = it.next();
			if (family.equals(ffr.getFamily()))
			{
				if (bold != ffr.isBold())
					continue;

				if (italic != ffr.isItalic())
					continue;

				return ffr;
			}
		}

		return null;
	}

	/*
	public static boolean hasFamily(Collection<FontFaceRule> rules, String family)
	{
		Iterator<FontFaceRule> it = rules.iterator();
		while (it.hasNext())
		{
			FontFaceRule ffr = it.next();
			if (family.equals(ffr.getFamily()))
			{
				return true;
			}
		}

		return false;
	}
     */

    public static class IgnoredDescriptor extends CompilerError
    {
        private static final long serialVersionUID = -4627590989999828547L;
        public String descriptor;

        public IgnoredDescriptor(String descriptor)
        {
            this.descriptor = descriptor;
        }
    }

    public static class UnicodeRangeNotSupported extends CompilerError
    {

        private static final long serialVersionUID = -7817266835618855999L;
    }
}
