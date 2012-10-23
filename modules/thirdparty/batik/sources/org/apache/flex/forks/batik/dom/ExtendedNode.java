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

import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.w3c.dom.Document;
import org.w3c.dom.Node;

/**
 * This interface provides an access to the non DOM methods implemented by
 * all the nodes in this implementation.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ExtendedNode.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface ExtendedNode extends Node, NodeEventTarget {

    /**
     * Sets the name of this node.
     */
    void setNodeName(String v);

    /**
     * Tests whether this node is readonly.
     */
    boolean isReadonly();

    /**
     * Sets this node readonly attribute.
     */
    void setReadonly(boolean v);

    /**
     * Sets the owner document of this node.
     */
    void setOwnerDocument(Document doc);

    /**
     * Sets the parent node.
     */
    void setParentNode(Node v);

    /**
     * Sets the node immediately preceding this node.
     */
    void setPreviousSibling(Node n);

    /**
     * Sets the node immediately following this node.
     */
    void setNextSibling(Node n);

    /**
     * Sets the value of the specified attribute. This method only applies
     * to Attr objects.
     */
    void setSpecified(boolean v);
}
