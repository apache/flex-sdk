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
import org.w3c.dom.Attr;
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGRadialGradientElement;

/**
 * This class implements {@link SVGRadialGradientElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMRadialGradientElement.java,v 1.9 2004/08/18 07:13:17 vhardy Exp $
 */
public class SVGOMRadialGradientElement
    extends    SVGOMGradientElement
    implements SVGRadialGradientElement {

    /**
     * Creates a new SVGOMRadialGradientElement object.
     */
    protected SVGOMRadialGradientElement() {
    }

    /**
     * Creates a new SVGOMRadialGradientElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMRadialGradientElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_RADIAL_GRADIENT_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGRadialGradientElement#getCx()}.
     */
    public SVGAnimatedLength getCx() {
        return getAnimatedLengthAttribute
            (null, SVG_CX_ATTRIBUTE, SVG_RADIAL_GRADIENT_CX_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGRadialGradientElement#getCy()}.
     */
    public SVGAnimatedLength getCy() {
        return getAnimatedLengthAttribute
            (null, SVG_CY_ATTRIBUTE, SVG_RADIAL_GRADIENT_CY_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGRadialGradientElement#getR()}.
     */
    public SVGAnimatedLength getR() {
        return getAnimatedLengthAttribute
            (null, SVG_R_ATTRIBUTE, SVG_RADIAL_GRADIENT_R_DEFAULT_VALUE,
             SVGOMAnimatedLength.OTHER_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGRadialGradientElement#getFx()}.
     */
    public SVGAnimatedLength getFx() {
        SVGAnimatedLength result =
            (SVGAnimatedLength)getLiveAttributeValue(null, SVG_FX_ATTRIBUTE);
        if (result == null) {
            result = new AbstractSVGAnimatedLength
                (this, null, SVG_FX_ATTRIBUTE,
                 SVGOMAnimatedLength.HORIZONTAL_LENGTH) {
                    protected String getDefaultValue() {
                        Attr attr = getAttributeNodeNS(null, SVG_CX_ATTRIBUTE);
                        if (attr == null) {
                            return SVG_RADIAL_GRADIENT_CX_DEFAULT_VALUE;
                        }
                        return attr.getValue();
                    }
                };
            putLiveAttributeValue(null, SVG_FX_ATTRIBUTE,
                                  (LiveAttributeValue)result);
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGRadialGradientElement#getFy()}.
     */
    public SVGAnimatedLength getFy() {
        SVGAnimatedLength result =
            (SVGAnimatedLength)getLiveAttributeValue(null, SVG_FY_ATTRIBUTE);
        if (result == null) {
            result = new AbstractSVGAnimatedLength
                (this, null, SVG_FY_ATTRIBUTE,
                 SVGOMAnimatedLength.VERTICAL_LENGTH) {
                    protected String getDefaultValue() {
                        Attr attr = getAttributeNodeNS(null, SVG_CY_ATTRIBUTE);
                        if (attr == null) {
                            return SVG_RADIAL_GRADIENT_CY_DEFAULT_VALUE;
                        }
                        return attr.getValue();
                    }
                };
            putLiveAttributeValue(null, SVG_FY_ATTRIBUTE,
                                  (LiveAttributeValue)result);
        }
        return result;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMRadialGradientElement();
    }
}
