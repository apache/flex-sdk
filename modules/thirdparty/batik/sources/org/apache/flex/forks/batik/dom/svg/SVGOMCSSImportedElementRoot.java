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
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.css.engine.CSSImportedElementRoot;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.AbstractDocumentFragment;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * This class implements {@link org.w3c.dom.DocumentFragment} interface.
 * It is used to implement the SVG use element behavioUr.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMCSSImportedElementRoot.java,v 1.5 2004/08/18 07:13:14 vhardy Exp $
 */
public class SVGOMCSSImportedElementRoot
    extends    AbstractDocumentFragment
    implements CSSImportedElementRoot {

    /**
     * The parent CSS element.
     */
    protected Element cssParentElement;

    /**
     * Indicates if the imported css element is from
     * this document.
     */
    protected boolean isLocal;

    /**
     * Creates a new DocumentFragment object.
     */
    protected SVGOMCSSImportedElementRoot() {
    }

    /**
     * Creates a new DocumentFragment object.
     */
    public SVGOMCSSImportedElementRoot(AbstractDocument owner,
                                       Element parent,
                                       boolean isLocal) {
	ownerDocument = owner;
        cssParentElement = parent;
        this.isLocal = isLocal;
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

    // CSSImportedElementRoot ///////////////////////////////

    /**
     * Returns the parent of the imported element, from the CSS
     * point of view.
     */
    public Element getCSSParentElement() {
        return cssParentElement;
    }


    /**
     * Returns true if the imported CSS tree is from this
     * 'owner' document.
     */
    public boolean getIsLocal() {
        return isLocal;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMCSSImportedElementRoot();
    }
}
