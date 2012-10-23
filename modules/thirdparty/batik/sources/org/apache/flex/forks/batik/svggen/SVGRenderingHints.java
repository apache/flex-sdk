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

import java.awt.RenderingHints;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;

/**
 * Utility class that converts a RenderingHints object into
 * a set of SVG properties. Here is how individual hints
 * are converted.
 * + RENDERING -> sets all other hints to
 *                initial value.
 * + FRACTIONAL_METRICS -> sets initial values for
 *                         text-rendering and shape-rendering.
 * + ALPHA_INTERPOLATION -> Not mapped
 * + ANTIALIASING -> shape-rendering and text-rendering
 * + COLOR_RENDERING -> color-rendering
 * + DITHERING -> not mapped
 * + INTERPOLATION -> image-rendering
 * + TEXT_ANTIALIASING -> text-rendering
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGRenderingHints.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGRenderingHints extends AbstractSVGConverter{
    /**
     * @param generatorContext used by converter to handle precision
     *        or to create elements.
     */
    public SVGRenderingHints(SVGGeneratorContext generatorContext) {
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
    public SVGDescriptor toSVG(GraphicContext gc){
        return toSVG(gc.getRenderingHints());
    }

    /**
     * @param hints RenderingHints object which should be converted
     *              to a set of SVG attributes.
     * @return map Map of attribute values that describe the hints
     */
    public static SVGHintsDescriptor toSVG(RenderingHints hints){
        // no hints should mean default
        String colorInterpolation = SVG_AUTO_VALUE;
        String colorRendering = SVG_AUTO_VALUE;
        String textRendering = SVG_AUTO_VALUE;
        String shapeRendering = SVG_AUTO_VALUE;
        String imageRendering = SVG_AUTO_VALUE;

        //
        // RENDERING
        //
        if(hints != null){
            Object rendering = hints.get(RenderingHints.KEY_RENDERING);
            if(rendering == RenderingHints.VALUE_RENDER_DEFAULT){
                colorInterpolation = SVG_AUTO_VALUE;
                colorRendering = SVG_AUTO_VALUE;
                textRendering = SVG_AUTO_VALUE;
                shapeRendering = SVG_AUTO_VALUE;
                imageRendering = SVG_AUTO_VALUE;
            }
            else if(rendering == RenderingHints.VALUE_RENDER_SPEED){
                colorInterpolation = SVG_SRGB_VALUE;
                colorRendering = SVG_OPTIMIZE_SPEED_VALUE;
                textRendering = SVG_OPTIMIZE_SPEED_VALUE;
                shapeRendering = SVG_GEOMETRIC_PRECISION_VALUE;
                imageRendering = SVG_OPTIMIZE_SPEED_VALUE;
            }
            else if(rendering == RenderingHints.VALUE_RENDER_QUALITY){
                colorInterpolation = SVG_LINEAR_RGB_VALUE;
                colorRendering = SVG_OPTIMIZE_QUALITY_VALUE;
                textRendering = SVG_OPTIMIZE_QUALITY_VALUE;
                shapeRendering = SVG_GEOMETRIC_PRECISION_VALUE;
                imageRendering = SVG_OPTIMIZE_QUALITY_VALUE;
            }

            //
            // Fractional Metrics
            //
            Object fractionalMetrics = hints.get(RenderingHints.KEY_FRACTIONALMETRICS);
            if(fractionalMetrics == RenderingHints.VALUE_FRACTIONALMETRICS_ON){
                textRendering = SVG_OPTIMIZE_QUALITY_VALUE;
                shapeRendering = SVG_GEOMETRIC_PRECISION_VALUE;
            }
            else if(fractionalMetrics == RenderingHints.VALUE_FRACTIONALMETRICS_OFF){
                textRendering = SVG_OPTIMIZE_SPEED_VALUE;
                shapeRendering = SVG_OPTIMIZE_SPEED_VALUE;
            }
            else if(fractionalMetrics == RenderingHints.VALUE_FRACTIONALMETRICS_DEFAULT){
                textRendering = SVG_AUTO_VALUE;
                shapeRendering = SVG_AUTO_VALUE;
            }

            //
            // Antialiasing
            //
            Object antialiasing = hints.get(RenderingHints.KEY_ANTIALIASING);
            if(antialiasing == RenderingHints.VALUE_ANTIALIAS_ON){
                textRendering = SVG_OPTIMIZE_LEGIBILITY_VALUE;
                shapeRendering = SVG_AUTO_VALUE;
            }
            else if(antialiasing == RenderingHints.VALUE_ANTIALIAS_OFF){
                textRendering = SVG_GEOMETRIC_PRECISION_VALUE;
                shapeRendering = SVG_CRISP_EDGES_VALUE;
            }
            else if(antialiasing == RenderingHints.VALUE_ANTIALIAS_DEFAULT){
                textRendering = SVG_AUTO_VALUE;
                shapeRendering = SVG_AUTO_VALUE;
            }

            //
            // Text Antialiasing
            //
            Object textAntialiasing = hints.get(RenderingHints.KEY_TEXT_ANTIALIASING);
            if(textAntialiasing == RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
                textRendering = SVG_GEOMETRIC_PRECISION_VALUE;
            else if(textAntialiasing == RenderingHints.VALUE_TEXT_ANTIALIAS_OFF)
                textRendering = SVG_OPTIMIZE_SPEED_VALUE;
            else if(textAntialiasing == RenderingHints.VALUE_TEXT_ANTIALIAS_DEFAULT)
                textRendering = SVG_AUTO_VALUE;

            //
            // Color Rendering
            //
            Object colorRenderingHint = hints.get(RenderingHints.KEY_COLOR_RENDERING);
            if(colorRenderingHint == RenderingHints.VALUE_COLOR_RENDER_DEFAULT)
                colorRendering = SVG_AUTO_VALUE;
            else if(colorRenderingHint == RenderingHints.VALUE_COLOR_RENDER_QUALITY)
                colorRendering = SVG_OPTIMIZE_QUALITY_VALUE;
            else if(colorRenderingHint == RenderingHints.VALUE_COLOR_RENDER_SPEED)
                colorRendering = SVG_OPTIMIZE_SPEED_VALUE;

            //
            // Interpolation
            //
            Object interpolation = hints.get(RenderingHints.KEY_INTERPOLATION);
            if(interpolation == RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR)
                imageRendering = SVG_OPTIMIZE_SPEED_VALUE;
            else if(interpolation == RenderingHints.VALUE_INTERPOLATION_BICUBIC
                    ||
                    interpolation == RenderingHints.VALUE_INTERPOLATION_BILINEAR)
                imageRendering = SVG_OPTIMIZE_QUALITY_VALUE;
        } // if(hints != null)

        return new SVGHintsDescriptor(colorInterpolation,
                                      colorRendering,
                                      textRendering,
                                      shapeRendering,
                                      imageRendering);
    }
}
