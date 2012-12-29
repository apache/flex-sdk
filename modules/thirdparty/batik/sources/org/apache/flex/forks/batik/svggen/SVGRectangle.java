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

import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RectangularShape;
import java.awt.geom.RoundRectangle2D;

import org.w3c.dom.Element;

/**
 * Utility class that converts a Rectangle2D or RoundRectangle2D
 * object into an SVG element.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGRectangle.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGRectangle extends SVGGraphicObjectConverter {
    /**
     * Line converter used for degenerate cases
     */
    private SVGLine svgLine;

    /**
     * @param generatorContext used to build Elements
     */
    public SVGRectangle(SVGGeneratorContext generatorContext) {
        super(generatorContext);
        svgLine = new SVGLine(generatorContext);
    }

    /**
     * @param rect rectangle object to convert to SVG
     */
    public Element toSVG(Rectangle2D rect) {
        return toSVG((RectangularShape)rect);
    }


    /**
     * In the Java 2D API, arc width/height are used
     * as absolute values.
     *
     * @param rect rectangle object to convert to SVG
     */
    public Element toSVG(RoundRectangle2D rect) {
        Element svgRect = toSVG((RectangularShape)rect);
        if(svgRect != null && svgRect.getTagName() == SVG_RECT_TAG){
            svgRect.setAttributeNS(null, SVG_RX_ATTRIBUTE,
                                   doubleString(Math.abs(rect.getArcWidth()/2)));
            svgRect.setAttributeNS(null, SVG_RY_ATTRIBUTE,
                                   doubleString(Math.abs(rect.getArcHeight()/2)));
        }

        return svgRect;
    }


    /**
     * @param rect rectangle object to convert to SVG
     */
    private Element toSVG(RectangularShape rect) {
        if(rect.getWidth() > 0 && rect.getHeight() > 0){
            Element svgRect =
                generatorContext.domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                            SVG_RECT_TAG);
            svgRect.setAttributeNS(null, SVG_X_ATTRIBUTE, doubleString(rect.getX()));
            svgRect.setAttributeNS(null, SVG_Y_ATTRIBUTE, doubleString(rect.getY()));
            svgRect.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE,
                                   doubleString(rect.getWidth()));
            svgRect.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE,
                                   doubleString(rect.getHeight()));
            
            return svgRect;
        }
        else{
            // Handle degenerate cases
            if(rect.getWidth() == 0 && rect.getHeight() > 0){
                // Degenerate to a line
                Line2D line = new Line2D.Double(rect.getX(), rect.getY(), rect.getX(), 
                                                rect.getY() + rect.getHeight());
                return svgLine.toSVG(line);
            }
            else if(rect.getWidth() > 0 && rect.getHeight() == 0){
                // Degenerate to a line
                Line2D line = new Line2D.Double(rect.getX(), rect.getY(),
                                                rect.getX() + rect.getWidth(),
                                                rect.getY());
                return svgLine.toSVG(line);
            }
            return null;
        }
    }
}
