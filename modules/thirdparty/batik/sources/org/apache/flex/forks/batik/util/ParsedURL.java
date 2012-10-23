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
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.flex.forks.batik.Version;

/**
 * A {@link java.net.URL}-like class that supports custom URI schemes
 * and GZIP encoding.
 * <p>
 *   This class is used as a replacement for {@link java.net.URL}.
 *   This is done for several reasons.  First, unlike {@link java.net.URL}
 *   this class will accept and parse as much of a URL as possible, without
 *   throwing a {@link java.net.MalformedURLException}.  This makes it useful
 *   for simply parsing a URL string (hence its name).
 * </p>
 * <p>
 *   Second, it allows for extension of the URI schemes supported by the
 *   parser.  Batik uses this to support the
 *   <a href='http://www.ietf.org/rfc/rfc2397'><code>data:</code> URL scheme (RFC2397)</a>.
 * </p>
 * <p>
 *   Third, by default it checks the streams that it opens to see if they
 *   are GZIP compressed, and if so it automatically uncompresses them
 *   (avoiding opening the stream twice in the process).
 * </p>
 * <p>
 *   It is worth noting that most real work is defered to the
 *   {@link ParsedURLData} class to which most methods are forwarded.
 *   This is done because it allows a constructor interface to {@link ParsedURL}
 *   (mostly for compatability with core {@link URL}), in spite of the fact that
 *   the real implemenation uses the protocol handlers as factories for protocol
 *   specific instances of the {@link ParsedURLData} class.
 * </p>
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: ParsedURL.java 606891 2007-12-26 11:45:26Z cam $
 */
public class ParsedURL {

    /**
     * The data class we defer most things to.
     */
    ParsedURLData data;

    /**
     * The user agent to associate with this URL
     */
    String userAgent;

    /**
     * This maps between protocol names and ParsedURLProtocolHandler instances.
     */
    private static Map handlersMap = null;

    /**
     * The default protocol handler.  This handler is used when
     * other handlers fail or no match for a protocol can be
     * found.
     */
    private static ParsedURLProtocolHandler defaultHandler
        = new ParsedURLDefaultProtocolHandler();

    private static String globalUserAgent = "Batik/"+Version.getVersion();

    public static String getGlobalUserAgent() { return globalUserAgent; }

    public static void setGlobalUserAgent(String userAgent) {
        globalUserAgent = userAgent;
    }

    /**
     * Returns the shared instance of HandlersMap.  This method is
     * also responsible for initializing the handler map if this is
     * the first time it has been requested since the class was
     * loaded.
     */
    private static synchronized Map getHandlersMap() {
        if (handlersMap != null) return handlersMap;

        handlersMap = new HashMap();
        registerHandler(new ParsedURLDataProtocolHandler());
        registerHandler(new ParsedURLJarProtocolHandler());

        Iterator iter = Service.providers(ParsedURLProtocolHandler.class);
        while (iter.hasNext()) {
            ParsedURLProtocolHandler handler;
            handler = (ParsedURLProtocolHandler)iter.next();

            // System.out.println("Handler: " + handler);
            registerHandler(handler);
        }


        return handlersMap;

    }

    /**
     * Returns the handler for a particular protocol.  If protocol is
     * <tt>null</tt> or no match is found in the handlers map it
     * returns the default protocol handler.
     * @param protocol The protocol to get a handler for.
     */
    public static synchronized ParsedURLProtocolHandler getHandler
        (String protocol) {
        if (protocol == null)
            return defaultHandler;

        Map handlers = getHandlersMap();
        ParsedURLProtocolHandler ret;
        ret = (ParsedURLProtocolHandler)handlers.get(protocol);
        if (ret == null)
            ret = defaultHandler;
        return ret;
    }

    /**
     * Registers a Protocol handler by adding it to the handlers map.
     * If the given protocol handler returns <tt>null</tt> as it's
     * supported protocol then it is registered as the default
     * protocol handler.
     * @param handler the new Protocol Handler to register
     */
    public static synchronized void registerHandler
        (ParsedURLProtocolHandler handler) {
        if (handler.getProtocolHandled() == null) {
            defaultHandler = handler;
            return;
        }

        Map handlers = getHandlersMap();
        handlers.put(handler.getProtocolHandled(), handler);
    }

    /**
     * This is a utility function others can call that checks if
     * is is a GZIP stream if so it returns a GZIPInputStream that
     * will decode the contents, otherwise it returns (or a
     * buffered version of is) untouched.
     * @param is Stream that may potentially be a GZIP stream.
     */
    public static InputStream checkGZIP(InputStream is)
        throws IOException {
        return ParsedURLData.checkGZIP(is);
    }

    /**
     * Construct a ParsedURL from the given url string.
     * @param urlStr The string to try and parse as a URL
     */
    public ParsedURL(String urlStr) {
        userAgent = getGlobalUserAgent();
        data      = parseURL(urlStr);
    }

    /**
     * Construct a ParsedURL from the given java.net.URL instance.
     * This is useful if you already have a valid java.net.URL
     * instance.  This bypasses most of the parsing and hence is
     * quicker and less prone to reinterpretation than converting the
     * URL to a string before construction.
     *
     * @param url The URL to "mimic".
     */
    public ParsedURL(URL url) {
        userAgent = getGlobalUserAgent();
        data      = new ParsedURLData(url);
    }

    /**
     * Construct a sub URL from two strings.
     * @param baseStr The 'parent' URL.  Should be complete.
     * @param urlStr The 'sub' URL may be complete or partial.
     *               the missing pieces will be taken from the baseStr.
     */
    public ParsedURL(String baseStr, String urlStr) {
        userAgent = getGlobalUserAgent();
        if (baseStr != null)
            data = parseURL(baseStr, urlStr);
        else
            data = parseURL(urlStr);
    }

    /**
     * Construct a sub URL from a base URL and a string for the sub url.
     * @param baseURL The 'parent' URL.
     * @param urlStr The 'sub' URL may be complete or partial.
     *               the missing pieces will be taken from the baseURL.
     */
    public ParsedURL(URL baseURL, String urlStr) {
        userAgent = getGlobalUserAgent();

        if (baseURL != null)
            data = parseURL(new ParsedURL(baseURL), urlStr);
        else
            data = parseURL(urlStr);
    }

    /**
     * Construct a sub URL from a base ParsedURL and a string for the sub url.
     * @param baseURL The 'parent' URL.
     * @param urlStr The 'sub' URL may be complete or partial.
     *               the missing pieces will be taken from the baseURL.
     */
    public ParsedURL(ParsedURL baseURL, String urlStr) {
        if (baseURL != null) {
            userAgent = baseURL.getUserAgent();
            data = parseURL(baseURL, urlStr);
        } else {
            data = parseURL(urlStr);
        }
    }

    /**
     * Return a string rep of the URL (can be passed back into the
     * constructor if desired).
     */
    public String toString() {
        return data.toString();
    }

    /**
     * Implement Object.equals.
     * Relies heavily on the contained ParsedURLData's implementation
     * of equals.
     */
    public boolean equals(Object obj) {
        if (obj == null) return false;
        if (! (obj instanceof ParsedURL))
            return false;
        ParsedURL purl = (ParsedURL)obj;
        return data.equals(purl.data);
    }

    /**
     * Implement Object.hashCode.
     * Relies on the contained ParsedURLData's implementation
     * of hashCode.
     */
    public int hashCode() {
        return data.hashCode();
    }

    /**
     * Returns true if the URL looks well formed and complete.
     * This does not garuntee that the stream can be opened but
     * is a good indication that things aren't totally messed up.
     */
    public boolean complete() {
        return data.complete();
    }

    /**
     * Return the user agent current associated with this url (or
     * null if none).
     */
    public String getUserAgent() {
        return userAgent;
    }
    /**
     * Sets the user agent associated with this url (null clears
     * any associated user agent).
     */
    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }

    /**
     * Returns the protocol for this URL.
     * The protocol is everything upto the first ':'.
     */
    public String getProtocol() {
        if (data.protocol == null) return null;
        return data.protocol;
    }

    /**
     * Returns the host for this URL, if any, <tt>null</tt> if there isn't
     * one or it doesn't make sense for the protocol.
     */
    public String getHost() {
        if (data.host == null) return null;
        return data.host;
    }

    /**
     * Returns the port on the host to connect to, if it was specified
     * in the url that was parsed, otherwise returns -1.
     */
    public int    getPort()     { return data.port; }

    /**
     * Returns the path for this URL, if any (where appropriate for
     * the protocol this also includes the file, not just directory).
     * Note that getPath appears in JDK 1.3 as a synonym for getFile
     * from JDK 1.2.
     */
    public String getPath() {
        if (data.path == null) return null;
        return data.path;
    }

    /**
     * Returns the 'fragment' reference in the URL.
     */
    public String getRef() {
        if (data.ref == null) return null;
        return data.ref;
    }


    /**
     * Returns the URL up to and include the port number on
     * the host.  Does not include the path or fragment pieces.
     */
    public String getPortStr() {
        return data.getPortStr();
    }

    /**
     * Returns the content type if available.  This is only available
     * for some protocols.
     */
    public String getContentType() {
        return data.getContentType(userAgent);
    }

    /**
     * Returns the content type's type/subtype, if available.  This is
     * only available for some protocols.
     */
    public String getContentTypeMediaType() {
        return data.getContentTypeMediaType(userAgent);
    }

    /**
     * Returns the content type's charset parameter, if available.  This is
     * only available for some protocols.
     */
    public String getContentTypeCharset() {
        return data.getContentTypeCharset(userAgent);
    }

    /**
     * Returns whether the Content-Type header has the given parameter.
     */
    public boolean hasContentTypeParameter(String param) {
        return data.hasContentTypeParameter(userAgent, param);
    }

    /**
     * Returns the content encoding if available.  This is only available
     * for some protocols.
     */
    public String getContentEncoding() {
        return data.getContentEncoding(userAgent);
    }

    /**
     * Attempt to open the stream checking for common compression
     * types, and automatically decompressing them if found.
     */
    public InputStream openStream() throws IOException {
        return data.openStream(userAgent, null);
    }

    /**
     * Attempt to open the stream checking for common compression
     * types, and automatically decompressing them if found.
     * @param mimeType The expected mime type of the content
     *        in the returned InputStream (mapped to Http accept
     *        header among other possabilities).
     */
    public InputStream openStream(String mimeType) throws IOException {
        List mt = new ArrayList(1);
        mt.add(mimeType);
        return data.openStream(userAgent, mt.iterator());
    }

    /**
     * Attempt to open the stream checking for common compression
     * types, and automatically decompressing them if found.
     * @param mimeTypes The expected mime types of the content
     *        in the returned InputStream (mapped to Http accept
     *        header among other possabilities).
     */
    public InputStream openStream(String [] mimeTypes) throws IOException {
        List mt = new ArrayList(mimeTypes.length);
        for (int i=0; i<mimeTypes.length; i++)
            mt.add(mimeTypes[i]);
        return data.openStream(userAgent, mt.iterator());
    }

    /**
     * Attempt to open the stream checking for common compression
     * types, and automatically decompressing them if found.
     * @param mimeTypes The expected mime types of the content
     *        in the returned InputStream (mapped to Http accept
     *        header among other possabilities).  The elements of
     *        the iterator must be strings.
     */
    public InputStream openStream(Iterator mimeTypes) throws IOException {
        return data.openStream(userAgent, mimeTypes);
    }

    /**
     * Attempt to open the stream, does no checking for compression
     * types.
     */
    public InputStream openStreamRaw() throws IOException {
        return data.openStreamRaw(userAgent, null);
    }

    /**
     * Attempt to open the stream, does no checking for compression
     * types.
     * @param mimeType The expected mime type of the content
     *        in the returned InputStream (mapped to Http accept
     *        header among other possabilities).
     */
    public InputStream openStreamRaw(String mimeType) throws IOException {
        List mt = new ArrayList(1);
        mt.add(mimeType);
        return data.openStreamRaw(userAgent, mt.iterator());
    }

    /**
     * Attempt to open the stream, does no checking for comression
     * types.
     * @param mimeTypes The expected mime types of the content
     *        in the returned InputStream (mapped to Http accept
     *        header among other possabilities).
     */
    public InputStream openStreamRaw(String [] mimeTypes) throws IOException {
        List mt = new ArrayList(mimeTypes.length);
        for (int i=0; i<mimeTypes.length; i++)
            mt.add(mimeTypes[i]);
        return data.openStreamRaw(userAgent, mt.iterator());
    }

    /**
     * Attempt to open the stream, does no checking for comression
     * types.
     * @param mimeTypes The expected mime types of the content
     *        in the returned InputStream (mapped to Http accept
     *        header among other possabilities).  The elements of
     *        the iterator must be strings.
     */
    public InputStream openStreamRaw(Iterator mimeTypes) throws IOException {
        return data.openStreamRaw(userAgent, mimeTypes);
    }

    public boolean sameFile(ParsedURL other) {
        return data.sameFile(other.data);
    }


    /**
     * Parse out the protocol from a url string. Used internally to
     * select the proper handler, all other parsing is done by
     * the selected protocol handler.
     */
    protected static String getProtocol(String urlStr) {
        if (urlStr == null) return null;
        int idx = 0, len = urlStr.length();

        if (len == 0) return null;

        // Protocol is only allowed to include -+.a-zA-Z
        // So as soon as we hit something else we know we
        // are done (if it is a ':' then we have protocol otherwise
        // we don't.
        char ch = urlStr.charAt(idx);
        while ((ch == '-') ||                      // todo this might be more efficient with a long mask
               (ch == '+') ||                      // which has a bit set for each valid char.
               (ch == '.') ||                      // check feasability
               ((ch >= 'a') && (ch <= 'z')) ||
               ((ch >= 'A') && (ch <= 'Z'))) {
            idx++;
            if (idx == len) {
                ch=0;
                break;
            }
            ch = urlStr.charAt(idx);
        }
        if (ch == ':') {
            // Has a protocol spec...
            return urlStr.substring(0, idx).toLowerCase();
        }
        return null;
    }

    /**
     * Factory method to construct an appropriate subclass of  ParsedURLData
     * @param urlStr the string to parse.
     */
    public static ParsedURLData parseURL(String urlStr) {
        ParsedURLProtocolHandler handler = getHandler(getProtocol(urlStr));
        return handler.parseURL(urlStr);
    }

    /**
     * Factory method to construct an appropriate subclass of  ParsedURLData,
     * for a sub url.
     * @param baseStr The base URL string to parse.
     * @param urlStr the sub URL string to parse.
     */
    public static ParsedURLData parseURL(String baseStr, String urlStr) {
        if (baseStr == null)
            return parseURL(urlStr);

        ParsedURL purl = new ParsedURL(baseStr);
        return parseURL(purl, urlStr);
    }

    /**
     * Factory method to construct an appropriate subclass of  ParsedURLData,
     * for a sub url.
     * @param baseURL The base ParsedURL to parse.
     * @param urlStr the sub URL string to parse.
     */
    public static ParsedURLData parseURL(ParsedURL baseURL, String urlStr) {
        if (baseURL == null)
            return parseURL(urlStr);

        String protocol = getProtocol(urlStr);
        if (protocol == null)
            protocol = baseURL.getProtocol();
        ParsedURLProtocolHandler handler = getHandler(protocol);
        return handler.parseURL(baseURL, urlStr);
    }
}
