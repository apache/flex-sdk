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
package org.apache.flex.forks.batik.dom.events;

import org.w3c.dom.events.CustomEvent;

/**
 * A custom event object.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DOMCustomEvent.java 478769 2006-11-24 04:50:12Z cam $
 */
public class DOMCustomEvent extends DOMEvent implements CustomEvent {

    /**
     * The custom detail associated with this event.
     */
    protected Object detail;

    /**
     * Returns the custom detail of this event.
     */
    public Object getDetail() {
        return detail;
    }

    /**
     * Initializes this custom event.
     */
    public void initCustomEventNS(String namespaceURIArg,
                                  String typeArg,
                                  boolean canBubbleArg,
                                  boolean cancelableArg,
                                  Object detailArg) {
        initEventNS(namespaceURIArg, typeArg, canBubbleArg, cancelableArg);
        detail = detailArg;
    }
}
