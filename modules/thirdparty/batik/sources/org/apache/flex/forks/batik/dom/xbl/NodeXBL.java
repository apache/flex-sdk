/*
 * Copyright (c) 2005 World Wide Web Consortium,
 *
 * (Massachusetts Institute of Technology, European Research Consortium for
 * Informatics and Mathematics, Keio University). All Rights Reserved. This
 * work is distributed under the W3C(r) Software License [1] in the hope that
 * it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * [1] http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
 *
 * Modifications:
 *
 * September 10, 2005
 *   Placed interface in org.apache.flex.forks.batik.dom.xbl for the time being.
 *   Added javadocs.
 */
package org.apache.flex.forks.batik.dom.xbl;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * Interface implemented by all nodes that support XBL.
 * Eventually will move to org.w3c.dom.xbl (or some such package).
 *
 * @version $Id: NodeXBL.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public interface NodeXBL {

    /**
     * Get the parent of this node in the fully flattened tree.
     */
    Node getXblParentNode();

    /**
     * Get the list of child nodes of this node in the fully flattened tree.
     */
    NodeList getXblChildNodes();

    /**
     * Get the list of child nodes of this node in the fully flattened tree
     * that are within the same shadow scope.
     */
    NodeList getXblScopedChildNodes();

    /**
     * Get the first child node of this node in the fully flattened tree.
     */
    Node getXblFirstChild();

    /**
     * Get the last child node of this node in the fully flattened tree.
     */
    Node getXblLastChild();

    /**
     * Get the node which directly precedes the current node in the
     * xblParentNode's xblChildNodes list.
     */
    Node getXblPreviousSibling();

    /**
     * Get the node which directly follows the current node in the
     * xblParentNode's xblChildNodes list.
     */
    Node getXblNextSibling();

    /**
     * Get the first element child of this node in the fully flattened tree.
     */
    Element getXblFirstElementChild();

    /**
     * Get the last element child of this node in the fully flattened tree.
     */
    Element getXblLastElementChild();

    /**
     * Get the first element that precedes the current node in the
     * xblParentNode's xblChildNodes list.
     */
    Element getXblPreviousElementSibling();

    /**
     * Get the first element that follows the current node in the
     * xblParentNode's xblChildNodes list.
     */
    Element getXblNextElementSibling();

    /**
     * Get the bound element whose shadow tree this current node resides in.
     */
    Element getXblBoundElement();

    /**
     * Get the shadow tree of this node.
     */
    Element getXblShadowTree();

    /**
     * Get the xbl:definition elements currently binding this element.
     */
    NodeList getXblDefinitions();
}
