/*

   Copyright 2000-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Bridge class for vending <tt>Filter</tt> objects.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: FilterBridge.java,v 1.10 2004/08/18 07:12:31 vhardy Exp $
 */
public interface FilterBridge extends Bridge {

    /**
     * Creates a <tt>Filter</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param filterElement the element that defines the filter
     * @param filteredElement the element that references the filter element
     * @param filteredNode the graphics node to filter
     */
    Filter createFilter(BridgeContext ctx,
                        Element filterElement,
                        Element filteredElement,
                        GraphicsNode filteredNode);

}
