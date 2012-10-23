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
package org.apache.flex.forks.batik.xml;

import java.io.IOException;
import java.io.InputStream;
import java.io.PushbackInputStream;
import java.io.Reader;

import org.apache.flex.forks.batik.util.io.StreamNormalizingReader;
import org.apache.flex.forks.batik.util.io.UTF16Decoder;

/**
 * This class represents a normalizing reader with encoding detection
 * management.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: XMLStreamNormalizingReader.java 475477 2006-11-15 22:44:28Z cam $
 */
public class XMLStreamNormalizingReader extends StreamNormalizingReader {
    
    /**
     * Creates a new XMLStreamNormalizingReader.
     * @param is The input stream to read.
     * @param encod The character encoding to use if the auto-detection fail.
     */
    public XMLStreamNormalizingReader(InputStream is, String encod)
        throws IOException {
        PushbackInputStream pbis = new PushbackInputStream(is, 128);
        byte[] buf = new byte[4];

        int len = pbis.read(buf);
        if (len > 0) {
            pbis.unread(buf, 0, len);
        }

        if (len == 4) {
            switch (buf[0] & 0x00FF) {
            case 0:
                if (buf[1] == 0x003c && buf[2] == 0x0000 && buf[3] == 0x003f) {
                    charDecoder = new UTF16Decoder(pbis, true);
                    return;
                }
                break;

            case '<':
                switch (buf[1] & 0x00FF) {
                case 0:
                    if (buf[2] == 0x003f && buf[3] == 0x0000) {
                        charDecoder = new UTF16Decoder(pbis, false);
                        return;
                    }
                    break;

                case '?':
                    if (buf[2] == 'x' && buf[3] == 'm') {
                        Reader r = XMLUtilities.createXMLDeclarationReader
                            (pbis, "UTF8");
                        String enc = XMLUtilities.getXMLDeclarationEncoding
                            (r, "UTF-8");
                        charDecoder = createCharDecoder(pbis, enc);
                        return;
                    }
                }
                break;

            case 0x004C:
                if (buf[1] == 0x006f &&
                    (buf[2] & 0x00FF) == 0x00a7 &&
                    (buf[3] & 0x00FF) == 0x0094) {
                    Reader r = XMLUtilities.createXMLDeclarationReader
                        (pbis, "CP037");
                    String enc = XMLUtilities.getXMLDeclarationEncoding
                        (r, "EBCDIC-CP-US");
                    charDecoder = createCharDecoder(pbis, enc);
                    return;
                }
                break;

            case 0x00FE:
                if ((buf[1] & 0x00FF) == 0x00FF) {
                    charDecoder = createCharDecoder(pbis, "UTF-16");
                    return;
                }
                break;

            case 0x00FF:
                if ((buf[1] & 0x00FF) == 0x00FE) {
                    charDecoder = createCharDecoder(pbis, "UTF-16");
                    return;
                }
            }
        }

        encod = (encod == null) ? "UTF-8" : encod;
        charDecoder = createCharDecoder(pbis, encod);
    }
}
