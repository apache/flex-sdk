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
package org.apache.flex.forks.batik.ext.awt.image.rendered;

import java.awt.Point;
import java.awt.image.Raster;
import java.lang.ref.SoftReference;
import java.util.HashMap;

import org.apache.flex.forks.batik.util.CleanerThread;
import org.apache.flex.forks.batik.util.HaltingThread;

public class TileMap implements TileStore {
    private static final boolean DEBUG = false;
    private static final boolean COUNT = false;		

    private HashMap rasters=new HashMap();

    static class TileMapLRUMember extends TileLRUMember {
        public Point   pt;
        public SoftReference parent;

        class RasterSoftRef extends CleanerThread.SoftReferenceCleared {
            RasterSoftRef(Object o) { super(o); }
            public void cleared() {
                if (DEBUG) System.err.println("Cleaned: " + this);
                TileMap tm = (TileMap)parent.get();
                if (tm != null)
                    tm.rasters.remove(pt);
            }
        }

        TileMapLRUMember(TileMap parent, Point pt, Raster ras) {
            super(ras);
            this.parent = new SoftReference(parent);
            this.pt     = pt;
        }

        public void setRaster(Raster ras) {
            hRaster = ras;
            wRaster = new RasterSoftRef(ras);
        }
    }

    private TileGenerator source = null;
    private LRUCache      cache = null;

    public TileMap(TileGenerator source,
		   LRUCache cache) {
        this.cache    = cache;
        this.source   = source;
    }

    public void setTile(int x, int y, Raster ras) {
        Point pt = new Point(x, y);

        if (ras == null) {
            // Clearing entry...
            Object o = rasters.remove(pt);
            if (o != null) 
                cache.remove((TileMapLRUMember)o);
            return;
        }

        Object o = rasters.get(pt);
        TileMapLRUMember item;
        if (o == null) {
            item = new TileMapLRUMember(this, pt, ras);
            rasters.put(pt, item);
        } else {
            item = (TileMapLRUMember)o;
            item.setRaster(ras);
        }
		
        cache.add(item);
        if (DEBUG) System.out.println("Setting: (" + x + ", " + y + ")");
    }

    // Returns Raster if the tile is _currently_ in the cache.  
    // If it is not currently in the cache it returns null.
    public Raster getTileNoCompute(int x, int y) {
        Point pt = new Point(x, y);
        Object o = rasters.get(pt);
        if (o == null) 
            return null;

        TileMapLRUMember item = (TileMapLRUMember)o;
        Raster ret = item.retrieveRaster();
        if (ret != null)
            cache.add(item);
        return ret;
    }

    public Raster getTile(int x, int y) {
        if (DEBUG) System.out.println("Fetching: (" + (x) + ", " + 
                                      (y) + ")");
        if (COUNT) synchronized (TileMap.class) { requests++; }

        Raster       ras  = null;
        Point pt = new Point(x, y);
        Object o = rasters.get(pt);
        TileMapLRUMember item = null;
        if (o != null) {
            item = (TileMapLRUMember)o;
            ras = item.retrieveRaster();
        }
		
        if (ras == null) {
            if (DEBUG) System.out.println("Generating: ("+(x)+", "+
                                          (y) + ")");
            if (COUNT) synchronized (TileMap.class) { misses++; }
            ras = source.genTile(x, y);

            // In all likelyhood the contents of this tile is junk!
            // So don't cache it (returning is probably fine since it
            // shouldn't come back to haunt us...)
            if (HaltingThread.hasBeenHalted())
                return ras;

            if (item != null)
                item.setRaster(ras);
            else  {
                item = new TileMapLRUMember(this, pt, ras);
                rasters.put(pt, item);
            }
        }

        // Update the item's position in the cache..
        cache.add(item);

        return ras;
    }

    static int requests;
    static int misses;
}
