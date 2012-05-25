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
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumber;
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumberList;
import org.w3c.flex.forks.dom.svg.SVGComponentTransferFunctionElement;

/**
 * This class represents the component transfer function elements.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMComponentTransferFunctionElement.java,v 1.8 2004/08/18 07:13:14 vhardy Exp $
 */
public abstract class SVGOMComponentTransferFunctionElement
    extends    SVGOMElement
    implements SVGComponentTransferFunctionElement {

    /**
     * The 'type' attribute values.
     */
    protected final static String[] TYPE_VALUES = {
        "",
        SVG_IDENTITY_VALUE,
        SVG_TABLE_VALUE,
        SVG_DISCRETE_VALUE,
        SVG_LINEAR_VALUE,
        SVG_GAMMA_VALUE
    };

    /**
     * Creates a new Element object.
     */
    protected SVGOMComponentTransferFunctionElement() {
    }

    /**
     * Creates a new Element object.
     * @param prefix The namespace prefix.
     * @param owner  The owner document.
     */
    protected SVGOMComponentTransferFunctionElement(String prefix,
                                                    AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGComponentTransferFunctionElement#getType()}.
     */
    public SVGAnimatedEnumeration getType() {
        return getAnimatedEnumerationAttribute
            (null, SVG_TYPE_ATTRIBUTE, TYPE_VALUES, (short)1);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGComponentTransferFunctionElement#getTableValues()}.
     */
    public SVGAnimatedNumberList getTableValues() {
        throw new RuntimeException("!!! TODO: getTableValues");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGComponentTransferFunctionElement#getSlope()}.
     */
    public SVGAnimatedNumber getSlope() {
        return getAnimatedNumberAttribute(null, SVG_SLOPE_ATTRIBUTE, 1f);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGComponentTransferFunctionElement#getIntercept()}.
     */
    public SVGAnimatedNumber getIntercept() {
        return getAnimatedNumberAttribute(null, SVG_INTERCEPT_ATTRIBUTE, 0f);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGComponentTransferFunctionElement#getAmplitude()}.
     */
    public SVGAnimatedNumber getAmplitude() {
        return getAnimatedNumberAttribute(null, SVG_AMPLITUDE_ATTRIBUTE, 1f);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGComponentTransferFunctionElement#getExponent()}.
     */
    public SVGAnimatedNumber getExponent() {
        return getAnimatedNumberAttribute(null, SVG_EXPONENT_ATTRIBUTE, 1f);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGComponentTransferFunctionElement#getOffset()}.
     */
    public SVGAnimatedNumber getOffset() {
        return getAnimatedNumberAttribute(null, SVG_OFFSET_ATTRIBUTE, 0f);
    }
}
