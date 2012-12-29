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

import org.apache.flex.forks.batik.dom.util.HashTable;
import org.w3c.dom.DOMException;
import org.w3c.dom.events.Event;

/**
 * This class implements the behavior of DocumentEvent.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DocumentEventSupport.java 475685 2006-11-16 11:16:05Z cam $
 */
public class DocumentEventSupport {
    
    /**
     * The Event type.
     */
    public static final String EVENT_TYPE = "Event";
    
    /**
     * The MutationEvent type.
     */
    public static final String MUTATION_EVENT_TYPE = "MutationEvent";
    
    /**
     * The MutationNameEvent type.
     */
    public static final String MUTATION_NAME_EVENT_TYPE = "MutationNameEvent";
    
    /**
     * The MouseEvent type.
     */
    public static final String MOUSE_EVENT_TYPE = "MouseEvent";

    /**
     * The UIEvent type.
     */
    public static final String UI_EVENT_TYPE = "UIEvent";

    /**
     * The KeyEvent type.
     */
    public static final String KEYBOARD_EVENT_TYPE = "KeyboardEvent";
    
    /**
     * The TextEvent type.
     */
    public static final String TEXT_EVENT_TYPE = "TextEvent";
    
    /**
     * The CustomEvent type.
     */
    public static final String CUSTOM_EVENT_TYPE = "CustomEvent";

    /**
     * The Event type.
     */
    public static final String EVENT_DOM2_TYPE = "Events";
    
    /**
     * The MutationEvent type.
     */
    public static final String MUTATION_EVENT_DOM2_TYPE = "MutationEvents";
    
    /**
     * The MouseEvent type.
     */
    public static final String MOUSE_EVENT_DOM2_TYPE = "MouseEvents";

    /**
     * The UIEvent type.
     */
    public static final String UI_EVENT_DOM2_TYPE = "UIEvents";

    /**
     * The KeyEvent type.
     */
    public static final String KEY_EVENT_DOM2_TYPE = "KeyEvents";

    /**
     * The event factories table.
     */
    protected HashTable eventFactories = new HashTable();
    {
        // DOM 3 event names:
        eventFactories.put(EVENT_TYPE.toLowerCase(),
                           new SimpleEventFactory());
        eventFactories.put(MUTATION_EVENT_TYPE.toLowerCase(),
                           new MutationEventFactory());
        eventFactories.put(MUTATION_NAME_EVENT_TYPE.toLowerCase(),
                           new MutationNameEventFactory());
        eventFactories.put(MOUSE_EVENT_TYPE.toLowerCase(),
                           new MouseEventFactory());
        eventFactories.put(KEYBOARD_EVENT_TYPE.toLowerCase(),
                           new KeyboardEventFactory());
        eventFactories.put(UI_EVENT_TYPE.toLowerCase(),
                           new UIEventFactory());
        eventFactories.put(TEXT_EVENT_TYPE.toLowerCase(),
                           new TextEventFactory());
        eventFactories.put(CUSTOM_EVENT_TYPE.toLowerCase(),
                           new CustomEventFactory());
        // DOM 2 event names:
        eventFactories.put(EVENT_DOM2_TYPE.toLowerCase(),
                           new SimpleEventFactory());
        eventFactories.put(MUTATION_EVENT_DOM2_TYPE.toLowerCase(),
                           new MutationEventFactory());
        eventFactories.put(MOUSE_EVENT_DOM2_TYPE.toLowerCase(),
                           new MouseEventFactory());
        eventFactories.put(KEY_EVENT_DOM2_TYPE.toLowerCase(),
                           new KeyEventFactory());
        eventFactories.put(UI_EVENT_DOM2_TYPE.toLowerCase(),
                           new UIEventFactory());
    }

    /**
     * Creates a new Event depending on the specified parameter.
     *
     * @param eventType The <code>eventType</code> parameter specifies the 
     *   type of <code>Event</code> interface to be created.  If the 
     *   <code>Event</code> interface specified is supported by the 
     *   implementation  this method will return a new <code>Event</code> of 
     *   the interface type requested.  If the  <code>Event</code> is to be 
     *   dispatched via the <code>dispatchEvent</code> method the  
     *   appropriate event init method must be called after creation in order 
     *   to initialize the <code>Event</code>'s values.  As an example, a 
     *   user wishing to synthesize some kind of  <code>UIEvent</code> would 
     *   call <code>createEvent</code> with the parameter "UIEvent".  The  
     *   <code>initUIEvent</code> method could then be called on the newly 
     *   created <code>UIEvent</code> to set the specific type of UIEvent to 
     *   be dispatched and set its context information.The 
     *   <code>createEvent</code> method is used in creating 
     *   <code>Event</code>s when it is either  inconvenient or unnecessary 
     *   for the user to create an <code>Event</code> themselves.  In cases 
     *   where the implementation provided <code>Event</code> is 
     *   insufficient, users may supply their own <code>Event</code> 
     *   implementations for use with the <code>dispatchEvent</code> method.
     *
     * @return The newly created <code>Event</code>
     *
     * @exception DOMException
     *   NOT_SUPPORTED_ERR: Raised if the implementation does not support the 
     *   type of <code>Event</code> interface requested
     */
    public Event createEvent(String eventType)
            throws DOMException {
        EventFactory ef = (EventFactory)eventFactories.get(eventType.toLowerCase());
        if (ef == null) {
            throw new DOMException(DOMException.NOT_SUPPORTED_ERR,
                                   "Bad event type: " + eventType);
        }
        return ef.createEvent();
    }

    /**
     * Registers a new EventFactory object.
     */
    public void registerEventFactory(String eventType,
                                            EventFactory factory) {
        eventFactories.put(eventType.toLowerCase(), factory);
    }


    /**
     * This interface represents an event factory.
     */
    public interface EventFactory {
        /**
         * Creates a new Event object.
         */
        Event createEvent();
    }

    /**
     * To create a simple event.
     */
    protected static class SimpleEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMEvent();
        }
    }

    /**
     * To create a mutation event.
     */
    protected static class MutationEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMMutationEvent();
        }
    }

    /**
     * To create a mutation name event.
     */
    protected static class MutationNameEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMMutationNameEvent();
        }
    }

    /**
     * To create a mouse event.
     */
    protected static class MouseEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMMouseEvent();
        }
    }

    /**
     * To create a key event.
     */
    protected static class KeyEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMKeyEvent();
        }
    }

    /**
     * To create a keyboard event.
     */
    protected static class KeyboardEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMKeyboardEvent();
        }
    }

    /**
     * To create a UI event.
     */
    protected static class UIEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMUIEvent();
        }
    }

    /**
     * To create a Text event.
     */
    protected static class TextEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMTextEvent();
        }
    }

    /**
     * To create a Custom event.
     */
    protected static class CustomEventFactory implements EventFactory {
        /**
         * Creates a new Event object.
         */
        public Event createEvent() {
            return new DOMCustomEvent();
        }
    }
}
