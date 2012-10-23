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

import java.awt.Color;
import java.awt.Paint;
import java.awt.geom.AffineTransform;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.ext.awt.MultipleGradientPaint;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.ParsedURL;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * Bridge class for vending gradients.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: AbstractSVGGradientElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public abstract class AbstractSVGGradientElementBridge
        extends AnimatableGenericSVGBridge
        implements PaintBridge, ErrorConstants {

    /**
     * Constructs a new AbstractSVGGradientElementBridge.
     */
    protected AbstractSVGGradientElementBridge() {}

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

        String s;

        // stop elements
        List stops = extractStop(paintElement, opacity, ctx);
        // if no stops are defined, painting is the same as 'none'
        if (stops == null) {
            return null;
        }
        int stopLength = stops.size();
        // if one stops is defined, painting is the same as a single color
        if (stopLength == 1) {
            return ((Stop)stops.get(0)).color;
        }
        float [] offsets = new float[stopLength];
        Color [] colors = new Color[stopLength];
        Iterator iter = stops.iterator();
        for (int i=0; iter.hasNext(); ++i) {
            Stop stop = (Stop)iter.next();
            offsets[i] = stop.offset;
            colors[i] = stop.color;
        }

        // 'spreadMethod' attribute - default is pad
        MultipleGradientPaint.CycleMethodEnum spreadMethod
            = MultipleGradientPaint.NO_CYCLE;
        s = SVGUtilities.getChainableAttributeNS
            (paintElement, null, SVG_SPREAD_METHOD_ATTRIBUTE, ctx);
        if (s.length() != 0) {
            spreadMethod = convertSpreadMethod(paintElement, s, ctx);
        }

        // 'color-interpolation' CSS property
        MultipleGradientPaint.ColorSpaceEnum colorSpace
            = CSSUtilities.convertColorInterpolation(paintElement);

        // 'gradientTransform' attribute - default is an Identity matrix
        AffineTransform transform;
        s = SVGUtilities.getChainableAttributeNS
            (paintElement, null, SVG_GRADIENT_TRANSFORM_ATTRIBUTE, ctx);
        if (s.length() != 0) {
            transform = SVGUtilities.convertTransform
                (paintElement, SVG_GRADIENT_TRANSFORM_ATTRIBUTE, s, ctx);
        } else {
            transform = new AffineTransform();
        }

        Paint paint = buildGradient(paintElement,
                                    paintedElement,
                                    paintedNode,
                                    spreadMethod,
                                    colorSpace,
                                    transform,
                                    colors,
                                    offsets,
                                    ctx);
        return paint;
    }

    /**
     * Builds a concrete gradient according to the specified parameters.
     *
     * @param paintElement the element that defines a Paint
     * @param paintedElement the element referencing the paint
     * @param paintedNode the graphics node on which the Paint will be applied
     * @param spreadMethod the spread method
     * @param colorSpace the color space (sRGB | LinearRGB)
     * @param transform the gradient transform
     * @param colors the colors of the gradient
     * @param offsets the offsets
     * @param ctx the bridge context to use
     */
    protected abstract
        Paint buildGradient(Element paintElement,
                            Element paintedElement,
                            GraphicsNode paintedNode,
                            MultipleGradientPaint.CycleMethodEnum spreadMethod,
                            MultipleGradientPaint.ColorSpaceEnum colorSpace,
                            AffineTransform transform,
                            Color [] colors,
                            float [] offsets,
                            BridgeContext ctx);

    // convenient methods

    /**
     * Converts the spreadMethod attribute.
     *
     * @param paintElement the paint Element with a spreadMethod
     * @param s the spread method
     * @param ctx the BridgeContext to use for error information
     */
    protected static MultipleGradientPaint.CycleMethodEnum convertSpreadMethod
        (Element paintElement, String s, BridgeContext ctx) {
        if (SVG_REPEAT_VALUE.equals(s)) {
            return MultipleGradientPaint.REPEAT;
        }
        if (SVG_REFLECT_VALUE.equals(s)) {
            return MultipleGradientPaint.REFLECT;
        }
        if (SVG_PAD_VALUE.equals(s)) {
            return MultipleGradientPaint.NO_CYCLE;
        }
        throw new BridgeException
            (ctx, paintElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
             new Object[] {SVG_SPREAD_METHOD_ATTRIBUTE, s});
    }

    /**
     * Returns the stops elements of the specified gradient
     * element. Stops can be children of the gradients or defined on
     * one of its 'ancestor' (linked with the xlink:href attribute).
     *
     * @param paintElement the gradient element
     * @param opacity the opacity
     * @param ctx the bridge context to use
     */
    protected static List extractStop(Element paintElement,
                                      float opacity,
                                      BridgeContext ctx) {

        List refs = new LinkedList();
        for (;;) {
            List stops = extractLocalStop(paintElement, opacity, ctx);
            if (stops != null) {
                return stops; // stop elements found, exit
            }
            String uri = XLinkSupport.getXLinkHref(paintElement);
            if (uri.length() == 0) {
                return null; // no xlink:href found, exit
            }
            // check if there is circular dependencies
            String baseURI = ((AbstractNode) paintElement).getBaseURI();
            ParsedURL purl = new ParsedURL(baseURI, uri);

            if (contains(refs, purl)) {
                throw new BridgeException(ctx, paintElement,
                                          ERR_XLINK_HREF_CIRCULAR_DEPENDENCIES,
                                          new Object[] {uri});
            }
            refs.add(purl);
            paintElement = ctx.getReferencedElement(paintElement, uri);
        }
    }

    /**
     * Returns a list of <tt>Stop</tt> elements, children of the
     * specified paintElement can have or null if any.
     *
     * @param gradientElement the paint element
     * @param opacity the opacity
     * @param ctx the bridge context
     */
    protected static List extractLocalStop(Element gradientElement,
                                           float opacity,
                                           BridgeContext ctx) {
        LinkedList stops = null;
        Stop previous = null;
        for (Node n = gradientElement.getFirstChild();
             n != null;
             n = n.getNextSibling()) {

            if ((n.getNodeType() != Node.ELEMENT_NODE)) {
                continue;
            }

            Element e = (Element)n;
            Bridge bridge = ctx.getBridge(e);
            if (bridge == null || !(bridge instanceof SVGStopElementBridge)) {
                continue;
            }
            Stop stop = ((SVGStopElementBridge)bridge).createStop
                (ctx, gradientElement, e, opacity);
            if (stops == null) {
                stops = new LinkedList();
            }
            if (previous != null) {
                if (stop.offset < previous.offset) {
                    stop.offset = previous.offset;
                }
            }
            stops.add(stop);
            previous = stop;
        }
        return stops;
    }

    /**
     * Returns true if the specified list of URLs contains the specified url.
     *
     * @param urls the list of URLs
     * @param key the url to search for
     */
    private static boolean contains(List urls, ParsedURL key) {
        Iterator iter = urls.iterator();
        while (iter.hasNext()) {
            if (key.equals(iter.next()))
                return true;
        }
        return false;
    }

    /**
     * This class represents a gradient &lt;stop> element.
     */
    public static class Stop {

        /** The stop color. */
        public Color color;
        /** The stop offset. */
        public float offset;

        /**
         * Constructs a new stop definition.
         *
         * @param color the stop color
         * @param offset the stop offset
         */
        public Stop(Color color, float offset) {
            this.color = color;
            this.offset = offset;
        }
    }

    /**
     * Bridge class for the gradient &lt;stop> element.
     */
    public static class SVGStopElementBridge extends AnimatableGenericSVGBridge
            implements Bridge {

        /**
         * Returns 'stop'.
         */
        public String getLocalName() {
            return SVG_STOP_TAG;
        }

        /**
         * Creates a <tt>Stop</tt> according to the specified parameters.
         *
         * @param ctx the bridge context to use
         * @param gradientElement the gradient element
         * @param stopElement the stop element
         * @param opacity an additional opacity of the stop color
         */
        public Stop createStop(BridgeContext ctx,
                               Element gradientElement,
                               Element stopElement,
                               float opacity) {

            String s = stopElement.getAttributeNS(null, SVG_OFFSET_ATTRIBUTE);
            if (s.length() == 0) {
                throw new BridgeException
                    (ctx, stopElement, ERR_ATTRIBUTE_MISSING,
                     new Object[] {SVG_OFFSET_ATTRIBUTE});
            }
            float offset;
            try {
                offset = SVGUtilities.convertRatio(s);
            } catch (NumberFormatException nfEx ) {
                throw new BridgeException
                    (ctx, stopElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {SVG_OFFSET_ATTRIBUTE, s, nfEx });
            }
            Color color
                = CSSUtilities.convertStopColor(stopElement, opacity, ctx);

            return new Stop(color, offset);
        }
    }
}
