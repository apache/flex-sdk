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

import java.awt.font.FontRenderContext;
import java.text.AttributedCharacterIterator;

import org.apache.flex.forks.batik.gvt.font.AltGlyphHandler;
import org.apache.flex.forks.batik.gvt.font.GVTGlyphVector;
import org.apache.flex.forks.batik.gvt.font.Glyph;
import org.apache.flex.forks.batik.gvt.font.SVGGVTGlyphVector;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Element;

/**
 * SVG font altGlyph handler. This class handles the creation of an alternate
 * GVTGlyphVector for the altGlyph element.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: SVGAltGlyphHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGAltGlyphHandler implements AltGlyphHandler, SVGConstants {

    private BridgeContext ctx;
    private Element textElement;

    /**
     * Constructs an SVGAltGlyphHandler.
     *
     * @param ctx The bridge context, this is needed during rendering to find
     * any referenced glyph elements.
     * @param textElement The element that contains text to be replaced by the
     * alternate glyphs. This should be an altGlyph element.
     */
    public SVGAltGlyphHandler(BridgeContext ctx, Element textElement) {
        this.ctx = ctx;
        this.textElement = textElement;
    }

    /**
     * Creates a glyph vector containing the alternate glyphs.
     *
     * @param frc The current font render context.
     * @param fontSize The required font size.
     * @return The GVTGlyphVector containing the alternate glyphs, or null if
     * the alternate glyphs could not be found.
     */
    public GVTGlyphVector createGlyphVector
        (FontRenderContext frc, float fontSize,
         AttributedCharacterIterator aci) {
        try {
            if (SVG_NAMESPACE_URI.equals(textElement.getNamespaceURI()) &&
                SVG_ALT_GLYPH_TAG.equals(textElement.getLocalName())) {
                SVGAltGlyphElementBridge altGlyphBridge
                    = (SVGAltGlyphElementBridge)ctx.getBridge(textElement);
                Glyph[] glyphArray = altGlyphBridge.createAltGlyphArray
                    (ctx, textElement, fontSize, aci);
                if (glyphArray != null) {
                    return new SVGGVTGlyphVector(null, glyphArray, frc);
                }
            }
        } catch (SecurityException e) {
            ctx.getUserAgent().displayError(e);
            // Throw exception because we do not want to continue
            // processing. In the case of a SecurityException, the 
            // end user would get a lot of exception like this one.
            throw e;
        }

        return null;
    }
}

