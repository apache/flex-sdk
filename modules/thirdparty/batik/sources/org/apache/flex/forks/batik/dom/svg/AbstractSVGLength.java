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
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.parser.LengthParser;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.UnitProcessor;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGLength;

/**
 * Default implementation for SVGLength.
 *
 * This implementation provides the basic
 * functionalities of SVGLength. To have
 * a complete implementation, an element is
 * required to resolve the units.
 *
 * According to the usage of this AbstractSVGLength,
 * the <code>reset()</code> method is after
 * changes being made to the unitType or the value
 * of this length. Before any values are return
 * to the user of the AbstractSVGLength, the
 * <code>revalidate()</code> method is being called
 * to insure the validity of the value and unit type
 * held by this object.
 *
 * @author nicolas.socheleau@bitflash.com
 * @version $Id: AbstractSVGLength.java 527382 2007-04-11 04:31:58Z cam $
 */
public abstract class AbstractSVGLength
    implements SVGLength {

    /**
     * This constant represents horizontal lengths.
     */
    public static final short HORIZONTAL_LENGTH =
        UnitProcessor.HORIZONTAL_LENGTH;

    /**
     * This constant represents vertical lengths.
     */
    public static final short VERTICAL_LENGTH =
        UnitProcessor.VERTICAL_LENGTH;

    /**
     * This constant represents other lengths.
     */
    public static final short OTHER_LENGTH =
        UnitProcessor.OTHER_LENGTH;

    /**
     * The type of this length.
     */
    protected short unitType;

    /**
     * The value of this length.
     */
    protected float value;

    /**
     * This length's direction.
     */
    protected short direction;

    /**
     * The context used to resolve the units.
     */
    protected UnitProcessor.Context context;

    /**
     * The unit string representations.
     */
    protected static final String[] UNITS = {
        "", "", "%", "em", "ex", "px", "cm", "mm", "in", "pt", "pc"
    };

    /**
     * Return the SVGElement associated to this length.
     */
    protected abstract SVGOMElement getAssociatedElement();

    /**
     * Creates a new AbstractSVGLength.
     */
    public AbstractSVGLength(short direction) {
        context = new DefaultContext();
        this.direction = direction;
        this.value = 0.0f;
        this.unitType = SVGLength.SVG_LENGTHTYPE_NUMBER;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGLength#getUnitType()}.
     */
    public short getUnitType() {
        revalidate();
        return unitType;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGLength#getValue()}.
     */
    public float getValue() {
        revalidate();
        try {
            return UnitProcessor.svgToUserSpace(value, unitType,
                                                direction, context);
        } catch (IllegalArgumentException ex) {
            // XXX Should we throw an exception here when the length
            //     type is unknown?
            return 0f;
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGLength#setValue(float)}.
     */
    public void setValue(float value) throws DOMException {
        this.value = UnitProcessor.userSpaceToSVG(value, unitType,
                                                  direction, context);
        reset();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGLength#getValueInSpecifiedUnits()}.
     */
    public float getValueInSpecifiedUnits() {
        revalidate();
        return value;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGLength#setValueInSpecifiedUnits(float)}.
     */
    public void setValueInSpecifiedUnits(float value) throws DOMException {
        revalidate();
        this.value = value;
        reset();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGLength#getValueAsString()}.
     */
    public String getValueAsString() {
        revalidate();
        if (unitType == SVGLength.SVG_LENGTHTYPE_UNKNOWN) {
            return "";
        }
        return Float.toString(value) + UNITS[unitType];
    }

    /**
     * <b>DOM</b>: Implements {@link SVGLength#setValueAsString(String)}.
     */
    public void setValueAsString(String value) throws DOMException {
        parse(value);
        reset();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGLength#newValueSpecifiedUnits(short,float)}.
     */
    public void newValueSpecifiedUnits(short unit, float value) {
        unitType = unit;
        this.value = value;
        reset();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGLength#convertToSpecifiedUnits(short)}.
     */
    public void convertToSpecifiedUnits(short unit) {
        float v = getValue();
        unitType = unit;
        setValue(v);
    }

    /**
     * Callback method after changes
     * made to this length.
     *
     * The default implementation does nothing.
     */
    protected void reset() {
    }

    /**
     * Callback method before any value
     * is return from this length.
     *
     * The default implementation does nothing.
     */
    protected void revalidate() {
    }

    /**
     * Parse a String value as a SVGLength.
     *
     * Initialize this length with the result
     * of the parsing of this value.
     * @param s String representation of a SVGlength.
     */
    protected void parse(String s) {
        try {
            LengthParser lengthParser = new LengthParser();
            UnitProcessor.UnitResolver ur =
                new UnitProcessor.UnitResolver();
            lengthParser.setLengthHandler(ur);
            lengthParser.parse(s);
            unitType = ur.unit;
            value = ur.value;
        } catch (ParseException e) {
            unitType = SVG_LENGTHTYPE_UNKNOWN;
            value = 0;
        }
    }

    /**
     * To resolve the units.
     */
    protected class DefaultContext implements UnitProcessor.Context {

        /**
         * Returns the element.
         */
        public Element getElement() {
            return getAssociatedElement();
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         */
        public float getPixelUnitToMillimeter() {
            return getAssociatedElement().getSVGContext()
                .getPixelUnitToMillimeter();
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
            return getAssociatedElement().getSVGContext().getFontSize();
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
            return getAssociatedElement().getSVGContext().getViewportWidth();
        }

        /**
         * Returns the viewport height used to compute units.
         */
        public float getViewportHeight() {
            return getAssociatedElement().getSVGContext().getViewportHeight();
        }
    }
}
