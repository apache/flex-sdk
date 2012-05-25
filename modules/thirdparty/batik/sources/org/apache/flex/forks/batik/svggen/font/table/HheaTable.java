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
package org.apache.flex.forks.batik.svggen.font.table;

import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * @version $Id: HheaTable.java,v 1.3 2004/08/18 07:15:21 vhardy Exp $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class HheaTable implements Table {

    private int version;
    private short ascender;
    private short descender;
    private short lineGap;
    private short advanceWidthMax;
    private short minLeftSideBearing;
    private short minRightSideBearing;
    private short xMaxExtent;
    private short caretSlopeRise;
    private short caretSlopeRun;
    private short metricDataFormat;
    private short numberOfHMetrics;

    protected HheaTable(DirectoryEntry de,RandomAccessFile raf) throws IOException {
        raf.seek(de.getOffset());
        version = raf.readInt();
        ascender = raf.readShort();
        descender = raf.readShort();
        lineGap = raf.readShort();
        advanceWidthMax = raf.readShort();
        minLeftSideBearing = raf.readShort();
        minRightSideBearing = raf.readShort();
        xMaxExtent = raf.readShort();
        caretSlopeRise = raf.readShort();
        caretSlopeRun = raf.readShort();
        for (int i = 0; i < 5; i++) {
            raf.readShort();
        }
        metricDataFormat = raf.readShort();
        numberOfHMetrics = raf.readShort();
    }

    public short getAdvanceWidthMax() {
        return advanceWidthMax;
    }

    public short getAscender() {
        return ascender;
    }

    public short getCaretSlopeRise() {
        return caretSlopeRise;
    }

    public short getCaretSlopeRun() {
        return caretSlopeRun;
    }

    public short getDescender() {
        return descender;
    }

    public short getLineGap() {
        return lineGap;
    }

    public short getMetricDataFormat() {
        return metricDataFormat;
    }

    public short getMinLeftSideBearing() {
        return minLeftSideBearing;
    }

    public short getMinRightSideBearing() {
        return minRightSideBearing;
    }

    public short getNumberOfHMetrics() {
        return numberOfHMetrics;
    }

    public int getType() {
        return hhea;
    }

    public short getXMaxExtent() {
        return xMaxExtent;
    }
}
