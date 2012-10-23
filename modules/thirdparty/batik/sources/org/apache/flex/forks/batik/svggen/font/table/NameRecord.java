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
 * @version $Id: NameRecord.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class NameRecord {

    private short platformId;
    private short encodingId;
    private short languageId;
    private short nameId;
    private short stringLength;
    private short stringOffset;
    private String record;

    protected NameRecord(RandomAccessFile raf) throws IOException {
        platformId = raf.readShort();
        encodingId = raf.readShort();
        languageId = raf.readShort();
        nameId = raf.readShort();
        stringLength = raf.readShort();
        stringOffset = raf.readShort();
    }
    
    public short getEncodingId() {
        return encodingId;
    }
    
    public short getLanguageId() {
        return languageId;
    }
    
    public short getNameId() {
        return nameId;
    }
    
    public short getPlatformId() {
        return platformId;
    }

    public String getRecordString() {
        return record;
    }

    protected void loadString(RandomAccessFile raf, int stringStorageOffset) throws IOException {
        StringBuffer sb = new StringBuffer();
        raf.seek(stringStorageOffset + stringOffset);
        if (platformId == Table.platformAppleUnicode) {
            
            // Unicode (big-endian)
            for (int i = 0; i < stringLength/2; i++) {
                sb.append(raf.readChar());
            }
        } else if (platformId == Table.platformMacintosh) {

            // Macintosh encoding, ASCII
            for (int i = 0; i < stringLength; i++) {
                sb.append((char) raf.readByte());
            }
        } else if (platformId == Table.platformISO) {
            
            // ISO encoding, ASCII
            for (int i = 0; i < stringLength; i++) {
                sb.append((char) raf.readByte());
            }
        } else if (platformId == Table.platformMicrosoft) {
            
            // Microsoft encoding, Unicode
            char c;
            for (int i = 0; i < stringLength/2; i++) {
                c = raf.readChar();
                sb.append(c);
            }
        }
        record = sb.toString();
    }
}
