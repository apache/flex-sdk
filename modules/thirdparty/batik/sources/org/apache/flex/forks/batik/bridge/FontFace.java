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

import java.awt.Font;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.gvt.font.AWTFontFamily;
import org.apache.flex.forks.batik.gvt.font.FontFamilyResolver;
import org.apache.flex.forks.batik.gvt.font.GVTFontFace;
import org.apache.flex.forks.batik.gvt.font.GVTFontFamily;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGDocument;

/**
 * This class represents a &lt;font-face> element or @font-face rule
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: FontFace.java 588550 2007-10-26 07:52:41Z dvholten $
 */
public abstract class FontFace extends GVTFontFace
    implements ErrorConstants  {

    /**
     * List of ParsedURL's referencing SVGFonts or TrueType fonts,
     * or Strings naming locally installed fonts.
     */
    List srcs;

    /**
     * Constructes an SVGFontFace with the specfied font-face attributes.
     */
    public FontFace
        (List srcs,
         String familyName, float unitsPerEm, String fontWeight,
         String fontStyle, String fontVariant, String fontStretch,
         float slope, String panose1, float ascent, float descent,
         float strikethroughPosition, float strikethroughThickness,
         float underlinePosition,     float underlineThickness,
         float overlinePosition,      float overlineThickness) {
        super(familyName, unitsPerEm, fontWeight,
              fontStyle, fontVariant, fontStretch,
              slope, panose1, ascent, descent,
              strikethroughPosition, strikethroughThickness,
              underlinePosition, underlineThickness,
              overlinePosition, overlineThickness);
        this.srcs = srcs;
    }

    /**
     * Constructes an SVGFontFace with the specfied fontName.
     */
    protected FontFace(String familyName) {
        super(familyName);
    }

    public static CSSFontFace createFontFace(String familyName,
                                             FontFace src) {
        return new CSSFontFace
            (new LinkedList(src.srcs),
             familyName, src.unitsPerEm, src.fontWeight,
             src.fontStyle, src.fontVariant, src.fontStretch,
             src.slope, src.panose1, src.ascent, src.descent,
             src.strikethroughPosition, src.strikethroughThickness,
             src.underlinePosition, src.underlineThickness,
             src.overlinePosition, src.overlineThickness);
    }

    /**
     * Returns the font associated with this rule or element.
     */
    public GVTFontFamily getFontFamily(BridgeContext ctx) {
        String name = FontFamilyResolver.lookup(familyName);
        if (name != null) {
            GVTFontFace ff = createFontFace(name, this);
            return new AWTFontFamily(ff);
        }

        Iterator iter = srcs.iterator();
        while (iter.hasNext()) {
            Object o = iter.next();
            if (o instanceof String) {
                String str = (String)o;
                name = FontFamilyResolver.lookup(str);
                if (name != null) {
                    GVTFontFace ff = createFontFace(str, this);
                    return new AWTFontFamily(ff);
                }
            } else if (o instanceof ParsedURL) {
                try {
                    GVTFontFamily ff = getFontFamily(ctx, (ParsedURL)o);
                    if (ff != null)
                        return ff;
                } catch (SecurityException ex) {
                    // Security violation notify the user but keep going.
                    ctx.getUserAgent().displayError(ex);
                } catch (BridgeException ex) {
                    // If Security violation notify
                    // the user but keep going.
                    if (ERR_URI_UNSECURE.equals(ex.getCode()))
                        ctx.getUserAgent().displayError(ex);
                } catch (Exception ex) {
                    // Do nothing couldn't get Referenced URL.
                }
            }
        }

        return new AWTFontFamily(this);
    }

    /**
     * Tries to build a GVTFontFamily from a URL reference
     */
    protected GVTFontFamily getFontFamily(BridgeContext ctx,
                                          ParsedURL purl) {
        String purlStr = purl.toString();

        Element e = getBaseElement(ctx);
        SVGDocument svgDoc = (SVGDocument)e.getOwnerDocument();
        String docURL = svgDoc.getURL();
        ParsedURL pDocURL = null;
        if (docURL != null)
            pDocURL = new ParsedURL(docURL);

        // try to load an SVG document
        String baseURI = AbstractNode.getBaseURI(e);
        purl = new ParsedURL(baseURI, purlStr);
        UserAgent userAgent = ctx.getUserAgent();

        try {
            userAgent.checkLoadExternalResource(purl, pDocURL);
        } catch (SecurityException ex) {
            // Can't load font - Security violation.
            // We should not throw the error that is for certain, just
            // move down the font list, but do we display the error or not???
            // I'll vote yes just because it is a security exception (other
            // exceptions like font not available etc I would skip).
            userAgent.displayError(ex);
            return null;
        }

        if (purl.getRef() != null) {
            // Reference must be to a SVGFont.
            Element ref = ctx.getReferencedElement(e, purlStr);
            if (!ref.getNamespaceURI().equals(SVG_NAMESPACE_URI) ||
                !ref.getLocalName().equals(SVG_FONT_TAG)) {
                return null;
            }

            SVGDocument doc  = (SVGDocument)e.getOwnerDocument();
            SVGDocument rdoc = (SVGDocument)ref.getOwnerDocument();

            Element fontElt = ref;
            if (doc != rdoc) {
                fontElt = (Element)doc.importNode(ref, true);
                String base = AbstractNode.getBaseURI(ref);
                Element g = doc.createElementNS(SVG_NAMESPACE_URI, SVG_G_TAG);
                g.appendChild(fontElt);
                g.setAttributeNS(XMLConstants.XML_NAMESPACE_URI,
                                 "xml:base", base);
                CSSUtilities.computeStyleAndURIs(ref, fontElt, purlStr);
            }

            // Search for a font-face element
            Element fontFaceElt = null;
            for (Node n = fontElt.getFirstChild();
                 n != null;
                 n = n.getNextSibling()) {
                if ((n.getNodeType() == Node.ELEMENT_NODE) &&
                    n.getNamespaceURI().equals(SVG_NAMESPACE_URI) &&
                    n.getLocalName().equals(SVG_FONT_FACE_TAG)) {
                    fontFaceElt = (Element)n;
                    break;
                }
            }
            // todo : if the above loop fails to find a fontFaceElt, a null is passed to createFontFace()
            
            SVGFontFaceElementBridge fontFaceBridge;
            fontFaceBridge = (SVGFontFaceElementBridge)ctx.getBridge
                (SVG_NAMESPACE_URI, SVG_FONT_FACE_TAG);
            GVTFontFace gff = fontFaceBridge.createFontFace(ctx, fontFaceElt);


            return new SVGFontFamily(gff, fontElt, ctx);
        }
        // Must be a reference to a 'Web Font'.
        // Let's see if JDK can parse it.
        try {
            Font font = Font.createFont(Font.TRUETYPE_FONT,
                                        purl.openStream());
            return new AWTFontFamily(this, font);
        } catch (Exception ex) {
        }
        return null;
    }

    /**
     * Default implementation uses the root element of the document
     * associated with BridgeContext.  This is useful for CSS case.
     */
    protected Element getBaseElement(BridgeContext ctx) {
        SVGDocument d = (SVGDocument)ctx.getDocument();
        return d.getRootElement();
    }

}
