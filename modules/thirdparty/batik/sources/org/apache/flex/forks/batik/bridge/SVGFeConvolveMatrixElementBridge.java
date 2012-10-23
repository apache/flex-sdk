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
package org.apache.flex.forks.batik.bridge;

import java.awt.Point;
import java.awt.geom.Rectangle2D;
import java.awt.image.Kernel;
import java.util.Map;
import java.util.StringTokenizer;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ConvolveMatrixRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ConvolveMatrixRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;feConvolveMatrix> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFeConvolveMatrixElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class SVGFeConvolveMatrixElementBridge
    extends AbstractSVGFilterPrimitiveElementBridge {


    /**
     * Constructs a new bridge for the &lt;feConvolveMatrix> element.
     */
    public SVGFeConvolveMatrixElementBridge() {}

    /**
     * Returns 'feConvolveMatrix'.
     */
    public String getLocalName() {
        return SVG_FE_CONVOLVE_MATRIX_TAG;
    }

    /**
     * Creates a <tt>Filter</tt> primitive according to the specified
     * parameters.
     *
     * @param ctx the bridge context to use
     * @param filterElement the element that defines a filter
     * @param filteredElement the element that references the filter
     * @param filteredNode the graphics node to filter
     *
     * @param inputFilter the <tt>Filter</tt> that represents the current
     *        filter input if the filter chain.
     * @param filterRegion the filter area defined for the filter chain
     *        the new node will be part of.
     * @param filterMap a map where the mediator can map a name to the
     *        <tt>Filter</tt> it creates. Other <tt>FilterBridge</tt>s
     *        can then access a filter node from the filterMap if they
     *        know its name.
     */
    public Filter createFilter(BridgeContext ctx,
                               Element filterElement,
                               Element filteredElement,
                               GraphicsNode filteredNode,
                               Filter inputFilter,
                               Rectangle2D filterRegion,
                               Map filterMap) {

        // 'order' attribute - default is [3, 3]
        int[] orderXY = convertOrder(filterElement, ctx);

        // 'kernelMatrix' attribute - required
        float[] kernelMatrix = convertKernelMatrix(filterElement, orderXY, ctx);

        // 'divisor' attribute - default is kernel matrix sum or 1 if sum is 0
        float divisor = convertDivisor(filterElement, kernelMatrix, ctx);

        // 'bias' attribute - default is 0
        float bias = convertNumber(filterElement, SVG_BIAS_ATTRIBUTE, 0, ctx);

        // 'targetX' and 'targetY' attribute
        int[] targetXY = convertTarget(filterElement, orderXY, ctx);

        // 'edgeMode' attribute - default is 'duplicate'
        PadMode padMode = convertEdgeMode(filterElement, ctx);

        // 'kernelUnitLength' attribute
        double[] kernelUnitLength = convertKernelUnitLength(filterElement, ctx);

        // 'preserveAlpha' attribute - default is 'false'
        boolean preserveAlpha = convertPreserveAlpha(filterElement, ctx);

        // 'in' attribute
        Filter in = getIn(filterElement,
                          filteredElement,
                          filteredNode,
                          inputFilter,
                          filterMap,
                          ctx);
        if (in == null) {
            return null; // disable the filter
        }

        // Default region is the size of in (if in is SourceGraphic or
        // SourceAlpha it will already include a pad/crop to the
        // proper filter region size).
        Rectangle2D defaultRegion = in.getBounds2D();
        Rectangle2D primitiveRegion
            = SVGUtilities.convertFilterPrimitiveRegion(filterElement,
                                                        filteredElement,
                                                        filteredNode,
                                                        defaultRegion,
                                                        filterRegion,
                                                        ctx);

        PadRable pad = new PadRable8Bit(in, primitiveRegion, PadMode.ZERO_PAD);

        // build the convolve filter
        ConvolveMatrixRable convolve = new ConvolveMatrixRable8Bit(pad);
        for (int i = 0; i < kernelMatrix.length; i++) {
            kernelMatrix[i] /= divisor;
        }
        convolve.setKernel(new Kernel(orderXY[0], orderXY[1], kernelMatrix));
        convolve.setTarget(new Point(targetXY[0], targetXY[1]));
        convolve.setBias(bias);
        convolve.setEdgeMode(padMode);
        convolve.setKernelUnitLength(kernelUnitLength);
        convolve.setPreserveAlpha(preserveAlpha);

        // handle the 'color-interpolation-filters' property
        handleColorInterpolationFilters(convolve, filterElement);

        PadRable filter = new PadRable8Bit
            (convolve, primitiveRegion, PadMode.ZERO_PAD);

        // update the filter Map
        updateFilterMap(filterElement, filter, filterMap);

        return filter;
    }

    /**
     * Convert the 'order' attribute of the specified feConvolveMatrix
     * filter primitive element.
     *
     * @param filterElement the feConvolveMatrix filter primitive element
     * @param ctx the BridgeContext to use for error information
     */
    protected static int[] convertOrder(Element filterElement,
                                        BridgeContext ctx) {
        String s = filterElement.getAttributeNS(null, SVG_ORDER_ATTRIBUTE);
        if (s.length() == 0) {
            return new int[] {3, 3};
        }
        int [] orderXY = new int[2];
        StringTokenizer tokens = new StringTokenizer(s, " ,");
        try {
            orderXY[0] = SVGUtilities.convertSVGInteger(tokens.nextToken());
            if (tokens.hasMoreTokens()) {
                orderXY[1] = SVGUtilities.convertSVGInteger(tokens.nextToken());
            } else {
                orderXY[1] = orderXY[0];
            }
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_ORDER_ATTRIBUTE, s, nfEx });
        }
        if (tokens.hasMoreTokens() || orderXY[0] <= 0 || orderXY[1] <= 0) {
            throw new BridgeException
                (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_ORDER_ATTRIBUTE, s});
        }
        return orderXY;
    }

    /**
     * Convert the 'kernelMatrix' attribute of the specified feConvolveMatrix
     * filter primitive element.
     *
     * @param filterElement the feConvolveMatrix filter primitive element
     * @param orderXY the value of the 'order' attribute
     * @param ctx the BridgeContext to use for error information
     */
    protected static float[] convertKernelMatrix(Element filterElement,
                                                 int[] orderXY,
                                                 BridgeContext ctx) {

        String s =
            filterElement.getAttributeNS(null, SVG_KERNEL_MATRIX_ATTRIBUTE);
        if (s.length() == 0) {
            throw new BridgeException
                (ctx, filterElement, ERR_ATTRIBUTE_MISSING,
                 new Object[] {SVG_KERNEL_MATRIX_ATTRIBUTE});
        }
        int size = orderXY[0]*orderXY[1];
        float [] kernelMatrix = new float[size];
        StringTokenizer tokens = new StringTokenizer(s, " ,");
        int i = 0;
        try {
            while (tokens.hasMoreTokens() && i < size) {
                kernelMatrix[i++]
                    = SVGUtilities.convertSVGNumber(tokens.nextToken());
            }
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_KERNEL_MATRIX_ATTRIBUTE, s, nfEx });
        }
        if (i != size) {
            throw new BridgeException
                (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_KERNEL_MATRIX_ATTRIBUTE, s});
        }
        return kernelMatrix;
    }

    /**
     * Convert the 'divisor' attribute of the specified feConvolveMatrix
     * filter primitive element.
     *
     * @param filterElement the feConvolveMatrix filter primitive element
     * @param kernelMatrix the value of the 'kernelMatrix' attribute
     * @param ctx the BridgeContext to use for error information
     */
    protected static float convertDivisor(Element filterElement,
                                          float[] kernelMatrix,
                                          BridgeContext ctx) {

        String s = filterElement.getAttributeNS(null, SVG_DIVISOR_ATTRIBUTE);
        if (s.length() == 0) {
            // default is sum of kernel values (if sum is zero then 1.0)
            float sum = 0;
            for (int i=0; i < kernelMatrix.length; ++i) {
                sum += kernelMatrix[i];
            }
            return (sum == 0) ? 1.0f : sum;
        } else {
            try {
                return SVGUtilities.convertSVGNumber(s);
            } catch (NumberFormatException nfEx ) {
                throw new BridgeException
                    (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {SVG_DIVISOR_ATTRIBUTE, s, nfEx });
            }
        }
    }

    /**
     * Convert the 'targetX' and 'targetY' attributes of the specified
     * feConvolveMatrix filter primitive element.
     *
     * @param filterElement the feConvolveMatrix filter primitive element
     * @param orderXY the value of the 'order' attribute
     * @param ctx the BridgeContext to use for error information
     */
    protected static int[] convertTarget(Element filterElement, int[] orderXY,
                                         BridgeContext ctx) {

        int[] targetXY = new int[2];
        // 'targetX' attribute - default is floor(orderX / 2)
        String s = filterElement.getAttributeNS(null, SVG_TARGET_X_ATTRIBUTE);
        if (s.length() == 0) {
            targetXY[0] = orderXY[0] / 2;
        } else {
            try {
                int v = SVGUtilities.convertSVGInteger(s);
                if (v < 0 || v >= orderXY[0]) {
                    throw new BridgeException
                        (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                         new Object[] {SVG_TARGET_X_ATTRIBUTE, s});
                }
                targetXY[0] = v;
            } catch (NumberFormatException nfEx ) {
                throw new BridgeException
                    (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {SVG_TARGET_X_ATTRIBUTE, s, nfEx });
            }
        }
        // 'targetY' attribute - default is floor(orderY / 2)
        s = filterElement.getAttributeNS(null, SVG_TARGET_Y_ATTRIBUTE);
        if (s.length() == 0) {
            targetXY[1] = orderXY[1] / 2;
        } else {
            try {
                int v = SVGUtilities.convertSVGInteger(s);
                if (v < 0 || v >= orderXY[1]) {
                    throw new BridgeException
                        (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                         new Object[] {SVG_TARGET_Y_ATTRIBUTE, s});
                }
                targetXY[1] = v;
            } catch (NumberFormatException nfEx ) {
                throw new BridgeException
                    (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {SVG_TARGET_Y_ATTRIBUTE, s, nfEx });
            }
        }
        return targetXY;
    }

    /**
     * Convert the 'kernelUnitLength' attribute of the specified
     * feConvolveMatrix filter primitive element.
     *
     * @param filterElement the feConvolveMatrix filter primitive element
     * @param ctx the BridgeContext to use for error information
     */
    protected static double[] convertKernelUnitLength(Element filterElement,
                                                      BridgeContext ctx) {
        String s = filterElement.getAttributeNS
            (null, SVG_KERNEL_UNIT_LENGTH_ATTRIBUTE);
        if (s.length() == 0) {
            return null;
        }
        double [] units = new double[2];
        StringTokenizer tokens = new StringTokenizer(s, " ,");
        try {
            units[0] = SVGUtilities.convertSVGNumber(tokens.nextToken());
            if (tokens.hasMoreTokens()) {
                units[1] = SVGUtilities.convertSVGNumber(tokens.nextToken());
            } else {
                units[1] = units[0];
            }
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_KERNEL_UNIT_LENGTH_ATTRIBUTE, s});

        }
        if (tokens.hasMoreTokens() || units[0] <= 0 || units[1] <= 0) {
            throw new BridgeException
                (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_KERNEL_UNIT_LENGTH_ATTRIBUTE, s});
        }
        return units;
    }

    /**
     * Convert the 'edgeMode' attribute of the specified feConvolveMatrix
     * filter primitive element.
     *
     * @param filterElement the feConvolveMatrix filter primitive element
     * @param ctx the BridgeContext to use for error information
     */
    protected static PadMode convertEdgeMode(Element filterElement,
                                             BridgeContext ctx) {
        String s = filterElement.getAttributeNS(null, SVG_EDGE_MODE_ATTRIBUTE);
        if (s.length() == 0) {
            return PadMode.REPLICATE;
        }
        if (SVG_DUPLICATE_VALUE.equals(s)) {
            return PadMode.REPLICATE;
        }
        if (SVG_WRAP_VALUE.equals(s)) {
            return PadMode.WRAP;
        }
        if (SVG_NONE_VALUE.equals(s)) {
            return PadMode.ZERO_PAD;
        }
        throw new BridgeException
            (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
             new Object[] {SVG_EDGE_MODE_ATTRIBUTE, s});
    }

    /**
     * Convert the 'preserveAlpha' attribute of the specified feConvolveMatrix
     * filter primitive element.
     *
     * @param filterElement the feConvolveMatrix filter primitive element
     * @param ctx the BridgeContext to use for error information
     */
    protected static boolean convertPreserveAlpha(Element filterElement,
                                                  BridgeContext ctx) {
        String s
            = filterElement.getAttributeNS(null, SVG_PRESERVE_ALPHA_ATTRIBUTE);
        if (s.length() == 0) {
            return false;
        }
        if (SVG_TRUE_VALUE.equals(s)) {
            return true;
        }
        if (SVG_FALSE_VALUE.equals(s)) {
            return false;
        }
        throw new BridgeException
            (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
             new Object[] {SVG_PRESERVE_ALPHA_ATTRIBUTE, s});
    }
}
