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
package org.apache.flex.forks.batik.css.engine;

/**
 * A simple hashtable, not synchronized, with fixed load factor.
 * Keys are Strings and values are ints.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StringIntMap.java 489226 2006-12-21 00:05:36Z cam $
 */
public class StringIntMap {

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
     * @param c The capacity of the table.
     */
    public StringIntMap(int c) {
        // the table is set to 75% of the requested size
        table = new Entry[( c - ( c >> 2)) + 1];
    }

    /**
     * Gets the value corresponding to the given string.
     * @return the value or -1.
     */
    public int get( String key ) {
        int hash = key.hashCode() & 0x7FFFFFFF;
        int index = hash % table.length;

        for ( Entry e = table[ index ]; e != null; e = e.next ) {
            if ( ( e.hash == hash ) && e.key.equals( key ) ) {
                return e.value;
            }
        }
        return -1;
    }

    /**
     * Sets a new value for the given variable
     */
    public void put( String key, int value ) {
        int hash = key.hashCode() & 0x7FFFFFFF;
        int index = hash % table.length;

        for ( Entry e = table[ index ]; e != null; e = e.next ) {
            if ( ( e.hash == hash ) && e.key.equals( key ) ) {
                e.value = value;
                return;
            }
        }

        // The key is not in the hash table
        int len = table.length;
        if ( count++ >= ( len - ( len >> 2 ) ) ) {
            // more than 75% loaded: grow
            rehash();
            index = hash % table.length;
        }

        Entry e = new Entry( hash, key, value, table[ index ] );
        table[ index ] = e;
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
     * To manage collisions
     */
    protected static class Entry {

        /**
         * The hash code, must not change after init.
         */
        public final int hash;

        /**
         * The key
         */
        public String key;

        /**
         * The value, not changed after creation.
         */
        public int value;

        /**
         * The next entry - changed, when table[] is reordered.
         */
        public Entry next;

        /**
         * Creates a new entry
         */
        public Entry( int hash, String key, int value, Entry next ) {
            this.hash  = hash;
            this.key   = key;
            this.value = value;
            this.next  = next;
        }
    }
}
