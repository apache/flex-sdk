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

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGAnimatedBoolean;

/**
 * This class implements the {@link SVGAnimatedBoolean} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAnimatedBoolean.java,v 1.5 2004/08/18 07:13:14 vhardy Exp $
 */
public class SVGOMAnimatedBoolean
    implements SVGAnimatedBoolean,
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
     * The actual boolean value.
     */
    protected boolean baseVal;

    /**
     * The default's attribute value.
     */
    protected String defaultValue;

    /**
     * Whether the mutation comes from this object.
     */
    protected boolean mutate;

    /**
     * Creates a new SVGOMAnimatedBoolean.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param attr The attribute node, if any.
     * @param val The default attribute value, if missing.
     */
    public SVGOMAnimatedBoolean(AbstractElement elt,
                                String ns,
                                String ln,
                                Attr attr,
                                String val) {
        element = elt;
        namespaceURI = ns;
        localName = ln;
        if (attr != null) {
            String s = attr.getValue();
            baseVal = "true".equals(s);
        }
        defaultValue = val;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedBoolean#getBaseVal()}.
     */
    public boolean getBaseVal() {
        return baseVal;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedBoolean#setBaseVal(boolean)}.
     */
    public void setBaseVal(boolean baseVal) throws DOMException {
        if (this.baseVal != baseVal) {
            mutate = true;
            this.baseVal = baseVal;
            element.setAttributeNS(namespaceURI, localName,
                                   (baseVal) ? "true" : "false");
            mutate = false;
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedBoolean#getAnimVal()}.
     */
    public boolean getAnimVal() {
        throw new RuntimeException("!!! TODO: getAnimVal()");
    }

    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
        if (!mutate) {
            baseVal = "true".equals(newv);
        }
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
        if (!mutate) {
            baseVal = "true".equals(newv);
        }
    }

    /**
     * Called when an Attr node has been removed.
     */
    public void attrRemoved(Attr node, String oldv) {
        if (!mutate) {
            baseVal = "true".equals(defaultValue);
        }
    }
}
