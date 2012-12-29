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

import java.awt.Polygon;
import java.awt.Shape;
import java.awt.geom.Arc2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RoundRectangle2D;

import org.w3c.dom.Element;

/**
 * Utility class that converts a Shape object into the corresponding
 * SVG element. Note that this class analyzes the input Shape class
 * to generate the most appropriate corresponding SVG element:
 * + Polygon is mapped to polygon
 * + Rectangle2D and RoundRectangle2D are mapped to rect
 * + Ellipse2D is mapped to circle or ellipse
 * + Line2D is mapped to line
 * + Arc2D, CubicCurve2D, Area, GeneralPath and QuadCurve2D are mapped to
 *   path.
 * + Any custom Shape implementation is mapped to path as well.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGShape.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGShape extends SVGGraphicObjectConverter {
    /*
     * Subconverts, for each type of Shape class
     */
    private SVGArc       svgArc;
    private SVGEllipse   svgEllipse;
    private SVGLine      svgLine;
    private SVGPath      svgPath;
    private SVGPolygon   svgPolygon;
    private SVGRectangle svgRectangle;

    /**
     * @param generatorContext used to build Elements
     */
    public SVGShape(SVGGeneratorContext generatorContext) {
        super(generatorContext);
        svgArc       = new SVGArc(generatorContext);
        svgEllipse   = new SVGEllipse(generatorContext);
        svgLine      = new SVGLine(generatorContext);
        svgPath      = new SVGPath(generatorContext);
        svgPolygon   = new SVGPolygon(generatorContext);
        svgRectangle = new SVGRectangle(generatorContext);
    }

    /**
     * @param shape Shape object to be converted
     */
    public Element toSVG(Shape shape){
        if(shape instanceof Polygon)
            return svgPolygon.toSVG((Polygon)shape);
        else if(shape instanceof Rectangle2D)
            return svgRectangle.toSVG((Rectangle2D)shape);
        else if(shape instanceof RoundRectangle2D)
            return svgRectangle.toSVG((RoundRectangle2D)shape);
        else if(shape instanceof Ellipse2D)
            return svgEllipse.toSVG((Ellipse2D)shape);
        else if(shape instanceof Line2D)
            return svgLine.toSVG((Line2D)shape);
        else if(shape instanceof Arc2D)
            return svgArc.toSVG((Arc2D)shape);
        else
            return svgPath.toSVG(shape);
    }
}
