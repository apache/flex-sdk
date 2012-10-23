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
package org.apache.flex.forks.batik.extension.svg;

import java.awt.geom.AffineTransform;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.LinearTransfer;
import org.apache.flex.forks.batik.ext.awt.image.TransferFunction;
import org.apache.flex.forks.batik.ext.awt.image.renderable.AbstractColorInterpolationRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.rendered.ComponentTransferRed;

/**
 *
 * @version $Id: BatikHistogramNormalizationFilter8Bit.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class BatikHistogramNormalizationFilter8Bit
    extends      AbstractColorInterpolationRable
    implements   BatikHistogramNormalizationFilter {

    private float trim = 0.01f;

    /**
     * Sets the source of the operation
     */
    public void setSource(Filter src){
        init(src, null);
    }

    /**
     * Returns the source of the operation
     */
    public Filter getSource(){
        return (Filter)getSources().get(0);
    }

    /**
     * Returns the trim percent for this normalization.
     */
    public float getTrim() {
        return trim;
    }

    /**
     * Sets the trim percent for this normalization.
     */
    public void setTrim(float trim) {
        this.trim = trim;
        touch();
    }

    public BatikHistogramNormalizationFilter8Bit(Filter src, float trim) {
        setSource(src);
        setTrim(trim);
    }

    protected int [] histo = null;
    protected float slope, intercept;

    /**
     * This method computes the histogram of the image and
     * from that the appropriate clipping points, which leads
     * to a slope and intercept for a LinearTransfer function
     *
     * @param rc We get the set of rendering hints from rc.
     */
    public void computeHistogram(RenderContext rc) {
        if (histo != null)
            return;

        Filter src = getSource();

        float scale  = 100.0f/src.getWidth();
        float yscale = 100.0f/src.getHeight();

        if (scale > yscale) scale=yscale;

        AffineTransform at = AffineTransform.getScaleInstance(scale, scale);
        rc = new RenderContext(at, rc.getRenderingHints());
        RenderedImage histRI = getSource().createRendering(rc);

        histo = new HistogramRed(convertSourceCS(histRI)).getHistogram();

        int t = (int)(histRI.getWidth()*histRI.getHeight()*trim+0.5);
        int c, i;
        for (c=0, i=0; i<255; i++) {
            c+=histo[i];
            // System.out.println("C[" + i + "] = " + c + "  T: " + t);
            if (c>=t) break;
        }
        int low = i;

        for (c=0, i=255; i>0; i--) {
            c+=histo[i];
            // System.out.println("C[" + i + "] = " + c + "  T: " + t);
            if (c>=t) break;
        }
        int hi = i;

        slope = 255f/(hi-low);
        intercept = (slope*-low)/255f;
    }


    public RenderedImage createRendering(RenderContext rc) {
        //
        // Get source's rendered image
        //
        RenderedImage srcRI = getSource().createRendering(rc);

        if(srcRI == null)
            return null;

        computeHistogram(rc);

        SampleModel sm = srcRI.getSampleModel();
        int bands = sm.getNumBands();

        // System.out.println("Slope, Intercept: " + slope + ", " + intercept);
        TransferFunction [] tfs = new TransferFunction[bands];
        TransferFunction    tf  = new LinearTransfer(slope, intercept);
        for (int i=0; i<tfs.length; i++)
            tfs[i] = tf;

        return new ComponentTransferRed(convertSourceCS(srcRI), tfs, null);
    }
}
