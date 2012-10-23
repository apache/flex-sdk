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


/**
 * A set that uses two keys.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DoublyIndexedSet.java 592621 2007-11-07 05:58:12Z cam $
 */
public class DoublyIndexedSet {

    /**
     * The table to store entries.
     */
    protected DoublyIndexedTable table = new DoublyIndexedTable();

    /**
     * Dummy value object for the table.
     */
    protected static Object value = new Object();

    /**
     * Returns the number of entries in the set.
     */
    public int size() {
        return table.size();
    }

    /**
     * Adds an entry to the set.
     */
    public void add(Object o1, Object o2) {
        table.put(o1, o2, value);
    }

    /**
     * Removes an entry from the set.
     */
    public void remove(Object o1, Object o2) {
        table.remove(o1, o2);
    }

    /**
     * Returns whether the given keys are in the set.
     */
    public boolean contains(Object o1, Object o2) {
        return table.get(o1, o2) != null;
    }

    /**
     * Clears the set.
     */
    public void clear() {
        table.clear();
    }
}
