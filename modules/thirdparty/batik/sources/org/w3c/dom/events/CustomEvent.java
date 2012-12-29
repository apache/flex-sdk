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

/**
 *  The CustomEvent interface is the recommended interface for 
 * application-specific event types. Unlike the <code>Event</code> 
 * interface, it allows applications to provide contextual information about 
 * the event type. Application-specific event types should have an 
 * associated namespace to avoid clashes with future general-purpose event 
 * types. 
 * <p> To create an instance of the <code>CustomEvent</code> interface, use 
 * the <code>DocumentEvent.createEvent("CustomEvent")</code> method call. 
 * <p>See also the <a href='http://www.w3.org/TR/2006/WD-DOM-Level-3-Events-20060413'>
   Document Object Model (DOM) Level 3 Events Specification
  </a>.
 * @since DOM Level 3
 */
public interface CustomEvent extends Event {
    /**
     *  Specifies some detail information about the <code>Event</code>. 
     */
    public Object getDetail();

    /**
     *  The <code>initCustomEventNS</code> method is used to initialize the 
     * value of a <code>CustomEvent</code> object and has the same behavior 
     * as <code>Event.initEventNS()</code>. 
     * @param namespaceURI  Refer to the <code>Event.initEventNS()</code> 
     *   method for a description of this parameter. 
     * @param typeArg  Refer to the <code>Event.initEventNS()</code> method 
     *   for a description of this parameter. 
     * @param canBubbleArg  Refer to the <code>Event.initEventNS()</code> 
     *   method for a description of this parameter. 
     * @param cancelableArg  Refer to the <code>Event.initEventNS()</code> 
     *   method for a description of this parameter. 
     * @param detailArg  Specifies <code>CustomEvent.detail</code>. This 
     *   value may be <code>null</code>.   
     */
    public void initCustomEventNS(String namespaceURI, 
                                  String typeArg, 
                                  boolean canBubbleArg, 
                                  boolean cancelableArg, 
                                  Object detailArg);

}
