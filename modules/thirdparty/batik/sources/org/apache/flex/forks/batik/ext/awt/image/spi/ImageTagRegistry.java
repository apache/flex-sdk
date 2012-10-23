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
package org.apache.flex.forks.batik.ext.awt.image.spi;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StreamCorruptedException;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;

import org.apache.flex.forks.batik.ext.awt.color.ICCColorSpaceExt;
import org.apache.flex.forks.batik.ext.awt.image.URLImageCache;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ProfileRable;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.Service;

/**
 * This class handles the registered Image tag handlers.  These are
 * instances of RegistryEntry in this package.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: ImageTagRegistry.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public class ImageTagRegistry implements ErrorConstants {

    List entries    = new LinkedList();
    List extensions = null;
    List mimeTypes  = null;

    URLImageCache rawCache;
    URLImageCache imgCache;

    public ImageTagRegistry() {
        this(null, null);
    }

    public ImageTagRegistry(URLImageCache rawCache, URLImageCache imgCache) {
        if (rawCache == null)
            rawCache = new URLImageCache();
        if (imgCache == null)
            imgCache = new URLImageCache();

        this.rawCache= rawCache;
        this.imgCache= imgCache;
    }

    /** Removes all decoded raster images from the cache.
     *  All Images will be reloaded from the original source
     *  if decoded again.
     */
    public void flushCache() {
        rawCache.flush();
        imgCache.flush();
    }

    /** Removes the given URL from the cache.  Only the Image
     *  associated with that URL will be removed from the cache.
     */
    public void flushImage(ParsedURL purl) {
        rawCache.clear(purl);
        imgCache.clear(purl);
    }

    public Filter checkCache(ParsedURL purl, ICCColorSpaceExt colorSpace) {
        // I just realized that this whole thing could
        boolean needRawData = (colorSpace != null);

        Filter      ret        = null;
        URLImageCache cache;
        if (needRawData) cache = rawCache;
        else             cache = imgCache;

        ret = cache.request(purl);
        if (ret == null) {
            cache.clear(purl);
            return null;
        }

        // System.out.println("Image came from cache" + purl);
        if (colorSpace != null)
            ret = new ProfileRable(ret, colorSpace);
        return ret;
    }

    public Filter readURL(ParsedURL purl) {
        return readURL(null, purl, null, true, true);
    }

    public Filter readURL(ParsedURL purl, ICCColorSpaceExt colorSpace) {
        return readURL(null, purl, colorSpace, true, true);
    }

    public Filter readURL(InputStream is, ParsedURL purl,
                          ICCColorSpaceExt colorSpace,
                          boolean allowOpenStream,
                          boolean returnBrokenLink) {
        if ((is != null) && !is.markSupported())
            // Doesn't support mark so wrap with
            // BufferedInputStream that does.
            is = new BufferedInputStream(is);

        // I just realized that this whole thing could
        boolean needRawData = (colorSpace != null);

        Filter      ret     = null;
        URLImageCache cache = null;

        if (purl != null) {
            if (needRawData) cache = rawCache;
            else             cache = imgCache;

            ret = cache.request(purl);
            if (ret != null) {
                // System.out.println("Image came from cache" + purl);
                if (colorSpace != null)
                    ret = new ProfileRable(ret, colorSpace);
                return ret;
            }
        }
        // System.out.println("Image didn't come from cache: " + purl);

        boolean     openFailed = false;
        List mimeTypes = getRegisteredMimeTypes();

        Iterator i;
        i = entries.iterator();
        while (i.hasNext()) {
            RegistryEntry re = (RegistryEntry)i.next();
            if (re instanceof URLRegistryEntry) {
                if ((purl == null) || !allowOpenStream) continue;

                URLRegistryEntry ure = (URLRegistryEntry)re;
                if (ure.isCompatibleURL(purl)) {
                    ret = ure.handleURL(purl, needRawData);

                    // Check if we got an image.
                    if (ret != null) break;
                }
                continue;
            }

            if (re instanceof StreamRegistryEntry) {
                StreamRegistryEntry sre = (StreamRegistryEntry)re;
                // Quick out last time the open didn't work for this
                // URL so don't try again...
                if (openFailed) continue;

                try {
                    if (is == null) {
                        // Haven't opened the stream yet let's try.
                        if ((purl == null) || !allowOpenStream)
                            break;  // No purl nothing we can do...
                        try {
                            is = purl.openStream(mimeTypes.iterator());
                        } catch(IOException ioe) {
                            // Couldn't open the stream, go to next entry.
                            openFailed = true;
                            continue;
                        }

                        if (!is.markSupported())
                            // Doesn't support mark so wrap with
                            // BufferedInputStream that does.
                            is = new BufferedInputStream(is);
                    }

                    if (sre.isCompatibleStream(is)) {
                        ret = sre.handleStream(is, purl, needRawData);
                        if (ret != null) break;
                    }
                } catch (StreamCorruptedException sce) {
                    // Stream is messed up so setup to reopen it..
                    is = null;
                }
                continue;
            }
        }

        if (cache != null)
            cache.put(purl, ret);

        if (ret == null) {
            if (!returnBrokenLink)
                return null;
            if (openFailed)
                // Technially it's possible that it's an unknown
                // 'protocol that caused the open to fail but probably
                // it's a bad URL...
                return getBrokenLinkImage(this, ERR_URL_UNREACHABLE, null);

            // We were able to get to the data we just couldn't
            // make sense of it...
            return getBrokenLinkImage(this, ERR_URL_UNINTERPRETABLE, null);
        }

        if (BrokenLinkProvider.hasBrokenLinkProperty(ret)) {
            // Don't Return Broken link image unless requested
            return (returnBrokenLink)?ret:null;
        }

        if (colorSpace != null)
            ret = new ProfileRable(ret, colorSpace);

        return ret;
    }

    public Filter readStream(InputStream is) {
        return readStream(is, null);
    }

    public Filter readStream(InputStream is, ICCColorSpaceExt colorSpace) {
        if (!is.markSupported())
            // Doesn't support mark so wrap with BufferedInputStream that does.
            is = new BufferedInputStream(is);

        boolean needRawData = (colorSpace != null);

        Filter ret = null;

        Iterator i = entries.iterator();
        while (i.hasNext()) {
            RegistryEntry re = (RegistryEntry)i.next();

            if (! (re instanceof StreamRegistryEntry))
                continue;
            StreamRegistryEntry sre = (StreamRegistryEntry)re;

            try {
                if (sre.isCompatibleStream(is)) {
                    ret = sre.handleStream(is, null, needRawData);

                    if (ret != null) break;
                }
            } catch (StreamCorruptedException sce) {
                break;
            }
        }

        if (ret == null)
            return getBrokenLinkImage(this, ERR_STREAM_UNREADABLE, null);

        if ((colorSpace != null) &&
            (!BrokenLinkProvider.hasBrokenLinkProperty(ret)))
            ret = new ProfileRable(ret, colorSpace);

        return ret;
    }

    public synchronized void register(RegistryEntry newRE) {
        float priority = newRE.getPriority();

        ListIterator li;
        li = entries.listIterator();
        while (li.hasNext()) {
            RegistryEntry re = (RegistryEntry)li.next();
            if (re.getPriority() > priority) {
                li.previous();
                li.add(newRE);
                return;
            }
        }
        li.add(newRE);
        extensions = null;
        mimeTypes = null;
    }

    /**
     * Returns a List that contains String of all the extensions that
     * can be handleded by the various registered image format
     * handlers.
     */
    public synchronized List getRegisteredExtensions() {
        if (extensions != null)
            return extensions;

        extensions = new LinkedList();
        Iterator iter = entries.iterator();
        while(iter.hasNext()) {
            RegistryEntry re = (RegistryEntry)iter.next();
            extensions.addAll(re.getStandardExtensions());
        }
        extensions = Collections.unmodifiableList(extensions);
        return extensions;
    }

    /**
     * Returns a List that contains String of all the mime types that
     * can be handleded by the various registered image format
     * handlers.
     */
    public synchronized List getRegisteredMimeTypes() {
        if (mimeTypes != null)
            return mimeTypes;

        mimeTypes = new LinkedList();
        Iterator iter = entries.iterator();
        while(iter.hasNext()) {
            RegistryEntry re = (RegistryEntry)iter.next();
            mimeTypes.addAll(re.getMimeTypes());
        }
        mimeTypes = Collections.unmodifiableList(mimeTypes);
        return mimeTypes;
    }

    static ImageTagRegistry registry = null;

    public static synchronized ImageTagRegistry getRegistry() {
        if (registry != null)
            return registry;

        registry = new ImageTagRegistry();

        //registry.register(new PNGRegistryEntry());
        //registry.register(new TIFFRegistryEntry());
        //registry.register(new JPEGRegistryEntry());
        registry.register(new JDKRegistryEntry());

        Iterator iter = Service.providers(RegistryEntry.class);
        while (iter.hasNext()) {
            RegistryEntry re = (RegistryEntry)iter.next();
            // System.out.println("RE: " + re);
            registry.register(re);
        }

        return registry;
    }

    static BrokenLinkProvider defaultProvider
        = new DefaultBrokenLinkProvider();

    static BrokenLinkProvider brokenLinkProvider = null;

    public static synchronized Filter
        getBrokenLinkImage(Object base, String code, Object [] params) {
        Filter ret = null;
        if (brokenLinkProvider != null)
            ret = brokenLinkProvider.getBrokenLinkImage(base, code, params);

        if (ret == null)
            ret = defaultProvider.getBrokenLinkImage(base, code, params);

        return ret;
    }


    public static synchronized void
        setBrokenLinkProvider(BrokenLinkProvider provider) {
        brokenLinkProvider = provider;
    }
}

