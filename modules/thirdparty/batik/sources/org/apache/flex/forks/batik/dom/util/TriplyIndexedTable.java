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
package org.apache.flex.forks.batik.dom.util;

/**
 * This class represents a triply indexed hash table.
 * <br>Note: This implementation is not Thread-safe.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: TriplyIndexedTable.java 489226 2006-12-21 00:05:36Z cam $
 */
public class TriplyIndexedTable {

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
     * Creates a new TriplyIndexedTable.
     */
    public TriplyIndexedTable() {
        table = new Entry[INITIAL_CAPACITY];
    }

    /**
     * Creates a new TriplyIndexedTable.
     * @param c The inital capacity.
     */
    public TriplyIndexedTable(int c) {
        table = new Entry[c];
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
    public Object put(Object o1, Object o2, Object o3, Object value) {
        int hash  = hashCode(o1, o2, o3) & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if ((e.hash == hash) && e.match(o1, o2, o3)) {
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

        Entry e = new Entry(hash, o1, o2, o3, value, table[index]);
        table[index] = e;
        return null;
    }

    /**
     * Gets the value of an entry
     * @return the value or null
     */
    public Object get(Object o1, Object o2, Object o3) {
        int hash  = hashCode(o1, o2, o3) & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if ((e.hash == hash) && e.match(o1, o2, o3)) {
                return e.value;
            }
        }
        return null;
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
    protected int hashCode(Object o1, Object o2, Object o3) {
        return (o1 == null ? 0 : o1.hashCode())
             ^ (o2 == null ? 0 : o2.hashCode())
             ^ (o3 == null ? 0 : o3.hashCode());
    }

    /**
     * To manage collisions
     */
    protected static class Entry {
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
         * The third key
         */
        public Object key3;

        /**
         * The value
         */
        public Object value;

        /**
         * The next entry
         */
        public Entry next;

        /**
         * Creates a new entry
         */
        public Entry(int hash, Object key1, Object key2, Object key3,
                     Object value, Entry next) {
            this.hash  = hash;
            this.key1  = key1;
            this.key2  = key2;
            this.key3  = key3;
            this.value = value;
            this.next  = next;
        }

        /**
         * Whether this entry matches the given keys.
         */
        public boolean match(Object o1, Object o2, Object o3) {
            if (key1 != null) {
                if (!key1.equals(o1)) {
                    return false;
                }
            } else if (o1 != null) {
                return false;
            }
            if (key2 != null) {
                if (!key2.equals(o2)) {
                    return false;
                }
            } else if (o2 != null) {
                return false;
            }
            if (key3 != null) {
                return key3.equals(o3);
            }
            return o3 == null;
        }
    }
}
