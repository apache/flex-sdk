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

import java.io.Serializable;

/**
 * A simple hashtable, not synchronized, with fixed load factor,
 * that maps objects to ints.
 * This implementation is not Thread-safe.
 * 
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: IntTable.java 489226 2006-12-21 00:05:36Z cam $
 */
public class IntTable implements Serializable {

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
     * Creates a new table.
     */
    public IntTable() {
        table = new Entry[INITIAL_CAPACITY];
    }

    /**
     * Creates a new table.
     * @param c The initial capacity.
     */
    public IntTable(int c) {
        table = new Entry[c];
    }

    /**
     * Creates a copy of the given HashTable object.
     * @param t The table to copy.
     */
    public IntTable(IntTable t) {
        count = t.count;
        table = new Entry[t.table.length];
        for (int i = 0; i < table.length; i++) {
            Entry e = t.table[i];
            Entry n = null;
            if (e != null) {
                n = new Entry(e.hash, e.key, e.value, null);
                table[i] = n;
                e = e.next;
                while (e != null) {
                    n.next = new Entry(e.hash, e.key, e.value, null);
                    n = n.next;
                    e = e.next;
                }
            }
        }
    }

    /**
     * Returns the size of this table.
     */
    public int size() {
        return count;
    }

    /**
     * Finds the Entry with the given key.
     */
    protected Entry find(Object key) {
        return null;
    }

    /**
     * Returns the value associated with the given key.
     */
    public int get(Object key) {
        int hash  = key == null ? 0 : key.hashCode() & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if (e.hash == hash
                    && (e.key == null && key == null
                        || e.key != null && e.key.equals(key))) {
                return e.value;
            }
        }

        return 0;
    }

    /**
     * Sets the value associated with the given key.
     */
    public int put(Object key, int value) {
        int hash  = key == null ? 0 : key.hashCode() & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if (e.hash == hash
                    && (e.key == null && key == null
                        || e.key != null && e.key.equals(key))) {
                int old = e.value;
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

        table[index] = new Entry(hash, key, value, table[index]);
        return 0;
    }

    /**
     * Increments the value associated with the given key.
     */
    public int inc(Object key) {
        int hash  = key == null ? 0 : key.hashCode() & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if (e.hash == hash
                    && (e.key == null && key == null
                        || e.key != null && e.key.equals(key))) {
                return e.value++;
            }
        }

        // The key is not in the hash table
        int len = table.length;
        if (count++ >= (len - (len >> 2))) {
            // more than 75% loaded: grow
            rehash();
            index = hash % table.length;
        }

        table[index] = new Entry(hash, key, 1, table[index]);
        return 0;
    }

    /**
     * Decrements the value associated with the given key.
     */
    public int dec(Object key) {
        int hash  = key == null ? 0 : key.hashCode() & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if (e.hash == hash
                    && (e.key == null && key == null
                        || e.key != null && e.key.equals(key))) {
                return e.value--;
            }
        }

        // The key is not in the hash table
        int len = table.length;
        if (count++ >= (len - (len >> 2))) {
            // more than 75% loaded: grow
            rehash();
            index = hash % table.length;
        }

        table[index] = new Entry(hash, key, -1, table[index]);
        return 0;
    }

    /**
     * Removes an entry from the table.
     */
    public int remove(Object key) {
        int hash  = key == null ? 0 : key.hashCode() & 0x7FFFFFFF;
        int index = hash % table.length;

        Entry p = null;
        for (Entry e = table[index]; e != null; e = e.next) {
            if (e.hash == hash
                    && (e.key == null && key == null
                        || e.key != null && e.key.equals(key))) {
                int result = e.value;
                if (p == null) {
                    table[index] = e.next;
                } else {
                    p.next = e.next;
                }
                count--;
                return result;
            }
            p = e;
        }
        return 0;
    }

    /**
     * Clears the table.
     */
    public void clear() {
        for (int i = 0; i < table.length; i++) {
            table[i] = null;
        }
        count = 0;
    }

    /**
     * Rehashes the table.
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
     * To manage collisions.
     */
    protected static class Entry implements Serializable {

        /**
         * The hash code.
         */
        public int hash;

        /**
         * The key.
         */
        public Object key;

        /**
         * The value.
         */
        public int value;

        /**
         * The next entry
         */
        public Entry next;

        /**
         * Creates a new Entry object.
         */
        public Entry(int hash, Object key, int value, Entry next) {
            this.hash  = hash;
            this.key   = key;
            this.value = value;
            this.next  = next;
        }
    }
}
