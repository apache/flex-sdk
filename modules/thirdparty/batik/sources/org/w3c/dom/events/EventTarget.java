/*
 * Copyright (c) 2006 World Wide Web Consortium,
 *
 * (Massachusetts Institute of Technology, European Research Consortium for
 * Informatics and Mathematics, Keio University). All Rights Reserved. This
 * work is distributed under the W3C(r) Software License [1] in the hope that
 * it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * [1] http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
 */

package org.w3c.dom.events;

import org.w3c.dom.DOMException;

/**
 *  The <code>EventTarget</code> interface is implemented by all the objects 
 * which could be event targets in an implementation which supports the . 
 * The interface allows registration and removal of event listeners, and 
 * dispatch of events to an event target. 
 * <p> When used with , this interface is implemented by all target nodes and 
 * target ancestors, i.e. all DOM <code>Nodes</code> of the tree support 
 * this interface when the implementation conforms to DOM Level 3 Events 
 * and, therefore, this interface can be obtained by using binding-specific 
 * casting methods on an instance of the <code>Node</code> interface. 
 * <p> Invoking <code>addEventListener</code> or 
 * <code>addEventListenerNS</code> repeatedly on the same 
 * <code>EventTarget</code> with the same values for the parameters 
 * <code>namespaceURI</code>, <code>type</code>, <code>listener</code>, and 
 * <code>useCapture</code> has no effect. Doing so does not cause the 
 * <code>EventListener</code> to be called more than once and does not cause 
 * a change in the triggering order. In order to register a listener for a 
 * different event group () the previously registered listener has to be 
 * removed first. 
 * <p>See also the <a href='http://www.w3.org/TR/2006/WD-DOM-Level-3-Events-20060413'>
   Document Object Model (DOM) Level 3 Events Specification
  </a>.
 * @since DOM Level 2
 */
public interface EventTarget {
    /**
     *  This method allows the registration of an event listener in the 
     * default group and, depending on the <code>useCapture</code> 
     * parameter, on the capture phase of the DOM event flow or its target 
     * and bubbling phases. Invoking this method is equivalent to invoking 
     * <code>addEventListenerNS</code> with the same values for the 
     * parameters <code>type</code>, <code>listener</code>, and 
     * <code>useCapture</code>, and the value <code>null</code> for the 
     * parameters <code>namespaceURI</code> and <code>evtGroup</code>. 
     * @param type  Specifies the <code>Event.type</code> associated with the 
     *   event for which the user is registering. 
     * @param listener  The <code>listener</code> parameter takes an object 
     *   implemented by the user which implements the 
     *   <code>EventListener</code> interface and contains the method to be 
     *   called when the event occurs. 
     * @param useCapture  If true, <code>useCapture</code> indicates that the 
     *   user wishes to add the event listener for the capture phase only, 
     *   i.e. this event listener will not be triggered during the target 
     *   and bubbling phases. If <code>false</code>, the event listener will 
     *   only be triggered during the target and bubbling phases.   
     */
    public void addEventListener(String type, 
                                 EventListener listener, 
                                 boolean useCapture);

    /**
     *  This method allows the removal of event listeners from the default 
     * group. Calling <code>removeEventListener</code> with arguments which 
     * do not identify any currently registered <code>EventListener</code> 
     * on the <code>EventTarget</code> has no effect. The 
     * <code>Event.namespaceURI</code> for which the user registered the 
     * event listener is implied and is <code>null</code>. 
     * <p ><b>Note:</b>  Event listeners registered for other event groups 
     * than the default group cannot be removed using this method; see 
     * <code>EventTarget.removeEventListenerNS()</code> for that effect. 
     * @param type  Specifies the <code>Event.type</code> for which the user 
     *   registered the event listener. 
     * @param listener  The <code>EventListener</code> to be removed. 
     * @param useCapture  Specifies whether the <code>EventListener</code> 
     *   being removed was registered for the capture phase or not. If a 
     *   listener was registered twice, once for the capture phase and once 
     *   for the target and bubbling phases, each must be removed 
     *   separately. Removal of an event listener registered for the capture 
     *   phase does not affect the same event listener registered for the 
     *   target and bubbling phases, and vice versa.   
     */
    public void removeEventListener(String type, 
                                    EventListener listener, 
                                    boolean useCapture);

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
    public boolean dispatchEvent(Event evt)
                                 throws EventException, DOMException;

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
    public void addEventListenerNS(String namespaceURI, 
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
    public void removeEventListenerNS(String namespaceURI, 
                                      String type, 
                                      EventListener listener, 
                                      boolean useCapture);

}
