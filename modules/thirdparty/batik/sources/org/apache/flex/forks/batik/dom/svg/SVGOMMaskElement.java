/*

   Copyright 2000-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGMaskElement;

/**
 * This class implements {@link org.w3c.flex.forks.dom.svg.SVGMaskElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMMaskElement.java,v 1.12 2004/08/18 07:13:17 vhardy Exp $
 */
public class SVGOMMaskElement
    extends    SVGGraphicsElement
    implements SVGMaskElement {

    /**
     * The units values.
     */
    protected final static String[] UNITS_VALUES = {
        "",
        SVG_USER_SPACE_ON_USE_VALUE,
        SVG_OBJECT_BOUNDING_BOX_VALUE
    };

    /**
     * Creates a new SVGOMMaskElement object.
     */
    protected SVGOMMaskElement() {
    }

    /**
     * Creates a new SVGOMMaskElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMMaskElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_MASK_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getMaskUnits()}.
     */
    public SVGAnimatedEnumeration getMaskUnits() {
        return getAnimatedEnumerationAttribute
            (null, SVG_MASK_UNITS_ATTRIBUTE, UNITS_VALUES,
             (short)2);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getMaskContentUnits()}.
     */
    public SVGAnimatedEnumeration getMaskContentUnits() {
        return getAnimatedEnumerationAttribute
            (null, SVG_MASK_CONTENT_UNITS_ATTRIBUTE, UNITS_VALUES,
             (short)1);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getX()}.
     */
    public SVGAnimatedLength getX() {
        return getAnimatedLengthAttribute
            (null, SVG_X_ATTRIBUTE, SVG_MASK_X_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getY()}.
     */
    public SVGAnimatedLength getY() {
        return getAnimatedLengthAttribute
            (null, SVG_Y_ATTRIBUTE, SVG_MASK_Y_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getWidth()}.
     */
    public SVGAnimatedLength getWidth() {
        return getAnimatedLengthAttribute
            (null, SVG_WIDTH_ATTRIBUTE, SVG_MASK_WIDTH_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getHeight()}.
     */
    public SVGAnimatedLength getHeight() {
        return getAnimatedLengthAttribute
            (null, SVG_HEIGHT_ATTRIBUTE, SVG_MASK_HEIGHT_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMMaskElement();
    }
}
