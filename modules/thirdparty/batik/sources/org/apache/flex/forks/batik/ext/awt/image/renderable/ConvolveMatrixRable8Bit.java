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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.Point;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.color.ColorSpace;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.BufferedImageOp;
import java.awt.image.ColorModel;
import java.awt.image.ConvolveOp;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferInt;
import java.awt.image.DirectColorModel;
import java.awt.image.Kernel;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.rendered.AffineRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.BufferedImageCachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.PadRed;

/**
 * Convolves an image with a convolution matrix.
 *
 * Known limitations:
 *   Does not support bias other than zero - pending 16bit pathway
 *   Does not support edgeMode="wrap" - pending Tile code.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: ConvolveMatrixRable8Bit.java 478363 2006-11-22 23:01:13Z dvholten $
 */
public class ConvolveMatrixRable8Bit
    extends    AbstractColorInterpolationRable
    implements ConvolveMatrixRable {

    Kernel kernel;
    Point  target;
    float bias;
    boolean kernelHasNegValues;
    PadMode edgeMode;
    float [] kernelUnitLength = new float[2];

    boolean preserveAlpha = false;

    public ConvolveMatrixRable8Bit(Filter source) {
        super(source);
    }

    public Filter getSource() {
        return (Filter)getSources().get(0);
    }

    public void setSource(Filter src) {
        init(src);
    }


    /**
     * Returns the Convolution Kernel in use
     */
    public Kernel getKernel() {
        return kernel;
    }

    /**
     * Sets the Convolution Kernel to use.
     * @param k Kernel to use for convolution.
     */
    public void setKernel(Kernel k) {
        touch();
        this.kernel = k;
        kernelHasNegValues = false;
        float [] kv = k.getKernelData(null);
        for (int i=0; i<kv.length; i++)
            if (kv[i] < 0) {
                kernelHasNegValues = true;
                break;
            }
    }

    public Point getTarget() {
        return (Point)target.clone();
    }

    public void setTarget(Point pt) {
        touch();
        this.target = (Point)pt.clone();
    }

    /**
     * Returns the shift value to apply to the result of convolution
     */
    public double getBias() {
        return bias;
    }

    /**
     * Returns the shift value to apply to the result of convolution
     */
    public void setBias(double bias) {
        touch();
        this.bias = (float)bias;
    }

    /**
     * Returns the current edge handling mode.
     */
    public PadMode getEdgeMode() {
        return edgeMode;
    }

    /**
     * Sets the current edge handling mode.
     */
    public void setEdgeMode(PadMode edgeMode) {
        touch();
        this.edgeMode = edgeMode;
    }

    /**
     * Returns the [x,y] distance in user space between kernel values
     */
    public double [] getKernelUnitLength() {
        if (kernelUnitLength == null)
            return null;

        double [] ret = new double[2];
        ret[0] = kernelUnitLength[0];
        ret[1] = kernelUnitLength[1];
        return ret;
    }

    /**
     * Sets the [x,y] distance in user space between kernel values
     * If set to zero then device space will be used.
     */
    public void setKernelUnitLength(double [] kernelUnitLength) {
        touch();
        if (kernelUnitLength == null) {
            this.kernelUnitLength = null;
            return;
        }

        if (this.kernelUnitLength == null)
            this.kernelUnitLength = new float[2];

        this.kernelUnitLength[0] = (float)kernelUnitLength[0];
        this.kernelUnitLength[1] = (float)kernelUnitLength[1];
    }

    /**
     * Returns false if the convolution should affect the Alpha channel
     */
    public boolean getPreserveAlpha() {
        return preserveAlpha;
    }

    /**
     * Sets Alpha channel handling.
     * A value of False indicates that the convolution should apply to
     * the Alpha Channel
     */
    public void setPreserveAlpha(boolean preserveAlpha) {
        touch();
        this.preserveAlpha = preserveAlpha;
    }


    public void fixAlpha(BufferedImage bi) {
        if ((!bi.getColorModel().hasAlpha()) ||
            (!bi.isAlphaPremultiplied()))
            // No need to fix alpha if it isn't premultiplied...
            return;
        if (GraphicsUtil.is_INT_PACK_Data(bi.getSampleModel(), true))
            fixAlpha_INT_PACK(bi.getRaster());
        else
            fixAlpha_FALLBACK(bi.getRaster());
    }

    public void fixAlpha_INT_PACK(WritableRaster wr) {
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
                int v = (pixel>>16)&0xFF;
                if (a < v) a = v;
                v = (pixel>> 8)&0xFF;
                if (a < v) a = v;
                v = (pixel    )&0xFF;
                if (a < v) a = v;
                pixels[sp] = (pixel&0x00FFFFFF) | (a << 24);
                sp++;
            }
        }
    }

    public void fixAlpha_FALLBACK(WritableRaster wr) {
        int x0=wr.getMinX();
        int w =wr.getWidth();
        int y0=wr.getMinY();
        int y1=y0 + wr.getHeight()-1;
        int bands = wr.getNumBands();
        int a, x, y, b, i;
        int [] pixel = null;
        for (y=y0; y<=y1; y++) {
            pixel = wr.getPixels(x0, y, w, 1, pixel);
            i=0;
            for (x=0; x<w; x++) {
                a=pixel[i];
                for (b=1; b<bands; b++)
                    if (pixel[i+b] > a) a = pixel[i+b];
                pixel[i+bands-1] = a;
                i+=bands;
            }
            wr.setPixels(x0, y, w, 1, pixel);
        }
    }

    public RenderedImage createRendering(RenderContext rc) {
        // Just copy over the rendering hints.
        RenderingHints rh = rc.getRenderingHints();
        if (rh == null) rh = new RenderingHints(null);

        // update the current affine transform
        AffineTransform at = rc.getTransform();


        // This splits out the scale and applies it
        // prior to the Gaussian.  Then after appying the gaussian
        // it applies the shear (rotation) and translation components.
        double sx = at.getScaleX();
        double sy = at.getScaleY();

        double shx = at.getShearX();
        double shy = at.getShearY();

        double tx = at.getTranslateX();
        double ty = at.getTranslateY();

        // The Scale is the "hypotonose" of the matrix vectors.  This
        // represents the complete scaling value from user to an
        // intermediate space that is scaled similarly to device
        // space.
        double scaleX = Math.sqrt(sx*sx + shy*shy);
        double scaleY = Math.sqrt(sy*sy + shx*shx);

        // These values represent the scale factor to the intermediate
        // coordinate system where we will apply our convolution.
        if (kernelUnitLength != null) {
            if (kernelUnitLength[0] > 0.0)
                scaleX = 1/kernelUnitLength[0];

            if (kernelUnitLength[1] > 0.0)
                scaleY = 1/kernelUnitLength[1];
        }

        Shape aoi = rc.getAreaOfInterest();
        if(aoi == null)
            aoi = getBounds2D();

        Rectangle2D r = aoi.getBounds2D();

        int kw = kernel.getWidth();
        int kh = kernel.getHeight();
        int kx = target.x;
        int ky = target.y;

        // Grow the region in usr space.
        {
            double rx0 = r.getX() -(kx/scaleX);
            double ry0 = r.getY() -(ky/scaleY);
            double rx1 = rx0 + r.getWidth()  + (kw-1)/scaleX;
            double ry1 = ry0 + r.getHeight() + (kh-1)/scaleY;
            r = new Rectangle2D.Double(Math.floor(rx0),
                                       Math.floor(ry0),
                                       Math.ceil (rx1-Math.floor(rx0)),
                                       Math.ceil (ry1-Math.floor(ry0)));
        }
        // This will be the affine transform between our usr space and
        // an intermediate space which is scaled according to
        // kernelUnitLength and is axially aligned with our user
        // space.
        AffineTransform srcAt
            = AffineTransform.getScaleInstance(scaleX, scaleY);

        // This is the affine transform between our intermediate
        // coordinate space (where the convolution takes place) and
        // the real device space, or null (if we don't need an
        // intermediate space).

        // The shear/rotation simply divides out the
        // common scale factor in the matrix.
        AffineTransform resAt = new AffineTransform(sx/scaleX, shy/scaleX,
                                                    shx/scaleY, sy/scaleY,
                                                    tx, ty);

        RenderedImage ri;
        ri = getSource().createRendering(new RenderContext(srcAt, r, rh));
        if (ri == null)
            return null;

        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.printImage
        //     ("Padded Image", ri,
        //      new Rectangle(ri.getMinX()+22,ri.getMinY()+38,5,5));

        CachableRed cr = convertSourceCS(ri);

        Shape devShape = srcAt.createTransformedShape(aoi);
        Rectangle2D devRect = devShape.getBounds2D();
        r = devRect;
        r = new Rectangle2D.Double(Math.floor(r.getX()-kx),
                                   Math.floor(r.getY()-ky),
                                   Math.ceil (r.getX()+r.getWidth())-
                                   Math.floor(r.getX())+(kw-1),
                                   Math.ceil (r.getY()+r.getHeight())-
                                   Math.floor(r.getY())+(kh-1));

        if (!r.getBounds().equals(cr.getBounds())) {
            if (edgeMode == PadMode.WRAP)
                throw new IllegalArgumentException
                    ("edgeMode=\"wrap\" is not supported by ConvolveMatrix.");
            cr = new PadRed(cr, r.getBounds(), edgeMode, rh);
        }

        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.printImage
        //     ("Padded Image", cr,
        //      new Rectangle(cr.getMinX()+23,cr.getMinY()+39,5,5));

        if (bias != 0.0)
            throw new IllegalArgumentException
                ("Only bias equal to zero is supported in ConvolveMatrix.");

        BufferedImageOp op = new ConvolveOp(kernel,
                                            ConvolveOp.EDGE_NO_OP,
                                            rh);

        ColorModel cm = cr.getColorModel();

        // OK this is a bit of a cheat. We Pull the DataBuffer out of
        // The read-only raster that getData gives us. And use it to
        // build a WritableRaster.  This avoids a copy of the data.
        Raster rr = cr.getData();
        WritableRaster wr = GraphicsUtil.makeRasterWritable(rr, 0, 0);

        // Here we update the translate to account for the phase shift
        // (if any) introduced by setting targetX, targetY in SVG.
        int phaseShiftX = target.x - kernel.getXOrigin();
        int phaseShiftY = target.y - kernel.getYOrigin();
        int destX = (int)(r.getX() + phaseShiftX);
        int destY = (int)(r.getY() + phaseShiftY);

        BufferedImage destBI;
        if (!preserveAlpha) {
            // Force the data to be premultiplied since often the JDK
            // code doesn't properly premultiply the values...
            cm = GraphicsUtil.coerceData(wr, cm, true);

            BufferedImage srcBI;
            srcBI = new BufferedImage(cm, wr, cm.isAlphaPremultiplied(), null);

            // Easy case just apply the op...
            destBI = op.filter(srcBI, null);

            if (kernelHasNegValues) {
                // When the kernel has negative values it's possible
                // for the resultant image to have alpha values less
                // than the associated color values this will lead to
                // problems later when we try to display the image so
                // we fix this here.
                fixAlpha(destBI);
            }

        } else {
            BufferedImage srcBI;
            srcBI = new BufferedImage(cm, wr, cm.isAlphaPremultiplied(), null);

            // Construct a linear sRGB cm without alpha...
            cm = new DirectColorModel(ColorSpace.getInstance
                                      (ColorSpace.CS_LINEAR_RGB), 24,
                                      0x00FF0000, 0x0000FF00,
                                      0x000000FF, 0x0, false,
                                      DataBuffer.TYPE_INT);



            // Create an image with that color model
            BufferedImage tmpSrcBI = new BufferedImage
                (cm, cm.createCompatibleWritableRaster(wr.getWidth(),
                                                       wr.getHeight()),
                 cm.isAlphaPremultiplied(), null);

            // Copy the color data (no alpha) to that image
            // (dividing out alpha if needed).
            GraphicsUtil.copyData(srcBI, tmpSrcBI);

            // org.apache.flex.forks.batik.test.gvt.ImageDisplay.showImage
            //   ("tmpSrcBI: ", tmpSrcBI);

            // Get a linear sRGB Premult ColorModel
            ColorModel dstCM = GraphicsUtil.Linear_sRGB_Unpre;
            // Construct out output image around that ColorModel
            destBI = new BufferedImage
                (dstCM, dstCM.createCompatibleWritableRaster(wr.getWidth(),
                                                             wr.getHeight()),
                 dstCM.isAlphaPremultiplied(), null);

            // Construct another image on the same data buffer but without
            // an alpha channel.

            // Create the Raster (note we are using 'cm' again).
            WritableRaster dstWR =
                Raster.createWritableRaster
                (cm.createCompatibleSampleModel(wr.getWidth(), wr.getHeight()),
                 destBI.getRaster().getDataBuffer(),
                 new Point(0,0));

            // Create the BufferedImage.
            BufferedImage tmpDstBI = new BufferedImage
                (cm, dstWR, cm.isAlphaPremultiplied(), null);

            // Filter between the two image without alpha.
            tmpDstBI = op.filter(tmpSrcBI, tmpDstBI);

            // org.apache.flex.forks.batik.test.gvt.ImageDisplay.showImage
            //   ("tmpDstBI: ", tmpDstBI);

            // Copy the alpha channel into the result (note the color
            // channels are still unpremult.
            Rectangle srcRect = wr.getBounds();
            Rectangle dstRect = new Rectangle(srcRect.x-phaseShiftX,
                                              srcRect.y-phaseShiftY,
                                              srcRect.width, srcRect.height);
            GraphicsUtil.copyBand(wr, srcRect, wr.getNumBands()-1,
                                  destBI.getRaster(), dstRect,
                                  destBI.getRaster().getNumBands()-1);
        }

        // Wrap it as a CachableRed
        cr = new BufferedImageCachableRed(destBI, destX, destY);

        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.printImage
        //     ("Cropped Image", cr,
        //      new Rectangle(cr.getMinX()+22,cr.getMinY()+38,5,5));
        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.printImage
        //     ("Cropped sRGB", GraphicsUtil.convertTosRGB(cr),
        //      new Rectangle(cr.getMinX()+22,cr.getMinY()+38,5,5));

        // Make sure to crop junk from edges.
        cr = new PadRed(cr, devRect.getBounds(), PadMode.ZERO_PAD, rh);

        // If we need to scale/rotate/translate the result do so now...
        if (!resAt.isIdentity())
            cr = new AffineRed(cr, resAt, null);

        // return the result.
        return cr;
    }

}
