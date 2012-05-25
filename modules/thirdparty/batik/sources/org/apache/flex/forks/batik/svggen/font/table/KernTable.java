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
 *
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 * @version $Id: KernTable.java,v 1.3 2004/08/18 07:15:21 vhardy Exp $
 */
public class KernTable implements Table {
    
    private int version;
    private int nTables;
    private KernSubtable[] tables;

    /** Creates new KernTable */
    protected KernTable(DirectoryEntry de, RandomAccessFile raf) throws IOException {
        raf.seek(de.getOffset());
        version = raf.readUnsignedShort();
        nTables = raf.readUnsignedShort();
        tables = new KernSubtable[nTables];
        for (int i = 0; i < nTables; i++) {
            tables[i] = KernSubtable.read(raf);
        }
    }

    public int getSubtableCount() {
        return nTables;
    }
    
    public KernSubtable getSubtable(int i) {
        return tables[i];
    }

    /** Get the table type, as a table directory value.
     * @return The table type
     */
    public int getType() {
        return kern;
    }

}
