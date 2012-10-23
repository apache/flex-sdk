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
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.dom.svg.SVGContext;
import org.apache.flex.forks.batik.ext.awt.MultipleGradientPaint;
import org.apache.flex.forks.batik.ext.awt.RadialGradientPaint;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;radialGradient> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGRadialGradientElementBridge.java 594776 2007-11-14 05:34:02Z cam $
 */
public class SVGRadialGradientElementBridge
    extends AbstractSVGGradientElementBridge {


    /**
     * Constructs a new SVGRadialGradientElementBridge.
     */
    public SVGRadialGradientElementBridge() {}

    /**
     * Returns 'radialGradient'.
     */
    public String getLocalName() {
        return SVG_RADIAL_GRADIENT_TAG;
    }

    /**
     * Builds a radial gradient according to the specified parameters.
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
    protected
        Paint buildGradient(Element paintElement,
                            Element paintedElement,
                            GraphicsNode paintedNode,
                            MultipleGradientPaint.CycleMethodEnum spreadMethod,
                            MultipleGradientPaint.ColorSpaceEnum colorSpace,
                            AffineTransform transform,
                            Color [] colors,
                            float [] offsets,
                            BridgeContext ctx) {

        // 'cx' attribute - default is 50%
        String cxStr = SVGUtilities.getChainableAttributeNS
            (paintElement, null, SVG_CX_ATTRIBUTE, ctx);
        if (cxStr.length() == 0) {
            cxStr = SVG_RADIAL_GRADIENT_CX_DEFAULT_VALUE;
        }

        // 'cy' attribute - default is 50%
        String cyStr = SVGUtilities.getChainableAttributeNS
            (paintElement, null, SVG_CY_ATTRIBUTE, ctx);
        if (cyStr.length() == 0) {
            cyStr = SVG_RADIAL_GRADIENT_CY_DEFAULT_VALUE;
        }

        // 'r' attribute - default is 50%
        String rStr = SVGUtilities.getChainableAttributeNS
            (paintElement, null, SVG_R_ATTRIBUTE, ctx);
        if (rStr.length() == 0) {
            rStr = SVG_RADIAL_GRADIENT_R_DEFAULT_VALUE;
        }

        // 'fx' attribute - default is same as cx
        String fxStr = SVGUtilities.getChainableAttributeNS
            (paintElement, null, SVG_FX_ATTRIBUTE, ctx);
        if (fxStr.length() == 0) {
            fxStr = cxStr;
        }

        // 'fy' attribute - default is same as cy
        String fyStr = SVGUtilities.getChainableAttributeNS
            (paintElement, null, SVG_FY_ATTRIBUTE, ctx);
        if (fyStr.length() == 0) {
            fyStr = cyStr;
        }

        // 'gradientUnits' attribute - default is objectBoundingBox
        short coordSystemType;
        String s = SVGUtilities.getChainableAttributeNS
            (paintElement, null, SVG_GRADIENT_UNITS_ATTRIBUTE, ctx);
        if (s.length() == 0) {
            coordSystemType = SVGUtilities.OBJECT_BOUNDING_BOX;
        } else {
            coordSystemType = SVGUtilities.parseCoordinateSystem
                (paintElement, SVG_GRADIENT_UNITS_ATTRIBUTE, s, ctx);
        }

        // The last paragraph of section 7.11 in SVG 1.1 states that objects
        // with zero width or height bounding boxes that use gradients with
        // gradientUnits="objectBoundingBox" must not use the gradient.
        SVGContext bridge = BridgeContext.getSVGContext(paintedElement);
        if (coordSystemType == SVGUtilities.OBJECT_BOUNDING_BOX
                && bridge instanceof AbstractGraphicsNodeBridge) {
            // XXX Make this work for non-AbstractGraphicsNodeBridges, like
            // the various text child bridges.
            Rectangle2D bbox = ((AbstractGraphicsNodeBridge) bridge).getBBox();
            if (bbox != null && bbox.getWidth() == 0 || bbox.getHeight() == 0) {
                return null;
            }
        }

        // additional transform to move to objectBoundingBox coordinate system
        if (coordSystemType == SVGUtilities.OBJECT_BOUNDING_BOX) {
            transform = SVGUtilities.toObjectBBox(transform,
                                                  paintedNode);
        }
        UnitProcessor.Context uctx
            = UnitProcessor.createContext(ctx, paintElement);

        float r = SVGUtilities.convertLength(rStr,
                                             SVG_R_ATTRIBUTE,
                                             coordSystemType,
                                             uctx);
        // A value of zero will cause the area to be painted as a single color
        // using the color and opacity of the last gradient stop.
        if (r == 0) {
            return colors[colors.length-1];
        } else {
            Point2D c = SVGUtilities.convertPoint(cxStr,
                                                  SVG_CX_ATTRIBUTE,
                                                  cyStr,
                                                  SVG_CY_ATTRIBUTE,
                                                  coordSystemType,
                                                  uctx);

            Point2D f = SVGUtilities.convertPoint(fxStr,
                                                  SVG_FX_ATTRIBUTE,
                                                  fyStr,
                                                  SVG_FY_ATTRIBUTE,
                                                  coordSystemType,
                                                  uctx);

            // <!> FIXME: colorSpace ignored for radial gradient at this time
            return new RadialGradientPaint(c,
                                           r,
                                           f,
                                           offsets,
                                           colors,
                                           spreadMethod,
                                           RadialGradientPaint.SRGB,
                                           transform);
        }
    }
}
