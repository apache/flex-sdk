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
import java.awt.geom.Rectangle2D;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.FilterAlphaRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.FilterColorInterpolation;
import org.apache.flex.forks.batik.ext.awt.image.renderable.FloodRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.filter.BackgroundRable8Bit;
import org.w3c.dom.Element;

/**
 * The base bridge class for SVG filter primitives.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: AbstractSVGFilterPrimitiveElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public abstract class AbstractSVGFilterPrimitiveElementBridge
        extends AnimatableGenericSVGBridge
        implements FilterPrimitiveBridge, ErrorConstants {

    /**
     * Constructs a new bridge for a filter primitive element.
     */
    protected AbstractSVGFilterPrimitiveElementBridge() {}

    /**
     * Returns the input source of the specified filter primitive
     * element defined by its 'in' attribute.
     *
     * @param filterElement the filter primitive element
     * @param filteredElement the element on which the filter is referenced
     * @param filteredNode the graphics node on which the filter is applied
     * @param inputFilter the default input filter
     * @param filterMap the map that containes the named filter primitives
     * @param ctx the bridge context
     */
    protected static Filter getIn(Element filterElement,
                                  Element filteredElement,
                                  GraphicsNode filteredNode,
                                  Filter inputFilter,
                                  Map filterMap,
                                  BridgeContext ctx) {

        String s = filterElement.getAttributeNS(null, SVG_IN_ATTRIBUTE);
        if (s.length() == 0) {
            return inputFilter;
        } else {
            return getFilterSource(filterElement,
                                   s,
                                   filteredElement,
                                   filteredNode,
                                   filterMap,
                                   ctx);
        }
    }

    /**
     * Returns the input source of the specified filter primitive
     * element defined by its 'in2' attribute. The 'in2' attribute is assumed
     * to be required if the subclasses ask for it.
     *
     * @param filterElement the filter primitive element
     * @param filteredElement the element on which the filter is referenced
     * @param filteredNode the graphics node on which the filter is applied
     * @param inputFilter the default input filter
     * @param filterMap the map that containes the named filter primitives
     * @param ctx the bridge context
     */
    protected static Filter getIn2(Element filterElement,
                                   Element filteredElement,
                                   GraphicsNode filteredNode,
                                   Filter inputFilter,
                                   Map filterMap,
                                   BridgeContext ctx) {

        String s = filterElement.getAttributeNS(null, SVG_IN2_ATTRIBUTE);
        if (s.length() == 0) {
            throw new BridgeException(ctx, filterElement, ERR_ATTRIBUTE_MISSING,
                                      new Object [] {SVG_IN2_ATTRIBUTE});
        }
        return getFilterSource(filterElement,
                               s,
                               filteredElement,
                               filteredNode,
                               filterMap,
                               ctx);
    }

    /**
     * Updates the filterMap according to the specified parameters.
     *
     * @param filterElement the filter primitive element
     * @param filter the filter that is part of the filter chain
     * @param filterMap the filter map to update
     */
    protected static void updateFilterMap(Element filterElement,
                                          Filter filter,
                                          Map filterMap) {

        String s = filterElement.getAttributeNS(null, SVG_RESULT_ATTRIBUTE);
        if ((s.length() != 0) && (s.trim().length() != 0)) {
            filterMap.put(s, filter);
        }
    }

    /**
     * Handles the 'color-interpolation-filters' CSS property.
     *
     * @param filter the filter
     * @param filterElement the filter element
     */
    protected static void handleColorInterpolationFilters(Filter filter,
                                                          Element filterElement) {
        if (filter instanceof FilterColorInterpolation) {
            boolean isLinear
                = CSSUtilities.convertColorInterpolationFilters(filterElement);
            // System.out.println("IsLinear: " + isLinear +
            //                    " Filter: " + filter);
            ((FilterColorInterpolation)filter).setColorSpaceLinear(isLinear);
        }
    }

    /**
     * Returns the filter source according to the specified parameters.
     *
     * @param filterElement the filter element
     * @param s the input of the filter primitive
     * @param filteredElement the filtered element
     * @param filteredNode the filtered graphics node
     * @param filterMap the filter map that contains named filter primitives
     * @param ctx the bridge context
     */
    static Filter getFilterSource(Element filterElement,
                                  String s,
                                  Element filteredElement,
                                  GraphicsNode filteredNode,
                                  Map filterMap,
                                  BridgeContext ctx) {

        // SourceGraphic
        Filter srcG = (Filter)filterMap.get(SVG_SOURCE_GRAPHIC_VALUE);
        Rectangle2D filterRegion = srcG.getBounds2D();

        int length = s.length();
        Filter source = null;
        switch (length) {
        case 13:
            if (SVG_SOURCE_GRAPHIC_VALUE.equals(s)) {
                // SourceGraphic
                source = srcG;
            }
            break;
        case 11:
            if (s.charAt(1) == SVG_SOURCE_ALPHA_VALUE.charAt(1)) {
                if (SVG_SOURCE_ALPHA_VALUE.equals(s)) {
                    // SourceAlpha
                    source = srcG;
                    source = new FilterAlphaRable(source);
                }
            } else if (SVG_STROKE_PAINT_VALUE.equals(s)) {
                    // StrokePaint
                    Paint paint = PaintServer.convertStrokePaint
                        (filteredElement,filteredNode, ctx);
                    // <!> FIXME: Should we create a transparent flood ???
                    source = new FloodRable8Bit(filterRegion, paint);
            }
            break;
        case 15:
            if (s.charAt(10) == SVG_BACKGROUND_IMAGE_VALUE.charAt(10)) {
                if (SVG_BACKGROUND_IMAGE_VALUE.equals(s)) {
                    // BackgroundImage
                    source = new BackgroundRable8Bit(filteredNode);
                    source = new PadRable8Bit(source, filterRegion,
                                              PadMode.ZERO_PAD);
                }
            } else if (SVG_BACKGROUND_ALPHA_VALUE.equals(s)) {
                // BackgroundAlpha
                source = new BackgroundRable8Bit(filteredNode);
                source = new FilterAlphaRable(source);
                source = new PadRable8Bit(source, filterRegion,
                                          PadMode.ZERO_PAD);
            }
            break;
        case 9:
            if (SVG_FILL_PAINT_VALUE.equals(s)) {
                // FillPaint
                Paint paint = PaintServer.convertFillPaint
                    (filteredElement,filteredNode, ctx);
                if (paint == null) {
                    paint = new Color(0, 0, 0, 0); // create a transparent flood
                }
                source = new FloodRable8Bit(filterRegion, paint);
            }
            break;
        }
        if (source == null) {
            // <identifier>
            source = (Filter)filterMap.get(s);
        }
        return source;
    }

    /**
     * This is a bit of a hack but we set the flood bounds to
     * -floatmax/2 -> floatmax/2 (should cover the area ok).
     */
    static final Rectangle2D INFINITE_FILTER_REGION
        = new Rectangle2D.Float(-Float.MAX_VALUE/2,
                                -Float.MAX_VALUE/2,
                                Float.MAX_VALUE,
                                Float.MAX_VALUE);



    /**
     * Converts on the specified filter primitive element, the specified
     * attribute that represents an integer and with the specified
     * default value.
     *
     * @param filterElement the filter primitive element
     * @param attrName the name of the attribute
     * @param defaultValue the default value of the attribute
     * @param ctx the BridgeContext to use for error information
     */
    protected static int convertInteger(Element filterElement,
                                        String attrName,
                                        int defaultValue,
                                        BridgeContext ctx) {
        String s = filterElement.getAttributeNS(null, attrName);
        if (s.length() == 0) {
            return defaultValue;
        } else {
            try {
                return SVGUtilities.convertSVGInteger(s);
            } catch (NumberFormatException nfEx ) {
                throw new BridgeException
                    (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {attrName, s});
            }
        }
    }

    /**
     * Converts on the specified filter primitive element, the specified
     * attribute that represents a float and with the specified
     * default value.
     *
     * @param filterElement the filter primitive element
     * @param attrName the name of the attribute
     * @param defaultValue the default value of the attribute
     * @param ctx the BridgeContext to use for error information
     */
    protected static float convertNumber(Element filterElement,
                                         String attrName,
                                         float defaultValue,
                                         BridgeContext ctx) {

        String s = filterElement.getAttributeNS(null, attrName);
        if (s.length() == 0) {
            return defaultValue;
        } else {
            try {
                return SVGUtilities.convertSVGNumber(s);
            } catch (NumberFormatException nfEx) {
                throw new BridgeException
                    (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {attrName, s, nfEx});
            }
        }
    }
}
