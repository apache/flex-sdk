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
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.GaussianBlurRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;feGaussianBlur> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFeGaussianBlurElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class SVGFeGaussianBlurElementBridge
    extends AbstractSVGFilterPrimitiveElementBridge {


    /**
     * Constructs a new bridge for the &lt;feGaussianBlur> element.
     */
    public SVGFeGaussianBlurElementBridge() {}

    /**
     * Returns 'feGaussianBlur'.
     */
    public String getLocalName() {
        return SVG_FE_GAUSSIAN_BLUR_TAG;
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

        // 'stdDeviation' attribute - default is [0, 0]
        float[] stdDeviationXY = convertStdDeviation(filterElement, ctx);
        if (stdDeviationXY[0] < 0 || stdDeviationXY[1] < 0) {
            throw new BridgeException(ctx, filterElement,
                                      ERR_ATTRIBUTE_VALUE_MALFORMED,
                                      new Object[] {SVG_STD_DEVIATION_ATTRIBUTE,
                                                    String.valueOf( stdDeviationXY[ 0 ] ) +
                                                    stdDeviationXY[1]});
        }

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

        // Take the filter primitive region into account, we need to
        // pad/crop the input and output.
        PadRable pad = new PadRable8Bit(in, primitiveRegion, PadMode.ZERO_PAD);

        // build filter
        Filter blur = new GaussianBlurRable8Bit
            (pad, stdDeviationXY[0], stdDeviationXY[1]);

        // handle the 'color-interpolation-filters' property
        handleColorInterpolationFilters(blur, filterElement);

        PadRable filter
            = new PadRable8Bit(blur, primitiveRegion, PadMode.ZERO_PAD);

        // update the filter Map
        updateFilterMap(filterElement, filter, filterMap);

        return filter;
    }

    /**
     * Returns the standard deviation of the specified feGaussianBlur
     * filter primitive element.
     *
     * @param filterElement the feGaussianBlur filter primitive element
     * @param ctx the BridgeContext to use for error information
     */
    protected static float[] convertStdDeviation(Element filterElement,
                                                 BridgeContext ctx) {
        String s
            = filterElement.getAttributeNS(null, SVG_STD_DEVIATION_ATTRIBUTE);
        if (s.length() == 0) {
            return new float[] {0, 0};
        }
        float [] stdDevs = new float[2];
        StringTokenizer tokens = new StringTokenizer(s, " ,");
        try {
            stdDevs[0] = SVGUtilities.convertSVGNumber(tokens.nextToken());
            if (tokens.hasMoreTokens()) {
                stdDevs[1] = SVGUtilities.convertSVGNumber(tokens.nextToken());
            } else {
                stdDevs[1] = stdDevs[0];
            }
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_STD_DEVIATION_ATTRIBUTE, s, nfEx });
        }
        if (tokens.hasMoreTokens()) {
            throw new BridgeException
                (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_STD_DEVIATION_ATTRIBUTE, s});
        }
        return stdDevs;
    }
}
