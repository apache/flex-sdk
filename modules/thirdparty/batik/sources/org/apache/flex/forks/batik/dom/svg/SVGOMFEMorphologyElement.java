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
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGFEMorphologyElement;

/**
 * This class implements {@link SVGFEMorphologyElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEMorphologyElement.java,v 1.9 2004/08/18 07:13:15 vhardy Exp $
 */
public class SVGOMFEMorphologyElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEMorphologyElement {

    /**
     * The 'operator' attribute values.
     */
    protected final static String[] OPERATOR_VALUES = {
        "",
        SVG_ERODE_VALUE,
        SVG_DILATE_VALUE
    };

    /**
     * Creates a new SVGOMFEMorphologyElement object.
     */
    protected SVGOMFEMorphologyElement() {
    }

    /**
     * Creates a new SVGOMFEMorphologyElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEMorphologyElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_MORPHOLOGY_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEMorphologyElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return getAnimatedStringAttribute(null, SVG_IN_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEMorphologyElement#getOperator()}.
     */
    public SVGAnimatedEnumeration getOperator() {
        return getAnimatedEnumerationAttribute
            (null, SVG_OPERATOR_ATTRIBUTE, OPERATOR_VALUES, (short)1);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEMorphologyElement#getRadiusX()}.
     */
    public SVGAnimatedLength getRadiusX() {
        throw new RuntimeException(" !!! TODO getRadiusX()");
    } 

    /**
     * <b>DOM</b>: Implements {@link SVGFEMorphologyElement#getRadiusY()}.
     */
    public SVGAnimatedLength getRadiusY() {
        throw new RuntimeException(" !!! TODO getRadiusY()");
    } 

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEMorphologyElement();
    }
}
