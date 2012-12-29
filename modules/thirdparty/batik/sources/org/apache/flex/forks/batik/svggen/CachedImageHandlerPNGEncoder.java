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
package org.apache.flex.forks.batik.svggen;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriter;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriterRegistry;

/**
 * GenericImageHandler which caches PNG images.
 *
 * @author <a href="mailto:paul_evenblij@compuware.com">Paul Evenblij</a>
 * @version $Id: CachedImageHandlerPNGEncoder.java 475477 2006-11-15 22:44:28Z cam $
 */
public class CachedImageHandlerPNGEncoder extends DefaultCachedImageHandler {
    public static final String CACHED_PNG_PREFIX = "pngImage";
    public static final String CACHED_PNG_SUFFIX = ".png";

    protected String refPrefix = "";

    /**
     * @param imageDir directory where this handler should generate images.
     *        If null, an IllegalArgumentException is thrown.
     * @param urlRoot root for the urls that point to images created by this
     *        image handler. If null, then the url corresponding to imageDir
     *        is used.
     */
    public CachedImageHandlerPNGEncoder(String imageDir, String urlRoot)
        throws SVGGraphics2DIOException {
        refPrefix = urlRoot + "/";
        setImageCacher(new ImageCacher.External(imageDir,
                                                CACHED_PNG_PREFIX,
                                                CACHED_PNG_SUFFIX));
    }
    
    
    /**
     * Uses PNG encoding.
     */
    public void encodeImage(BufferedImage buf, OutputStream os)
            throws IOException {
        ImageWriter writer = ImageWriterRegistry.getInstance()
            .getWriterFor("image/png");
        writer.writeImage(buf, os);
    }

    public int getBufferedImageType(){
        return BufferedImage.TYPE_INT_ARGB;
    }

    public String getRefPrefix(){
        return refPrefix;
    }
}
