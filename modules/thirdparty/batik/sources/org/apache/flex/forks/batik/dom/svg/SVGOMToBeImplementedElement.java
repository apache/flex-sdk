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
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.w3c.dom.Node;

/**
 * This is a development only class. It is used temporarily in the
 * SVG DOM implementation for SVG elements whose DOM support has not
 * been put in.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGOMToBeImplementedElement.java 475685 2006-11-16 11:16:05Z cam $
 */
public class SVGOMToBeImplementedElement
    extends SVGGraphicsElement {
    
    /**
     * This element's local name
     */
    protected String localName;

    /**
     * Creates a new SVGOMToBeImplementedElement object.
     */
    protected SVGOMToBeImplementedElement() {
    }

    /**
     * Creates a new SVGOMToBeImplementedElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     * @param localName the local name for the element.
     */
    public SVGOMToBeImplementedElement(String prefix, AbstractDocument owner,
                                       String localName) {
        super(prefix, owner);
        this.localName = localName;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return localName;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMToBeImplementedElement();
    }

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        super.export(n, d);
        SVGOMToBeImplementedElement ae = (SVGOMToBeImplementedElement)n;
        ae.localName = localName;
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        super.deepExport(n, d);
        SVGOMToBeImplementedElement ae = (SVGOMToBeImplementedElement)n;
        ae.localName = localName;
        return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        super.copyInto(n);
        SVGOMToBeImplementedElement ae = (SVGOMToBeImplementedElement)n;
        ae.localName = localName;
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        super.deepCopyInto(n);
        SVGOMToBeImplementedElement ae = (SVGOMToBeImplementedElement)n;
        ae.localName = localName;
        return n;
    }

}
