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
package org.apache.flex.forks.batik.svggen.font.table;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * @version $Id: HmtxTable.java 489226 2006-12-21 00:05:36Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class HmtxTable implements Table {

    private byte[] buf = null;
    private int[] hMetrics = null;
    private short[] leftSideBearing = null;

    protected HmtxTable(DirectoryEntry de,RandomAccessFile raf) throws IOException {
        raf.seek(de.getOffset());
        buf = new byte[de.getLength()];
        raf.read(buf);
/*
        TableMaxp t_maxp = (TableMaxp) td.getEntryByTag(maxp).getTable();
        TableHhea t_hhea = (TableHhea) td.getEntryByTag(hhea).getTable();
        int lsbCount = t_maxp.getNumGlyphs() - t_hhea.getNumberOfHMetrics();
        hMetrics = new int[t_hhea.getNumberOfHMetrics()];
        for (int i = 0; i < t_hhea.getNumberOfHMetrics(); i++) {
            hMetrics[i] = raf.readInt();
        }
        if (lsbCount > 0) {
            leftSideBearing = new short[lsbCount];
            for (int i = 0; i < lsbCount; i++) {
                leftSideBearing[i] = raf.readShort();
            }
        }
*/
    }

    public void init(int numberOfHMetrics, int lsbCount) {
        if (buf == null) {
            return;
        }
        hMetrics = new int[numberOfHMetrics];
        ByteArrayInputStream bais = new ByteArrayInputStream(buf);
        for (int i = 0; i < numberOfHMetrics; i++) {
            // pack 4 bytes from bais into an int and store in hMetrics[]
            // bais.read() returns an int 0..255, so no need to worry for sign-extension here
            hMetrics[i] = (bais.read()<<24 | bais.read()<<16 |
                           bais.read()<< 8 | bais.read());
        }
        if (lsbCount > 0) {
            leftSideBearing = new short[lsbCount];
            for (int i = 0; i < lsbCount; i++) {
                leftSideBearing[i] = (short)(bais.read()<<8 | bais.read());
            }
        }
        buf = null;
    }

    public int getAdvanceWidth(int i) {
        if (hMetrics == null) {
            return 0;
        }
        if (i < hMetrics.length) {
            return hMetrics[i] >> 16;
        } else {
            return hMetrics[hMetrics.length - 1] >> 16;
        }
    }

    public short getLeftSideBearing(int i) {
        if (hMetrics == null) {
            return 0;
        }
        if (i < hMetrics.length) {
            return (short)(hMetrics[i] & 0xffff);
        } else {
            return leftSideBearing[i - hMetrics.length];
        }
    }

    public int getType() {
        return hmtx;
    }
}
