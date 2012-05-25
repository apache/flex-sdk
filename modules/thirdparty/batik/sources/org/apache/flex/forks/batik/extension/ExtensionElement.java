/*

   Copyright 2001-2002  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.extension;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;

/**
 * This class implements the basic features an element must have in order
 * to be usable as a foreign element within an SVGOMDocument.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ExtensionElement.java,v 1.5 2004/08/18 07:14:19 vhardy Exp $
 */
public abstract class ExtensionElement 
    extends SVGOMElement {

    /**
     * Creates a new Element object.
     */
    protected ExtensionElement() {
    }

    /**
     * Creates a new Element object.
     * @param name The element name, for validation purposes.
     * @param owner The owner document.
     */
    protected ExtensionElement(String name, AbstractDocument owner) {
        super(name, owner);
    }

    /**
     * Tests whether this node is readonly.
     */
    public boolean isReadonly() {
        return false;
    }

    /**
     * Sets this node readonly attribute.
     */
    public void setReadonly(boolean v) {
    }
}
