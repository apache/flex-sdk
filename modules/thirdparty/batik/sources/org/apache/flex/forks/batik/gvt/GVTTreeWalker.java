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
package org.apache.flex.forks.batik.gvt;

import java.util.List;

/**
 * <tt>GVTTreeWalker</tt> objects are used to navigate a GVT tree or subtree.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: GVTTreeWalker.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GVTTreeWalker {

    /** The GVT root into which text is searched. */
    protected GraphicsNode gvtRoot;

    /** The root of the subtree of the GVT which is traversed. */
    protected GraphicsNode treeRoot;

    /** The current GraphicsNode. */
    protected GraphicsNode currentNode;

    /**
     * Constructs a new <tt>GVTTreeWalker</tt>.
     *
     * @param treeRoot the top of the graphics node tree to search
     */
    public GVTTreeWalker(GraphicsNode treeRoot) {
        this.gvtRoot     = treeRoot.getRoot();
        this.treeRoot    = treeRoot;
        this.currentNode = treeRoot;
    }

    /**
     * Returns the root graphics node.
     */
    public GraphicsNode getRoot() {
        return treeRoot;
    }

    /**
     * Returns the GVT root graphics node.
     */
    public GraphicsNode getGVTRoot() {
        return gvtRoot;
    }

    /**
     * Sets the current GraphicsNode to the specified node.
     *
     * @param node the new current graphics node
     * @exception IllegalArgumentException if the node is not part of
     * the GVT Tree this walker is dedicated to
     */
    public void setCurrentGraphicsNode(GraphicsNode node) {
        if (node.getRoot() != gvtRoot) {
            throw new IllegalArgumentException
                ("The node "+node+" is not part of the document "+gvtRoot);
        }
        currentNode = node;
    }

    /**
     * Returns the current <tt>GraphicsNode</tt>.
     */
    public GraphicsNode getCurrentGraphicsNode() {
        return currentNode;
    }

    /**
     * Returns the previous <tt>GraphicsNode</tt>. If the current
     * graphics node does not have a previous node, returns null and
     * retains the current node.
     */
    public GraphicsNode previousGraphicsNode() {
        GraphicsNode result = getPreviousGraphicsNode(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * Returns the next <tt>GraphicsNode</tt>. If the current graphics
     * node does not have a next node, returns null and retains the
     * current node.
     */
    public GraphicsNode nextGraphicsNode() {
        GraphicsNode result = getNextGraphicsNode(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * Returns the parent of the current <tt>GraphicsNode</tt>. If the
     * current graphics node has no parent, returns null and retains
     * the current node.
     */
    public GraphicsNode parentGraphicsNode() {
        // Don't ascend above treeRoot.
        if (currentNode == treeRoot) return null;

        GraphicsNode result = currentNode.getParent();
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * Returns the next sibling of the current
     * <tt>GraphicsNode</tt>. If the current graphics node does not
     * have a next sibling, returns null and retains the current node.
     */
    public GraphicsNode getNextSibling() {
        GraphicsNode result = getNextSibling(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * Returns the next previous of the current
     * <tt>GraphicsNode</tt>. If the current graphics node does not
     * have a previous sibling, returns null and retains the current
     * node.
     */
    public GraphicsNode getPreviousSibling() {
        GraphicsNode result = getPreviousSibling(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * Returns the first child of the current
     * <tt>GraphicsNode</tt>. If the current graphics node does not
     * have a first child, returns null and retains the current node.
     */
    public GraphicsNode firstChild() {
        GraphicsNode result = getFirstChild(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    /**
     * Returns the last child of the current <tt>GraphicsNode</tt>. If
     * the current graphics node does not have a last child, returns
     * null and retains the current node.
     */
    public GraphicsNode lastChild() {
        GraphicsNode result = getLastChild(currentNode);
        if (result != null) {
            currentNode = result;
        }
        return result;
    }

    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    protected GraphicsNode getNextGraphicsNode(GraphicsNode node) {
        if (node == null) {
            return null;
        }
        // Go to the first child
        GraphicsNode n = getFirstChild(node);
        if (n != null) {
            return n;
        }

        // Go to the next sibling
        n = getNextSibling(node);
        if (n != null) {
            return n;
        }

        // Go to the first sibling of one of the ancestors
        n = node;
        while ((n = n.getParent()) != null && n != treeRoot) {
            GraphicsNode t = getNextSibling(n);
            if (t != null) {
                return t;
            }
        }
        return null;
    }

    protected GraphicsNode getPreviousGraphicsNode(GraphicsNode node) {
        if (node == null) {
            return null;
        }

        // The previous of root is null
        if (node == treeRoot) {
            return null;
        }

        GraphicsNode n = getPreviousSibling(node);

        // Go to the parent of a first child
        if (n == null) {
            return node.getParent();
        }

        // Go to the last child of child...
        GraphicsNode t;
        while ((t = getLastChild(n)) != null) {
            n = t;
        }
        return n;
    }

    protected static GraphicsNode getLastChild(GraphicsNode node) {
        if (!(node instanceof CompositeGraphicsNode)) {
            return null;
        }
        CompositeGraphicsNode parent = (CompositeGraphicsNode)node;
        List children = parent.getChildren();
        if (children == null) {
            return null;
        }
        if (children.size() >= 1) {
            return (GraphicsNode)children.get(children.size()-1);
        } else {
            return null;
        }
    }

    protected static GraphicsNode getPreviousSibling(GraphicsNode node) {
        CompositeGraphicsNode parent = node.getParent();
        if (parent == null) {
            return null;
        }
        List children = parent.getChildren();
        if (children == null) {
            return null;
        }
        int index = children.indexOf(node);
        if (index-1 >= 0) {
            return (GraphicsNode)children.get(index-1);
        } else {
            return null;
        }
    }

    protected static GraphicsNode getFirstChild(GraphicsNode node) {
        if (!(node instanceof CompositeGraphicsNode)) {
            return null;
        }
        CompositeGraphicsNode parent = (CompositeGraphicsNode)node;
        List children = parent.getChildren();
        if (children == null) {
            return null;
        }
        if (children.size() >= 1) {
            return (GraphicsNode)children.get(0);
        } else {
            return null;
        }
    }

    protected static GraphicsNode getNextSibling(GraphicsNode node) {
        CompositeGraphicsNode parent = node.getParent();
        if (parent == null) {
            return null;
        }
        List children = parent.getChildren();
        if (children == null) {
            return null;
        }
        int index = children.indexOf(node);
        if (index+1 < children.size()) {
            return (GraphicsNode)children.get(index+1);
        } else {
            return null;
        }
    }
}
