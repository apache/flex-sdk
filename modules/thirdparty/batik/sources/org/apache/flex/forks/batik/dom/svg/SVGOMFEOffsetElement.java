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
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumber;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGFEOffsetElement;

/**
 * This class implements {@link SVGFEOffsetElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEOffsetElement.java,v 1.10 2004/08/18 07:13:15 vhardy Exp $
 */
public class SVGOMFEOffsetElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEOffsetElement {

    /**
     * Creates a new SVGOMFEOffsetElement object.
     */
    protected SVGOMFEOffsetElement() {
    }

    /**
     * Creates a new SVGOMFEOffsetElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEOffsetElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_OFFSET_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEOffsetElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return getAnimatedStringAttribute(null, SVG_IN_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFEOffsetElement#getDx()}.
     */
    public SVGAnimatedNumber getDx() {
        return getAnimatedNumberAttribute(null, SVG_DX_ATTRIBUTE, 0f);
    } 

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFEOffsetElement#getDy()}.
     */
    public SVGAnimatedNumber getDy() {
        return getAnimatedNumberAttribute(null, SVG_DY_ATTRIBUTE, 0f);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEOffsetElement();
    }
}
