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
import java.io.File;
import java.lang.reflect.Method;
import java.net.MalformedURLException;

import org.w3c.dom.Element;

/**
 * This abstract implementation of the ImageHandler interface
 * is intended to be the base class for ImageHandlers that generate
 * image files for all the images they handle. This class stores
 * images in an configurable directory. The xlink:href value the
 * class generates is made of a configurable url root and the name
 * of the file created by this handler.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: AbstractImageHandlerEncoder.java 579230 2007-09-25 12:52:48Z cam $
 * @see             org.apache.flex.forks.batik.svggen.SVGGraphics2D
 * @see             org.apache.flex.forks.batik.svggen.ImageHandlerJPEGEncoder
 * @see             org.apache.flex.forks.batik.svggen.ImageHandlerPNGEncoder
 */
public abstract class AbstractImageHandlerEncoder extends DefaultImageHandler {
    private static final AffineTransform IDENTITY = new AffineTransform();

    /**
     * Directory where all images are placed
     */
    private String imageDir = "";

    /**
     * Value for the url root corresponding to the directory
     */
    private String urlRoot = "";

    // for createGraphics method.
    private static Method createGraphics = null;
    private static boolean initDone = false;
    private static final Class[] paramc = new Class[] {BufferedImage.class};
    private static Object[] paramo = null;

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
            } catch (ThreadDeath td) {
                throw td;
            } catch (Throwable t) {
                // happen only if Batik extensions are not there
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
     * @param imageDir directory where this handler should generate images.
     *        If null, an SVGGraphics2DRuntimeException is thrown.
     * @param urlRoot root for the urls that point to images created by this
     *        image handler. If null, then the url corresponding to imageDir
     *        is used.
     */
    public AbstractImageHandlerEncoder(String imageDir, String urlRoot)
        throws SVGGraphics2DIOException {
        if (imageDir == null)
            throw new SVGGraphics2DRuntimeException(ERR_IMAGE_DIR_NULL);

        File imageDirFile = new File(imageDir);
        if (!imageDirFile.exists())
            throw new SVGGraphics2DRuntimeException(ERR_IMAGE_DIR_DOES_NOT_EXIST);

        this.imageDir = imageDir;
        if (urlRoot != null)
            this.urlRoot = urlRoot;
        else {
            try{
                this.urlRoot = imageDirFile.toURL().toString();
            } catch (MalformedURLException e) {
                throw new SVGGraphics2DIOException(ERR_CANNOT_USE_IMAGE_DIR+
                                                   e.getMessage(),
                                                   e);
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
        // Create an buffered image where the image will be drawn
        Dimension size = new Dimension(image.getWidth(null),
                                       image.getHeight(null));
        BufferedImage buf = buildBufferedImage(size);

        Graphics2D g = createGraphics(buf);

        g.drawImage(image, 0, 0, null);
        g.dispose();

        // Save image into file
        saveBufferedImageToFile(imageElement, buf, generatorContext);
    }

    /**
     * This template method should set the xlink:href attribute on the input
     * Element parameter
     */
    protected void handleHREF(RenderedImage image, Element imageElement,
                              SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        // Create an buffered image where the image will be drawn
        Dimension size = new Dimension(image.getWidth(), image.getHeight());
        BufferedImage buf = buildBufferedImage(size);

        Graphics2D g = createGraphics(buf);

        g.drawRenderedImage(image, IDENTITY);
        g.dispose();

        // Save image into file
        saveBufferedImageToFile(imageElement, buf, generatorContext);
    }

    /**
     * This template method should set the xlink:href attribute on the input
     * Element parameter
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

        // Save image into file
        saveBufferedImageToFile(imageElement, buf, generatorContext);
    }

    private void saveBufferedImageToFile(Element imageElement,
                                         BufferedImage buf,
                                         SVGGeneratorContext generatorContext)
        throws SVGGraphics2DIOException {
        if (generatorContext == null)
            throw new SVGGraphics2DRuntimeException(ERR_CONTEXT_NULL);

        // Create a new file in image directory
        File imageFile = null;

        // While the files we are generating exist, try to create another
        // id that is unique.
        while (imageFile == null) {
            String fileId = generatorContext.idGenerator.generateID(getPrefix());
            imageFile = new File(imageDir, fileId + getSuffix());
            if (imageFile.exists())
                imageFile = null;
        }

        // Encode image here
        encodeImage(buf, imageFile);

        // Update HREF
        imageElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                    XLINK_HREF_QNAME, urlRoot + "/" +
                                    imageFile.getName());
    }

    /**
     * @return the suffix used by this encoder. E.g., ".jpg" for
     * ImageHandlerJPEGEncoder
     */
    public abstract String getSuffix();

    /**
     * @return the prefix used by this encoder. E.g., "jpegImage" for
     * ImageHandlerJPEGEncoder
     */
    public abstract String getPrefix();

    /**
     * Derived classes should implement this method and encode the input
     * BufferedImage as needed
     */
    public abstract void encodeImage(BufferedImage buf, File imageFile)
        throws SVGGraphics2DIOException;

    /**
     * This method creates a BufferedImage of the right size and type
     * for the derived class.
     */
    public abstract BufferedImage buildBufferedImage(Dimension size);
}
