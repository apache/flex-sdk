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
import org.w3c.flex.forks.dom.svg.SVGFECompositeElement;

/**
 * This class implements {@link SVGFECompositeElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFECompositeElement.java,v 1.13 2004/08/18 07:13:15 vhardy Exp $
 */
public class SVGOMFECompositeElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFECompositeElement {

    /**
     * The 'operator' attribute values.
     */
    protected final static String[] OPERATOR_VALUES = {
        "",
        SVG_OVER_VALUE,
        SVG_IN_VALUE,
        SVG_OUT_VALUE,
        SVG_ATOP_VALUE,
        SVG_XOR_VALUE,
        SVG_ARITHMETIC_VALUE
    };

    /**
     * Creates a new SVGOMFECompositeElement object.
     */
    protected SVGOMFECompositeElement() {
    }

    /**
     * Creates a new SVGOMFECompositeElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFECompositeElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_COMPOSITE_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFECompositeElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return getAnimatedStringAttribute(null, SVG_IN_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFECompositeElement#getIn2()}.
     */
    public SVGAnimatedString getIn2() {
        return getAnimatedStringAttribute(null, SVG_IN2_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFECompositeElement#getOperator()}.
     */
    public SVGAnimatedEnumeration getOperator() {
        return getAnimatedEnumerationAttribute
            (null, SVG_OPERATOR_ATTRIBUTE, OPERATOR_VALUES, (short)1);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFECompositeElement#getK1()}.
     */
    public SVGAnimatedNumber getK1() {
        return getAnimatedNumberAttribute(null, SVG_K1_ATTRIBUTE, 0f);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFECompositeElement#getK2()}.
     */
    public SVGAnimatedNumber getK2() {
        return getAnimatedNumberAttribute(null, SVG_K2_ATTRIBUTE, 0f);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFECompositeElement#getK3()}.
     */
    public SVGAnimatedNumber getK3() {
        return getAnimatedNumberAttribute(null, SVG_K3_ATTRIBUTE, 0f);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFECompositeElement#getK4()}.
     */
    public SVGAnimatedNumber getK4() {
        return getAnimatedNumberAttribute(null, SVG_K4_ATTRIBUTE, 0f);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFECompositeElement();
    }
}
