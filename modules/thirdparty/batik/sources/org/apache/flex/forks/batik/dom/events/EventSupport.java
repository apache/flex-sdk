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

import java.util.HashSet;
import java.util.List;
import java.util.Iterator;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.util.HashTable;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
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
 * @version $Id: EventSupport.java 601207 2007-12-05 04:57:31Z cam $
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
     * The node for which events are being handled.
     */
    protected AbstractNode node;

    /**
     * Creates a new EventSupport object.
     * @param n the node for which events are being handled
     */
    public EventSupport(AbstractNode n) {
        node = n;
    }

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
        addEventListenerNS(null, type, listener, useCapture, null);
    }

    /**
     * Registers an event listener for the given namespaced event type
     * in the specified group.
     */
    public void addEventListenerNS(String namespaceURI,
                                   String type,
                                   EventListener listener,
                                   boolean useCapture,
                                   Object group) {
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
        list.addListener(namespaceURI, group, listener);
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
        removeEventListenerNS(null, type, listener, useCapture);
    }

    /**
     * Deregisters an event listener.
     */
    public void removeEventListenerNS(String namespaceURI,
                                      String type,
                                      EventListener listener,
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
        EventListenerList list = (EventListenerList) listeners.get(type);
        if (list != null) {
            list.removeListener(namespaceURI, listener);
            if (list.size() == 0) {
                listeners.remove(type);
            }
        }
    }

    /**
     * Moves all of the event listeners from this EventSupport object
     * to the given EventSupport object.
     * Used by {@link
     * org.apache.flex.forks.batik.dom.AbstractDocument#renameNode(Node,String,String)}.
     */
    public void moveEventListeners(EventSupport other) {
        other.capturingListeners = capturingListeners;
        other.bubblingListeners = bubblingListeners;
        capturingListeners = null;
        bubblingListeners = null;
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
     * @param evt Specifies the event type, behavior, and contextual
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
    public boolean dispatchEvent(NodeEventTarget target, Event evt)
            throws EventException {
        if (evt == null) {
            return false;
        }
        if (!(evt instanceof AbstractEvent)) {
            throw createEventException(DOMException.NOT_SUPPORTED_ERR,
                                       "unsupported.event",
                                       new Object[] { });
        }
        AbstractEvent e = (AbstractEvent) evt;
        String type = e.getType();
        if (type == null || type.length() == 0) {
            throw createEventException
                (EventException.UNSPECIFIED_EVENT_TYPE_ERR,
                 "unspecified.event",
                 new Object[] {});
        }
        // fix event status
        e.setTarget(target);
        e.stopPropagation(false);
        e.stopImmediatePropagation(false);
        e.preventDefault(false);
        // dump the tree hierarchy from top to the target
        NodeEventTarget[] ancestors = getAncestors(target);
        // CAPTURING_PHASE : fire event listeners from top to EventTarget
        e.setEventPhase(Event.CAPTURING_PHASE);
        HashSet stoppedGroups = new HashSet();
        HashSet toBeStoppedGroups = new HashSet();
        for (int i = 0; i < ancestors.length; i++) {
            NodeEventTarget node = ancestors[i];
            e.setCurrentTarget(node);
            fireEventListeners(node, e, true, stoppedGroups,
                               toBeStoppedGroups);
            stoppedGroups.addAll(toBeStoppedGroups);
            toBeStoppedGroups.clear();
        }
        // AT_TARGET : fire local event listeners
        e.setEventPhase(Event.AT_TARGET);
        e.setCurrentTarget(target);
        fireEventListeners(target, e, false, stoppedGroups,
                           toBeStoppedGroups);
        stoppedGroups.addAll(toBeStoppedGroups);
        toBeStoppedGroups.clear();
        // BUBBLING_PHASE : fire event listeners from target to top
        if (e.getBubbles()) {
            e.setEventPhase(Event.BUBBLING_PHASE);
            for (int i = ancestors.length - 1; i >= 0; i--) {
                NodeEventTarget node = ancestors[i];
                e.setCurrentTarget(node);
                fireEventListeners(node, e, false, stoppedGroups,
                                   toBeStoppedGroups);
                stoppedGroups.addAll(toBeStoppedGroups);
                toBeStoppedGroups.clear();
            }
        }
        if (!e.getDefaultPrevented()) {
            runDefaultActions(e);
        }
        return e.getDefaultPrevented();
    }

    /**
     * Runs all of the registered default actions for the given event object.
     */
    protected void runDefaultActions(AbstractEvent e) {
        List runables = e.getDefaultActions();
        if (runables != null) {
            Iterator i = runables.iterator();
            while (i.hasNext()) {
                Runnable r = (Runnable)i.next();
                r.run();
            }
        }
    }

    /**
     * Fires the given listeners on the given event target.
     */
    protected void fireEventListeners(NodeEventTarget node,
                                      AbstractEvent e,
                                      EventListenerList.Entry[] listeners,
                                      HashSet stoppedGroups,
                                      HashSet toBeStoppedGroups) {
        if (listeners == null) {
            return;
        }
        // fire event listeners
        String eventNS = e.getNamespaceURI();
        for (int i = 0; i < listeners.length; i++) {
            try {
                String listenerNS = listeners[i].getNamespaceURI();
                if (listenerNS != null && eventNS != null
                        && !listenerNS.equals(eventNS)) {
                    continue;
                }
                Object group = listeners[i].getGroup();
                if (stoppedGroups == null || !stoppedGroups.contains(group)) {
                    listeners[i].getListener().handleEvent(e);
                    if (e.getStopImmediatePropagation()) {
                        if (stoppedGroups != null) {
                            stoppedGroups.add(group);
                        }
                        e.stopImmediatePropagation(false);
                    } else if (e.getStopPropagation()) {
                        if (toBeStoppedGroups != null) {
                            toBeStoppedGroups.add(group);
                        }
                        e.stopPropagation(false);
                    }
                }
            } catch (ThreadDeath td) {
                throw td;
            } catch (Throwable th) {
                th.printStackTrace();
            }
        }
    }

    /**
     * Fires the registered listeners on the given event target.
     */
    protected void fireEventListeners(NodeEventTarget node,
                                      AbstractEvent e,
                                      boolean useCapture,
                                      HashSet stoppedGroups,
                                      HashSet toBeStoppedGroups) {
        String type = e.getType();
        EventSupport support = node.getEventSupport();
        // check if the event support has been instantiated
        if (support == null) {
            return;
        }
        EventListenerList list = support.getEventListeners(type, useCapture);
        // check if the event listeners list is not empty
        if (list == null) {
            return;
        }
        // dump event listeners, we get the registered listeners NOW
        EventListenerList.Entry[] listeners = list.getEventListeners();
        fireEventListeners(node, e, listeners, stoppedGroups,
                           toBeStoppedGroups);
    }

    /**
     * Returns all ancestors of the specified node.
     */
    protected NodeEventTarget[] getAncestors(NodeEventTarget node) {
        node = node.getParentNodeEventTarget(); // skip current node
        int nancestors = 0;
        for (NodeEventTarget n = node;
             n != null;
             n = n.getParentNodeEventTarget(), nancestors++) {
        }
        NodeEventTarget[] ancestors = new NodeEventTarget[nancestors];
        for (int i = nancestors - 1;
             i >= 0;
             --i, node = node.getParentNodeEventTarget()) {
            ancestors[i] = node;
        }
        return ancestors;
    }

    /**
     * Returns whether this node target has an event listener for the
     * given event namespace URI and type.
     */
    public boolean hasEventListenerNS(String namespaceURI, String type) {
        if (capturingListeners != null) {
            EventListenerList ell
                = (EventListenerList) capturingListeners.get(type);
            if (ell != null) {
                if (ell.hasEventListener(namespaceURI)) {
                    return true;
                }
            }
        }
        if (bubblingListeners != null) {
            EventListenerList ell
                = (EventListenerList) capturingListeners.get(type);
            if (ell != null) {
                return ell.hasEventListener(namespaceURI);
            }
        }
        return false;
    }

    /**
     * Returns a list event listeners depending on the specified event
     * type and phase.
     * @param type the event type
     * @param useCapture
     */
    public EventListenerList getEventListeners(String type,
                                               boolean useCapture) {
        HashTable listeners
            = useCapture ? capturingListeners : bubblingListeners;
        if (listeners == null) {
            return null;
        }
        return (EventListenerList) listeners.get(type);
    }

    /**
     * Creates an EventException. Overrides this method if you need to
     * create your own RangeException subclass.
     * @param code the exception code
     * @param key the resource key
     * @param args arguments to use when formatting the message
     */
    protected EventException createEventException(short code,
                                                  String key,
                                                  Object[] args) {
        try {
            AbstractDocument doc = (AbstractDocument) node.getOwnerDocument();
            return new EventException(code, doc.formatMessage(key, args));
        } catch (Exception e) {
            return new EventException(code, key);
        }
    }

    /**
     * Calls {@link AbstractEvent#setTarget}.
     */
    protected void setTarget(AbstractEvent e, NodeEventTarget target) {
        e.setTarget(target);
    }

    /**
     * Calls {@link AbstractEvent#stopPropagation(boolean)}.
     */
    protected void stopPropagation(AbstractEvent e, boolean b) {
        e.stopPropagation(b);
    }

    /**
     * Calls {@link AbstractEvent#stopImmediatePropagation(boolean)}.
     */
    protected void stopImmediatePropagation(AbstractEvent e, boolean b) {
        e.stopImmediatePropagation(b);
    }

    /**
     * Calls {@link AbstractEvent#preventDefault(boolean)}.
     */
    protected void preventDefault(AbstractEvent e, boolean b) {
        e.preventDefault(b);
    }

    /**
     * Calls {@link AbstractEvent#setCurrentTarget}.
     */
    protected void setCurrentTarget(AbstractEvent e, NodeEventTarget target) {
        e.setCurrentTarget(target);
    }

    /**
     * Calls {@link AbstractEvent#setEventPhase}.
     */
    protected void setEventPhase(AbstractEvent e, short phase) {
        e.setEventPhase(phase);
    }

    /**
     * Returns the ultimate original event for the given event.
     */
    public static Event getUltimateOriginalEvent(Event evt) {
        AbstractEvent e = (AbstractEvent) evt;
        for (;;) {
            AbstractEvent origEvt = (AbstractEvent) e.getOriginalEvent();
            if (origEvt == null) {
                break;
            }
            e = origEvt;
        }
        return e;
    }
}
