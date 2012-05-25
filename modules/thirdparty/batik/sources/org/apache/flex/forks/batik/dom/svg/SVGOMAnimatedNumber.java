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

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumber;

/**
 * This class implements the {@link SVGAnimatedNumber} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAnimatedNumber.java,v 1.8 2004/08/18 07:13:14 vhardy Exp $
 */
public class SVGOMAnimatedNumber
    implements SVGAnimatedNumber,
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
     * The default value.
     */
    protected float defaultValue;

    /**
     * Creates a new SVGOMAnimatedNumber.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param val The default value, if the attribute is not specified.
     */
    public SVGOMAnimatedNumber(AbstractElement elt,
                               String ns,
                               String ln,
                               float  val) {
        element = elt;
        namespaceURI = ns;
        localName = ln;
        defaultValue = val;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedNumber#getBaseVal()}.
     */
    public float getBaseVal() {
        Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
        if (attr == null) {
            return defaultValue;
        }
        return Float.parseFloat(attr.getValue());
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedNumber#setBaseVal(float)}.
     */
    public void setBaseVal(float baseVal) throws DOMException {
        element.setAttributeNS(namespaceURI, localName,
                               String.valueOf(baseVal));
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedNumber#getAnimVal()}.
     */
    public float getAnimVal() {
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
