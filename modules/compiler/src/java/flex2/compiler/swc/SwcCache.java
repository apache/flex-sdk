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

package flex2.compiler.swc;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Iterator;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.Set;

import flash.util.Trace;
import flash.util.FileUtils;
import flash.util.LRUCache;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * Loads, stores, and caches SWCs.  This is the class to start with
 * when working with SWCs.  There's only two public methods for
 * SwcCache, one for getting SWCs and one for saving SWCs-
 * getSwcGroup() and export().
 *
 * SwcCache takes care of caching and synchronization.  There should
 * be only one SwcCache.
 *
 * The class has two levels of caching.  There is a cache of SWCs as
 * well as a cache of directories of SWCs.  When a directory is asked
 * for, we check the timestamp and return the cached value if its the
 * same.  If its not, then we look for SWCs in the directory.  If we
 * have a cached SWC, we check the timestampe and return the cache SWC
 * if its the same.
 *
 * For now, we are just synchronizing on the whole cache on each get
 * or export.  We could add more logic to do read/write
 * synchronization on specific SwcGroups.  From tests though it looks
 * like the two layers of caching will provide enough for performance.
 *
 * @author Brian Deitte
 */
public class SwcCache
{
    public static int CACHE_INITIAL_SIZE = 20;
    public static int CACHE_MAX_SIZE = 66;

    public static final String SWC_EXTENSION = ".swc";
    public static final String GENSWC_EXTENSION = "-generated.swc";

    // cache of Swcs, with the key in the map being the path of the SWC
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected SwcLRUCache swcLRUCache = new SwcLRUCache();

    // for testing under load
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected boolean useCache = true;

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected boolean lazyRead = true;
    
    /**
     * Loads the current path SWCs and returns a SwcGroup. There will be one SwcGroup per compile,
     * and this is the piece that the compiler will mostly deal with for SWCs.
     */
    public SwcGroup getSwcGroup( VirtualFile[] paths )
    {
        // fixme - this could be improved.
        String[] urls = new String[paths.length];
        for (int i = 0; i < paths.length; ++i)
            urls[i] = paths[i].getName();
        return getSwcGroup( urls );
    }

    /**
     * Used directly by the DigestTool.
     */
    public synchronized SwcGroup getSwcGroup(String[] paths)
    {
        SwcGroup group;
        String path;
        Map<String, Swc> swcs = new LinkedHashMap<String, Swc>();

        for (int i = 0; i < paths.length; i++)
        {
            path = paths[i];
            swcs.putAll(getSwcs(path));
        }

        group = new SwcGroup(swcs);

        return group;
    }

    /**
     * 
     * @param groups 
     * @param rslGroup The group of RSLs that are in groups. 
     * @return SwcGroup
     */
    // todo - this could be made much more efficient by avoiding re-merging swcs
    public synchronized SwcGroup getSwcGroup(List<SwcGroup> groups, SwcGroup rslGroup)
    {
        Map<String, Swc> swcs = new LinkedHashMap<String, Swc>();

        for (SwcGroup g : groups)
        {
            if (g != null)
            {
                swcs.putAll( g.getSwcs() );
            }
        }

        SwcGroup group = null;

        if (swcs.size() > 0)
        {
            group = new SwcGroup( swcs, rslGroup );
        }

        return group;
    }

    /**
     * Saves the given SWC to disk and adds to the cache
     */
    public synchronized boolean export(Swc swc)
            throws FileNotFoundException, IOException
    {
        try
        {
            if (! swc.save())
            {
                return false;
            }

            if (Trace.swc)
            {
                Trace.trace("Exported SWC " + swc.getLocation() + "(" + swc.getLastModified() + ")");
            }

            if (!(swc.getArchive() instanceof SwcWriteOnlyArchive))
            {
                // add to Swc cache
                swcLRUCache.put(swc.getLocation(), swc);
            }
        }
        catch (Exception e)
        {
            if (Trace.error)
            {
                e.printStackTrace();
            }
            if (e instanceof SwcException)
            {
                throw (SwcException) e;
            }
            else
            {
                SwcException ex = new SwcException.SwcNotExported(swc.getLocation(), e);
                ThreadLocalToolkit.log(ex);
                throw ex;
            }
        }
        return true;
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected Map<String, Swc> getSwcs(String path)
    {
        Map<String, Swc> map = new LinkedHashMap<String, Swc>();
        File f = new File(path);
        if (!f.exists())
        {
            throw new SwcException.SwcNotFound(path);
        }
        File catalog = new File( FileUtils.addPathComponents( path, Swc.CATALOG_XML, File.separatorChar ) );

        if (!f.isDirectory() || catalog.exists())
        {
            Swc swc = getSwc( f );
            if (swc != null)
            {
                map.put( swc.getLocation(), swc );
            }
        }
        else
        {
            File[] files = FileUtils.listFiles( f );
            for (int i = 0; i < files.length; i++)
            {
                File file = files[i];

                // we don't want to snarf an entire directory tree, just a single level.
                if ((!file.isDirectory()) && file.canRead())
                {
                    String lowerCase = file.getName().toLowerCase();

                    if (lowerCase.endsWith( GENSWC_EXTENSION ))   // never automatically read genswcs
                        continue;

                    if (lowerCase.endsWith( SWC_EXTENSION ))
                    {
                        Swc swc = getSwc( file );
                        if (swc != null)
                        {
                            map.put( swc.getLocation(), swc );
                        }
                    }
                }
            }
        }
        return map;
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected Swc getSwc(File file)
    {
        Swc swc;
        try
        {
            String location = FileUtils.canonicalPath(file);
            swc = (Swc) swcLRUCache.get(location);

            long fileLastModified = file.lastModified();

            if (swc == null || (fileLastModified != swc.getLastModified()))
            {
                if (Trace.swc)
                {
                    if (swc != null)
                    {
                        Trace.trace("Reloading: location = " + location +
                                    ", fileLastModified = " + fileLastModified +
                                    ", swc.getLastModified() = " + swc.getLastModified() +
                                    ", swc = " + swc.hashCode());
                    }
                    else
                    {
                        Trace.trace("Loading " + location);
                    }
                }

                SwcArchive archive = file.isDirectory()?
                        (SwcArchive) new SwcDirectoryArchive( location ) :
                        lazyRead ? new SwcLazyReadArchive( location ) : new SwcDynamicArchive( location );

                swc = new Swc( archive, true );
                swc.setLastModified(fileLastModified);

                if (ThreadLocalToolkit.errorCount() > 0)
                {
                    swc = null;
                }
                else if (useCache)
                {
                    swcLRUCache.put(location, swc);
                }
            }
            else if (Trace.swc)
            {
                Trace.trace("Using cached version of " + location);
            }
        }
        catch(Exception e)
        {
            if (Trace.error)
            {
                e.printStackTrace();
            }
            SwcException.SwcNotLoaded ex = new SwcException.SwcNotLoaded(file.getName(), e);
            ThreadLocalToolkit.log(ex);
            throw ex;
        }
        return swc;
    }

    public void setLastModified(String location, long lastModified)
    {
        Swc swc = (Swc) swcLRUCache.get(location);
    
        if (swc != null)
        {
            swc.setLastModified(lastModified);
        }
    }

    public void setLazyRead(boolean lazyRead)
    {
        this.lazyRead = lazyRead;
    }
    
    public void remove(String swcLocation)
    {
        swcLRUCache.remove(swcLocation);
    }

    static class SwcLRUCache extends LRUCache
    {
        private static final long serialVersionUID = 1867582701366939733L;

        SwcLRUCache()
        {
            super(CACHE_INITIAL_SIZE, CACHE_MAX_SIZE);
        }

        protected Object fetch(Object key)
        {
            return null;
        }

        /**
         * Get a list of swcs in the cache.
         * 
         * @return a list of swcs, each of type Swc. 
         */
        public List<Swc> getSwcs()
        {
            ArrayList<Swc> swcs = new ArrayList<Swc>(size());
            for (Iterator iter = entrySet().iterator(); iter.hasNext();)
            {
                Map.Entry entry = (Map.Entry)iter.next();
                LRUListEntry lruEntry = (LRUListEntry)entry.getValue();
                swcs.add((Swc)lruEntry.getValue());
            }
            
            return swcs;
        }
    }

}
