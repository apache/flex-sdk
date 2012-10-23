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
package org.apache.flex.forks.batik.bridge;

import java.lang.ref.SoftReference;
import java.text.AttributedCharacterIterator;
import java.util.Map;

import org.apache.flex.forks.batik.gvt.font.GVTFont;
import org.apache.flex.forks.batik.gvt.font.GVTFontFace;
import org.apache.flex.forks.batik.gvt.font.GVTFontFamily;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * A font family class for SVG fonts.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: SVGFontFamily.java 489226 2006-12-21 00:05:36Z cam $
 */
public class SVGFontFamily implements GVTFontFamily {

    public static final
        AttributedCharacterIterator.Attribute TEXT_COMPOUND_ID =
        GVTAttributedCharacterIterator.TextAttribute.TEXT_COMPOUND_ID;

    protected GVTFontFace fontFace;
    protected Element fontElement;
    protected BridgeContext ctx;
    protected Boolean complex = null;



    /**
     * Constructs an SVGFontFamily.
     *
     * @param fontFace The font face object that describes this font family.
     * @param fontElement The element that contains the font data for this family.
     * @param ctx The bridge context. This is required for lazily loading the
     * font data at render time.
     */
    public SVGFontFamily(GVTFontFace fontFace,
                         Element fontElement,
                         BridgeContext ctx) {
        this.fontFace = fontFace;
        this.fontElement = fontElement;
        this.ctx = ctx;
    }

    /**
     * Returns the family name of this font.
     *
     * @return The font family name.
     */
    public String getFamilyName() {
        return fontFace.getFamilyName();
    }

    /**
     * Returns the font-face associated with this font family.
     *
     * @return The font face.
     */
    public GVTFontFace getFontFace() {
        return fontFace;
    }

    /**
     * Derives a GVTFont object of the correct size.
     *
     * @param size The required size of the derived font.
     * @param aci The character iterator containing the text to be rendered
     * using the derived font.
     *
     * @return The derived font.
     */
    public GVTFont deriveFont(float size, AttributedCharacterIterator aci) {
        return deriveFont(size, aci.getAttributes());
    }

    /**
     * Derives a GVTFont object of the correct size from an attribute Map.
     * @param size  The required size of the derived font.
     * @param attrs The Attribute Map to get Values from.
     */
    public GVTFont deriveFont(float size, Map attrs) {
        SVGFontElementBridge fontBridge;
        fontBridge = (SVGFontElementBridge)ctx.getBridge(fontElement);
        SoftReference sr = (SoftReference)attrs.get(TEXT_COMPOUND_ID);
        Element textElement = (Element)sr.get();
        return fontBridge.createFont(ctx, fontElement, textElement,
                                     size, fontFace);
    }

    /**
     * This method looks at the SVG font and checks if any of
     * the glyphs use renderable child elements.  If so this
     * is a complex font in that full CSS inheritance needs to
     * be applied.  Otherwise if it only uses the 'd' attribute
     * it does not need CSS treatment.
     */
    public boolean isComplex() {
        if (complex != null) return complex.booleanValue();
        boolean ret = isComplex(fontElement, ctx);
        complex = ret ? Boolean.TRUE : Boolean.FALSE;
        return ret;
    }

    public static boolean isComplex(Element fontElement, BridgeContext ctx) {
        NodeList glyphElements = fontElement.getElementsByTagNameNS
            (SVGConstants.SVG_NAMESPACE_URI, SVGConstants.SVG_GLYPH_TAG);

        int numGlyphs = glyphElements.getLength();
        for (int i = 0; i < numGlyphs; i++) {
            Element glyph = (Element)glyphElements.item(i);
            Node child    = glyph.getFirstChild();
            for (;child != null; child = child.getNextSibling()) {
                if (child.getNodeType() != Node.ELEMENT_NODE)
                    continue;
                Element e = (Element)child;
                Bridge b = ctx.getBridge(e);
                if ((b != null) && (b instanceof GraphicsNodeBridge)) {
                    return true;
                }
            }
        }
        return false;
    }
}
