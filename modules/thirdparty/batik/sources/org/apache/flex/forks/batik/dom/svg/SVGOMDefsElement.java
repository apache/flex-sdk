/*

   Copyright 2000-2001  The Apache Software Foundation 

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
import org.w3c.flex.forks.dom.svg.SVGDefsElement;

/**
 * This class implements {@link SVGDefsElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMDefsElement.java,v 1.6 2004/08/18 07:13:15 vhardy Exp $
 */
public class SVGOMDefsElement
    extends    SVGGraphicsElement
    implements SVGDefsElement {

    /**
     * Creates a new SVGOMDefsElement object.
     */
    protected SVGOMDefsElement() {
    }

    /**
     * Creates a new SVGOMDefsElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMDefsElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);

    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_DEFS_TAG;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMDefsElement();
    }
}
