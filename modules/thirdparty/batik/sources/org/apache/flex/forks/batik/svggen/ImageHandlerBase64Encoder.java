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
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderableImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriter;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriterRegistry;
import org.apache.flex.forks.batik.util.Base64EncoderStream;
import org.w3c.dom.Element;

/**
 * This implementation of ImageHandler encodes the input image as
 * a PNG image first, then encodes the PNG image using Base64
 * encoding and uses the result to encoder the image url using
 * the data protocol.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ImageHandlerBase64Encoder.java 475477 2006-11-15 22:44:28Z cam $
 * @see             org.apache.flex.forks.batik.svggen.SVGGraphics2D
 * @see             org.apache.flex.forks.batik.svggen.ImageHandler
 */
public class ImageHandlerBase64Encoder extends DefaultImageHandler {
    /**
     * Build an <code>ImageHandlerBase64Encoder</code> instance.
     */
    public ImageHandlerBase64Encoder() {
        super();
    }

    /**
     * The handler should set the xlink:href tag and the width and
     * height attributes.
     */
    public void handleHREF(Image image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        if (image == null)
            throw new SVGGraphics2DRuntimeException(ERR_IMAGE_NULL);

        int width = image.getWidth(null);
        int height = image.getHeight(null);

        if (width==0 || height==0) {
            handleEmptyImage(imageElement);
        } else {
            if (image instanceof RenderedImage) {
                handleHREF((RenderedImage)image, imageElement,
                           generatorContext);
            } else {
                BufferedImage buf =
                    new BufferedImage(width, height,
                                      BufferedImage.TYPE_INT_ARGB);

                Graphics2D g = buf.createGraphics();
                g.drawImage(image, 0, 0, null);
                g.dispose();
                handleHREF((RenderedImage)buf, imageElement,
                           generatorContext);
            }
        }
    }

    /**
     * The handler should set the xlink:href tag and the width and
     * height attributes.
     */
    public void handleHREF(RenderableImage image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        if (image == null){
            throw new SVGGraphics2DRuntimeException(ERR_IMAGE_NULL);
        }

        RenderedImage r = image.createDefaultRendering();
        if (r == null) {
            handleEmptyImage(imageElement);
        } else {
            handleHREF(r, imageElement, generatorContext);
        }
    }

    protected void handleEmptyImage(Element imageElement) {
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME, DATA_PROTOCOL_PNG_PREFIX);
        imageElement.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE, "0");
        imageElement.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE, "0");
    }

    /**
     * This version of handleHREF encodes the input image into a
     * PNG image whose bytes are then encoded with Base64. The
     * resulting encoded data is used to set the url on the
     * input imageElement, using the data: protocol.
     */
    public void handleHREF(RenderedImage image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {

        //
        // Setup Base64Encoder stream to byte array.
        //
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        Base64EncoderStream b64Encoder = new Base64EncoderStream(os);
        try {
            //
            // Now, encode the input image to the base 64 stream.
            //
            encodeImage(image, b64Encoder);

            // Close the b64 encoder stream (terminates the b64 streams).
            b64Encoder.close();
        } catch (IOException e) {
            // Should not happen because we are doing in-memory processing
            throw new SVGGraphics2DIOException(ERR_UNEXPECTED, e);
        }

        //
        // Finally, write out url
        //
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME,
                                    DATA_PROTOCOL_PNG_PREFIX +
                                    os.toString());

    }

    public void encodeImage(RenderedImage buf, OutputStream os)
        throws SVGGraphics2DIOException {
        try{
            ImageWriter writer = ImageWriterRegistry.getInstance()
                .getWriterFor("image/png");
            writer.writeImage(buf, os);
        } catch(IOException e) {
            // We are doing in-memory processing. This should not happen.
            throw new SVGGraphics2DIOException(ERR_UNEXPECTED);
        }
    }

    /**
     * This method creates a BufferedImage with an alpha channel, as this is
     * supported by Base64.
     */
    public BufferedImage buildBufferedImage(Dimension size) {
        return new BufferedImage(size.width, size.height,
                                 BufferedImage.TYPE_INT_ARGB);
    }
}
