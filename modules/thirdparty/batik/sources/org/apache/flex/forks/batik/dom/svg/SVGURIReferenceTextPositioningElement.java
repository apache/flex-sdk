/*

   Copyright 2001-2003  The Apache Software Foundation 

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
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGURIReference;

/**
 * This class implements both {@link org.w3c.flex.forks.dom.svg.SVGTextPositioningElement}
 * and {@link SVGURIReference}..
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGURIReferenceTextPositioningElement.java,v 1.6 2004/08/18 07:13:19 vhardy Exp $
 */
public abstract class SVGURIReferenceTextPositioningElement
    extends    SVGOMTextPositioningElement
    implements SVGURIReference {

    /**
     * Creates a new SVGURIReferenceTextPositioningElement object.
     */
    protected SVGURIReferenceTextPositioningElement() {
    }

    /**
     * Creates a new SVGURIReferenceTextPositioningElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGURIReferenceTextPositioningElement(String prefix,
                                                    AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.flex.forks.dom.svg.SVGURIReference#getHref()}.
     */
    public SVGAnimatedString getHref() {
        return SVGURIReferenceSupport.getHref(this);
    }
}
