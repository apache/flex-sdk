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

import org.apache.flex.forks.batik.css.engine.CSSNavigableNode;
import org.apache.flex.forks.batik.dom.AbstractAttr;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.events.MutationEvent;

/**
 * This class provides a superclass to implement an SVG element, or
 * an element interoperable with the SVG elements.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public abstract class AbstractElement
        extends org.apache.flex.forks.batik.dom.AbstractElement
        implements NodeEventTarget, CSSNavigableNode, SVGConstants {

    /**
     * The live attribute values.
     */
    protected transient DoublyIndexedTable liveAttributeValues =
        new DoublyIndexedTable();

    /**
     * Creates a new Element object.
     */
    protected AbstractElement() {
    }

    /**
     * Creates a new Element object.
     * @param prefix The namespace prefix.
     * @param owner  The owner document.
     */
    protected AbstractElement(String prefix, AbstractDocument owner) {
        ownerDocument = owner;
        setPrefix(prefix);
        initializeAttributes();
    }

    // CSSNavigableNode ///////////////////////////////////////////////////

    /**
     * Returns the CSS parent node of this node.
     */
    public Node getCSSParentNode() {
        return getXblParentNode();
    }

    /**
     * Returns the CSS previous sibling node of this node.
     */
    public Node getCSSPreviousSibling() {
        return getXblPreviousSibling();
    }

    /**
     * Returns the CSS next sibling node of this node.
     */
    public Node getCSSNextSibling() {
        return getXblNextSibling();
    }

    /**
     * Returns the CSS first child node of this node.
     */
    public Node getCSSFirstChild() {
        return getXblFirstChild();
    }

    /**
     * Returns the CSS last child of this node.
     */
    public Node getCSSLastChild() {
        return getXblLastChild();
    }

    /**
     * Returns whether this node is the root of a (conceptual) hidden tree
     * that selectors will not work across.
     */
    public boolean isHiddenFromSelectors() {
        return false;
    }

    // Attributes /////////////////////////////////////////////////////////

    public void fireDOMAttrModifiedEvent(String name, Attr node, String oldv,
                                         String newv, short change) {
        super.fireDOMAttrModifiedEvent(name, node, oldv, newv, change);
        // This handles the SVG 1.2 behaviour where setting the value of
        // 'id' must also change 'xml:id', and vice versa.
        if (((SVGOMDocument) ownerDocument).isSVG12
                && (change == MutationEvent.ADDITION
                    || change == MutationEvent.MODIFICATION)) {
            if (node.getNamespaceURI() == null
                    && node.getNodeName().equals(SVG_ID_ATTRIBUTE)) {
                Attr a =
                    getAttributeNodeNS(XML_NAMESPACE_URI, SVG_ID_ATTRIBUTE);
                if (a == null) {
                    setAttributeNS(XML_NAMESPACE_URI, SVG_ID_ATTRIBUTE, newv);
                } else if (!a.getNodeValue().equals(newv)) {
                    a.setNodeValue(newv);
                }
            } else if (node.getNodeName().equals(XML_ID_QNAME)) {
                Attr a = getAttributeNodeNS(null, SVG_ID_ATTRIBUTE);
                if (a == null) {
                    setAttributeNS(null, SVG_ID_ATTRIBUTE, newv);
                } else if (!a.getNodeValue().equals(newv)) {
                    a.setNodeValue(newv);
                }
            }
        }
    }

    /**
     * Returns the live attribute value associated with given
     * attribute, if any.
     * @param ns The attribute's namespace.
     * @param ln The attribute's local name.
     */
    public LiveAttributeValue getLiveAttributeValue(String ns, String ln) {
//         if (liveAttributeValues == null) {
//             return null;
//         }
        return (LiveAttributeValue)liveAttributeValues.get(ns, ln);
    }

    /**
     * Associates a live attribute value to this element.
     * @param ns The attribute's namespace.
     * @param ln The attribute's local name.
     * @param val The live value.
     */
    public void putLiveAttributeValue(String ns, String ln,
                                      LiveAttributeValue val) {
//         if (liveAttributeValues == null) {
//             liveAttributeValues = new SoftDoublyIndexedTable();
//         }
        liveAttributeValues.put(ns, ln, val);
    }

    /**
     * Returns the AttributeInitializer for this element type.
     * @return null if this element has no attribute with a default value.
     */
    protected AttributeInitializer getAttributeInitializer() {
        return null;
    }

    /**
     * Initializes the attributes of this element to their default value.
     */
    protected void initializeAttributes() {
        AttributeInitializer ai = getAttributeInitializer();
        if (ai != null) {
            ai.initializeAttributes(this);
        }
    }

    /**
     * Resets an attribute to the default value.
     * @return true if a default value is known for the given attribute.
     */
    protected boolean resetAttribute(String ns, String prefix, String ln) {
        AttributeInitializer ai = getAttributeInitializer();
        if (ai == null) {
            return false;
        }
        return ai.resetAttribute(this, ns, prefix, ln);
    }

    /**
     * Creates the attribute list.
     */
    protected NamedNodeMap createAttributes() {
        return new ExtendedNamedNodeHashMap();
    }

    /**
     * Sets an unspecified attribute.
     * @param nsURI The attribute namespace URI.
     * @param name The attribute's qualified name.
     * @param value The attribute's default value.
    */
    public void setUnspecifiedAttribute(String nsURI, String name,
                                        String value) {
        if (attributes == null) {
            attributes = createAttributes();
        }
        ((ExtendedNamedNodeHashMap)attributes).
            setUnspecifiedAttribute(nsURI, name, value);
    }

    /**
     * Called when an attribute has been added.
     */
    protected void attrAdded(Attr node, String newv) {
        LiveAttributeValue lav = getLiveAttributeValue(node);
        if (lav != null) {
            lav.attrAdded(node, newv);
        }
    }

    /**
     * Called when an attribute has been modified.
     */
    protected void attrModified(Attr node, String oldv, String newv) {
        LiveAttributeValue lav = getLiveAttributeValue(node);
        if (lav != null) {
            lav.attrModified(node, oldv, newv);
        }
    }

    /**
     * Called when an attribute has been removed.
     */
    protected void attrRemoved(Attr node, String oldv) {
        LiveAttributeValue lav = getLiveAttributeValue(node);
        if (lav != null) {
            lav.attrRemoved(node, oldv);
        }
    }

    /**
     * Gets Returns the live attribute value associated with given
     * attribute, if any.
     */
    private LiveAttributeValue getLiveAttributeValue(Attr node) {
        String ns = node.getNamespaceURI();
        return getLiveAttributeValue(ns, (ns == null)
                                     ? node.getNodeName()
                                     : node.getLocalName());
    }

    // Importation ////////////////////////////////////////////////////

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        super.export(n, d);
        ((AbstractElement)n).initializeAttributes();

        super.export(n, d);
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        super.export(n, d);
        ((AbstractElement)n).initializeAttributes();

        super.deepExport(n, d);
        return n;
    }

    /**
     * An implementation of the {@link NamedNodeMap}.
     */
    protected class ExtendedNamedNodeHashMap extends NamedNodeHashMap {

        /**
         * Creates a new ExtendedNamedNodeHashMap object.
         */
        public ExtendedNamedNodeHashMap() {
        }

        /**
         * Adds an unspecified attribute to the map.
         *
         * @param nsURI The attribute namespace URI.
         * @param name The attribute's qualified name.
         * @param value The attribute's default value.
         */
        public void setUnspecifiedAttribute( String nsURI, String name,
                                             String value ) {
            Attr attr = getOwnerDocument().createAttributeNS( nsURI, name );
            attr.setValue( value );
            ( (AbstractAttr)attr ).setSpecified( false );
            setNamedItemNS( attr );
        }

        /**
         * <b>DOM</b>: Implements {@link NamedNodeMap#removeNamedItemNS(String,String)}.
         */
        public Node removeNamedItemNS( String namespaceURI, String localName )
                throws DOMException {
            if ( isReadonly() ) {
                throw createDOMException
                        ( DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                "readonly.node.map",
                                new Object[]{} );
            }
            if ( localName == null ) {
                throw createDOMException( DOMException.NOT_FOUND_ERR,
                        "attribute.missing",
                        new Object[]{""} );
            }
            AbstractAttr n = (AbstractAttr)remove( namespaceURI, localName );
            if ( n == null ) {
                throw createDOMException( DOMException.NOT_FOUND_ERR,
                        "attribute.missing",
                        new Object[]{localName} );
            }
            n.setOwnerElement( null );
            String prefix = n.getPrefix();

            // Reset the attribute to its default value
            if ( !resetAttribute( namespaceURI, prefix, localName ) ) {
                // Mutation event
                fireDOMAttrModifiedEvent( n.getNodeName(), n,
                        n.getNodeValue(), "",
                        MutationEvent.REMOVAL );
            }
            return n;
        }
    }
}
