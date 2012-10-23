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

import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * @version $Id: HeadTable.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class HeadTable implements Table {

    private int versionNumber;
    private int fontRevision;
    private int checkSumAdjustment;
    private int magicNumber;
    private short flags;
    private short unitsPerEm;
    private long created;
    private long modified;
    private short xMin;
    private short yMin;
    private short xMax;
    private short yMax;
    private short macStyle;
    private short lowestRecPPEM;
    private short fontDirectionHint;
    private short indexToLocFormat;
    private short glyphDataFormat;

    protected HeadTable(DirectoryEntry de,RandomAccessFile raf) throws IOException {
        raf.seek(de.getOffset());
        versionNumber = raf.readInt();
        fontRevision = raf.readInt();
        checkSumAdjustment = raf.readInt();
        magicNumber = raf.readInt();
        flags = raf.readShort();
        unitsPerEm = raf.readShort();
        created = raf.readLong();
        modified = raf.readLong();
        xMin = raf.readShort();
        yMin = raf.readShort();
        xMax = raf.readShort();
        yMax = raf.readShort();
        macStyle = raf.readShort();
        lowestRecPPEM = raf.readShort();
        fontDirectionHint = raf.readShort();
        indexToLocFormat = raf.readShort();
        glyphDataFormat = raf.readShort();
    }

    public int getCheckSumAdjustment() {
        return checkSumAdjustment;
    }

    public long getCreated() {
        return created;
    }

    public short getFlags() {
        return flags;
    }

    public short getFontDirectionHint() {
        return fontDirectionHint;
    }

    public int getFontRevision(){
        return fontRevision;
    }

    public short getGlyphDataFormat() {
        return glyphDataFormat;
    }

    public short getIndexToLocFormat() {
        return indexToLocFormat;
    }

    public short getLowestRecPPEM() {
        return lowestRecPPEM;
    }

    public short getMacStyle() {
        return macStyle;
    }

    public long getModified() {
        return modified;
    }

    public int getType() {
        return head;
    }

    public short getUnitsPerEm() {
        return unitsPerEm;
    }

    public int getVersionNumber() {
        return versionNumber;
    }

    public short getXMax() {
        return xMax;
    }

    public short getXMin() {
        return xMin;
    }

    public short getYMax() {
        return yMax;
    }

    public short getYMin() {
        return yMin;
    }

    public String toString() {
        return new StringBuffer()
            .append("head\n\tversionNumber: ").append(versionNumber)
            .append("\n\tfontRevision: ").append(fontRevision)
            .append("\n\tcheckSumAdjustment: ").append(checkSumAdjustment)
            .append("\n\tmagicNumber: ").append(magicNumber)
            .append("\n\tflags: ").append(flags)
            .append("\n\tunitsPerEm: ").append(unitsPerEm)
            .append("\n\tcreated: ").append(created)
            .append("\n\tmodified: ").append(modified)
            .append("\n\txMin: ").append(xMin)
            .append(", yMin: ").append(yMin)
            .append("\n\txMax: ").append(xMax)
            .append(", yMax: ").append(yMax)
            .append("\n\tmacStyle: ").append(macStyle)
            .append("\n\tlowestRecPPEM: ").append(lowestRecPPEM)
            .append("\n\tfontDirectionHint: ").append(fontDirectionHint)
            .append("\n\tindexToLocFormat: ").append(indexToLocFormat)
            .append("\n\tglyphDataFormat: ").append(glyphDataFormat)
            .toString();
    }
}
