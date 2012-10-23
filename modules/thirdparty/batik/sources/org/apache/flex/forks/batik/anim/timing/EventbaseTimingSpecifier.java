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
package org.apache.flex.forks.batik.anim.timing;

import org.apache.flex.forks.batik.dom.events.NodeEventTarget;

import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;

/**
 * A class to handle eventbase SMIL timing specifiers.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: EventbaseTimingSpecifier.java 580338 2007-09-28 13:13:46Z cam $
 */
public class EventbaseTimingSpecifier
        extends EventLikeTimingSpecifier
        implements EventListener {

    /**
     * The ID of the eventbase element.
     */
    protected String eventbaseID;

    /**
     * The eventbase element.
     */
    protected TimedElement eventbase;

    /**
     * The eventbase element as an {@link EventTarget}.
     */
    protected EventTarget eventTarget;

    /**
     * The namespace URI of the event to sync to.
     */
    protected String eventNamespaceURI;

    /**
     * The type of the event to sync to.
     */
    protected String eventType;

    /**
     * The animation name of the event to sync to.
     */
    protected String eventName;

    /**
     * Creates a new EventbaseTimingSpecifier object.
     */
    public EventbaseTimingSpecifier(TimedElement owner, boolean isBegin,
                                    float offset, String eventbaseID,
                                    String eventName) {
        super(owner, isBegin, offset);
        this.eventbaseID = eventbaseID;
        this.eventName = eventName;
        TimedDocumentRoot root = owner.getRoot();
        this.eventNamespaceURI = root.getEventNamespaceURI(eventName);
        this.eventType = root.getEventType(eventName);
        if (eventbaseID == null) {
            this.eventTarget = owner.getAnimationEventTarget();
        } else {
            this.eventTarget = owner.getEventTargetById(eventbaseID);
        }
    }

    /**
     * Returns a string representation of this timing specifier.
     */
    public String toString() {
        return (eventbaseID == null ? "" : eventbaseID + ".") + eventName
            + (offset != 0 ? super.toString() : "");
    }

    /**
     * Initializes this timing specifier by adding the initial instance time
     * to the owner's instance time list or setting up any event listeners.
     */
    public void initialize() {
        ((NodeEventTarget) eventTarget).addEventListenerNS
            (eventNamespaceURI, eventType, this, false, null);
    }

    /**
     * Deinitializes this timing specifier by removing any event listeners.
     */
    public void deinitialize() {
        ((NodeEventTarget) eventTarget).removeEventListenerNS
            (eventNamespaceURI, eventType, this, false);
    }

    // EventListener /////////////////////////////////////////////////////////

    /**
     * Handles an event fired on the eventbase element.
     */
    public void handleEvent(Event e) {
        owner.eventOccurred(this, e);
    }

    /**
     * Invoked to resolve an event-like timing specifier into an instance time.
     */
    public void resolve(Event e) {
        float time = owner.getRoot().convertEpochTime(e.getTimeStamp());
        InstanceTime instance = new InstanceTime(this, time + offset, true);
        owner.addInstanceTime(instance, isBegin);
    }
}
