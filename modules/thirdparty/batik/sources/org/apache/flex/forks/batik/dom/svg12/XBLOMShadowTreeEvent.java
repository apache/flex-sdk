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
package org.apache.flex.forks.batik.dom.svg12;

import org.apache.flex.forks.batik.dom.events.AbstractEvent;
import org.apache.flex.forks.batik.dom.xbl.ShadowTreeEvent;
import org.apache.flex.forks.batik.dom.xbl.XBLShadowTreeElement;

/**
 * This class implements the {@link ShadowTreeEvent} event class.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: XBLOMShadowTreeEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class XBLOMShadowTreeEvent extends AbstractEvent
                                  implements ShadowTreeEvent {
    
    /**
     * The shadow tree that is the object of this event.
     */
    protected XBLShadowTreeElement xblShadowTree;

    /**
     * Returns the shadow tree that is the object of this event.
     */
    public XBLShadowTreeElement getXblShadowTree() {
        return xblShadowTree;
    }

    /**
     * Initializes this event object.
     */
    public void initShadowTreeEvent(String typeArg,
                                    boolean canBubbleArg,
                                    boolean cancelableArg,
                                    XBLShadowTreeElement xblShadowTreeArg) {
        initEvent(typeArg, canBubbleArg, cancelableArg);
        xblShadowTree = xblShadowTreeArg;
    }

    /**
     * Initializes this event object with a namespaced event type.
     */
    public void initShadowTreeEventNS(String namespaceURIArg,
                                      String typeArg,
                                      boolean canBubbleArg,
                                      boolean cancelableArg,
                                      XBLShadowTreeElement xblShadowTreeArg) {
        initEventNS(namespaceURIArg, typeArg, canBubbleArg, cancelableArg);
        xblShadowTree = xblShadowTreeArg;
    }
}
