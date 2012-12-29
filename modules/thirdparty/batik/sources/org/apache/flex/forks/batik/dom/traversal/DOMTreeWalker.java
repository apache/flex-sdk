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

import org.apache.flex.forks.batik.dom.AbstractNode;
import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.traversal.NodeFilter;
import org.w3c.dom.traversal.TreeWalker;

/**
 * This class implements the {@link org.w3c.dom.traversal.NodeIterator}
 * interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DOMTreeWalker.java 475477 2006-11-15 22:44:28Z cam $
 */
public class DOMTreeWalker implements TreeWalker {

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
     * The current node.
     */
    protected Node currentNode;

    /**
     * Creates a new TreeWalker object.
     * @param n The root node.
     * @param what Which node types are presented via the iterator.
     * @param nf The NodeFilter used to screen nodes.
     * @param exp Whether the children of entity reference nodes are visible
     *            to the tree walker.
     */
    public DOMTreeWalker(Node n, int what, NodeFilter nf, boolean exp) {
        root = n;
        whatToShow = what;
        filter = nf;
        expandEntityReferences = exp;

        currentNode = root;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#getRoot()}.
     */
    public Node getRoot() {
        return root;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#getWhatToShow()}.
     */
    public int getWhatToShow() {
        return whatToShow;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#getFilter()}.
     */
    public NodeFilter getFilter() {
        return filter;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#getExpandEntityReferences()}.
     */
    public boolean getExpandEntityReferences() {
        return expandEntityReferences;
    }
    
    /**
     * <b>DOM</b>: Implements {@link TreeWalker#getCurrentNode()}.
     */
    public Node getCurrentNode() {
        return currentNode;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#setCurrentNode(Node)}.
     */
    public void setCurrentNode(Node n) {
        if (n == null) {
            throw ((AbstractNode)root).createDOMException
                (DOMException.NOT_SUPPORTED_ERR,
                 "null.current.node",  null);
        }
        currentNode = n;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#parentNode()}.
     */
    public Node parentNode() {
        Node result = parentNode(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#firstChild()}.
     */
    public Node firstChild() {
        Node result = firstChild(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#lastChild()}.
     */
    public Node lastChild() {
        Node result = lastChild(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#previousSibling()}.
     */
    public Node previousSibling() {
        Node result = previousSibling(currentNode, root);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#nextSibling()}.
     */
    public Node nextSibling() {
        Node result = nextSibling(currentNode, root);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#previousNode()}.
     */
    public Node previousNode() {
        Node result = previousSibling(currentNode, root);
        if (result == null) {
            result = parentNode(currentNode);
            if (result != null) {
                currentNode = result;
            }
            return result;
        }
        Node n = lastChild(result);
        Node last = n;
        while (n != null) {
            last = n;
            n = lastChild(last);
        }
        return currentNode = (last != null) ? last : result;
    }

    /**
     * <b>DOM</b>: Implements {@link TreeWalker#nextNode()}.
     */
    public Node nextNode() {
        Node result;
        if ((result = firstChild(currentNode)) != null) {
            return currentNode = result;
        }
        if ((result = nextSibling(currentNode, root)) != null) {
            return currentNode = result;
        }
        Node parent = currentNode;
        for (;;) {
            parent = parentNode(parent);
            if (parent == null) {
                return null;
            }
            if ((result = nextSibling(parent, root)) != null) {
                return currentNode = result;
            }
        }
    }

    /**
     * Returns the parent node of the given node.
     */
    protected Node parentNode(Node n) {
        if (n == root) {
            return null;
        }
        Node result = n;
        for (;;) {
            result = result.getParentNode();
            if (result == null) {
                return null;
            }
            if ((whatToShow & (1 << result.getNodeType() - 1)) != 0) {
                if (filter == null ||
                    filter.acceptNode(result) == NodeFilter.FILTER_ACCEPT) {
                    return result;
                }
            }
        }
    }

    /**
     * Returns the first child of the given node.
     */
    protected Node firstChild(Node n) {
        if (n.getNodeType() == Node.ENTITY_REFERENCE_NODE &&
            !expandEntityReferences) {
            return null;
        }
        Node result = n.getFirstChild();
        if (result == null) {
            return null;
        }
        switch (acceptNode(result)) {
        case NodeFilter.FILTER_ACCEPT:
            return result;
        case NodeFilter.FILTER_SKIP:
            Node t = firstChild(result);
            if (t != null) {
                return t;
            }
            // Fall through
        default: // NodeFilter.FILTER_REJECT
            return nextSibling(result, n);
        }
    }

    /**
     * Returns the last child of the given node.
     */
    protected Node lastChild(Node n) {
        if (n.getNodeType() == Node.ENTITY_REFERENCE_NODE &&
            !expandEntityReferences) {
            return null;
        }
        Node result = n.getLastChild();
        if (result == null) {
            return null;
        }
        switch (acceptNode(result)) {
        case NodeFilter.FILTER_ACCEPT:
            return result;
        case NodeFilter.FILTER_SKIP:
            Node t = lastChild(result);
            if (t != null) {
                return t;
            }
            // Fall through
        default: // NodeFilter.FILTER_REJECT
            return previousSibling(result, n);
        }
    }

    /**
     * Returns the previous sibling of the given node.
     */
    protected Node previousSibling(Node n, Node root) {
        while (true) {
            if (n == root) {
                return null;
            }
            Node result = n.getPreviousSibling();
            if (result == null) {
                result = n.getParentNode();
                if (result == null || result == root) {
                    return null;
                }
                if (acceptNode(result) == NodeFilter.FILTER_SKIP) {
                    n = result;
                    continue;
                }
                return null;
            }
            switch (acceptNode(result)) {
            case NodeFilter.FILTER_ACCEPT:
                return result;
            case NodeFilter.FILTER_SKIP:
                Node t = lastChild(result);
                if (t != null) {
                    return t;
                }
                // Fall through
            default: // NodeFilter.FILTER_REJECT
                n = result;
                continue;
            }
        }
    }

    /**
     * Returns the next sibling of the given node.
     */
    protected Node nextSibling(Node n, Node root) {
        while (true) {
            if (n == root) {
                return null;
            }
            Node result = n.getNextSibling();
            if (result == null) {
                result = n.getParentNode();
                if (result == null || result == root) {
                    return null;
                }
                if (acceptNode(result) == NodeFilter.FILTER_SKIP) {
                    n = result;
                    continue;
                }
                return null;
            }

            switch (acceptNode(result)) {
            case NodeFilter.FILTER_ACCEPT:
                return result;
            case NodeFilter.FILTER_SKIP:
                Node t = firstChild(result);
                if (t != null) {
                    return t;
                }
                // Fall through
            default: // NodeFilter.FILTER_REJECT
                n = result;
                continue;
            }
        }
    }

    /**
     * Whether or not the given node is accepted by this tree walker.
     */
    protected short acceptNode(Node n) {
        if ((whatToShow & (1 << n.getNodeType() - 1)) != 0) {
            if (filter == null) {
                return NodeFilter.FILTER_ACCEPT;
            } else {
                return filter.acceptNode(n);
            }
        } else {
            return NodeFilter.FILTER_SKIP;
        }
    }
}
