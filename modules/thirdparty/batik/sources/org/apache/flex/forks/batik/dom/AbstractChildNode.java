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

import org.w3c.dom.Node;

/**
 * This class implements the {@link org.w3c.dom.Node} interface with support
 * for parent and siblings.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractChildNode.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class AbstractChildNode extends AbstractNode {
    /**
     * The parent node of this node.
     */
    protected Node parentNode;

    /**
     * The previous sibling.
     */
    protected Node previousSibling;

    /**
     * Returns the next sibling.
     */
    protected Node nextSibling;

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getParentNode()}.
     * @return {@link #parentNode}
     */
    public Node getParentNode() {
        return parentNode;
    }

    /**
     * Sets the parent node.
     */
    public void setParentNode(Node v) {
        parentNode = v;
    }

    /**
     * Sets the node immediately preceding this node.
     */
    public void setPreviousSibling(Node v) {
        previousSibling = v;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getPreviousSibling()}.
     * @return {@link #previousSibling}.
     */
    public Node getPreviousSibling() {
        return previousSibling;
    }

    /**
     * Sets the node immediately following this node.
     */
    public void setNextSibling(Node v) {
        nextSibling = v;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNextSibling()}.
     * @return {@link #nextSibling}.
     */
    public Node getNextSibling() {
        return nextSibling;
    }
}
