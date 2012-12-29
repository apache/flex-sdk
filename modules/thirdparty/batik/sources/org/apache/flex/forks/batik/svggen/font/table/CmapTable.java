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
 * @version $Id: CmapTable.java 476924 2006-11-19 21:13:26Z dvholten $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class CmapTable implements Table {

    private int version;
    private int numTables;
    private CmapIndexEntry[] entries;
    private CmapFormat[] formats;

    protected CmapTable(DirectoryEntry de, RandomAccessFile raf) throws IOException {
        raf.seek(de.getOffset());
        long fp = raf.getFilePointer();
        version = raf.readUnsignedShort();
        numTables = raf.readUnsignedShort();
        entries = new CmapIndexEntry[numTables];
        formats = new CmapFormat[numTables];

        // Get each of the index entries
        for (int i = 0; i < numTables; i++) {
            entries[i] = new CmapIndexEntry(raf);
        }

        // Get each of the tables
        for (int i = 0; i < numTables; i++) {
            raf.seek(fp + entries[i].getOffset());
            int format = raf.readUnsignedShort();
            formats[i] = CmapFormat.create(format, raf);
        }
    }

    public CmapFormat getCmapFormat(short platformId, short encodingId) {

        // Find the requested format
        for (int i = 0; i < numTables; i++) {
            if (entries[i].getPlatformId() == platformId
                    && entries[i].getEncodingId() == encodingId) {
                return formats[i];
            }
        }
        return null;
    }

    public int getType() {
        return cmap;
    }

    public String toString() {
        StringBuffer sb = new StringBuffer( numTables * 8 ).append("cmap\n");

        // Get each of the index entries
        for (int i = 0; i < numTables; i++) {
            sb.append( '\t' ).append(entries[i].toString()).append( '\n' );
        }

        // Get each of the tables
        for (int i = 0; i < numTables; i++) {
            sb.append( '\t' ).append(formats[i].toString()).append( '\n' );
        }
        return sb.toString();
    }
}
