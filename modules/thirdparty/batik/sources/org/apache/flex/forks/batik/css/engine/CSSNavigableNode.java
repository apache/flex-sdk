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
package org.apache.flex.forks.batik.css.engine;

import org.w3c.dom.Node;

/**
 * An interface for DOM classes that can be navigated for CSS selector
 * matching and cascade computation.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: CSSNavigableNode.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface CSSNavigableNode {

    /**
     * Returns the CSS parent node of this node.
     */
    Node getCSSParentNode();

    /**
     * Returns the CSS previous sibling node of this node.
     */
    Node getCSSPreviousSibling();

    /**
     * Returns the CSS next sibling node of this node.
     */
    Node getCSSNextSibling();

    /**
     * Returns the CSS first child node of this node.
     */
    Node getCSSFirstChild();

    /**
     * Returns the CSS last child of this node.
     */
    Node getCSSLastChild();

    /**
     * Returns whether this node is the root of a (conceptual) hidden tree
     * that selectors will not work across.
     */
    boolean isHiddenFromSelectors();
}
