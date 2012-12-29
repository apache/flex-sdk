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
 * This class represents a stack of HashTable objects.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: HashTableStack.java 475685 2006-11-16 11:16:05Z cam $
 */
public class HashTableStack {
    /**
     * The current link.
     */
    protected Link current = new Link(null);

    /**
     * Creates a new HashTableStack object.
     */
    public HashTableStack() {
    }

    /**
     * Pushes a new table on the stack.
     */
    public void push() {
        current.pushCount++;
    }

    /**
     * Removes the table on the top of the stack.
     */
    public void pop() {
        if (current.pushCount-- == 0) {
            current = current.next;
        }
    }

    /**
     * Creates a mapping in the table on the top of the stack.
     */
    public String put(String s, String v) {
        if (current.pushCount != 0) {
            current.pushCount--;
            current = new Link(current);
        }
        if (s.length() == 0) current.defaultStr = v;
        return (String)current.table.put(s, v);
    }
    
    /**
     * Gets an item in the table on the top of the stack.
     */
    public String get(String s) {
        if (s.length() == 0) return current.defaultStr;

        for (Link l = current; l != null; l = l.next) {
            String uri = (String)l.table.get(s);
            if (uri != null) {
                return uri;
            }
        }
        return null;
    }
        
    /**
     * To store the hashtables.
     */
    protected static class Link {
        /**
         * The table.
         */
        public HashTable table;
        
        /**
         * The next link.
         */
        public Link next;

        /**
         * The default namespace for this part of the stack.
         */
        public String defaultStr;

        /**
         * The count of pushes since this link was
         * added.
         */
        public int pushCount = 0;
        
        /**
         * Creates a new link.
         */
        public Link(Link n) {
            table = new HashTable();
            next  = n;
            if (next != null) 
                defaultStr = next.defaultStr;
        }
    }
}
