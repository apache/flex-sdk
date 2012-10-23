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
package org.apache.flex.forks.batik.bridge.svg12;

import java.awt.Color;
import java.awt.Paint;
import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.bridge.AnimatableGenericSVGBridge;
import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.BridgeException;
import org.apache.flex.forks.batik.bridge.CSSUtilities;
import org.apache.flex.forks.batik.bridge.ErrorConstants;
import org.apache.flex.forks.batik.bridge.PaintBridge;
import org.apache.flex.forks.batik.bridge.PaintServer;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.svg.ICCColor;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.SVG12Constants;
import org.apache.flex.forks.batik.util.SVG12CSSConstants;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.dom.Element;
import org.w3c.dom.css.CSSValue;

/**
 * Bridge class for a regular polygon element.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas Deweese</a>
 * @version $Id: SVGSolidColorElementBridge.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class SVGSolidColorElementBridge extends AnimatableGenericSVGBridge
        implements PaintBridge {

    /**
     * Constructs a new bridge for the &lt;rect> element.
     */
    public SVGSolidColorElementBridge() { /* nothing */ }

    /**
     * Returns the SVG namespace URI.
     */
    public String getNamespaceURI() {
        return SVG12Constants.SVG_NAMESPACE_URI;
    }

    /**
     * Returns 'rect'.
     */
    public String getLocalName() {
        return SVG12Constants.SVG_SOLID_COLOR_TAG;
    }

    /**
     * Creates a <tt>Paint</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param paintElement the element that defines a Paint
     * @param paintedElement the element referencing the paint
     * @param paintedNode the graphics node on which the Paint will be applied
     * @param opacity the opacity of the Paint to create
     */
    public Paint createPaint(BridgeContext ctx,
                             Element paintElement,
                             Element paintedElement,
                             GraphicsNode paintedNode,
                             float opacity) {

        opacity = extractOpacity(paintElement, opacity, ctx);

        return extractColor(paintElement, opacity, ctx);
    }

    protected static float extractOpacity(Element paintElement,
                                          float opacity,
                                          BridgeContext ctx) {
        Map refs = new HashMap();
        CSSEngine eng = CSSUtilities.getCSSEngine(paintElement);
        int pidx = eng.getPropertyIndex
            (SVG12CSSConstants.CSS_SOLID_OPACITY_PROPERTY);

        for (;;) {
            Value opacityVal =
                CSSUtilities.getComputedStyle(paintElement, pidx);

            // Was solid-opacity explicity set on this element?
            StyleMap sm =
                ((CSSStylableElement)paintElement).getComputedStyleMap(null);
            if (!sm.isNullCascaded(pidx)) {
                // It was explicit...
                float attr = PaintServer.convertOpacity(opacityVal);
                return (opacity * attr);
            }

            String uri = XLinkSupport.getXLinkHref(paintElement);
            if (uri.length() == 0) {
                return opacity; // no xlink:href found, exit
            }

            SVGOMDocument doc = (SVGOMDocument)paintElement.getOwnerDocument();
            ParsedURL purl = new ParsedURL(doc.getURL(), uri);

            // check if there is circular dependencies
            if (refs.containsKey(purl)) {
                throw new BridgeException
                    (ctx, paintElement,
                     ErrorConstants.ERR_XLINK_HREF_CIRCULAR_DEPENDENCIES,
                     new Object[] {uri});
            }
            refs.put(purl, purl);
            paintElement = ctx.getReferencedElement(paintElement, uri);
        }
    }

    protected static Color extractColor(Element paintElement,
                                        float opacity,
                                        BridgeContext ctx) {
        Map refs = new HashMap();
        CSSEngine eng = CSSUtilities.getCSSEngine(paintElement);
        int pidx = eng.getPropertyIndex
            (SVG12CSSConstants.CSS_SOLID_COLOR_PROPERTY);

        for (;;) {
            Value colorDef =
                CSSUtilities.getComputedStyle(paintElement, pidx);

            // Was solid-color explicity set on this element?
            StyleMap sm =
                ((CSSStylableElement)paintElement).getComputedStyleMap(null);
            if (!sm.isNullCascaded(pidx)) {
                // It was explicit...
                if (colorDef.getCssValueType() ==
                    CSSValue.CSS_PRIMITIVE_VALUE) {
                    return PaintServer.convertColor(colorDef, opacity);
                } else {
                    return PaintServer.convertRGBICCColor
                        (paintElement, colorDef.item(0),
                         (ICCColor)colorDef.item(1),
                         opacity, ctx);
                }
            }


            String uri = XLinkSupport.getXLinkHref(paintElement);
            if (uri.length() == 0) {
                // no xlink:href found, exit
                return new Color(0, 0, 0, opacity);
            }

            SVGOMDocument doc = (SVGOMDocument)paintElement.getOwnerDocument();
            ParsedURL purl = new ParsedURL(doc.getURL(), uri);

            // check if there is circular dependencies
            if (refs.containsKey(purl)) {
                throw new BridgeException
                    (ctx, paintElement,
                     ErrorConstants.ERR_XLINK_HREF_CIRCULAR_DEPENDENCIES,
                     new Object[] {uri});
            }
            refs.put(purl, purl);
            paintElement = ctx.getReferencedElement(paintElement, uri);
        }
    }
}
