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

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.TurbulenceRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.TurbulenceRable8Bit;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;feTurbulence> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFeTurbulenceElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class SVGFeTurbulenceElementBridge
    extends AbstractSVGFilterPrimitiveElementBridge {

    /**
     * Constructs a new bridge for the &lt;feTurbulence> element.
     */
    public SVGFeTurbulenceElementBridge() {}

    /**
     * Returns 'feTurbulence'.
     */
    public String getLocalName() {
        return SVG_FE_TURBULENCE_TAG;
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

        // default region is the filter chain region
        Rectangle2D defaultRegion = filterRegion;
        Rectangle2D primitiveRegion
            = SVGUtilities.convertFilterPrimitiveRegion(filterElement,
                                                        filteredElement,
                                                        filteredNode,
                                                        defaultRegion,
                                                        filterRegion,
                                                        ctx);

        // 'baseFrequency' attribute - default is [0, 0]
        float [] baseFrequency
            = convertBaseFrenquency(filterElement, ctx);

        // 'numOctaves' attribute - default is 1
        int numOctaves
            = convertInteger(filterElement, SVG_NUM_OCTAVES_ATTRIBUTE, 1, ctx);

        // 'seed' attribute - default is 0
        int seed
            = convertInteger(filterElement, SVG_SEED_ATTRIBUTE, 0, ctx);

        // 'stitchTiles' attribute - default is 'noStitch'
        boolean stitchTiles
            = convertStitchTiles(filterElement, ctx);

        // 'fractalNoise' attribute - default is 'turbulence'
        boolean isFractalNoise
            = convertType(filterElement, ctx);

        // create the filter primitive
        TurbulenceRable turbulenceRable
            = new TurbulenceRable8Bit(primitiveRegion);

        turbulenceRable.setBaseFrequencyX(baseFrequency[0]);
        turbulenceRable.setBaseFrequencyY(baseFrequency[1]);
        turbulenceRable.setNumOctaves(numOctaves);
        turbulenceRable.setSeed(seed);
        turbulenceRable.setStitched(stitchTiles);
        turbulenceRable.setFractalNoise(isFractalNoise);

        // handle the 'color-interpolation-filters' property
        handleColorInterpolationFilters(turbulenceRable, filterElement);

        // update the filter Map
        updateFilterMap(filterElement, turbulenceRable, filterMap);

        return turbulenceRable;
    }

    /**
     * Converts the 'baseFrequency' attribute of the specified
     * feTurbulence element.
     *
     * @param e the feTurbulence element
     * @param ctx the BridgeContext to use for error information
     */
    protected static float[] convertBaseFrenquency(Element e,
                                                   BridgeContext ctx) {
        String s = e.getAttributeNS(null, SVG_BASE_FREQUENCY_ATTRIBUTE);
        if (s.length() == 0) {
            return new float[] {0.001f, 0.001f};
        }
        float[] v = new float[2];
        StringTokenizer tokens = new StringTokenizer(s, " ,");
        try {
            v[0] = SVGUtilities.convertSVGNumber(tokens.nextToken());
            if (tokens.hasMoreTokens()) {
                v[1] = SVGUtilities.convertSVGNumber(tokens.nextToken());
            } else {
                v[1] = v[0];
            }
            if (tokens.hasMoreTokens()) {
                throw new BridgeException
                    (ctx, e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {SVG_BASE_FREQUENCY_ATTRIBUTE, s});
            }
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, e, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_BASE_FREQUENCY_ATTRIBUTE, s});
        }
        if (v[0] < 0 || v[1] < 0) {
            throw new BridgeException
                (ctx, e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_BASE_FREQUENCY_ATTRIBUTE, s});
        }
        return v;
    }

    /**
     * Converts the 'stitchTiles' attribute of the specified
     * feTurbulence element.
     *
     * @param e the feTurbulence element
     * @param ctx the BridgeContext to use for error information
     * @return true if stitchTiles attribute is 'stitch', false otherwise
     */
    protected static boolean convertStitchTiles(Element e, BridgeContext ctx) {
        String s = e.getAttributeNS(null, SVG_STITCH_TILES_ATTRIBUTE);
        if (s.length() == 0) {
            return false;
        }
        if (SVG_STITCH_VALUE.equals(s)) {
            return true;
        }
        if (SVG_NO_STITCH_VALUE.equals(s)) {
            return false;
        }
        throw new BridgeException(ctx, e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                  new Object[] {SVG_STITCH_TILES_ATTRIBUTE, s});
    }

    /**
     * Converts the 'type' attribute of the specified feTurbulence element.
     *
     * @param e the feTurbulence element
     * @param ctx the BridgeContext to use for error information
     * @return true if type attribute value is 'fractalNoise', false otherwise
     */
    protected static boolean convertType(Element e, BridgeContext ctx) {
        String s = e.getAttributeNS(null, SVG_TYPE_ATTRIBUTE);
        if (s.length() == 0) {
            return false;
        }
        if (SVG_FRACTAL_NOISE_VALUE.equals(s)) {
            return true;
        }
        if (SVG_TURBULENCE_VALUE.equals(s)) {
            return false;
        }
        throw new BridgeException(ctx, e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                  new Object[] {SVG_TYPE_ATTRIBUTE, s});
    }
}
