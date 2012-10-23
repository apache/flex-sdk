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

import org.apache.flex.forks.batik.dom.util.IntTable;
import org.apache.flex.forks.batik.dom.util.HashTable;

import org.w3c.dom.events.EventListener;

/**
 * Class to manager event listeners for one event type.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: EventListenerList.java 579851 2007-09-26 23:49:35Z cam $
 */
public class EventListenerList {

    /**
     * Total number of event listners.
     */
    protected int n;

    /**
     * Linked list of entries.
     */
    protected Entry head;

    /**
     * Counts of listener entries with a given namespace URI.
     */
    protected IntTable counts = new IntTable();

    /**
     * Cache of listeners with any namespace URI.
     */
    protected Entry[] listeners;

    /**
     * Caches of listeners with a given namespace URI.
     */
    protected HashTable listenersNS = new HashTable();

    /**
     * Adds a listener.
     */
    public void addListener(String namespaceURI,
                            Object group,
                            EventListener listener) {
        for (Entry e = head; e != null; e = e.next) {
            if ((namespaceURI != null && namespaceURI.equals(e.namespaceURI)
                        || namespaceURI == null && e.namespaceURI == null)
                    && e.listener == listener) {
                // Listener is already in the list, so do nothing.
                return;
            }
        }
        head = new Entry(listener, namespaceURI, group, head);
        counts.inc(namespaceURI);
        n++;
        listeners = null;
        listenersNS.remove(namespaceURI);
    }

    /**
     * Removes a listener.
     */
    public void removeListener(String namespaceURI,
                               EventListener listener) {
        if (head == null) {
            return;
        } else if (head != null
                && (namespaceURI != null && namespaceURI.equals(head.namespaceURI)
                    || namespaceURI == null && head.namespaceURI == null)
                && listener == head.listener) {
            head = head.next;
        } else {
            Entry e;
            Entry prev = head;
            for (e = head.next; e != null; e = e.next) {
                if ((namespaceURI != null && namespaceURI.equals(e.namespaceURI)
                            || namespaceURI == null && e.namespaceURI == null)
                        && e.listener == listener) {
                    prev.next = e.next;
                    break;
                }
                prev = e;
            }
            if (e == null) {
                // Listener not present.
                return;
            }
        }
        counts.dec(namespaceURI);
        n--;
        listeners = null;
        listenersNS.remove(namespaceURI);
    }

    /**
     * Returns an array containing all event listener entries.
     */
    public Entry[] getEventListeners() {
        if (listeners != null) {
            return listeners;
        }
        listeners = new Entry[n];
        int i = 0;
        for (Entry e = head; e != null; e = e.next) {
            listeners[i++] = e;
        }
        return listeners;
    }

    /**
     * Returns an array of EventListeners that match the given namespace URI.
     */
    public Entry[] getEventListeners(String namespaceURI) {
        if (namespaceURI == null) {
            return getEventListeners();
        }
        Entry[] ls = (Entry[]) listenersNS.get(namespaceURI);
        if (ls != null) {
            return ls;
        }
        int count = counts.get(namespaceURI);
        if (count == 0) {
            return null;
        }
        ls = new Entry[count];
        listenersNS.put(namespaceURI, ls);
        int i = 0;
        for (Entry e = head; i < count; e = e.next) {
            if (namespaceURI.equals(e.namespaceURI)) {
                ls[i++] = e;
            }
        }
        return ls;
    }

    /**
     * Returns whether there is an event listener for the given namespace URI.
     */
    public boolean hasEventListener(String namespaceURI) {
        if (namespaceURI == null) {
            return n != 0;
        }
        return counts.get(namespaceURI) != 0;
    }

    /**
     * Returns the number of event listeners stored in this object.
     */
    public int size() {
        return n;
    }

    /**
     * EventListenerTable entry class.
     */
    public class Entry {
        
        /**
         * The event listener.
         */
        protected EventListener listener;

        /**
         * The namespace URI of the event the listener is listening for.
         */
        protected String namespaceURI;

        /**
         * The event group.
         */
        protected Object group;

        /**
         * Flag used by getListeners.
         */
        protected boolean mark;

        /**
         * The next Entry in the list.
         */
        protected Entry next;

        /**
         * Creates a new Entry object.
         */
        public Entry(EventListener listener,
                     String namespaceURI,
                     Object group,
                     Entry next) {
            this.listener = listener;
            this.namespaceURI = namespaceURI;
            this.group = group;
            this.next = next;
        }

        /**
         * Returns the event listener.
         */
        public EventListener getListener() {
            return listener;
        }

        /**
         * Returns the event group.
         */
        public Object getGroup() {
            return group;
        }

        /**
         * Returns the event namespace URI.
         */
        public String getNamespaceURI() {
            return namespaceURI;
        }
    }
}
