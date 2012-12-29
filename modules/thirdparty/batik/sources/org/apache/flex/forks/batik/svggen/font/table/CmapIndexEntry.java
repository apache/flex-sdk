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
 * @version $Id: CmapIndexEntry.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class CmapIndexEntry {

    private int platformId;
    private int encodingId;
    private int offset;

    protected CmapIndexEntry(RandomAccessFile raf) throws IOException {
        platformId = raf.readUnsignedShort();
        encodingId = raf.readUnsignedShort();
        offset = raf.readInt();
    }

    public int getEncodingId() {
        return encodingId;
    }

    public int getOffset() {
        return offset;
    }

    public int getPlatformId() {
        return platformId;
    }

    public String toString() {
        String platform;
        String encoding = "";

        switch (platformId) {
            case 1: platform = " (Macintosh)"; break;
            case 3: platform = " (Windows)"; break;
            default: platform = "";
        }
        if (platformId == 3) {
            // Windows specific encodings
            switch (encodingId) {
                case 0: encoding = " (Symbol)"; break;
                case 1: encoding = " (Unicode)"; break;
                case 2: encoding = " (ShiftJIS)"; break;
                case 3: encoding = " (Big5)"; break;
                case 4: encoding = " (PRC)"; break;
                case 5: encoding = " (Wansung)"; break;
                case 6: encoding = " (Johab)"; break;
                default: encoding = "";
            }
        }
        return new StringBuffer()
        .append( "platform id: " )
        .append( platformId )
        .append( platform )
        .append( ", encoding id: " )
        .append( encodingId )
        .append( encoding )
        .append( ", offset: " )
        .append( offset ).toString();
    }
}
