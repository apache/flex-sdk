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
package org.apache.flex.forks.batik.parser;

import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGLength;

/**
 * This class provides methods to convert SVG length and coordinate to
 * float in user units.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: UnitProcessor.java 480490 2006-11-29 09:02:20Z dvholten $
 */
public abstract class UnitProcessor {

    /**
     * This constant represents horizontal lengths.
     */
    public static final short HORIZONTAL_LENGTH = 2;

    /**
     * This constant represents vertical lengths.
     */
    public static final short VERTICAL_LENGTH = 1;

    /**
     * This constant represents other lengths.
     */
    public static final short OTHER_LENGTH = 0;

    /**
     * precomputed square-root of 2.0
     */
    static final double SQRT2 = Math.sqrt( 2.0 );
    
    /**
     * No instance of this class is required.
     */
    protected UnitProcessor() { }


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
                                               Context ctx)
        throws ParseException {
        LengthParser lengthParser = new LengthParser();
        UnitResolver ur = new UnitResolver();
        lengthParser.setLengthHandler(ur);
        lengthParser.parse(s);
        return svgToObjectBoundingBox(ur.value, ur.unit, d, ctx);
    }

    /**
     * Returns the specified value with the specified direction in
     * objectBoundingBox units.
     *
     * @param value the value
     * @param type the type of the value
     * @param d the direction of the value
     * @param ctx the context used to resolve relative value
     */
    public static float svgToObjectBoundingBox(float value,
                                               short type,
                                               short d,
                                               Context ctx) {
        switch (type) {
        case SVGLength.SVG_LENGTHTYPE_NUMBER:
            // as is
            return value;
        case SVGLength.SVG_LENGTHTYPE_PERCENTAGE:
            // If a percentage value is used, it is converted to a
            // 'bounding box' space coordinate by division by 100
            return value / 100f;
        case SVGLength.SVG_LENGTHTYPE_PX:
        case SVGLength.SVG_LENGTHTYPE_MM:
        case SVGLength.SVG_LENGTHTYPE_CM:
        case SVGLength.SVG_LENGTHTYPE_IN:
        case SVGLength.SVG_LENGTHTYPE_PT:
        case SVGLength.SVG_LENGTHTYPE_PC:
        case SVGLength.SVG_LENGTHTYPE_EMS:
        case SVGLength.SVG_LENGTHTYPE_EXS:
            // <!> FIXME: resolve units in userSpace but consider them
            // in the objectBoundingBox coordinate system
            return svgToUserSpace(value, type, d, ctx);
        default:
            throw new IllegalArgumentException("Length has unknown type");
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // SVG methods - userSpace
    /////////////////////////////////////////////////////////////////////////


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
                                       Context ctx) throws ParseException {
        LengthParser lengthParser = new LengthParser();
        UnitResolver ur = new UnitResolver();
        lengthParser.setLengthHandler(ur);
        lengthParser.parse(s);
        return svgToUserSpace(ur.value, ur.unit, d, ctx);
    }

    /**
     * Converts the specified value of the specified type and
     * direction to user units.
     *
     * @param v the value to convert
     * @param type the type of the value
     * @param d HORIZONTAL_LENGTH, VERTICAL_LENGTH, or OTHER_LENGTH
     * @param ctx the context used to resolve relative value
     */
    public static float svgToUserSpace(float v,
                                       short type,
                                       short d,
                                       Context ctx) {
        switch (type) {
        case SVGLength.SVG_LENGTHTYPE_NUMBER:
        case SVGLength.SVG_LENGTHTYPE_PX:
            return v;
        case SVGLength.SVG_LENGTHTYPE_MM:
            return (v / ctx.getPixelUnitToMillimeter());
        case SVGLength.SVG_LENGTHTYPE_CM:
            return (v * 10f / ctx.getPixelUnitToMillimeter());
        case SVGLength.SVG_LENGTHTYPE_IN:
            return (v * 25.4f / ctx.getPixelUnitToMillimeter());
        case SVGLength.SVG_LENGTHTYPE_PT:
            return (v * 25.4f / (72f * ctx.getPixelUnitToMillimeter()));
        case SVGLength.SVG_LENGTHTYPE_PC:
            return (v * 25.4f / (6f * ctx.getPixelUnitToMillimeter()));
        case SVGLength.SVG_LENGTHTYPE_EMS:
            return emsToPixels(v, d, ctx);
        case SVGLength.SVG_LENGTHTYPE_EXS:
            return exsToPixels(v, d, ctx);
        case SVGLength.SVG_LENGTHTYPE_PERCENTAGE:
            return percentagesToPixels(v, d, ctx);
        default:
            throw new IllegalArgumentException("Length has unknown type");
        }
    }

    /**
     * Converts the specified value of the specified type and
     * direction to SVG units.
     *
     * @param v the value to convert
     * @param type the type of the value
     * @param d HORIZONTAL_LENGTH, VERTICAL_LENGTH, or OTHER_LENGTH
     * @param ctx the context used to resolve relative value
     */
    public static float userSpaceToSVG(float v,
                                       short type,
                                       short d,
                                       Context ctx) {
        switch (type) {
        case SVGLength.SVG_LENGTHTYPE_NUMBER:
        case SVGLength.SVG_LENGTHTYPE_PX:
            return v;
        case SVGLength.SVG_LENGTHTYPE_MM:
            return (v * ctx.getPixelUnitToMillimeter());
        case SVGLength.SVG_LENGTHTYPE_CM:
            return (v * ctx.getPixelUnitToMillimeter() / 10f);
        case SVGLength.SVG_LENGTHTYPE_IN:
            return (v * ctx.getPixelUnitToMillimeter() / 25.4f);
        case SVGLength.SVG_LENGTHTYPE_PT:
            return (v * (72f * ctx.getPixelUnitToMillimeter()) / 25.4f);
        case SVGLength.SVG_LENGTHTYPE_PC:
            return (v * (6f * ctx.getPixelUnitToMillimeter()) / 25.4f);
        case SVGLength.SVG_LENGTHTYPE_EMS:
            return pixelsToEms(v, d, ctx);
        case SVGLength.SVG_LENGTHTYPE_EXS:
            return pixelsToExs(v, d, ctx);
        case SVGLength.SVG_LENGTHTYPE_PERCENTAGE:
            return pixelsToPercentages(v, d, ctx);
        default:
            throw new IllegalArgumentException("Length has unknown type");
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // Utilities methods for relative length
    /////////////////////////////////////////////////////////////////////////

    /**
     * Converts percentages to user units.
     *
     * @param v the percentage to convert
     * @param d HORIZONTAL_LENGTH, VERTICAL_LENGTH, or OTHER_LENGTH
     * @param ctx the context
     */
    protected static float percentagesToPixels(float v, short d, Context ctx) {
        if (d == HORIZONTAL_LENGTH) {
            float w = ctx.getViewportWidth();
            return w * v / 100f;
        } else if (d == VERTICAL_LENGTH) {
            float h = ctx.getViewportHeight();
            return h * v / 100f;
        } else {
            double w = ctx.getViewportWidth();
            double h = ctx.getViewportHeight();
            double vpp = Math.sqrt(w * w + h * h) / SQRT2;
            return (float)(vpp * v / 100d);
        }
    }

    /**
     * Converts user units to percentages relative to the viewport.
     *
     * @param v the value to convert
     * @param d HORIZONTAL_LENGTH, VERTICAL_LENGTH, or OTHER_LENGTH
     * @param ctx the context
     */
    protected static float pixelsToPercentages(float v, short d, Context ctx) {
        if (d == HORIZONTAL_LENGTH) {
            float w = ctx.getViewportWidth();
            return v * 100f / w;
        } else if (d == VERTICAL_LENGTH) {
            float h = ctx.getViewportHeight();
            return v * 100f / h;
        } else {
            double w = ctx.getViewportWidth();
            double h = ctx.getViewportHeight();
            double vpp = Math.sqrt(w * w + h * h) / SQRT2;
            return (float)(v * 100d / vpp);
        }
    }

    /**
     * Converts user units to ems units.
     *
     * @param v the value to convert
     * @param d HORIZONTAL_LENGTH, VERTICAL_LENGTH, or OTHER_LENGTH
     * @param ctx the context
     */
    protected static float pixelsToEms(float v, short d, Context ctx) {
        return v / ctx.getFontSize();
    }

    /**
     * Converts ems units to user units.
     *
     * @param v the value to convert
     * @param d HORIZONTAL_LENGTH, VERTICAL_LENGTH, or OTHER_LENGTH
     * @param ctx the context
     */
    protected static float emsToPixels(float v, short d, Context ctx) {
        return v * ctx.getFontSize();
    }

    /**
     * Converts user units to exs units.
     *
     * @param v the value to convert
     * @param d HORIZONTAL_LENGTH, VERTICAL_LENGTH, or OTHER_LENGTH
     * @param ctx the context
     */
    protected static float pixelsToExs(float v, short d, Context ctx) {
        float xh = ctx.getXHeight();
        return v / xh / ctx.getFontSize();
    }

    /**
     * Converts exs units to user units.
     *
     * @param v the value to convert
     * @param d HORIZONTAL_LENGTH, VERTICAL_LENGTH, or OTHER_LENGTH
     * @param ctx the context
     */
    protected static float exsToPixels(float v, short d, Context ctx) {
        float xh = ctx.getXHeight();
        return v * xh * ctx.getFontSize();
    }


    /**
     * A LengthHandler that convert units.
     */
    public static class UnitResolver implements LengthHandler {

        /**
         * The length value.
         */
        public float value;

        /**
         * The length type.
         */
        public short unit = SVGLength.SVG_LENGTHTYPE_NUMBER;

        /**
         * Implements {@link LengthHandler#startLength()}.
         */
        public void startLength() throws ParseException {
        }

        /**
         * Implements {@link LengthHandler#lengthValue(float)}.
         */
        public void lengthValue(float v) throws ParseException {
            this.value = v;
        }

        /**
         * Implements {@link LengthHandler#em()}.
         */
        public void em() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_EMS;
        }

        /**
         * Implements {@link LengthHandler#ex()}.
         */
        public void ex() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_EXS;
        }

        /**
         * Implements {@link LengthHandler#in()}.
         */
        public void in() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_IN;
        }

        /**
         * Implements {@link LengthHandler#cm()}.
         */
        public void cm() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_CM;
        }

        /**
         * Implements {@link LengthHandler#mm()}.
         */
        public void mm() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_MM;
        }

        /**
         * Implements {@link LengthHandler#pc()}.
         */
        public void pc() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_PC;
        }

        /**
         * Implements {@link LengthHandler#pt()}.
         */
        public void pt() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_PT;
        }

        /**
         * Implements {@link LengthHandler#px()}.
         */
        public void px() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_PX;
        }

        /**
         * Implements {@link LengthHandler#percentage()}.
         */
        public void percentage() throws ParseException {
            this.unit = SVGLength.SVG_LENGTHTYPE_PERCENTAGE;
        }

        /**
         * Implements {@link LengthHandler#endLength()}.
         */
        public void endLength() throws ParseException {
        }
    }

    /**
     * Holds the informations needed to compute the units.
     */
    public interface Context {

        /**
         * Returns the element.
         */
        Element getElement();

        /**
         * Returns the size of a px CSS unit in millimeters.
         */
        float getPixelUnitToMillimeter();

        /**
         * Returns the size of a px CSS unit in millimeters.
         * This will be removed after next release.
         * @see #getPixelUnitToMillimeter()
         */
        float getPixelToMM();

        /**
         * Returns the font-size value.
         */
        float getFontSize();

        /**
         * Returns the x-height value.
         */
        float getXHeight();

        /**
         * Returns the viewport width used to compute units.
         */
        float getViewportWidth();

        /**
         * Returns the viewport height used to compute units.
         */
        float getViewportHeight();
    }
}
