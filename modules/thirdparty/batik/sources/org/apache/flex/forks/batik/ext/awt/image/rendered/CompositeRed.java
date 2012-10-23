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
package org.apache.flex.forks.batik.ext.awt.image.rendered;

import java.awt.CompositeContext;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.color.ColorSpace;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.DirectColorModel;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

import org.apache.flex.forks.batik.ext.awt.image.CompositeRule;
import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.SVGComposite;

/**
 * This is an implementation of an affine operation as a RenderedImage.
 * Right now the implementation makes use of the AffineBufferedImageOp
 * to do the work.  Eventually this may move to be more tiled in nature.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: CompositeRed.java 489226 2006-12-21 00:05:36Z cam $
 */
public class CompositeRed extends AbstractRed {

    CompositeRule rule;
    CompositeContext [] contexts;

    public CompositeRed(List srcs, CompositeRule rule) {
        super(); // We _must_ call init...

        CachableRed src = (CachableRed)srcs.get(0);

        ColorModel  cm = fixColorModel (src);

        this.rule = rule;

        SVGComposite comp = new SVGComposite(rule);
        contexts = new CompositeContext[srcs.size()];

        int idx = 0;
        Iterator i = srcs.iterator();
        Rectangle myBounds = null;
        while (i.hasNext()) {
            CachableRed cr = (CachableRed)i.next();

            contexts[idx++] = comp.createContext(cr.getColorModel(), cm, null);

            Rectangle newBound = cr.getBounds();
            if (myBounds == null) {
                myBounds = newBound;
                continue;
            }

            switch (rule.getRule()) {
            case CompositeRule.RULE_IN:
                if (myBounds.intersects(newBound))
                    myBounds = myBounds.intersection(newBound);
                else {
                    myBounds.width = 0;
                    myBounds.height = 0;
                }
                break;
            case CompositeRule.RULE_OUT:
                // Last node determines bounds...
                myBounds = newBound;
                break;
            default:
                // myBounds= myBounds.union(newBound);
                myBounds.add( newBound );
            }
        }

        if (myBounds == null)
            throw new IllegalArgumentException
                ("Composite Operation Must have some source!");

        if (rule.getRule() == CompositeRule.RULE_ARITHMETIC) {
            List vec = new ArrayList( srcs.size() );
            i = srcs.iterator();
            while (i.hasNext()) {
                CachableRed cr = (CachableRed)i.next();
                Rectangle r = cr.getBounds();
                // For arithmetic make sure they are all the same size...
                if ((r.x      != myBounds.x) ||
                    (r.y      != myBounds.y) ||
                    (r.width  != myBounds.width) ||
                    (r.height != myBounds.height))
                    cr = new PadRed(cr, myBounds, PadMode.ZERO_PAD, null);
                vec.add(cr);
            }
            srcs = vec;
        }

        // fix my sample model so it makes sense given my size.
        SampleModel sm = fixSampleModel(src, cm, myBounds);

        // System.out.println("Comp: " + myBounds);
        // System.out.println("  SM: " + sm.getWidth()+"x"+sm.getHeight());

        int defSz = AbstractTiledRed.getDefaultTileSize();

        // Make tile(0,0) fall on the closest intersection of defaultSz.
        int tgX = defSz*(int)Math.floor(myBounds.x/defSz);
        int tgY = defSz*(int)Math.floor(myBounds.y/defSz);

        // Finish initializing our base class...
        init(srcs, myBounds, cm, sm, tgX, tgY, null);
    }

    public WritableRaster copyData(WritableRaster wr) {
        // copyToRaster(wr);
        genRect(wr);
        return wr;
    }

    public Raster getTile(int x, int y) {
        int tx = tileGridXOff+x*tileWidth;
        int ty = tileGridYOff+y*tileHeight;
        Point pt = new Point(tx, ty);
        WritableRaster wr = Raster.createWritableRaster(sm, pt);
        genRect(wr);

        return wr;
    }

    public void emptyRect(WritableRaster wr) {
        PadRed.ZeroRecter zr = PadRed.ZeroRecter.getZeroRecter(wr);
        zr.zeroRect(new Rectangle(wr.getMinX(), wr.getMinY(),
                                  wr.getWidth(), wr.getHeight()));
    }

    public void genRect(WritableRaster wr) {
        // long startTime = System.currentTimeMillis();
        // System.out.println("Comp GenR: " + wr);
        Rectangle r = wr.getBounds();

        int idx = 0;
        Iterator i = srcs.iterator();
        boolean first = true;
        while (i.hasNext()) {
            CachableRed cr = (CachableRed)i.next();
            if (first) {
                Rectangle crR = cr.getBounds();
                if ((r.x < crR.x)                   ||
                    (r.y < crR.y)                   ||
                    (r.x+r.width > crR.x+crR.width) ||
                    (r.y+r.height > crR.y+crR.height))
                    // Portions outside my bounds, zero them...
                    emptyRect(wr);

                // Fill in initial image...
                cr.copyData(wr);

                if ( ! cr.getColorModel().isAlphaPremultiplied() )
                    GraphicsUtil.coerceData(wr, cr.getColorModel(), true);
                first = false;
            } else {
                Rectangle crR = cr.getBounds();
                if (crR.intersects(r)) {
                    Rectangle smR = crR.intersection(r);
                    Raster ras = cr.getData(smR);
                    WritableRaster smWR = wr.createWritableChild
                        (smR.x, smR.y, smR.width, smR.height,
                         smR.x, smR.y, null);

                    contexts[idx].compose(ras, smWR, smWR);
                }
            }

            idx++;
        }
        // long endTime = System.currentTimeMillis();
        // System.out.println("Other: " + (endTime-startTime));
    }

    // This is an alternate Implementation that uses drawImage.
    // In testing this was not significantly faster and it had some
    // problems with alpha premultiplied.
    public void genRect_OVER(WritableRaster wr) {
        // long startTime = System.currentTimeMillis();
        // System.out.println("Comp GenR: " + wr);
        Rectangle r = wr.getBounds();

        ColorModel cm = getColorModel();

        BufferedImage bi = new BufferedImage
            (cm, wr.createWritableTranslatedChild(0,0),
             cm.isAlphaPremultiplied(), null);

        Graphics2D g2d = GraphicsUtil.createGraphics(bi);
        g2d.translate(-r.x, -r.y);

        Iterator i = srcs.iterator();
        boolean first = true;
        while (i.hasNext()) {
            CachableRed cr = (CachableRed)i.next();
            if (first) {
                Rectangle crR = cr.getBounds();
                if ((r.x < crR.x)                   ||
                    (r.y < crR.y)                   ||
                    (r.x+r.width > crR.x+crR.width) ||
                    (r.y+r.height > crR.y+crR.height))
                    // Portions outside my bounds, zero them...
                    emptyRect(wr);

                // Fill in initial image...
                cr.copyData(wr);

                GraphicsUtil.coerceData(wr, cr.getColorModel(),
                                        cm.isAlphaPremultiplied());
                first = false;
            } else {
                GraphicsUtil.drawImage(g2d, cr);
            }
        }
        // long endTime = System.currentTimeMillis();
        // System.out.println("OVER: " + (endTime-startTime));
    }

        /**
         * This function 'fixes' the source's sample model.
         * right now it just ensures that the sample model isn't
         * much larger than my width.
         */
    protected static SampleModel fixSampleModel(CachableRed src,
                                                ColorModel  cm,
                                                Rectangle   bounds) {
        int defSz = AbstractTiledRed.getDefaultTileSize();

        // Make tile(0,0) fall on the closest intersection of defaultSz.
        int tgX = defSz*(int)Math.floor(bounds.x/defSz);
        int tgY = defSz*(int)Math.floor(bounds.y/defSz);

        int tw  = (bounds.x+bounds.width)-tgX;
        int th  = (bounds.y+bounds.height)-tgY;

        SampleModel sm = src.getSampleModel();

        int  w  = sm.getWidth();
        if (w < defSz) w = defSz;
        if (w > tw)    w = tw;

        int h   = sm.getHeight();
        if (h < defSz) h = defSz;
        if (h > th)    h = th;

        if ((w <= 0) || (h <= 0)) {
            w = 1;
            h = 1;
        }

        // System.out.println("tg: " + tgX + "x" + tgY);
        // System.out.println("t: " + tw + "x" + th);
        // System.out.println("sz: " + w + "x" + h);

        return cm.createCompatibleSampleModel(w, h);
    }

    protected static ColorModel fixColorModel(CachableRed src) {
        ColorModel  cm = src.getColorModel();

        if (cm.hasAlpha()) {
            if (!cm.isAlphaPremultiplied())
                cm = GraphicsUtil.coerceColorModel(cm, true);
            return cm;
        }

        int b = src.getSampleModel().getNumBands()+1;
        if (b > 4)
            throw new IllegalArgumentException
                ("CompositeRed can only handle up to three band images");

        int [] masks = new int[4];
        for (int i=0; i < b-1; i++)
            masks[i] = 0xFF0000 >> (8*i);
        masks[3] = 0xFF << (8*(b-1));
        ColorSpace cs = cm.getColorSpace();

        return new DirectColorModel(cs, 8*b, masks[0], masks[1],
                                    masks[2], masks[3],
                                    true, DataBuffer.TYPE_INT);
    }
}
