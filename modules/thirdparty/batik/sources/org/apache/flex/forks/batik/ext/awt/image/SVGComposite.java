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

import java.awt.AlphaComposite;
import java.awt.Composite;
import java.awt.CompositeContext;
import java.awt.RenderingHints;
import java.awt.color.ColorSpace;
import java.awt.image.ColorModel;
import java.awt.image.DataBufferInt;
import java.awt.image.PackedColorModel;
import java.awt.image.Raster;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;

/**
 * This provides an implementation of all the composite rules in SVG.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: SVGComposite.java 478363 2006-11-22 23:01:13Z dvholten $
 */
public class SVGComposite
    implements Composite {

    public static final SVGComposite OVER
        = new SVGComposite(CompositeRule.OVER);

    public static final SVGComposite IN
        = new SVGComposite(CompositeRule.IN);

    public static final SVGComposite OUT
        = new SVGComposite(CompositeRule.OUT);

    public static final SVGComposite ATOP
        = new SVGComposite(CompositeRule.ATOP);

    public static final SVGComposite XOR
        = new SVGComposite(CompositeRule.XOR);

    public static final SVGComposite MULTIPLY
        = new SVGComposite(CompositeRule.MULTIPLY);

    public static final SVGComposite SCREEN
        = new SVGComposite(CompositeRule.SCREEN);

    public static final SVGComposite DARKEN
        = new SVGComposite(CompositeRule.DARKEN);

    public static final SVGComposite LIGHTEN
        = new SVGComposite(CompositeRule.LIGHTEN);


    CompositeRule rule;

    public CompositeRule getRule() { return rule; }

    public SVGComposite(CompositeRule rule) {
        this.rule = rule;
    }

    public boolean equals(Object o) {
        if (o instanceof SVGComposite) {
            SVGComposite svgc = (SVGComposite)o;
            return (svgc.getRule() == getRule());
        } else if (o instanceof AlphaComposite) {
            AlphaComposite ac = (AlphaComposite)o;
            switch (getRule().getRule()) {
            case CompositeRule.RULE_OVER:
                return (ac == AlphaComposite.SrcOver);
            case CompositeRule.RULE_IN:
                return (ac == AlphaComposite.SrcIn);
            case CompositeRule.RULE_OUT:
                return (ac == AlphaComposite.SrcOut);
            default:
                return false;
            }
        }
        return false;
    }

    public boolean is_INT_PACK(ColorModel cm) {
          // Check ColorModel is of type DirectColorModel
        if(!(cm instanceof PackedColorModel)) return false;

        PackedColorModel pcm = (PackedColorModel)cm;

        int [] masks = pcm.getMasks();

        // Check transfer type
        if(masks.length != 4) return false;

        if (masks[0] != 0x00ff0000) return false;
        if (masks[1] != 0x0000ff00) return false;
        if (masks[2] != 0x000000ff) return false;
        if (masks[3] != 0xff000000) return false;

        return true;
   }

    public CompositeContext createContext(ColorModel srcCM,
                                          ColorModel dstCM,
                                          RenderingHints hints) {
        if (false) {
            ColorSpace srcCS = srcCM.getColorSpace();
            ColorSpace dstCS = dstCM.getColorSpace();
            System.out.println("srcCS: " + srcCS);
            System.out.println("dstCS: " + dstCS);
            System.out.println
                ("lRGB: " + ColorSpace.getInstance(ColorSpace.CS_LINEAR_RGB));
            System.out.println
                ("sRGB: " + ColorSpace.getInstance(ColorSpace.CS_sRGB));
        }

        // Orig Time no int_pack = 51792
        // Simple int_pack       = 19600
        boolean use_int_pack = (is_INT_PACK(srcCM) && is_INT_PACK(dstCM));
        // use_int_pack = false;

        switch (rule.getRule()) {
        case CompositeRule.RULE_OVER:
            if (!dstCM.hasAlpha()) {
                if (use_int_pack)
                    return new OverCompositeContext_INT_PACK_NA(srcCM, dstCM);
                else
                    return new OverCompositeContext_NA  (srcCM, dstCM);
            }

            if (!use_int_pack)
                return new OverCompositeContext(srcCM, dstCM);

            if (srcCM.isAlphaPremultiplied())
                return new OverCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new OverCompositeContext_INT_PACK_UNPRE(srcCM, dstCM);

        case CompositeRule.RULE_IN:
            if (use_int_pack)
                return new InCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new InCompositeContext  (srcCM, dstCM);

        case CompositeRule.RULE_OUT:
            if (use_int_pack)
                return new OutCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new OutCompositeContext (srcCM, dstCM);

        case CompositeRule.RULE_ATOP:
            if (use_int_pack)
                return new AtopCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new AtopCompositeContext(srcCM, dstCM);

        case CompositeRule.RULE_XOR:
            if (use_int_pack)
                return new XorCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new XorCompositeContext (srcCM, dstCM);

        case CompositeRule.RULE_ARITHMETIC:
            float [] coeff = rule.getCoefficients();
            if (use_int_pack)
                return new ArithCompositeContext_INT_PACK_LUT
                    (srcCM, dstCM, coeff[0], coeff[1], coeff[2], coeff[3]);
            else
                return new ArithCompositeContext
                    (srcCM, dstCM, coeff[0], coeff[1], coeff[2], coeff[3]);

        case CompositeRule.RULE_MULTIPLY:
            if (use_int_pack)
                return new MultiplyCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new MultiplyCompositeContext(srcCM, dstCM);

        case CompositeRule.RULE_SCREEN:
            if (use_int_pack)
                return new ScreenCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new ScreenCompositeContext  (srcCM, dstCM);

        case CompositeRule.RULE_DARKEN:
            if (use_int_pack)
                return new DarkenCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new DarkenCompositeContext  (srcCM, dstCM);

        case CompositeRule.RULE_LIGHTEN:
            if (use_int_pack)
                return new LightenCompositeContext_INT_PACK(srcCM, dstCM);
            else
                return new LightenCompositeContext (srcCM, dstCM);

        default:
            throw new UnsupportedOperationException
                ("Unknown composite rule requested.");
        }

    }

    public abstract static class AlphaPreCompositeContext
        implements CompositeContext {

        ColorModel srcCM, dstCM;
        AlphaPreCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            this.srcCM = srcCM;
            this.dstCM = dstCM;
        }

        public void dispose() {
            srcCM = null;
            dstCM = null;
        }

        protected abstract void precompose(Raster src, Raster dstIn,
                                           WritableRaster dstOut);

        public void compose(Raster src, Raster dstIn, WritableRaster dstOut) {
            ColorModel srcPreCM = srcCM;
            if (!srcCM.isAlphaPremultiplied())
                srcPreCM = GraphicsUtil.coerceData((WritableRaster)src,
                                                   srcCM, true);

            ColorModel dstPreCM = dstCM;
            if (!dstCM.isAlphaPremultiplied())
                dstPreCM = GraphicsUtil.coerceData((WritableRaster)dstIn,
                                                   dstCM, true);

            precompose(src, dstIn, dstOut);

            if (!srcCM.isAlphaPremultiplied())
                GraphicsUtil.coerceData((WritableRaster)src,
                                        srcPreCM, false);

            if (!dstCM.isAlphaPremultiplied()) {
                GraphicsUtil.coerceData(dstOut, dstPreCM, false);

                if (dstIn != dstOut)
                    GraphicsUtil.coerceData((WritableRaster)dstIn,
                                            dstPreCM, false);
            }
        }
    }

    public abstract static class AlphaPreCompositeContext_INT_PACK
        extends AlphaPreCompositeContext {

        AlphaPreCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        protected abstract void precompose_INT_PACK
            (final int width, final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp);

        protected void precompose(Raster src, Raster dstIn,
                                           WritableRaster dstOut) {

            int x0=dstOut.getMinX();
            int w =dstOut.getWidth();

            int y0=dstOut.getMinY();
            int h =dstOut.getHeight();

            SinglePixelPackedSampleModel srcSPPSM;
            srcSPPSM = (SinglePixelPackedSampleModel)src.getSampleModel();

            final int     srcScanStride = srcSPPSM.getScanlineStride();
            DataBufferInt srcDB         = (DataBufferInt)src.getDataBuffer();
            final int []  srcPixels     = srcDB.getBankData()[0];
            final int     srcBase =
                (srcDB.getOffset() +
                 srcSPPSM.getOffset(x0-src.getSampleModelTranslateX(),
                                    y0-src.getSampleModelTranslateY()));


            SinglePixelPackedSampleModel dstInSPPSM;
            dstInSPPSM = (SinglePixelPackedSampleModel)dstIn.getSampleModel();

            final int dstInScanStride = dstInSPPSM.getScanlineStride();
            DataBufferInt dstInDB     = (DataBufferInt)dstIn.getDataBuffer();
            final int []  dstInPixels     = dstInDB.getBankData()[0];
            final int     dstInBase =
                (dstInDB.getOffset() +
                 dstInSPPSM.getOffset(x0-dstIn.getSampleModelTranslateX(),
                                      y0-dstIn.getSampleModelTranslateY()));

            SinglePixelPackedSampleModel dstOutSPPSM
                = (SinglePixelPackedSampleModel)dstOut.getSampleModel();

            final int dstOutScanStride = dstOutSPPSM.getScanlineStride();
            DataBufferInt dstOutDB     = (DataBufferInt)dstOut.getDataBuffer();
            final int []  dstOutPixels     = dstOutDB.getBankData()[0];
            final int     dstOutBase =
                (dstOutDB.getOffset() +
                 dstOutSPPSM.getOffset(x0-dstOut.getSampleModelTranslateX(),
                                       y0-dstOut.getSampleModelTranslateY()));

            final int   srcAdjust  =    srcScanStride - w;
            final int  dstInAdjust =  dstInScanStride - w;
            final int dstOutAdjust = dstOutScanStride - w;

            precompose_INT_PACK(w, h,
                                srcPixels,    srcAdjust,    srcBase,
                                dstInPixels,  dstInAdjust,  dstInBase,
                                dstOutPixels, dstOutAdjust, dstOutBase);
        }
    }


    /**
     * This implements SRC_OVER for 4 band byte data.
     */
    public static class OverCompositeContext
        extends AlphaPreCompositeContext {
        OverCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                int sp  = 0;
                int end = w*4;
                while(sp<end) {
                    final int dstM = (255-srcPix[sp+3])*norm;
                    dstPix[sp] = srcPix[sp] + ((dstPix[sp]*dstM +pt5)>>>24);
                    ++sp;
                    dstPix[sp] = srcPix[sp] + ((dstPix[sp]*dstM +pt5)>>>24);
                    ++sp;
                    dstPix[sp] = srcPix[sp] + ((dstPix[sp]*dstM +pt5)>>>24);
                    ++sp;
                    dstPix[sp] = srcPix[sp] + ((dstPix[sp]*dstM +pt5)>>>24);
                    ++sp;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }

        }
    }

    /**
     * This implements SRC_OVER for 4 band byte src data and
     * 3 band byte dst data.
     */
    public static class OverCompositeContext_NA
        extends AlphaPreCompositeContext {
        OverCompositeContext_NA(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                int srcSP  = 0;
                int dstSP  = 0;
                int end = w*4;
                while (srcSP<end) {
                    final int dstM = (255-srcPix[srcSP+3])*norm;
                    dstPix[dstSP] =
                        srcPix[srcSP] + ((dstPix[dstSP]*dstM +pt5)>>>24);
                    ++srcSP; ++dstSP;
                    dstPix[dstSP] =
                        srcPix[srcSP] + ((dstPix[dstSP]*dstM +pt5)>>>24);
                    ++srcSP; ++dstSP;
                    dstPix[dstSP] =
                        srcPix[srcSP] + ((dstPix[dstSP]*dstM +pt5)>>>24);
                    srcSP+=2; ++dstSP;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }
        }
    }

    /**
     * This implements SRC_OVER for Int packed data where the src is
     * premultiplied.
     */
    public static class OverCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        OverCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, dstInP, dstM;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP   = srcPixels  [srcSp++];
                    dstInP = dstInPixels[dstInSp++];

                    dstM = (255-(srcP>>>24))*norm;
                    dstOutPixels[dstOutSp++] =
                        (((     srcP & 0xFF000000) +
                          (((((dstInP>>>24)     )*dstM+pt5)&0xFF000000)     ))|
                         ((     srcP & 0x00FF0000) +
                          (((((dstInP>> 16)&0xFF)*dstM+pt5)&0xFF000000)>>> 8))|
                         ((     srcP & 0x0000FF00) +
                          (((((dstInP>>  8)&0xFF)*dstM+pt5)&0xFF000000)>>>16))|
                         ((     srcP & 0x000000FF) +
                          (((((dstInP     )&0xFF)*dstM+pt5)         )>>>24)));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    /**
     * This implements SRC_OVER for Int packed data and dest has no Alpha...
     */
    public static class OverCompositeContext_INT_PACK_NA
        extends AlphaPreCompositeContext_INT_PACK {
        OverCompositeContext_INT_PACK_NA(ColorModel srcCM, ColorModel dstCM) {
            super (srcCM, dstCM);
        }

        // When we get here src data has been premultiplied.
        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, dstInP, dstM;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP   = srcPixels  [srcSp++];
                    dstInP = dstInPixels[dstInSp++];

                    dstM = (255-(srcP>>>24))*norm;
                    dstOutPixels[dstOutSp++] =
                        (((     srcP & 0x00FF0000) +
                          (((((dstInP>> 16)&0xFF)*dstM+pt5)&0xFF000000)>>> 8))|
                         ((     srcP & 0x0000FF00) +
                          (((((dstInP>>  8)&0xFF)*dstM+pt5)&0xFF000000)>>>16))|
                         ((     srcP & 0x000000FF) +
                          (((((dstInP     )&0xFF)*dstM+pt5)         )>>>24)));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    /**
     * This implements SRC_OVER for Int packed data where the src is
     * unpremultiplied.  This avoids having to multiply the alpha on the
     * the source then divide it out again.
     */
    public static class OverCompositeContext_INT_PACK_UNPRE
        extends AlphaPreCompositeContext_INT_PACK {
        OverCompositeContext_INT_PACK_UNPRE
            (ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);

            if (srcCM.isAlphaPremultiplied())
                throw new IllegalArgumentException
                    ("OverCompositeContext_INT_PACK_UNPRE is only for" +
                     "sources with unpremultiplied alpha");
        }

        public void compose(Raster src, Raster dstIn, WritableRaster dstOut) {
            ColorModel dstPreCM = dstCM;
            if (!dstCM.isAlphaPremultiplied())
                dstPreCM = GraphicsUtil.coerceData((WritableRaster)dstIn,
                                                   dstCM, true);

            precompose(src, dstIn, dstOut);

            if (!dstCM.isAlphaPremultiplied()) {
                GraphicsUtil.coerceData(dstOut, dstPreCM, false);

                if (dstIn != dstOut)
                    GraphicsUtil.coerceData((WritableRaster)dstIn,
                                            dstPreCM, false);
            }
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcM, dstP, dstM;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP   = srcPixels  [srcSp++];
                    dstP = dstInPixels[dstInSp++];

                    srcM = (    (srcP>>>24))*norm;
                    dstM = (255-(srcP>>>24))*norm;

                    dstOutPixels[dstOutSp++] =
                        ((((( srcP&0xFF000000)      +
                            ((dstP>>>24)     )*dstM + pt5)&0xFF000000)     ) |
                         (((((srcP>> 16)&0xFF)*srcM +
                            ((dstP>> 16)&0xFF)*dstM + pt5)&0xFF000000)>>> 8) |
                         (((((srcP>>  8)&0xFF)*srcM +
                            ((dstP>>  8)&0xFF)*dstM + pt5)&0xFF000000)>>>16) |
                         (((((srcP     )&0xFF)*srcM +
                            ((dstP     )&0xFF)*dstM + pt5)           )>>>24));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    public static class InCompositeContext
        extends AlphaPreCompositeContext {
        InCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                int sp  = 0;
                int end = w*4;
                while(sp<end) {
                    final int srcM = dstPix[sp+3]*norm;
                    dstPix[sp] = (srcPix[sp]*srcM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM + pt5)>>>24; ++sp;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }

        }
    }

    public static class InCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        InCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcM;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcM = (dstInPixels[dstInSp++]>>>24)*norm;
                    srcP = srcPixels   [srcSp++];
                    dstOutPixels[dstOutSp++] =
                        ((((((srcP>>>24)     )*srcM + pt5)&0xFF000000)     ) |
                         (((((srcP>> 16)&0xFF)*srcM + pt5)&0xFF000000)>>> 8) |
                         (((((srcP>>  8)&0xFF)*srcM + pt5)&0xFF000000)>>>16) |
                         (((((srcP     )&0xFF)*srcM + pt5)           )>>>24));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    public static class OutCompositeContext
        extends AlphaPreCompositeContext {
        OutCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                int sp  = 0;
                int end = w*4;
                while(sp<end) {
                    final int srcM = (255-dstPix[sp+3])*norm;
                    dstPix[sp] = (srcPix[sp]*srcM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM + pt5)>>>24; ++sp;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }

        }
    }

    public static class OutCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        OutCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcM;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcM = (255-(dstInPixels[dstInSp++]>>>24))*norm;
                    srcP = srcPixels   [srcSp++];
                    dstOutPixels[dstOutSp++] =
                        ((((((srcP>>>24)     )*srcM + pt5)&0xFF000000)     ) |
                         (((((srcP>> 16)&0xFF)*srcM + pt5)&0xFF000000)>>> 8) |
                         (((((srcP>>  8)&0xFF)*srcM + pt5)&0xFF000000)>>>16) |
                         (((((srcP     )&0xFF)*srcM + pt5)           )>>>24));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    public static class AtopCompositeContext
        extends AlphaPreCompositeContext {
        AtopCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                int sp  = 0;
                int end = w*4;
                while(sp<end) {
                    final int srcM = (    dstPix[sp+3])*norm;
                    final int dstM = (255-srcPix[sp+3])*norm;
                    dstPix[sp] =(srcPix[sp]*srcM + dstPix[sp]*dstM +pt5)>>>24;
                    ++sp;
                    dstPix[sp] =(srcPix[sp]*srcM + dstPix[sp]*dstM +pt5)>>>24;
                    ++sp;
                    dstPix[sp] =(srcPix[sp]*srcM + dstPix[sp]*dstM +pt5)>>>24;
                    sp+=2;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }

        }
    }

    public static class AtopCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        AtopCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcM, dstP, dstM;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP = srcPixels  [srcSp++];
                    dstP = dstInPixels[dstInSp++];

                    srcM = (     dstP>>>24) *norm;
                    dstM = (255-(srcP>>>24))*norm;

                    dstOutPixels[dstOutSp++] =
                        ((dstP&0xFF000000)                                   |
                         (((((srcP>> 16)&0xFF)*srcM +
                            ((dstP>> 16)&0xFF)*dstM + pt5)&0xFF000000)>>> 8) |
                         (((((srcP>>  8)&0xFF)*srcM +
                            ((dstP>>  8)&0xFF)*dstM + pt5)&0xFF000000)>>>16) |
                         (((((srcP     )&0xFF)*srcM +
                            ((dstP     )&0xFF)*dstM + pt5)           )>>>24));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    public static class XorCompositeContext
        extends AlphaPreCompositeContext {

        XorCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                int sp  = 0;
                int end = w*4;
                while(sp<end) {
                    final int srcM = (255-dstPix[sp+3])*norm;
                    final int dstM = (255-srcPix[sp+3])*norm;

                    dstPix[sp] = (srcPix[sp]*srcM +
                                  dstPix[sp]*dstM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM +
                                  dstPix[sp]*dstM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM +
                                  dstPix[sp]*dstM + pt5)>>>24; ++sp;
                    dstPix[sp] = (srcPix[sp]*srcM +
                                  dstPix[sp]*dstM + pt5)>>>24; ++sp;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }

        }
    }

    public static class XorCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        XorCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcM, dstP, dstM;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP = srcPixels  [srcSp++];
                    dstP = dstInPixels[dstInSp++];

                    srcM = (255-(dstP>>>24))*norm;
                    dstM = (255-(srcP>>>24))*norm;

                    dstOutPixels[dstOutSp++] =
                        ((((((srcP>>>24)     )*srcM +
                            ((dstP>>>24)     )*dstM + pt5)&0xFF000000)     ) |
                         (((((srcP>> 16)&0xFF)*srcM +
                            ((dstP>> 16)&0xFF)*dstM + pt5)&0xFF000000)>>> 8) |
                         (((((srcP>>  8)&0xFF)*srcM +
                            ((dstP>>  8)&0xFF)*dstM + pt5)&0xFF000000)>>>16) |
                         (((((srcP     )&0xFF)*srcM +
                            ((dstP     )&0xFF)*dstM + pt5)           )>>>24));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    public static class ArithCompositeContext
        extends AlphaPreCompositeContext {
        float k1, k2, k3, k4;
        ArithCompositeContext(ColorModel srcCM,
                              ColorModel dstCM,
                              float k1, float k2, float k3, float k4) {
            super(srcCM, dstCM);
            this.k1 = k1;
            this.k2 = k2;
            this.k3 = k3;
            this.k4 = k4;
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();
            int bands = dstOut.getNumBands();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            float kk1 = k1/255.0f;
            float kk4 = k4*255.0f+0.5f;

            int y, i, b, val, max;
            for (y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                for (i=0; i<srcPix.length; i++) {
                    max=0;
                    for (b=1; b<bands; b++, i++) {
                        val =(int)((kk1*srcPix[i]*dstPix[i]) +
                                   k2*srcPix[i] + k3*dstPix[i] + kk4);
                        if ((val & 0xFFFFFF00) != 0)
                            if ((val & 0x80000000) != 0) val = 0;
                            else                         val = 255;
                        if (val > max) max=val;
                        dstPix[i] = val;
                    }

                    val =(int)((kk1*srcPix[i]*dstPix[i]) +
                               k2*srcPix[i] + k3*dstPix[i] + kk4);
                    if ((val & 0xFFFFFF00) != 0)
                        if ((val & 0x80000000) != 0) val = 0;
                        else                         val = 255;
                    if (val > max)
                        dstPix[i] = val;
                    else
                        dstPix[i] = max;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }
        }
    }

    public static class ArithCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        float k1, k2, k3, k4;
        ArithCompositeContext_INT_PACK(ColorModel srcCM,
                                       ColorModel dstCM,
                                       float k1, float k2,
                                       float k3, float k4) {
            super(srcCM, dstCM);
            this.k1 = k1/255.0f;
            this.k2 = k2;
            this.k3 = k3;
            this.k4 = k4*255.0f+0.5f;
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            int srcP, dstP, a, r, g, b;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP = srcPixels   [srcSp++];
                    dstP = dstInPixels   [dstInSp++];
                    a = (int)((srcP>>>24)*(dstP>>>24)*k1 +
                              (srcP>>>24)*k2 + (dstP>>>24)*k3 + k4);
                    if ((a & 0xFFFFFF00) != 0)
                        if ((a & 0x80000000) != 0) a = 0;
                        else                       a = 255;

                    r = (int)(((srcP>> 16)&0xFF)*((dstP>> 16)&0xFF)*k1 +
                              ((srcP>> 16)&0xFF)*k2 +
                              ((dstP>> 16)&0xFF)*k3 + k4);
                    if ((r & 0xFFFFFF00) != 0)
                        if ((r & 0x80000000) != 0) r = 0;
                        else                       r = 255;
                    if (a < r) a = r;

                    g = (int)(((srcP>>  8)&0xFF)*((dstP>>  8)&0xFF)*k1 +
                              ((srcP>>  8)&0xFF)*k2 +
                              ((dstP>>  8)&0xFF)*k3 + k4);
                    if ((g & 0xFFFFFF00) != 0)
                        if ((g & 0x80000000) != 0) g = 0;
                        else                       g = 255;
                    if (a < g) a = g;

                    b = (int)((srcP&0xFF)*(dstP&0xFF)*k1 +
                              (srcP&0xFF)*k2 + (dstP&0xFF)*k3 + k4);
                    if ((b & 0xFFFFFF00) != 0)
                        if ((b & 0x80000000) != 0) b = 0;
                        else                       b = 255;
                    if (a < b) a = b;

                    dstOutPixels[dstOutSp++]
                        = ((a<<24) | (r<<16) | (g<<8) | b);
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
            // long endTime = System.currentTimeMillis();
            // System.out.println("Arith Time: " + (endTime-startTime));
        }
    }

    public static class ArithCompositeContext_INT_PACK_LUT
        extends AlphaPreCompositeContext_INT_PACK {
        byte [] lut;
        ArithCompositeContext_INT_PACK_LUT(ColorModel srcCM,
                                           ColorModel dstCM,
                                           float k1, float k2,
                                           float k3, float k4) {
            super(srcCM, dstCM);
            k1 = k1/255.0f;
            k4 = k4*255.0f+0.5f;
            int sz = 256*256;
            lut = new byte[sz];
            int val;
            for (int i=0; i<sz; i++) {
                val = (int)((i>>8)*(i&0xFF)*k1 + (i>>8)*k2 + (i&0xFF)*k3 + k4);
                if ((val & 0xFFFFFF00) != 0)
                    if ((val & 0x80000000) != 0) val = 0;
                    else                         val = 255;
                lut[i] = (byte)val;
            }
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            byte[] workTbl = lut;   // local is cheaper
            int srcP, dstP;
            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP = srcPixels  [srcSp++];
                    dstP = dstInPixels[dstInSp++];

                    int a = 0xFF & workTbl[(((srcP>> 16)&0xFF00)|((dstP>>>24)       ))];
                    int r = 0xFF & workTbl[(((srcP>>  8)&0xFF00)|((dstP>> 16)&0x00FF))];
                    int g = 0xFF & workTbl[(((srcP     )&0xFF00)|((dstP>>  8)&0x00FF))];
                    int b = 0xFF & workTbl[(((srcP<<  8)&0xFF00)|((dstP     )&0x00FF))];
                    if (r>a) a = r;
                    if (g>a) a = g;
                    if (b>a) a = b;
                    dstOutPixels[dstOutSp++] = (a<<24)|(r<<16)|(g<<8)|(b);
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
            // long endTime = System.currentTimeMillis();
            // System.out.println("ArithLut Time: " + (endTime-startTime));
        }
    }


    /**
     * The following classes implement the various blend modes from SVG.  */
    public static class MultiplyCompositeContext
        extends AlphaPreCompositeContext {

        MultiplyCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);
            int srcM, dstM;

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                int sp  = 0;
                int end = w*4;
                while(sp<end) {
                    srcM = 255-dstPix[sp+3];
                    dstM = 255-srcPix[sp+3];

                    dstPix[sp] = ((srcPix[sp]*srcM + dstPix[sp]*dstM +
                                   srcPix[sp]*dstPix[sp])*norm + pt5)>>>24;
                    ++sp;

                    dstPix[sp] = ((srcPix[sp]*srcM + dstPix[sp]*dstM +
                                   srcPix[sp]*dstPix[sp])*norm + pt5)>>>24;
                    ++sp;

                    dstPix[sp] = ((srcPix[sp]*srcM + dstPix[sp]*dstM +
                                   srcPix[sp]*dstPix[sp])*norm + pt5)>>>24;
                    ++sp;

                    dstPix[sp] = (srcPix[sp] + dstPix[sp] -
                                  ((dstPix[sp]*srcPix[sp]*norm + pt5)>>>24));
                    ++sp;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }
        }
    }

    public static class MultiplyCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        MultiplyCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcA, srcR, srcG, srcB, srcM;
            int dstP, dstA, dstR, dstG, dstB, dstM;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP = srcPixels  [srcSp++];
                    dstP = dstInPixels[dstInSp++];

                    srcA = (srcP>>>24);
                    dstA = (dstP>>>24);
                    srcR = (srcP>> 16)&0xFF;
                    dstR = (dstP>> 16)&0xFF;
                    srcG = (srcP>>  8)&0xFF;
                    dstG = (dstP>>  8)&0xFF;
                    srcB = (srcP     )&0xFF;
                    dstB = (dstP     )&0xFF;

                    srcM = 255-dstA;
                    dstM = 255-srcA;

                    dstOutPixels[dstOutSp++] =
                        (((((srcR*srcM + dstR*dstM + srcR*dstR)
                            *norm + pt5)&0xFF000000)>>> 8) |
                         ((((srcG*srcM + dstG*dstM + srcG*dstG)
                            *norm + pt5)&0xFF000000)>>>16) |
                         ((((srcB*srcM + dstB*dstM + srcB*dstB)
                            *norm + pt5)           )>>>24) |
                         ((srcA + dstA - ((srcA*dstA*norm + pt5)>>>24))<<24));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    public static class ScreenCompositeContext
        extends AlphaPreCompositeContext {

        ScreenCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                int sp  = 0;
                int end = w*4;
                while(sp<end) {

                    int iSrcPix = srcPix[ sp ];
                    int iDstPix = dstPix[ sp ];

                    dstPix[sp] = ( iSrcPix + iDstPix -
                                  ((iDstPix*iSrcPix*norm + pt5)>>>24));
                    ++sp;
                    iSrcPix = srcPix[ sp ];
                    iDstPix = dstPix[ sp ];
                    dstPix[sp] = ( iSrcPix + iDstPix -
                                  ((iDstPix*iSrcPix*norm + pt5)>>>24));
                    ++sp;
                    iSrcPix = srcPix[ sp ];
                    iDstPix = dstPix[ sp ];
                    dstPix[sp] = ( iSrcPix + iDstPix -
                                  ((iDstPix*iSrcPix*norm + pt5)>>>24));
                    ++sp;
                    iSrcPix = srcPix[ sp ];
                    iDstPix = dstPix[ sp ];
                    dstPix[sp] = ( iSrcPix + iDstPix -
                                  ((iDstPix*iSrcPix*norm + pt5)>>>24));
                    ++sp;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }
        }
    }

    public static class ScreenCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        ScreenCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcA, srcR, srcG, srcB;
            int dstP, dstA, dstR, dstG, dstB;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP = srcPixels  [srcSp++];
                    dstP = dstInPixels[dstInSp++];

                    srcA = (srcP>>>24);
                    dstA = (dstP>>>24);
                    srcR = (srcP>> 16)&0xFF;
                    dstR = (dstP>> 16)&0xFF;
                    srcG = (srcP>>  8)&0xFF;
                    dstG = (dstP>>  8)&0xFF;
                    srcB = (srcP     )&0xFF;
                    dstB = (dstP     )&0xFF;

                    dstOutPixels[dstOutSp++] =
                        (((srcR + dstR - ((srcR*dstR*norm + pt5)>>>24))<<16)|
                         ((srcG + dstG - ((srcG*dstG*norm + pt5)>>>24))<< 8)|
                         ((srcB + dstB - ((srcB*dstB*norm + pt5)>>>24))    )|
                         ((srcA + dstA - ((srcA*dstA*norm + pt5)>>>24))<<24));
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    public static class DarkenCompositeContext
        extends AlphaPreCompositeContext {

        DarkenCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int sp, srcM, dstM, t1, t2;

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                sp  = 0;
                final int end = w*4;
                while(sp<end) {
                    srcM = 255-dstPix[sp+3];
                    dstM = 255-srcPix[sp+3];

                    t1 = ((srcM*srcPix[sp]*norm + pt5)>>>24) + dstPix[sp];
                    t2 = ((dstM*dstPix[sp]*norm + pt5)>>>24) + srcPix[sp];
                    if (t1 > t2) dstPix[sp] = t2;
                    else         dstPix[sp] = t1;
                    ++sp;

                    t1 = ((srcM*srcPix[sp]*norm + pt5)>>>24) + dstPix[sp];
                    t2 = ((dstM*dstPix[sp]*norm + pt5)>>>24) + srcPix[sp];
                    if (t1 > t2) dstPix[sp] = t2;
                    else         dstPix[sp] = t1;
                    ++sp;

                    t1 = ((srcM*srcPix[sp]*norm + pt5)>>>24) + dstPix[sp];
                    t2 = ((dstM*dstPix[sp]*norm + pt5)>>>24) + srcPix[sp];
                    if (t1 > t2) dstPix[sp] = t2;
                    else         dstPix[sp] = t1;
                    ++sp;

                    dstPix[sp] = (srcPix[sp] + dstPix[sp] -
                                  ((dstPix[sp]*srcPix[sp]*norm + pt5)>>>24));
                    ++sp;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }
        }
    }

    public static class DarkenCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        DarkenCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcM;
            int dstP, dstM, dstA, dstR, dstG, dstB;

            int srcV, dstV, tmp;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP = srcPixels  [srcSp++];
                    dstP = dstInPixels[dstInSp++];

                    srcV = (srcP>>>24);
                    dstV = (dstP>>>24);
                    srcM = (255-dstV)*norm;
                    dstM = (255-srcV)*norm;
                    dstA = (srcV + dstV - ((srcV*dstV*norm + pt5)>>>24));

                    srcV = (srcP>> 16)&0xFF;
                    dstV = (dstP>> 16)&0xFF;
                    dstR = ((srcM*srcV + pt5)>>>24) + dstV;
                    tmp  = ((dstM*dstV + pt5)>>>24) + srcV;
                    if (dstR > tmp) dstR = tmp;

                    srcV = (srcP>>  8)&0xFF;
                    dstV = (dstP>>  8)&0xFF;
                    dstG = ((srcM*srcV + pt5)>>>24) + dstV;
                    tmp  = ((dstM*dstV + pt5)>>>24) + srcV;
                    if (dstG > tmp) dstG = tmp;


                    srcV = (srcP     )&0xFF;
                    dstV = (dstP     )&0xFF;
                    dstB = ((srcM*srcV + pt5)>>>24) + dstV;
                    tmp  = ((dstM*dstV + pt5)>>>24) + srcV;
                    if (dstB > tmp) dstB = tmp;

                    dstA &= 0xFF; // trim to 8 bit
                    dstR &= 0xFF;
                    dstG &= 0xFF;
                    dstB &= 0xFF;

                    dstOutPixels[dstOutSp++] =
                        ((dstA<<24) | (dstR<<16) | (dstG<< 8) | dstB);
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

    public static class LightenCompositeContext
        extends AlphaPreCompositeContext {

        LightenCompositeContext(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose(Raster src, Raster dstIn,
                               WritableRaster dstOut) {
            int [] srcPix = null;
            int [] dstPix = null;

            int x=dstOut.getMinX();
            int w=dstOut.getWidth();

            int y0=dstOut.getMinY();
            int y1=y0 + dstOut.getHeight();

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int sp, srcM, dstM, t1, t2;

            for (int y = y0; y<y1; y++) {
                srcPix = src.getPixels  (x, y, w, 1, srcPix);
                dstPix = dstIn.getPixels(x, y, w, 1, dstPix);
                sp  = 0;
                final int end = w*4;
                while(sp<end) {
                    srcM = 255-dstPix[sp+3];
                    dstM = 255-srcPix[sp+3];

                    t1 = ((srcM*srcPix[sp]*norm + pt5)>>>24) + dstPix[sp];
                    t2 = ((dstM*dstPix[sp]*norm + pt5)>>>24) + srcPix[sp];
                    if (t1 > t2) dstPix[sp] = t1;
                    else         dstPix[sp] = t2;
                    ++sp;

                    t1 = ((srcM*srcPix[sp]*norm + pt5)>>>24) + dstPix[sp];
                    t2 = ((dstM*dstPix[sp]*norm + pt5)>>>24) + srcPix[sp];
                    if (t1 > t2) dstPix[sp] = t1;
                    else         dstPix[sp] = t2;
                    ++sp;

                    t1 = ((srcM*srcPix[sp]*norm + pt5)>>>24) + dstPix[sp];
                    t2 = ((dstM*dstPix[sp]*norm + pt5)>>>24) + srcPix[sp];
                    if (t1 > t2) dstPix[sp] = t1;
                    else         dstPix[sp] = t2;
                    ++sp;

                    dstPix[sp] = (srcPix[sp] + dstPix[sp] -
                                  ((dstPix[sp]*srcPix[sp]*norm + pt5)>>>24));
                    ++sp;
                }
                dstOut.setPixels(x, y, w, 1, dstPix);
            }
        }
    }

    public static class LightenCompositeContext_INT_PACK
        extends AlphaPreCompositeContext_INT_PACK {
        LightenCompositeContext_INT_PACK(ColorModel srcCM, ColorModel dstCM) {
            super(srcCM, dstCM);
        }

        public void precompose_INT_PACK
            (final int width,           final int height,
             final int [] srcPixels,    final int srcAdjust,    int srcSp,
             final int [] dstInPixels,  final int dstInAdjust,  int dstInSp,
             final int [] dstOutPixels, final int dstOutAdjust, int dstOutSp) {

            final int norm = (1<<24)/255;
            final int pt5  = (1<<23);

            int srcP, srcM;
            int dstP, dstM, dstA, dstR, dstG, dstB;

            int srcV, dstV, tmp;

            for (int y = 0; y<height; y++) {
                final int end = dstOutSp+width;
                while (dstOutSp<end) {
                    srcP = srcPixels  [srcSp++];
                    dstP = dstInPixels[dstInSp++];

                    srcV = (srcP>>>24);
                    dstV = (dstP>>>24);
                    srcM = (255-dstV)*norm;
                    dstM = (255-srcV)*norm;
                    dstA = (srcV + dstV - ((srcV*dstV*norm + pt5)>>>24));

                    srcV = (srcP>> 16)&0xFF;
                    dstV = (dstP>> 16)&0xFF;
                    dstR = ((srcM*srcV + pt5)>>>24) + dstV;
                    tmp  = ((dstM*dstV + pt5)>>>24) + srcV;
                    if (dstR < tmp) dstR = tmp;

                    srcV = (srcP>>  8)&0xFF;
                    dstV = (dstP>>  8)&0xFF;
                    dstG = ((srcM*srcV + pt5)>>>24) + dstV;
                    tmp  = ((dstM*dstV + pt5)>>>24) + srcV;
                    if (dstG < tmp) dstG = tmp;


                    srcV = (srcP     )&0xFF;
                    dstV = (dstP     )&0xFF;
                    dstB = ((srcM*srcV + pt5)>>>24) + dstV;
                    tmp  = ((dstM*dstV + pt5)>>>24) + srcV;
                    if (dstB < tmp) dstB = tmp;

                    dstA &= 0xFF; // trim to 8 bit
                    dstR &= 0xFF;
                    dstG &= 0xFF;
                    dstB &= 0xFF;

                    dstOutPixels[dstOutSp++] =
                        ((dstA<<24) | (dstR<<16) | (dstG<< 8) | dstB);
                }
                srcSp    += srcAdjust;
                dstInSp  += dstInAdjust;
                dstOutSp += dstOutAdjust;
            }
        }
    }

}
