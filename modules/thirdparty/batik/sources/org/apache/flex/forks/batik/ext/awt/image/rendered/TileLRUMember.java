/*

   Copyright 2001  The Apache Software Foundation 

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

import  java.awt.image.Raster;
import  java.lang.ref.Reference;
import  java.lang.ref.SoftReference;

/**
 * This is a useful class that wraps a Raster for patricipation in
 * an LRU Cache.  When this object drops out of the LRU cache it
 * removes it's hard reference to the tile, but retains it's soft
 * reference allowing for the recovery of the tile when the JVM is
 * not under memory pressure
 */
public class TileLRUMember implements LRUCache.LRUObj {
    private static final boolean DEBUG = false;
			
	protected LRUCache.LRUNode myNode  = null;
	protected Reference        wRaster = null;
	protected Raster           hRaster = null;

	public TileLRUMember() { }

	public TileLRUMember(Raster ras) { 
	    setRaster(ras);
	}

	public void setRaster(Raster ras) {
	    hRaster = ras;
	    wRaster = new SoftReference(ras);
	}

	public boolean checkRaster() {
	    if (hRaster != null) return true;

	    if ((wRaster       != null) && 
            (wRaster.get() != null)) return true;
			
	    return false;
	}

	public Raster retrieveRaster() {
	    if (hRaster != null) return hRaster;
	    if (wRaster == null) return null;

	    hRaster = (Raster)wRaster.get();

	    if (hRaster == null)  // didn't manage to retrieve it...
            wRaster = null;

	    return hRaster;
	}

	public LRUCache.LRUNode lruGet()         { return myNode; }
	public void lruSet(LRUCache.LRUNode nde) { myNode = nde; }
	public void lruRemove()                  { 
	    myNode  = null; 
	    hRaster = null;
	    if (DEBUG) System.out.println("Removing");
	}
}

