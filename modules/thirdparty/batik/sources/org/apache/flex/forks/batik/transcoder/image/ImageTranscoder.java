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
package org.apache.flex.forks.batik.transcoder.image;

import java.awt.AlphaComposite;
import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;
import java.awt.image.SinglePixelPackedSampleModel;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.gvt.renderer.ConcreteImageRendererFactory;
import org.apache.flex.forks.batik.gvt.renderer.ImageRenderer;
import org.apache.flex.forks.batik.gvt.renderer.ImageRendererFactory;
import org.apache.flex.forks.batik.transcoder.SVGAbstractTranscoder;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.TranscodingHints;
import org.apache.flex.forks.batik.transcoder.keys.BooleanKey;
import org.apache.flex.forks.batik.transcoder.keys.PaintKey;
import org.w3c.dom.Document;

/**
 * This class enables to transcode an input to an image of any format.
 *
 * <p>Two transcoding hints (<tt>KEY_WIDTH</tt> and
 * <tt>KEY_HEIGHT</tt>) can be used to respectively specify the image
 * width and the image height. If only one of these keys is specified,
 * the transcoder preserves the aspect ratio of the original image.
 *
 * <p>The <tt>KEY_BACKGROUND_COLOR</tt> defines the background color
 * to use for opaque image formats, or the background color that may
 * be used for image formats that support alpha channel.
 *
 * <p>The <tt>KEY_AOI</tt> represents the area of interest to paint
 * in device space.
 *
 * <p>Three additional transcoding hints that act on the SVG
 * processor can be specified:
 *
 * <p><tt>KEY_LANGUAGE</tt> to set the default language to use (may be
 * used by a &lt;switch> SVG element for example),
 * <tt>KEY_USER_STYLESHEET_URI</tt> to fix the URI of a user
 * stylesheet, and <tt>KEY_MM_PER_PIXEL</tt> to specify the number of
 * millimeters in each pixel .
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: ImageTranscoder.java 533275 2007-04-28 01:30:54Z deweese $
 */
public abstract class ImageTranscoder extends SVGAbstractTranscoder {

    /**
     * Constructs a new <tt>ImageTranscoder</tt>.
     */
    protected ImageTranscoder() {
    }

    /**
     * Transcodes the specified Document as an image in the specified output.
     *
     * @param document the document to transcode
     * @param uri the uri of the document or null if any
     * @param output the ouput where to transcode
     * @exception TranscoderException if an error occured while transcoding
     */
    protected void transcode(Document document,
                             String uri,
                             TranscoderOutput output)
            throws TranscoderException {

        // Sets up root, curTxf & curAoi
        super.transcode(document, uri, output);

        // prepare the image to be painted
        int w = (int)(width+0.5);
        int h = (int)(height+0.5);

        // paint the SVG document using the bridge package
        // create the appropriate renderer
        ImageRenderer renderer = createRenderer();
        renderer.updateOffScreen(w, h);
        // curTxf.translate(0.5, 0.5);
        renderer.setTransform(curTxf);
        renderer.setTree(this.root);
        this.root = null; // We're done with it...

        try {
            // now we are sure that the aoi is the image size
            Shape raoi = new Rectangle2D.Float(0, 0, width, height);
            // Warning: the renderer's AOI must be in user space
            renderer.repaint(curTxf.createInverse().
                             createTransformedShape(raoi));
            BufferedImage rend = renderer.getOffScreen();
            renderer = null; // We're done with it...

            BufferedImage dest = createImage(w, h);

            Graphics2D g2d = GraphicsUtil.createGraphics(dest);
            if (hints.containsKey(KEY_BACKGROUND_COLOR)) {
                Paint bgcolor = (Paint)hints.get(KEY_BACKGROUND_COLOR);
                g2d.setComposite(AlphaComposite.SrcOver);
                g2d.setPaint(bgcolor);
                g2d.fillRect(0, 0, w, h);
            }
            if (rend != null) { // might be null if the svg document is empty
                g2d.drawRenderedImage(rend, new AffineTransform());
            }
            g2d.dispose();
            rend = null; // We're done with it...
            writeImage(dest, output);
        } catch (Exception ex) {
            throw new TranscoderException(ex);
        }
    }

    /**
     * Method so subclasses can modify the Renderer used to render document.
     */
    protected ImageRenderer createRenderer() {
        ImageRendererFactory rendFactory = new ConcreteImageRendererFactory();
        // ImageRenderer renderer = rendFactory.createDynamicImageRenderer();
        return rendFactory.createStaticImageRenderer();
    }

    /**
     * Converts an image so that viewers which do not support the
     * alpha channel will see a white background (and not a black
     * one).
     * @param img the image to convert
     * @param sppsm
     */
    protected void forceTransparentWhite(BufferedImage img, SinglePixelPackedSampleModel sppsm) {
        //
        // This is a trick so that viewers which do not support
        // the alpha channel will see a white background (and not
        // a black one).
        //
        int w = img.getWidth();
        int h = img.getHeight();
        DataBufferInt biDB=(DataBufferInt)img.getRaster().getDataBuffer();
        int scanStride = sppsm.getScanlineStride();
        int dbOffset = biDB.getOffset();
        int[] pixels = biDB.getBankData()[0];
        int p = dbOffset;
        int adjust = scanStride - w;
        int a=0, r=0, g=0, b=0, pel=0;
        for(int i=0; i<h; i++){
            for(int j=0; j<w; j++){
                pel = pixels[p];
                a = (pel >> 24) & 0xff;
                r = (pel >> 16) & 0xff;
                g = (pel >> 8 ) & 0xff;
                b =  pel        & 0xff;
                r = (255*(255 -a) + a*r)/255;
                g = (255*(255 -a) + a*g)/255;
                b = (255*(255 -a) + a*b)/255;
                pixels[p++] =
                    (a<<24 & 0xff000000) |
                    (r<<16 & 0xff0000) |
                    (g<<8  & 0xff00) |
                    (b     & 0xff);
            }
            p += adjust;
        }
    }

    /**
     * Creates a new image with the specified dimension.
     * @param width the image width in pixels
     * @param height the image height in pixels
     */
    public abstract BufferedImage createImage(int width, int height);

    /**
     * Writes the specified image to the specified output.
     * @param img the image to write
     * @param output the output where to store the image
     * @throws TranscoderException if an error occured while storing the image
     */
    public abstract void writeImage(BufferedImage img, TranscoderOutput output)
        throws TranscoderException;

    // --------------------------------------------------------------------
    // Keys definition
    // --------------------------------------------------------------------

    /**
     * The image background paint key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_BACKGROUND_COLOR</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Paint</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">null</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the background color to use.
     * The color is required by opaque image formats and is used by
     * image formats that support alpha channel.</TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_BACKGROUND_COLOR
        = new PaintKey();

    /**
     * The forceTransparentWhite key.
     *
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_FORCE_TRANSPARENT_WHITE</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Boolean</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">false</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>

     * <TD VALIGN="TOP">It controls whether the encoder should force
     * the image's fully transparent pixels to be fully transparent
     * white instead of fully transparent black.  This is usefull when
     * the encoded file is displayed in a browser which does not
     * support transparency correctly and lets the image display with
     * a white background instead of a black background. <br />
     *
     * However, note that the modified image will display differently
     * over a white background in a viewer that supports
     * transparency.<br/>
     *
     * Not all Transcoders use this key (in particular some formats
     * can't preserve the alpha channel at all in which case this
     * is not used.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_FORCE_TRANSPARENT_WHITE
        = new BooleanKey();
}
