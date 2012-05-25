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

import flash.swf.builder.types.ShapeBuilder;
import flash.swf.builder.types.ShapeIterator;
import flash.swf.types.GlyphEntry;
import flash.swf.types.Shape;
import flash.swf.SwfConstants;
import flash.util.Trace;

import org.apache.flex.forks.batik.svggen.font.Font;
import org.apache.flex.forks.batik.svggen.font.Glyph;
import org.apache.flex.forks.batik.svggen.font.Point;
import org.apache.flex.forks.batik.svggen.font.table.CmapFormat;
import org.apache.flex.forks.batik.svggen.font.table.CmapTable;
import org.apache.flex.forks.batik.svggen.font.table.GlyfTable;
import org.apache.flex.forks.batik.svggen.font.table.GlyphDescription;
import org.apache.flex.forks.batik.svggen.font.table.HeadTable;
import org.apache.flex.forks.batik.svggen.font.table.HheaTable;
import org.apache.flex.forks.batik.svggen.font.table.HmtxTable;
import org.apache.flex.forks.batik.svggen.font.table.NameTable;
import org.apache.flex.forks.batik.svggen.font.table.Os2Table;
import org.apache.flex.forks.batik.svggen.font.table.Table;

import java.io.File;
import java.net.URL;
import java.util.ArrayList;
import java.util.Map;

/**
 * This implementation of FontManager uses Apache Batik to process
 * TrueTypeFont Files.
 *
 * @author Peter Farland
 */
@SuppressWarnings("unchecked")
public class BatikFontManager extends CachedFontManager
{
	private JREFontManager jreManager;
    // Used to initialize the JREFontManager.
	private Map initializeMap;

    public static String processLocation(Object location)
    {
        String path = null;

        if (location != null)
        {
            if (location instanceof URL)
            {
                URL url = (URL)location;
                if (url.getProtocol().toLowerCase().indexOf("file") > -1)
                {
                    path = url.getFile();
                }
            }
            else
            {
                File f = new File(location.toString());
                if (f.exists())
                {
                    path = f.getAbsolutePath();
                }
            }
        }

        return path;
    }

    public void initialize(Map map)
    {
        super.initialize(map);
        initializeMap = map;
    }

	public FontFace getEntryFromSystem(String familyName, int style, boolean useTwips)
	{
		FontManager manager = parent;
		if (manager == null)
		{
			if (jreManager == null)
			{
				jreManager = new JREFontManager();
                jreManager.initialize(initializeMap);
			}
			manager = jreManager;
		}
        return manager.getEntryFromSystem(familyName, style, useTwips);
	}

	protected FontSet createSetForSystemFont(String family, int style, boolean useTwips)
	{
		FontManager manager = parent;
		if (manager == null || ! (manager instanceof CachedFontManager))
		{
			if (jreManager == null)
			{
				jreManager = new JREFontManager();
			}
			manager = jreManager;
		}

        return ((CachedFontManager)manager).createSetForSystemFont(family, style, useTwips);
	}

    public FontFace getEntryFromLocation(URL location, int requestedStyle, boolean useTwips)
    {
    	// C: Batik should only do TT.
    	if (!location.toString().toLowerCase().endsWith(".ttf"))
    	{
        	return (parent != null) ? parent.getEntryFromLocation(location, requestedStyle, useTwips) : null;
    	}
    	
        FontFace entry = null;

        String locationKey = location != null ? location.toExternalForm() : null;
        Object fam = getFontFileCache().get(locationKey);
        if (fam == null)
        {
            fam = createFontFromLocation(location, requestedStyle, useTwips);
        }

        if (fam != null)
        {
            String family = fam.toString();

            FontSet fontSet = (FontSet)getFontCache().get(family);

            // The font file cache should still have this family
            // from the location fetch above...
            if (fontSet != null)
            {
                entry = fontSet.get(requestedStyle);
            }

            // Finally, remember the family for this location
            getFontFileCache().put(locationKey, family);
        }
        else if (parent != null)
        {
        	// C: give the parent font manager a chance...
        	return parent.getEntryFromLocation(location, requestedStyle, useTwips);
        }

        return entry;
    }

    protected String createFontFromLocation(Object location, int requestedStyle, boolean useTwips)
    {
        String family = null;
        String path = processLocation(location);

        if (path != null)
        {
            try
            {
	            // Use Batik to load the Font
	            Font font = Font.create(path);

                if (font != null)
                {
	                FSType type = FSType.getFSType(font);
	                if (! type.usableByFlex)
	                {
		                throw new UnusableFontLicense(location + "", type.description);
	                }
	                String copyright = font.getNameTable().getRecord(Table.nameCopyrightNotice);
	                String trademark = font.getNameTable().getRecord(Table.nameTrademark);

                    // BatikFontManager will try to work out the real
                    // style from the sub family name and update the
                    // style property...
                    BatikFontFace fontFace = new BatikFontFace(font, 0,
                            maxGlyphsPerFace, type, copyright, trademark,
                            useTwips, majorCompatibilityVersion < 3);

                    // From Flex 4 we just use the requested style rather than
                    // validating it matches the style described by the font
                    if (majorCompatibilityVersion > 3)
                        fontFace.style = requestedStyle;

                    family = fontFace.getFamily();

                    FontSet fontSet = (FontSet)getFontCache().get(family);

                    if (fontSet == null)
                    {
                        fontSet = new FontSet(maxFacesPerFont);
                        getFontCache().put(family, fontSet);
                    }

                    fontSet.put(fontFace.style, fontFace);
                }
            }
            catch (UnusableFontLicense l)
            {
	            throw l;
            }
            catch (Throwable t)
            {
                throw new RuntimeException("Unexpected exception encountered while reading font file '" + path + "'");
            }
        }

        return family;
    }

    /*
    public static class BatikRuntimeException extends RuntimeException {
    	public final static long serialVersionUID = -1;
    	public BatikRuntimeException(String s) {super(s);}
    	public BatikRuntimeException(Throwable e) {super(e);}
    }
    */

    public static class BatikFontFace extends CachedFontFace
    {
        static final short PLATFORM_APPLE_UNICODE = 0;
        static final short PLATFORM_MACINTOSH = 1;
        static final short PLATFORM_ISO = 2;
        static final short PLATFORM_MICROSOFT = 3;
        static final short ENCODING_UNDEFINED = 0;
        static final short ENCODING_UGL = 1;
        static final short ENCODING_ROMAN = 0;

        public BatikFontFace(Font font, int style, int maxGlyphs, FSType fsType, String copyright, String trademark,
                             boolean useTwips, boolean keep201Behavior)
        {
            super(maxGlyphs, style, fsType, copyright, trademark, useTwips);
            init(font, keep201Behavior);
        }

        private void init(Font font, boolean keep201Behavior)
        {
            numGlyphs = font.getNumGlyphs();

            processCmapTable(font);
            processNameTable(font);
            processHeadTable(font); //Must process this before HHEA table
            processHheaTable(font);
            processOS2Table(font);

            hmtx = (HmtxTable)font.getTable(Table.hmtx);
            glyf = (GlyfTable)font.getTable(Table.glyf);
            this.keep201Behavior = keep201Behavior; 
        }

        /**
         * Contains multiple mapping tables from Unicode and various 8-bit encodings to glyph ids.
         * Multi-platform.
         */
        private void processCmapTable(Font font)
        {
            CmapTable cmap = font.getCmapTable();

            if (cmap != null)
            {
                // Decide upon a cmap table to use for our character to glyph look-up
                if (forceAscii)
                {
                    // We've been asked to use the ASCII/Macintosh cmap format
                    cmapFmt = cmap.getCmapFormat(Table.platformMacintosh, Table.encodingRoman);
                    platformID = PLATFORM_MACINTOSH;
                    encodingID = ENCODING_ROMAN;
                }
                else
                {
                    // The default behaviour is to use the Unicode cmap encoding
                    cmapFmt = cmap.getCmapFormat(Table.platformMicrosoft, Table.encodingUGL);
                    if (cmapFmt == null)
                    {
                        // This might be a symbol font, so we'll look for an "undefined" encoding
                        cmapFmt = cmap.getCmapFormat(Table.platformMicrosoft, Table.encodingUndefined);
                        platformID = PLATFORM_MICROSOFT;
                        encodingID = ENCODING_UNDEFINED;
                    }
                    else
                    {
                        platformID = PLATFORM_MICROSOFT;
                        encodingID = ENCODING_UGL;
                    }
                }
            }

            if (cmapFmt == null)
            {
                throw new RuntimeException("Cannot find a suitable cmap table");
            }
        }

        /**
         * Contains strings that provide general information about the font.
         * Strings are multilingual and multi-platform and are identified by number.
         * Some numbers have a standard meaning such as font name and copyright.
         * Arbitrary numbered strings can also be present.
         */
        private void processNameTable(Font font)
        {
            NameTable name = font.getNameTable();

            if (name != null)
            {
                fontFamily = name.getRecord(Table.nameFontFamilyName);
                subFamilyName = name.getRecord(Table.nameFontSubfamilyName);
	            postscriptName = name.getRecord(Table.namePostscriptName);

                if (subFamilyName != null)
                {
                    style = guessStyleFromSubFamilyName(subFamilyName);
                }
            }
            else
            {
            	if (Trace.font)
                    Trace.trace("Font " + fontFamily + " did not have an HEAD Table.");
            }
        }

        /**
         * Contains overall font metrics and checksum for font.
         * Also contains font appearance (Mac). Must be called before
         * reading HHEA table.
         */
        private void processHeadTable(Font font)
        {
            HeadTable head = font.getHeadTable();

            if (head != null)
            {
                unitsPerEm = head.getUnitsPerEm();
            }
            else
            {
            	if (Trace.font)
                    Trace.trace("Font " + fontFamily + " did not have an HEAD Table.");
            }

            //Scale points to SWF fixed EM square of 1024 FUnits
            emScale = SWF_EM_SQUARE / (double)unitsPerEm;
        }

        /**
         * Contains overall horizontal metrics and caret slope.
         * Also contains line spacing (Mac).
         */
        private void processHheaTable(Font font)
        {
            HheaTable hhea = font.getHheaTable();

            if (hhea != null)
            {
                //TODO: I'm skeptical about these values, shouldn't the x-height and baseline be taken into consideration here?!
                ascent = (short)Math.rint(hhea.getAscender() * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));
                descent = (short)Math.rint(hhea.getDescender() * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));
                lineGap = (short)Math.rint(hhea.getLineGap() * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));
            }
            else
            {
            	if (Trace.font)
                    Trace.trace("Font " + fontFamily + " did not have an HHEA Table.");
            }
        }

        /**
         * Contains line spacing, font weight, font style, codepoint ranges (codepage and Unicode)
         * covered by glyphs, overall appearance, sub- and super-script support, strike out information.
         */
        private void processOS2Table(Font font)
        {
            Os2Table os2 = font.getOS2Table();

            if (os2 != null)
            {
                if (!forceAscii)
                {
                    int winAscent = os2.getWinAscent();
                    ascent = (short)Math.rint(winAscent * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));

                    int winDescent = os2.getWinDescent();
                    descent = (short)Math.rint(winDescent * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));

                    int winLeading = os2.getTypoLineGap();
                    lineGap = (short)Math.rint(winLeading * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));
                }

                horizAdvanceX = os2.getAvgCharWidth();
                panose = os2.getPanose().toString();
                usFirstCharIndex = os2.getFirstCharIndex();
            }
            else
            {
            	if (Trace.font)
                    Trace.trace("Font " + fontFamily + " did not have an OS/2 Table.");
            }
        }

        //SWF through version 7 does not use kerning information.
        /*
        private void processKernTable(Font font)
        {
            KernTable kern = (KernTable)font.getTable(Table.kern);
            if (kern != null)
            kst = kern.getSubtable(0);
        }
        */

        public boolean canDisplay(char c)
        {
            return cmapFmt.mapCharCode(getCharIndex(c)) > 0;
        }

        public GlyphEntry getGlyphEntry(char c)
        {
            return (GlyphEntry)glyphCache.get(c);
        }

        public GlyphEntry createGlyphEntry(char c)
        {
            return createGlyphEntry(c, c);
        }

        public GlyphEntry createGlyphEntry(char c, char referenceChar)
        {
            int index = getCharIndex(referenceChar);
            index = cmapFmt.mapCharCode(index);
            Glyph glyph = getGlyph(index);

            Shape s = getShapeFromGlyph(glyph);

            GlyphEntry ge = new GlyphEntry();
            ge.advance = (int)(getAdvance(referenceChar) * emScale * (useTwips ? SwfConstants.TWIPS_PER_PIXEL : 1));
            ge.character = c;
            ge.shape = s;

            // Glyph bounds are not used by the Flash Player so no need to calculate
	        //ge.bounds = DefineShapeBuilder.getBounds(s.shapeRecords, null);

            return ge;
        }

        public int getFirstChar()
        {
            if (platformID == PLATFORM_MICROSOFT && encodingID == ENCODING_UNDEFINED)
                return usFirstCharIndex - 0xF000;
            else
                return usFirstCharIndex;
        }

        private int getCharIndex(char index)
        {
            if (platformID == PLATFORM_MICROSOFT && encodingID == ENCODING_UNDEFINED)
                index += (usFirstCharIndex - (usFirstCharIndex - 0xF000));

            return index;
        }

        private Glyph getGlyph(int index)
        {
            Glyph glyph = null;
            GlyphDescription desc = glyf.getDescription(index);

            if (desc != null)
                glyph = new Glyph(glyf.getDescription(index), hmtx.getLeftSideBearing(index), hmtx.getAdvanceWidth(index));

            return glyph;
        }

        private Shape getShapeFromGlyph(Glyph glyph)
        {
            ShapeBuilder shape = new ShapeBuilder(useTwips);
            shape.setCurrentLineStyle(0);
            shape.setCurrentFillStyle1(1);
            shape.setUseFillStyle1(true);
            shape.processShape(new GlyphIterator(glyph, emScale, keep201Behavior));

            return shape.build();
        }

        public int getAdvance(char c)
        {
            if (hmtx != null)
            {
                int index = getCharIndex(c);
                index = cmapFmt.mapCharCode(index);
                return hmtx.getAdvanceWidth(index);
            }

            return horizAdvanceX;
        }

        public int getAscent()
        {
            return ascent;
        }

        public int getDescent()
        {
            return descent;
        }

        public String getFamily()
        {
            return fontFamily;
        }

        public int getLineGap()
        {
            return lineGap;
        }

        public int getMissingGlyphCode()
        {
            return missingGlyphCode;
        }

        public int getNumGlyphs()
        {
            return numGlyphs;
        }

        public double getPointSize()
        {
            return 1.0f;
        }

        public String getPanose()
        {
            return panose;
        }

        public short getUnitsPerEm()
        {
            return unitsPerEm;
        }

        public double getEmScale()
        {
            return emScale;
        }

	    public String getPostscriptName()
	    {
		    return postscriptName;
	    }

        private CmapFormat cmapFmt = null;
        private GlyfTable glyf;
        private HmtxTable hmtx;
        private int horizAdvanceX;

        private String fontFamily;
        private String subFamilyName;
	    private String postscriptName;
        private short unitsPerEm;
        private String panose;
        private short ascent;
        private short descent;
        private short lineGap;
        private boolean forceAscii;
        private double emScale;
        private int numGlyphs;
        private short platformID;
        private short encodingID;
        private int usFirstCharIndex;
        private int missingGlyphCode = 0;
        private boolean keep201Behavior;

    }

    public static class GlyphIterator implements ShapeIterator
    {
        private final double emScale;
        private double[][] segments;
        private int index;
        private boolean keep201Behavior;

        public GlyphIterator(Glyph glyph, double emScale, boolean keep201Behavior)
        {
            this.emScale = emScale;
            this.keep201Behavior = keep201Behavior;
            if (glyph != null)
                readPoints(glyph);
            else
                segments = new double[][]{};
//            System.out.println("Batik");
//            for (int i = 0; i < segments.length; i++)
//            {
//            	System.out.println(segments[i][4] + ": " + segments[i][0] + "  " + segments[i][1]);
//            }
        }

        private void readPoints(Glyph glyph)
        {
            int count = glyph.getPointCount();
            int offset = 0;
            boolean newContour = true;
            ArrayList<double[]> aSegments = new ArrayList<double[]>(count);
            Point lastMove = null;

            while (offset < count - 1)
            {
                Point point = glyph.getPoint(offset);

                if (point.endOfContour)
                {
                    newContour = true;
                    offset++;
                    continue;
                }

                Point point_plus1 = glyph.getPoint((offset + 1));
                Point point_plus2;

                //Implicit close, using the last move point as the next point
                if (point_plus1.endOfContour)
                    point_plus2 = lastMove;
                else if (offset <= count - 3)
                    point_plus2 = glyph.getPoint((offset + 2));
                else
                    point_plus2 = null;

                if (newContour)
                {
                    double[] segment = new double[5];
                    segment[0] = point.x * emScale;
                    segment[1] = -point.y * emScale;
                    segment[4] = MOVE_TO;
                    aSegments.add(segment);
                    newContour = false;
                    lastMove = point;
                }
                else if (point.onCurve && point_plus1 != null && point_plus1.onCurve)
                {
                    //This is a simple line
                    double[] segment = new double[5];
                    segment[0] = point_plus1.x * emScale;
                    segment[1] = -point_plus1.y * emScale;
                    segment[4] = LINE_TO;
                    aSegments.add(segment);

                    offset++;
                }
                else if (point.onCurve && !point_plus1.onCurve && point_plus2.onCurve)
                {
                    // Then draw the curve, it has no implied points
                    double[] segment = new double[5];
                    segment[0] = point_plus1.x * emScale;
                    segment[1] = -point_plus1.y * emScale;
                    segment[2] = point_plus2.x * emScale;
                    segment[3] = -point_plus2.y * emScale;
                    segment[4] = QUAD_TO;
                    aSegments.add(segment);

                    //Handle implicit close situation
                    if (point_plus1.endOfContour)
                    {
                        offset++;
                        newContour = true;
                    }
                    else
                    {
                        offset += 2;
                    }
                }
                else if (point.onCurve && !point_plus1.onCurve && !point_plus2.onCurve)
                {
                    // This is a curve with one implied point, the mid-point between the next two points
                    double[] segment = new double[5];
                    segment[0] = point_plus1.x * emScale;
                    segment[1] = -point_plus1.y * emScale;
                    segment[2] = midPoint(point_plus1.x, point_plus2.x) * emScale;
                    segment[3] = -midPoint(point_plus1.y, point_plus2.y) * emScale;
                    segment[4] = QUAD_TO;
                    aSegments.add(segment);

                    //Handle implicit close situation
                    if (point_plus1.endOfContour)
                    {
                    	offset++;
                        newContour = true;
                    }
                    else
                    {
                    	// !!! Laurie's change. Handle off-curve/off-curve/end. There is
                    	// an implict curve between the second off-curve and the starting point.

                        // Handle implicit close situation
                        if (point_plus2.endOfContour && !keep201Behavior)
                        {
    	                	segment = new double[5];
    	                    segment[0] = point_plus2.x * emScale;
    	                    segment[1] = -point_plus2.y * emScale;
    	                    segment[2] = lastMove.x * emScale;
    	                    segment[3] = -lastMove.y * emScale;
    	                    segment[4] = QUAD_TO;
    	                    aSegments.add(segment);
    	                    // !!! END Laurie's change
                        }
                        offset += 2;
                    }
                }
                else if (!point.onCurve && !point_plus1.onCurve)
                {
                    // This is a curve with two implied points, but the first one must have been the previous control point
                    double[] segment = new double[5];
                    segment[0] = point.x * emScale;
                    segment[1] = -point.y * emScale;
                    segment[2] = midPoint(point.x, point_plus1.x) * emScale;
                    segment[3] = -midPoint(point.y, point_plus1.y) * emScale;
                    segment[4] = QUAD_TO;
                    aSegments.add(segment);

//                  !!! Laurie's change. Handle off-curve/off-curve/end. There is
                	// an implict curve between the second off-curve and the starting point.

                    // Handle implicit close situation
                    if (point_plus1.endOfContour && !keep201Behavior)
                    {
	                	segment = new double[5];
	                    segment[0] = point_plus1.x * emScale;
	                    segment[1] = -point_plus1.y * emScale;
	                    segment[2] = lastMove.x * emScale;
	                    segment[3] = -lastMove.y * emScale;
	                    segment[4] = QUAD_TO;
	                    aSegments.add(segment);
	                    // !!! END Laurie's change
                    }
                    
                    offset++;
                }
                else if (!point.onCurve && point_plus1.onCurve)
                {
                    // This is a curve with one implied point, but it must have been the previous control point
                    double[] segment = new double[5];
                    segment[0] = point.x * emScale;
                    segment[1] = -point.y * emScale;
                    segment[2] = point_plus1.x * emScale;
                    segment[3] = -point_plus1.y * emScale;
                    segment[4] = QUAD_TO;
                    aSegments.add(segment);
                    offset++;
                }
                else
                {
                    //TODO: ERROR?!
                    offset++;
                }
            }

            segments = new double[aSegments.size()][];
            segments = aSegments.toArray(segments);
        }

        private static double midPoint(int a, int b)
        {
            return a + (b - a) / 2.0;
        }

        public short currentSegment(double[] coords)
        {
            coords[0] = segments[index][0];
            coords[1] = segments[index][1];
            coords[2] = segments[index][2];
            coords[3] = segments[index][3];
            return (short)segments[index][4]; //TODO: A double here is a waste of memory
        }

        public boolean isDone()
        {
            return segments == null || index >= segments.length;
        }

        public void next()
        {
            index++;
        }
    }

	public static class UnusableFontLicense extends RuntimeException
	{
        private static final long serialVersionUID = 1969620523936688562L;

        public UnusableFontLicense(String location, String description)
		{
			super("The font " + location + " has a license that prevents it from being embedded: " + description + ".");
		}
	}
}
