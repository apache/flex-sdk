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

import java.awt.geom.Rectangle2D;
import java.util.Map;
import java.util.StringTokenizer;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ColorMatrixRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ColorMatrixRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;feColorMatrix> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFeColorMatrixElementBridge.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class SVGFeColorMatrixElementBridge
    extends AbstractSVGFilterPrimitiveElementBridge {

    /**
     * Constructs a new bridge for the &lt;feColorMatrix> element.
     */
    public SVGFeColorMatrixElementBridge() {}

    /**
     * Returns 'feColorMatrix'.
     */
    public String getLocalName() {
        return SVG_FE_COLOR_MATRIX_TAG;
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

        int type = convertType(filterElement, ctx);
        ColorMatrixRable colorMatrix;
        switch (type) {
        case ColorMatrixRable.TYPE_HUE_ROTATE:
            float a = convertValuesToHueRotate(filterElement, ctx);
            colorMatrix = ColorMatrixRable8Bit.buildHueRotate(a);
            break;
        case ColorMatrixRable.TYPE_LUMINANCE_TO_ALPHA:
            colorMatrix = ColorMatrixRable8Bit.buildLuminanceToAlpha();
            break;
        case ColorMatrixRable.TYPE_MATRIX:
            float [][] matrix = convertValuesToMatrix(filterElement, ctx);
            colorMatrix = ColorMatrixRable8Bit.buildMatrix(matrix);
            break;
        case ColorMatrixRable.TYPE_SATURATE:
            float s = convertValuesToSaturate(filterElement, ctx);
            colorMatrix = ColorMatrixRable8Bit.buildSaturate(s);
            break;
        default:
            throw new Error("invalid convertType:" + type ); // can't be reached
        }
        colorMatrix.setSource(in);

        // handle the 'color-interpolation-filters' property
        handleColorInterpolationFilters(colorMatrix, filterElement);

        Filter filter
            = new PadRable8Bit(colorMatrix, primitiveRegion, PadMode.ZERO_PAD);

        // update the filter Map
        updateFilterMap(filterElement, filter, filterMap);

        return filter;
    }

    /**
     * Converts the 'values' attribute of the specified feColorMatrix
     * filter primitive element for the 'matrix' type.
     *
     * @param filterElement the filter element
     * @param ctx the BridgeContext to use for error information
     */
    protected static float[][] convertValuesToMatrix(Element filterElement,
                                                     BridgeContext ctx) {
        String s = filterElement.getAttributeNS(null, SVG_VALUES_ATTRIBUTE);
        float [][] matrix = new float[4][5];
        if (s.length() == 0) {
            matrix[0][0] = 1;
            matrix[1][1] = 1;
            matrix[2][2] = 1;
            matrix[3][3] = 1;
            return matrix;
        }
        StringTokenizer tokens = new StringTokenizer(s, " ,");
        int n = 0;
        try {
            while (n < 20 && tokens.hasMoreTokens()) {
                matrix[n/5][n%5]
                    = SVGUtilities.convertSVGNumber(tokens.nextToken());
                n++;
            }
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_VALUES_ATTRIBUTE, s, nfEx });
        }
        if (n != 20 || tokens.hasMoreTokens()) {
            throw new BridgeException
                (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_VALUES_ATTRIBUTE, s});
        }

        for (int i = 0; i < 4; ++i) {
            matrix[i][4] *= 255;
        }
        return matrix;
    }

    /**
     * Converts the 'values' attribute of the specified feColorMatrix
     * filter primitive element for the 'saturate' type.
     *
     * @param filterElement the filter element
     * @param ctx the BridgeContext to use for error information
     */
    protected static float convertValuesToSaturate(Element filterElement,
                                                   BridgeContext ctx) {
        String s = filterElement.getAttributeNS(null, SVG_VALUES_ATTRIBUTE);
        if (s.length() == 0)
            return 1; // default is 1
        try {
            return SVGUtilities.convertSVGNumber(s);
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_VALUES_ATTRIBUTE, s});
        }
    }

    /**
     * Converts the 'values' attribute of the specified feColorMatrix
     * filter primitive element for the 'hueRotate' type.
     *
     * @param filterElement the filter element
     * @param ctx the BridgeContext to use for error information
     */
    protected static float convertValuesToHueRotate(Element filterElement,
                                                    BridgeContext ctx) {
        String s = filterElement.getAttributeNS(null, SVG_VALUES_ATTRIBUTE);
        if (s.length() == 0)
            return 0; // default is 0
        try {
            return (float) Math.toRadians( SVGUtilities.convertSVGNumber(s) );
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object [] {SVG_VALUES_ATTRIBUTE, s});
        }
    }

    /**
     * Converts the type of the specified color matrix filter primitive.
     *
     * @param filterElement the filter element
     * @param ctx the BridgeContext to use for error information
     */
    protected static int convertType(Element filterElement, BridgeContext ctx) {
        String s = filterElement.getAttributeNS(null, SVG_TYPE_ATTRIBUTE);
        if (s.length() == 0) {
            return ColorMatrixRable.TYPE_MATRIX;
        }
        if (SVG_HUE_ROTATE_VALUE.equals(s)) {
            return ColorMatrixRable.TYPE_HUE_ROTATE;
        }
        if (SVG_LUMINANCE_TO_ALPHA_VALUE.equals(s)) {
            return ColorMatrixRable.TYPE_LUMINANCE_TO_ALPHA;
        }
        if (SVG_MATRIX_VALUE.equals(s)) {
            return ColorMatrixRable.TYPE_MATRIX;
        }
        if (SVG_SATURATE_VALUE.equals(s)) {
            return ColorMatrixRable.TYPE_SATURATE;
        }
        throw new BridgeException
            (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
             new Object[] {SVG_TYPE_ATTRIBUTE, s});
    }
}
