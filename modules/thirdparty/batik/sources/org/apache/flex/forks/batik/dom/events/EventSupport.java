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
package org.apache.flex.forks.batik.dom.events;

import org.apache.flex.forks.batik.dom.util.HashTable;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventException;
import org.w3c.dom.events.EventListener;

/**
 * The class allows registration and removal of EventListeners on
 * an NodeEventTarget and dispatch of events to that NodeEventTarget.  
 *
 * @see NodeEventTarget
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: EventSupport.java,v 1.17 2005/03/27 08:58:32 cam Exp $
 */
public class EventSupport {

    /**
     * The capturing listeners table.
     */
    protected HashTable capturingListeners;

    /**
     * The bubbling listeners table.
     */
    protected HashTable bubblingListeners;

    /**
     * This method allows the registration of event listeners on the
     * event target.  If an <code>EventListener</code> is added to an
     * <code>EventTarget</code> which is currently processing an event
     * the new listener will not be triggered by the current event.
     * <br> If multiple identical <code>EventListener</code>s are
     * registered on the same <code>EventTarget</code> with the same
     * parameters the duplicate instances are discarded. They do not
     * cause the <code>EventListener</code> to be called twice and
     * since they are discarded they do not need to be removed with
     * the <code>removeEventListener</code> method.
     *
     * @param type The event type for which the user is registering
     *
     * @param listener The <code>listener</code> parameter takes an
     * interface implemented by the user which contains the methods to
     * be called when the event occurs.
     *
     * @param useCapture If true, <code>useCapture</code> indicates
     * that the user wishes to initiate capture.  After initiating
     * capture, all events of the specified type will be dispatched to
     * the registered <code>EventListener</code> before being
     * dispatched to any <code>EventTargets</code> beneath them in the
     * tree.  Events which are bubbling upward through the tree will
     * not trigger an <code>EventListener</code> designated to use
     * capture.  
     */
    public void addEventListener(String type, EventListener listener, 
				 boolean useCapture) {
	HashTable listeners;
	if (useCapture) {
	    if (capturingListeners == null) {
		capturingListeners = new HashTable();
	    }
	    listeners = capturingListeners;
	} else {
	    if (bubblingListeners == null) {
		bubblingListeners = new HashTable();
	    }
	    listeners = bubblingListeners;
	}
	EventListenerList list = (EventListenerList) listeners.get(type);
	if (list == null) {
	    list = new EventListenerList();
	    listeners.put(type, list);
	}
	if (!list.contains(listener)) {
	    list.add(listener);
	}
    }

    /**
     * This method allows the removal of event listeners from the
     * event target.  If an <code>EventListener</code> is removed from
     * an <code>EventTarget</code> while it is processing an event, it
     * will complete its current actions but will not be triggered
     * again during any later stages of event flow.  <br>If an
     * <code>EventListener</code> is removed from an
     * <code>EventTarget</code> which is currently processing an event
     * the removed listener will still be triggered by the current
     * event. <br>Calling <code>removeEventListener</code> with
     * arguments which do not identify any currently registered
     * <code>EventListener</code> on the <code>EventTarget</code> has
     * no effect.
     *
     * @param type Specifies the event type of the
     * <code>EventListener</code> being removed.
     *
     * @param listener The <code>EventListener</code> parameter
     * indicates the <code>EventListener </code> to be removed.
     *
     * @param useCapture Specifies whether the
     * <code>EventListener</code> being removed was registered as a
     * capturing listener or not.  If a listener was registered twice,
     * one with capture and one without, each must be removed
     * separately.  Removal of a capturing listener does not affect a
     * non-capturing version of the same listener, and vice versa.  
     */
    public void removeEventListener(String type, EventListener listener, 
				    boolean useCapture) {
	HashTable listeners;
	if (useCapture) {
	    listeners = capturingListeners;
	} else {
	    listeners = bubblingListeners;
	}
	if (listeners == null) {
	    return;
	}
	EventListenerList list = (EventListenerList)listeners.get(type);
	if (list != null) {
	    list.remove(listener);
            if (list.size() == 0) {
                listeners.remove(type);
            }
	}
    }

    /**
     * This method allows the dispatch of events into the
     * implementations event model. Events dispatched in this manner
     * will have the same capturing and bubbling behavior as events
     * dispatched directly by the implementation. The target of the
     * event is the <code> EventTarget</code> on which
     * <code>dispatchEvent</code> is called.
     *
     * @param target the target node
     * @param e Specifies the event type, behavior, and contextual
     * information to be used in processing the event.
     *
     * @return The return value of <code>dispatchEvent</code>
     * indicates whether any of the listeners which handled the event
     * called <code>preventDefault</code>.  If
     * <code>preventDefault</code> was called the value is false, else
     * the value is true.
     *
     * @exception EventException
     *   UNSPECIFIED_EVENT_TYPE_ERR: Raised if the
     *   <code>Event</code>'s type was not specified by initializing
     *   the event before <code>dispatchEvent</code> was
     *   called. Specification of the <code>Event</code>'s type as
     *   <code>null</code> or an empty string will also trigger this
     *   exception.  
     */
    public static boolean dispatchEvent(NodeEventTarget target, Event e) 
	    throws EventException {
	AbstractEvent evt = (AbstractEvent) e;
	if (evt == null) {
	    return false;
	}
	String type = evt.getType();
	if (type == null) {
	    throw createUnspecifiedEventTypeErr("Event type can't be null");
	}
	// fix event status
	evt.setTarget(target);
	evt.stopPropagation(false);
	evt.preventDefault(false);
	// dump the tree hierarchy from top to the target
	NodeEventTarget [] ancestors = getAncestors(target);
	// CAPTURING_PHASE : fire event listeners from top to EventTarget
	evt.setEventPhase(Event.CAPTURING_PHASE);
	for (int i=0; i < ancestors.length && !evt.getStopPropagation();
	     ++i) {
	    NodeEventTarget node = ancestors[i];
	    evt.setCurrentTarget(node);
	    fireEventListeners(node, evt, true);
	}
	// AT_TARGET : fire local event listeners
	if (!evt.getStopPropagation()) {
	    evt.setEventPhase(Event.AT_TARGET);
	    evt.setCurrentTarget(target);
	    fireEventListeners(target, evt, false);
	}
	// BUBBLING_PHASE : fire event listeners from target to top
	if (evt.getBubbles()) {
	    evt.setEventPhase(Event.BUBBLING_PHASE);
	    for (int i=ancestors.length-1; 
		     i >=0 && !evt.getStopPropagation(); --i) {
		NodeEventTarget node = ancestors[i];
		evt.setCurrentTarget(node);
		fireEventListeners(node, evt, false);
	    }
	}
	return !evt.getPreventDefault();
    }

    private static void fireEventListeners(NodeEventTarget node, 
					   Event evt, boolean useCapture) {
	String type = evt.getType();
	EventSupport support = node.getEventSupport();
	// check if the event support has been instantiated
	if (support == null) {
	    return;
	}
	EventListenerList list=support.getEventListeners(type, useCapture);
	// check if the event listeners list is not empty
	if (list == null) {
	    return;
	}
	// dump event listeners, we get the registered listeners NOW
	EventListener [] listeners = list.getEventListeners();
	// check if event listeners with the correct event type exist
	if (listeners == null) {
	    return;
	}
	// fire event listeners
	for (int i=0; i < listeners.length; ++i) {
	    try {
		listeners[i].handleEvent(evt);
            } catch (ThreadDeath td) {
                throw td;
	    } catch (Throwable th) {
                th.printStackTrace();
	    }
	}
    }

    // Returns all ancestors of the specified node
    private static NodeEventTarget [] getAncestors(NodeEventTarget node) {
	node = node.getParentNodeEventTarget(); // skip current node
	int nancestors = 0;
	for (NodeEventTarget n = node;
             n != null;
             n = n.getParentNodeEventTarget(), nancestors++) {}
	NodeEventTarget [] ancestors = new NodeEventTarget[nancestors];
	for (int i=nancestors-1;
             i >= 0;
             --i, node = node.getParentNodeEventTarget()) {
	    ancestors[i] = node;
	}
	return ancestors;
    }

    /**
     * Returns a list event listeners depending on the specified event
     * type and phase.
     * @param type the event type 
     * @param useCapture
     */
    public EventListenerList getEventListeners(String type, 
					       boolean useCapture) {
	HashTable listeners=(useCapture)?capturingListeners:bubblingListeners;
	if (listeners == null) {
	    return null;
	} else {
	    return (EventListenerList) listeners.get(type);
	}
    }

    /**
     * Creates an EventException. Overrides this method if you need to
     * create your own RangeException subclass.
     * @param code the exception code
     * @param message the detail message
     */
    private static EventException createEventException(short code, String s) {
	return new EventException(code, s);
    }

    private static EventException createUnspecifiedEventTypeErr(String s) {
	return createEventException(EventException.UNSPECIFIED_EVENT_TYPE_ERR,
				    s);
    }
}
