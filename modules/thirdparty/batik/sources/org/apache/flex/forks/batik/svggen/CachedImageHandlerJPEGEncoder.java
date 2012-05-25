/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

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

import com.sun.image.codec.jpeg.JPEGCodec;
import com.sun.image.codec.jpeg.JPEGEncodeParam;
import com.sun.image.codec.jpeg.JPEGImageEncoder;

/**
 * GenericImageHandler which caches JPEG images.
 *
 * @author <a href="mailto:paul_evenblij@compuware.com">Paul Evenblij</a>
 * @version $Id: CachedImageHandlerJPEGEncoder.java,v 1.5 2004/08/18 07:14:59 vhardy Exp $
 */
public class CachedImageHandlerJPEGEncoder extends DefaultCachedImageHandler {
    public static final String CACHED_JPEG_PREFIX = "jpegImage";
    public static final String CACHED_JPEG_SUFFIX = ".jpg";

    protected String refPrefix = "";
     
    /**
     * @param imageDir directory where this handler should generate images.
     *        If null, an IllegalArgumentException is thrown.
     * @param urlRoot root for the urls that point to images created by this
     *        image handler. If null, then the url corresponding to imageDir
     *        is used.
     */
    public CachedImageHandlerJPEGEncoder(String imageDir, String urlRoot)
        throws SVGGraphics2DIOException {
        refPrefix = urlRoot + "/";
        setImageCacher(new ImageCacher.External(imageDir,
                                                CACHED_JPEG_PREFIX,
                                                CACHED_JPEG_SUFFIX));
    }
   
    /**
     * Uses JPEG encoding.
     */
    public void encodeImage(BufferedImage buf, OutputStream os)
        throws IOException {
        JPEGImageEncoder encoder = JPEGCodec.createJPEGEncoder(os);
        JPEGEncodeParam param = encoder.getDefaultJPEGEncodeParam(buf);
        param.setQuality(1, false);
        encoder.encode(buf, param);
    }

    public int getBufferedImageType(){
        return BufferedImage.TYPE_INT_RGB;
    }

    public String getRefPrefix(){
        return refPrefix;
    }
}
