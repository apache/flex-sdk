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
package org.apache.flex.forks.batik.transcoder;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * The <tt>TranscodingHints</tt> class defines a way to pass
 * transcoding parameters or options to any transcoders.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: TranscodingHints.java 588550 2007-10-26 07:52:41Z dvholten $
 */
public class TranscodingHints extends HashMap {

    /**
     * Constructs a new empty <tt>TranscodingHints</tt>.
     */
    public TranscodingHints() {
        this(null);
    }

    /**
     * Constructs a new <tt>TranscodingHints</tt> with keys and values
     * initialized from the specified Map object (which may be null).
     *
     * @param init a map of key/value pairs to initialize the hints
     *          or null if the object should be empty
     */
    public TranscodingHints(Map init) {
        super(7);
        if (init != null) {
            putAll(init);
        }
    }

    /**
     * Returns <tt>true</tt> if this <tt>TranscodingHints</tt> contains a
     * mapping for the specified key, false otherwise.
     *
     * @param key key whose present in this <tt>TranscodingHints</tt>
     * is to be tested.
     * @exception ClassCastException key is not of type
     * <tt>TranscodingHints.Key</tt>
     */
    public boolean containsKey(Object key) {
        return super.containsKey(key);
    }

    /**
     * Returns the value to which the specified key is mapped.
     *
     * @param key a trancoding hint key
     * @exception ClassCastException key is not of type
     * <tt>TranscodingHints.Key</tt>
     */
    public Object get(Object key) {
        return super.get(key);
    }

    /**
     * Maps the specified <tt>key</tt> to the specified <tt>value</tt>
     * in this <tt>TranscodingHints</tt> object.
     *
     * @param key the trancoding hint key.
     * @param value the trancoding hint value.
     * @exception IllegalArgumentException value is not
     * appropriate for the specified key.
     * @exception ClassCastException key is not of type
     * <tt>TranscodingHints.Key</tt>
     */
    public Object put(Object key, Object value) {
        if (!((Key) key).isCompatibleValue(value)) {
            throw new IllegalArgumentException(value+
                                               " incompatible with "+
                                               key);
        }
        return super.put(key, value);
    }

    /**
     * Removes the key and its corresponding value from this
     * <tt>TranscodingHints</tt> object.
     *
     * @param key the trancoding hints key that needs to be removed
     * @exception ClassCastException key is not of type
     * <tt>TranscodingHints.Key</tt>
     */
    public Object remove(Object key) {
        return super.remove(key);
    }

    /**
     * Copies all of the keys and corresponding values from the
     * specified <tt>TranscodingHints</tt> object to this
     * <tt>TranscodingHints</tt> object.
     */
    public void putAll(TranscodingHints hints) {
        super.putAll(hints);
    }

    /**
     * Copies all of the mappings from the specified <tt>Map</tt>
     * to this <tt>TranscodingHints</tt>.
     *
     * @param m mappings to be stored in this <tt>TranscodingHints</tt>.
     * @exception ClassCastException key is not of type
     * <tt>TranscodingHints.Key</tt>
     */
    public void putAll(Map m) {
        if (m instanceof TranscodingHints) {
            putAll(((TranscodingHints) m));
        } else {
            Iterator iter = m.entrySet().iterator();
            while (iter.hasNext()) {
                Map.Entry entry = (Map.Entry) iter.next();
                put(entry.getKey(), entry.getValue());
            }
        }
    }

    /**
     * Defines the base type of all keys used to control various
     * aspects of the transcoding operations.
     */
    public abstract static class Key {

        /**
         * Constructs a key.
         */
        protected Key() { }

        /**
         * Returns true if the specified object is a valid value for
         * this key, false otherwise.
         */
        public abstract boolean isCompatibleValue(Object val);
    }
}
