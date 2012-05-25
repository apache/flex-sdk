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
import org.w3c.flex.forks.dom.svg.SVGAnimatedBoolean;
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;
import org.w3c.flex.forks.dom.svg.SVGAnimatedInteger;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumber;
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumberList;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGFEConvolveMatrixElement;

/**
 * This class implements {@link SVGFEConvolveMatrixElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEConvolveMatrixElement.java,v 1.13 2004/08/18 07:13:15 vhardy Exp $
 */
public class SVGOMFEConvolveMatrixElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEConvolveMatrixElement {

    /**
     * The 'edgeMode' attribute values.
     */
    protected final static String[] EDGE_MODE_VALUES = {
        "",
        SVG_DUPLICATE_VALUE,
        SVG_WRAP_VALUE,
        SVG_NONE_VALUE
    };

    /**
     * Creates a new SVGOMFEConvolveMatrixElement object.
     */
    protected SVGOMFEConvolveMatrixElement() {
    }

    /**
     * Creates a new SVGOMFEConvolveMatrixElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEConvolveMatrixElement(String prefix,
                                        AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_CONVOLVE_MATRIX_TAG;
    }

    /**
     * <b>DOM</b>: Implements { @link SVGFEConvolveMatrixElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return getAnimatedStringAttribute(null, SVG_IN_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getEdgeMode()}.
     */
    public SVGAnimatedEnumeration getEdgeMode() {
        return getAnimatedEnumerationAttribute
            (null, SVG_EDGE_MODE_ATTRIBUTE, EDGE_MODE_VALUES, (short)1);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getKernelMatrix()}.
     */
    public SVGAnimatedNumberList getKernelMatrix() {
        throw new RuntimeException("!!! TODO: getKernelMatrix()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getOrderX()}.
     */
    public SVGAnimatedInteger getOrderX() {
        throw new RuntimeException("!!! TODO: getOrderX()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getOrderY()}.
     */
    public SVGAnimatedInteger getOrderY() {
        throw new RuntimeException("!!! TODO: getOrderY()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getTargetX()}.
     */
    public SVGAnimatedInteger getTargetX() {
        // Default value relative to orderX...
        throw new RuntimeException("!!! TODO: getTargetX()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getTargetY()}.
     */
    public SVGAnimatedInteger getTargetY() {
        // Default value relative to orderY...
        throw new RuntimeException("!!! TODO: getTargetY()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getDivisor()}.
     */
    public SVGAnimatedNumber getDivisor() {
        // Default value relative to kernel matrix...
        throw new RuntimeException("!!! TODO: getDivisor()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFEConvolveMatrixElement#getBias()}.
     */
    public SVGAnimatedNumber getBias() {
        return getAnimatedNumberAttribute(null, SVG_BIAS_ATTRIBUTE, 0f);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFEConvolveMatrixElement#getKernelUnitLengthX()}.
     */
    public SVGAnimatedLength getKernelUnitLengthX() {
        throw new RuntimeException("!!! TODO: getKernelUnitLengthX()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFEConvolveMatrixElement#getKernelUnitLengthY()}.
     */
    public SVGAnimatedLength getKernelUnitLengthY() {
        throw new RuntimeException("!!! TODO: getKernelUnitLengthY()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFEConvolveMatrixElement#getPreserveAlpha()}.
     */
    public SVGAnimatedBoolean getPreserveAlpha() {
        LiveAttributeValue lav;
        lav = getLiveAttributeValue(null, SVG_PRESERVE_ALPHA_ATTRIBUTE);
        if (lav == null) {
            lav = new SVGOMAnimatedBoolean
                (this, null, SVG_PRESERVE_ALPHA_ATTRIBUTE,
                 getAttributeNodeNS(null, SVG_PRESERVE_ALPHA_ATTRIBUTE),
                 "false");
            putLiveAttributeValue(null, SVG_PRESERVE_ALPHA_ATTRIBUTE, lav);
        }
        return (SVGAnimatedBoolean)lav;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEConvolveMatrixElement();
    }
}
