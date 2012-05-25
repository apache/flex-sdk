/*

   Copyright 2000-2002  The Apache Software Foundation 

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

import org.w3c.dom.events.EventListener;

/**
 * A simple list of EventListener. Listeners are always added at the
 * head of the list.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 */
public class EventListenerList {

    /**
     * Current number of entries in list.
     */
    protected int              n         = 0;
    /**
     * Simple Linked list of listeners.
     */
    protected Entry            first     = null;
    /**
     * Array of listeners retained between calls to getEventListeners if the
     * list of listeners doesn't change.  This needs to be a copy so if the
     * list of listeners changes during event dispatch it doesn't effect
     * the inprogress dispatch.
     */
    protected EventListener [] listeners = null;

    /**
     * Returns an array of the event listeners of this list, or null if any.
     */
    public EventListener [] getEventListeners() {
	if (first == null)     return null;
        if (listeners != null) return listeners;

	listeners = new EventListener[n];
	Entry current = first;
	for (int i=0; i < n; ++i, current = current.next) {
	    listeners[i] = current.listener;
	}
	return listeners;
    }

    /**
     * Adds the specified event listener.
     * @param listener the event listener to add
     */
    public void add(EventListener listener) {
	first = new Entry(listener, first);
        listeners = null; // Clear current listener list.
	n++;
    }

    /**
     * Removes the specified event listener.
     * @param listener the event listener to remove
     */
    public void remove(EventListener listener) {
	if (first == null) return;


        if (first.listener == listener) {
	    first = first.next;
            listeners = null; // Clear current listener list.
	    --n;
	} else {
	    Entry prev = first;
	    Entry e = first.next;
	    while (e != null) {
                if (e.listener == listener) {
                    prev.next = e.next;
                    listeners = null; // Clear current listener list.
                    --n;
                    break;
                }
		prev = e;
		e = e.next;
	    }
	}
    }

    /**
     * Returns true of the specified event listener has already been
     * added to this list, false otherwise.
     * @param listener the listener th check
     */
    public boolean contains(EventListener listener) {
	for (Entry e=first; e != null; e = e.next) {
	    if (listener == e.listener)
		return true;
	}
	return false;
    }

    /**
     * Returns the number of listeners in the list.
     */
    public int size() {
        return n;
    }

    // simple entry for the list
    protected static class Entry {
	EventListener listener;
	Entry         next;

	public Entry(EventListener listener, Entry next) {
	    this.listener = listener;
	    this.next = next;
	}
    }
}
