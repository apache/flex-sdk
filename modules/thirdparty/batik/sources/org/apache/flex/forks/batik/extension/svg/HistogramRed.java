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
package org.apache.flex.forks.batik.extension.svg;

import java.awt.image.Raster;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.rendered.AbstractRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;

/**
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: HistogramRed.java 479564 2006-11-27 09:56:57Z dvholten $
 */
public class HistogramRed extends AbstractRed {

    // This is used to track which tiles we have computed
    // a histogram for.
    boolean [] computed;
    int tallied = 0;

    int [] bins = new int[256];

    public HistogramRed(CachableRed src){
        super(src, null);

        int tiles = getNumXTiles()*getNumYTiles();
        computed = new boolean[tiles];
    }

    public void tallyTile(Raster r) {
        final int minX = r.getMinX();
        final int minY = r.getMinY();
        final int w = r.getWidth();
        final int h = r.getHeight();

        int [] samples = null;
        int val;
        for (int y=minY; y<minY+h; y++) {
            samples = r.getPixels(minX, y, w, 1, samples);
            for (int x=0; x<3*w; x++) {
                // Simple fixed point conversion to lumincence.
                val  = samples[x++]*5; // Red
                val += samples[x++]*9; // Green
                val += samples[x++]*2; // blue
                bins[val>>4]++;
            }
        }
        tallied++;
    }

    public int [] getHistogram() {
        if (tallied == computed.length)
            return bins;

        CachableRed src = (CachableRed)getSources().get( 0 );
        int yt0 = src.getMinTileY();

        int xtiles = src.getNumXTiles();
        int xt0 = src.getMinTileX();

        for (int y=0; y<src.getNumYTiles(); y++) {
            for (int x=0; x<xtiles; x++) {
                int idx = (x+xt0)+y*xtiles;
                if (computed[idx]) continue;

                Raster r = src.getTile(x+xt0, y+yt0);
                tallyTile(r);
                computed[idx]=true;
            }
        }
        return bins;
    }

    public WritableRaster copyData(WritableRaster wr) {
        copyToRaster(wr);
        return wr;
    }

    public Raster getTile(int tileX, int tileY) {
        int yt = tileY-getMinTileY();
        int xt = tileX-getMinTileX();

        CachableRed src = (CachableRed)getSources().get(0);
        Raster r = src.getTile(tileX, tileY);

        int idx = xt+yt*getNumXTiles();

        if (computed[idx])
            return r;

        tallyTile(r);
        computed[idx] = true;
        return r;
    }
}

