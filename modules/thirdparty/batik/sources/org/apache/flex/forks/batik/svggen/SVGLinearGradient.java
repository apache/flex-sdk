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
package org.apache.flex.forks.batik.svggen;

import java.awt.GradientPaint;
import java.awt.Paint;
import java.awt.geom.Point2D;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Utility class that converts a Java GradientPaint into an
 * SVG linear gradient element
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGLinearGradient.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGLinearGradient extends AbstractSVGConverter {
    /**
     * @param generatorContext used to build Elements
     */
    public SVGLinearGradient(SVGGeneratorContext generatorContext) {
        super(generatorContext);
    }

    /**
     * Converts part or all of the input GraphicContext into
     * a set of attribute/value pairs and related definitions
     *
     * @param gc GraphicContext to be converted
     * @return descriptor of the attributes required to represent
     *         some or all of the GraphicContext state, along
     *         with the related definitions
     * @see org.apache.flex.forks.batik.svggen.SVGDescriptor
     */
    public SVGDescriptor toSVG(GraphicContext gc) {
        Paint paint = gc.getPaint();
        return toSVG((GradientPaint)paint);
    }

    /**
     * @param gradient the GradientPaint to be converted
     * @return a description of the SVG paint and opacity corresponding
     *         to the gradient Paint. The definiton of the
     *         linearGradient is put in the linearGradientDefsMap
     */
    public SVGPaintDescriptor toSVG(GradientPaint gradient) {
        // Reuse definition if gradient has already been converted
        SVGPaintDescriptor gradientDesc =
            (SVGPaintDescriptor)descMap.get(gradient);

        Document domFactory = generatorContext.domFactory;

        if (gradientDesc == null) {
            Element gradientDef =
                domFactory.createElementNS(SVG_NAMESPACE_URI,
                                           SVG_LINEAR_GRADIENT_TAG);
            gradientDef.setAttributeNS(null, SVG_GRADIENT_UNITS_ATTRIBUTE,
                                       SVG_USER_SPACE_ON_USE_VALUE);

            //
            // Process gradient vector
            //
            Point2D p1 = gradient.getPoint1();
            Point2D p2 = gradient.getPoint2();
            gradientDef.setAttributeNS(null, SVG_X1_ATTRIBUTE,
                                       doubleString(p1.getX()));
            gradientDef.setAttributeNS(null, SVG_Y1_ATTRIBUTE,
                                       doubleString(p1.getY()));
            gradientDef.setAttributeNS(null, SVG_X2_ATTRIBUTE,
                                       doubleString(p2.getX()));
            gradientDef.setAttributeNS(null, SVG_Y2_ATTRIBUTE,
                                       doubleString(p2.getY()));

            //
            // Spread method
            //
            String spreadMethod = SVG_PAD_VALUE;
            if(gradient.isCyclic())
                spreadMethod = SVG_REFLECT_VALUE;
            gradientDef.setAttributeNS
                (null, SVG_SPREAD_METHOD_ATTRIBUTE, spreadMethod);

            //
            // First gradient stop
            //
            Element gradientStop =
                domFactory.createElementNS(SVG_NAMESPACE_URI, SVG_STOP_TAG);
            gradientStop.setAttributeNS(null, SVG_OFFSET_ATTRIBUTE,
                                      SVG_ZERO_PERCENT_VALUE);

            SVGPaintDescriptor colorDesc = SVGColor.toSVG(gradient.getColor1(), generatorContext);
            gradientStop.setAttributeNS(null, SVG_STOP_COLOR_ATTRIBUTE,
                                      colorDesc.getPaintValue());
            gradientStop.setAttributeNS(null, SVG_STOP_OPACITY_ATTRIBUTE,
                                      colorDesc.getOpacityValue());

            gradientDef.appendChild(gradientStop);

            //
            // Second gradient stop
            //
            gradientStop =
                domFactory.createElementNS(SVG_NAMESPACE_URI, SVG_STOP_TAG);
            gradientStop.setAttributeNS(null, SVG_OFFSET_ATTRIBUTE,
                                      SVG_HUNDRED_PERCENT_VALUE);

            colorDesc = SVGColor.toSVG(gradient.getColor2(), generatorContext);
            gradientStop.setAttributeNS(null, SVG_STOP_COLOR_ATTRIBUTE,
                                        colorDesc.getPaintValue());
            gradientStop.setAttributeNS(null, SVG_STOP_OPACITY_ATTRIBUTE,
                                        colorDesc.getOpacityValue());

            gradientDef.appendChild(gradientStop);

            //
            // Gradient ID
            //
            gradientDef.
                setAttributeNS(null, SVG_ID_ATTRIBUTE,
                               generatorContext.idGenerator.
                               generateID(ID_PREFIX_LINEAR_GRADIENT));

            //
            // Build Paint descriptor
            //
            StringBuffer paintAttrBuf = new StringBuffer(URL_PREFIX);
            paintAttrBuf.append(SIGN_POUND);
            paintAttrBuf.append(gradientDef.getAttributeNS(null, SVG_ID_ATTRIBUTE));
            paintAttrBuf.append(URL_SUFFIX);

            gradientDesc = new SVGPaintDescriptor(paintAttrBuf.toString(),
                                                  SVG_OPAQUE_VALUE,
                                                  gradientDef);

            //
            // Update maps so that gradient can be reused if needed
            //
            descMap.put(gradient, gradientDesc);
            defSet.add(gradientDef);
        }

        return gradientDesc;
    }
}
