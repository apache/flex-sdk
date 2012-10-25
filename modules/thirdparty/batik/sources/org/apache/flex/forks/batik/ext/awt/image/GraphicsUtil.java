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
package org.apache.flex.forks.batik.ext.awt.image;

import java.awt.Composite;
import java.awt.Graphics2D;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.color.ColorSpace;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.ComponentSampleModel;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferByte;
import java.awt.image.DataBufferInt;
import java.awt.image.DataBufferShort;
import java.awt.image.DataBufferUShort;
import java.awt.image.DirectColorModel;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;
import java.awt.image.renderable.RenderContext;
import java.awt.image.renderable.RenderableImage;
import java.lang.ref.Reference;
import java.lang.ref.WeakReference;

import org.apache.flex.forks.batik.ext.awt.RenderingHintsKeyExt;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PaintRable;
import org.apache.flex.forks.batik.ext.awt.image.rendered.AffineRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.Any2LsRGBRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.Any2sRGBRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.BufferedImageCachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.FormatRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.RenderedImageCachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.TranslateRed;


/**
 * Set of utility methods for Graphics.
 * These generally bypass broken methods in Java2D or provide tweaked
 * implementations.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: GraphicsUtil.java 579990 2007-09-27 12:43:14Z cam $
 */
public class GraphicsUtil {

    public static AffineTransform IDENTITY = new AffineTransform();

    /**
     * Draws <tt>ri</tt> into <tt>g2d</tt>.  It does this be
     * requesting tiles from <tt>ri</tt> and drawing them individually
     * in <tt>g2d</tt> it also takes care of some colorspace and alpha
     * issues.
     * @param g2d The Graphics2D to draw into.
     * @param ri  The image to be drawn.
     */
    public static void drawImage(Graphics2D g2d,
                                 RenderedImage ri) {
        drawImage(g2d, wrap(ri));
    }

    /**
     * Draws <tt>cr</tt> into <tt>g2d</tt>.  It does this be
     * requesting tiles from <tt>ri</tt> and drawing them individually
     * in <tt>g2d</tt> it also takes care of some colorspace and alpha
     * issues.
     * @param g2d The Graphics2D to draw into.
     * @param cr  The image to be drawn.
     */
    public static void drawImage(Graphics2D g2d,
                                 CachableRed cr) {

        // System.out.println("DrawImage G: " + g2d);

        AffineTransform at = null;
        while (true) {
            if (cr instanceof AffineRed) {
                AffineRed ar = (AffineRed)cr;
                if (at == null)
                    at = ar.getTransform();
                else
                    at.concatenate(ar.getTransform());
                cr = ar.getSource();
                continue;
            } else if (cr instanceof TranslateRed) {
                TranslateRed tr = (TranslateRed)cr;
                // System.out.println("testing Translate");
                int dx = tr.getDeltaX();
                int dy = tr.getDeltaY();
                if (at == null)
                    at = AffineTransform.getTranslateInstance(dx, dy);
                else
                    at.translate(dx, dy);
                cr = tr.getSource();
                continue;
            }
            break;
        }
        AffineTransform g2dAt   = g2d.getTransform();
        if ((at == null) || (at.isIdentity()))
            at = g2dAt;
        else
            at.preConcatenate(g2dAt);

        ColorModel srcCM = cr.getColorModel();
        ColorModel g2dCM = getDestinationColorModel(g2d);
        ColorSpace g2dCS = null;
        if (g2dCM != null)
            g2dCS = g2dCM.getColorSpace();
        if (g2dCS == null)
            // Assume device is sRGB
            g2dCS = ColorSpace.getInstance(ColorSpace.CS_sRGB);

        ColorModel drawCM = g2dCM;
        if ((g2dCM == null) || !g2dCM.hasAlpha()) {
            // If we can't find out about our device or the device
            // does not support alpha just use SRGB unpremultiplied
            // (Just because this seems to work for us).
            drawCM = sRGB_Unpre;
        }

        if (cr instanceof BufferedImageCachableRed) {
            // There is a huge win if we can use the BI directly here.
            // This results in something like a 10x performance gain
            // for images, the best thing is this is the common case.
            if (g2dCS.equals(srcCM.getColorSpace()) &&
                drawCM.equals(srcCM)) {
                // System.err.println("Fast Case");
                g2d.setTransform(at);
                BufferedImageCachableRed bicr;
                bicr = (BufferedImageCachableRed)cr;
                g2d.drawImage(bicr.getBufferedImage(),
                              bicr.getMinX(), bicr.getMinY(), null);
                g2d.setTransform(g2dAt);
                return;
            }
        }

        // Scaling down so do it before color conversion.
        double determinant = at.getDeterminant();
        if (!at.isIdentity() && (determinant <= 1.0)) {
            if (at.getType() != AffineTransform.TYPE_TRANSLATION)
                cr = new AffineRed(cr, at, g2d.getRenderingHints());
            else {
                int xloc = cr.getMinX() + (int)at.getTranslateX();
                int yloc = cr.getMinY() + (int)at.getTranslateY();
                cr = new TranslateRed(cr, xloc, yloc);
            }
        }

        if (g2dCS != srcCM.getColorSpace()) {
            // System.out.println("srcCS: " + srcCM.getColorSpace());
            // System.out.println("g2dCS: " + g2dCS);
            // System.out.println("sRGB: " +
            //                    ColorSpace.getInstance(ColorSpace.CS_sRGB));
            // System.out.println("LsRGB: " +
            //                    ColorSpace.getInstance
            //                    (ColorSpace.CS_LINEAR_RGB));
            if      (g2dCS == ColorSpace.getInstance(ColorSpace.CS_sRGB))
                cr = convertTosRGB(cr);
            else if (g2dCS == ColorSpace.getInstance(ColorSpace.CS_LINEAR_RGB))
                cr = convertToLsRGB(cr);
        }
        srcCM = cr.getColorModel();
        if (!drawCM.equals(srcCM))
            cr = FormatRed.construct(cr, drawCM);

        // Scaling up so do it after color conversion.
        if (!at.isIdentity() && (determinant > 1.0))
            cr = new AffineRed(cr, at, g2d.getRenderingHints());

        // Now CR is in device space, so clear the g2d transform.
        g2d.setTransform(IDENTITY);

        // Ugly Hack alert.  This Makes it use our SrcOver implementation
        // Which doesn't seem to have as many bugs as the JDK one when
        // going between different src's and destinations (of course it's
        // also a lot slower).
        Composite g2dComposite = g2d.getComposite();
        if (g2d.getRenderingHint(RenderingHintsKeyExt.KEY_TRANSCODING) ==
            RenderingHintsKeyExt.VALUE_TRANSCODING_PRINTING) {
            if (SVGComposite.OVER.equals(g2dComposite)) {
                g2d.setComposite(SVGComposite.OVER);
            }
        }
        Rectangle crR  = cr.getBounds();
        Shape     clip = g2d.getClip();

        try {
            Rectangle clipR;
            if (clip == null) {
                clip  = crR;
                clipR = crR;
            } else {
                clipR   = clip.getBounds();

                if ( ! clipR.intersects(crR) )
                    return; // Nothing to draw...
                clipR = clipR.intersection(crR);
            }

            Rectangle gcR = getDestinationBounds(g2d);
            // System.out.println("ClipRects: " + clipR + " -> " + gcR);
            if (gcR != null) {
                if ( ! clipR.intersects(gcR) )
                    return; // Nothing to draw...
                clipR = clipR.intersection(gcR);
            }

            // System.out.println("Starting Draw: " + cr);
            // long startTime = System.currentTimeMillis();

            boolean useDrawRenderedImage = false;

            srcCM = cr.getColorModel();
            SampleModel srcSM = cr.getSampleModel();
            if ((srcSM.getWidth()*srcSM.getHeight()) >=
                (clipR.width*clipR.height))
                // if srcSM tiles are around the clip size
                // then just draw the renderedImage
                useDrawRenderedImage = true;

            Object atpHint = g2d.getRenderingHint
                (RenderingHintsKeyExt.KEY_AVOID_TILE_PAINTING);

            if (atpHint == RenderingHintsKeyExt.VALUE_AVOID_TILE_PAINTING_ON)
                useDrawRenderedImage = true; //for PDF and PS transcoders

            if (atpHint == RenderingHintsKeyExt.VALUE_AVOID_TILE_PAINTING_OFF)
                useDrawRenderedImage = false;


            WritableRaster wr;
            if (useDrawRenderedImage) {
                // This can be significantly faster but can also
                // require much more memory, so we only use it when
                // the clip size is smaller than the tile size.
                Raster r = cr.getData(clipR);
                wr = ((WritableRaster)r).createWritableChild
                    (clipR.x, clipR.y, clipR.width, clipR.height,
                     0, 0, null);

                BufferedImage bi = new BufferedImage
                    (srcCM, wr, srcCM.isAlphaPremultiplied(), null);

                // Any of the drawImage calls that take an
                // Affine are prone to the 'CGGStackRestore: gstack
                // underflow' bug on Mac OS X.  This should work
                // around that problem.
                g2d.drawImage(bi, clipR.x, clipR.y, null);
            } else {
                // Use tiles to draw image...
                wr = Raster.createWritableRaster(srcSM, new Point(0,0));
                BufferedImage bi = new BufferedImage
                    (srcCM, wr, srcCM.isAlphaPremultiplied(), null);

                int xt0 = cr.getMinTileX();
                int xt1 = xt0+cr.getNumXTiles();
                int yt0 = cr.getMinTileY();
                int yt1 = yt0+cr.getNumYTiles();
                int tw  = srcSM.getWidth();
                int th  = srcSM.getHeight();

                Rectangle tR  = new Rectangle(0,0,tw,th);
                Rectangle iR  = new Rectangle(0,0,0,0);

                if (false) {
                    System.err.println("SrcCM: " + srcCM);
                    System.err.println("CR: " + cr);
                    System.err.println("CRR: " + crR + " TG: [" +
                                       xt0 + ',' +
                                       yt0 + ',' +
                                       xt1 + ',' +
                                       yt1 +"] Off: " +
                                       cr.getTileGridXOffset() + ',' +
                                       cr.getTileGridYOffset());
                }

                int yloc = yt0*th+cr.getTileGridYOffset();
                int skip = (clipR.y-yloc)/th;
                if (skip <0) skip = 0;
                yt0+=skip;

                int xloc = xt0*tw+cr.getTileGridXOffset();
                skip = (clipR.x-xloc)/tw;
                if (skip <0) skip = 0;
                xt0+=skip;

                int endX = clipR.x+clipR.width-1;
                int endY = clipR.y+clipR.height-1;

                if (false) {
                    System.out.println("clipR: " + clipR + " TG: [" +
                                       xt0 + ',' +
                                       yt0 + ',' +
                                       xt1 + ',' +
                                       yt1 +"] Off: " +
                                       cr.getTileGridXOffset() + ',' +
                                       cr.getTileGridYOffset());
                }


                yloc = yt0*th+cr.getTileGridYOffset();
                int minX = xt0*tw+cr.getTileGridXOffset();
                int xStep = tw;
                xloc = minX;
                for (int y=yt0; y<yt1; y++, yloc += th) {
                    if (yloc > endY) break;
                    for (int x=xt0; x<xt1; x++, xloc+=xStep) {
                        if ((xloc<minX) || (xloc > endX)) break;
                        tR.x = xloc;
                        tR.y = yloc;
                        Rectangle2D.intersect(crR, tR, iR);

                        WritableRaster twr;
                        twr = wr.createWritableChild(0, 0,
                                                     iR.width, iR.height,
                                                     iR.x, iR.y, null);

                        // System.out.println("Generating tile: " + twr);
                        cr.copyData(twr);

                        // Make sure we only draw the region that was written.
                        BufferedImage subBI;
                        subBI = bi.getSubimage(0, 0, iR.width,  iR.height);

                        if (false) {
                            System.out.println("Drawing: " + tR);
                            System.out.println("IR: "      + iR);
                        }

                        // For some reason using the transform version
                        // causes a gStackUnderflow error but if I just
                        // use the drawImage with an x & y it works.
                        g2d.drawImage(subBI, iR.x, iR.y, null);
                        // AffineTransform trans
                        //  = AffineTransform.getTranslateInstance(iR.x, iR.y);
                        // g2d.drawImage(subBI, trans, null);

                        // String label = "sub [" + x + ", " + y + "]: ";
                        // org.ImageDisplay.showImage
                        //     (label, subBI);
                    }
                    xStep = -xStep; // Reverse directions.
                    xloc += xStep;   // Get back in bounds.
                }
            }
            // long endTime = System.currentTimeMillis();
            // System.out.println("Time: " + (endTime-startTime));


        } finally {
            g2d.setTransform(g2dAt);
            g2d.setComposite(g2dComposite);
        }

        // System.out.println("Finished Draw");
    }


    /**
     * Draws a <tt>Filter</tt> (<tt>RenderableImage</tt>) into a
     * Graphics 2D after taking into account a particular
     * <tt>RenderContext</tt>.<p>
     *
     * This method also attempts to unwind the rendering chain a bit.
     * So it knows about certain operations (like affine, pad,
     * composite), rather than applying each of these operations in
     * turn it accounts for their affects through modifications to the
     * Graphics2D. This avoids generating lots of intermediate images.
     *
     * @param g2d    The Graphics to draw into.
     * @param filter The filter to draw
     * @param rc The render context that controls the drawing operation.
     */
    public static void drawImage(Graphics2D      g2d,
                                 RenderableImage filter,
                                 RenderContext   rc) {

        AffineTransform origDev  = g2d.getTransform();
        Shape           origClip = g2d.getClip();
        RenderingHints  origRH   = g2d.getRenderingHints();

        Shape clip = rc.getAreaOfInterest();
        if (clip != null)
            g2d.clip(clip);
        g2d.transform(rc.getTransform());
        g2d.setRenderingHints(rc.getRenderingHints());

        drawImage(g2d, filter);

        g2d.setTransform(origDev);
        g2d.setClip(origClip);
        g2d.setRenderingHints(origRH);
    }

    /**
     * Draws a <tt>Filter</tt> (<tt>RenderableImage</tt>) into a
     * Graphics 2D.<p>
     *
     * This method also attempts to unwind the rendering chain a bit.
     * So it knows about certain operations (like affine, pad,
     * composite), rather than applying each of these operations in
     * turn it accounts for their affects through modifications to the
     * Graphics2D.  This avoids generating lots of intermediate images.
     *
     * @param g2d    The Graphics to draw into.
     * @param filter The filter to draw
     */
    public static void drawImage(Graphics2D g2d,
                                 RenderableImage filter) {
        if (filter instanceof PaintRable) {
            PaintRable pr = (PaintRable)filter;
            if (pr.paintRable(g2d))
                // paintRable succeeded so we are done...
                return;
        }

        // Get our sources image...
        // System.out.println("UnOpt: " + filter);
        AffineTransform at = g2d.getTransform();
        RenderedImage ri = filter.createRendering
            (new RenderContext(at, g2d.getClip(), g2d.getRenderingHints()));

        if (ri == null)
            return;

        g2d.setTransform(IDENTITY);
        drawImage(g2d, GraphicsUtil.wrap(ri));
        g2d.setTransform(at);
    }

    /**
     * This is a wrapper around the system's
     * BufferedImage.createGraphics that arranges for bi to be stored
     * in a Rendering hint in the returned Graphics2D.
     * This allows for accurate determination of the 'devices' size,
     * and colorspace.
     * @param bi The BufferedImage that the returned Graphics should
     *           draw into.
     * @return A Graphics2D that draws into BufferedImage with <tt>bi</tt>
     *         stored in a rendering hint.
     */
    public static Graphics2D createGraphics(BufferedImage bi,
                                            RenderingHints hints) {
        Graphics2D g2d = bi.createGraphics();
        if (hints != null)
            g2d.addRenderingHints(hints);
        g2d.setRenderingHint(RenderingHintsKeyExt.KEY_BUFFERED_IMAGE,
                             new WeakReference(bi));
        g2d.clip(new Rectangle(0, 0, bi.getWidth(), bi.getHeight()));
        return g2d;
    }


    public static Graphics2D createGraphics(BufferedImage bi) {
        Graphics2D g2d = bi.createGraphics();
        g2d.setRenderingHint(RenderingHintsKeyExt.KEY_BUFFERED_IMAGE,
                             new WeakReference(bi));
        g2d.clip(new Rectangle(0, 0, bi.getWidth(), bi.getHeight()));
        return g2d;
    }


    public static final boolean WARN_DESTINATION;

    static {
        boolean warn = true;
        try {
            String s = System.getProperty
                ("org.apache.flex.forks.batik.warn_destination", "true");
            warn = Boolean.valueOf(s).booleanValue();
        } catch (SecurityException se) {
        } catch (NumberFormatException nfe) {
        } finally {
            WARN_DESTINATION = warn;
        }
    }

    public static BufferedImage getDestination(Graphics2D g2d) {
        Object o = g2d.getRenderingHint
            (RenderingHintsKeyExt.KEY_BUFFERED_IMAGE);
        if (o != null)
            return (BufferedImage)(((Reference)o).get());

        // Check if this is a BufferedImage G2d if so throw an error...
        GraphicsConfiguration gc = g2d.getDeviceConfiguration();
        if (gc == null) {
            return null;
        }

        GraphicsDevice gd = gc.getDevice();
        if (WARN_DESTINATION &&
            (gd.getType() == GraphicsDevice.TYPE_IMAGE_BUFFER) &&
            (g2d.getRenderingHint(RenderingHintsKeyExt.KEY_TRANSCODING) !=
                RenderingHintsKeyExt.VALUE_TRANSCODING_PRINTING))
            // throw new IllegalArgumentException
            System.err.println
                ("Graphics2D from BufferedImage lacks BUFFERED_IMAGE hint");

        return null;
    }

    public static ColorModel getDestinationColorModel(Graphics2D g2d) {
        BufferedImage bi = getDestination(g2d);
        if (bi != null) {
            return bi.getColorModel();
        }

        GraphicsConfiguration gc = g2d.getDeviceConfiguration();
        if (gc == null) {
            return null; // Can't tell
        }

        // We are going to a BufferedImage but no hint was provided
        // so we can't determine the destination Color Model.
        if (gc.getDevice().getType() == GraphicsDevice.TYPE_IMAGE_BUFFER) {
            if (g2d.getRenderingHint(RenderingHintsKeyExt.KEY_TRANSCODING) ==
                RenderingHintsKeyExt.VALUE_TRANSCODING_PRINTING)
                return sRGB_Unpre;

            // System.out.println("CM: " + gc.getColorModel());
            // System.out.println("CS: " + gc.getColorModel().getColorSpace());
            return null;
        }

        return gc.getColorModel();
    }

    public static ColorSpace getDestinationColorSpace(Graphics2D g2d) {
        ColorModel cm = getDestinationColorModel(g2d);
        if (cm != null) return cm.getColorSpace();

        return null;
    }

    public static Rectangle getDestinationBounds(Graphics2D g2d) {
        BufferedImage bi = getDestination(g2d);
        if (bi != null) {
            return new Rectangle(0, 0, bi.getWidth(), bi.getHeight());
        }

        GraphicsConfiguration gc = g2d.getDeviceConfiguration();
        if (gc == null) {
            return null;
        }

        // We are going to a BufferedImage but no hint was provided
        // so we can't determine the destination bounds.
        if (gc.getDevice().getType() == GraphicsDevice.TYPE_IMAGE_BUFFER) {
            return null;
        }

        // This is a JDK 1.3ism, so we will just return null...
        // return gc.getBounds();
        return null;
    }


    /**
     * Standard prebuilt Linear_sRGB color model with no alpha */
    public static final ColorModel Linear_sRGB =
        new DirectColorModel(ColorSpace.getInstance
                             (ColorSpace.CS_LINEAR_RGB), 24,
                             0x00FF0000, 0x0000FF00,
                             0x000000FF, 0x0, false,
                             DataBuffer.TYPE_INT);
    /**
     * Standard prebuilt Linear_sRGB color model with premultiplied alpha.
     */
    public static final ColorModel Linear_sRGB_Pre =
        new DirectColorModel(ColorSpace.getInstance
                             (ColorSpace.CS_LINEAR_RGB), 32,
                             0x00FF0000, 0x0000FF00,
                             0x000000FF, 0xFF000000, true,
                             DataBuffer.TYPE_INT);
    /**
     * Standard prebuilt Linear_sRGB color model with unpremultiplied alpha.
     */
    public static final ColorModel Linear_sRGB_Unpre =
        new DirectColorModel(ColorSpace.getInstance
                             (ColorSpace.CS_LINEAR_RGB), 32,
                             0x00FF0000, 0x0000FF00,
                             0x000000FF, 0xFF000000, false,
                             DataBuffer.TYPE_INT);

    /**
     * Standard prebuilt sRGB color model with no alpha.
     */
    public static final ColorModel sRGB =
        new DirectColorModel(ColorSpace.getInstance
                             (ColorSpace.CS_sRGB), 24,
                             0x00FF0000, 0x0000FF00,
                             0x000000FF, 0x0, false,
                             DataBuffer.TYPE_INT);
    /**
     * Standard prebuilt sRGB color model with premultiplied alpha.
     */
    public static final ColorModel sRGB_Pre =
        new DirectColorModel(ColorSpace.getInstance
                             (ColorSpace.CS_sRGB), 32,
                             0x00FF0000, 0x0000FF00,
                             0x000000FF, 0xFF000000, true,
                             DataBuffer.TYPE_INT);
    /**
     * Standard prebuilt sRGB color model with unpremultiplied alpha.
     */
    public static final ColorModel sRGB_Unpre =
        new DirectColorModel(ColorSpace.getInstance
                             (ColorSpace.CS_sRGB), 32,
                             0x00FF0000, 0x0000FF00,
                             0x000000FF, 0xFF000000, false,
                             DataBuffer.TYPE_INT);

    /**
     * Method that returns either Linear_sRGB_Pre or Linear_sRGB_UnPre
     * based on premult flag.
     * @param premult True if the ColorModel should have premultiplied alpha.
     * @return        a ColorMdoel with Linear sRGB colorSpace and
     *                the alpha channel set in accordance with
     *                <tt>premult</tt>
     */
    public static ColorModel makeLinear_sRGBCM( boolean premult ) {

         return premult ? Linear_sRGB_Pre : Linear_sRGB_Unpre;
    }

    /**
     * Constructs a BufferedImage with a linear sRGB colorModel, and alpha.
     * @param width   The desired width of the BufferedImage
     * @param height  The desired height of the BufferedImage
     * @param premult The desired state of alpha premultiplied
     * @return        The requested BufferedImage.
     */
    public static BufferedImage makeLinearBufferedImage(int width,
                                                        int height,
                                                        boolean premult) {
        ColorModel cm = makeLinear_sRGBCM(premult);
        WritableRaster wr = cm.createCompatibleWritableRaster(width, height);
        return new BufferedImage(cm, wr, premult, null);
    }

    /**
     * This method will return a CacheableRed that has it's data in
     * the linear sRGB colorspace. If <tt>src</tt> is already in
     * linear sRGB then this method does nothing and returns <tt>src</tt>.
     * Otherwise it creates a transform that will convert
     * <tt>src</tt>'s output to linear sRGB and returns that CacheableRed.
     *
     * @param src The image to convert to linear sRGB.
     * @return    An equivilant image to <tt>src</tt> who's data is in
     *            linear sRGB.
     */
    public static CachableRed convertToLsRGB(CachableRed src) {
        ColorModel cm = src.getColorModel();
        ColorSpace cs = cm.getColorSpace();
        if (cs == ColorSpace.getInstance(ColorSpace.CS_LINEAR_RGB))
            return src;

        return new Any2LsRGBRed(src);
    }

    /**
     * This method will return a CacheableRed that has it's data in
     * the sRGB colorspace. If <tt>src</tt> is already in
     * sRGB then this method does nothing and returns <tt>src</tt>.
     * Otherwise it creates a transform that will convert
     * <tt>src</tt>'s output to sRGB and returns that CacheableRed.
     *
     * @param src The image to convert to sRGB.
     * @return    An equivilant image to <tt>src</tt> who's data is in sRGB.
     */
    public static CachableRed convertTosRGB(CachableRed src) {
        ColorModel cm = src.getColorModel();
        ColorSpace cs = cm.getColorSpace();
        if (cs == ColorSpace.getInstance(ColorSpace.CS_sRGB))
            return src;

        return new Any2sRGBRed(src);
    }

    /**
     * Convertes any RenderedImage to a CacheableRed.  <p>
     * If <tt>ri</tt> is already a CacheableRed it casts it down and
     * returns it.<p>
     *
     * In cases where <tt>ri</tt> is not already a CacheableRed it
     * wraps <tt>ri</tt> with a helper class.  The wrapped
     * CacheableRed "Pretends" that it has no sources since it has no
     * way of inteligently handling the dependency/dirty region calls
     * if it exposed the source.
     * @param ri The RenderedImage to convert.
     * @return   a CacheableRed that contains the same data as ri.
     */
    public static CachableRed wrap(RenderedImage ri) {
        if (ri instanceof CachableRed)
            return (CachableRed) ri;
        if (ri instanceof BufferedImage)
            return new BufferedImageCachableRed((BufferedImage)ri);
        return new RenderedImageCachableRed(ri);
    }

    /**
     * An internal optimized version of copyData designed to work on
     * Integer packed data with a SinglePixelPackedSampleModel.  Only
     * the region of overlap between src and dst is copied.
     *
     * Calls to this should be preflighted with is_INT_PACK_Data
     * on both src and dest (requireAlpha can be false).
     *
     * @param src The source of the data
     * @param dst The destination for the data.
     */
    public static void copyData_INT_PACK(Raster src, WritableRaster dst) {
        // System.out.println("Fast copyData");
        int x0 = dst.getMinX();
        if (x0 < src.getMinX()) x0 = src.getMinX();

        int y0 = dst.getMinY();
        if (y0 < src.getMinY()) y0 = src.getMinY();

        int x1 = dst.getMinX()+dst.getWidth()-1;
        if (x1 > src.getMinX()+src.getWidth()-1)
            x1 = src.getMinX()+src.getWidth()-1;

        int y1 = dst.getMinY()+dst.getHeight()-1;
        if (y1 > src.getMinY()+src.getHeight()-1)
            y1 = src.getMinY()+src.getHeight()-1;

        int width  = x1-x0+1;
        int height = y1-y0+1;

        SinglePixelPackedSampleModel srcSPPSM;
        srcSPPSM = (SinglePixelPackedSampleModel)src.getSampleModel();

        final int     srcScanStride = srcSPPSM.getScanlineStride();
        DataBufferInt srcDB         = (DataBufferInt)src.getDataBuffer();
        final int []  srcPixels     = srcDB.getBankData()[0];
        final int     srcBase =
            (srcDB.getOffset() +
             srcSPPSM.getOffset(x0-src.getSampleModelTranslateX(),
                                y0-src.getSampleModelTranslateY()));


        SinglePixelPackedSampleModel dstSPPSM;
        dstSPPSM = (SinglePixelPackedSampleModel)dst.getSampleModel();

        final int     dstScanStride = dstSPPSM.getScanlineStride();
        DataBufferInt dstDB         = (DataBufferInt)dst.getDataBuffer();
        final int []  dstPixels     = dstDB.getBankData()[0];
        final int     dstBase =
            (dstDB.getOffset() +
             dstSPPSM.getOffset(x0-dst.getSampleModelTranslateX(),
                                y0-dst.getSampleModelTranslateY()));

        if ((srcScanStride == dstScanStride) &&
            (srcScanStride == width)) {
            // System.out.println("VERY Fast copyData");

            System.arraycopy(srcPixels, srcBase, dstPixels, dstBase,
                             width*height);
        } else if (width > 128) {
            int srcSP = srcBase;
            int dstSP = dstBase;
            for (int y=0; y<height; y++) {
                System.arraycopy(srcPixels, srcSP, dstPixels, dstSP, width);
                srcSP += srcScanStride;
                dstSP += dstScanStride;
            }
        } else {
            for (int y=0; y<height; y++) {
                int srcSP = srcBase+y*srcScanStride;
                int dstSP = dstBase+y*dstScanStride;
                for (int x=0; x<width; x++)
                    dstPixels[dstSP++] = srcPixels[srcSP++];
            }
        }
    }

    public static void copyData_FALLBACK(Raster src, WritableRaster dst) {
        // System.out.println("Fallback copyData");

        int x0 = dst.getMinX();
        if (x0 < src.getMinX()) x0 = src.getMinX();

        int y0 = dst.getMinY();
        if (y0 < src.getMinY()) y0 = src.getMinY();

        int x1 = dst.getMinX()+dst.getWidth()-1;
        if (x1 > src.getMinX()+src.getWidth()-1)
            x1 = src.getMinX()+src.getWidth()-1;

        int y1 = dst.getMinY()+dst.getHeight()-1;
        if (y1 > src.getMinY()+src.getHeight()-1)
            y1 = src.getMinY()+src.getHeight()-1;

        int width  = x1-x0+1;
        int [] data = null;

        for (int y = y0; y <= y1 ; y++)  {
            data = src.getPixels(x0,y,width,1,data);
            dst.setPixels       (x0,y,width,1,data);
        }
    }

    /**
     * Copies data from one raster to another. Only the region of
     * overlap between src and dst is copied.  <tt>Src</tt> and
     * <tt>Dst</tt> must have compatible SampleModels.
     *
     * @param src The source of the data
     * @param dst The destination for the data.
     */
    public static void copyData(Raster src, WritableRaster dst) {
        if (is_INT_PACK_Data(src.getSampleModel(), false) &&
            is_INT_PACK_Data(dst.getSampleModel(), false)) {
            copyData_INT_PACK(src, dst);
            return;
        }

        copyData_FALLBACK(src, dst);
    }

    /**
     * Creates a new raster that has a <b>copy</b> of the data in
     * <tt>ras</tt>.  This is highly optimized for speed.  There is
     * no provision for changing any aspect of the SampleModel.
     *
     * This method should be used when you need to change the contents
     * of a Raster that you do not "own" (ie the result of a
     * <tt>getData</tt> call).
     * @param ras The Raster to copy.
     * @return    A writable copy of <tt>ras</tt>
     */
    public static WritableRaster copyRaster(Raster ras) {
        return copyRaster(ras, ras.getMinX(), ras.getMinY());
    }


    /**
     * Creates a new raster that has a <b>copy</b> of the data in
     * <tt>ras</tt>.  This is highly optimized for speed.  There is
     * no provision for changing any aspect of the SampleModel.
     * However you can specify a new location for the returned raster.
     *
     * This method should be used when you need to change the contents
     * of a Raster that you do not "own" (ie the result of a
     * <tt>getData</tt> call).
     *
     * @param ras The Raster to copy.
     *
     * @param minX The x location for the upper left corner of the
     *             returned WritableRaster.
     *
     * @param minY The y location for the upper left corner of the
     *             returned WritableRaster.
     *
     * @return    A writable copy of <tt>ras</tt>
     */
    public static WritableRaster copyRaster(Raster ras, int minX, int minY) {
        WritableRaster ret = Raster.createWritableRaster
            (ras.getSampleModel(),
             new Point(0,0));
        ret = ret.createWritableChild
            (ras.getMinX()-ras.getSampleModelTranslateX(),
             ras.getMinY()-ras.getSampleModelTranslateY(),
             ras.getWidth(), ras.getHeight(),
             minX, minY, null);

        // Use System.arraycopy to copy the data between the two...
        DataBuffer srcDB = ras.getDataBuffer();
        DataBuffer retDB = ret.getDataBuffer();
        if (srcDB.getDataType() != retDB.getDataType()) {
            throw new IllegalArgumentException
                ("New DataBuffer doesn't match original");
        }
        int len   = srcDB.getSize();
        int banks = srcDB.getNumBanks();
        int [] offsets = srcDB.getOffsets();
        for (int b=0; b< banks; b++) {
            switch (srcDB.getDataType()) {
            case DataBuffer.TYPE_BYTE: {
                DataBufferByte srcDBT = (DataBufferByte)srcDB;
                DataBufferByte retDBT = (DataBufferByte)retDB;
                System.arraycopy(srcDBT.getData(b), offsets[b],
                                 retDBT.getData(b), offsets[b], len);
                break;
            }
            case DataBuffer.TYPE_INT: {
                DataBufferInt srcDBT = (DataBufferInt)srcDB;
                DataBufferInt retDBT = (DataBufferInt)retDB;
                System.arraycopy(srcDBT.getData(b), offsets[b],
                                 retDBT.getData(b), offsets[b], len);
                break;
            }
            case DataBuffer.TYPE_SHORT: {
                DataBufferShort srcDBT = (DataBufferShort)srcDB;
                DataBufferShort retDBT = (DataBufferShort)retDB;
                System.arraycopy(srcDBT.getData(b), offsets[b],
                                 retDBT.getData(b), offsets[b], len);
                break;
            }
            case DataBuffer.TYPE_USHORT: {
                DataBufferUShort srcDBT = (DataBufferUShort)srcDB;
                DataBufferUShort retDBT = (DataBufferUShort)retDB;
                System.arraycopy(srcDBT.getData(b), offsets[b],
                                 retDBT.getData(b), offsets[b], len);
                break;
            }
            }
        }

        return ret;
    }

    /**
     * Coerces <tt>ras</tt> to be writable.  The returned Raster continues to
     * reference the DataBuffer from ras, so modifications to the returned
     * WritableRaster will be seen in ras.<p>
     *
     * This method should only be used if you need a WritableRaster due to
     * an interface (such as to construct a BufferedImage), but have no
     * intention of modifying the contents of the returned Raster.  If
     * you have any doubt about other users of the data in <tt>ras</tt>,
     * use copyRaster (above).
     * @param ras The raster to make writable.
     * @return    A Writable version of ras (shares DataBuffer with
     *            <tt>ras</tt>).
     */
    public static WritableRaster makeRasterWritable(Raster ras) {
        return makeRasterWritable(ras, ras.getMinX(), ras.getMinY());
    }

    /**
     * Coerces <tt>ras</tt> to be writable.  The returned Raster continues to
     * reference the DataBuffer from ras, so modifications to the returned
     * WritableRaster will be seen in ras.<p>
     *
     * You can specify a new location for the returned WritableRaster, this
     * is especially useful for constructing BufferedImages which require
     * the Raster to be at (0,0).
     *
     * This method should only be used if you need a WritableRaster due to
     * an interface (such as to construct a BufferedImage), but have no
     * intention of modifying the contents of the returned Raster.  If
     * you have any doubt about other users of the data in <tt>ras</tt>,
     * use copyRaster (above).
     *
     * @param ras The raster to make writable.
     *
     * @param minX The x location for the upper left corner of the
     *             returned WritableRaster.
     *
     * @param minY The y location for the upper left corner of the
     *             returned WritableRaster.
     *
     * @return A Writable version of <tT>ras</tt> with it's upper left
     *         hand coordinate set to minX, minY (shares it's DataBuffer
     *         with <tt>ras</tt>).
     */
    public static WritableRaster makeRasterWritable(Raster ras,
                                                    int minX, int minY) {
        WritableRaster ret = Raster.createWritableRaster
            (ras.getSampleModel(),
             ras.getDataBuffer(),
             new Point(0,0));
        ret = ret.createWritableChild
            (ras.getMinX()-ras.getSampleModelTranslateX(),
             ras.getMinY()-ras.getSampleModelTranslateY(),
             ras.getWidth(), ras.getHeight(),
             minX, minY, null);
        return ret;
    }

    /**
     * Create a new ColorModel with it's alpha premultiplied state matching
     * newAlphaPreMult.
     * @param cm The ColorModel to change the alpha premult state of.
     * @param newAlphaPreMult The new state of alpha premult.
     * @return   A new colorModel that has isAlphaPremultiplied()
     *           equal to newAlphaPreMult.
     */
    public static ColorModel
        coerceColorModel(ColorModel cm, boolean newAlphaPreMult) {
        if (cm.isAlphaPremultiplied() == newAlphaPreMult)
            return cm;

        // Easiest way to build proper colormodel for new Alpha state...
        // Eventually this should switch on known ColorModel types and
        // only fall back on this hack when the CM type is unknown.
        WritableRaster wr = cm.createCompatibleWritableRaster(1,1);
        return cm.coerceData(wr, newAlphaPreMult);
    }

    /**
     * Coerces data within a bufferedImage to match newAlphaPreMult,
     * Note that this can not change the colormodel of bi so you
     *
     * @param wr The raster to change the state of.
     * @param cm The colormodel currently associated with data in wr.
     * @param newAlphaPreMult The desired state of alpha Premult for raster.
     * @return A new colormodel that matches newAlphaPreMult.
     */
    public static ColorModel
        coerceData(WritableRaster wr, ColorModel cm, boolean newAlphaPreMult) {

        // System.out.println("CoerceData: " + cm.isAlphaPremultiplied() +
        //                    " Out: " + newAlphaPreMult);
        if ( ! cm.hasAlpha() )
            // Nothing to do no alpha channel
            return cm;

        if (cm.isAlphaPremultiplied() == newAlphaPreMult)
            // nothing to do alpha state matches...
            return cm;

        // System.out.println("CoerceData: " + wr.getSampleModel());

        if (newAlphaPreMult) {
            multiplyAlpha(wr);
        } else {
            divideAlpha(wr);
        }

        return coerceColorModel(cm, newAlphaPreMult);
    }

    public static void multiplyAlpha(WritableRaster wr) {
        if (is_BYTE_COMP_Data(wr.getSampleModel()))
            mult_BYTE_COMP_Data(wr);
        else if (is_INT_PACK_Data(wr.getSampleModel(), true))
            mult_INT_PACK_Data(wr);
        else {
            int [] pixel = null;
            int    bands = wr.getNumBands();
            float  norm = 1.0f/255f;
            int x0, x1, y0, y1, a, b;
            float alpha;
            x0 = wr.getMinX();
            x1 = x0+wr.getWidth();
            y0 = wr.getMinY();
            y1 = y0+wr.getHeight();
            for (int y=y0; y<y1; y++)
                for (int x=x0; x<x1; x++) {
                    pixel = wr.getPixel(x,y,pixel);
                    a = pixel[bands-1];
                    if ((a >= 0) && (a < 255)) {
                        alpha = a*norm;
                        for (b=0; b<bands-1; b++)
                            pixel[b] = (int)(pixel[b]*alpha+0.5f);
                        wr.setPixel(x,y,pixel);
                    }
                }
        }
    }

    public static void divideAlpha(WritableRaster wr) {
        if (is_BYTE_COMP_Data(wr.getSampleModel()))
            divide_BYTE_COMP_Data(wr);
        else if (is_INT_PACK_Data(wr.getSampleModel(), true))
            divide_INT_PACK_Data(wr);
        else {
            int x0, x1, y0, y1, a, b;
            float ialpha;
            int    bands = wr.getNumBands();
            int [] pixel = null;

            x0 = wr.getMinX();
            x1 = x0+wr.getWidth();
            y0 = wr.getMinY();
            y1 = y0+wr.getHeight();
            for (int y=y0; y<y1; y++)
                for (int x=x0; x<x1; x++) {
                    pixel = wr.getPixel(x,y,pixel);
                    a = pixel[bands-1];
                    if ((a > 0) && (a < 255)) {
                        ialpha = 255/(float)a;
                        for (b=0; b<bands-1; b++)
                            pixel[b] = (int)(pixel[b]*ialpha+0.5f);
                        wr.setPixel(x,y,pixel);
                    }
                }
        }
    }

    /**
     * Copies data from one bufferedImage to another paying attention
     * to the state of AlphaPreMultiplied.
     *
     * @param src The source
     * @param dst The destination
     */
    public static void
        copyData(BufferedImage src, BufferedImage dst) {
        Rectangle srcRect = new Rectangle(0, 0,
                                          src.getWidth(), src.getHeight());
        copyData(src, srcRect, dst, new Point(0,0));
    }


    /**
     * Copies data from one bufferedImage to another paying attention
     * to the state of AlphaPreMultiplied.
     *
     * @param src The source
     * @param srcRect The Rectangle of source data to be copied
     * @param dst The destination
     * @param destP The Place for the upper left corner of srcRect in dst.
     */
    public static void
        copyData(BufferedImage src, Rectangle srcRect,
                 BufferedImage dst, Point destP) {

       /*
        if (srcCS != dstCS)
            throw new IllegalArgumentException
                ("Images must be in the same ColorSpace in order "+
                 "to copy Data between them");
        */
        boolean srcAlpha = src.getColorModel().hasAlpha();
        boolean dstAlpha = dst.getColorModel().hasAlpha();

        // System.out.println("Src has: " + srcAlpha +
        //                    " is: " + src.isAlphaPremultiplied());
        //
        // System.out.println("Dst has: " + dstAlpha +
        //                    " is: " + dst.isAlphaPremultiplied());

        if (srcAlpha == dstAlpha)
            if (( ! srcAlpha ) ||
                (src.isAlphaPremultiplied() == dst.isAlphaPremultiplied())) {
                // They match one another so just copy everything...
                copyData(src.getRaster(), dst.getRaster());
                return;
            }

        // System.out.println("Using Slow CopyData");

        int [] pixel = null;
        Raster         srcR  = src.getRaster();
        WritableRaster dstR  = dst.getRaster();
        int            bands = dstR.getNumBands();

        int dx = destP.x-srcRect.x;
        int dy = destP.y-srcRect.y;

        int w  = srcRect.width;
        int x0 = srcRect.x;
        int y0 = srcRect.y;
        int y1 = y0+srcRect.height-1;

        if (!srcAlpha) {
            // Src has no alpha dest does so set alpha to 1.0 everywhere.
            // System.out.println("Add Alpha");
            int [] oPix = new int[bands*w];
            int out = (w*bands)-1; // The 2 skips alpha channel
            while(out >= 0) {
                // Fill alpha channel with 255's
                oPix[out] = 255;
                out -= bands;
            }

            int b, in;
            for (int y=y0; y<=y1; y++) {
                pixel = srcR.getPixels(x0,y,w,1,pixel);
                in  = w*(bands-1)-1;
                out = (w*bands)-2; // The 2 skips alpha channel on last pix
                switch (bands) {
                case 4:
                    while(in >= 0) {
                        oPix[out--] = pixel[in--];
                        oPix[out--] = pixel[in--];
                        oPix[out--] = pixel[in--];
                        out--;
                    }
                    break;
                default:
                    while(in >= 0) {
                        for (b=0; b<bands-1; b++)
                            oPix[out--] = pixel[in--];
                        out--;
                    }
                }
                dstR.setPixels(x0+dx, y+dy, w, 1, oPix);
            }
        } else if (dstAlpha && dst.isAlphaPremultiplied()) {
            // Src and dest have Alpha but we need to multiply it for dst.
            // System.out.println("Mult Case");
            int a, b, alpha, in, fpNorm = (1<<24)/255, pt5 = 1<<23;
            for (int y=y0; y<=y1; y++) {
                pixel = srcR.getPixels(x0,y,w,1,pixel);
                in=bands*w-1;
                switch (bands) {
                case 4:
                    while(in >= 0) {
                        a = pixel[in];
                        if (a == 255)
                            in -= 4;
                        else {
                            in--;
                            alpha = fpNorm*a;
                            pixel[in] = (pixel[in]*alpha+pt5)>>>24; in--;
                            pixel[in] = (pixel[in]*alpha+pt5)>>>24; in--;
                            pixel[in] = (pixel[in]*alpha+pt5)>>>24; in--;
                        }
                    }
                    break;
                default:
                    while(in >= 0) {
                        a = pixel[in];
                        if (a == 255)
                            in -= bands;
                        else {
                            in--;
                            alpha = fpNorm*a;
                            for (b=0; b<bands-1; b++) {
                                pixel[in] = (pixel[in]*alpha+pt5)>>>24;
                                in--;
                            }
                        }
                    }
                }
                dstR.setPixels(x0+dx, y+dy, w, 1, pixel);
            }
        } else if (dstAlpha && !dst.isAlphaPremultiplied()) {
            // Src and dest have Alpha but we need to divide it out for dst.
            // System.out.println("Div Case");
            int a, b, ialpha, in, fpNorm = 0x00FF0000, pt5 = 1<<15;
            for (int y=y0; y<=y1; y++) {
                pixel = srcR.getPixels(x0,y,w,1,pixel);
                in=(bands*w)-1;
                switch(bands) {
                case 4:
                    while(in >= 0) {
                        a = pixel[in];
                        if ((a <= 0) || (a >= 255))
                            in -= 4;
                        else {
                            in--;
                            ialpha = fpNorm/a;
                            pixel[in] = (pixel[in]*ialpha+pt5)>>>16; in--;
                            pixel[in] = (pixel[in]*ialpha+pt5)>>>16; in--;
                            pixel[in] = (pixel[in]*ialpha+pt5)>>>16; in--;
                        }
                    }
                    break;
                default:
                    while(in >= 0) {
                        a = pixel[in];
                        if ((a <= 0) || (a >= 255))
                            in -= bands;
                        else {
                            in--;
                            ialpha = fpNorm/a;
                            for (b=0; b<bands-1; b++) {
                                pixel[in] = (pixel[in]*ialpha+pt5)>>>16;
                                in--;
                            }
                        }
                    }
                }
                dstR.setPixels(x0+dx, y+dy, w, 1, pixel);
            }
        } else if (src.isAlphaPremultiplied()) {
            int [] oPix = new int[bands*w];
            // Src has alpha dest does not so unpremult and store...
            // System.out.println("Remove Alpha, Div Case");
            int a, b, ialpha, in, out, fpNorm = 0x00FF0000, pt5 = 1<<15;
            for (int y=y0; y<=y1; y++) {
                pixel = srcR.getPixels(x0,y,w,1,pixel);
                in  = (bands+1)*w -1;
                out = (bands*w)-1;
                while(in >= 0) {
                    a = pixel[in]; in--;
                    if (a > 0) {
                        if (a < 255) {
                            ialpha = fpNorm/a;
                            for (b=0; b<bands; b++)
                                oPix[out--] = (pixel[in--]*ialpha+pt5)>>>16;
                        } else
                            for (b=0; b<bands; b++)
                                oPix[out--] = pixel[in--];
                    } else {
                        in -= bands;
                        for (b=0; b<bands; b++)
                            oPix[out--] = 255;
                    }
                }
                dstR.setPixels(x0+dx, y+dy, w, 1, oPix);
            }
        } else {
            // Src has unpremult alpha, dest does not have alpha,
            // just copy the color channels over.
            Rectangle dstRect = new Rectangle(destP.x, destP.y,
                                              srcRect.width, srcRect.height);
            for (int b=0; b<bands; b++)
                copyBand(srcR, srcRect, b,
                         dstR, dstRect, b);
        }
    }

    public static void copyBand(Raster         src, int srcBand,
                                WritableRaster dst, int dstBand) {

        Rectangle sR   = src.getBounds();
        Rectangle dR   = dst.getBounds();
        Rectangle cpR  = sR.intersection(dR);

        copyBand(src, cpR, srcBand, dst, cpR, dstBand);
    }

    public static void copyBand(Raster         src, Rectangle sR, int sBand,
                                WritableRaster dst, Rectangle dR, int dBand) {
        int dy = dR.y -sR.y;
        int dx = dR.x -sR.x;
        sR = sR.intersection(src.getBounds());
        dR = dR.intersection(dst.getBounds());
        int width, height;
        if (dR.width  < sR.width)  width  = dR.width;
        else                       width  = sR.width;
        if (dR.height < sR.height) height = dR.height;
        else                       height = sR.height;

        int x = sR.x+dx;
        int [] samples = null;
        for (int y=sR.y; y< sR.y+height; y++) {
            samples = src.getSamples(sR.x, y, width, 1, sBand, samples);
            dst.setSamples(x, y+dy, width, 1, dBand, samples);
        }
    }

    public static boolean is_INT_PACK_Data(SampleModel sm,
                                           boolean requireAlpha) {
        // Check ColorModel is of type DirectColorModel
        if(!(sm instanceof SinglePixelPackedSampleModel)) return false;

        // Check transfer type
        if(sm.getDataType() != DataBuffer.TYPE_INT)       return false;

        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)sm;

        int [] masks = sppsm.getBitMasks();
        if (masks.length == 3) {
            if (requireAlpha) return false;
        } else if (masks.length != 4)
            return false;

        if(masks[0] != 0x00ff0000) return false;
        if(masks[1] != 0x0000ff00) return false;
        if(masks[2] != 0x000000ff) return false;
        if ((masks.length == 4) &&
            (masks[3] != 0xff000000)) return false;

        return true;
    }

        public static boolean is_BYTE_COMP_Data(SampleModel sm) {
            // Check ColorModel is of type DirectColorModel
            if(!(sm instanceof ComponentSampleModel))    return false;

            // Check transfer type
            if(sm.getDataType() != DataBuffer.TYPE_BYTE) return false;

            return true;
        }

    protected static void divide_INT_PACK_Data(WritableRaster wr) {
        // System.out.println("Divide Int");

        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)wr.getSampleModel();

        final int width = wr.getWidth();

        final int scanStride = sppsm.getScanlineStride();
        DataBufferInt db = (DataBufferInt)wr.getDataBuffer();
        final int base
            = (db.getOffset() +
               sppsm.getOffset(wr.getMinX()-wr.getSampleModelTranslateX(),
                               wr.getMinY()-wr.getSampleModelTranslateY()));

        // Access the pixel data array
        final int[] pixels = db.getBankData()[0];
        for (int y=0; y<wr.getHeight(); y++) {
            int sp = base + y*scanStride;
            final int end = sp + width;
            while (sp < end) {
                int pixel = pixels[sp];
                int a = pixel>>>24;
                if (a<=0) {
                    pixels[sp] = 0x00FFFFFF;
                } else if (a<255) {
                    int aFP = (0x00FF0000/a);
                    pixels[sp] =
                        ((a << 24) |
                         (((((pixel&0xFF0000)>>16)*aFP)&0xFF0000)    ) |
                         (((((pixel&0x00FF00)>>8) *aFP)&0xFF0000)>>8 ) |
                         (((((pixel&0x0000FF))    *aFP)&0xFF0000)>>16));
                }
                sp++;
            }
        }
    }

    protected static void mult_INT_PACK_Data(WritableRaster wr) {
        // System.out.println("Multiply Int: " + wr);

        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)wr.getSampleModel();

        final int width = wr.getWidth();

        final int scanStride = sppsm.getScanlineStride();
        DataBufferInt db = (DataBufferInt)wr.getDataBuffer();
        final int base
            = (db.getOffset() +
               sppsm.getOffset(wr.getMinX()-wr.getSampleModelTranslateX(),
                               wr.getMinY()-wr.getSampleModelTranslateY()));
        // Access the pixel data array
        final int[] pixels = db.getBankData()[0];
        for (int y=0; y<wr.getHeight(); y++) {
            int sp = base + y*scanStride;
            final int end = sp + width;
            while (sp < end) {
                int pixel = pixels[sp];
                int a = pixel>>>24;
                if ((a>=0) && (a<255)) {   // this does NOT include a == 255 (0xff) !
                    pixels[sp] = ((a << 24) |
                                  ((((pixel&0xFF0000)*a)>>8)&0xFF0000) |
                                  ((((pixel&0x00FF00)*a)>>8)&0x00FF00) |
                                  ((((pixel&0x0000FF)*a)>>8)&0x0000FF));
                }
                sp++;
            }
        }
    }


    protected static void divide_BYTE_COMP_Data(WritableRaster wr) {
        // System.out.println("Multiply Int: " + wr);

        ComponentSampleModel csm;
        csm = (ComponentSampleModel)wr.getSampleModel();

        final int width = wr.getWidth();

        final int scanStride = csm.getScanlineStride();
        final int pixStride  = csm.getPixelStride();
        final int [] bandOff = csm.getBandOffsets();

        DataBufferByte db = (DataBufferByte)wr.getDataBuffer();
        final int base
            = (db.getOffset() +
               csm.getOffset(wr.getMinX()-wr.getSampleModelTranslateX(),
                             wr.getMinY()-wr.getSampleModelTranslateY()));

        int aOff = bandOff[bandOff.length-1];
        int bands = bandOff.length-1;

        // Access the pixel data array
        final byte[] pixels = db.getBankData()[0];
        for (int y=0; y<wr.getHeight(); y++) {
            int sp = base + y*scanStride;
            final int end = sp + width*pixStride;
            while (sp < end) {
              int a = pixels[sp+aOff]&0xFF;
              if (a==0) {
                for ( int b=0; b<bands; b++)
                  pixels[sp+bandOff[b]] = (byte)0xFF;
              } else if (a<255) {         // this does NOT include a == 255 (0xff) !
                int aFP = (0x00FF0000/a);
                for ( int b=0; b<bands; b++) {
                  int i = sp+bandOff[b];
                  pixels[i] = (byte)(((pixels[i]&0xFF)*aFP)>>>16);
                }
              }
              sp+=pixStride;
            }
        }
    }

    protected static void mult_BYTE_COMP_Data(WritableRaster wr) {
        // System.out.println("Multiply Int: " + wr);

        ComponentSampleModel csm;
        csm = (ComponentSampleModel)wr.getSampleModel();

        final int width = wr.getWidth();

        final int scanStride = csm.getScanlineStride();
        final int pixStride  = csm.getPixelStride();
        final int [] bandOff = csm.getBandOffsets();

        DataBufferByte db = (DataBufferByte)wr.getDataBuffer();
        final int base
            = (db.getOffset() +
               csm.getOffset(wr.getMinX()-wr.getSampleModelTranslateX(),
                             wr.getMinY()-wr.getSampleModelTranslateY()));


        int aOff = bandOff[bandOff.length-1];
        int bands = bandOff.length-1;

        // Access the pixel data array
        final byte[] pixels = db.getBankData()[0];
        for (int y=0; y<wr.getHeight(); y++) {
            int sp = base + y*scanStride;
            final int end = sp + width*pixStride;
            while (sp < end) {
              int a = pixels[sp+aOff]&0xFF;
              if (a!=0xFF)
                for ( int b=0; b<bands; b++) {
                  int i = sp+bandOff[b];
                  pixels[i] = (byte)(((pixels[i]&0xFF)*a)>>8);
                }
              sp+=pixStride;
            }
        }
    }

/*
  This is skanky debugging code that might be useful in the future:

            if (count == 33) {
                String label = "sub [" + x + ", " + y + "]: ";
                org.ImageDisplay.showImage
                    (label, subBI);
                org.ImageDisplay.printImage
                    (label, subBI,
                     new Rectangle(75-iR.x, 90-iR.y, 32, 32));

            }


            // if ((count++ % 50) == 10)
            //     org.ImageDisplay.showImage("foo: ", subBI);


            Graphics2D realG2D = g2d;
            while (realG2D instanceof sun.java2d.ProxyGraphics2D) {
                realG2D = ((sun.java2d.ProxyGraphics2D)realG2D).getDelegate();
            }
            if (realG2D instanceof sun.awt.image.BufferedImageGraphics2D) {
                count++;
                if (count == 34) {
                    RenderedImage ri;
                    ri = ((sun.awt.image.BufferedImageGraphics2D)realG2D).bufImg;
                    // g2d.setComposite(SVGComposite.OVER);
                    // org.ImageDisplay.showImage("Bar: " + count, cr);
                    org.ImageDisplay.printImage("Bar: " + count, cr,
                                                new Rectangle(75, 90, 32, 32));

                    org.ImageDisplay.showImage ("Foo: " + count, ri);
                    org.ImageDisplay.printImage("Foo: " + count, ri,
                                                new Rectangle(75, 90, 32, 32));

                    System.out.println("BI: "   + ri);
                    System.out.println("BISM: " + ri.getSampleModel());
                    System.out.println("BICM: " + ri.getColorModel());
                    System.out.println("BICM class: " + ri.getColorModel().getClass());
                    System.out.println("BICS: " + ri.getColorModel().getColorSpace());
                    System.out.println
                        ("sRGB CS: " +
                         ColorSpace.getInstance(ColorSpace.CS_sRGB));
                    System.out.println("G2D info");
                    System.out.println("\tComposite: " + g2d.getComposite());
                    System.out.println("\tTransform" + g2d.getTransform());
                    java.awt.RenderingHints rh = g2d.getRenderingHints();
                    java.util.Set keys = rh.keySet();
                    java.util.Iterator iter = keys.iterator();
                    while (iter.hasNext()) {
                        Object o = iter.next();

                        System.out.println("\t" + o.toString() + " -> " +
                                           rh.get(o).toString());
                    }

                    ri = cr;
                    System.out.println("RI: "   + ri);
                    System.out.println("RISM: " + ri.getSampleModel());
                    System.out.println("RICM: " + ri.getColorModel());
                    System.out.println("RICM class: " + ri.getColorModel().getClass());
                    System.out.println("RICS: " + ri.getColorModel().getColorSpace());
                }
            }
*/

}
