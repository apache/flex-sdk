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

import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Bridge class for creating, building, and updating a <tt>GraphicsNode</tt>
 * according to an <tt>Element</tt>.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: GraphicsNodeBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface GraphicsNodeBridge extends Bridge {

    /**
     * Creates a <tt>GraphicsNode</tt> according to the specified parameters.
     * This is called before children have been added to the
     * returned GraphicsNode (obviously since you construct and return it).
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @return a graphics node that represents the specified element
     */
    GraphicsNode createGraphicsNode(BridgeContext ctx, Element e);

    /**
     * Builds using the specified BridgeContext and element, the
     * specified graphics node.  This is called after all the children
     * of the node have been constructed and added, so it is safe to
     * do work that depends on being able to see your children nodes
     * in this method.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @param node the graphics node to build
     */
    void buildGraphicsNode(BridgeContext ctx, Element e, GraphicsNode node);

    /**
     * Returns true if the bridge handles container element, false
     * otherwise.
     */
    boolean isComposite();

    /**
     * Returns true if the graphics node has to be displayed, false
     * otherwise.
     */
    boolean getDisplay(Element e);

    /**
     * Returns the Bridge instance to be used for a single DOM 
     * element. For example, a static Bridge (i.e., a Bridge for
     * static SVG content) will always return the same instance.
     * A dynamic Bridge will return a new instance on each call.
     *
     * <!> FIX ME: Move to Bridge 
     */
    Bridge getInstance();

}
