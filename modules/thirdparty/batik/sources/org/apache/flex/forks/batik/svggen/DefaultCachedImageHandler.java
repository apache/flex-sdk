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
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderableImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Method;

import org.w3c.dom.Element;

/**
 * This class is a default implementation of the GenericImageHandler
 * for handlers implementing a caching strategy.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: DefaultCachedImageHandler.java 478176 2006-11-22 14:50:50Z dvholten $
 * @see             org.apache.flex.forks.batik.svggen.SVGGraphics2D
 */
public abstract class DefaultCachedImageHandler
    implements CachedImageHandler,
               SVGSyntax,
               ErrorConstants {

    // duplicate the string here to remove dependencies on
    // org.apache.flex.forks.batik.dom.util.XLinkSupport
    static final String XLINK_NAMESPACE_URI =
        "http://www.w3.org/1999/xlink";

    static final AffineTransform IDENTITY = new AffineTransform();

    // for createGraphics method.
    private static Method createGraphics = null;
    private static boolean initDone = false;
    private static final Class[] paramc = new Class[] {BufferedImage.class};
    private static Object[] paramo = null;

    protected ImageCacher imageCacher;

    /**
     * The image cache can be used by subclasses for efficient image storage
     */
    public ImageCacher getImageCacher() {
        return imageCacher;
    }

    void setImageCacher(ImageCacher imageCacher) {
        if (imageCacher == null){
            throw new IllegalArgumentException();
        }

        // Save current DOMTreeManager if any
        DOMTreeManager dtm = null;
        if (this.imageCacher != null){
            dtm = this.imageCacher.getDOMTreeManager();
        }

        this.imageCacher = imageCacher;
        if (dtm != null){
            this.imageCacher.setDOMTreeManager(dtm);
        }
    }

    /**
     * This <tt>GenericImageHandler</tt> implementation does not
     * need to interact with the DOMTreeManager.
     */
    public void setDOMTreeManager(DOMTreeManager domTreeManager){
        imageCacher.setDOMTreeManager(domTreeManager);
    }

    /**
     * This method creates a <code>Graphics2D</code> from a
     * <code>BufferedImage</code>. If Batik extensions to AWT are
     * in the CLASSPATH it uses them, otherwise, it uses the regular
     * AWT method.
     */
    private static Graphics2D createGraphics(BufferedImage buf) {
        if (!initDone) {
            try {
                Class clazz = Class.forName("org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil");
                createGraphics = clazz.getMethod("createGraphics", paramc);
                paramo = new Object[1];
            } catch (Throwable t) {
                // happen only if Batik extensions are not their
            } finally {
                initDone = true;
            }
        }
        if (createGraphics == null)
            return buf.createGraphics();
        else {
            paramo[0] = buf;
            Graphics2D g2d = null;
            try {
                g2d = (Graphics2D)createGraphics.invoke(null, paramo);
            } catch (Exception e) {
                // should not happened
            }
            return g2d;
        }
    }

    /**
     * Creates an Element which can refer to an image.
     * Note that no assumptions should be made by the caller about the
     * corresponding SVG tag. By default, an &lt;image&gt; tag is
     * used, but the {@link CachedImageHandlerBase64Encoder}, for
     * example, overrides this method to use a different tag.
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
        AffineTransform af  = null;

        if(imageWidth == 0 || imageHeight == 0 ||
           width == 0 || height == 0) {

            // Forget about it
            handleEmptyImage(imageElement);

        } else {
            // First set the href
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

            // Then create the transformation:
            // Because we cache image data, the stored image may
            // need to be scaled.
            af = handleTransform(imageElement, x, y, imageWidth, imageHeight,
                                 width, height, generatorContext);
        }
        return af;
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
        AffineTransform af  = null;

        if(imageWidth == 0 || imageHeight == 0 ||
           width == 0 || height == 0) {

            // Forget about it
            handleEmptyImage(imageElement);

        } else {
            // First set the href
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

            // Then create the transformation:
            // Because we cache image data, the stored image may
            // need to be scaled.
            af = handleTransform(imageElement, x, y, imageWidth, imageHeight,
                                 width, height, generatorContext);
        }
        return af;
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
        AffineTransform af  = null;

        if(imageWidth == 0 || imageHeight == 0 ||
           width == 0 || height == 0) {

            // Forget about it
            handleEmptyImage(imageElement);

        } else {
            // First set the href
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

            // Then create the transformation:
            // Because we cache image data, the stored image may
            // need to be scaled.
            af = handleTransform(imageElement, x,y,
                                 imageWidth, imageHeight,
                                 width, height, generatorContext);
        }
        return af;
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
        // In this the default case, <image> element, we just
        // set x, y, width and height attributes.
        // No additional transform is necessary.
        imageElement.setAttributeNS(null,
                                    SVG_X_ATTRIBUTE,
                                    generatorContext.doubleString(x));
        imageElement.setAttributeNS(null,
                                    SVG_Y_ATTRIBUTE,
                                    generatorContext.doubleString(y));
        imageElement.setAttributeNS(null,
                                    SVG_WIDTH_ATTRIBUTE,
                                    generatorContext.doubleString(dstWidth));
        imageElement.setAttributeNS(null,
                                    SVG_HEIGHT_ATTRIBUTE,
                                    generatorContext.doubleString(dstHeight));
        return null;
    }

    protected void handleEmptyImage(Element imageElement) {
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME, "");
        imageElement.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE, "0");
        imageElement.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE, "0");
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
                BufferedImage buf = buildBufferedImage(new Dimension(width, height));
                Graphics2D g = createGraphics(buf);
                g.drawImage(image, 0, 0, null);
                g.dispose();
                handleHREF((RenderedImage)buf, imageElement,
                           generatorContext);
            }
        }
    }

    /**
     * This method creates a BufferedImage of the right size and type
     * for the derived class.
     */
    public BufferedImage buildBufferedImage(Dimension size){
        return new BufferedImage(size.width, size.height, getBufferedImageType());
    }

    /**
     * This template method should set the xlink:href attribute on the input
     * Element parameter
     */
    protected void handleHREF(RenderedImage image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        //
        // Create an buffered image if necessary
        //
        BufferedImage buf = null;
        if (image instanceof BufferedImage
            &&
            ((BufferedImage)image).getType() == getBufferedImageType()){
            buf = (BufferedImage)image;
        } else {
            Dimension size = new Dimension(image.getWidth(), image.getHeight());
            buf = buildBufferedImage(size);

            Graphics2D g = createGraphics(buf);

            g.drawRenderedImage(image, IDENTITY);
            g.dispose();
        }

        //
        // Cache image and set xlink:href
        //
        cacheBufferedImage(imageElement, buf, generatorContext);
    }

    /**
     * This method will delegate to the <tt>handleHREF</tt> which
     * uses a <tt>RenderedImage</tt>
     */
    protected void handleHREF(RenderableImage image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        // Create an buffered image where the image will be drawn
        Dimension size = new Dimension((int)Math.ceil(image.getWidth()),
                                       (int)Math.ceil(image.getHeight()));
        BufferedImage buf = buildBufferedImage(size);

        Graphics2D g = createGraphics(buf);

        g.drawRenderableImage(image, IDENTITY);
        g.dispose();

        handleHREF((RenderedImage)buf, imageElement, generatorContext);
    }

    protected void cacheBufferedImage(Element imageElement,
                                      BufferedImage buf,
                                      SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {

        ByteArrayOutputStream os;

        if (generatorContext == null)
            throw new SVGGraphics2DRuntimeException(ERR_CONTEXT_NULL);

        try {
            os = new ByteArrayOutputStream();
            // encode the image in memory
            encodeImage(buf, os);
            os.flush();
            os.close();
        } catch (IOException e) {
            // should not happen since we do in-memory processing
            throw new SVGGraphics2DIOException(ERR_UNEXPECTED, e);
        }

        // ask the cacher for a reference
        String ref = imageCacher.lookup(os,
                                                  buf.getWidth(),
                                                  buf.getHeight(),
                                                  generatorContext);

        // set the URL
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME,
                                    getRefPrefix() + ref);
    }

    /**
     * Should return the prefix with wich the image reference
     * should be pre-concatenated.
     */
    public abstract String getRefPrefix();

    /**
     * Derived classes should implement this method and encode the input
     * BufferedImage as needed
     */
    public abstract void encodeImage(BufferedImage buf, OutputStream os)
        throws IOException;

    /**
     * This template method should be overridden by derived classes to
     * declare the image type they need for saving to file.
     */
    public abstract int getBufferedImageType();

}
