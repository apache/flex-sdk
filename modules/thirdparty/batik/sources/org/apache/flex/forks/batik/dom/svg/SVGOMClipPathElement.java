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
import org.w3c.flex.forks.dom.svg.SVGClipPathElement;

/**
 * This class implements {@link SVGClipPathElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMClipPathElement.java,v 1.10 2004/08/18 07:13:14 vhardy Exp $
 */
public class SVGOMClipPathElement
    extends    SVGGraphicsElement
    implements SVGClipPathElement {

    /**
     * The clipPathUnits values.
     */
    protected final static String[] CLIP_PATH_UNITS_VALUES = {
        "",
        SVG_USER_SPACE_ON_USE_VALUE,
        SVG_OBJECT_BOUNDING_BOX_VALUE
    };

    /**
     * Creates a new SVGOMClipPathElement object.
     */
    protected SVGOMClipPathElement() {
    }

    /**
     * Creates a new SVGOMClipPathElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMClipPathElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_CLIP_PATH_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGClipPathElement#getClipPathUnits()}.
     */
    public SVGAnimatedEnumeration getClipPathUnits() {
        return getAnimatedEnumerationAttribute
            (null, SVG_CLIP_PATH_UNITS_ATTRIBUTE, CLIP_PATH_UNITS_VALUES,
             (short)1);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMClipPathElement();
    }
}
