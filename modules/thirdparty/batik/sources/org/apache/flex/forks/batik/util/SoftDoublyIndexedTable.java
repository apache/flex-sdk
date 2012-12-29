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

import java.lang.ref.ReferenceQueue;
import java.lang.ref.SoftReference;

/**
 * This class represents a doubly indexed hash table, which holds
 * soft references to the contained values.
 * <br>This HashMap is not Thread-safe.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SoftDoublyIndexedTable.java 489226 2006-12-21 00:05:36Z cam $
 */
public class SoftDoublyIndexedTable {

    /**
     * The initial capacity
     */
    protected static final int INITIAL_CAPACITY = 11;

    /**
     * The underlying array
     */
    protected Entry[] table;

    /**
     * The number of entries
     */
    protected int count;

    /**
     * The reference queue.
     */
    protected ReferenceQueue referenceQueue = new ReferenceQueue();

    /**
     * Creates a new SoftDoublyIndexedTable.
     */
    public SoftDoublyIndexedTable() {
        table = new Entry[INITIAL_CAPACITY];
    }

    /**
     * Creates a new DoublyIndexedTable.
     * @param c The inital capacity.
     */
    public SoftDoublyIndexedTable(int c) {
        table = new Entry[c];
    }

    /**
     * Returns the size of this table.
     */
    public int size() {
        return count;
    }

    /**
     * Gets the value of a variable
     * @return the value or null
     */
    public Object get( Object o1, Object o2 ) {
        int hash = hashCode( o1, o2 ) & 0x7FFFFFFF;
        int index = hash % table.length;

        for ( Entry e = table[ index ]; e != null; e = e.next ) {
            if ( ( e.hash == hash ) && e.match( o1, o2 ) ) {
                return e.get();
            }
        }
        return null;
    }

    /**
     * Sets a new value for the given variable
     * @return the old value or null
     */
    public Object put( Object o1, Object o2, Object value ) {
        removeClearedEntries();

        int hash = hashCode( o1, o2 ) & 0x7FFFFFFF;
        int index = hash % table.length;

        Entry e = table[ index ];
        if ( e != null ) {
            if ( ( e.hash == hash ) && e.match( o1, o2 ) ) {
                Object old = e.get();
                table[ index ] = new Entry( hash, o1, o2, value, e.next );
                return old;
            }
            Entry o = e;
            e = e.next;
            while ( e != null ) {
                if ( ( e.hash == hash ) && e.match( o1, o2 ) ) {
                    Object old = e.get();
                    e = new Entry( hash, o1, o2, value, e.next );
                    o.next = e;
                    return old;
                }

                o = e;
                e = e.next;
            }
        }

        // The key is not in the hash table
        int len = table.length;
        if ( count++ >= ( len - ( len >> 2 ) ) ) {
            // more than 75% loaded: grow
            rehash();
            index = hash % table.length;
        }

        table[ index ] = new Entry( hash, o1, o2, value, table[ index ] );
        return null;
    }

    /**
     * Clears the table.
     */
    public void clear() {
        table = new Entry[INITIAL_CAPACITY];
        count = 0;
        referenceQueue = new ReferenceQueue();
    }

    /**
     * Rehash the table
     */
    protected void rehash() {
        Entry[] oldTable = table;

        table = new Entry[oldTable.length * 2 + 1];

        for ( int i = oldTable.length - 1; i >= 0; i-- ) {
            for ( Entry old = oldTable[ i ]; old != null; ) {
                Entry e = old;
                old = old.next;

                int index = e.hash % table.length;
                e.next = table[ index ];
                table[ index ] = e;
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
     * Removes the cleared entries.
     */
    protected void removeClearedEntries() {
        Entry e;
        while ((e = (Entry)referenceQueue.poll()) != null) {
            int index = e.hash % table.length;
            Entry t = table[index];
            if (t == e) {
                table[index] = e.next;
            } else {
                loop: for (;t!=null;) {
                    Entry c = t.next;
                    if (c == e) {
                        t.next = e.next;
                        break loop;
                    }
                    t = c;
                }
            }
            count--;
        }
    }

    /**
     * To manage collisions
     */
    protected class Entry extends SoftReference {

        /**
         * The hash code
         */
        public int hash;

        /**
         * The first key
         */
        public Object key1;

        /**
         * The second key
         */
        public Object key2;

        /**
         * The next entry
         */
        public Entry next;

        /**
         * Creates a new entry
         */
        public Entry( int hash, Object key1, Object key2, Object value, Entry next ) {
            super( value, referenceQueue );
            this.hash = hash;
            this.key1 = key1;
            this.key2 = key2;
            this.next = next;
        }

        /**
         * Whether this entry match the given keys.
         */
        public boolean match( Object o1, Object o2 ) {
            if ( key1 != null ) {
                if ( !key1.equals( o1 ) ) {
                    return false;
                }
            } else if ( o1 != null ) {
                return false;
            }
            if ( key2 != null ) {
                return key2.equals( o2 );
            }
            return o2 == null;
        }
    }
}
