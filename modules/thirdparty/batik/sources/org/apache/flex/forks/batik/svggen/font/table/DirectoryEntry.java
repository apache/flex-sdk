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
 * @version $Id: DirectoryEntry.java,v 1.3 2004/08/18 07:15:20 vhardy Exp $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class DirectoryEntry {

    private int tag;
    private int checksum;
    private int offset;
    private int length;
    private Table table = null;

    protected DirectoryEntry(RandomAccessFile raf) throws IOException {
        tag = raf.readInt();
        checksum = raf.readInt();
        offset = raf.readInt();
        length = raf.readInt();
    }

    public int getChecksum() {
        return checksum;
    }

    public int getLength() {
        return length;
    }

    public int getOffset() {
        return offset;
    }

    public int getTag() {
        return tag;
    }

    public String toString() {
        return new StringBuffer()
            .append((char)((tag>>24)&0xff))
            .append((char)((tag>>16)&0xff))
            .append((char)((tag>>8)&0xff))
            .append((char)((tag)&0xff))
            .append(", offset: ")
            .append(offset)
            .append(", length: ")
            .append(length)
            .append(", checksum: 0x")
            .append(Integer.toHexString(checksum))
            .toString();
    }
}
