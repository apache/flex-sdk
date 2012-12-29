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

import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGAnimatedAngle;
import org.w3c.dom.svg.SVGAnimatedEnumeration;
import org.w3c.dom.svg.SVGAngle;
import org.w3c.dom.svg.SVGMarkerElement;

/**
 * A class that handles an {@link SVGAnimatedAngle} and an
 * {@link SVGAnimatedEnumeration} for the 'marker' element's
 * 'orient' attribute.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGOMAnimatedMarkerOrientValue.java 591550 2007-11-03 04:46:27Z cam $
 */
public class SVGOMAnimatedMarkerOrientValue extends AbstractSVGAnimatedValue {

    /**
     * Whether the base value is valid.
     */
    protected boolean valid;

    /**
     * The SVGAnimatedAngle.
     */
    protected AnimatedAngle animatedAngle = new AnimatedAngle();

    /**
     * The SVGAnimatedEnumeration.
     */
    protected AnimatedEnumeration animatedEnumeration =
        new AnimatedEnumeration();

    /**
     * The current base angle value.
     */
    protected BaseSVGAngle baseAngleVal;

    /**
     * The current base enumeration value.
     */
    protected short baseEnumerationVal;

    /**
     * The current animated angle value.
     */
    protected AnimSVGAngle animAngleVal;

    /**
     * The current animated enumeration value.
     */
    protected short animEnumerationVal;

    /**
     * Whether the value is changing.
     */
    protected boolean changing;

    /**
     * Creates a new SVGOMAnimatedMarkerOrientValue.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     */
    public SVGOMAnimatedMarkerOrientValue(AbstractElement elt,
                                          String ns,
                                          String ln) {
        super(elt, ns, ln);
    }

    /**
     * Updates the animated value with the given {@link AnimatableValue}.
     */
   protected void updateAnimatedValue(AnimatableValue val) {
        // XXX TODO
        throw new UnsupportedOperationException
            ("Animation of marker orient value is not implemented");
    }

    /**
     * Returns the base value of the attribute as an {@link AnimatableValue}.
     */
    public AnimatableValue getUnderlyingValue(AnimationTarget target) {
        // XXX TODO
        throw new UnsupportedOperationException
            ("Animation of marker orient value is not implemented");
    }
    
    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
        if (!changing) {
            valid = false;
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
        if (!changing) {
            valid = false;
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * Called when an Attr node has been removed.
     */
    public void attrRemoved(Attr node, String oldv) {
        if (!changing) {
            valid = false;
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * Sets the animated value to the given angle.
     */
    public void setAnimatedValueToAngle(short unitType, float value) {
        hasAnimVal = true;
        animAngleVal.setAnimatedValue(unitType, value);
        animEnumerationVal = SVGMarkerElement.SVG_MARKER_ORIENT_ANGLE;
        fireAnimatedAttributeListeners();
    }

    /**
     * Sets the animated value to the "auto" value.
     */
    public void setAnimatedValueToAuto() {
        hasAnimVal = true;
        animAngleVal.setAnimatedValue(SVGAngle.SVG_ANGLETYPE_UNSPECIFIED, 0);
        animEnumerationVal = SVGMarkerElement.SVG_MARKER_ORIENT_AUTO;
        fireAnimatedAttributeListeners();
    }

    /**
     * Resets the animated value.
     */
    public void resetAnimatedValue() {
        hasAnimVal = false;
        fireAnimatedAttributeListeners();
    }

    /**
     * Returns the {@link SVGAnimatedAngle} component of the orient value.
     */
    public SVGAnimatedAngle getAnimatedAngle() {
        return animatedAngle;
    }

    /**
     * Returns the {@link SVGAnimatedEnumeration} component of the orient value.
     */
    public SVGAnimatedEnumeration getAnimatedEnumeration() {
        return animatedEnumeration;
    }

    /**
     * This class represents the SVGAngle returned by
     * {@link AnimatedAngle#getBaseVal()}.
     */
    protected class BaseSVGAngle extends SVGOMAngle {

        /**
         * Invalidates this angle.
         */
        public void invalidate() {
            valid = false;
        }

        /**
         * Resets the value of the associated attribute.
         */
        protected void reset() {
            try {
                changing = true;
                valid = true;
                String value;
                if (baseEnumerationVal ==
                        SVGMarkerElement.SVG_MARKER_ORIENT_ANGLE) {
                    value = getValueAsString();
                } else if (baseEnumerationVal ==
                        SVGMarkerElement.SVG_MARKER_ORIENT_AUTO) {
                    value = SVGConstants.SVG_AUTO_VALUE;
                } else {
                    return;
                }
                element.setAttributeNS(namespaceURI, localName, value);
            } finally {
                changing = false;
            }
        }

        /**
         * Initializes the angle, if needed.
         */
        protected void revalidate() {
            if (!valid) {
                Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
                if (attr == null) {
                    unitType = SVGAngle.SVG_ANGLETYPE_UNSPECIFIED;
                    value = 0;
                } else {
                    parse(attr.getValue());
                }
                valid = true;
            }
        }

        /**
         * Parse a String value as an SVGAngle.  If orient="auto", the
         * method will parse the value "0" instead.
         */
        protected void parse(String s) {
            if (s.equals(SVGConstants.SVG_AUTO_VALUE)) {
                unitType = SVGAngle.SVG_ANGLETYPE_UNSPECIFIED;
                value = 0;
                baseEnumerationVal = SVGMarkerElement.SVG_MARKER_ORIENT_AUTO;
            } else {
                super.parse(s);
                if (unitType == SVGAngle.SVG_ANGLETYPE_UNKNOWN) {
                    baseEnumerationVal = SVGMarkerElement.SVG_MARKER_ORIENT_UNKNOWN;
                } else {
                    baseEnumerationVal = SVGMarkerElement.SVG_MARKER_ORIENT_ANGLE;
                }
            }
        }
    }

    /**
     * This class represents the SVGAngle returned by {@link AnimatedAngle#getAnimVal()}.
     */
    protected class AnimSVGAngle extends SVGOMAngle {

        /**
         * <b>DOM</b>: Implements {@link SVGAngle#getUnitType()}.
         */
        public short getUnitType() {
            if (hasAnimVal) {
                return super.getUnitType();
            }
            return animatedAngle.getBaseVal().getUnitType();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGAngle#getValue()}.
         */
        public float getValue() {
            if (hasAnimVal) {
                return super.getValue();
            }
            return animatedAngle.getBaseVal().getValue();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGAngle#getValueInSpecifiedUnits()}.
         */
        public float getValueInSpecifiedUnits() {
            if (hasAnimVal) {
                return super.getValueInSpecifiedUnits();
            }
            return animatedAngle.getBaseVal().getValueInSpecifiedUnits();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGAngle#getValueAsString()}.
         */
        public String getValueAsString() {
            if (hasAnimVal) {
                return super.getValueAsString();
            }
            return animatedAngle.getBaseVal().getValueAsString();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGAngle#setValue(float)}.
         */
        public void setValue(float value) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.angle",
                 null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGAngle#setValueInSpecifiedUnits(float)}.
         */
        public void setValueInSpecifiedUnits(float value) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.angle",
                 null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGAngle#setValueAsString(String)}.
         */
        public void setValueAsString(String value) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.angle",
                 null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGAngle#newValueSpecifiedUnits(short,float)}.
         */
        public void newValueSpecifiedUnits(short unit, float value) {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.angle",
                 null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGAngle#convertToSpecifiedUnits(short)}.
         */
        public void convertToSpecifiedUnits(short unit) {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.angle",
                 null);
        }

        /**
         * Sets the animated value.
         */
        protected void setAnimatedValue(int type, float val) {
            super.newValueSpecifiedUnits((short) type, val);
        }
    }

    /**
     * The {@link SVGAnimatedAngle} component of the marker orient value.
     */
    protected class AnimatedAngle implements SVGAnimatedAngle {

        /**
         * <b>DOM</b>: Implements {@link SVGAnimatedAngle#getBaseVal()}.
         */
        public SVGAngle getBaseVal() {
            if (baseAngleVal == null) {
                baseAngleVal = new BaseSVGAngle();
            }
            return baseAngleVal;
        }

        /**
         * <b>DOM</b>: Implements {@link SVGAnimatedAngle#getAnimVal()}.
         */
        public SVGAngle getAnimVal() {
            if (animAngleVal == null) {
                animAngleVal = new AnimSVGAngle();
            }
            return animAngleVal;
        }
    }

    /**
     * The {@link SVGAnimatedEnumeration} component of the marker orient value.
     */
    protected class AnimatedEnumeration implements SVGAnimatedEnumeration {

        /**
         * <b>DOM</b>: Implements {@link SVGAnimatedEnumeration#getBaseVal()}.
         */
        public short getBaseVal() {
            if (baseAngleVal == null) {
                baseAngleVal = new BaseSVGAngle();
            }
            baseAngleVal.revalidate();
            return baseEnumerationVal;
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGAnimatedEnumeration#setBaseVal(short)}.
         */
        public void setBaseVal(short baseVal) throws DOMException {
            if (baseVal == SVGMarkerElement.SVG_MARKER_ORIENT_AUTO) {
                baseEnumerationVal = baseVal;
                if (baseAngleVal == null) {
                    baseAngleVal = new BaseSVGAngle();
                }
                baseAngleVal.unitType = SVGAngle.SVG_ANGLETYPE_UNSPECIFIED;
                baseAngleVal.value = 0;
                baseAngleVal.reset();
            } else if (baseVal == SVGMarkerElement.SVG_MARKER_ORIENT_ANGLE) {
                baseEnumerationVal = baseVal;
                if (baseAngleVal == null) {
                    baseAngleVal = new BaseSVGAngle();
                }
                baseAngleVal.reset();
            }
        }

        /**
         * <b>DOM</b>: Implements {@link SVGAnimatedEnumeration#getAnimVal()}.
         */
        public short getAnimVal() {
            if (hasAnimVal) {
                return animEnumerationVal;
            }
            if (baseAngleVal == null) {
                baseAngleVal = new BaseSVGAngle();
            }
            baseAngleVal.revalidate();
            return baseEnumerationVal;
        }
    }
}
