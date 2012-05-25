/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.util;

import java.lang.ref.SoftReference;
import java.util.HashMap;

/**
 * This class manages a cache of soft references to objects that may
 * take some time to load or create, such as images loaded from the 
 * network.
 *
 * Adding an object is two fold: <br />
 * + First you add the key, this lets the cache know that someone is
 *   working on that key.  <br />
 * + Then when the completed object is ready you put it into the cache.<P>
 *
 * If someone requests a key after it has been added but before it has
 * been put they will be blocked until the put.
 */

public class SoftReferenceCache {
    HashMap map = new HashMap();

    /**
     * Let people create there own caches.
     */
    protected SoftReferenceCache() { }


    /**
     * Let people flush the cache (remove any cached data).  Pending
     * requests will be treated as though clear() was called on the
     * key, this should cause them to go and re-read the data.  
     */
    public synchronized void flush() {
        map.clear();
        this.notifyAll();
    }

    /**
     * Check if <tt>request(key)</tt> will return with an Object
     * (not putting you on the hook for it).  Note that it is possible
     * that this will return true but between this call and the call
     * to request the soft-reference will be cleared.  So it
     * is still possible for request to return NULL, just much less
     * likely (you can always call 'clear' in that case). 
     */
    protected final synchronized boolean isPresentImpl(Object key) {
        if (!map.containsKey(key))
            return false;

        Object o = map.get(key);
        if (o == null)  
            // It's been requested but hasn't been 'put' yet.
            return true;

        // It's been put let's make sure the soft reference hasn't
        // been cleared.
        SoftReference sr = (SoftReference)o;
        o = sr.get();
        if (o != null)
            return true;

        // Soft reference was cleared, so remove our record of key.
        clearImpl(key);
        return false;
    }

    /**
     * Check if <tt>request(key)</tt> will return immediately with the
     * Object.  Note that it is possible that this will return
     * true but between this call and the call to request the
     * soft-reference will be cleared.
     */
    protected final synchronized boolean isDoneImpl(Object key) {
        Object o = map.get(key);
        if (o == null) return false;
        SoftReference sr = (SoftReference)o;
        o = sr.get();
        if (o != null)
            return true;

        // Soft reference was cleared
        clearImpl(key);
        return false;
    }

    /**
     * If this returns null then you are now 'on the hook'.
     * to put the Object associated with key into the
     * cache.  */
    protected final synchronized Object requestImpl(Object key) {
        if (map.containsKey(key)) {

            Object o = map.get(key);
            while(o == null) {
                try {
                    // When something is cleared or put we will be notified.
                    wait();
                }
                catch (InterruptedException ie) { }

                // check if key was cleared, if so it will most likely
                // never be 'put'.
                if (!map.containsKey(key))
                    break;

                // Let's see if it was put...
                o = map.get(key);
            }
            if (o != null) {
                SoftReference sr = (SoftReference)o;
                o = sr.get();
                if (o != null)
                    return o;
            }
        }

        // So now the caller get's the hot potato.
        map.put(key, null);
        return null;
    }

    /**
     * Clear the entry for key.
     * This is the easiest way to 'get off the hook'.
     * if you didn't indend to get on it.
     */
    protected final synchronized void clearImpl(Object key) {
        map.remove(key);
        this.notifyAll();
    }

    /**
     * Associate object with key.  'object' is only referenced through
     * a soft reference so don't rely on the cache to keep it
     * around.  If the map no longer contains our url it was
     * probably cleared or flushed since we were put on the hook
     * for it, so in that case we will do nothing.
     */
    protected final synchronized void putImpl(Object key, Object object) {
        if (map.containsKey(key)) {
            SoftReference ref = new SoftRefKey(object, key);
            map.put(key, ref);
            this.notifyAll();
        }
    }

    class SoftRefKey extends CleanerThread.SoftReferenceCleared {
        Object key;
        public SoftRefKey(Object o, Object key) {
            super(o);
            this.key = key;
        }

        public void cleared() {
            SoftReferenceCache cache = SoftReferenceCache.this;
            if (cache == null) return; // Can't really happen.
            synchronized (cache) {
                Object o = cache.map.remove(key);
                if (this == o) {
                    // Notify other threads that they may have
                    // to provide this resource now.
                    cache.notifyAll(); 
                } else {
                    // Must not have been ours put it back...
                    // Can happen if a clear is done.
                    cache.map.put(key, o);
                }
 
            }
        }
    }
}
