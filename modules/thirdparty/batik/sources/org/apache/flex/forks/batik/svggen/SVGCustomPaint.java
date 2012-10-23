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

import java.awt.Paint;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;
import org.w3c.dom.Element;

/**
 * Utility class that converts an custom Paint object into
 * a set of SVG properties and definitions.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGCustomPaint.java 475477 2006-11-15 22:44:28Z cam $
 * @see                org.apache.flex.forks.batik.svggen.SVGPaint
 */
public class SVGCustomPaint extends AbstractSVGConverter {
    /**
     * @param generatorContext the context.
     */
    public SVGCustomPaint(SVGGeneratorContext generatorContext) {
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
        return toSVG(gc.getPaint());
    }

    /**
     * @param paint the Paint object to convert to SVG
     * @return a description of the SVG paint and opacity corresponding
     *         to the Paint. The definiton of the paint is put in the
     *         linearGradientDefsMap
     */
    public SVGPaintDescriptor toSVG(Paint paint) {
        SVGPaintDescriptor paintDesc = (SVGPaintDescriptor)descMap.get(paint);

        if (paintDesc == null) {
            // First time this paint is used. Request handler
            // to do the convertion
            paintDesc =
                generatorContext.extensionHandler.
                handlePaint(paint,
                            generatorContext);

            if (paintDesc != null) {
                Element def = paintDesc.getDef();
                if(def != null) defSet.add(def);
                descMap.put(paint, paintDesc);
            }
        }

        return paintDesc;
    }
}
