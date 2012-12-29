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

import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.parser.ParseException;
import org.w3c.dom.Element;

/**
 * This class provides methods to convert SVG length and coordinate to
 * float in user units.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: UnitProcessor.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public abstract class UnitProcessor
    extends org.apache.flex.forks.batik.parser.UnitProcessor {

    /**
     * Creates a context for the specified element.
     *
     * @param ctx the bridge context that contains the user agent and
     * viewport definition
     * @param e the element interested in its context
     */
    public static Context createContext(BridgeContext ctx, Element e) {
        return new DefaultContext(ctx, e);
    }

    /////////////////////////////////////////////////////////////////////////
    // SVG methods - objectBoundingBox
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the specified horizontal coordinate in object bounding box
     * coordinate system.
     *
     * @param s the horizontal coordinate
     * @param attr the attribute name that represents the coordinate
     * @param ctx the context used to resolve relative value
     */
    public static
        float svgHorizontalCoordinateToObjectBoundingBox(String s,
                                                         String attr,
                                                         Context ctx) {
        return svgToObjectBoundingBox(s, attr, HORIZONTAL_LENGTH, ctx);
    }

    /**
     * Returns the specified vertical coordinate in object bounding box
     * coordinate system.
     *
     * @param s the vertical coordinate
     * @param attr the attribute name that represents the coordinate
     * @param ctx the context used to resolve relative value
     */
    public static
        float svgVerticalCoordinateToObjectBoundingBox(String s,
                                                       String attr,
                                                       Context ctx) {
        return svgToObjectBoundingBox(s, attr, VERTICAL_LENGTH, ctx);
    }

    /**
     * Returns the specified 'other' coordinate in object bounding box
     * coordinate system.
     *
     * @param s the 'other' coordinate
     * @param attr the attribute name that represents the coordinate
     * @param ctx the context used to resolve relative value
     */
    public static
        float svgOtherCoordinateToObjectBoundingBox(String s,
                                                    String attr,
                                                    Context ctx) {
        return svgToObjectBoundingBox(s, attr, OTHER_LENGTH, ctx);
    }

    /**
     * Returns the specified horizontal length in object bounding box
     * coordinate system. A length must be greater than 0.
     *
     * @param s the 'other' length
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static
        float svgHorizontalLengthToObjectBoundingBox(String s,
                                                     String attr,
                                                     Context ctx) {
        return svgLengthToObjectBoundingBox(s, attr, HORIZONTAL_LENGTH, ctx);
    }

    /**
     * Returns the specified vertical length in object bounding box
     * coordinate system. A length must be greater than 0.
     *
     * @param s the vertical length
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static
        float svgVerticalLengthToObjectBoundingBox(String s,
                                                   String attr,
                                                   Context ctx) {
        return svgLengthToObjectBoundingBox(s, attr, VERTICAL_LENGTH, ctx);
    }

    /**
     * Returns the specified 'other' length in object bounding box
     * coordinate system. A length must be greater than 0.
     *
     * @param s the 'other' length
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static
        float svgOtherLengthToObjectBoundingBox(String s,
                                                String attr,
                                                Context ctx) {
        return svgLengthToObjectBoundingBox(s, attr, OTHER_LENGTH, ctx);
    }

    /**
     * Returns the specified length with the specified direction in
     * user units. A length must be greater than 0.
     *
     * @param s the length
     * @param attr the attribute name that represents the length
     * @param d the direction of the length
     * @param ctx the context used to resolve relative value
     */
    public static float svgLengthToObjectBoundingBox(String s,
                                                     String attr,
                                                     short d,
                                                     Context ctx) {
        float v = svgToObjectBoundingBox(s, attr, d, ctx);
        if (v < 0) {
            throw new BridgeException(getBridgeContext(ctx), ctx.getElement(),
                                      ErrorConstants.ERR_LENGTH_NEGATIVE,
                                      new Object[] {attr, s});
        }
        return v;
    }

    /**
     * Returns the specified value with the specified direction in
     * objectBoundingBox units.
     *
     * @param s the value
     * @param attr the attribute name that represents the value
     * @param d the direction of the value
     * @param ctx the context used to resolve relative value
     */
    public static float svgToObjectBoundingBox(String s,
                                               String attr,
                                               short d,
                                               Context ctx) {
        try {
            return org.apache.flex.forks.batik.parser.UnitProcessor.
                svgToObjectBoundingBox(s, attr, d, ctx);
        } catch (ParseException pEx ) {
            throw new BridgeException
                (getBridgeContext(ctx), ctx.getElement(),
                 pEx, ErrorConstants.ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {attr, s, pEx });
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // SVG methods - userSpace
    /////////////////////////////////////////////////////////////////////////


    /**
     * Returns the specified horizontal length in user units. A length
     * must be greater than 0.
     *
     * @param s the horizontal length
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static float svgHorizontalLengthToUserSpace(String s,
                                                       String attr,
                                                       Context ctx) {
        return svgLengthToUserSpace(s, attr, HORIZONTAL_LENGTH, ctx);
    }

    /**
     * Returns the specified vertical length in user units. A length
     * must be greater than 0.
     *
     * @param s the vertical length
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static float svgVerticalLengthToUserSpace(String s,
                                                     String attr,
                                                     Context ctx) {
        return svgLengthToUserSpace(s, attr, VERTICAL_LENGTH, ctx);
    }

    /**
     * Returns the specified 'other' length in user units. A length
     * must be greater than 0.
     *
     * @param s the 'other' length
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static float svgOtherLengthToUserSpace(String s,
                                                  String attr,
                                                  Context ctx) {
        return svgLengthToUserSpace(s, attr, OTHER_LENGTH, ctx);
    }

    /**
     * Returns the specified horizontal coordinate in user units.
     *
     * @param s the horizontal coordinate
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static float svgHorizontalCoordinateToUserSpace(String s,
                                                           String attr,
                                                           Context ctx) {
        return svgToUserSpace(s, attr, HORIZONTAL_LENGTH, ctx);
    }

    /**
     * Returns the specified vertical coordinate in user units.
     *
     * @param s the vertical coordinate
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static float svgVerticalCoordinateToUserSpace(String s,
                                                         String attr,
                                                         Context ctx) {
        return svgToUserSpace(s, attr, VERTICAL_LENGTH, ctx);
    }

    /**
     * Returns the specified 'other' coordinate in user units.
     *
     * @param s the 'other' coordinate
     * @param attr the attribute name that represents the length
     * @param ctx the context used to resolve relative value
     */
    public static float svgOtherCoordinateToUserSpace(String s,
                                                      String attr,
                                                      Context ctx) {
        return svgToUserSpace(s, attr, OTHER_LENGTH, ctx);
    }

    /**
     * Returns the specified length with the specified direction in
     * user units. A length must be greater than 0.
     *
     * @param s the 'other' coordinate
     * @param attr the attribute name that represents the length
     * @param d the direction of the length
     * @param ctx the context used to resolve relative value
     */
    public static float svgLengthToUserSpace(String s,
                                             String attr,
                                             short d,
                                             Context ctx) {
        float v = svgToUserSpace(s, attr, d, ctx);
        if (v < 0) {
            throw new BridgeException(getBridgeContext(ctx), ctx.getElement(),
                                      ErrorConstants.ERR_LENGTH_NEGATIVE,
                                      new Object[] {attr, s});
        } else {
            return v;
        }
    }

    /**
     * Returns the specified coordinate with the specified direction
     * in user units.
     *
     * @param s the 'other' coordinate
     * @param attr the attribute name that represents the length
     * @param d the direction of the coordinate
     * @param ctx the context used to resolve relative value
     */
    public static float svgToUserSpace(String s,
                                       String attr,
                                       short d,
                                       Context ctx) {
        try {
            return org.apache.flex.forks.batik.parser.UnitProcessor.
                svgToUserSpace(s, attr, d, ctx);
        } catch (ParseException pEx ) {
            throw new BridgeException
                (getBridgeContext(ctx), ctx.getElement(),
                 pEx, ErrorConstants.ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {attr, s, pEx, });
        }
    }

    /**
     * Returns the {@link BridgeContext} from the given {@link Context}
     * if it is a {@link DefaultContext}, or null otherwise.
     */
    protected static BridgeContext getBridgeContext(Context ctx) {
        if (ctx instanceof DefaultContext) {
            return ((DefaultContext) ctx).ctx;
        }
        return null;
    }

    /**
     * This class is the default context for a particular element. Information
     * not available on the element are obtained from the bridge context (such
     * as the viewport or the pixel to millimeter factor).
     */
    public static class DefaultContext implements Context {

        /**
         * The element.
         */
        protected Element e;

        /**
         * The bridge context.
         */
        protected BridgeContext ctx;

        /**
         * Creates a new DefaultContext.
         */
        public DefaultContext(BridgeContext ctx, Element e) {
            this.ctx = ctx;
            this.e = e;
        }

        /**
         * Returns the element.
         */
        public Element getElement() {
            return e;
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         */
        public float getPixelUnitToMillimeter() {
            return ctx.getUserAgent().getPixelUnitToMillimeter();
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         * This will be removed after next release.
         * @see #getPixelUnitToMillimeter()
         */
        public float getPixelToMM() {
            return getPixelUnitToMillimeter();

        }

        /**
         * Returns the font-size value.
         */
        public float getFontSize() {
            return CSSUtilities.getComputedStyle
                (e, SVGCSSEngine.FONT_SIZE_INDEX).getFloatValue();
        }

        /**
         * Returns the x-height value.
         */
        public float getXHeight() {
            return 0.5f;
        }

        /**
         * Returns the viewport width used to compute units.
         */
        public float getViewportWidth() {
            return ctx.getViewport(e).getWidth();
        }

        /**
         * Returns the viewport height used to compute units.
         */
        public float getViewportHeight() {
            return ctx.getViewport(e).getHeight();
        }
    }
}
