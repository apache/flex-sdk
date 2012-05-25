/*

   Copyright 2000-2002  The Apache Software Foundation 

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
import org.w3c.flex.forks.dom.svg.SVGFEDistantLightElement;

/**
 * This class implements {@link SVGFEDistantLightElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEDistantLightElement.java,v 1.10 2004/08/18 07:13:15 vhardy Exp $
 */
public class SVGOMFEDistantLightElement
    extends    SVGOMElement
    implements SVGFEDistantLightElement {

    /**
     * Creates a new SVGOMFEDistantLightElement object.
     */
    protected SVGOMFEDistantLightElement() {
    }

    /**
     * Creates a new SVGOMFEDistantLightElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEDistantLightElement(String prefix,
                                      AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_DISTANT_LIGHT_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEDistantLightElement#getAzimuth()}.
     */
    public SVGAnimatedNumber getAzimuth() {
        return getAnimatedNumberAttribute(null, SVG_AZIMUTH_ATTRIBUTE, 0f);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEDistantLightElement#getElevation()}.
     */
    public SVGAnimatedNumber getElevation() {
        return getAnimatedNumberAttribute(null, SVG_ELEVATION_ATTRIBUTE, 0f);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEDistantLightElement();
    }
}
