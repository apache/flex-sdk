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

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;

/**
 * This class implements the {@link SVGAnimatedString} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAnimatedString.java,v 1.7 2004/08/18 07:13:14 vhardy Exp $
 */
public class SVGOMAnimatedString
    implements SVGAnimatedString,
               LiveAttributeValue {

    /**
     * The associated element.
     */
    protected AbstractElement element;

    /**
     * The attribute's namespace URI.
     */
    protected String namespaceURI;

    /**
     * The attribute's local name.
     */
    protected String localName;

    /**
     * Creates a new SVGOMAnimatedString.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     */
    public SVGOMAnimatedString(AbstractElement elt,
                               String ns,
                               String ln) {
        element = elt;
        namespaceURI = ns;
        localName = ln;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedString#getBaseVal()}.
     */
    public String getBaseVal() {
        return element.getAttributeNS(namespaceURI, localName);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedString#setBaseVal(String)}.
     */
    public void setBaseVal(String baseVal) throws DOMException {
        element.setAttributeNS(namespaceURI, localName, baseVal);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedString#getAnimVal()}.
     */
    public String getAnimVal() {
        throw new RuntimeException("!!! TODO: getAnimVal()");
    }

    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
    }

    /**
     * Called when an Attr node has been removed.
     */
    public void attrRemoved(Attr node, String oldv) {
    }
}
