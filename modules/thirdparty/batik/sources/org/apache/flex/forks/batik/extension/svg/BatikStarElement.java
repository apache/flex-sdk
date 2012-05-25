/*

   Copyright 2001,2003  The Apache Software Foundation 

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
 * This class implements a star shape extension to sVG
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: BatikStarElement.java,v 1.6 2004/08/18 07:14:21 vhardy Exp $
 */
public class BatikStarElement
    extends    PrefixableStylableExtensionElement 
    implements BatikExtConstants {

    /**
     * Creates a new BatikStarElement object.
     */
    protected BatikStarElement() {
    }

    /**
     * Creates a new BatikStarElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public BatikStarElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return BATIK_EXT_STAR_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNamespaceURI()}.
     */
    public String getNamespaceURI() {
        return BATIK_EXT_NAMESPACE_URI;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new BatikStarElement();
    }
}
