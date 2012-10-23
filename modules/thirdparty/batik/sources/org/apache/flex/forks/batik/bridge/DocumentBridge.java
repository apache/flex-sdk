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
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.gvt.RootGraphicsNode;

import org.w3c.dom.Document;

/**
 * Interface for bridge classes that operate on Document nodes.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DocumentBridge.java 582434 2007-10-06 02:11:51Z cam $
 */
public interface DocumentBridge extends Bridge {

    /**
     * Creates a <tt>GraphicsNode</tt> according to the specified parameters.
     * This is called before children have been added to the
     * returned GraphicsNode (obviously since you construct and return it).
     *
     * @param ctx the bridge context to use
     * @param doc the document node that describes the graphics node to build
     * @return a graphics node that represents the specified document node
     */
    RootGraphicsNode createGraphicsNode(BridgeContext ctx, Document doc);

    /**
     * Builds using the specified BridgeContext and element, the
     * specified graphics node.  This is called after all the children
     * of the node have been constructed and added, so it is safe to
     * do work that depends on being able to see your children nodes
     * in this method.
     *
     * @param ctx the bridge context to use
     * @param doc the document node that describes the graphics node to build
     * @param node the graphics node to build
     */
    void buildGraphicsNode(BridgeContext ctx, Document doc, RootGraphicsNode node);
}
