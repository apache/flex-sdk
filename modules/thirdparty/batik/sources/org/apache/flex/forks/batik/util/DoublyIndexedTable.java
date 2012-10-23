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
package org.apache.flex.forks.batik.util;

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * This class represents a doubly indexed hash table.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DoublyIndexedTable.java 592621 2007-11-07 05:58:12Z cam $
 */
public class DoublyIndexedTable {

    /**
     * The initial capacity
     */
    protected int initialCapacity;

    /**
     * The underlying array
     */
    protected Entry[] table;

    /**
     * The number of entries
     */
    protected int count;

    /**
     * Creates a new DoublyIndexedTable.
     */
    public DoublyIndexedTable() {
        this(16);
    }

    /**
     * Creates a new DoublyIndexedTable.
     * @param c The inital capacity.
     */
    public DoublyIndexedTable(int c) {
        initialCapacity = c;
        table = new Entry[c];
    }

    /**
     * Creates a new DoublyIndexedTable initialized to contain all of
     * the entries of the specified other DoublyIndexedTable.
     */
    public DoublyIndexedTable(DoublyIndexedTable other) {
        initialCapacity = other.initialCapacity;
        table = new Entry[other.table.length];
        for (int i = 0; i < other.table.length; i++) {
            Entry newE = null;
            Entry e = other.table[i];
            while (e != null) {
                newE = new Entry(e.hash, e.key1, e.key2, e.value, newE);
                e = e.next;
            }
            table[i] = newE;
        }
        count = other.count;
    }
    
    /**
     * Returns the size of this table.
     */
    public int size() {
        return count;
    }

    /**
     * Puts a value in the table.
     * @return the old value or null
     */
    public Object put(Object o1, Object o2, Object value) {
        int hash  = hashCode(o1, o2) & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if ((e.hash == hash) && e.match(o1, o2)) {
                Object old = e.value;
                e.value = value;
                return old;
            }
        }

        // The key is not in the hash table
        int len = table.length;
        if (count++ >= (len - (len >> 2))) {
            // more than 75% loaded: grow
            rehash();
            index = hash % table.length;
        }

        Entry e = new Entry(hash, o1, o2, value, table[index]);
        table[index] = e;
        return null;
    }

    /**
     * Gets the value of an entry
     * @return the value or null
     */
    public Object get(Object o1, Object o2) {
        int hash  = hashCode(o1, o2) & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if ((e.hash == hash) && e.match(o1, o2)) {
                return e.value;
            }
        }
        return null;
    }

    /**
     * Removes an entry from the table.
     * @return the value or null
     */
    public Object remove(Object o1, Object o2) {
        int hash  = hashCode(o1, o2) & 0x7FFFFFFF;
        int index = hash % table.length;

        Entry e = table[index];
        if (e == null) {
            return null;
        }

        if (e.hash == hash && e.match(o1, o2)) {
            table[index] = e.next;
            count--;
            return e.value;
        }

        Entry prev = e;
        for (e = e.next; e != null; prev = e, e = e.next) {
            if (e.hash == hash && e.match(o1, o2)) {
                prev.next = e.next;
                count--;
                return e.value;
            }
        }
        return null;
    }

    /**
     * Returns an array of all of the values in the table.
     */
    public Object[] getValuesArray() {
        Object[] values = new Object[count];
        int i = 0;

        for (int index = 0; index < table.length; index++) {
            for (Entry e = table[index]; e != null; e = e.next) {
                values[i++] = e.value;
            }
        }
        return values;
    }

    /**
     * Clears the table.
     */
    public void clear() {
        table = new Entry[initialCapacity];
        count = 0;
    }

    /**
     * Returns an iterator on the entries of the table.
     */
    public Iterator iterator() {
        return new TableIterator();
    }

    /**
     * Rehash the table
     */
    protected void rehash() {
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

    /**
     * Computes a hash code corresponding to the given objects.
     */
    protected int hashCode(Object o1, Object o2) {
        int result = (o1 == null) ? 0 : o1.hashCode();
        return result ^ ((o2 == null) ? 0 : o2.hashCode());
    }

    /**
     * An entry in the {@link DoublyIndexedTable}.
     */
    public static class Entry {

        /**
         * The hash code.
         */
        protected int hash;

        /**
         * The first key.
         */
        protected Object key1;

        /**
         * The second key.
         */
        protected Object key2;

        /**
         * The value.
         */
        protected Object value;

        /**
         * The next entry.
         */
        protected Entry next;

        /**
         * Creates a new entry.
         */
        public Entry(int hash, Object key1, Object key2, Object value,
                     Entry next) {
            this.hash  = hash;
            this.key1  = key1;
            this.key2  = key2;
            this.value = value;
            this.next  = next;
        }

        /**
         * Returns this entry's first key.
         */
        public Object getKey1() {
            return key1;
        }

        /**
         * Returns this entry's second key.
         */
        public Object getKey2() {
            return key2;
        }

        /**
         * Returns this entry's value.
         */
        public Object getValue() {
            return value;
        }

        /**
         * Whether this entry match the given keys.
         */
        protected boolean match(Object o1, Object o2) {
            if (key1 != null) {
                if (!key1.equals(o1)) {
                    return false;
                }
            } else if (o1 != null) {
                return false;
            }
            if (key2 != null) {
                return key2.equals(o2);
            }
            return o2 == null;
        }
    }

    /**
     * An Iterator class for a {@link DoublyIndexedTable}.
     */
    protected class TableIterator implements Iterator {

        /**
         * The index of the next entry to return.
         */
        private int nextIndex;

        /**
         * The next Entry to return.
         */
        private Entry nextEntry;

        /**
         * Whether the Iterator has run out of elements.
         */
        private boolean finished;

        /**
         * Creates a new TableIterator.
         */
        public TableIterator() {
            while (nextIndex < table.length) {
                nextEntry = table[nextIndex];
                if (nextEntry != null) {
                    break;
                }
                nextIndex++;
            }
            finished = nextEntry == null;
        }

        public boolean hasNext() {
            return !finished;
        }

        public Object next() {
            if (finished) {
                throw new NoSuchElementException();
            }
            Entry ret = nextEntry;
            findNext();
            return ret;
        }

        /**
         * Searches for the next Entry in the table.
         */
        protected void findNext() {
            nextEntry = nextEntry.next;
            if (nextEntry == null) {
                nextIndex++;
                while (nextIndex < table.length) {
                    nextEntry = table[nextIndex];
                    if (nextEntry != null) {
                        break;
                    }
                    nextIndex++;
                }
            }
            finished = nextEntry == null;
        }

        public void remove() {
            throw new UnsupportedOperationException();
        }
    }
}
