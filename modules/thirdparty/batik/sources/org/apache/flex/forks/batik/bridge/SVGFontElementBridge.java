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

import org.apache.flex.forks.batik.gvt.text.ArabicTextHandler;
import org.apache.flex.forks.batik.gvt.font.GVTFontFace;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
 * Bridge class for the &lt;font> element.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: SVGFontElementBridge.java 475685 2006-11-16 11:16:05Z cam $
 */
public class SVGFontElementBridge extends AbstractSVGBridge {

    /**
     * Constructs a new bridge for the &lt;font> element.
     */
    public SVGFontElementBridge() {
    }

    /**
     * Returns 'font'.
     */
    public String getLocalName() {
        return SVG_FONT_TAG;
    }

    /**
     * Constructs a new SVGGVTFont that represents the specified &lt;font> element
     * at the requested size.
     *
     * @param ctx The current bridge context.
     * @param fontElement The font element to base the SVGGVTFont construction on.
     * @param textElement The text element that will use the new font.
     * @param size The size of the new font.
     * @param fontFace The font face object that contains the font attributes.
     *
     * @return The new SVGGVTFont.
     */
    public SVGGVTFont createFont(BridgeContext ctx,
                                 Element fontElement,
                                 Element textElement,
                                 float size,
                                 GVTFontFace fontFace) {


        // construct a list of glyph codes that this font can display and
        // a list of the glyph elements
        NodeList glyphElements = fontElement.getElementsByTagNameNS
            (SVG_NAMESPACE_URI, SVG_GLYPH_TAG);
        int numGlyphs = glyphElements.getLength();
        String[] glyphCodes = new String[numGlyphs];
        String[] glyphNames = new String[numGlyphs];
        String[] glyphLangs = new String[numGlyphs];
        String[] glyphOrientations = new String[numGlyphs];
        String[] glyphForms = new String[numGlyphs];
        Element[] glyphElementArray = new Element[numGlyphs];

        for (int i = 0; i < numGlyphs; i++) {
            Element glyphElement = (Element)glyphElements.item(i);
            glyphCodes[i] = glyphElement.getAttributeNS(null, SVG_UNICODE_ATTRIBUTE);
            if (glyphCodes[i].length() > 1) {
                // ligature, may need to reverse if arabic so that it is in visual order
                if (ArabicTextHandler.arabicChar(glyphCodes[i].charAt(0))) {
                    glyphCodes[i] = (new StringBuffer(glyphCodes[i])).reverse().toString();
                }
            }
            glyphNames[i] = glyphElement.getAttributeNS(null, SVG_GLYPH_NAME_ATTRIBUTE);
            glyphLangs[i] = glyphElement.getAttributeNS(null, SVG_LANG_ATTRIBUTE);
            glyphOrientations[i] = glyphElement.getAttributeNS(null, SVG_ORIENTATION_ATTRIBUTE);
            glyphForms[i] = glyphElement.getAttributeNS(null, SVG_ARABIC_FORM_ATTRIBUTE);
            glyphElementArray[i] = glyphElement;
        }

        // get the missing glyph element
        NodeList missingGlyphElements = fontElement.getElementsByTagNameNS
            (SVG_NAMESPACE_URI, SVG_MISSING_GLYPH_TAG);
        Element missingGlyphElement = null;
        if (missingGlyphElements.getLength() > 0) {
            missingGlyphElement = (Element)missingGlyphElements.item(0);
        }

        // get the hkern elements
        NodeList hkernElements = fontElement.getElementsByTagNameNS
            (SVG_NAMESPACE_URI, SVG_HKERN_TAG);
        Element[] hkernElementArray = new Element[hkernElements.getLength()];

        for (int i = 0; i < hkernElementArray.length; i++) {
            Element hkernElement = (Element)hkernElements.item(i);
            hkernElementArray[i] = hkernElement;
        }

        // get the vkern elements
        NodeList vkernElements = fontElement.getElementsByTagNameNS
            (SVG_NAMESPACE_URI, SVG_VKERN_TAG);
        Element[] vkernElementArray = new Element[vkernElements.getLength()];

        for (int i = 0; i < vkernElementArray.length; i++) {
            Element vkernElement = (Element)vkernElements.item(i);
            vkernElementArray[i] = vkernElement;
        }

        // return the new SVGGVTFont
        return new SVGGVTFont
            (size, fontFace, glyphCodes, glyphNames, glyphLangs,
             glyphOrientations, glyphForms, ctx,
             glyphElementArray, missingGlyphElement,
             hkernElementArray, vkernElementArray, textElement);
    }
}
