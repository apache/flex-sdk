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
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;

/**
 * This class provides an implementation of the {@link
 * SVGAnimatedEnumeration} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAnimatedEnumeration.java,v 1.8 2004/08/18 07:13:14 vhardy Exp $
 */
public class SVGOMAnimatedEnumeration
    implements SVGAnimatedEnumeration,
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
     * The values in this enumeration.
     */
    protected String[] values;

    /**
     * The default value, if the attribute is not specified.
     */
    protected short defaultValue;

    /**
     * Creates a new SVGOMAnimatedEnumeration.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param val The values in this enumeration.
     * @param def The default value to use.
     */
    public SVGOMAnimatedEnumeration(AbstractElement elt,
                                    String ns,
                                    String ln,
                                    String[] val,
                                    short def) {
        element = elt;
        namespaceURI = ns;
        localName = ln;
        values = val;
        defaultValue = def;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedEnumeration#getBaseVal()}.
     */
    public short getBaseVal() {
        String val = element.getAttributeNS(namespaceURI, localName);
        if (val.length() == 0) {
            return defaultValue;
        }
        for (short i = 0; i < values.length; i++) {
            if (val.equals(values[i])) {
                return i;
            }
        }
        return 0;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGAnimatedEnumeration#setBaseVal(short)}.
     */
    public void setBaseVal(short baseVal) throws DOMException {
        if (baseVal >= 0 && baseVal < values.length) {
            element.setAttributeNS(namespaceURI, localName, values[baseVal]);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedEnumeration#getAnimVal()}.
     */
    public short getAnimVal() {
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
