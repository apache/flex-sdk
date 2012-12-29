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

import org.w3c.dom.DOMException;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventException;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;

/**
 * A Node that uses an EventSupport for its event registration and
 * dispatch.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: NodeEventTarget.java 484911 2006-12-09 04:37:29Z cam $
 */
public interface NodeEventTarget extends EventTarget {

    /**
     * Returns the event support instance for this node, or null if any.
     */
    EventSupport getEventSupport();

    /**
     * Returns the parent node event target.
     */
    NodeEventTarget getParentNodeEventTarget();

    // Members inherited from DOM Level 3 Events org.w3c.dom.events.EventTarget
    // follow.

    /**
     *  This method allows the dispatch of events into the implementation's
     * event model. The event target of the event is the
     * <code>EventTarget</code> object on which <code>dispatchEvent</code>
     * is called.
     * @param evt  The event to be dispatched.
     * @return  Indicates whether any of the listeners which handled the
     *   event called <code>Event.preventDefault()</code>. If
     *   <code>Event.preventDefault()</code> was called the returned value
     *   is <code>false</code>, else it is <code>true</code>.
     * @exception EventException
     *    UNSPECIFIED_EVENT_TYPE_ERR: Raised if the <code>Event.type</code>
     *   was not specified by initializing the event before
     *   <code>dispatchEvent</code> was called. Specification of the
     *   <code>Event.type</code> as <code>null</code> or an empty string
     *   will also trigger this exception.
     *   <br> DISPATCH_REQUEST_ERR: Raised if the <code>Event</code> object is
     *   already being dispatched.
     * @exception DOMException
     *    NOT_SUPPORTED_ERR: Raised if the <code>Event</code> object has not
     *   been created using <code>DocumentEvent.createEvent()</code>.
     *   <br> INVALID_CHARACTER_ERR: Raised if <code>Event.type</code> is not
     *   an <a href='http://www.w3.org/TR/2004/REC-xml-names11-20040204/#NT-NCName'>NCName</a> as defined in [<a href='http://www.w3.org/TR/2004/REC-xml-names11-20040204/'>XML Namespaces 1.1</a>]
     *   .
     * @version DOM Level 3
     */
    boolean dispatchEvent(Event evt) throws EventException, DOMException;

    /**
     *  This method allows the registration of an event listener in a
     * specified group or the default group and, depending on the
     * <code>useCapture</code> parameter, on the capture phase of the DOM
     * event flow or its target and bubbling phases.
     * @param namespaceURI  Specifies the <code>Event.namespaceURI</code>
     *   associated with the event for which the user is registering.
     * @param type  Refer to the <code>EventTarget.addEventListener()</code>
     *   method for a description of this parameter.
     * @param listener  Refer to the
     *   <code>EventTarget.addEventListener()</code> method for a
     *   description of this parameter.
     * @param useCapture  Refer to the
     *   <code>EventTarget.addEventListener()</code> method for a
     *   description of this parameter.
     * @param evtGroup  The object that represents the event group to
     *   associate with the <code>EventListener</code> (see also ). Use
     *   <code>null</code> to attach the event listener to the default
     *   group.
     * @since DOM Level 3
     */
    void addEventListenerNS(String namespaceURI,
                            String type,
                            EventListener listener,
                            boolean useCapture,
                            Object evtGroup);

    /**
     *  This method allows the removal of an event listener, independently of
     * the associated event group. Calling <code>removeEventListenerNS</code>
     *  with arguments which do not identify any currently registered
     * <code>EventListener</code> on the <code>EventTarget</code> has no
     * effect.
     * @param namespaceURI  Specifies the <code>Event.namespaceURI</code>
     *   associated with the event for which the user registered the event
     *   listener.
     * @param type  Refer to the
     *   <code>EventTarget.removeEventListener()</code> method for a
     *   description of this parameter.
     * @param listener  Refer to the
     *   <code>EventTarget.removeEventListener()</code> method for a
     *   description of this parameter.
     * @param useCapture  Refer to the
     *   <code>EventTarget.removeEventListener()</code> method for a
     *   description of this parameter.
     * @since DOM Level 3
     */
    void removeEventListenerNS(String namespaceURI,
                               String type,
                               EventListener listener,
                               boolean useCapture);
}
