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

import java.awt.Image;
import java.awt.geom.AffineTransform;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderableImage;

import org.w3c.dom.Element;

/**
 * Implements the <tt>GenericImageHandler</tt> interface and only
 * uses &lt;image&gt; elements. This class delegates to the
 * <tt>ImageHandler</tt> interface for handling the xlink:href
 * attribute on the elements it creates.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: SimpleImageHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SimpleImageHandler implements GenericImageHandler, SVGSyntax, ErrorConstants {
    // duplicate the string here to remove dependencies on
    // org.apache.flex.forks.batik.dom.util.XLinkSupport
    static final String XLINK_NAMESPACE_URI =
        "http://www.w3.org/1999/xlink";

    /**
     * <tt>ImageHandler</tt> which handles xlink:href attribute setting
     */
    protected ImageHandler imageHandler;

    /**
     * @param imageHandler ImageHandler handling the xlink:href on the 
     *        &lt;image&gt; elements this GenericImageHandler implementation
     *        creates.
     */
    public SimpleImageHandler(ImageHandler imageHandler){
        if (imageHandler == null){
            throw new IllegalArgumentException();
        }

        this.imageHandler = imageHandler;
    }

    /**
     * This <tt>GenericImageHandler</tt> implementation does not
     * need to interact with the DOMTreeManager.
     */
    public void setDOMTreeManager(DOMTreeManager domTreeManager){
    }

    /**
     * Creates an Element which can refer to an image.
     * Note that no assumptions should be made by the caller about the
     * corresponding SVG tag.
     */
    public Element createElement(SVGGeneratorContext generatorContext) {
        // Create a DOM Element in SVG namespace to refer to an image
        Element imageElement =
            generatorContext.getDOMFactory().createElementNS
            (SVG_NAMESPACE_URI, SVG_IMAGE_TAG);

        return imageElement;
    }

    /**
     * The handler sets the xlink:href tag and returns a transform
     */
    public AffineTransform handleImage(Image image,
                                       Element imageElement,
                                       int x, int y,
                                       int width, int height,
                                       SVGGeneratorContext generatorContext) {

        int imageWidth      = image.getWidth(null);
        int imageHeight     = image.getHeight(null);
        if(imageWidth == 0 || imageHeight == 0 ||
           width == 0 || height == 0) {

            // Forget about it
            handleEmptyImage(imageElement);

        } else {
            imageHandler.handleImage(image, imageElement, generatorContext);
            setImageAttributes(imageElement, x, y, width, height,
                               generatorContext);
        }
        return null;
    }

    /**
     * The handler sets the xlink:href tag and returns a transform
     */
    public AffineTransform handleImage(RenderedImage image,
                                       Element imageElement,
                                       int x, int y,
                                       int width, int height,
                                       SVGGeneratorContext generatorContext) {

        int imageWidth      = image.getWidth();
        int imageHeight     = image.getHeight();

        if(imageWidth == 0 || imageHeight == 0 ||
           width == 0 || height == 0) {

            // Forget about it
            handleEmptyImage(imageElement);

        } else {
            imageHandler.handleImage(image, imageElement, generatorContext);
            setImageAttributes(imageElement, x, y, width, height, 
                               generatorContext);
        }
        return null;
    }

    /**
     * The handler sets the xlink:href tag and returns a transform
     */
    public AffineTransform handleImage(RenderableImage image,
                                       Element imageElement,
                                       double x, double y,
                                       double width, double height,
                                       SVGGeneratorContext generatorContext) {

        double imageWidth   = image.getWidth();
        double imageHeight  = image.getHeight();

        if(imageWidth == 0 || imageHeight == 0 ||
           width == 0 || height == 0) {

            // Forget about it
            handleEmptyImage(imageElement);

        } else {
            imageHandler.handleImage(image, imageElement, generatorContext);
            setImageAttributes(imageElement, x, y, width, height, generatorContext);
        }
        return null;
    }

    /**
     * Sets the x/y/width/height attributes on the &lt;image&gt; 
     * element.
     */
    protected void setImageAttributes(Element imageElement,
                                      double x, 
                                      double y,
                                      double width,
                                      double height,
                                      SVGGeneratorContext generatorContext) {
        imageElement.setAttributeNS(null,
                                    SVG_X_ATTRIBUTE,
                                    generatorContext.doubleString(x));
        imageElement.setAttributeNS(null,
                                    SVG_Y_ATTRIBUTE,
                                    generatorContext.doubleString(y));
        imageElement.setAttributeNS(null,
                                    SVG_WIDTH_ATTRIBUTE,
                                    generatorContext.doubleString(width));
        imageElement.setAttributeNS(null,
                                    SVG_HEIGHT_ATTRIBUTE,
                                    generatorContext.doubleString(height));
        imageElement.setAttributeNS(null,
                                    SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE,
                                    SVG_NONE_VALUE);
    }
              
    protected void handleEmptyImage(Element imageElement) {
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME, "");
        imageElement.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE, "0");
        imageElement.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE, "0");
    }

}
