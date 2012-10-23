/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.dom.svg12;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.svg.AttributeInitializer;
import org.apache.flex.forks.batik.dom.svg.SVGGraphicsElement;

import org.w3c.dom.Node;

/**
 * This class implements foreign namespace elements that can be
 * bound with XBL.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: BindableElement.java 475477 2006-11-15 22:44:28Z cam $
 */
public class BindableElement extends SVGGraphicsElement {

    /**
     * The namespace URI of the custom element.
     */
    protected String namespaceURI;

    /**
     * The local name of the custom element.
     */
    protected String localName;

    /**
     * The shadow tree.
     */
    protected XBLOMShadowTreeElement xblShadowTree;

    /**
     * Creates a new BindableElement object.
     */
    protected BindableElement() {
    }

    /**
     * Creates a new BindableElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     * @param ns The namespace of the custom element.
     * @param ln The local name of the custom element.
     */
    public BindableElement(String prefix,
                           AbstractDocument owner,
                           String ns,
                           String ln) {
        super(prefix, owner);
        namespaceURI = ns;
        localName = ln;
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getNamespaceURI()}.
     */
    public String getNamespaceURI() {
        return namespaceURI;
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return localName;
    }

    /**
     * Returns the AttributeInitializer for this element type.
     * @return null if this element has no attribute with a default value.
     */
    protected AttributeInitializer getAttributeInitializer() {
        return null;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new BindableElement(null, null, namespaceURI, localName);
    }

    /**
     * Sets the shadow tree for this bindable element.
     */
    public void setShadowTree(XBLOMShadowTreeElement s) {
        xblShadowTree = s;
    }

    /**
     * Returns the shadow tree for this bindable element.
     */
    public XBLOMShadowTreeElement getShadowTree() {
        return xblShadowTree;
    }

    // CSSNavigableNode ///////////////////////////////////////////////

    /**
     * Returns the shadow tree.
     */
    public Node getCSSFirstChild() {
        if (xblShadowTree != null) {
            return xblShadowTree.getFirstChild();
        }
        return null;
    }

    /**
     * Returns the shadow tree.
     */
    public Node getCSSLastChild() {
        return getCSSFirstChild();
    }
}
