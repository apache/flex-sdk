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

import java.util.List;

import org.apache.flex.forks.batik.gvt.font.GVTFontFamily;
import org.w3c.dom.Element;

/**
 * This class represents a &lt;font-face> element or @font-face rule
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: SVGFontFace.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGFontFace extends FontFace {

    Element fontFaceElement;
    GVTFontFamily fontFamily = null;
    /**
     * Constructes an SVGFontFace with the specfied font-face attributes.
     */
    public SVGFontFace
        (Element fontFaceElement, List srcs,
         String familyName, float unitsPerEm, String fontWeight,
         String fontStyle, String fontVariant, String fontStretch,
         float slope, String panose1, float ascent, float descent,
         float strikethroughPosition, float strikethroughThickness,
         float underlinePosition, float underlineThickness,
         float overlinePosition, float overlineThickness) {
        super(srcs,
              familyName, unitsPerEm, fontWeight, 
              fontStyle, fontVariant, fontStretch, 
              slope, panose1, ascent, descent,
              strikethroughPosition, strikethroughThickness,
              underlinePosition, underlineThickness,
              overlinePosition, overlineThickness);
        this.fontFaceElement = fontFaceElement;
    }

    /**
     * Returns the font associated with this rule or element.
     */
    public GVTFontFamily getFontFamily(BridgeContext ctx) {
        if (fontFamily != null)
            return fontFamily;

        Element fontElt = SVGUtilities.getParentElement(fontFaceElement);
        if (fontElt.getNamespaceURI().equals(SVG_NAMESPACE_URI) &&
            fontElt.getLocalName().equals(SVG_FONT_TAG)) {
            return new SVGFontFamily(this, fontElt, ctx);
        }

        fontFamily = super.getFontFamily(ctx);
        return fontFamily;
    }

    public Element getFontFaceElement() {
        return fontFaceElement;
    }

    /**
     * Default implementation uses the root element of the document 
     * associated with BridgeContext.  This is useful for CSS case.
     */
    protected Element getBaseElement(BridgeContext ctx) {
        if (fontFaceElement != null) 
            return fontFaceElement;
        return super.getBaseElement(ctx);
    }

}
