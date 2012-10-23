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
package org.apache.flex.forks.batik.gvt.font;

import java.awt.Shape;
import java.awt.geom.Rectangle2D;
import java.lang.ref.ReferenceQueue;
import java.lang.ref.SoftReference;

/**
 * This class represents a doubly indexed hash table, which holds
 * soft references to the contained glyph geometry informations.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @author <a href="mailto:tkormann@ilog.fr">Thierry Kormann</a>
 * @version $Id: AWTGlyphGeometryCache.java 489226 2006-12-21 00:05:36Z cam $
 */
public class AWTGlyphGeometryCache {

    /**
     * The initial capacity
     */
    protected static final int INITIAL_CAPACITY = 71;

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
     * Creates a new AWTGlyphGeometryCache.
     */
    public AWTGlyphGeometryCache() {
        table = new Entry[INITIAL_CAPACITY];
    }

    /**
     * Creates a new AWTGlyphGeometryCache.
     * @param c The inital capacity.
     */
    public AWTGlyphGeometryCache(int c) {
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
    public Value get(char c) {
        int hash  = hashCode(c) & 0x7FFFFFFF;
        int index = hash % table.length;

        for (Entry e = table[index]; e != null; e = e.next) {
            if ((e.hash == hash) && e.match(c)) {
                return (Value)e.get();
            }
        }
        return null;
    }

    /**
     * Sets a new value for the given variable
     * @return the old value or null
     */
    public Value put(char c, Value value) {
        removeClearedEntries();

        int hash  = hashCode(c) & 0x7FFFFFFF;
        int index = hash % table.length;

        Entry e = table[index];
        if (e != null) {
            if ((e.hash == hash) && e.match(c)) {
                Object old = e.get();
                table[index] = new Entry(hash, c, value, e.next);
                return (Value)old;
            }
            Entry o = e;
            e = e.next;
            while (e != null) {
                if ((e.hash == hash) && e.match(c)) {
                    Object old = e.get();
                    e = new Entry(hash, c, value, e.next);
                    o.next = e;
                    return (Value)old;
                }

                o = e;
                e = e.next;
            }
        }

        // The key is not in the hash table
        int len = table.length;
        if (count++ >= (len - (len >> 2))) {
            // more than 75% loaded: grow
            rehash();
            index = hash % table.length;
        }

        table[index] = new Entry(hash, c, value, table[index]);
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

    /**
     * Computes a hash code corresponding to the given objects.
     */
    protected int hashCode(char c) {
        return c;
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
     * The object that holds glyph geometry.
     */
    public static class Value {

        protected Shape outline;
        protected Rectangle2D gmB;
        protected Rectangle2D outlineBounds;

        /**
         * Constructs a new Value with the specified parameter.
         */
        public Value(Shape outline, Rectangle2D gmB) {
            this.outline = outline;
            this.outlineBounds = outline.getBounds2D();
            this.gmB = gmB;
        }

        /**
         * Returns the outline of the glyph.
         */
        public Shape getOutline() {
            return outline;
        }

        /**
         * Returns the bounds of the glyph according to its glyph metrics.
         */
        public Rectangle2D getBounds2D() {
            return gmB;
        }

        /**
         * Returns the bounds of the outline.
         */
        public Rectangle2D getOutlineBounds2D() {
            return outlineBounds;
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
         * The character
         */
        public char c;

        /**
         * The next entry
         */
        public Entry next;

        /**
         * Creates a new entry
         */
        public Entry(int hash, char c, Value value, Entry next) {
            super(value, referenceQueue);
            this.hash  = hash;
            this.c  = c;
            this.next  = next;
        }

        /**
         * Whether this entry match the given keys.
         */
        public boolean match(char o2) {
            return (c == o2);
        }
    }
}
