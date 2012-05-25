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

import flash.swf.builder.types.PathIteratorWrapper;
import flash.swf.builder.types.ShapeBuilder;
import flash.swf.types.GlyphEntry;
import flash.swf.types.Shape;
import flash.swf.SwfConstants;
import flash.util.Trace;

import java.awt.font.FontRenderContext;
import java.awt.font.GlyphMetrics;
import java.awt.font.GlyphVector;
import java.awt.font.TextAttribute;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.awt.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.BufferedInputStream;
import java.net.URL;
import java.util.Locale;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * The <code>JREFontManager</code> attempts to optimize the loading of
 * JDK fonts through caching of <code>FontSet</code>s. A
 * <code>FontSet</code> keeps track of the different styles (faces)
 * for a given font family as <code>FontFace</code> instances. A
 * manager can derive available styles from a single
 * <code>FontFace</code> through its reference to a
 * <code>java.awt.Font</code> object.
 *
 * @author Peter Farland
 */
@SuppressWarnings("unchecked")
public class JREFontManager extends CachedFontManager
{
    private boolean readLocalFonts;
    private Map<String, LocalFont> localFonts;
    public static String LOCAL_FONTS_SNAPSHOT = "flex.fonts-snapshot";
    private String localFontsFile;

    public void initialize(Map map)
    {
        super.initialize(map);
        if (map != null)
        {
            localFontsFile = (String)map.get(LOCAL_FONTS_SNAPSHOT);
        }
        if (localFontsFile == null)
        {
            localFontsFile = "localFonts.ser";
        }
    }

    protected String createFontFromLocation(Object location, int requestedStyle, boolean useTwips)
    {
        String family = null;
        InputStream is = null;

        try
        {
            if (location != null && location instanceof URL)
            {
                URL url = (URL)location;

                if (url.getProtocol().toLowerCase().indexOf("file") > -1)
                {
                    File f = new File(url.getFile());
                    // Do NOT buffer this stream, Font.createFont() does it for us.
                    is = new FileInputStream(f);
                }
                else
                {
                    is = url.openStream();
                }

                Font font = Font.createFont(Font.TRUETYPE_FONT, is);

                // Get the family and fontName info before we derive a new size as
                // the name might be reset to dialog!
                family = font.getFamily();
                String fontName = font.getFontName(Locale.ENGLISH);

                // Prior to Flex 4 we tried to validate that the requested style
                // matched the style of the font.
                if (majorCompatibilityVersion < 4)
                {
                    // We need to examine the name for the real style as
                    // Font.createFont always sets style to PLAIN and the user
                    // may have given us the wrong style info
                    int guessedStyle = CachedFontFace.guessStyleFromSubFamilyName(fontName);

                    // Only bother deriving a font and storing the work if this
                    // really was the style requested
                    if (requestedStyle != guessedStyle)
                        return null;
                }

                // Now that we've processed the font with the JRE font manager, we now need to get the fsType
                // and copyright info from from Batik.  This is a bit strange, as one of the advantages of the
                // JRE font manager is that it can process some fonts that Batik cannot.  This check is needed,
                // though, anytime we create a font.  So it may mean we don't need the JRE font manager anymore,
                // but since I'm not sure of that, it'll be kept in for awhile.
                String locationStr = BatikFontManager.processLocation(location);
                org.apache.flex.forks.batik.svggen.font.Font batikFont = org.apache.flex.forks.batik.svggen.font.Font.create(locationStr);
                if (batikFont == null)
                {
                    throw new FontFormatException ("Unable to create font." );
                }
                FSType type = FSType.getFSType(batikFont);
                if (! type.usableByFlex)
                {
                    throw new BatikFontManager.UnusableFontLicense(location + "", type.description);
                }
                String copyright = batikFont.getNameTable().getRecord((short)0);
                String trademark = batikFont.getNameTable().getRecord((short)7);

                // Set to a default size so metrics are established
                // getAttributes() returns a Map which is based on a Hashtable of <Obj,Obj>, or <TA,Obj> in practice
                // we need to suppress the cast because getAttributes defines the return type as <TA,?> 
                Map<TextAttribute, Object> attributes = (Map<TextAttribute, Object>) font.getAttributes();

                attributes.put(TextAttribute.FAMILY, family);
                attributes.put(TextAttribute.SIZE, DEFAULT_FONT_SIZE_OBJECT);
                attributes.put(TextAttribute.POSTURE, CachedFontFace.isItalic(requestedStyle) ? TextAttribute.POSTURE_OBLIQUE : TextAttribute.POSTURE_REGULAR);
                attributes.put(TextAttribute.WEIGHT, CachedFontFace.isBold(requestedStyle) ? TextAttribute.WEIGHT_BOLD : TextAttribute.WEIGHT_REGULAR);

                font = font.deriveFont(attributes);

                FontSet fontSet = (FontSet)getFontCache().get(family);
                if (fontSet == null)
                {
                    fontSet = new FontSet(maxFacesPerFont);
                    getFontCache().put(family, fontSet);
                }

                fontSet.put(requestedStyle, new JREFontFace(font, requestedStyle, maxGlyphsPerFace, type, copyright, trademark, useTwips));
            }
        }
        catch (FileNotFoundException ex)
        {
            return null;
        }
        catch (FontFormatException ex)
        {
            return null;
        }
        catch (IOException ex)
        {
            return null;
        }
        finally
        {
            try
            {
                is.close();
            }
            catch (Throwable t)
            {
            }
        }

        return family;
    }

    /**
     * Attempts to load a font from the cache by location or from disk if it is the first
     * request at this address. The location is bound to a font family name after the initial
     * loading, and the relationship exists for the lifetime of the cache.
     *
     * @param location
     * @param style
     * @return FontSet.FontFace
     */
    public FontFace getEntryFromLocation(URL location, int style, boolean useTwips)
    {
        FontFace entry = null;
        Object fam = getFontFileCache().get(location);

        if (fam == null)
        {
            fam = createFontFromLocation(location, style, useTwips);
        }

        if (fam != null)
        {
            String family = fam.toString();

            FontSet fontSet = (FontSet)getFontCache().get(family);

            // The font file cache should still have this family
            // from the location fetch above...
            if (fontSet != null)
            {
                entry = fontSet.get(style);
            }
        }

        return entry;
    }

    private static ArrayList<String> systemFontNames = null;

    protected FontSet createSetForSystemFont(String family, int style, boolean useTwips)
    {
        FontSet fontSet = null;
        if (family != null)
        {
            if (systemFontNames == null)
                initializeSystemFonts();

            if (systemFontNames != null && !systemFontNames.contains(family.trim().toLowerCase()))
            {
                if (Trace.font)
                    Trace.trace("Font family '" + family + "' not known to JRE.");

                return null;
            }

            //Load a font by family and style, set size to 240 for greater granularity
            Font font = Font.decode(family + "-" + getStyleAsString(style) + "-" + DEFAULT_FONT_SIZE_STRING);

            fontSet = new FontSet(maxFacesPerFont);
            fontSet.put(font.getStyle(), new JREFontFace(font, font.getStyle(), maxGlyphsPerFace, null, null, null, useTwips));
        }
        return fontSet;
    }

    /**
     * Attempts to locate a font by family name and style from the JRE's list of
     * fonts, which are primarily system registered fonts.
     *
     * @param familyName
     * @param style      - either Font.PLAIN, Font.BOLD, Font.ITALIC or Font.BOLD+Font.ITALIC
     * @return FontSet.FontFace
     */
    public FontFace getEntryFromSystem(String familyName, int style, boolean useTwips)
    {
        if (! readLocalFonts)
          {
              readLocalFonts();
          }

        FontFace entry = null;

        FontSet fontSet = (FontSet)getFontCache().get(familyName);

        // This is likely to be the first time looking for this family
        if (fontSet == null)
        {
            fontSet = createSetForSystemFont(familyName, style, useTwips);
        }

        // If the family was invalid on the OS there's nothing more we can do here
        if (fontSet != null)
        {
            entry = fontSet.get(style);
        }

        if (entry != null)
        {
            LocalFont font = localFonts.get(entry.getPostscriptName());
            if (font == null)
            {
                // silent failure
                if (Trace.font)
                {
                    Trace.trace("Information on font " + familyName + " could not be found.  Run FontSnapshot to get a list of the current local fonts.");
                }
            }
            else
            {
                entry.setCopyright(font.copyright);
                entry.setTrademark(font.trademark);
                entry.setFSType(FSType.getFSType(font.fsType));
            }
        }

        return entry;
    }

	private void readLocalFonts()
    {
        readLocalFonts = true;

        localFonts = new HashMap<String, LocalFont>();
//		initDefaultLocalFonts();
        try
        {
            InputStream buffStream = new BufferedInputStream(new FileInputStream(localFontsFile));
            ObjectInputStream in = new ObjectInputStream(buffStream);
            
            // there's no way around suppressing the cast warning from Object, the types get erased anyway
            Map<String, LocalFont> customLocalFonts = (Map<String, LocalFont>)in.readObject();
            
            localFonts.putAll(customLocalFonts);
        }
        catch(FileNotFoundException fnfe)
        {
            // ignore... a message will be printed out later if needed
            if (Trace.font)
            {
                fnfe.printStackTrace();
            }
        }
        catch(Exception fnfe)
        {
            if (Trace.font)
            {
                Trace.trace("Could not read localFonts.ser: " + fnfe);
            }
        }
    }

    private String getStyleAsString(int style)
    {
        String styleName;

        switch (style)
        {
            case 1:
                styleName = "bold";
                break;
            case 2:
                styleName = "italic";
                break;
            case 3:
                styleName = "bolditalic";
                break;
            default:
                styleName = "plain";
        }

        return styleName;
    }

    private static void initializeSystemFonts()
    {
        GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
        String[] fnts = ge.getAvailableFontFamilyNames();

        if (fnts != null)
        {
            systemFontNames = new ArrayList<String>(fnts.length);
            for (int i = 0; i < fnts.length; i++)
            {
                systemFontNames.add(fnts[i].trim().toLowerCase());
            }
        }
    }

    public static class JREFontFace extends CachedFontFace
    {
	    // FIXME: need to deal with useTwips differently for caching

        public JREFontFace(Font font, int style, int maxGlyph, FSType fsType, String copyright, String trademark, boolean useTwips)
        {
            super(maxGlyph, style, fsType, copyright, trademark, useTwips);
            this.font = font;
            init();
        }

        private void init()
        {
            //Convert from device to grid co-ordinates, fixed at 72dpi
            emScale = SWF_EM_SQUARE / getPointSize(); //If you want to correct for resolution, multiply this value by 72/resolution

            scaleTransform = new AffineTransform();
            scaleTransform.setToScale(emScale, emScale);

            //We use a BufferedImage to get to the system FontMetrics...
            //Feel free to suggest a better way of getting this object.
            if (graphics == null)
            {
                BufferedImage bi = new BufferedImage(50, 50, BufferedImage.TYPE_INT_RGB);
                graphics = bi.createGraphics();
                graphics.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
                graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            }

            fontMetrics = graphics.getFontMetrics(font);
            frc = new FontRenderContext(null, true, false);

            ascent = (int)Math.rint(fontMetrics.getAscent() * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));
            descent = (int)Math.rint(fontMetrics.getDescent() * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));

            //Ignore JDK leading values, they never match Flash MX - using an estimation technique similar to Breeze instead.
            //leading = (int)StrictMath.rint(fontMetrics.getLeading() * emScale);
            //if (leading == 0)
            lineGap = (int)Math.rint(Math.abs((getPointSize() - ascent - descent)));
        }

        public boolean canDisplay(char c)
        {
            return font.canDisplay(c);
        }

        public String getFamily()
        {
            return font.getName();
        }

        public int getFirstChar()
        {
            return 0;
        }

        public GlyphEntry getGlyphEntry(char c)
        {
            return (GlyphEntry)glyphCache.get(c);
        }

        protected GlyphEntry createGlyphEntry(char c)
        {
            return createGlyphEntry(c, c);
        }

        public GlyphEntry createGlyphEntry(char c, char referenceChar)
        {
            Shape swfShape = null;
            int advance = 0;

            GlyphVector gv = font.createGlyphVector(frc, new char[]{referenceChar});
            java.awt.Shape glyphOutline = gv.getGlyphOutline(0);

            GlyphMetrics metrics = gv.getGlyphMetrics(0);
            advance = (int)Math.rint(metrics.getAdvance()); //Do not scale here, DefineText needs values unscaled

            java.awt.Shape scaledShape = scaleTransform.createTransformedShape(glyphOutline);
            swfShape = createGlyphShape(scaledShape);

            GlyphEntry ge = new GlyphEntry();
            ge = new GlyphEntry(); //Note: we will set the index on building DefineFont2 tag
            ge.advance = (int)(advance * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));
            ge.shape = swfShape;
	        //Glyph bounds are not used by the Flash Player so no need to calculate
	        //Rectangle2D bs = scaledShape.getBounds2D();
	        //bounds = new Rect((int)StrictMath.rint(bs.getMinX() * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1)),
			//        (int)StrictMath.rint(bs.getMaxX() * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1)),
			//        (int)StrictMath.rint(bs.getMinY() * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1)),
			//        (int)StrictMath.rint(bs.getMaxY()) * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));
            //ge.bounds = bounds;
            ge.character = c;

            return ge;
        }

        private Shape createGlyphShape(java.awt.Shape outline)
        {
            ShapeBuilder shape = new ShapeBuilder(useTwips);
            shape.setCurrentLineStyle(0);
            shape.setCurrentFillStyle1(1);
            shape.setUseFillStyle1(true);
            shape.processShape(new PathIteratorWrapper(outline.getPathIterator(null)));

            return shape.build();
        }

        public int getAdvance(char c)
        {
            return 0;  //To change body of implemented methods use File | Settings | File Templates.
        }

        public Font getFont()
        {
            return font;
        }

        public int getMissingGlyphCode()
        {
            return font.getMissingGlyphCode();
        }

        public double getPointSize()
        {
            return font.getSize2D();
        }

        public FontRenderContext getFontRenderContext()
        {
            return frc;
        }

        public int getAscent()
        {
            return ascent;
        }

        public int getDescent()
        {
            return descent;
        }

        public int getLineGap()
        {
            return lineGap;
        }

        public int getNumGlyphs()
        {
            return font.getNumGlyphs();
        }

        public double getEmScale()
        {
            return emScale;
        }

        public String getPostscriptName()
        {
            return font.getPSName();
        }

        private Font font;
        private static Graphics2D graphics;
        private FontRenderContext frc;
        private FontMetrics fontMetrics;
        private int ascent;
        private int descent;
        private int lineGap;
        private double emScale;
        private AffineTransform scaleTransform;
    }
}
