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

import java.awt.Color;
import java.util.StringTokenizer;

import org.apache.flex.forks.batik.ext.awt.image.DistantLight;
import org.apache.flex.forks.batik.ext.awt.image.Light;
import org.apache.flex.forks.batik.ext.awt.image.PointLight;
import org.apache.flex.forks.batik.ext.awt.image.SpotLight;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * Bridge class for the &lt;feDiffuseLighting> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: AbstractSVGLightingElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public abstract class AbstractSVGLightingElementBridge
    extends AbstractSVGFilterPrimitiveElementBridge {

    /**
     * Constructs a new bridge for the lighting filter primitives.
     */
    protected AbstractSVGLightingElementBridge() {}

    /**
     * Returns the light from the specified lighting filter primitive
     * element or null if any
     *
     * @param filterElement the lighting filter primitive element
     * @param ctx the bridge context
     */
    protected static
        Light extractLight(Element filterElement, BridgeContext ctx) {

        Color color = CSSUtilities.convertLightingColor(filterElement, ctx);

        for (Node n = filterElement.getFirstChild();
             n != null;
             n = n.getNextSibling()) {

            if (n.getNodeType() != Node.ELEMENT_NODE) {
                continue;
            }

            Element e = (Element)n;
            Bridge bridge = ctx.getBridge(e);
            if (bridge == null ||
                !(bridge instanceof AbstractSVGLightElementBridge)) {
                continue;
            }
            return ((AbstractSVGLightElementBridge)bridge).createLight
                (ctx, filterElement, e, color);
        }
        return null;
    }

    /**
     * Convert the 'kernelUnitLength' attribute of the specified
     * feDiffuseLighting or feSpecularLighting filter primitive element.
     *
     * @param filterElement the filter primitive element
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
     * The base bridge class for light element.
     */
    protected abstract static class AbstractSVGLightElementBridge
        extends AnimatableGenericSVGBridge {

        /**
         * Creates a <tt>Light</tt> according to the specified parameters.
         *
         * @param ctx the bridge context to use
         * @param filterElement the lighting filter primitive element
         * @param lightElement the element describing a light
         * @param color the color of the light
         */
        public abstract Light createLight(BridgeContext ctx,
                                          Element filterElement,
                                          Element lightElement,
                                          Color color);
    }

    /**
     * Bridge class for the &lt;feSpotLight> element.
     */
    public static class SVGFeSpotLightElementBridge
        extends AbstractSVGLightElementBridge {

        /**
         * Constructs a new bridge for a light element.
         */
        public SVGFeSpotLightElementBridge() {}

        /**
         * Returns 'feSpotLight'.
         */
        public String getLocalName() {
            return SVG_FE_SPOT_LIGHT_TAG;
        }

        /**
         * Creates a <tt>Light</tt> according to the specified parameters.
         *
         * @param ctx the bridge context to use
         * @param filterElement the lighting filter primitive element
         * @param lightElement the element describing a light
         * @param color the color of the light
         */
        public Light createLight(BridgeContext ctx,
                                 Element filterElement,
                                 Element lightElement,
                                 Color color) {

            // 'x' attribute - default is 0
            double x = convertNumber(lightElement, SVG_X_ATTRIBUTE, 0, ctx);

            // 'y' attribute - default is 0
            double y = convertNumber(lightElement, SVG_Y_ATTRIBUTE, 0, ctx);

            // 'z' attribute - default is 0
            double z = convertNumber(lightElement, SVG_Z_ATTRIBUTE, 0, ctx);

            // 'pointsAtX' attribute - default is 0
            double px = convertNumber(lightElement, SVG_POINTS_AT_X_ATTRIBUTE,
                                      0, ctx);

            // 'pointsAtY' attribute - default is 0
            double py = convertNumber(lightElement, SVG_POINTS_AT_Y_ATTRIBUTE,
                                      0, ctx);

            // 'pointsAtZ' attribute - default is 0
            double pz = convertNumber(lightElement, SVG_POINTS_AT_Z_ATTRIBUTE,
                                      0, ctx);

            // 'specularExponent' attribute - default is 1
            double specularExponent = convertNumber
                (lightElement, SVG_SPECULAR_EXPONENT_ATTRIBUTE, 1, ctx);

            // 'limitingConeAngle' attribute - default is 90
            double limitingConeAngle = convertNumber
                (lightElement, SVG_LIMITING_CONE_ANGLE_ATTRIBUTE, 90, ctx);

            return new SpotLight(x, y, z,
                                 px, py, pz,
                                 specularExponent,
                                 limitingConeAngle,
                                 color);
        }
    }

    /**
     * Bridge class for the &lt;feDistantLight> element.
     */
    public static class SVGFeDistantLightElementBridge
        extends AbstractSVGLightElementBridge {

        /**
         * Constructs a new bridge for a light element.
         */
        public SVGFeDistantLightElementBridge() {}

        /**
         * Returns 'feDistantLight'.
         */
        public String getLocalName() {
            return SVG_FE_DISTANT_LIGHT_TAG;
        }

        /**
         * Creates a <tt>Light</tt> according to the specified parameters.
         *
         * @param ctx the bridge context to use
         * @param filterElement the lighting filter primitive element
         * @param lightElement the element describing a light
         * @param color the color of the light
         */
        public Light createLight(BridgeContext ctx,
                                 Element filterElement,
                                 Element lightElement,
                                 Color color) {

            // 'azimuth' attribute - default is 0
            double azimuth
                = convertNumber(lightElement, SVG_AZIMUTH_ATTRIBUTE, 0, ctx);

            // 'elevation' attribute - default is 0
            double elevation
                = convertNumber(lightElement, SVG_ELEVATION_ATTRIBUTE, 0, ctx);

            return new DistantLight(azimuth, elevation, color);
        }
    }

    /**
     * Bridge class for the &lt;fePointLight> element.
     */
    public static class SVGFePointLightElementBridge
        extends AbstractSVGLightElementBridge {

        /**
         * Constructs a new bridge for a light element.
         */
        public SVGFePointLightElementBridge() {}

        /**
         * Returns 'fePointLight'.
         */
        public String getLocalName() {
            return SVG_FE_POINT_LIGHT_TAG;
        }

        /**
         * Creates a <tt>Light</tt> according to the specified parameters.
         *
         * @param ctx the bridge context to use
         * @param filterElement the lighting filter primitive element
         * @param lightElement the element describing a light
         * @param color the color of the light
         */
        public Light createLight(BridgeContext ctx,
                                 Element filterElement,
                                 Element lightElement,
                                 Color color) {

            // 'x' attribute - default is 0
            double x = convertNumber(lightElement, SVG_X_ATTRIBUTE, 0, ctx);

            // 'y' attribute - default is 0
            double y = convertNumber(lightElement, SVG_Y_ATTRIBUTE, 0, ctx);

            // 'z' attribute - default is 0
            double z = convertNumber(lightElement, SVG_Z_ATTRIBUTE, 0, ctx);

            return new PointLight(x, y, z, color);
        }
    }
}
