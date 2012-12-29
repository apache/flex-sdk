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
 * @version $Id: LocaTable.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class LocaTable implements Table {

    private byte[] buf = null;
    private int[] offsets = null;
    private short factor = 0;

    protected LocaTable(DirectoryEntry de, RandomAccessFile raf) throws IOException {
        raf.seek(de.getOffset());
        buf = new byte[de.getLength()];
        raf.read(buf);
    }

    public void init(int numGlyphs, boolean shortEntries) {
        if (buf == null) {
            return;
        }
        offsets = new int[numGlyphs + 1];
        ByteArrayInputStream bais = new ByteArrayInputStream(buf);
        if (shortEntries) {
            factor = 2;
            for (int i = 0; i <= numGlyphs; i++) {
                offsets[i] = (bais.read()<<8 | bais.read());
            }
        } else {
            factor = 1;
            for (int i = 0; i <= numGlyphs; i++) {
                offsets[i] = (bais.read()<<24 | bais.read()<<16 | 
                              bais.read()<< 8 | bais.read());
            }
        }
        buf = null;
    }
    
    public int getOffset(int i) {
        if (offsets == null) {
            return 0;
        }
        return offsets[i] * factor;
    }

    public int getType() {
        return loca;
    }
}
