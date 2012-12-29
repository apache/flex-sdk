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

import org.apache.flex.forks.batik.ext.awt.image.ComponentTransferFunction;
import org.apache.flex.forks.batik.ext.awt.image.ConcreteComponentTransferFunction;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ComponentTransferRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * Bridge class for the &lt;feComponentTransfer> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFeComponentTransferElementBridge.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class SVGFeComponentTransferElementBridge
    extends AbstractSVGFilterPrimitiveElementBridge {

    /**
     * Constructs a new bridge for the &lt;feComponentTransfer> element.
     */
    public SVGFeComponentTransferElementBridge() {}

    /**
     * Returns 'feComponentTransfer'.
     */
    public String getLocalName() {
        return SVG_FE_COMPONENT_TRANSFER_TAG;
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

        // Now, extract the various transfer functions. They are
        // defined in the filterElement's children.
        // Functions are ordered as follow: r, g, b, a.
        ComponentTransferFunction funcR = null;
        ComponentTransferFunction funcG = null;
        ComponentTransferFunction funcB = null;
        ComponentTransferFunction funcA = null;

        for (Node n = filterElement.getFirstChild();
             n != null;
             n = n.getNextSibling()) {

            if (n.getNodeType() != Node.ELEMENT_NODE) {
                continue;
            }

            Element e = (Element)n;
            Bridge bridge = ctx.getBridge(e);
            if (bridge == null || !(bridge instanceof SVGFeFuncElementBridge)) {
                continue;
            }
            SVGFeFuncElementBridge funcBridge
                = (SVGFeFuncElementBridge)bridge;
            ComponentTransferFunction func
                = funcBridge.createComponentTransferFunction(filterElement, e);
            if (funcBridge instanceof SVGFeFuncRElementBridge) {
                funcR = func;
            } else if (funcBridge instanceof SVGFeFuncGElementBridge) {
                funcG = func;
            } else if (funcBridge instanceof SVGFeFuncBElementBridge) {
                funcB = func;
            } else if (funcBridge instanceof SVGFeFuncAElementBridge) {
                funcA = func;
            }
        }

        Filter filter = new ComponentTransferRable8Bit
            (in, funcA, funcR, funcG, funcB);

        // handle the 'color-interpolation-filters' property
        handleColorInterpolationFilters(filter, filterElement);

        filter = new PadRable8Bit(filter, primitiveRegion, PadMode.ZERO_PAD);

        // update the filter Map
        updateFilterMap(filterElement, filter, filterMap);

        return filter;
    }

    /**
     * Bridge class for the &lt;feFuncA> element.
     */
    public static class SVGFeFuncAElementBridge extends SVGFeFuncElementBridge {

        /**
         * Constructs a new bridge for the <tt>feFuncA</tt> element.
         */
        public SVGFeFuncAElementBridge() {}

        /**
         * Returns 'feFuncA'.
         */
        public String getLocalName() {
            return SVG_FE_FUNC_A_TAG;
        }
    }

    /**
     * Bridge class for the &lt;feFuncR> element.
     */
    public static class SVGFeFuncRElementBridge extends SVGFeFuncElementBridge {

        /**
         * Constructs a new bridge for the <tt>feFuncR</tt> element.
         */
        public SVGFeFuncRElementBridge() {}

        /**
         * Returns 'feFuncR'.
         */
        public String getLocalName() {
            return SVG_FE_FUNC_R_TAG;
        }
    }

    /**
     * Bridge class for the &lt;feFuncG> element.
     */
    public static class SVGFeFuncGElementBridge extends SVGFeFuncElementBridge {

        /**
         * Constructs a new bridge for the <tt>feFuncG</tt> element.
         */
        public SVGFeFuncGElementBridge() {}

        /**
         * Returns 'feFuncG'.
         */
        public String getLocalName() {
            return SVG_FE_FUNC_G_TAG;
        }
    }

    /**
     * Bridge class for the &lt;feFuncB> element.
     */
    public static class SVGFeFuncBElementBridge extends SVGFeFuncElementBridge {

        /**
         * Constructs a new bridge for the <tt>feFuncB</tt> element.
         */
        public SVGFeFuncBElementBridge() {}

        /**
         * Returns 'feFuncB'.
         */
        public String getLocalName() {
            return SVG_FE_FUNC_B_TAG;
        }
    }

    /**
     * The base bridge class for component transfer function.
     */
    protected abstract static class SVGFeFuncElementBridge
            extends AnimatableGenericSVGBridge {

        /**
         * Constructs a new bridge for component transfer function.
         */
        protected SVGFeFuncElementBridge() {}

        /**
         * Creates a <tt>ComponentTransferFunction</tt> according to
         * the specified parameters.
         *
         * @param filterElement the feComponentTransfer filter primitive element
         * @param funcElement the feFuncX element
         */
        public ComponentTransferFunction createComponentTransferFunction
            (Element filterElement, Element funcElement) {

            int type = convertType(funcElement, ctx);
            switch (type) {
            case ComponentTransferFunction.DISCRETE: {
                float [] v = convertTableValues(funcElement, ctx);
                if (v == null) {
                    return ConcreteComponentTransferFunction.getIdentityTransfer();
                } else {
                    return ConcreteComponentTransferFunction.getDiscreteTransfer(v);
                }
            }
            case ComponentTransferFunction.IDENTITY: {
                return ConcreteComponentTransferFunction.getIdentityTransfer();
            }
            case ComponentTransferFunction.GAMMA: {
                // 'amplitude' attribute - default is 1
                float amplitude
                    = convertNumber(funcElement, SVG_AMPLITUDE_ATTRIBUTE, 1, ctx);
                // 'exponent' attribute - default is 1
                float exponent
                    = convertNumber(funcElement, SVG_EXPONENT_ATTRIBUTE, 1, ctx);
                // 'offset' attribute - default is 0
                float offset
                    = convertNumber(funcElement, SVG_OFFSET_ATTRIBUTE, 0, ctx);

                return ConcreteComponentTransferFunction.getGammaTransfer
                    (amplitude, exponent, offset);
            }
            case ComponentTransferFunction.LINEAR: {
                // 'slope' attribute - default is 1
                float slope
                    = convertNumber(funcElement, SVG_SLOPE_ATTRIBUTE, 1, ctx);
                // 'intercept' attribute - default is 0
                float intercept
                    = convertNumber(funcElement, SVG_INTERCEPT_ATTRIBUTE, 0, ctx);

                return ConcreteComponentTransferFunction.getLinearTransfer
                    (slope, intercept);
            }
            case ComponentTransferFunction.TABLE: {
                float [] v = convertTableValues(funcElement, ctx);
                if (v == null) {
                    return ConcreteComponentTransferFunction.getIdentityTransfer();
                } else {
                    return ConcreteComponentTransferFunction.getTableTransfer(v);
                }
            }
            default:
                throw new Error("invalid convertType:" + type ); // can't be reached
            }

        }

        /**
         * Converts the 'tableValues' attribute of the specified component
         * transfer function element.
         *
         * @param e the element that represents a component transfer function
         * @param ctx the BridgeContext to use for error information
         */
        protected static float [] convertTableValues(Element e, BridgeContext ctx) {
            String s = e.getAttributeNS(null, SVG_TABLE_VALUES_ATTRIBUTE);
            if (s.length() == 0) {
                return null;
            }
            StringTokenizer tokens = new StringTokenizer(s, " ,");
            float [] v = new float[tokens.countTokens()];
            try {
                for (int i = 0; tokens.hasMoreTokens(); ++i) {
                    v[i] = SVGUtilities.convertSVGNumber(tokens.nextToken());
                }
            } catch (NumberFormatException nfEx ) {
                throw new BridgeException
                    (ctx, e, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {SVG_TABLE_VALUES_ATTRIBUTE, s});
        }
            return v;
        }

        /**
         * Converts the type of the specified component transfert
         * function element.
         *
         * @param e the element that represents a component transfer function
         * @param ctx the BridgeContext to use for error information
         */
        protected static int convertType(Element e, BridgeContext ctx) {
            String s = e.getAttributeNS(null, SVG_TYPE_ATTRIBUTE);
            if (s.length() == 0) {
                throw new BridgeException(ctx, e, ERR_ATTRIBUTE_MISSING,
                                          new Object[] {SVG_TYPE_ATTRIBUTE});
            }
            if (SVG_DISCRETE_VALUE.equals(s)) {
                return ComponentTransferFunction.DISCRETE;
            }
            if (SVG_IDENTITY_VALUE.equals(s)) {
                return ComponentTransferFunction.IDENTITY;
            }
            if (SVG_GAMMA_VALUE.equals(s)) {
                return ComponentTransferFunction.GAMMA;
            }
            if (SVG_LINEAR_VALUE.equals(s)) {
                return ComponentTransferFunction.LINEAR;
            }
            if (SVG_TABLE_VALUE.equals(s)) {
                return ComponentTransferFunction.TABLE;
            }
            throw new BridgeException(ctx, e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                      new Object[] {SVG_TYPE_ATTRIBUTE, s});
        }
    }
}
