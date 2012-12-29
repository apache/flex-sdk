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

import java.awt.Color;
import java.awt.GradientPaint;
import java.awt.Paint;
import java.awt.TexturePaint;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;

/**
 * Utility class that converts a Paint object into an
 * SVG element.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGPaint.java 475477 2006-11-15 22:44:28Z cam $
 * @see              org.apache.flex.forks.batik.svggen.SVGLinearGradient
 * @see              org.apache.flex.forks.batik.svggen.SVGTexturePaint
 */
public class SVGPaint implements SVGConverter {
    /**
     * All GradientPaint convertions are handed to svgLinearGradient
     */
    private SVGLinearGradient svgLinearGradient;

    /**
     * All TexturePaint convertions are handed to svgTextureGradient
     */
    private SVGTexturePaint svgTexturePaint;

    /**
     * All Color convertions are handed to svgColor
     */
    private SVGColor svgColor;

    /**
     * All custom Paint convetions are handed to svgCustomPaint
     */
    private SVGCustomPaint svgCustomPaint;

    /**
     * Used to generate DOM elements
     */
    private SVGGeneratorContext generatorContext;

    /**
     * @param generatorContext the context.
     */
    public SVGPaint(SVGGeneratorContext generatorContext) {
        this.svgLinearGradient = new SVGLinearGradient(generatorContext);
        this.svgTexturePaint = new SVGTexturePaint(generatorContext);
        this.svgCustomPaint = new SVGCustomPaint(generatorContext);
        this.svgColor = new SVGColor(generatorContext);
        this.generatorContext = generatorContext;
    }

    /**
     * @return Set of Elements defining the Paints this
     *         converter has processed since it was created
     */
    public List getDefinitionSet(){
        List paintDefs = new LinkedList(svgLinearGradient.getDefinitionSet());
        paintDefs.addAll(svgTexturePaint.getDefinitionSet());
        paintDefs.addAll(svgCustomPaint.getDefinitionSet());
        paintDefs.addAll(svgColor.getDefinitionSet());
        return paintDefs;
    }

    public SVGTexturePaint getTexturePaintConverter(){
        return svgTexturePaint;
    }

    public SVGLinearGradient getGradientPaintConverter(){
        return svgLinearGradient;
    }

    public SVGCustomPaint getCustomPaintConverter(){
        return svgCustomPaint;
    }

    public SVGColor getColorConverter(){
        return svgColor;
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
        return toSVG(gc.getPaint());
    }

    /**
     * @param paint Paint to be converted to SVG
     * @return a descriptor of the corresponding SVG paint
     */
    public SVGPaintDescriptor toSVG(Paint paint){
        // we first try the extension handler because we may
        // want to override the way a Paint is managed!
        SVGPaintDescriptor paintDesc = svgCustomPaint.toSVG(paint);

        if (paintDesc == null) {
            if (paint instanceof Color)
                paintDesc = SVGColor.toSVG((Color)paint, generatorContext);
            else if (paint instanceof GradientPaint)
                paintDesc = svgLinearGradient.toSVG((GradientPaint)paint);
            else if (paint instanceof TexturePaint)
                paintDesc = svgTexturePaint.toSVG((TexturePaint)paint);
        }

        return paintDesc;
    }
}
