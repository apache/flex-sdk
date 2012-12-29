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

import java.awt.Dimension;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriter;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriterParams;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriterRegistry;

/**
 * This implementation of the abstract AbstractImageHandlerEncoder
 * class creates JPEG images in the image directory and sets the
 * url pointing to that file in the xlink:href attributes of the
 * image elements it handles.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ImageHandlerJPEGEncoder.java 475477 2006-11-15 22:44:28Z cam $
 * @see             org.apache.flex.forks.batik.svggen.SVGGraphics2D
 * @see             org.apache.flex.forks.batik.svggen.ImageHandlerJPEGEncoder
 * @see             org.apache.flex.forks.batik.svggen.ImageHandlerPNGEncoder
 */
public class ImageHandlerJPEGEncoder extends AbstractImageHandlerEncoder {
    /**
     * @param imageDir directory where this handler should generate images.
     *        If null, an IllegalArgumentException is thrown.
     * @param urlRoot root for the urls that point to images created by this
     *        image handler. If null, then the url corresponding to imageDir
     *        is used.
     */
    public ImageHandlerJPEGEncoder(String imageDir, String urlRoot)
        throws SVGGraphics2DIOException {
        super(imageDir, urlRoot);
    }

    /**
     * @return the suffix used by this encoder. E.g., ".jpg" for
     *  ImageHandlerJPEGEncoder
     */
    public final String getSuffix() {
        return ".jpg";
    }

    /**
     * @return the prefix used by this encoder. E.g., "jpegImage" for
     * ImageHandlerJPEGEncoder
     */
    public final String getPrefix() {
        return "jpegImage";
    }

    /**
     * Derived classes should implement this method and encode the input
     * BufferedImage as needed
     */
    public void encodeImage(BufferedImage buf, File imageFile)
        throws SVGGraphics2DIOException {
        try{
            OutputStream os = new FileOutputStream(imageFile);
            try {
                ImageWriter writer = ImageWriterRegistry.getInstance()
                    .getWriterFor("image/jpeg");
                ImageWriterParams params = new ImageWriterParams();
                params.setJPEGQuality(1, false);
                writer.writeImage(buf, os, params);
                
            } finally {
                os.close();
            }
        } catch(IOException e) {
            throw new SVGGraphics2DIOException(ERR_WRITE+imageFile.getName());
        }
    }

    /**
     * This method creates a BufferedImage of the right size and type
     * for the derived class.
     */
    public BufferedImage buildBufferedImage(Dimension size) {
        return new BufferedImage(size.width, size.height,
                                 BufferedImage.TYPE_INT_RGB);
    }
}
