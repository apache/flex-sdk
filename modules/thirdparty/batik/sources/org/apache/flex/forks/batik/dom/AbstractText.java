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
package org.apache.flex.forks.batik.dom;

import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.util.XMLConstants;
import org.apache.flex.forks.batik.xml.XMLUtilities;

import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.Text;

/**
 * This class implements the {@link org.w3c.dom.Text} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractText.java 475685 2006-11-16 11:16:05Z cam $
 */

public abstract class AbstractText
    extends    AbstractCharacterData
    implements Text {

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Text#splitText(int)}.
     */
    public Text splitText(int offset) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        String v = getNodeValue();
        if (offset < 0 || offset >= v.length()) {
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                                     "offset",
                                     new Object[] { new Integer(offset) });
        }
        Node n = getParentNode();
        if (n == null) {
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                                     "need.parent",
                                     new Object[] {});
        }
        String t1 = v.substring(offset);
        Text t = createTextNode(t1);
        Node ns = getNextSibling();
        if (ns != null) {
            n.insertBefore(t, ns);
        } else {
            n.appendChild(t);
        }
        setNodeValue(v.substring(0, offset));
        return t;
    }

    /**
     * Get the previous <a href="http://www.w3.org/TR/2004/REC-DOM-Level-3-Core-20040407/glossary.html#dt-logically-adjacent-text-nodes">logically
     * adjacent text node</a>.
     */
    protected Node getPreviousLogicallyAdjacentTextNode(Node n) {
        Node p = n.getPreviousSibling();
        Node parent = n.getParentNode();
        while (p == null
                && parent != null
                && parent.getNodeType() == Node.ENTITY_REFERENCE_NODE) {
            p = parent;
            parent = p.getParentNode();
            p = p.getPreviousSibling();
        }
        while (p != null && p.getNodeType() == Node.ENTITY_REFERENCE_NODE) {
            p = p.getLastChild();
        }
        if (p == null) {
            return null;
        }
        int nt = p.getNodeType();
        if (nt == Node.TEXT_NODE || nt == Node.CDATA_SECTION_NODE) {
            return p;
        }
        return null;
    }

    /**
     * Get the next <a href="http://www.w3.org/TR/2004/REC-DOM-Level-3-Core-20040407/glossary.html#dt-logically-adjacent-text-nodes">logically
     * adjacent text node</a>.
     */
    protected Node getNextLogicallyAdjacentTextNode(Node n) {
        Node p = n.getNextSibling();
        Node parent = n.getParentNode();
        while (p == null
                && parent != null
                && parent.getNodeType() == Node.ENTITY_REFERENCE_NODE) {
            p = parent;
            parent = p.getParentNode();
            p = p.getNextSibling();
        }
        while (p != null && p.getNodeType() == Node.ENTITY_REFERENCE_NODE) {
            p = p.getFirstChild();
        }
        if (p == null) {
            return null;
        }
        int nt = p.getNodeType();
        if (nt == Node.TEXT_NODE || nt == Node.CDATA_SECTION_NODE) {
            return p;
        }
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Text#getWholeText()}.
     */
    public String getWholeText() {
        StringBuffer sb = new StringBuffer();
        for (Node n = this;
                n != null;
                n = getPreviousLogicallyAdjacentTextNode(n)) {
            sb.insert(0, n.getNodeValue());
        }
        for (Node n = getNextLogicallyAdjacentTextNode(this);
                n != null;
                n = getNextLogicallyAdjacentTextNode(n)) {
            sb.append(n.getNodeValue());
        }
        return sb.toString();
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Text#isElementContentWhitespace()}.
     */
    public boolean isElementContentWhitespace() {
        int len = nodeValue.length();
        for (int i = 0; i < len; i++) {
            if (!XMLUtilities.isXMLSpace(nodeValue.charAt(i))) {
                return false;
            }
        }
        Node p = getParentNode();
        if (p.getNodeType() == Node.ELEMENT_NODE) {
            String sp = XMLSupport.getXMLSpace((Element) p);
            return !sp.equals(XMLConstants.XML_PRESERVE_VALUE);
        }
        return true;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Text#replaceWholeText(String)}.
     */
    public Text replaceWholeText(String s) throws DOMException {
        for (Node n = getPreviousLogicallyAdjacentTextNode(this);
                n != null;
                n = getPreviousLogicallyAdjacentTextNode(n)) {
            AbstractNode an = (AbstractNode) n;
            if (an.isReadonly()) {
                throw createDOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                     "readonly.node",
                     new Object[] { new Integer(n.getNodeType()),
                                    n.getNodeName() });
            }
        }
        for (Node n = getNextLogicallyAdjacentTextNode(this);
                n != null;
                n = getNextLogicallyAdjacentTextNode(n)) {
            AbstractNode an = (AbstractNode) n;
            if (an.isReadonly()) {
                throw createDOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                     "readonly.node",
                     new Object[] { new Integer(n.getNodeType()),
                                    n.getNodeName() });
            }
        }
        Node parent = getParentNode();
        for (Node n = getPreviousLogicallyAdjacentTextNode(this);
                n != null;
                n = getPreviousLogicallyAdjacentTextNode(n)) {
            parent.removeChild(n);
        }
        for (Node n = getNextLogicallyAdjacentTextNode(this);
                n != null;
                n = getNextLogicallyAdjacentTextNode(n)) {
            parent.removeChild(n);
        }
        if (isReadonly()) {
            Text t = createTextNode(s);
            parent.replaceChild(t, this);
            return t;
        }
        setNodeValue(s);
        return this;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getTextContent()}.
     */
    public String getTextContent() {
        if (isElementContentWhitespace()) {
            return "";
        }
        return getNodeValue();
    }

    /**
     * Creates a text node of the current type.
     */
    protected abstract Text createTextNode(String text);
}
