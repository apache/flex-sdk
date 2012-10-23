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

import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;

import org.w3c.dom.Element;

/**
 * Utility class that converts an Ellipse2D object into
 * a corresponding SVG element, i.e., a circle or an ellipse.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGEllipse.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGEllipse extends SVGGraphicObjectConverter {
    /**
     * Line converter used for degenerate cases
     */
    private SVGLine svgLine;

    /**
     * @param generatorContext used to build Elements
     */
    public SVGEllipse(SVGGeneratorContext generatorContext) {
        super(generatorContext);
    }

    /**
     * @param ellipse the Ellipse2D object to be converted
     */
    public Element toSVG(Ellipse2D ellipse) {
        if(ellipse.getWidth() < 0 || ellipse.getHeight() < 0){
            return null;
        }

        if(ellipse.getWidth() == ellipse.getHeight())
            return toSVGCircle(ellipse);
        else
            return toSVGEllipse(ellipse);
    }

    /**
     * @param ellipse the Ellipse2D object to be converted to a circle
     */
    private Element toSVGCircle(Ellipse2D ellipse){
        Element svgCircle =
            generatorContext.domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                        SVG_CIRCLE_TAG);
        svgCircle.setAttributeNS(null, SVG_CX_ATTRIBUTE,
                                 doubleString(ellipse.getX() +
                                              ellipse.getWidth()/2));
        svgCircle.setAttributeNS(null, SVG_CY_ATTRIBUTE,
                                 doubleString(ellipse.getY() +
                                              ellipse.getHeight()/2));
        svgCircle.setAttributeNS(null, SVG_R_ATTRIBUTE,
                                 doubleString(ellipse.getWidth()/2));
        return svgCircle;
    }

    /**
     * @param ellipse the Ellipse2D object to be converted to an ellipse
     */
    private Element toSVGEllipse(Ellipse2D ellipse){
        if(ellipse.getWidth() > 0 && ellipse.getHeight() > 0){
            Element svgCircle =
                generatorContext.domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                            SVG_ELLIPSE_TAG);
            svgCircle.setAttributeNS(null, SVG_CX_ATTRIBUTE,
                                     doubleString(ellipse.getX() +
                                                  ellipse.getWidth()/2));
            svgCircle.setAttributeNS(null, SVG_CY_ATTRIBUTE,
                                     doubleString(ellipse.getY() +
                                                  ellipse.getHeight()/2));
            svgCircle.setAttributeNS(null, SVG_RX_ATTRIBUTE,
                                     doubleString(ellipse.getWidth()/2));
            svgCircle.setAttributeNS(null, SVG_RY_ATTRIBUTE,
                                     doubleString(ellipse.getHeight()/2));
            return svgCircle;
        }
        else if(ellipse.getWidth() == 0 && ellipse.getHeight() > 0){
            // Degenerate to a line
            Line2D line = new Line2D.Double(ellipse.getX(), ellipse.getY(), ellipse.getX(), 
                                            ellipse.getY() + ellipse.getHeight());
            if (svgLine == null)
                svgLine = new SVGLine(generatorContext);
            return svgLine.toSVG(line);
        }
        else if(ellipse.getWidth() > 0 && ellipse.getHeight() == 0){
            // Degenerate to a line
            Line2D line = new Line2D.Double(ellipse.getX(), ellipse.getY(),
                                            ellipse.getX() + ellipse.getWidth(),
                                            ellipse.getY());
            if (svgLine == null)
                svgLine = new SVGLine(generatorContext);
            return svgLine.toSVG(line);
        }
        return null;
    }
}
