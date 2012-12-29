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

import java.awt.geom.Arc2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.awt.geom.Point2D;

import org.w3c.dom.Element;

/**
 * Utility class that converts an Arc2D object into
 * a corresponding SVG element, i.e., a path with an elliptical arc
 * and optionally lines..
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: SVGArc.java 476924 2006-11-19 21:13:26Z dvholten $
 */
public class SVGArc extends SVGGraphicObjectConverter {

    /**
     * Line converter used for degenerate cases
     */
    private SVGLine svgLine;

    /**
     * Ellipse converter for 360 degree arcs.
     */
    private SVGEllipse svgEllipse;

    /**
     * @param generatorContext used to build Elements
     */
    public SVGArc(SVGGeneratorContext generatorContext) {
        super(generatorContext);
    }

    /**
     * @param arc the Arc2D object to be converted
     */
    public Element toSVG(Arc2D arc) {
        double ext    = arc.getAngleExtent();
        double width  = arc.getWidth();
        double height = arc.getHeight();

        if (width == 0 || height == 0) {
            Line2D line = new Line2D.Double
                (arc.getX(), arc.getY(),
                 arc.getX() + width,
                 arc.getY() + height);
            if (svgLine == null) {
                svgLine = new SVGLine(generatorContext);
            }
            return svgLine.toSVG(line);
        }

        if (ext >= 360 || ext <= -360) {
            Ellipse2D ellipse = new Ellipse2D.Double
                (arc.getX(), arc.getY(), width, height);
            if (svgEllipse == null) {
                svgEllipse = new SVGEllipse(generatorContext);
            }
            return svgEllipse.toSVG(ellipse);
        }

        Element svgPath = generatorContext.domFactory.createElementNS
            (SVG_NAMESPACE_URI, SVG_PATH_TAG);
        StringBuffer d = new StringBuffer( 64 );

        Point2D startPt = arc.getStartPoint();
        Point2D endPt   = arc.getEndPoint();
        int     type    = arc.getArcType();

        d.append(PATH_MOVE);
        d.append(doubleString(startPt.getX()));
        d.append(SPACE);
        d.append(doubleString(startPt.getY()));
        d.append(SPACE);

        d.append(PATH_ARC);
        d.append(doubleString(width / 2));
        d.append(SPACE);
        d.append(doubleString(height / 2));
        d.append(SPACE);
        d.append( '0' );  // no rotation with J2D arc.
        d.append(SPACE);
        if (ext > 0) {
            // CCW sweep case, ext > 0
            if (ext > 180)  d.append( '1' );  // use large arc.
            else            d.append( '0' );  // use small arc.
            d.append(SPACE);
            d.append( '0' );  // sweep ccw
        } else {
            // CW sweep case, ext < 0
            if (ext < -180)  d.append( '1' );  // use large arc.
            else             d.append( '0' );  // use small arc.
            d.append(SPACE);
            d.append( '1' );  // sweep cw
        }

        d.append(SPACE);
        d.append(doubleString(endPt.getX()));
        d.append(SPACE);
        d.append(doubleString(endPt.getY()));

        if (type == Arc2D.CHORD) {
            d.append(PATH_CLOSE);
        } else if (type == Arc2D.PIE) {
            double cx = arc.getX() + width / 2;
            double cy = arc.getY() + height / 2;
            d.append(PATH_LINE_TO);
            d.append(SPACE);
            d.append(doubleString(cx));
            d.append(SPACE);
            d.append(doubleString(cy));
            d.append(SPACE);
            d.append(PATH_CLOSE);
        }
        svgPath.setAttributeNS(null, SVG_D_ATTRIBUTE, d.toString());
        return svgPath;
    }
}
