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
 *
 * @version $Id: TableFactory.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class TableFactory {

    public static Table create(DirectoryEntry de, RandomAccessFile raf) throws IOException {
        Table t = null;
        switch (de.getTag()) {
        case Table.BASE:
            break;
        case Table.CFF:
            break;
        case Table.DSIG:
            break;
        case Table.EBDT:
            break;
        case Table.EBLC:
            break;
        case Table.EBSC:
            break;
        case Table.GDEF:
            break;
        case Table.GPOS:
            t = new GposTable(de, raf);
            break;
        case Table.GSUB:
            t = new GsubTable(de, raf);
            break;
        case Table.JSTF:
            break;
        case Table.LTSH:
            break;
        case Table.MMFX:
            break;
        case Table.MMSD:
            break;
        case Table.OS_2:
            t = new Os2Table(de, raf);
            break;
        case Table.PCLT:
            break;
        case Table.VDMX:
            break;
        case Table.cmap:
            t = new CmapTable(de, raf);
            break;
        case Table.cvt:
            t = new CvtTable(de, raf);
            break;
        case Table.fpgm:
            t = new FpgmTable(de, raf);
            break;
        case Table.fvar:
            break;
        case Table.gasp:
            break;
        case Table.glyf:
            t = new GlyfTable(de, raf);
            break;
        case Table.hdmx:
            break;
        case Table.head:
            t = new HeadTable(de, raf);
            break;
        case Table.hhea:
            t = new HheaTable(de, raf);
            break;
        case Table.hmtx:
            t = new HmtxTable(de, raf);
            break;
        case Table.kern:
            t = new KernTable(de, raf);
            break;
        case Table.loca:
            t = new LocaTable(de, raf);
            break;
        case Table.maxp:
            t = new MaxpTable(de, raf);
            break;
        case Table.name:
            t = new NameTable(de, raf);
            break;
        case Table.prep:
            t = new PrepTable(de, raf);
            break;
        case Table.post:
            t = new PostTable(de, raf);
            break;
        case Table.vhea:
            break;
        case Table.vmtx:
            break;
        }
        return t;
    }
}
