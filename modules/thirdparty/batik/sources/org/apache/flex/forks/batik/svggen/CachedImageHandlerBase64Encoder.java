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

import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriter;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageWriterRegistry;
import org.apache.flex.forks.batik.util.Base64EncoderStream;
import org.w3c.dom.Element;


/**
 * This subclass of {@link ImageHandlerBase64Encoder} implements
 * functionality specific to the cached version of the image
 * encoder.
 *
 * @author <a href="mailto:paul_evenblij@compuware.com">Paul Evenblij</a>
 * @version $Id: CachedImageHandlerBase64Encoder.java 475477 2006-11-15 22:44:28Z cam $
 */
public class CachedImageHandlerBase64Encoder extends DefaultCachedImageHandler {
    /**
     * Build a <code>CachedImageHandlerBase64Encoder</code> instance.
     */
    public CachedImageHandlerBase64Encoder() {
        super();
        setImageCacher(new ImageCacher.Embedded());
    }
    
   /**
    * Creates an Element which can refer to an image.
    * Note that no assumptions should be made by the caller about the
    * corresponding SVG tag.
    */
    public Element createElement(SVGGeneratorContext generatorContext) {
        // Create a DOM Element in SVG namespace to refer to an image
        // For this cached version we return <use>
        Element imageElement =
            generatorContext.getDOMFactory().createElementNS(
                                                             SVG_NAMESPACE_URI, SVG_USE_TAG);
        
        return imageElement;
    }


    public String getRefPrefix(){
        return "";
    }

    /**
     * Determines the transformation needed to get the cached image to
     * scale & position properly. Sets x and y attributes on the element
     * accordingly.
     */
    protected AffineTransform handleTransform(Element imageElement,
                                              double x, double y,
                                              double srcWidth,
                                              double srcHeight,
                                              double dstWidth,
                                              double dstHeight,
                                              SVGGeneratorContext generatorContext) {

        // If scaling is necessary, create a transform, since "width" and "height"
        // have no effect on a <use> element referring to an <image> element.

        AffineTransform af  = new AffineTransform();
        double hRatio = dstWidth / srcWidth;
        double vRatio = dstHeight / srcHeight;

        af.translate(x,y);

        if(hRatio != 1 || vRatio != 1) {
            af.scale(hRatio, vRatio);
        } 

        if (!af.isIdentity()){
            return af;
        } else {
            return null;
        }
    }

    /**
     * Uses PNG encoding.
     */
    public void encodeImage(BufferedImage buf, OutputStream os)
            throws IOException {
        Base64EncoderStream b64Encoder = new Base64EncoderStream(os);
        ImageWriter writer = ImageWriterRegistry.getInstance()
            .getWriterFor("image/png");
        writer.writeImage(buf, b64Encoder);
        b64Encoder.close();
    }

    public int getBufferedImageType(){
        return BufferedImage.TYPE_INT_ARGB;
    }
}

