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
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGFEBlendElement;

/**
 * This class implements {@link SVGFEBlendElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEBlendElement.java,v 1.10 2004/08/18 07:13:15 vhardy Exp $
 */
public class SVGOMFEBlendElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEBlendElement {

    /**
     * The 'mode' attribute values.
     */
    protected final static String[] MODE_VALUES = {
        "",
        SVG_NORMAL_VALUE,
        SVG_MULTIPLY_VALUE,
        SVG_SCREEN_VALUE,
        SVG_DARKEN_VALUE,
        SVG_LIGHTEN_VALUE
    };

    /**
     * Creates a new SVGOMFEBlendElement object.
     */
    protected SVGOMFEBlendElement() {
    }

    /**
     * Creates a new SVGOMFEBlendElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEBlendElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_BLEND_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEBlendElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return getAnimatedStringAttribute(null, SVG_IN_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEBlendElement#getIn2()}.
     */
    public SVGAnimatedString getIn2() {
        return getAnimatedStringAttribute(null, SVG_IN2_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEBlendElement#getMode()}.
     */
    public SVGAnimatedEnumeration getMode() {
        return getAnimatedEnumerationAttribute
            (null, SVG_MODE_ATTRIBUTE, MODE_VALUES, (short)1);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEBlendElement();
    }
}
