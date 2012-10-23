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
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.util.DoublyIndexedTable;

/**
 * This class is used by elements to initialize and reset their attributes.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AttributeInitializer.java 592621 2007-11-07 05:58:12Z cam $
 */
public class AttributeInitializer {

    /**
     * The list of namespaces, prefixes and names.
     */
    protected String[] keys;

    /**
     * The length of keys.
     */
    protected int length;

    /**
     * The attribute values table.
     */
    protected DoublyIndexedTable values = new DoublyIndexedTable();

    /**
     * Creates a new AttributeInitializer.
     */
    public AttributeInitializer(int capacity) {
        keys = new String[capacity * 3];
    }

    /**
     * Adds a default attribute value to the initializer.
     * @param ns The attribute namespace URI.
     * @param prefix The attribute's name prefix, or null.
     * @param ln The attribute's local name.
     * @param val The attribute's default value.
     */
    public void addAttribute(String ns, String prefix, String ln, String val) {
        int len = keys.length;
        if (length == len) {
            String[] t = new String[len * 2];
            System.arraycopy( keys, 0, t, 0, len );
            keys = t;
        }
        keys[length++] = ns;
        keys[length++] = prefix;
        keys[length++] = ln;
        values.put(ns, ln, val);
    }

    /**
     * Initializes the attributes of the given element.
     */
    public void initializeAttributes(AbstractElement elt) {
        for (int i = length - 1; i >= 2; i -= 3) {
            resetAttribute(elt, keys[i - 2], keys[i - 1], keys[i]);
        }
    }

    /**
     * Resets an attribute of the given element to its default value.
     * @param elt The element to modify.
     * @param ns The attribute namespace URI.
     * @param prefix The attribute's name prefix.
     * @param ln The attribute's local name.
     * @return true if a default value is known for the given attribute and
     *         if it was resetted.
     */
    public boolean resetAttribute(AbstractElement elt,
                                  String ns, String prefix, String ln) {
        String val = (String)values.get(ns, ln);
        if (val == null) {
            return false;
        }
        if (prefix != null) {
            ln = prefix + ':' + ln;
        }
        elt.setUnspecifiedAttribute(ns, ln, val);
        return true;
    }
}
