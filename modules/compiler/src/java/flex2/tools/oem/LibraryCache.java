/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.tools.oem;

import flex2.compiler.swc.SwcCache;

/**
 * A cache of library files that is designed to be used to compile
 * Application and Library objects, which ideally have some common
 * library path elements.
 *
 * @since 3.0
 * @author dloverin
 */
public class LibraryCache extends CacheBase
{
    private SwcCache swcCache;      // the cache that does all the work.

    public LibraryCache()
    {
    }
    
    /**
     * Get the SwcCache current being used by this class.
     * 
     * @return the current SwcCache.
     */
    SwcCache getSwcCache()
    {
        return swcCache;
    }

    /**
     * Set the swcCache to be used by this cache. The reference to the
     * previous cache is overwritten.
     * 
     * @param swcCache the new SwcCache object.
     */
    void setSwcCache(SwcCache swcCache)
    {
        this.swcCache = swcCache;
    }
}
