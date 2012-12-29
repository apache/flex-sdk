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
 * @version $Id: TableDirectory.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class TableDirectory {

    private int version = 0;
    private short numTables = 0;
    private short searchRange = 0;
    private short entrySelector = 0;
    private short rangeShift = 0;
    private DirectoryEntry[] entries;

    public TableDirectory(RandomAccessFile raf) throws IOException {
        version = raf.readInt();
        numTables = raf.readShort();
        searchRange = raf.readShort();
        entrySelector = raf.readShort();
        rangeShift = raf.readShort();
        entries = new DirectoryEntry[numTables];
        for (int i = 0; i < numTables; i++) {
            entries[i] = new DirectoryEntry(raf);
        }

        // Sort them into file order (simple bubble sort)
        boolean modified = true;
        while (modified) {
            modified = false;
            for (int i = 0; i < numTables - 1; i++) {
                if (entries[i].getOffset() > entries[i+1].getOffset()) {
                    DirectoryEntry temp = entries[i];
                    entries[i] = entries[i+1];
                    entries[i+1] = temp;
                    modified = true;
                }
            }
        }
    }

    public DirectoryEntry getEntry(int index) {
        return entries[index];
    }

    public DirectoryEntry getEntryByTag(int tag) {
        for (int i = 0; i < numTables; i++) {
            if (entries[i].getTag() == tag) {
                return entries[i];
            }
        }
        return null;
    }

    public short getEntrySelector() {
        return entrySelector;
    }

    public short getNumTables() {
        return numTables;
    }

    public short getRangeShift() {
        return rangeShift;
    }

    public short getSearchRange() {
        return searchRange;
    }

    public int getVersion() {
        return version;
    }
}
