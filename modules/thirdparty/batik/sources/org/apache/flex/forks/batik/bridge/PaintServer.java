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

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Paint;
import java.awt.Shape;
import java.awt.Stroke;

import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.svg.ICCColor;
import org.apache.flex.forks.batik.ext.awt.color.ICCColorSpaceExt;
import org.apache.flex.forks.batik.gvt.CompositeShapePainter;
import org.apache.flex.forks.batik.gvt.FillShapePainter;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.Marker;
import org.apache.flex.forks.batik.gvt.MarkerShapePainter;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.ShapePainter;
import org.apache.flex.forks.batik.gvt.StrokeShapePainter;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Element;
import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.css.CSSValue;

/**
 * A collection of utility methods to deliver <tt>java.awt.Paint</tt>,
 * <tt>java.awt.Stroke</tt> objects that could be used to paint a
 * shape. This class also provides additional methods the deliver SVG
 * Paint using the ShapePainter interface.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: PaintServer.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public abstract class PaintServer
    implements SVGConstants, CSSConstants, ErrorConstants {

    /**
     * No instance of this class is required.
     */
    protected PaintServer() {}


    /////////////////////////////////////////////////////////////////////////
    // 'marker-start', 'marker-mid', 'marker-end' delegates to the PaintServer
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns a <tt>ShapePainter</tt> defined on the specified
     * element and for the specified shape node.
     *
     * @param e the element with the marker CSS properties
     * @param node the shape node
     * @param ctx the bridge context
     */
    public static ShapePainter convertMarkers(Element e,
                                              ShapeNode node,
                                              BridgeContext ctx) {
        Value v;
        v = CSSUtilities.getComputedStyle(e, SVGCSSEngine.MARKER_START_INDEX);
        Marker startMarker = convertMarker(e, v, ctx);
        v = CSSUtilities.getComputedStyle(e, SVGCSSEngine.MARKER_MID_INDEX);
        Marker midMarker = convertMarker(e, v, ctx);
        v = CSSUtilities.getComputedStyle(e, SVGCSSEngine.MARKER_END_INDEX);
        Marker endMarker = convertMarker(e, v, ctx);

        if (startMarker != null || midMarker != null || endMarker != null) {
            MarkerShapePainter p = new MarkerShapePainter(node.getShape());
            p.setStartMarker(startMarker);
            p.setMiddleMarker(midMarker);
            p.setEndMarker(endMarker);
            return p;
        } else {
            return null;
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // org.apache.flex.forks.batik.gvt.Marker
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns a <tt>Marker</tt> defined on the specified element by
     * the specified value, and for the specified shape node.
     *
     * @param e the painted element
     * @param v the CSS value describing the marker to construct
     * @param ctx the bridge context
     */
    public static Marker convertMarker(Element e,
                                       Value v,
                                       BridgeContext ctx) {

        if (v.getPrimitiveType() == CSSPrimitiveValue.CSS_IDENT) {
            return null; // 'none'
        } else {
            String uri = v.getStringValue();
            Element markerElement = ctx.getReferencedElement(e, uri);
            Bridge bridge = ctx.getBridge(markerElement);
            if (bridge == null || !(bridge instanceof MarkerBridge)) {
                throw new BridgeException(ctx, e, ERR_CSS_URI_BAD_TARGET,
                                          new Object[] {uri});
            }
            return ((MarkerBridge)bridge).createMarker(ctx, markerElement, e);
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // 'stroke', 'fill' ... converts to ShapePainter
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns a <tt>ShapePainter</tt> defined on the specified element and
     * for the specified shape node, and using the specified bridge
     * context.
     *
     * @param e the element interested in a shape painter
     * @param node the shape node
     * @param ctx the bridge context
     */
    public static ShapePainter convertFillAndStroke(Element e,
                                                    ShapeNode node,
                                                    BridgeContext ctx) {
        Shape shape = node.getShape();
        if (shape == null) return null;

        Paint  fillPaint   = convertFillPaint  (e, node, ctx);
        FillShapePainter fp = new FillShapePainter(shape);
        fp.setPaint(fillPaint);

        Stroke stroke      = convertStroke     (e);
        if (stroke == null)
            return fp;

        Paint  strokePaint = convertStrokePaint(e, node, ctx);
        StrokeShapePainter sp = new StrokeShapePainter(shape);
        sp.setStroke(stroke);
        sp.setPaint(strokePaint);

        CompositeShapePainter cp = new CompositeShapePainter(shape);
        cp.addShapePainter(fp);
        cp.addShapePainter(sp);
        return cp;
    }


    public static ShapePainter convertStrokePainter(Element e,
                                                    ShapeNode node,
                                                    BridgeContext ctx) {
        Shape shape = node.getShape();
        if (shape == null) return null;

        Stroke stroke = convertStroke(e);
        if (stroke == null)
            return null;

        Paint  strokePaint = convertStrokePaint(e, node, ctx);
        StrokeShapePainter sp = new StrokeShapePainter(shape);
        sp.setStroke(stroke);
        sp.setPaint(strokePaint);
        return sp;
    }

    /////////////////////////////////////////////////////////////////////////
    // java.awt.Paint
    /////////////////////////////////////////////////////////////////////////

    /**
     * Converts for the specified element, its stroke paint properties
     * to a Paint object.
     *
     * @param strokedElement the element interested in a Paint
     * @param strokedNode the graphics node to stroke
     * @param ctx the bridge context
     */
    public static Paint convertStrokePaint(Element strokedElement,
                                           GraphicsNode strokedNode,
                                           BridgeContext ctx) {
        Value v = CSSUtilities.getComputedStyle
            (strokedElement, SVGCSSEngine.STROKE_OPACITY_INDEX);
        float opacity = convertOpacity(v);
        v = CSSUtilities.getComputedStyle
            (strokedElement, SVGCSSEngine.STROKE_INDEX);

        return convertPaint(strokedElement,
                            strokedNode,
                            v,
                            opacity,
                            ctx);
    }

    /**
     * Converts for the specified element, its fill paint properties
     * to a Paint object.
     *
     * @param filledElement the element interested in a Paint
     * @param filledNode the graphics node to fill
     * @param ctx the bridge context
     */
    public static Paint convertFillPaint(Element filledElement,
                                         GraphicsNode filledNode,
                                         BridgeContext ctx) {
        Value v = CSSUtilities.getComputedStyle
            (filledElement, SVGCSSEngine.FILL_OPACITY_INDEX);
        float opacity = convertOpacity(v);
        v = CSSUtilities.getComputedStyle
            (filledElement, SVGCSSEngine.FILL_INDEX);

        return convertPaint(filledElement,
                            filledNode,
                            v,
                            opacity,
                            ctx);
    }

    /**
     * Converts a Paint definition to a concrete <tt>java.awt.Paint</tt>
     * instance according to the specified parameters.
     *
     * @param paintedElement the element interested in a Paint
     * @param paintedNode the graphics node to paint (objectBoundingBox)
     * @param paintDef the paint definition
     * @param opacity the opacity to consider for the Paint
     * @param ctx the bridge context
     */
    public static Paint convertPaint(Element paintedElement,
                                        GraphicsNode paintedNode,
                                        Value paintDef,
                                        float opacity,
                                        BridgeContext ctx) {
        if (paintDef.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE) {
            switch (paintDef.getPrimitiveType()) {
            case CSSPrimitiveValue.CSS_IDENT:
                return null; // none

            case CSSPrimitiveValue.CSS_RGBCOLOR:
                return convertColor(paintDef, opacity);

            case CSSPrimitiveValue.CSS_URI:
                return convertURIPaint(paintedElement,
                                       paintedNode,
                                       paintDef,
                                       opacity,
                                       ctx);

            default:
                throw new IllegalArgumentException
                    ("Paint argument is not an appropriate CSS value");
            }
        } else { // List
            Value v = paintDef.item(0);
            switch (v.getPrimitiveType()) {
            case CSSPrimitiveValue.CSS_RGBCOLOR:
                return convertRGBICCColor(paintedElement, v,
                                          (ICCColor)paintDef.item(1),
                                          opacity, ctx);

            case CSSPrimitiveValue.CSS_URI: {
                Paint result = silentConvertURIPaint(paintedElement,
                                                     paintedNode,
                                                     v, opacity, ctx);
                if (result != null) return result;

                v = paintDef.item(1);
                switch (v.getPrimitiveType()) {
                case CSSPrimitiveValue.CSS_IDENT:
                    return null; // none

                case CSSPrimitiveValue.CSS_RGBCOLOR:
                    if (paintDef.getLength() == 2) {
                        return convertColor(v, opacity);
                    } else {
                        return convertRGBICCColor(paintedElement, v,
                                                  (ICCColor)paintDef.item(2),
                                                  opacity, ctx);
                    }
                default:
                    throw new IllegalArgumentException
                        ("Paint argument is not an appropriate CSS value");
                }
            }
            default:
                // can't be reached
                throw new IllegalArgumentException
                    ("Paint argument is not an appropriate CSS value");
            }
        }
    }

    /**
     * Converts a Paint specified by URI without sending any error.
     * if a problem occured while processing the URI, it just returns
     * null (same effect as 'none')
     *
     * @param paintedElement the element interested in a Paint
     * @param paintedNode the graphics node to paint (objectBoundingBox)
     * @param paintDef the paint definition
     * @param opacity the opacity to consider for the Paint
     * @param ctx the bridge context
     * @return the paint object or null when impossible
     */
    public static Paint silentConvertURIPaint(Element paintedElement,
                                              GraphicsNode paintedNode,
                                              Value paintDef,
                                              float opacity,
                                              BridgeContext ctx) {
        Paint paint = null;
        try {
            paint = convertURIPaint(paintedElement, paintedNode,
                                    paintDef, opacity, ctx);
        } catch (BridgeException ex) {
        }
        return paint;
    }

    /**
     * Converts a Paint specified as a URI.
     *
     * @param paintedElement the element interested in a Paint
     * @param paintedNode the graphics node to paint (objectBoundingBox)
     * @param paintDef the paint definition
     * @param opacity the opacity to consider for the Paint
     * @param ctx the bridge context
     */
    public static Paint convertURIPaint(Element paintedElement,
                                        GraphicsNode paintedNode,
                                        Value paintDef,
                                        float opacity,
                                        BridgeContext ctx) {

        String uri = paintDef.getStringValue();
        Element paintElement = ctx.getReferencedElement(paintedElement, uri);

        Bridge bridge = ctx.getBridge(paintElement);
        if (bridge == null || !(bridge instanceof PaintBridge)) {
            throw new BridgeException
                (ctx, paintedElement, ERR_CSS_URI_BAD_TARGET,
                 new Object[] {uri});
        }
        return ((PaintBridge)bridge).createPaint(ctx,
                                                 paintElement,
                                                 paintedElement,
                                                 paintedNode,
                                                 opacity);
    }

    /**
     * Returns a Color object that corresponds to the input Paint's
     * ICC color value or an RGB color if the related color profile
     * could not be used or loaded for any reason.
     *
     * @param paintedElement the element using the color
     * @param colorDef the color definition
     * @param iccColor the ICC color definition
     * @param opacity the opacity
     * @param ctx the bridge context to use
     */
    public static Color convertRGBICCColor(Element paintedElement,
                                           Value colorDef,
                                           ICCColor iccColor,
                                           float opacity,
                                           BridgeContext ctx) {
        Color color = null;
        if (iccColor != null){
            color = convertICCColor(paintedElement, iccColor, opacity, ctx);
        }
        if (color == null){
            color = convertColor(colorDef, opacity);
        }
        return color;
    }

    /**
     * Returns a Color object that corresponds to the input Paint's
     * ICC color value or null if the related color profile could not
     * be used or loaded for any reason.
     *
     * @param e the element using the color
     * @param c the ICC color definition
     * @param opacity the opacity
     * @param ctx the bridge context to use
     */
    public static Color convertICCColor(Element e,
                                        ICCColor c,
                                        float opacity,
                                        BridgeContext ctx){
        // Get ICC Profile's name
        String iccProfileName = c.getColorProfile();
        if (iccProfileName == null){
            return null;
        }
        // Ask the bridge to map the ICC profile name to an  ICC_Profile object
        SVGColorProfileElementBridge profileBridge
            = (SVGColorProfileElementBridge)
            ctx.getBridge(SVG_NAMESPACE_URI, SVG_COLOR_PROFILE_TAG);
        if (profileBridge == null){
            return null; // no bridge for color profile
        }

        ICCColorSpaceExt profileCS
            = profileBridge.createICCColorSpaceExt(ctx, e, iccProfileName);
        if (profileCS == null){
            return null; // no profile
        }

        // Now, convert the colors to an array of floats
        int n = c.getNumberOfColors();
        float[] colorValue = new float[n];
        if (n == 0) {
            return null;
        }
        for (int i = 0; i < n; i++) {
            colorValue[i] = c.getColor(i);
        }

        // Convert values to RGB
        float[] rgb = profileCS.intendedToRGB(colorValue);
        return new Color(rgb[0], rgb[1], rgb[2], opacity);
    }

    /**
     * Converts the given Value and opacity to a Color object.
     * @param c The CSS color to convert.
     * @param opacity The opacity value (0 &lt;= o &lt;= 1).
     */
    public static Color convertColor(Value c, float opacity) {
        int r = resolveColorComponent(c.getRed());
        int g = resolveColorComponent(c.getGreen());
        int b = resolveColorComponent(c.getBlue());
        return new Color(r, g, b, Math.round(opacity * 255f));
    }

    /////////////////////////////////////////////////////////////////////////
    // java.awt.stroke
    /////////////////////////////////////////////////////////////////////////

    /**
     * Converts a <tt>Stroke</tt> object defined on the specified element.
     *
     * @param e the element on which the stroke is specified
     */
    public static Stroke convertStroke(Element e) {
        Value v;
        v = CSSUtilities.getComputedStyle
            (e, SVGCSSEngine.STROKE_WIDTH_INDEX);
        float width = v.getFloatValue();
        if (width == 0.0f)
            return null; // Stop here no stroke should be painted.

        v = CSSUtilities.getComputedStyle
            (e, SVGCSSEngine.STROKE_LINECAP_INDEX);
        int linecap = convertStrokeLinecap(v);
        v = CSSUtilities.getComputedStyle
            (e, SVGCSSEngine.STROKE_LINEJOIN_INDEX);
        int linejoin = convertStrokeLinejoin(v);
        v = CSSUtilities.getComputedStyle
            (e, SVGCSSEngine.STROKE_MITERLIMIT_INDEX);
        float miterlimit = convertStrokeMiterlimit(v);
        v = CSSUtilities.getComputedStyle
            (e, SVGCSSEngine.STROKE_DASHARRAY_INDEX);
        float[] dasharray = convertStrokeDasharray(v);

        float dashoffset = 0;
        if (dasharray != null) {
            v =  CSSUtilities.getComputedStyle
                (e, SVGCSSEngine.STROKE_DASHOFFSET_INDEX);
            dashoffset = v.getFloatValue();

            // make the dashoffset positive since BasicStroke cannot handle
            // negative values
            if ( dashoffset < 0 ) {
                float dashpatternlength = 0;
                for ( int i=0; i<dasharray.length; i++ ) {
                    dashpatternlength += dasharray[i];
                }
                // if the dash pattern consists of an odd number of elements,
                // the pattern length must be doubled
                if ( (dasharray.length % 2) != 0 )
                    dashpatternlength *= 2;

                if (dashpatternlength ==0) {
                    dashoffset=0;
                } else {
                    while (dashoffset < 0)
                        dashoffset += dashpatternlength;
                }
            }
        }
        return new BasicStroke(width,
                               linecap,
                               linejoin,
                               miterlimit,
                               dasharray,
                               dashoffset);
    }

    /////////////////////////////////////////////////////////////////////////
    // Stroke utility methods
    /////////////////////////////////////////////////////////////////////////

    /**
     * Converts the 'stroke-dasharray' property to a list of float
     * number in user units.
     *
     * @param v the CSS value describing the dasharray property
     */
    public static float [] convertStrokeDasharray(Value v) {
        float [] dasharray = null;
        if (v.getCssValueType() == CSSValue.CSS_VALUE_LIST) {
            int length = v.getLength();
            dasharray = new float[length];
            float sum = 0;
            for (int i = 0; i < dasharray.length; ++i) {
                dasharray[i] = v.item(i).getFloatValue();
                sum += dasharray[i];
            }
            if (sum == 0) {
                /* 11.4 - If the sum of the <length>'s is zero, then
                 * the stroke is rendered as if a value of none were specified.
                 */
                dasharray = null;
            }
        }
        return dasharray;
    }

    /**
     * Converts the 'miterlimit' property to the appropriate float number.
     * @param v the CSS value describing the miterlimit property
     */
    public static float convertStrokeMiterlimit(Value v) {
        float miterlimit = v.getFloatValue();
        return (miterlimit < 1.0f) ? 1.0f : miterlimit;
    }

    /**
     * Converts the 'linecap' property to the appropriate BasicStroke constant.
     * @param v the CSS value describing the linecap property
     */
    public static int convertStrokeLinecap(Value v) {
        String s = v.getStringValue();
        switch (s.charAt(0)) {
        case 'b':
            return BasicStroke.CAP_BUTT;
        case 'r':
            return BasicStroke.CAP_ROUND;
        case 's':
            return BasicStroke.CAP_SQUARE;
        default:
            throw new IllegalArgumentException
                ("Linecap argument is not an appropriate CSS value");
        }
    }

    /**
     * Converts the 'linejoin' property to the appropriate BasicStroke
     * constant.
     * @param v the CSS value describing the linejoin property
     */
    public static int convertStrokeLinejoin(Value v) {
        String s = v.getStringValue();
        switch (s.charAt(0)) {
        case 'm':
            return BasicStroke.JOIN_MITER;
        case 'r':
            return BasicStroke.JOIN_ROUND;
        case 'b':
            return BasicStroke.JOIN_BEVEL;
        default:
            throw new IllegalArgumentException
                ("Linejoin argument is not an appropriate CSS value");
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // Paint utility methods
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the value of one color component (0 <= result <= 255).
     * @param v the value that defines the color component
     */
    public static int resolveColorComponent(Value v) {
        float f;
        switch(v.getPrimitiveType()) {
        case CSSPrimitiveValue.CSS_PERCENTAGE:
            f = v.getFloatValue();
            f = (f > 100f) ? 100f : (f < 0f) ? 0f : f;
            return Math.round(255f * f / 100f);
        case CSSPrimitiveValue.CSS_NUMBER:
            f = v.getFloatValue();
            f = (f > 255f) ? 255f : (f < 0f) ? 0f : f;
            return Math.round(f);
        default:
            throw new IllegalArgumentException
                ("Color component argument is not an appropriate CSS value");
        }
    }

    /**
     * Returns the opacity represented by the specified CSSValue.
     * @param v the value that represents the opacity
     * @return the opacity between 0 and 1
     */
    public static float convertOpacity(Value v) {
        float r = v.getFloatValue();
        return (r < 0f) ? 0f : (r > 1.0f) ? 1.0f : r;
    }
}
