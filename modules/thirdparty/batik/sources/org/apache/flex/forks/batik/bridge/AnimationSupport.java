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

import java.util.Calendar;

import org.apache.flex.forks.batik.anim.timing.TimedElement;
import org.apache.flex.forks.batik.dom.events.DOMTimeEvent;
import org.apache.flex.forks.batik.dom.svg.IdContainer;
import org.apache.flex.forks.batik.dom.svg.SVGOMAnimationElement;
import org.apache.flex.forks.batik.dom.svg.SVGOMUseShadowRoot;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.smil.TimeEvent;

/**
 * Class that provides utilities for animation support.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimationSupport.java 579494 2007-09-26 07:40:20Z cam $
 */
public abstract class AnimationSupport {

    /**
     * Fires a {@link TimeEvent} on the given {@link EventTarget}.
     */
    public static void fireTimeEvent(EventTarget target, String eventType,
                                     Calendar time, int detail) {
        DocumentEvent de = (DocumentEvent) ((Node) target).getOwnerDocument();
        DOMTimeEvent evt = (DOMTimeEvent) de.createEvent("TimeEvent");
        evt.initTimeEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI, eventType,
                            null,
                            detail);
        evt.setTimestamp(time.getTime().getTime());
        target.dispatchEvent(evt);
    }

    /**
     * Returns the timed element with the given ID, using the given node
     * as the context for the lookup.
     */
    public static TimedElement getTimedElementById(String id, Node n) {
        Element e = getElementById(id, n);
        if (e instanceof SVGOMAnimationElement) {
            SVGAnimationElementBridge b = (SVGAnimationElementBridge)
                ((SVGOMAnimationElement) e).getSVGContext();
            return b.getTimedElement();
        }
        return null;
    }

    /**
     * Returns the event target with the given ID, using the given
     * node as the context for the lookup.
     */
    public static EventTarget getEventTargetById(String id, Node n) {
        return (EventTarget) getElementById(id, n);
    }

    /**
     * Returns the element with the given ID, using the given node
     * as the context for the lookup.
     */
    protected static Element getElementById(String id, Node n) {
        Node p = n.getParentNode();
        while (p != null) {
            n = p;
            if (n instanceof SVGOMUseShadowRoot) {
                p = ((SVGOMUseShadowRoot) n).getCSSParentNode();
            } else {
                p = n.getParentNode();
            }
        }
        if (n instanceof IdContainer) {
            return ((IdContainer) n).getElementById(id);
        }
        return null;
    }
}
