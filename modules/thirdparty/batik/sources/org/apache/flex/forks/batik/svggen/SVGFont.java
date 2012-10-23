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
package org.apache.flex.forks.batik.svggen;

import java.awt.Font;
import java.awt.Shape;
import java.awt.font.FontRenderContext;
import java.awt.font.GlyphMetrics;
import java.awt.font.GlyphVector;
import java.awt.font.LineMetrics;
import java.awt.font.TextAttribute;
import java.awt.geom.AffineTransform;
import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
 * Utility class that converts a Font object into a set of SVG
 * font attributes
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGFont.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class SVGFont extends AbstractSVGConverter {
    public static final float EXTRA_LIGHT =
        TextAttribute.WEIGHT_EXTRA_LIGHT.floatValue();
    public static final float LIGHT =
        TextAttribute.WEIGHT_LIGHT.floatValue();
    public static final float DEMILIGHT =
        TextAttribute.WEIGHT_DEMILIGHT.floatValue();
    public static final float REGULAR =
        TextAttribute.WEIGHT_REGULAR.floatValue();
    public static final float SEMIBOLD =
        TextAttribute.WEIGHT_SEMIBOLD.floatValue();
    public static final float MEDIUM =
        TextAttribute.WEIGHT_MEDIUM.floatValue();
    public static final float DEMIBOLD =
        TextAttribute.WEIGHT_DEMIBOLD.floatValue();
    public static final float BOLD =
        TextAttribute.WEIGHT_BOLD.floatValue();
    public static final float HEAVY =
        TextAttribute.WEIGHT_HEAVY.floatValue();
    public static final float EXTRABOLD =
        TextAttribute.WEIGHT_EXTRABOLD.floatValue();
    public static final float ULTRABOLD =
        TextAttribute.WEIGHT_ULTRABOLD.floatValue();

    public static final float POSTURE_REGULAR =
        TextAttribute.POSTURE_REGULAR.floatValue();
    public static final float POSTURE_OBLIQUE =
        TextAttribute.POSTURE_OBLIQUE.floatValue();

    /**
     * Contains threshold value for the various Font styles. If a given
     * style is in an interval, then it is mapped to the style at the top
     * of that interval.
     * @see #styleToSVG
     */
    static final float[] fontStyles = {
        POSTURE_REGULAR + (POSTURE_OBLIQUE - POSTURE_REGULAR)/2
    };

    /**
     * SVG Styles corresponding to the fontStyles
     */
    static final String[] svgStyles = {
        /*POSTURE_REGULAR*/   SVG_NORMAL_VALUE,
        /*POSTURE_OBLIQUE*/   SVG_ITALIC_VALUE
    };

    /**
     * Contains threshold values for the various Font weights. If a given
     * weight is in an interval, then it is mapped to the weight at the top
     * of the interval.
     * @see #weightToSVG
     */
    static final float[] fontWeights = { EXTRA_LIGHT + (LIGHT - EXTRA_LIGHT)/2f,
                                         LIGHT + (DEMILIGHT - LIGHT)/2f,
                                         DEMILIGHT + (REGULAR - DEMILIGHT)/2f,
                                         REGULAR + (SEMIBOLD - REGULAR)/2f,
                                         SEMIBOLD + (MEDIUM - SEMIBOLD)/2f,
                                         MEDIUM + (DEMIBOLD - MEDIUM)/2f,
                                         DEMIBOLD + (BOLD - DEMIBOLD)/2f,
                                         BOLD + (HEAVY - BOLD)/2f,
                                         HEAVY + (EXTRABOLD - HEAVY)/2f,
                                         EXTRABOLD + (ULTRABOLD - EXTRABOLD),
    };

    /**
     * SVG Weights corresponding to the fontWeights
     */
    static final String[] svgWeights = {
        /*EXTRA_LIGHT*/ SVG_100_VALUE,
        /*LIGHT*/       SVG_200_VALUE,
        /*DEMILIGHT*/   SVG_300_VALUE,
        /*REGULAR*/     SVG_NORMAL_VALUE,
        /*SEMIBOLD*/    SVG_500_VALUE,
        /*MEDIUM*/      SVG_500_VALUE,
        /*DEMIBOLD*/    SVG_600_VALUE,
        /*BOLD*/        SVG_BOLD_VALUE,
        /*HEAVY*/       SVG_800_VALUE,
        /*EXTRABOLD*/   SVG_800_VALUE,
        /*ULTRABOLD*/   SVG_900_VALUE
    };

    /**
     * Logical fonts mapping
     */
    static Map logicalFontMap = new HashMap();

    static {
        logicalFontMap.put("dialog", "sans-serif");
        logicalFontMap.put("dialoginput", "monospace");
        logicalFontMap.put("monospaced", "monospace");
        logicalFontMap.put("serif", "serif");
        logicalFontMap.put("sansserif", "sans-serif");
        logicalFontMap.put("symbol", "'WingDings'");
    }

    /**
     * The common font size to use when generating all SVG fonts.
     */
    static final int COMMON_FONT_SIZE = 100;

    /**
     * Used to keep track of which characters have been rendered by each font
     * used. MapKey is the fontKey, mapValue is a sorted array of used characters.
     */
    final Map fontStringMap = new HashMap();

    /**
     * @param generatorContext used to build Elements
     */
    public SVGFont(SVGGeneratorContext generatorContext) {
        super(generatorContext);
    }

    /**
     * Records that the specified font has been used to draw the text string.
     * This is so we can keep track of which glyphs are required for each
     * SVG font that is generated.
     */
    public void recordFontUsage(String string, Font font) {

        Font   commonSizeFont = createCommonSizeFont(font);
        String fontKey        = (commonSizeFont.getFamily() +
                                 commonSizeFont.getStyle());

//        String textUsingFont = (String)fontStringMap.get(fontKey);
//        if (textUsingFont == null) {
//            // font has not been used before
//            textUsingFont = "";
//        }
//
//        // append any new characters to textUsingFont
//        // FIXX: This is horribly inefficent, consider binary tree, Set, etc.
//        for (int i = 0; i < string.length(); i++) {
//            char ch = string.charAt(i);
//            if (textUsingFont.indexOf(ch) == -1) {
//                textUsingFont += ch;
//            }
//        }
        CharListHelper chl = (CharListHelper) fontStringMap.get( fontKey );
        if ( chl == null ){
            // was not in use before, so we need to create a fresh one
            chl = new CharListHelper();
        }
        for (int i = 0; i < string.length(); i++) {
            char ch = string.charAt(i);    // todo take care of surrogate chars here...
            chl.add( ch );
        }

        fontStringMap.put(fontKey, chl );
    }

    /**
     * Creates a new Font that is of the common font size used for generating
     * SVG fonts. The new Font will be the same as the specified font, with
     * only its size attribute modified.
     */
    private static Font createCommonSizeFont(Font font) {
        Map attributes = new HashMap(font.getAttributes());
        attributes.put(TextAttribute.SIZE, new Float(COMMON_FONT_SIZE));
        // Remove Transform from font otherwise it will be applied twice.
        attributes.remove(TextAttribute.TRANSFORM);
        return new Font(attributes);
    }

    /**
     * Converts part or all of the input GraphicContext into
     * a set of attribute/value pairs and related definitions
     *
     * @param gc GraphicContext to be converted
     * @return descriptor of the attributes required to represent
     *         some or all of the GraphicContext state, along
     *         with the related definitions
     * @see org.apache.flex.forks.batik.svggen.SVGDescriptor
     */
    public SVGDescriptor toSVG(GraphicContext gc) {
        return toSVG(gc.getFont(), gc.getFontRenderContext());
    }

    /**
     * @param font Font object which should be converted to a set
     *        of SVG attributes
     * @param frc The FontRenderContext which will be used to generate glyph
     * elements for the SVGFont definition element
     * @return description of attribute values that describe the font
     */
    public SVGFontDescriptor toSVG(Font font, FontRenderContext frc) {
        // Remove affine from FRC otherwise it will be applied twice.
        FontRenderContext localFRC;
        localFRC = new FontRenderContext(new AffineTransform(),
                                         frc.isAntiAliased(),
                                         frc.usesFractionalMetrics());

        String fontSize = "" + doubleString(font.getSize2D());
        String fontWeight = weightToSVG(font);
        String fontStyle = styleToSVG(font);
        String fontFamilyStr = familyToSVG(font);

        Font commonSizeFont = createCommonSizeFont(font);
        String fontKey = (commonSizeFont.getFamily() +
                          commonSizeFont.getStyle());

        CharListHelper clh = (CharListHelper)fontStringMap.get(fontKey);

        if (clh == null) {
            // this font hasn't been used by any text yet,
            // so don't create an SVG Font element for it
            return new SVGFontDescriptor(fontSize, fontWeight,
                                         fontStyle, fontFamilyStr,
                                         null);
        }

        Document domFactory = generatorContext.domFactory;

        // see if a description already exists for this font
        SVGFontDescriptor fontDesc =
            (SVGFontDescriptor)descMap.get(fontKey);

        Element fontDef;

        if (fontDesc != null) {

            // use the SVG Font element that has already been created
            fontDef = fontDesc.getDef();

        } else {

            // create a new SVG Font element
            fontDef = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                 SVG_FONT_TAG);

            //
            // create the font-face element
            //
            Element fontFace = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                          SVG_FONT_FACE_TAG);
            String svgFontFamilyString = fontFamilyStr;
            if (fontFamilyStr.startsWith("'") &&
                fontFamilyStr.endsWith("'")) {
                // get rid of the quotes
                svgFontFamilyString
                    = fontFamilyStr.substring(1, fontFamilyStr.length()-1);
            }
            fontFace.setAttributeNS(null, SVG_FONT_FAMILY_ATTRIBUTE,
                                    svgFontFamilyString);
            fontFace.setAttributeNS(null, SVG_FONT_WEIGHT_ATTRIBUTE,
                                    fontWeight);
            fontFace.setAttributeNS(null, SVG_FONT_STYLE_ATTRIBUTE,
                                    fontStyle);
            fontFace.setAttributeNS(null, SVG_UNITS_PER_EM_ATTRIBUTE,
                                    ""+COMMON_FONT_SIZE);
            fontDef.appendChild(fontFace);

            //
            // create missing glyph element
            //
            Element missingGlyphElement
                = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                             SVG_MISSING_GLYPH_TAG);

            int[] missingGlyphCode = new int[1];
            missingGlyphCode[0] = commonSizeFont.getMissingGlyphCode();
            GlyphVector gv;
            gv = commonSizeFont.createGlyphVector(localFRC, missingGlyphCode);
            Shape missingGlyphShape = gv.getGlyphOutline(0);
            GlyphMetrics gm = gv.getGlyphMetrics(0);

            // need to turn the missing glyph upside down to be in the font
            // coordinate system (i.e Y axis up)
            AffineTransform at = AffineTransform.getScaleInstance(1, -1);
            missingGlyphShape = at.createTransformedShape(missingGlyphShape);

            missingGlyphElement.setAttributeNS(null, SVG_D_ATTRIBUTE,
                                    SVGPath.toSVGPathData(missingGlyphShape, generatorContext));
            missingGlyphElement.setAttributeNS(null, SVG_HORIZ_ADV_X_ATTRIBUTE, String.valueOf( gm.getAdvance() ) );
            fontDef.appendChild(missingGlyphElement);

            // set the font's default horizontal advance to be the same as
            // the missing glyph
            fontDef.setAttributeNS(null, SVG_HORIZ_ADV_X_ATTRIBUTE, String.valueOf( gm.getAdvance() ) );

            // set the ascent and descent attributes
            LineMetrics lm = commonSizeFont.getLineMetrics("By", localFRC);
            fontFace.setAttributeNS(null, SVG_ASCENT_ATTRIBUTE,  String.valueOf( lm.getAscent() ) );
            fontFace.setAttributeNS(null, SVG_DESCENT_ATTRIBUTE, String.valueOf( lm.getDescent() ) );

            //
            // Font ID
            //
            fontDef.setAttributeNS(null, SVG_ID_ATTRIBUTE,  generatorContext.idGenerator.generateID(ID_PREFIX_FONT));
        }

        //
        // add any new glyphs to the fontDef here
        //
        String textUsingFont = clh.getNewChars();
        clh.clearNewChars();

        // process the characters in textUsingFont backwards since the new chars
        // are at the end, can stop when find a char that already has a glyph
        for (int i = textUsingFont.length()-1; i >= 0; i--) {
            char c = textUsingFont.charAt(i);
            String searchStr = String.valueOf( c );
            boolean foundGlyph = false;
            NodeList fontChildren = fontDef.getChildNodes();
            for (int j = 0; j < fontChildren.getLength(); j++) {
                if (fontChildren.item(j) instanceof Element) {
                    Element childElement = (Element)fontChildren.item(j);
                    if (childElement.getAttributeNS(null, SVG_UNICODE_ATTRIBUTE).equals( searchStr )) {
                        foundGlyph = true;
                        break;
                    }
                }
            }
            if (!foundGlyph) {
                // need to create one
                Element glyphElement
                    = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                 SVG_GLYPH_TAG);

                GlyphVector gv;
                gv = commonSizeFont.createGlyphVector(localFRC, ""+c);
                Shape glyphShape = gv.getGlyphOutline(0);
                GlyphMetrics gm = gv.getGlyphMetrics(0);

                // need to turn the glyph upside down to be in the font
                // coordinate system (i.e Y axis up)
                AffineTransform at = AffineTransform.getScaleInstance(1, -1);
                glyphShape = at.createTransformedShape(glyphShape);

                glyphElement.setAttributeNS(null, SVG_D_ATTRIBUTE,
                                            SVGPath.toSVGPathData(glyphShape, generatorContext));
                glyphElement.setAttributeNS(null, SVG_HORIZ_ADV_X_ATTRIBUTE, String.valueOf( gm.getAdvance() ) );
                glyphElement.setAttributeNS(null, SVG_UNICODE_ATTRIBUTE,     String.valueOf( c ) );

                fontDef.appendChild(glyphElement);
            } else {
                // have reached the chars in textUsingFont that already
                // have glyphs, don't need to process any further
                break;
            }
        }

        //
        // create a new font description for this instance of the font usage
        //
        SVGFontDescriptor newFontDesc
            = new SVGFontDescriptor(fontSize, fontWeight,
                                    fontStyle, fontFamilyStr,
                                    fontDef);

        //
        // Update maps so that the font def can be reused if needed
        //
        if (fontDesc == null) {
            descMap.put(fontKey, newFontDesc);
            defSet.add(fontDef);
        }

        return newFontDesc;
    }

    /**
     * @param font whose family should be converted to an SVG string
     *   value.
     */
    public static String familyToSVG(Font font) {
        String fontFamilyStr = font.getFamily();
        String logicalFontFamily =
            (String)logicalFontMap.get(font.getName().toLowerCase());
        if (logicalFontFamily != null)
            fontFamilyStr = logicalFontFamily;
        else {
            final char QUOTE = '\'';
            fontFamilyStr = QUOTE + fontFamilyStr + QUOTE;
        }
        return fontFamilyStr;
    }

    /**
     * @param font whose style should be converted to an SVG string
     *        value.
     */
    public static String styleToSVG(Font font) {
        Map attrMap = font.getAttributes();
        Float styleValue = (Float)attrMap.get(TextAttribute.POSTURE);

        if (styleValue == null) {
            if (font.isItalic())
                styleValue = TextAttribute.POSTURE_OBLIQUE;
            else
                styleValue = TextAttribute.POSTURE_REGULAR;
        }

        float style = styleValue.floatValue();

        int i = 0;
        for (i=0; i< fontStyles.length; i++) {
            if (style <= fontStyles[i])
                break;
        }

        return svgStyles[i];
    }

    /**
     * @param font whose weight should be converted to an SVG string
     *        value. Note that there is loss of precision for
     *        semibold and extrabold.
     */
    public static String weightToSVG(Font font) {
        Map attrMap = font.getAttributes();
        Float weightValue = (Float)attrMap.get(TextAttribute.WEIGHT);
        if (weightValue==null) {
            if (font.isBold())
                weightValue = TextAttribute.WEIGHT_BOLD;
            else
                weightValue = TextAttribute.WEIGHT_REGULAR;
        }

        float weight = weightValue.floatValue();

        int i = 0;
        for (i=0; i<fontWeights.length; i++) {
            if (weight<=fontWeights[i])
                break;
        }

        return svgWeights[i];
    }

    /**
     * this helper-class implements a set of characters. it stores all used characters
     * in a font.
     *
     * <br>implementation: we keep a sorted list of integers. This allows to use binary search
     * for lookup and insert. The use of <code>int</code> instead of <code>char</code> allows us to
     * handle surrogate characters as well.
     */
    private static class CharListHelper {

        /**
         * the number of slots actually used.
         * must always be 0 &lt;= nUsed &lt;= charList.length
         */
        private int nUsed = 0;

        /**
         * keeps added characters, is kept sorted for efficient search.
         */
        private int[] charList = new int[ 40 ];

        /**
         * this keeps all added characters in order. It can be cleared from toSVG()
         * when glyphs are created for some characters.
         */
        private StringBuffer freshChars = new StringBuffer( 40 );

        CharListHelper() {

        }

        /**
         * get a string of all characters added since last call to clearNewChars().
         * @return a string of all recently added characters
         */
        String getNewChars(){
            return freshChars.toString();
        }

        /**
         * reset the string of recently added characters - used after glyphs were created for them.
         */
        void clearNewChars(){
            freshChars = new StringBuffer( 40 );
        }

        /**
         * test, if the character is contained in the charList.
         * If not, insert c into charList.
         * charList is kept sorted for efficient search.
         * @param c
         * @return true, when fresh inserted
         */
        boolean add( int c ){
            int pos = binSearch( charList, nUsed, c );
            if ( pos >= 0 ){
                // was in list: no activity needed
                return false;
            }
            // insert new char into array, grow if necessary
            if ( nUsed == charList.length ){
                // full, allocate some more slots - moderately...
                int[] t = new int[ nUsed + 20 ];
                System.arraycopy( charList, 0, t, 0, nUsed );
                charList = t;
            }
            // now we can insert the new character
            pos = -pos -1;
            System.arraycopy( charList, pos, charList, pos+1, nUsed - pos );
            charList[ pos ] = c;
            freshChars.append( (char)c );    // todo if necessary split surrogates here
            nUsed++;

            return true;
        }

        /**
         * unfortunatly, Arrays.binarySearch() does not support search in a
         * part of the array (not in jdk1.3 and jdk1.4). - so we have do provide our own
         * implementation.
         * @param list to search within
         * @param nUsed the last used index, can be &lt; list.length
         * @param chr the character to lookup
         * @return the index when found, or the negative insert position.
         */
        static int binSearch( int[] list, int nUsed, int chr ){

            int low = 0;
            int high = nUsed -1;

            while ( low <= high ) {
                int mid = ( low + high ) >>> 1;  // we're not sun - we know how to binSearch...
                int midVal = list[ mid ];

                if ( midVal < chr ) {
                    low = mid + 1;
                } else if ( midVal > chr ) {
                    high = mid - 1;
                } else {
                    return mid; // char found
                }
            }
            return -( low + 1 );  // char not found, should be inserted at -pos -1
        }


    }

}
