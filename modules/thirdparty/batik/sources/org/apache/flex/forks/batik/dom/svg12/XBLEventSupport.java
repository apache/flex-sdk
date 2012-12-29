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

import java.util.HashSet;

import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.events.AbstractEvent;
import org.apache.flex.forks.batik.dom.events.EventListenerList;
import org.apache.flex.forks.batik.dom.events.EventSupport;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.util.HashTable;
import org.apache.flex.forks.batik.dom.xbl.NodeXBL;
import org.apache.flex.forks.batik.dom.xbl.ShadowTreeEvent;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventException;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.MutationEvent;

/**
 * An EventSupport class that handles XBL-specific event processing.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: XBLEventSupport.java 601207 2007-12-05 04:57:31Z cam $
 */
public class XBLEventSupport extends EventSupport {

    /**
     * The unstoppable capturing listeners table.
     */
    protected HashTable capturingImplementationListeners;

    /**
     * The unstoppable bubbling listeners table.
     */
    protected HashTable bubblingImplementationListeners;

    /**
     * Map of event types to their aliases.
     */
    protected static HashTable eventTypeAliases = new HashTable();
    static {
        eventTypeAliases.put("SVGLoad",   "load");
        eventTypeAliases.put("SVGUnoad",  "unload");
        eventTypeAliases.put("SVGAbort",  "abort");
        eventTypeAliases.put("SVGError",  "error");
        eventTypeAliases.put("SVGResize", "resize");
        eventTypeAliases.put("SVGScroll", "scroll");
        eventTypeAliases.put("SVGZoom",   "zoom");
    }

    /**
     * Creates a new XBLEventSupport object.
     */
    public XBLEventSupport(AbstractNode n) {
        super(n);
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
        super.addEventListenerNS
            (namespaceURI, type, listener, useCapture, group);
        if (namespaceURI == null
                || namespaceURI.equals(XMLConstants.XML_EVENTS_NAMESPACE_URI)) {
            String alias = (String) eventTypeAliases.get(type);
            if (alias != null) {
                super.addEventListenerNS
                    (namespaceURI, alias, listener, useCapture, group);
            }
        }
    }

    /**
     * Deregisters an event listener.
     */
    public void removeEventListenerNS(String namespaceURI,
                                      String type,
                                      EventListener listener,
                                      boolean useCapture) {
        super.removeEventListenerNS(namespaceURI, type, listener, useCapture);
        if (namespaceURI == null
                || namespaceURI.equals(XMLConstants.XML_EVENTS_NAMESPACE_URI)) {
            String alias = (String) eventTypeAliases.get(type);
            if (alias != null) {
                super.removeEventListenerNS
                    (namespaceURI, alias, listener, useCapture);
            }
        }
    }

    /**
     * Registers an event listener that will not be stopped by the usual
     * XBL stopping.
     */
    public void addImplementationEventListenerNS(String namespaceURI,
                                                 String type,
                                                 EventListener listener,
                                                 boolean useCapture) {
        HashTable listeners;
        if (useCapture) {
            if (capturingImplementationListeners == null) {
                capturingImplementationListeners = new HashTable();
            }
            listeners = capturingImplementationListeners;
        } else {
            if (bubblingImplementationListeners == null) {
                bubblingImplementationListeners = new HashTable();
            }
            listeners = bubblingImplementationListeners;
        }
        EventListenerList list = (EventListenerList) listeners.get(type);
        if (list == null) {
            list = new EventListenerList();
            listeners.put(type, list);
        }
        list.addListener(namespaceURI, null, listener);
    }

    /**
     * Unregisters an implementation event listener.
     */
    public void removeImplementationEventListenerNS(String namespaceURI,
                                                    String type,
                                                    EventListener listener,
                                                    boolean useCapture) {
        HashTable listeners = useCapture ? capturingImplementationListeners
                                         : bubblingImplementationListeners;
        if (listeners == null) {
            return;
        }
        EventListenerList list = (EventListenerList) listeners.get(type);
        if (list == null) {
            return;
        }
        list.removeListener(namespaceURI, listener);
        if (list.size() == 0) {
            listeners.remove(type);
        }
    }

    /**
     * Moves all of the event listeners from this EventSupport object
     * to the given EventSupport object.
     * Used by {@link
     * org.apache.flex.forks.batik.dom.AbstractDocument#renameNode(Node,String,String)}.
     */
    public void moveEventListeners(EventSupport other) {
        super.moveEventListeners(other);
        XBLEventSupport es = (XBLEventSupport) other;
        es.capturingImplementationListeners = capturingImplementationListeners;
        es.bubblingImplementationListeners = bubblingImplementationListeners;
        capturingImplementationListeners = null;
        bubblingImplementationListeners = null;
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
//         System.err.println("\t[] dispatching " + e.getType() + " on " + ((Node) target).getNodeName());
        if (evt == null) {
            return false;
        }
        if (!(evt instanceof AbstractEvent)) {
            throw createEventException
                (DOMException.NOT_SUPPORTED_ERR,
                 "unsupported.event",
                 new Object[] {});
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
        setTarget(e, target);
        stopPropagation(e, false);
        stopImmediatePropagation(e, false);
        preventDefault(e, false);
        // dump the tree hierarchy from top to the target
        NodeEventTarget[] ancestors = getAncestors(target);
        int bubbleLimit = e.getBubbleLimit();
        int minAncestor = 0;
        if (isSingleScopeEvent(e)) {
            // DOM Mutation events are dispatched only within the
            // one shadow scope
            AbstractNode targetNode = (AbstractNode) target;
            Node boundElement = targetNode.getXblBoundElement();
            if (boundElement != null) {
                minAncestor = ancestors.length;
                while (minAncestor > 0) {
                    AbstractNode ancestorNode =
                        (AbstractNode) ancestors[minAncestor - 1];
                    if (ancestorNode.getXblBoundElement() != boundElement) {
                        break;
                    }
                    minAncestor--;
                }
            }
        } else if (bubbleLimit != 0) {
            // Other events may have a bubble limit (such as UI events)
            minAncestor = ancestors.length - bubbleLimit + 1;
            if (minAncestor < 0) {
                minAncestor = 0;
            }
        }
//         System.err.println("\t== ancestors:");
//         for (int i = 0; i < ancestors.length; i++) {
//             if (i < minAncestor) {
//                 System.err.print("\t     ");
//             } else {
//                 System.err.print("\t   * ");
//             }
//             System.err.println(((Node) ancestors[i]).getNodeName());
//         }
        AbstractEvent[] es = getRetargettedEvents(target, ancestors, e);
        boolean preventDefault = false;
        // CAPTURING_PHASE : fire event listeners from top to EventTarget
        HashSet stoppedGroups = new HashSet();
        HashSet toBeStoppedGroups = new HashSet();
        for (int i = 0; i < minAncestor; i++) {
            NodeEventTarget node = ancestors[i];
//             System.err.println("\t--   CAPTURING " + e.getType() + "  " + ((Node) node).getNodeName());
            setCurrentTarget(es[i], node);
            setEventPhase(es[i], Event.CAPTURING_PHASE);
            fireImplementationEventListeners(node, es[i], true);
        }
        for (int i = minAncestor; i < ancestors.length; i++) {
            NodeEventTarget node = ancestors[i];
//             System.err.println("\t-- * CAPTURING " + e.getType() + "  " + ((Node) node).getNodeName());
            setCurrentTarget(es[i], node);
            setEventPhase(es[i], Event.CAPTURING_PHASE);
            fireImplementationEventListeners(node, es[i], true);
            fireEventListeners(node, es[i], true, stoppedGroups,
                               toBeStoppedGroups);
            fireHandlerGroupEventListeners(node, es[i], true, stoppedGroups,
                                           toBeStoppedGroups);
            preventDefault = preventDefault || es[i].getDefaultPrevented();
            stoppedGroups.addAll(toBeStoppedGroups);
            toBeStoppedGroups.clear();
        }
        // AT_TARGET : fire local event listeners
//         System.err.println("\t-- * AT_TARGET " + e.getType() + "  " + ((Node) target).getNodeName());
        setEventPhase(e, Event.AT_TARGET);
        setCurrentTarget(e, target);
        fireImplementationEventListeners(target, e, false);
        fireEventListeners(target, e, false, stoppedGroups,
                           toBeStoppedGroups);
        fireHandlerGroupEventListeners(node, e, false, stoppedGroups,
                                       toBeStoppedGroups);
        stoppedGroups.addAll(toBeStoppedGroups);
        toBeStoppedGroups.clear();
        preventDefault = preventDefault || e.getDefaultPrevented();
        // BUBBLING_PHASE : fire event listeners from target to top
        if (e.getBubbles()) {
            for (int i = ancestors.length - 1; i >= minAncestor; i--) {
                NodeEventTarget node = ancestors[i];
//                 System.err.println("\t-- * BUBBLING  " + e.getType() + "  " + ((Node) node).getNodeName());
                setCurrentTarget(es[i], node);
                setEventPhase(es[i], Event.BUBBLING_PHASE);
                fireImplementationEventListeners(node, es[i], false);
                fireEventListeners(node, es[i], false, stoppedGroups,
                                   toBeStoppedGroups);
                fireHandlerGroupEventListeners
                    (node, es[i], false, stoppedGroups, toBeStoppedGroups);
                preventDefault =
                    preventDefault || es[i].getDefaultPrevented();
                stoppedGroups.addAll(toBeStoppedGroups);
                toBeStoppedGroups.clear();
            }
            for (int i = minAncestor - 1; i >= 0; i--) {
                NodeEventTarget node = ancestors[i];
//                 System.err.println("\t--   BUBBLING  " + e.getType() + "  " + ((Node) node).getNodeName());
                setCurrentTarget(es[i], node);
                setEventPhase(es[i], Event.BUBBLING_PHASE);
                fireImplementationEventListeners(node, es[i], false);
                preventDefault =
                    preventDefault || es[i].getDefaultPrevented();
            }
        }
        if (!preventDefault) {
            runDefaultActions(e);
        }
        return preventDefault;
    }

    /**
     * Fires the event handlers registered on an XBL 'handlerGroup' element.
     */
    protected void fireHandlerGroupEventListeners(NodeEventTarget node, 
                                                  AbstractEvent e,
                                                  boolean useCapture,
                                                  HashSet stoppedGroups,
                                                  HashSet toBeStoppedGroups) {
        // get the XBL definitions in effect for the event target
        NodeList defs = ((NodeXBL) node).getXblDefinitions();
        for (int j = 0; j < defs.getLength(); j++) {
            // find the 'handlerGroup' element
            Node n = defs.item(j).getFirstChild();
            while (n != null &&
                    !(n instanceof XBLOMHandlerGroupElement)) {
                n = n.getNextSibling();
            }
            if (n == null) {
                continue;
            }
            node = (NodeEventTarget) n;
            String type = e.getType();
            EventSupport support = node.getEventSupport();
            // check if the event support has been instantiated
            if (support == null) {
                continue;
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
    }

    /**
     * Returns whether the given event should be stopped once it crosses
     * a shadow scope boundary.
     */
    protected boolean isSingleScopeEvent(Event evt) {
        return evt instanceof MutationEvent
            || evt instanceof ShadowTreeEvent;
    }

    /**
     * Returns an array of Event objects to be used for each event target
     * in the event flow.  The Event objects are retargetted if an sXBL
     * shadow scope is crossed and the event is not a DOM mutation event.
     */
    protected AbstractEvent[] getRetargettedEvents(NodeEventTarget target,
                                                   NodeEventTarget[] ancestors,
                                                   AbstractEvent e) {
        boolean singleScope = isSingleScopeEvent(e);
        AbstractNode targetNode = (AbstractNode) target;
        AbstractEvent[] es = new AbstractEvent[ancestors.length];
        if (ancestors.length > 0) {
            int index = ancestors.length - 1;
            Node boundElement = targetNode.getXblBoundElement();
            AbstractNode ancestorNode = (AbstractNode) ancestors[index];
            if (!singleScope &&
                    ancestorNode.getXblBoundElement() != boundElement) {
                es[index] = retargetEvent(e, ancestors[index]);
            } else {
                es[index] = e;
            }
            while (--index >= 0) {
                ancestorNode = (AbstractNode) ancestors[index + 1];
                boundElement = ancestorNode.getXblBoundElement();
                AbstractNode nextAncestorNode = (AbstractNode) ancestors[index];
                Node nextBoundElement = nextAncestorNode.getXblBoundElement();
                if (!singleScope && nextBoundElement != boundElement) {
                    es[index] = retargetEvent(es[index + 1], ancestors[index]);
                } else {
                    es[index] = es[index + 1];
                }
            }
        }
        return es;
    }

    /**
     * Clones and retargets the given event.
     */
    protected AbstractEvent retargetEvent(AbstractEvent e,
                                          NodeEventTarget target) {
        AbstractEvent clonedEvent = e.cloneEvent();
        setTarget(clonedEvent, target);
        return clonedEvent;
    }
    
    /**
     * Returns the implementation listneers.
     */
    public EventListenerList getImplementationEventListeners
            (String type, boolean useCapture) {
        HashTable listeners = useCapture ? capturingImplementationListeners
                                         : bubblingImplementationListeners;
        if (listeners == null) {
            return null;
        }
        return (EventListenerList) listeners.get(type);
    }

    /**
     * Fires the registered implementation listeners on the given event
     * target.
     */
    protected void fireImplementationEventListeners(NodeEventTarget node, 
                                                    AbstractEvent e,
                                                    boolean useCapture) {
        String type = e.getType();
        XBLEventSupport support = (XBLEventSupport) node.getEventSupport();
        // check if the event support has been instantiated
        if (support == null) {
            return;
        }
        EventListenerList list =
            support.getImplementationEventListeners(type, useCapture);
        // check if the event listeners list is not empty
        if (list == null) {
            return;
        }
        // dump event listeners, we get the registered listeners NOW
        EventListenerList.Entry[] listeners = list.getEventListeners();
        fireEventListeners(node, e, listeners, null, null);
    }
}
