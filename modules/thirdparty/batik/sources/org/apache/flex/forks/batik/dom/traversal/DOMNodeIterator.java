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
package org.apache.flex.forks.batik.dom.traversal;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.traversal.NodeFilter;
import org.w3c.dom.traversal.NodeIterator;

/**
 * This class implements the {@link org.w3c.dom.traversal.NodeIterator}
 * interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DOMNodeIterator.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public class DOMNodeIterator implements NodeIterator {

    /**
     * The initial state.
     */
    protected static final short INITIAL = 0;

    /**
     * The invalid state.
     */
    protected static final short INVALID = 1;

    /**
     * The forward state.
     */
    protected static final short FORWARD = 2;

    /**
     * The backward state.
     */
    protected static final short BACKWARD = 3;

    /**
     * The document which created the iterator.
     */
    protected AbstractDocument document;

    /**
     * The root node.
     */
    protected Node root;

    /**
     * Which node types are presented via the iterator.
     */
    protected int whatToShow;

    /**
     * The NodeFilter used to screen nodes.
     */
    protected NodeFilter filter;

    /**
     * Whether the children of entity reference nodes are visible
     * to the iterator.
     */
    protected boolean expandEntityReferences;

    /**
     * The iterator state.
     */
    protected short state;

    /**
     * The reference node.
     */
    protected Node referenceNode;

    /**
     * Creates a new NodeIterator object.
     * @param doc The document which created the tree walker.
     * @param n The root node.
     * @param what Which node types are presented via the iterator.
     * @param nf The NodeFilter used to screen nodes.
     * @param exp Whether the children of entity reference nodes are visible
     *            to the iterator.
     */
    public DOMNodeIterator(AbstractDocument doc, Node n, int what,
                           NodeFilter nf, boolean exp) {
        document = doc;
        root = n;
        whatToShow = what;
        filter = nf;
        expandEntityReferences = exp;

        referenceNode = root;
    }

    /**
     * <b>DOM</b>: Implements {@link NodeIterator#getRoot()}.
     */
    public Node getRoot() {
        return root;
    }

    /**
     * <b>DOM</b>: Implements {@link NodeIterator#getWhatToShow()}.
     */
    public int getWhatToShow() {
        return whatToShow;
    }

    /**
     * <b>DOM</b>: Implements {@link NodeIterator#getFilter()}.
     */
    public NodeFilter getFilter() {
        return filter;
    }

    /**
     * <b>DOM</b>: Implements {@link NodeIterator#getExpandEntityReferences()}.
     */
    public boolean getExpandEntityReferences() {
        return expandEntityReferences;
    }

    /**
     * <b>DOM</b>: Implements {@link NodeIterator#nextNode()}.
     */
    public Node nextNode() {
        switch (state) {
        case INVALID:
            throw document.createDOMException
                (DOMException.INVALID_STATE_ERR,
                 "detached.iterator",  null);
        case BACKWARD:
        case INITIAL:
            state = FORWARD;
            return referenceNode;
        case FORWARD:
        }

        for (;;) {
            unfilteredNextNode();
            if (referenceNode == null) {
                return null;
            }
            if ((whatToShow & (1 << referenceNode.getNodeType() - 1)) != 0) {
                if (filter == null ||
                    filter.acceptNode(referenceNode) == NodeFilter.FILTER_ACCEPT) {
                    return referenceNode;
                }
            }
        }
    }

    /**
     * <b>DOM</b>: Implements {@link NodeIterator#previousNode()}.
     */
    public Node previousNode() {
        switch (state) {
        case INVALID:
            throw document.createDOMException
                (DOMException.INVALID_STATE_ERR,
                 "detached.iterator",  null);
        case FORWARD:
        case INITIAL:
            state = BACKWARD;
            return referenceNode;
        case BACKWARD:
        }

        for (;;) {
            unfilteredPreviousNode();
            if (referenceNode == null) {
                return referenceNode;
            }
            if ((whatToShow & (1 << referenceNode.getNodeType() - 1)) != 0) {
                if (filter == null ||
                    filter.acceptNode(referenceNode) == NodeFilter.FILTER_ACCEPT) {
                    return referenceNode;
                }
            }
        }
    }

    /**
     * <b>DOM</b>: Implements {@link NodeIterator#detach()}.
     */
    public void detach() {
        state = INVALID;
        document.detachNodeIterator(this);
    }

    /**
     * Called by the DOM when a node will be removed from the current document.
     */
    public void nodeToBeRemoved(Node removedNode) {
        if (state == INVALID) {
            return;
        }

        Node node;
        for (node = referenceNode;
             node != null && node != root;
             node = node.getParentNode()) {
            if (node == removedNode) {
                break;
            }
        }
        if (node == null || node == root) {
            return;
        }

        if (state == BACKWARD) {
            // Go to the first child
            if (node.getNodeType() != Node.ENTITY_REFERENCE_NODE ||
                expandEntityReferences) {
                Node n = node.getFirstChild();
                if (n != null) {
                    referenceNode = n;
                    return;
                }
            }

            // Go to the next sibling
            Node n = node.getNextSibling();
            if (n != null) {
                referenceNode = n;
                return;
            }

            // Go to the first sibling of one of the ancestors
            n = node;
            while ((n = n.getParentNode()) != null && n != root) {
                Node t = n.getNextSibling();
                if (t != null) {
                    referenceNode = t;
                    return;
                }
            }

            referenceNode = null;
        } else {
            Node n = node.getPreviousSibling();

            // Go to the parent of a first child
            if (n == null) {
                referenceNode = node.getParentNode();
                return;
            }

            // Go to the last child of child...
            if (n.getNodeType() != Node.ENTITY_REFERENCE_NODE ||
                expandEntityReferences) {
                Node t;
                while ((t = n.getLastChild()) != null) {
                    n = t;
                }
            }

            referenceNode = n;
        }
    }

    /**
     * Sets the reference node to the next node, unfiltered.
     */
    protected void unfilteredNextNode() {
        if (referenceNode == null) {
            return;
        }

        // Go to the first child
        if (referenceNode.getNodeType() != Node.ENTITY_REFERENCE_NODE ||
            expandEntityReferences) {
            Node n = referenceNode.getFirstChild();
            if (n != null) {
                referenceNode = n;
                return;
            }
        }

        // Go to the next sibling
        Node n = referenceNode.getNextSibling();
        if (n != null) {
            referenceNode = n;
            return;
        }

        // Go to the first sibling of one of the ancestors
        n = referenceNode;
        while ((n = n.getParentNode()) != null && n != root) {
            Node t = n.getNextSibling();
            if (t != null) {
                referenceNode = t;
                return;
            }
        }
        referenceNode = null;
    }

    /**
     * Sets the reference node to the previous node, unfiltered.
     */
    protected void unfilteredPreviousNode() {
        if (referenceNode == null) {
            return;
        }

        // The previous of root is null
        if (referenceNode == root) {
            referenceNode = null;
            return;
        }

        Node n = referenceNode.getPreviousSibling();

        // Go to the parent of a first child
        if (n == null) {
            referenceNode = referenceNode.getParentNode();
            return;
        }

        // Go to the last child of child...
        if (n.getNodeType() != Node.ENTITY_REFERENCE_NODE ||
            expandEntityReferences) {
            Node t;
            while ((t = n.getLastChild()) != null) {
                n = t;
            }
        }

        referenceNode = n;
    }
}
