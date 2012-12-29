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
 * @version $Id: CmapFormat.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public abstract class CmapFormat {

    protected int format;
    protected int length;
    protected int version;

    protected CmapFormat(RandomAccessFile raf) throws IOException {
        length = raf.readUnsignedShort();
        version = raf.readUnsignedShort();
    }

    protected static CmapFormat create(int format, RandomAccessFile raf)
    throws IOException {
        switch(format) {
            case 0:
            return new CmapFormat0(raf);
            case 2:
            return new CmapFormat2(raf);
            case 4:
            return new CmapFormat4(raf);
            case 6:
            return new CmapFormat6(raf);
        }
        return null;
    }

    public int getFormat() {
        return format;
    }

    public int getLength() {
        return length;
    }

    public int getVersion() {
        return version;
    }

    public abstract int mapCharCode(int charCode);

    public abstract int getFirst();
    public abstract int getLast();

    public String toString() {
        return new StringBuffer()
        .append("format: ")
        .append(format)
        .append(", length: ")
        .append(length)
        .append(", version: ")
        .append(version).toString();
    }
}
