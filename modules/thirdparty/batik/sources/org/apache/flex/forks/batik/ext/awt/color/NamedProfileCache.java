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

package org.apache.flex.forks.batik.ext.awt.color;

import org.apache.flex.forks.batik.util.SoftReferenceCache;

/**
 * This class manages a cache of soft references to named profiles that
 * we have already loaded. 
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: NamedProfileCache.java 475477 2006-11-15 22:44:28Z cam $
 */
public class NamedProfileCache extends SoftReferenceCache {

    static NamedProfileCache theCache = new NamedProfileCache();

    public static NamedProfileCache getDefaultCache() { return theCache; }

    /**
     * Let people create there own caches.
     */
    public NamedProfileCache() { }

    /**
     * Check if <tt>request(profileName)</tt> will return with a ICCColorSpaceExt
     * (not putting you on the hook for it).  Note that it is possible
     * that this will return true but between this call and the call
     * to request the soft-reference will be cleared.  So it
     * is still possible for request to return NULL, just much less
     * likely (you can always call 'clear' in that case). 
     */
    public synchronized boolean isPresent(String profileName) {
        return super.isPresentImpl(profileName);
    }

    /**
     * Check if <tt>request(profileName)</tt> will return immediately with the
     * ICCColorSpaceExt.  Note that it is possible that this will return
     * true but between this call and the call to request the
     * soft-reference will be cleared.
     */
    public synchronized boolean isDone(String profileName) {
        return super.isDoneImpl(profileName);
    }

    /**
     * If this returns null then you are now 'on the hook'.
     * to put the ICCColorSpaceExt associated with String into the
     * cache.  */
    public synchronized ICCColorSpaceExt request(String profileName) {
        return (ICCColorSpaceExt)super.requestImpl(profileName);
    }

    /**
     * Clear the entry for String.
     * This is the easiest way to 'get off the hook'.
     * if you didn't indend to get on it.
     */
    public synchronized void clear(String profileName) {
        super.clearImpl(profileName);
    }

    /**
     * Associate bi with profileName.  bi is only referenced through
     * a soft reference so don't rely on the cache to keep it
     * around.  If the map no longer contains our profileName it was
     * probably cleared or flushed since we were put on the hook
     * for it, so in that case we will do nothing.
     */
    public synchronized void put(String profileName, ICCColorSpaceExt bi) {
        super.putImpl(profileName, bi);
    }
}
