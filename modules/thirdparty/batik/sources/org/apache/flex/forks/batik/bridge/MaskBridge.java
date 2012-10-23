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
import org.apache.flex.forks.batik.gvt.filter.Mask;
import org.w3c.dom.Element;

/**
 * Factory class for vending <tt>Mask</tt> objects.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: MaskBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface MaskBridge extends Bridge {

    /**
     * Creates a <tt>Mask</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param maskElement the element that defines the mask
     * @param maskedElement the element that references the mask element
     * @param maskedNode the graphics node to mask
     */
    Mask createMask(BridgeContext ctx,
                    Element maskElement,
                    Element maskedElement,
                    GraphicsNode maskedNode);

}
