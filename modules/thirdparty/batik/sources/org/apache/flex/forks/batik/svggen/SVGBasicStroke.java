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

import java.awt.BasicStroke;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;

/**
 * Utility class that converts a Java BasicStroke object into
 * a set of SVG style attributes
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGBasicStroke.java 476924 2006-11-19 21:13:26Z dvholten $
 */
public class SVGBasicStroke extends AbstractSVGConverter{
    /**
     * @param generatorContext used by converter to handle precision
     *        or to create elements.
     */
    public SVGBasicStroke(SVGGeneratorContext generatorContext) {
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
        if(gc.getStroke() instanceof BasicStroke)
            return toSVG((BasicStroke)gc.getStroke());
        else
            return null;
    }

    /**
     * @param stroke BasicStroke to convert to a set of
     *        SVG attributes
     * @return map of attributes describing the stroke
     */
    public final SVGStrokeDescriptor toSVG(BasicStroke stroke)
    {
        // Stroke width
        String strokeWidth = doubleString(stroke.getLineWidth());

        // Cap style
        String capStyle = endCapToSVG(stroke.getEndCap());

        // Join style
        String joinStyle = joinToSVG(stroke.getLineJoin());

        // Miter limit
        String miterLimit = doubleString(stroke.getMiterLimit());

        // Dash array
        float[] array = stroke.getDashArray();
        String dashArray = null;
        if(array != null)
            dashArray = dashArrayToSVG(array);
        else
            dashArray = SVG_NONE_VALUE;

        // Dash offset
        String dashOffset = doubleString(stroke.getDashPhase());

        return new SVGStrokeDescriptor(strokeWidth, capStyle,
                                       joinStyle, miterLimit,
                                       dashArray, dashOffset);
    }

    /**
     * @param dashArray float array to convert to a string
     */
    private final String dashArrayToSVG(float[] dashArray){
        StringBuffer dashArrayBuf = new StringBuffer( dashArray.length * 8 );
        if(dashArray.length > 0)
            dashArrayBuf.append(doubleString(dashArray[0]));

        for(int i=1; i<dashArray.length; i++){
            dashArrayBuf.append(COMMA);
            dashArrayBuf.append(doubleString(dashArray[i]));
        }

        return dashArrayBuf.toString();
    }

    /**
     * @param lineJoin join style
     */
    private static String joinToSVG(int lineJoin){
        switch(lineJoin){
        case BasicStroke.JOIN_BEVEL:
            return SVG_BEVEL_VALUE;
        case BasicStroke.JOIN_ROUND:
            return SVG_ROUND_VALUE;
        case BasicStroke.JOIN_MITER:
        default:
            return SVG_MITER_VALUE;
        }
    }

    /**
     * @param endCap cap style
     */
    private static String endCapToSVG(int endCap){
        switch(endCap){
        case BasicStroke.CAP_BUTT:
            return SVG_BUTT_VALUE;
        case BasicStroke.CAP_ROUND:
            return SVG_ROUND_VALUE;
        default:
        case BasicStroke.CAP_SQUARE:
            return SVG_SQUARE_VALUE;
        }
    }
}
