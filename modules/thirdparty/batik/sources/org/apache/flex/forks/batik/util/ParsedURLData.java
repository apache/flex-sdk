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

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.zip.GZIPInputStream;
import java.util.zip.InflaterInputStream;
import java.util.zip.ZipException;

/**
 * Holds the data for more URLs.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: ParsedURLData.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class ParsedURLData {

    protected static final String HTTP_USER_AGENT_HEADER      = "User-Agent";

    protected static final String HTTP_ACCEPT_HEADER          = "Accept";
    protected static final String HTTP_ACCEPT_LANGUAGE_HEADER = "Accept-Language";
    protected static final String HTTP_ACCEPT_ENCODING_HEADER = "Accept-Encoding";

    protected static List acceptedEncodings = new LinkedList();
    static {
        acceptedEncodings.add("gzip");
    }

    /**
     * GZIP header magic number bytes, like found in a gzipped
     * files, which are encoded in Intel format (i&#x2e;e&#x2e; little indian).
     */
    public static final byte[] GZIP_MAGIC = {(byte)0x1f, (byte)0x8b};

    /**
     * This is a utility function others can call that checks if
     * is is a GZIP stream if so it returns a GZIPInputStream that
     * will decode the contents, otherwise it returns (or a
     * buffered version of is) untouched.
     * @param is Stream that may potentially be a GZIP stream.
     */
    public static InputStream checkGZIP(InputStream is)
        throws IOException {

            if (!is.markSupported())
                is = new BufferedInputStream(is);
            byte[] data = new byte[2];
            try {
                is.mark(2);
                is.read(data);
                is.reset();
            } catch (Exception ex) {
                is.reset();
                return is;
            }
        if ((data[0] == GZIP_MAGIC[0]) &&
            (data[1] == GZIP_MAGIC[1]))
            return new GZIPInputStream(is);

        if (((data[0]&0x0F)  == 8) &&
            ((data[0]>>>4)   <= 7)) {
            // Check for a zlib (deflate) stream
            int chk = ((((int)data[0])&0xFF)*256+
                       (((int)data[1])&0xFF));
            if ((chk %31)  == 0) {
                try {
                    // I'm not really as certain of this check
                    // as I would like so I want to force it
                    // to decode part of the stream.
                    is.mark(100);
                    InputStream ret = new InflaterInputStream(is);
                    if (!ret.markSupported())
                        ret = new BufferedInputStream(ret);
                    ret.mark(2);
                    ret.read(data);
                    is.reset();
                    ret = new InflaterInputStream(is);
                    return ret;
                } catch (ZipException ze) {
                    is.reset();
                    return is;
                }
            }
        }

        return is;
    }

    /**
     * Since the Data instance is 'hidden' in the ParsedURL
     * instance we make all our methods public.  This makes it
     * easy for the various Protocol Handlers to update an
     * instance as parsing proceeds.
     */
    public String protocol        = null;
    public String host            = null;
    public int    port            = -1;
    public String path            = null;
    public String ref             = null;
    public String contentType     = null;
    public String contentEncoding = null;

    public InputStream stream     = null;
    public boolean hasBeenOpened  = false;

    /**
     * The extracted type/subtype from the Content-Type header.
     */
    protected String contentTypeMediaType;

    /**
     * The extracted charset parameter from the Content-Type header.
     */
    protected String contentTypeCharset;

    /**
     * Void constructor
     */
    public ParsedURLData() {
    }

    /**
     * Build from an existing URL.
     */
    public ParsedURLData(URL url) {
        protocol = url.getProtocol();
        if ((protocol != null) && (protocol.length() == 0))
            protocol = null;

        host = url.getHost();
        if ((host != null) && (host.length() == 0))
            host = null;

        port     = url.getPort();

        path     = url.getFile();
        if ((path != null) && (path.length() == 0))
            path = null;

        ref      = url.getRef();
        if ((ref != null) && (ref.length() == 0))
            ref = null;
    }

    /**
     * Attempts to build a normal java.net.URL instance from this
     * URL.
     */
    protected URL buildURL() throws MalformedURLException {

        // System.out.println("File: " + file);
        // if (ref != null)
        //     file += "#" + ref;
        // System.err.println("Building: " + protocol + " - " +
        //                     host + " - " + path);

        if ((protocol != null) && (host != null)) {
            String file = "";
            if (path != null)
                file = path;
            if (port == -1)
                return new URL(protocol, host, file);

            return new URL(protocol, host, port, file);
        }

        return new URL(toString());
    }

    /**
     * Implement Object.hashCode.
     */
    public int hashCode() {
        int hc = port;
        if (protocol != null)
            hc ^= protocol.hashCode();
        if (host != null)
            hc ^= host.hashCode();

        // For some URLs path and ref can get fairly long
        // and the most unique part is towards the end
        // so we grab that part for HC purposes
        if (path != null) {
            int len = path.length();
            if (len > 20)
                hc ^= path.substring(len-20).hashCode();
            else
                hc ^= path.hashCode();
        }
        if (ref != null) {
            int len = ref.length();
            if (len > 20)
                hc ^= ref.substring(len-20).hashCode();
            else
                hc ^= ref.hashCode();
        }

        return hc;
    }

    /**
     * Implement Object.equals for ParsedURLData.
     */
    public boolean equals(Object obj) {
        if (obj == null) return false;
        if (! (obj instanceof ParsedURLData))
            return false;

        ParsedURLData ud = (ParsedURLData)obj;
        if (ud.port != port)
            return false;

        if (ud.protocol==null) {
            if (protocol != null)
                return false;
        } else if (protocol == null)
            return false;
        else if (!ud.protocol.equals(protocol))
            return false;

        if (ud.host==null) {
            if (host   !=null)
                return false;
        } else if (host == null)
            return false;
        else if (!ud.host.equals(host))
            return false;

        if (ud.ref==null) {
            if (ref   !=null)
                return false;
        } else if (ref == null)
            return false;
        else if (!ud.ref.equals(ref))
            return false;

        if (ud.path==null) {
            if (path   !=null)
                return false;
        } else if (path == null)
            return false;
        else if (!ud.path.equals(path))
            return false;

        return true;
    }

    /**
     * Returns the content type if available.  This is only available
     * for some protocols.
     */
    public String getContentType(String userAgent) {
        if (contentType != null)
            return contentType;

        if (!hasBeenOpened) {
            try {
                openStreamInternal(userAgent, null,  null);
            } catch (IOException ioe) { /* nothing */ }
        }

        return contentType;
    }

    /**
     * Returns the content type's type/subtype, if available.  This is
     * only available for some protocols.
     */
    public String getContentTypeMediaType(String userAgent) {
        if (contentTypeMediaType != null) {
            return contentTypeMediaType;
        }

        extractContentTypeParts(userAgent);

        return contentTypeMediaType;
    }

    /**
     * Returns the content type's charset parameter, if available.  This is
     * only available for some protocols.
     */
    public String getContentTypeCharset(String userAgent) {
        if (contentTypeMediaType != null) {
            return contentTypeCharset;
        }

        extractContentTypeParts(userAgent);

        return contentTypeCharset;
    }

    /**
     * Returns whether the Content-Type header has the given parameter.
     */
    public boolean hasContentTypeParameter(String userAgent, String param) {
        getContentType(userAgent);
        if (contentType == null) {
            return false;
        }
        int i = 0;
        int len = contentType.length();
        int plen = param.length();
loop1:  while (i < len) {
            switch (contentType.charAt(i)) {
                case ' ':
                case ';':
                    break loop1;
            }
            i++;
        }
        if (i == len) {
            contentTypeMediaType = contentType;
        } else {
            contentTypeMediaType = contentType.substring(0, i);
        }
loop2:  for (;;) {
            while (i < len && contentType.charAt(i) != ';') {
                i++;
            }
            if (i == len) {
                return false;
            }
            i++;
            while (i < len && contentType.charAt(i) == ' ') {
                i++;
            }
            if (i >= len - plen - 1) {
                return false;
            }
            for (int j = 0; j < plen; j++) {
                if (!(contentType.charAt(i++) == param.charAt(j))) {
                    continue loop2;
                }
            }
            if (contentType.charAt(i) == '=') {
                return true;
            }
        }
    }

    /**
     * Extracts the type/subtype and charset parameter from the Content-Type
     * header.
     */
    protected void extractContentTypeParts(String userAgent) {
        getContentType(userAgent);
        if (contentType == null) {
            return;
        }
        int i = 0;
        int len = contentType.length();
loop1:  while (i < len) {
            switch (contentType.charAt(i)) {
                case ' ':
                case ';':
                    break loop1;
            }
            i++;
        }
        if (i == len) {
            contentTypeMediaType = contentType;
        } else {
            contentTypeMediaType = contentType.substring(0, i);
        }
        for (;;) {
            while (i < len && contentType.charAt(i) != ';') {
                i++;
            }
            if (i == len) {
                return;
            }
            i++;
            while (i < len && contentType.charAt(i) == ' ') {
                i++;
            }
            if (i >= len - 8) {
                return;
            }
            if (contentType.charAt(i++) == 'c') {
                if (contentType.charAt(i++) != 'h') continue;
                if (contentType.charAt(i++) != 'a') continue;
                if (contentType.charAt(i++) != 'r') continue;
                if (contentType.charAt(i++) != 's') continue;
                if (contentType.charAt(i++) != 'e') continue;
                if (contentType.charAt(i++) != 't') continue;
                if (contentType.charAt(i++) != '=') continue;
                int j = i;
loop2:          while (i < len) {
                    switch (contentType.charAt(i)) {
                        case ' ':
                        case ';':
                            break loop2;
                    }
                    i++;
                }
                contentTypeCharset = contentType.substring(j, i);
                return;
            }
        }
    }

    /**
     * Returns the content encoding if available.  This is only available
     * for some protocols.
     */
    public String getContentEncoding(String userAgent) {
        if (contentEncoding != null)
            return contentEncoding;

        if (!hasBeenOpened) {
            try {
                openStreamInternal(userAgent, null,  null);
            } catch (IOException ioe) { /* nothing */ }
        }

        return contentEncoding;
    }

    /**
     * Returns true if the URL looks well formed and complete.
     * This does not garuntee that the stream can be opened but
     * is a good indication that things aren't totally messed up.
     */
    public boolean complete() {
        try {
            buildURL();
        } catch (MalformedURLException mue) {
            return false;
        }
        return true;
    }

    /**
     * Open the stream and check for common compression types.  If
     * the stream is found to be compressed with a standard
     * compression type it is automatically decompressed.
     * @param userAgent The user agent opening the stream (may be null).
     * @param mimeTypes The expected mime types of the content
     *        in the returned InputStream (mapped to Http accept
     *        header among other possability).  The elements of
     *        the iterator must be strings (may be null)
     */
    public InputStream openStream(String userAgent, Iterator mimeTypes)
        throws IOException {
        InputStream raw = openStreamInternal(userAgent, mimeTypes,
                                             acceptedEncodings.iterator());
        if (raw == null)
            return null;
        stream = null;

        return checkGZIP(raw);
    }

    /**
     * Open the stream and returns it.  No checks are made to see
     * if the stream is compressed or encoded in any way.
     * @param userAgent The user agent opening the stream (may be null).
     * @param mimeTypes The expected mime types of the content
     *        in the returned InputStream (mapped to Http accept
     *        header among other possability).  The elements of
     *        the iterator must be strings (may be null)
     */
    public InputStream openStreamRaw(String userAgent, Iterator mimeTypes)
        throws IOException {

        InputStream ret = openStreamInternal(userAgent, mimeTypes, null);
        stream = null;
        return ret;
    }

    protected InputStream openStreamInternal(String userAgent,
                                             Iterator mimeTypes,
                                             Iterator encodingTypes)
        throws IOException {
        if (stream != null)
            return stream;

        hasBeenOpened = true;

        URL url = null;
        try {
            url = buildURL();
        } catch (MalformedURLException mue) {
            throw new IOException
                ("Unable to make sense of URL for connection");
        }

        if (url == null)
            return null;

        URLConnection urlC = url.openConnection();
        if (urlC instanceof HttpURLConnection) {
            if (userAgent != null)
                urlC.setRequestProperty(HTTP_USER_AGENT_HEADER, userAgent);

            if (mimeTypes != null) {
                String acceptHeader = "";
                while (mimeTypes.hasNext()) {
                    acceptHeader += mimeTypes.next();
                    if (mimeTypes.hasNext())
                        acceptHeader += ",";
                }
                urlC.setRequestProperty(HTTP_ACCEPT_HEADER, acceptHeader);
            }

            if (encodingTypes != null) {
                String encodingHeader = "";
                while (encodingTypes.hasNext()) {
                    encodingHeader += encodingTypes.next();
                    if (encodingTypes.hasNext())
                        encodingHeader += ",";
                }
                urlC.setRequestProperty(HTTP_ACCEPT_ENCODING_HEADER,
                                        encodingHeader);
            }

            contentType     = urlC.getContentType();
            contentEncoding = urlC.getContentEncoding();
        }

        return (stream = urlC.getInputStream());
    }

    /**
     * Returns the URL up to and include the port number on
     * the host.  Does not include the path or fragment pieces.
     */
    public String getPortStr() {
        String portStr ="";
        if (protocol != null)
            portStr += protocol + ":";

        if ((host != null) || (port != -1)) {
            portStr += "//";
            if (host != null) portStr += host;
            if (port != -1)   portStr += ":" + port;
        }

        return portStr;
    }

    protected boolean sameFile(ParsedURLData other) {
        if (this == other) return true;

        // Check if the rest of the two PURLs matche other than
        // the 'ref'
        if ((port      == other.port) &&
            ((path     == other.path)
             || ((path!=null) && path.equals(other.path))) &&
            ((host     == other.host)
             || ((host!=null) && host.equals(other.host))) &&
            ((protocol == other.protocol)
             || ((protocol!=null) && protocol.equals(other.protocol))))
            return true;

        return false;
    }


    /**
     * Return a string representation of the data.
     */
    public String toString() {
        String ret = getPortStr();
        if (path != null)
            ret += path;

        if (ref != null)
            ret += "#" + ref;

        return ret;
    }
}

