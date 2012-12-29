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

import java.awt.geom.Rectangle2D;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Factory class for vending <tt>Filter</tt> objects that represents
 * a filter primitive.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: FilterPrimitiveBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface FilterPrimitiveBridge extends Bridge {

    /**
     * Creates a <tt>Filter</tt> primitive according to the specified
     * parameters.
     *
     * @param ctx the bridge context to use
     * @param filterElement the element that defines a filter
     * @param filteredElement the element that references the filter
     * @param filteredNode the graphics node to filter
     *
     * @param in the <tt>Filter</tt> that represents the current
     *        filter input if the filter chain.
     * @param filterRegion the filter area defined for the filter chain
     *        the new node will be part of.
     * @param filterMap a map where the mediator can map a name to the
     *        <tt>Filter</tt> it creates. Other <tt>FilterBridge</tt>s
     *        can then access a filter node from the filterMap if they
     *        know its name.
     */
    Filter createFilter(BridgeContext ctx,
                        Element filterElement,
                        Element filteredElement,
                        GraphicsNode filteredNode,
                        Filter in,
                        Rectangle2D filterRegion,
                        Map filterMap);

}
