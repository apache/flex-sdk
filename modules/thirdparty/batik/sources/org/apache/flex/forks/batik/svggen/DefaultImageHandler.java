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
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderableImage;

import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Element;

/**
 * This class provides a default implementation of the ImageHandler
 * interface simply puts a place holder in the xlink:href
 * attribute and sets the width and height of the element.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: DefaultImageHandler.java 501495 2007-01-30 18:00:36Z dvholten $
 * @see             org.apache.flex.forks.batik.svggen.SVGGraphics2D
 */
public class DefaultImageHandler
    implements ImageHandler, ErrorConstants, XMLConstants {

    /**
     * Build a <code>DefaultImageHandler</code>.
     */
    public DefaultImageHandler() {
    }

    /**
     * The handler should set the xlink:href tag and the width and
     * height attributes.
     */
    public void handleImage(Image image, Element imageElement,
                            SVGGeneratorContext generatorContext) {
        //
        // First, set the image width and height
        //
        imageElement.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE,  String.valueOf( image.getWidth( null ) ) );
        imageElement.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE, String.valueOf( image.getHeight( null ) ) );

        //
        // Now, set the href
        //
        try {
            handleHREF(image, imageElement, generatorContext);
        } catch (SVGGraphics2DIOException e) {
            try {
                generatorContext.errorHandler.handleError(e);
            } catch (SVGGraphics2DIOException io) {
                // we need a runtime exception because
                // java.awt.Graphics2D method doesn't throw exceptions..
                throw new SVGGraphics2DRuntimeException(io);
            }
        }
    }

    /**
     * The handler should set the xlink:href tag and the width and
     * height attributes.
     */
    public void handleImage(RenderedImage image, Element imageElement,
                            SVGGeneratorContext generatorContext) {
        //
        // First, set the image width and height
        //
        imageElement.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE,  String.valueOf( image.getWidth() ) );
        imageElement.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE, String.valueOf( image.getHeight() ) );

        //
        // Now, set the href
        //
        try {
            handleHREF(image, imageElement, generatorContext);
        } catch (SVGGraphics2DIOException e) {
            try {
                generatorContext.errorHandler.handleError(e);
            } catch (SVGGraphics2DIOException io) {
                // we need a runtime exception because
                // java.awt.Graphics2D method doesn't throw exceptions..
                throw new SVGGraphics2DRuntimeException(io);
            }
        }
    }

    /**
     * The handler should set the xlink:href tag and the width and
     * height attributes.
     */
    public void handleImage(RenderableImage image, Element imageElement,
                            SVGGeneratorContext generatorContext) {
        //
        // First, set the image width and height
        //
        imageElement.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE,  String.valueOf( image.getWidth() ) );
        imageElement.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE, String.valueOf( image.getHeight() ) );

        //
        // Now, set the href
        //
        try {
            handleHREF(image, imageElement, generatorContext);
        } catch (SVGGraphics2DIOException e) {
            try {
                generatorContext.errorHandler.handleError(e);
            } catch (SVGGraphics2DIOException io) {
                // we need a runtime exception because
                // java.awt.Graphics2D method doesn't throw exceptions..
                throw new SVGGraphics2DRuntimeException(io);
            }
        }
    }

    /**
     * This template method should set the xlink:href attribute on the input
     * Element parameter
     */
    protected void handleHREF(Image image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        // Simply write a placeholder
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME, image.toString());
    }

    /**
     * This template method should set the xlink:href attribute on the input
     * Element parameter
     */
    protected void handleHREF(RenderedImage image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        // Simply write a placeholder
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME, image.toString());
    }

    /**
     * This template method should set the xlink:href attribute on the input
     * Element parameter
     */
    protected void handleHREF(RenderableImage image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        // Simply write a placeholder
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME, image.toString());
    }
}

