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
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumber;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGFEDisplacementMapElement;

/**
 * This class implements {@link org.w3c.flex.forks.dom.svg.SVGFEDisplacementMapElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEDisplacementMapElement.java,v 1.12 2004/08/18 07:13:15 vhardy Exp $
 */
public class SVGOMFEDisplacementMapElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEDisplacementMapElement {

    /**
     * The 'xChannelSelector' and 'yChannelSelector' attributes values.
     */
    protected final static String[] CHANNEL_SELECTOR_VALUES = {
        "",
        SVG_R_VALUE,
        SVG_G_VALUE,
        SVG_B_VALUE,
        SVG_A_VALUE
    };

    /**
     * Creates a new SVGOMFEDisplacementMap object.
     */
    protected SVGOMFEDisplacementMapElement() {
    }

    /**
     * Creates a new SVGOMFEDisplacementMapElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEDisplacementMapElement(String prefix,
                                         AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_DISPLACEMENT_MAP_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEDisplacementMapElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return getAnimatedStringAttribute(null, SVG_IN_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEDisplacementMapElement#getIn2()}.
     */
    public SVGAnimatedString getIn2() {
        return getAnimatedStringAttribute(null, SVG_IN2_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFEDisplacementMapElement#getScale()}.
     */
    public SVGAnimatedNumber getScale() {
        return getAnimatedNumberAttribute(null, SVG_SCALE_ATTRIBUTE, 0f);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEDisplacementMapElement#getXChannelSelector()}.
     */
    public SVGAnimatedEnumeration getXChannelSelector() {
        return getAnimatedEnumerationAttribute
            (null, SVG_X_CHANNEL_SELECTOR_ATTRIBUTE,
             CHANNEL_SELECTOR_VALUES, (short)4);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEDisplacementMapElement#getYChannelSelector()}.
     */
    public SVGAnimatedEnumeration getYChannelSelector() {
        return getAnimatedEnumerationAttribute
            (null, SVG_Y_CHANNEL_SELECTOR_ATTRIBUTE,
             CHANNEL_SELECTOR_VALUES, (short)4);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEDisplacementMapElement();
    }
}
