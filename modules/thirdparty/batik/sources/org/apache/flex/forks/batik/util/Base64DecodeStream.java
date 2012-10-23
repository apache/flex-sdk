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
package org.apache.flex.forks.batik.util;

import java.io.IOException;
import java.io.InputStream;

/**
 * This class implements a Base64 Character decoder as specified in RFC1113.
 * Unlike some other encoding schemes there is nothing in this encoding that
 * tells the decoder where a buffer starts or stops, so to use it you will need
 * to isolate your encoded data into a single chunk and then feed them
 * this decoder. The simplest way to do that is to read all of the encoded
 * data into a string and then use:
 * <pre>
 *      byte    data[];
 *      InputStream is = new ByteArrayInputStream(data);
 *      is = new Base64DecodeStream(is);
 * </pre>
 *
 * On errors, this class throws a IOException with the following detail
 * strings:
 * <pre>
 *    "Base64DecodeStream: Bad Padding byte (2)."
 *    "Base64DecodeStream: Bad Padding byte (1)."
 * </pre>
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @author      Chuck McManis
 * @version $Id: Base64DecodeStream.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class Base64DecodeStream extends InputStream {

    InputStream src;

    public Base64DecodeStream(InputStream src) {
        this.src = src;
    }

    private static final byte[] pem_array = new byte[256];

    static {
        for (int i=0; i<pem_array.length; i++)
            pem_array[i] = -1;

        int idx = 0;
        for (char c='A'; c<='Z'; c++) {
            pem_array[c] = (byte)idx++;
        }
        for (char c='a'; c<='z'; c++) {
            pem_array[c] = (byte)idx++;
        }

        for (char c='0'; c<='9'; c++) {
            pem_array[c] = (byte)idx++;
        }

        pem_array['+'] = (byte)idx++;
        pem_array['/'] = (byte)idx++;
    }

    public boolean markSupported() { return false; }

    public void close()
        throws IOException {
        EOF = true;
    }

    public int available()
        throws IOException {
        return 3-out_offset;
    }

    byte[] decode_buffer = new byte[4];
    byte[] out_buffer = new byte[3];
    int  out_offset = 3;
    boolean EOF = false;

    public int read() throws IOException {

        if (out_offset == 3) {
            if (EOF || getNextAtom()) {
                EOF = true;
                return -1;
            }
        }

        return ((int)out_buffer[out_offset++])&0xFF;
    }

    public int read(byte []out, int offset, int len)
        throws IOException {

        int idx = 0;
        while (idx < len) {
            if (out_offset == 3) {
                if (EOF || getNextAtom()) {
                    EOF = true;
                    if (idx == 0) return -1;
                    else          return idx;
                }
            }

            out[offset+idx] = out_buffer[out_offset++];

            idx++;
        }
        return idx;
    }

    final boolean getNextAtom() throws IOException {
        int count, a, b, c, d;

        int off = 0;
        while(off != 4) {
            count = src.read(decode_buffer, off, 4-off);
            if (count == -1)
                return true;

            int in=off, out=off;
            while(in < off+count) {
                if ((decode_buffer[in] != '\n') &&
                    (decode_buffer[in] != '\r') &&
                    (decode_buffer[in] != ' '))
                    decode_buffer[out++] = decode_buffer[in];
                in++;
            }

            off = out;
        }

        a = pem_array[((int)decode_buffer[0])&0xFF];
        b = pem_array[((int)decode_buffer[1])&0xFF];
        c = pem_array[((int)decode_buffer[2])&0xFF];
        d = pem_array[((int)decode_buffer[3])&0xFF];

        out_buffer[0] = (byte)((a<<2) | (b>>>4));
        out_buffer[1] = (byte)((b<<4) | (c>>>2));
        out_buffer[2] = (byte)((c<<6) |  d     );

        if (decode_buffer[3] != '=') {
            // All three bytes are good.
            out_offset=0;
        } else if (decode_buffer[2] == '=') {
            // Only one byte of output.
            out_buffer[2] = out_buffer[0];
            out_offset = 2;
            EOF=true;
        } else {
            // Only two bytes of output.
            out_buffer[2] = out_buffer[1];
            out_buffer[1] = out_buffer[0];
            out_offset = 1;
            EOF=true;
        }

        return false;
    }
}
