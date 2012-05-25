/*

   Copyright 2002-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.extension.svg;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.extension.PrefixableStylableExtensionElement;
import org.w3c.dom.Node;

/**
 * This class implements a regular polygon extension to SVG
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: FlowRegionBreakElement.java,v 1.5 2004/10/29 01:08:33 deweese Exp $
 */
public class FlowRegionBreakElement
    extends    PrefixableStylableExtensionElement 
    implements BatikExtConstants {

    /**
     * Creates a new BatikRegularPolygonElement object.
     */
    protected FlowRegionBreakElement() {
    }

    /**
     * Creates a new BatikRegularPolygonElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public FlowRegionBreakElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return BATIK_EXT_FLOW_REGION_BREAK_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNamespaceURI()}.
     */
    public String getNamespaceURI() {
        return BATIK_12_NAMESPACE_URI;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new FlowRegionBreakElement();
    }
}
