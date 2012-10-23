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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;

/**
 * Protocol Handler for the 'data' protocol.
 * RFC: 2397
 * http://www.ietf.org/rfc/rfc2397.txt
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: ParsedURLDataProtocolHandler.java 578680 2007-09-24 07:20:03Z cam $ 
 */
public class ParsedURLDataProtocolHandler 
    extends AbstractParsedURLProtocolHandler {

    static final String DATA_PROTOCOL = "data";
    static final String BASE64 = "base64";
    static final String CHARSET = "charset";

    public ParsedURLDataProtocolHandler() {
        super(DATA_PROTOCOL);
    }

    public ParsedURLData parseURL(ParsedURL baseURL, String urlStr) {
        // No relative form...
        return parseURL(urlStr);
    }

    public ParsedURLData parseURL(String urlStr) {
        DataParsedURLData ret = new DataParsedURLData();

        int pidx=0, idx;
        int len = urlStr.length();

        // Pull fragment id off first...
        idx = urlStr.indexOf('#');
        ret.ref = null;
        if (idx != -1) {
            if (idx + 1 < len) {
                ret.ref = urlStr.substring(idx + 1);
            }
            urlStr = urlStr.substring(0, idx);
            len = urlStr.length();
        }

        idx = urlStr.indexOf(':');
        if (idx != -1) {
            // May have a protocol spec...
            ret.protocol = urlStr.substring(pidx, idx);
            if (ret.protocol.indexOf('/') == -1)
                pidx = idx+1;
            else {
                // Got a slash in protocol probably means 
                // no protocol given, (host and port?)
                ret.protocol = null;
                pidx = 0;
            }
        }

        idx = urlStr.indexOf(',',pidx);
        if ((idx != -1) && (idx != pidx)) {
            ret.host = urlStr.substring(pidx, idx);
            pidx = idx+1;

            int aidx = ret.host.lastIndexOf(';');
            if ((aidx == -1) || (aidx==ret.host.length())) {
                ret.contentType = ret.host;
            } else {
                String enc = ret.host.substring(aidx+1);
                idx = enc.indexOf('=');
                if (idx == -1) {
                    // It is an encoding.
                    ret.contentEncoding = enc;
                    ret.contentType = ret.host.substring(0, aidx);
                } else {
                    ret.contentType = ret.host;
                }
                // if theres a charset pull it out.
                aidx = 0;
                idx = ret.contentType.indexOf(';', aidx);
                if (idx != -1) {
                    aidx = idx+1;
                    while (aidx < ret.contentType.length()) {
                        idx = ret.contentType.indexOf(';', aidx);
                        if (idx == -1) idx = ret.contentType.length();
                        String param = ret.contentType.substring(aidx, idx);
                        int eqIdx = param.indexOf('=');
                        if ((eqIdx != -1) &&
                            (CHARSET.equals(param.substring(0,eqIdx)))) 
                            ret.charset = param.substring(eqIdx+1);
                        aidx = idx+1;
                    }
                }
            }
        }
        
        if (pidx < urlStr.length()) {
            ret.path = urlStr.substring(pidx);
        }

        return ret;
    }

    /**
     * Overrides some of the methods to support data protocol weirdness
     */
    static class DataParsedURLData extends ParsedURLData {

        String charset;

        public boolean complete() {
            return path != null;
        }

        public String getPortStr() {
            String portStr = "data:";
            if (host != null) {
                portStr += host;
            }
            portStr += ",";
            return portStr;
        }
                
        public String toString() {
            String ret = getPortStr();
            if (path != null) {
                ret += path;
            }
            if (ref != null) {
                ret += '#' + ref;
            }
            return ret;
        }

        /**
         * Returns the content type if available.  This is only available
         * for some protocols.
         */
        public String getContentType(String userAgent) {
            return contentType;
        }

        /**
         * Returns the content encoding if available.  This is only available
         * for some protocols.
         */
        public String getContentEncoding(String userAgent) {
            return contentEncoding;
        }

        protected InputStream openStreamInternal
            (String userAgent, Iterator mimeTypes, Iterator encodingTypes)
            throws IOException {
            stream = decode(path);
            if (BASE64.equals(contentEncoding)) {
                stream = new Base64DecodeStream(stream);
            }
            return stream;
        }

        public static InputStream decode(String s) {
            int len = s.length();
            byte [] data = new byte[len];
            int j=0;
            for(int i=0; i<len; i++) {
                char c = s.charAt(i);
                switch (c) {
                default : data[j++]= (byte)c;   break;
                case '%': {
                    if (i+2 < len) {
                        i += 2;
                        byte b; 
                        char c1 = s.charAt(i-1);
                        if      (c1 >= '0' && c1 <= '9') b=(byte)(c1-'0');
                        else if (c1 >= 'a' && c1 <= 'z') b=(byte)(c1-'a'+10);
                        else if (c1 >= 'A' && c1 <= 'Z') b=(byte)(c1-'A'+10);
                        else break;
                        b*=16;

                        char c2 = s.charAt(i);
                        if      (c2 >= '0' && c2 <= '9') b+=(byte)(c2-'0');
                        else if (c2 >= 'a' && c2 <= 'z') b+=(byte)(c2-'a'+10);
                        else if (c2 >= 'A' && c2 <= 'Z') b+=(byte)(c2-'A'+10);
                        else break;
                        data[j++] = b;
                    }
                }
                break;
                }
            }
            return new ByteArrayInputStream(data, 0, j);
        }
    }
}

