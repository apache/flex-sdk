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
package org.apache.flex.forks.batik.dom.xbl;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * An interface for classes that can manage XBL functionality for a
 * document's nodes.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: XBLManager.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface XBLManager {

    /**
     * Starts XBL processing on the document.
     */
    void startProcessing();

    /**
     * Stops XBL processing on the document.
     */
    void stopProcessing();

    /**
     * Returns whether XBL processing is currently enabled.
     */
    boolean isProcessing();

    /**
     * Get the parent of a node in the fully flattened tree.
     */
    Node getXblParentNode(Node n);

    /**
     * Get the list of child nodes of a node in the fully flattened tree.
     */
    NodeList getXblChildNodes(Node n);

    /**
     * Get the list of child nodes of a node in the fully flattened tree
     * that are within the same shadow scope.
     */
    NodeList getXblScopedChildNodes(Node n);

    /**
     * Get the first child node of a node in the fully flattened tree.
     */
    Node getXblFirstChild(Node n);

    /**
     * Get the last child node of a node in the fully flattened tree.
     */
    Node getXblLastChild(Node n);

    /**
     * Get the node which directly precedes a node in the xblParentNode's
     * xblChildNodes list.
     */
    Node getXblPreviousSibling(Node n);

    /**
     * Get the node which directly follows a node in thexblParentNode's
     * xblChildNodes list.
     */
    Node getXblNextSibling(Node n);

    /**
     * Get the first element child of a node in the fully flattened tree.
     */
    Element getXblFirstElementChild(Node n);

    /**
     * Get the last element child of a node in the fully flattened tree.
     */
    Element getXblLastElementChild(Node n);

    /**
     * Get the first element that precedes the a node in the
     * xblParentNode's xblChildNodes list.
     */
    Element getXblPreviousElementSibling(Node n);

    /**
     * Get the first element that follows a node in the
     * xblParentNode's xblChildNodes list.
     */
    Element getXblNextElementSibling(Node n);

    /**
     * Get the bound element whose shadow tree a node resides in.
     */
    Element getXblBoundElement(Node n);

    /**
     * Get the shadow tree of a node.
     */
    Element getXblShadowTree(Node n);

    /**
     * Get the xbl:definition elements currently binding an element.
     */
    NodeList getXblDefinitions(Node n);
}
