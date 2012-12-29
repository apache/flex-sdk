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

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Composite;
import java.awt.Cursor;
import java.awt.RenderingHints;
import java.awt.geom.GeneralPath;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.value.ListValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.svg.ICCColor;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.ext.awt.MultipleGradientPaint;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.filter.Mask;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.XMLConstants;
import org.w3c.dom.Element;
import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.css.CSSValue;

/**
 * A collection of utility method involving CSS property. The listed
 * methods bellow could be used as convenient methods to create
 * concrete objects regarding to CSS properties.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: CSSUtilities.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public abstract class CSSUtilities
    implements CSSConstants, ErrorConstants, XMLConstants {

    /**
     * No instance of this class is required.
     */
    protected CSSUtilities() {}

    /////////////////////////////////////////////////////////////////////////
    // Global methods
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns CSSEngine associated to the specified element.
     * @param e the element
     */
    public static CSSEngine getCSSEngine(Element e) {
        return ((SVGOMDocument)e.getOwnerDocument()).getCSSEngine();
    }

    /**
     * Returns the computed style of the given property.
     */
    public static Value getComputedStyle(Element e, int property) {
        CSSEngine engine = getCSSEngine(e);
        if (engine == null) return null;
        return engine.getComputedStyle((CSSStylableElement)e,
                                       null, property);
    }

    /////////////////////////////////////////////////////////////////////////
    // 'pointer-events'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the type that describes how this graphics node reacts to events.
     *
     * @return GraphicsNode.VISIBLE_PAINTED |
     *         GraphicsNode.VISIBLE_FILL |
     *         GraphicsNode.VISIBLE_STROKE |
     *         GraphicsNode.VISIBLE |
     *         GraphicsNode.PAINTED |
     *         GraphicsNode.FILL |
     *         GraphicsNode.STROKE |
     *         GraphicsNode.ALL |
     *         GraphicsNode.NONE
     */
    public static int convertPointerEvents(Element e) {
        Value v = getComputedStyle(e, SVGCSSEngine.POINTER_EVENTS_INDEX);
        String s = v.getStringValue();
        switch(s.charAt(0)) {
        case 'v':
            if (s.length() == 7) {
                return GraphicsNode.VISIBLE;
            } else {
                switch(s.charAt(7)) {
                case 'p':
                    return GraphicsNode.VISIBLE_PAINTED;
                case 'f':
                    return GraphicsNode.VISIBLE_FILL;
                case 's':
                    return GraphicsNode.VISIBLE_STROKE;
                default:
                    // can't be reached
                    throw new IllegalStateException("unexpected event, must be one of (p,f,s) is:" + s.charAt(7) );
                }
            }
        case 'p':
            return GraphicsNode.PAINTED;
        case 'f':
            return GraphicsNode.FILL;
        case 's':
            return GraphicsNode.STROKE;
        case 'a':
            return GraphicsNode.ALL;
        case 'n':
            return GraphicsNode.NONE;
        default:
            // can't be reached
            throw new IllegalStateException("unexpected event, must be one of (v,p,f,s,a,n) is:" + s.charAt(0) );
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // 'enable-background'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the subregion of user space where access to the
     * background image is allowed to happen.
     *
     * @param e the container element
     */
    public static Rectangle2D convertEnableBackground(Element e /*,
                                        UnitProcessor.Context uctx*/) {
        Value v = getComputedStyle(e, SVGCSSEngine.ENABLE_BACKGROUND_INDEX);
        if (v.getCssValueType() != CSSValue.CSS_VALUE_LIST) {
            return null; // accumulate
        }
        ListValue lv = (ListValue)v;
        int length = lv.getLength();
        switch (length) {
        case 1:
            return CompositeGraphicsNode.VIEWPORT; // new
        case 5: // new <x>,<y>,<width>,<height>
            float x = lv.item(1).getFloatValue();
            float y = lv.item(2).getFloatValue();
            float w = lv.item(3).getFloatValue();
            float h = lv.item(4).getFloatValue();
            return new Rectangle2D.Float(x, y, w, h);

        default:
            throw new IllegalStateException("Unexpected length:" + length ); // Cannot happen
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // 'color-interpolation-filters'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the color space for the specified filter element. Checks the
     * 'color-interpolation-filters' property.
     *
     * @param e the element
     * @return true if the color space is linear, false otherwise (sRGB).
     */
    public static boolean convertColorInterpolationFilters(Element e) {
        Value v = getComputedStyle(e,
                             SVGCSSEngine.COLOR_INTERPOLATION_FILTERS_INDEX);
        return CSS_LINEARRGB_VALUE == v.getStringValue();
    }

    /////////////////////////////////////////////////////////////////////////
    // 'color-interpolation'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the color space for the specified element. Checks the
     * 'color-interpolation' property
     *
     * @param e the element
     */
    public static MultipleGradientPaint.ColorSpaceEnum
        convertColorInterpolation(Element e) {
        Value v = getComputedStyle(e, SVGCSSEngine.COLOR_INTERPOLATION_INDEX);
        return (CSS_LINEARRGB_VALUE == v.getStringValue())
            ? MultipleGradientPaint.LINEAR_RGB
            : MultipleGradientPaint.SRGB;
    }

    /////////////////////////////////////////////////////////////////////////
    // 'cursor'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Checks if the cursor property on the input element is set to auto
     */
    public static boolean isAutoCursor(Element e) {
        Value cursorValue =
            CSSUtilities.getComputedStyle(e,
                                          SVGCSSEngine.CURSOR_INDEX);

        boolean isAuto = false;
        if (cursorValue != null){
            if(
               cursorValue.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE
               &&
               cursorValue.getPrimitiveType() == CSSPrimitiveValue.CSS_IDENT
               &&
               cursorValue.getStringValue().charAt(0) == 'a'
               ) {
                isAuto = true;
            } else if (
                       cursorValue.getCssValueType() == CSSValue.CSS_VALUE_LIST
                       &&
                       cursorValue.getLength() == 1) {
                Value lValue = cursorValue.item(0);
                if (lValue != null
                    &&
                    lValue.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE
                    &&
                    lValue.getPrimitiveType() == CSSPrimitiveValue.CSS_IDENT
                    &&
                    lValue.getStringValue().charAt(0) == 'a') {
                    isAuto = true;
                }
            }
        }

        return isAuto;
    }

    /**
     * Returns the Cursor corresponding to the input element's
     * cursor property
     *
     * @param e the element
     */
    public static Cursor
        convertCursor(Element e, BridgeContext ctx) {
        return ctx.getCursorManager().convertCursor(e);
    }

    ////////////////////////////////////////////////////////////////////////
    // 'color-rendering', 'text-rendering', 'image-rendering',
    // 'shape-rendering'
    ////////////////////////////////////////////////////////////////////////

    /**
     * Fills the rendering hints for the specified shape element or do
     * nothing none has been specified. Checks the 'shape-rendering'
     * property. If the given RenderingHints is null, a new
     * RenderingHints is created.
     *
     * <p>Here is how the mapping between SVG rendering hints and the Java2D
     * rendering hints is done:</p>
     *
     * <dl>
     * <dt>'optimizeSpeed':</dt>
     * <dd>
     * <ul>
     * <li>KEY_RENDERING=VALUE_RENDER_SPEED</li>
     * <li>KEY_ANTIALIASING=VALUE_ANTIALIAS_OFF</li>
     * </ul>
     * </dd>
     * <dt>'crispEdges':</dt>
     * <dd>
     * <ul>
     * <li>KEY_RENDERING=VALUE_RENDER_DEFAULT</li>
     * <li>KEY_ANTIALIASING=VALUE_ANTIALIAS_OFF</li>
     * </ul>
     * </dd>
     * <dt>'geometricPrecision':</dt>
     * <dd>
     * <ul>
     * <li>KEY_RENDERING=VALUE_RENDER_QUALITY</li>
     * <li>KEY_ANTIALIASING=VALUE_ANTIALIAS_ON</li>
     * </ul>
     * </dd>
     * </dl>
     *
     * @param e the element
     * @param hints a RenderingHints to fill, or null.
     */
    public static RenderingHints convertShapeRendering(Element e,
                                                       RenderingHints hints) {
        Value  v = getComputedStyle(e, SVGCSSEngine.SHAPE_RENDERING_INDEX);
        String s = v.getStringValue();
        int    len = s.length();
        if ((len == 4) && (s.charAt(0) == 'a')) // auto
            return hints;
        if (len < 10) return hints;  // Unknown.

        if (hints == null)
            hints = new RenderingHints(null);

        switch(s.charAt(0)) {
        case 'o': // optimizeSpeed
            hints.put(RenderingHints.KEY_RENDERING,
                      RenderingHints.VALUE_RENDER_SPEED);
            hints.put(RenderingHints.KEY_ANTIALIASING,
                      RenderingHints.VALUE_ANTIALIAS_OFF);
            break;
        case 'c': // crispEdges
            hints.put(RenderingHints.KEY_RENDERING,
                      RenderingHints.VALUE_RENDER_DEFAULT);
            hints.put(RenderingHints.KEY_ANTIALIASING,
                      RenderingHints.VALUE_ANTIALIAS_OFF);
            break;
        case 'g': // geometricPrecision
            hints.put(RenderingHints.KEY_RENDERING,
                      RenderingHints.VALUE_RENDER_QUALITY);
            hints.put(RenderingHints.KEY_ANTIALIASING,
                      RenderingHints.VALUE_ANTIALIAS_ON);
            hints.put(RenderingHints.KEY_STROKE_CONTROL,
                      RenderingHints.VALUE_STROKE_PURE);
            break;
        }
        return hints;
    }

    /**
     * Fills the rendering hints for the specified text element or do
     * nothing if none has been specified. If the given RenderingHints
     * is null, a new one is created. Checks the 'text-rendering'
     * property.
     *
     * <p>Here is how the mapping between SVG rendering hints and the Java2D
     * rendering hints is done:</p>
     *
     * <dl>
     * <dt>'optimizeSpeed':</dt>
     * <dd>
     * <ul>
     * <li>KEY_RENDERING=VALUE_RENDER_SPEED</li>
     * <li>KEY_ANTIALIASING=VALUE_ANTIALIAS_OFF</li>
     * <li>KEY_TEXT_ANTIALIASING=VALUE_TEXT_ANTIALIAS_OFF</li>
     * <li>KEY_FRACTIONALMETRICS=VALUE_FRACTIONALMETRICS_OFF</li>
     * </ul>
     * </dd>
     * <dt>'optimizeLegibility':</dt>
     * <dd>
     * <ul>
     * <li>KEY_RENDERING=VALUE_RENDER_QUALITY</li>
     * <li>KEY_ANTIALIASING=VALUE_ANTIALIAS_ON</li>
     * <li>KEY_TEXT_ANTIALIASING=VALUE_TEXT_ANTIALIAS_ON</li>
     * <li>KEY_FRACTIONALMETRICS=VALUE_FRACTIONALMETRICS_OFF</li>
     * </ul>
     * </dd>
     * <dt>'geometricPrecision':</dt>
     * <dd>
     * <ul>
     * <li>KEY_RENDERING=VALUE_RENDER_QUALITY</li>
     * <li>KEY_ANTIALIASING=VALUE_ANTIALIAS_DEFAULT</li>
     * <li>KEY_TEXT_ANTIALIASING=VALUE_TEXT_ANTIALIAS_DEFAULT</li>
     * <li>KEY_FRACTIONALMETRICS=VALUE_FRACTIONALMETRICS_ON</li>
     * </ul>
     * </dd>
     * </dl>
     *
     * <p>Note that for text both KEY_TEXT_ANTIALIASING and
     * KEY_ANTIALIASING are set as there is no guarantee that a Java2D
     * text rendering primitive will be used to draw text (eg. SVG
     * Font...).</p>
     *
     * @param e the element
     * @param hints a RenderingHints to fill, or null.
     */
    public static RenderingHints convertTextRendering(Element e,
                                                      RenderingHints hints) {
        Value v = getComputedStyle(e, SVGCSSEngine.TEXT_RENDERING_INDEX);
        String s = v.getStringValue();
        int    len = s.length();
        if ((len == 4) && (s.charAt(0) == 'a')) // auto
            return hints;
        if (len < 13) return hints;  // Unknown.

        if (hints == null)
            hints = new RenderingHints(null);

        switch(s.charAt(8)) {
        case 's': // optimizeSpeed
            hints.put(RenderingHints.KEY_RENDERING,
                      RenderingHints.VALUE_RENDER_SPEED);
            hints.put(RenderingHints.KEY_TEXT_ANTIALIASING,
                      RenderingHints.VALUE_TEXT_ANTIALIAS_OFF);
            hints.put(RenderingHints.KEY_ANTIALIASING,
                      RenderingHints.VALUE_ANTIALIAS_OFF);
            // hints.put(RenderingHints.KEY_FRACTIONALMETRICS,
            //           RenderingHints.VALUE_FRACTIONALMETRICS_OFF);
            break;
        case 'l': // optimizeLegibility
            hints.put(RenderingHints.KEY_RENDERING,
                      RenderingHints.VALUE_RENDER_QUALITY);
            hints.put(RenderingHints.KEY_TEXT_ANTIALIASING,
                      RenderingHints.VALUE_TEXT_ANTIALIAS_OFF);
            hints.put(RenderingHints.KEY_ANTIALIASING,
                      RenderingHints.VALUE_ANTIALIAS_ON);
            // hints.put(RenderingHints.KEY_FRACTIONALMETRICS,
            //           RenderingHints.VALUE_FRACTIONALMETRICS_OFF);
            break;
        case 'c': // geometricPrecision
            hints.put(RenderingHints.KEY_RENDERING,
                      RenderingHints.VALUE_RENDER_QUALITY);
            hints.put(RenderingHints.KEY_TEXT_ANTIALIASING,
                      RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
            hints.put(RenderingHints.KEY_ANTIALIASING,
                      RenderingHints.VALUE_ANTIALIAS_ON);
            hints.put(RenderingHints.KEY_FRACTIONALMETRICS,
                      RenderingHints.VALUE_FRACTIONALMETRICS_ON);
            hints.put(RenderingHints.KEY_STROKE_CONTROL,
                      RenderingHints.VALUE_STROKE_PURE);
            break;
        }
        return hints;
    }

    /**
     * Fills the rendering hints for the specified image element or do
     * nothing if none has been specified. If the given RenderingHints
     * is null, a new one is created. Checks the 'image-rendering'
     * property.
     *
     * <p>Here is how the mapping between SVG rendering hints and the Java2D
     * rendering hints is done:</p>
     *
     * <dl>
     * <dt>'optimizeSpeed':</dt>
     * <dd>
     * <ul>
     * <li>KEY_RENDERING=VALUE_RENDER_SPEED</li>
     * <li>KEY_INTERPOLATION=VALUE_INTERPOLATION_NEAREST_NEIGHBOR</li>
     * </ul>
     * </dd>
     * <dt>'optimizeQuality':</dt>
     * <dd>
     * <ul>
     * <li>KEY_RENDERING=VALUE_RENDER_QUALITY</li>
     * <li>KEY_INTERPOLATION=VALUE_INTERPOLATION_BICUBIC</li>
     * </ul>
     * </dd>
     * </dl>
     *
     * @param e the element
     * @param hints a RenderingHints to fill, or null.
     */
    public static RenderingHints convertImageRendering(Element e,
                                                       RenderingHints hints) {
        Value v = getComputedStyle(e, SVGCSSEngine.IMAGE_RENDERING_INDEX);
        String s = v.getStringValue();
        int    len = s.length();
        if ((len == 4) && (s.charAt(0) == 'a')) // auto
            return hints;
        if (len < 13) return hints;  // Unknown.

        if (hints == null)
            hints = new RenderingHints(null);

        switch(s.charAt(8)) {
        case 's': // optimizeSpeed
            hints.put(RenderingHints.KEY_RENDERING,
                      RenderingHints.VALUE_RENDER_SPEED);
            hints.put(RenderingHints.KEY_INTERPOLATION,
                      RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
            break;
        case 'q': // optimizeQuality
            hints.put(RenderingHints.KEY_RENDERING,
                      RenderingHints.VALUE_RENDER_QUALITY);
            hints.put(RenderingHints.KEY_INTERPOLATION,
                      RenderingHints.VALUE_INTERPOLATION_BICUBIC);
            break;
        }
        return hints;
    }

    /**
     * Fills the rendering hints for the specified element or do
     * nothing if none has been specified. If the given RenderingHints
     * is null, a new one is created. Checks the 'color-rendering'
     * property.
     *
     * <p>Here is how the mapping between SVG rendering hints and the Java2D
     * rendering hints is done:</p>
     *
     * <dl>
     * <dt>'optimizeSpeed':</dt>
     * <dd>
     * <ul>
     * <li>KEY_COLOR_RENDERING=VALUE_COLOR_RENDER_SPEED</li>
     * <li>KEY_ALPHA_INTERPOLATION=VALUE_ALPHA_INTERPOLATION_SPEED</li>
     * </ul>
     * </dd>
     * <dt>'optimizeQuality':</dt>
     * <dd>
     * <ul>
     * <li>KEY_COLOR_RENDERING=VALUE_COLOR_RENDER_QUALITY</li>
     * <li>KEY_ALPHA_INTERPOLATION=VALUE_ALPHA_INTERPOLATION_QUALITY</li>
     * </ul>
     * </dd>
     * </dl>
     *
     * @param e the element
     * @param hints a RenderingHints to fill, or null.
     */
    public static RenderingHints convertColorRendering(Element e,
                                                       RenderingHints hints) {
        Value v = getComputedStyle(e, SVGCSSEngine.COLOR_RENDERING_INDEX);
        String s = v.getStringValue();
        int    len = s.length();
        if ((len == 4) && (s.charAt(0) == 'a')) // auto
            return hints;
        if (len < 13) return hints;  // Unknown.

        if (hints == null)
            hints = new RenderingHints(null);

        switch(s.charAt(8)) {
        case 's': // optimizeSpeed
            hints.put(RenderingHints.KEY_COLOR_RENDERING,
                      RenderingHints.VALUE_COLOR_RENDER_SPEED);
            hints.put(RenderingHints.KEY_ALPHA_INTERPOLATION,
                      RenderingHints.VALUE_ALPHA_INTERPOLATION_SPEED);
            break;
        case 'q': // optimizeQuality
            hints.put(RenderingHints.KEY_COLOR_RENDERING,
                      RenderingHints.VALUE_COLOR_RENDER_QUALITY);
            hints.put(RenderingHints.KEY_ALPHA_INTERPOLATION,
                      RenderingHints.VALUE_ALPHA_INTERPOLATION_QUALITY);
            break;
        }
        return hints;
    }

    /////////////////////////////////////////////////////////////////////////
    // 'display'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns true if the specified element has to be displayed, false
     * otherwise. Checks the 'display' property.
     *
     * @param e the element
     */
    public static boolean convertDisplay(Element e) {
        if (!(e instanceof CSSStylableElement)) {
            return true;
        }
        Value v = getComputedStyle(e, SVGCSSEngine.DISPLAY_INDEX);
        return v.getStringValue().charAt(0) != 'n';
    }

    /////////////////////////////////////////////////////////////////////////
    // 'visibility'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns true if the specified element is visible, false
     * otherwise. Checks the 'visibility' property.
     *
     * @param e the element
     */
    public static boolean convertVisibility(Element e) {
        Value v = getComputedStyle(e, SVGCSSEngine.VISIBILITY_INDEX);
        return v.getStringValue().charAt(0) == 'v';
    }

    /////////////////////////////////////////////////////////////////////////
    // 'opacity'
    /////////////////////////////////////////////////////////////////////////

    public static final Composite TRANSPARENT =
        AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0);

    /**
     * Returns a composite object that represents the 'opacity' of the
     * specified element.
     *
     * @param e the element
     */
    public static Composite convertOpacity(Element e) {
        Value v = getComputedStyle(e, SVGCSSEngine.OPACITY_INDEX);
        float f = v.getFloatValue();
        if (f <= 0f) {
            return TRANSPARENT;
        } else if (f >= 1.0f) {
            return AlphaComposite.SrcOver;
        } else {
            return AlphaComposite.getInstance(AlphaComposite.SRC_OVER, f);
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // 'overflow' and 'clip'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns true if the 'overflow' property indicates that an
     * additional clip is required, false otherwise. An additional
     * clip is needed if the 'overflow' property is 'scroll' or
     * 'hidden'.
     *
     * @param e the element with the 'overflow' property
     */
    public static boolean convertOverflow(Element e) {
        Value v = getComputedStyle(e, SVGCSSEngine.OVERFLOW_INDEX);
        String s = v.getStringValue();
        return (s.charAt(0) == 'h') || (s.charAt(0) == 's');
    }

    /**
     * Returns an array of floating offsets representing the 'clip'
     * property or null if 'auto'. The offsets are specified in the
     * order top, right, bottom, left.
     *
     * @param e the element with the 'clip' property
     */
    public static float[] convertClip(Element e) {
        Value v = getComputedStyle(e, SVGCSSEngine.CLIP_INDEX);
        int primitiveType = v.getPrimitiveType();
        switch ( primitiveType ) {
        case CSSPrimitiveValue.CSS_RECT:
            float [] off = new float[4];
            off[0] = v.getTop().getFloatValue();
            off[1] = v.getRight().getFloatValue();
            off[2] = v.getBottom().getFloatValue();
            off[3] = v.getLeft().getFloatValue();
            return off;
        case CSSPrimitiveValue.CSS_IDENT:
            return null; // 'auto' means no offsets
        default:
            // can't be reached
            throw new IllegalStateException("Unexpected primitiveType:" + primitiveType );
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // 'filter'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns a <tt>Filter</tt> referenced by the specified element
     * and which applies on the specified graphics node.
     * Handle the 'filter' property.
     *
     * @param filteredElement the element that references the filter
     * @param filteredNode the graphics node associated to the element
     *                     to filter.
     * @param ctx the bridge context
     */
    public static Filter convertFilter(Element filteredElement,
                                       GraphicsNode filteredNode,
                                       BridgeContext ctx) {
        Value v = getComputedStyle(filteredElement, SVGCSSEngine.FILTER_INDEX);
        int primitiveType = v.getPrimitiveType();
        switch ( primitiveType ) {
        case CSSPrimitiveValue.CSS_IDENT:
            return null; // 'filter:none'

        case CSSPrimitiveValue.CSS_URI:
            String uri = v.getStringValue();
            Element filter = ctx.getReferencedElement(filteredElement, uri);
            Bridge bridge = ctx.getBridge(filter);
            if (bridge == null || !(bridge instanceof FilterBridge)) {
                throw new BridgeException(ctx, filteredElement,
                                          ERR_CSS_URI_BAD_TARGET,
                                          new Object[] {uri});
            }
            return ((FilterBridge)bridge).createFilter(ctx,
                                                       filter,
                                                       filteredElement,
                                                       filteredNode);
        default:
            throw new IllegalStateException("Unexpected primitive type:" + primitiveType ); // can't be reached

        }
    }

    /////////////////////////////////////////////////////////////////////////
    // 'clip-path' and 'clip-rule'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns a <tt>Clip</tt> referenced by the specified element and
     * which applies on the specified graphics node.
     * Handle the 'clip-path' property.
     *
     * @param clippedElement the element that references the clip
     * @param clippedNode the graphics node associated to the element to clip
     * @param ctx the bridge context
     */
    public static ClipRable convertClipPath(Element clippedElement,
                                            GraphicsNode clippedNode,
                                            BridgeContext ctx) {
        Value v = getComputedStyle(clippedElement,
                                   SVGCSSEngine.CLIP_PATH_INDEX);
        int primitiveType = v.getPrimitiveType();
        switch ( primitiveType ) {
        case CSSPrimitiveValue.CSS_IDENT:
            return null; // 'clip-path:none'

        case CSSPrimitiveValue.CSS_URI:
            String uri = v.getStringValue();
            Element cp = ctx.getReferencedElement(clippedElement, uri);
            Bridge bridge = ctx.getBridge(cp);
            if (bridge == null || !(bridge instanceof ClipBridge)) {
                throw new BridgeException(ctx, clippedElement,
                                          ERR_CSS_URI_BAD_TARGET,
                                          new Object[] {uri});
            }
            return ((ClipBridge)bridge).createClip(ctx,
                                                   cp,
                                                   clippedElement,
                                                   clippedNode);
        default:
            throw new IllegalStateException("Unexpected primitive type:" + primitiveType ); // can't be reached
        }
    }

    /**
     * Returns the 'clip-rule' for the specified element.
     *
     * @param e the element interested in its a 'clip-rule'
     * @return GeneralPath.WIND_NON_ZERO | GeneralPath.WIND_EVEN_ODD
     */
    public static int convertClipRule(Element e) {
        Value v = getComputedStyle(e, SVGCSSEngine.CLIP_RULE_INDEX);
        return (v.getStringValue().charAt(0) == 'n')
            ? GeneralPath.WIND_NON_ZERO
            : GeneralPath.WIND_EVEN_ODD;
    }

    /////////////////////////////////////////////////////////////////////////
    // 'mask'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns a <tt>Mask</tt> referenced by the specified element and
     * which applies on the specified graphics node.
     * Handle the 'mask' property.
     *
     * @param maskedElement the element that references the mask
     * @param maskedNode the graphics node associated to the element to mask
     * @param ctx the bridge context
     */
    public static Mask convertMask(Element maskedElement,
                                   GraphicsNode maskedNode,
                                   BridgeContext ctx) {
        Value v = getComputedStyle(maskedElement, SVGCSSEngine.MASK_INDEX);
        int primitiveType = v.getPrimitiveType();
        switch ( primitiveType ) {
        case CSSPrimitiveValue.CSS_IDENT:
            return null; // 'mask:none'

        case CSSPrimitiveValue.CSS_URI:
            String uri = v.getStringValue();
            Element m = ctx.getReferencedElement(maskedElement, uri);
            Bridge bridge = ctx.getBridge(m);
            if (bridge == null || !(bridge instanceof MaskBridge)) {
                throw new BridgeException(ctx, maskedElement,
                                          ERR_CSS_URI_BAD_TARGET,
                                          new Object[] {uri});
            }
            return ((MaskBridge)bridge).createMask(ctx,
                                                   m,
                                                   maskedElement,
                                                   maskedNode);
        default:
            throw new IllegalStateException("Unexpected primitive type:" + primitiveType ); // can't be reached
        }
    }

    /**
     * Returns the 'fill-rule' for the specified element.
     *
     * @param e the element interested in its a 'fill-rule'
     * @return GeneralPath.WIND_NON_ZERO | GeneralPath.WIND_EVEN_ODD
     */
    public static int convertFillRule(Element e) {
        Value v = getComputedStyle(e, SVGCSSEngine.FILL_RULE_INDEX);
        return (v.getStringValue().charAt(0) == 'n')
            ? GeneralPath.WIND_NON_ZERO
            : GeneralPath.WIND_EVEN_ODD;
    }

    /////////////////////////////////////////////////////////////////////////
    // 'lighting-color'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Converts the color defined on the specified lighting filter element
     * to a <tt>Color</tt>.
     *
     * @param e the lighting filter element
     * @param ctx the bridge context
     */
    public static Color convertLightingColor(Element e, BridgeContext ctx) {
        Value v = getComputedStyle(e, SVGCSSEngine.LIGHTING_COLOR_INDEX);
        if (v.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE) {
            return PaintServer.convertColor(v, 1);
        } else {
            return PaintServer.convertRGBICCColor
                (e, v.item(0), (ICCColor)v.item(1), 1, ctx);
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // 'flood-color' and 'flood-opacity'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Converts the color defined on the specified &lt;feFlood>
     * element to a <tt>Color</tt>.
     *
     * @param e the feFlood element
     * @param ctx the bridge context
     */
    public static Color convertFloodColor(Element e, BridgeContext ctx) {
        Value v = getComputedStyle(e, SVGCSSEngine.FLOOD_COLOR_INDEX);
        Value o = getComputedStyle(e, SVGCSSEngine.FLOOD_OPACITY_INDEX);
        float f = PaintServer.convertOpacity(o);
        if (v.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE) {
            return PaintServer.convertColor(v, f);
        } else {
            return PaintServer.convertRGBICCColor
                (e, v.item(0), (ICCColor)v.item(1), f, ctx);
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // 'stop-color'
    /////////////////////////////////////////////////////////////////////////

    /**
     * Converts the color defined on the specified &lt;stop> element
     * to a <tt>Color</tt>.
     *
     * @param e the stop element
     * @param opacity the paint opacity
     * @param ctx the bridge context to use
     */
    public static Color convertStopColor(Element e,
                                         float opacity,
                                         BridgeContext ctx) {
        Value v = getComputedStyle(e, SVGCSSEngine.STOP_COLOR_INDEX);
        Value o = getComputedStyle(e, SVGCSSEngine.STOP_OPACITY_INDEX);
        opacity *= PaintServer.convertOpacity(o);
        if (v.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE) {
            return PaintServer.convertColor(v, opacity);
        } else {
            return PaintServer.convertRGBICCColor
                (e, v.item(0), (ICCColor)v.item(1), opacity, ctx);
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // CSS support for <use>
    /////////////////////////////////////////////////////////////////////////

    /**
     * Partially computes the style in the 'def' tree and set it in the 'use'
     * tree.
     * <p>Note: This method must be called only when 'use' has been
     * added to the DOM tree.
     *
     * @param refElement the referenced element
     * @param localRefElement the referenced element in the current document
     */
    public static void computeStyleAndURIs(Element refElement,
                                           Element localRefElement,
                                           String  uri) {
        // Pull fragement id off first...
        int idx = uri.indexOf('#');
        if (idx != -1)
            uri = uri.substring(0,idx);

        // Only set xml:base if we have a real URL.
        if (uri.length() != 0)
            localRefElement.setAttributeNS(XML_NAMESPACE_URI,
                                           "base",
                                           uri);

        CSSEngine engine    = CSSUtilities.getCSSEngine(localRefElement);
        CSSEngine refEngine = CSSUtilities.getCSSEngine(refElement);

        engine.importCascadedStyleMaps(refElement, refEngine, localRefElement);
    }

    /////////////////////////////////////////////////////////////////////////
    // Additional utility methods used internally
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the winding rule represented by the specified CSSValue.
     *
     * @param v the value that represents the rule
     * @return GeneralPath.WIND_NON_ZERO | GeneralPath.WIND_EVEN_ODD
     */
    protected static int rule(CSSValue v) {
        return (((CSSPrimitiveValue)v).getStringValue().charAt(0) == 'n')
            ? GeneralPath.WIND_NON_ZERO
            : GeneralPath.WIND_EVEN_ODD;
    }
}
