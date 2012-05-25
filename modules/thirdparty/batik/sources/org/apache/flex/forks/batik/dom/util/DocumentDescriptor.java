/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom.util;

import org.w3c.dom.Element;

import org.apache.flex.forks.batik.util.CleanerThread;

/**
 * This class contains informations about a document.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DocumentDescriptor.java,v 1.6 2005/02/22 09:13:02 cam Exp $
 */
public class DocumentDescriptor {
	    
    /**
     * The table initial capacity
     */
    protected final static int INITIAL_CAPACITY = 101;

    /**
     * The underlying array
     */
    protected Entry[] table;
	    
    /**
     * The number of entries
     */
    protected int count;
	    
    /**
     * Creates a new table.
     */
    public DocumentDescriptor() {
	table = new Entry[INITIAL_CAPACITY];
    }

    /**
     * Returns the number of elements in the document.
     */
    public int getNumberOfElements() {
	synchronized (this) {
            return count;
        }
    }
    
    /**
     * Returns the location in the source file of the end element.
     * @return zero if the information is unknown.
     */
    public int getLocationLine(Element elt) {
        synchronized (this) {
            int hash = elt.hashCode() & 0x7FFFFFFF;
            int index = hash % table.length;
	
            for (Entry e = table[index]; e != null; e = e.next) {
                if (e.hash != hash) 
                    continue;
                Object o = e.get();
                if (o == elt) 
                    return e.locationLine;
            }
        }
        return 0;
    }
    
    /**
     * Sets the location in the source file of the end element.
     */
    public void setLocationLine(Element elt, int line) {
        synchronized (this) {
            int hash  = elt.hashCode() & 0x7FFFFFFF;
            int index = hash % table.length;
	
            for (Entry e = table[index]; e != null; e = e.next) {
                if (e.hash != hash) 
                    continue;
                Object o = e.get();
                if (o == elt)
                    e.locationLine = line;
            }
	
            // The key is not in the hash table
            int len = table.length;
            if (count++ >= (len * 3) >>> 2) {
                rehash();
                index = hash % table.length;
            }
	
            Entry e = new Entry(hash, elt, line, table[index]);
            table[index] = e;
        }
    }

    /**
     * Rehash the table
     */
    protected void rehash () {
	Entry[] oldTable = table;
	
	table = new Entry[oldTable.length * 2 + 1];
	
	for (int i = oldTable.length-1; i >= 0; i--) {
	    for (Entry old = oldTable[i]; old != null;) {
		Entry e = old;
		old = old.next;
		
		int index = e.hash % table.length;
		e.next = table[index];
		table[index] = e;
	    }
	}
    }

    protected void removeEntry(Entry e) {
        synchronized (this) {
            int hash = e.hash;
            int index = hash % table.length;
            Entry curr = table[index];
            Entry prev = null;
            while (curr != e) {
                prev = curr;
                curr = curr.next;
            }
            if (curr == null) return; // already remove???

            if (prev == null)
                // First entry.
                table[index] = curr.next;
            else 
                prev.next = curr.next;
            count--;
        }
    }

    /**
     * To manage collisions
     */
    protected class Entry extends CleanerThread.WeakReferenceCleared {
	/**
	 * The hash code
	 */
	public int hash;
	
	/**
	 * The line number.
	 */
	public int locationLine;
	
	/**
	 * The next entry
	 */
	public Entry next;
	
	/**
	 * Creates a new entry
	 */
	public Entry(int hash, Element element, int locationLine, Entry next) {
            super(element);
	    this.hash         = hash;
	    this.locationLine = locationLine;
	    this.next         = next;
	}

        public void cleared() {
            removeEntry(this);
        }
    }
}
