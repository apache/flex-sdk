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

import org.w3c.dom.views.AbstractView;
import org.w3c.dom.smil.TimeEvent;

/**
 * An event class for SMIL timing events.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DOMTimeEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class DOMTimeEvent extends AbstractEvent implements TimeEvent {

    /**
     * The view from which the event was generated.
     */
    protected AbstractView view;

    /**
     * For repeat events this is the repeat iteration.  Unused for the
     * other time events.
     */
    protected int detail;

    /**
     * Returns the view from which the event was generated.
     */
    public AbstractView getView() {
        return view;
    }

    /**
     * Returns the repeat iteration if this is a repeat event.
     */
    public int getDetail() {
        return detail;
    }

    /**
     * Initializes the values of the TimeEvent object.
     */
    public void initTimeEvent(String typeArg,
                              AbstractView viewArg,
                              int detailArg) {
        initEvent(typeArg, false, false);
        this.view = viewArg;
        this.detail = detailArg;
    }

    /**
     * Initializes the values of the TimeEvent object.
     */
    public void initTimeEventNS(String namespaceURIArg,
                                String typeArg,
                                AbstractView viewArg,
                                int detailArg) {
        initEventNS(namespaceURIArg, typeArg, false, false);
        this.view = viewArg;
        this.detail = detailArg;
    }

    /**
     * Sets the timestamp of this time event.  This is required for
     * synchronization of time events in the SMIL timing model.
     */
    public void setTimestamp(long timeStamp) {
        this.timeStamp = timeStamp;
    }
}
