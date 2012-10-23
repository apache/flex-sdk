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
package org.apache.flex.forks.batik.util.io;

import java.io.IOException;
import java.io.InputStream;

/**
 * This class represents an object which decodes UTF-16 characters from
 * a stream of bytes.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: UTF16Decoder.java 475477 2006-11-15 22:44:28Z cam $
 */
public class UTF16Decoder extends AbstractCharDecoder {

    /**
     * Whether the stream's byte-order is big-endian.
     */
    protected boolean bigEndian;
    
    /**
     * Creates a new UTF16Decoder.
     * It is assumed that the byte-order mark is present.
     * @param is The stream to decode.
     */
    public UTF16Decoder(InputStream is) throws IOException {
        super(is);
        // Byte-order detection.
        int b1 = is.read();
        if (b1 == -1) {
            endOfStreamError("UTF-16");
        }
        int b2 = is.read();
        if (b2 == -1) {
            endOfStreamError("UTF-16");
        }
        int m = (((b1 & 0xff) << 8) | (b2 & 0xff));
        switch (m) {
        case 0xfeff:
            bigEndian = true;
            break;
        case 0xfffe:
            break;
        default:
            charError("UTF-16");
        }
    }

    /**
     * Creates a new UTF16Decoder.
     * @param is The stream to decode. 
     * @param be Whether or not the given stream's byte-order is
     * big-endian.
     */
    public UTF16Decoder(InputStream is, boolean be) {
        super(is);
        bigEndian = be;
    }

    /**
     * Reads the next character.
     * @return a character or END_OF_STREAM.
     */
    public int readChar() throws IOException {
        if (position == count) {
            fillBuffer();
        }
        if (count == -1) {
            return END_OF_STREAM;
        }
        byte b1 = buffer[position++];
        if (position == count) {
            fillBuffer();
        }
        if (count == -1) {
            endOfStreamError("UTF-16");
        }
        byte b2 = buffer[position++];
        int c = (bigEndian)
            ? (((b1 & 0xff) << 8) | (b2 & 0xff))
            : (((b2 & 0xff) << 8) | (b1 & 0xff));
        if (c == 0xfffe) {
            charError("UTF-16");
        }
        return c;
    }
}
