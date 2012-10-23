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

import org.w3c.dom.events.TextEvent;
import org.w3c.dom.views.AbstractView;

/**
 * Class to implement DOM 3 Text events.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DOMTextEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class DOMTextEvent extends DOMUIEvent implements TextEvent {

    /**
     * The text data.
     */
    protected String data;

    /**
     * Returns the text data.
     */
    public String getData() {
        return data;
    }

    /**
     * <b>DOM</b>: Initializes this TextEvent.
     */
    public void initTextEvent(String typeArg, 
                              boolean canBubbleArg, 
                              boolean cancelableArg, 
                              AbstractView viewArg, 
                              String dataArg) {
        initUIEvent(typeArg, canBubbleArg, cancelableArg, viewArg, 0);
        data = dataArg;
    }

    /**
     * <b>DOM</b>: Initializes this TextEvent.
     */
    public void initTextEventNS(String namespaceURIArg,
                                String typeArg, 
                                boolean canBubbleArg, 
                                boolean cancelableArg, 
                                AbstractView viewArg, 
                                String dataArg) {
        initUIEventNS(namespaceURIArg,
                      typeArg,
                      canBubbleArg,
                      cancelableArg,
                      viewArg,
                      0);
        data = dataArg;
    }
}
