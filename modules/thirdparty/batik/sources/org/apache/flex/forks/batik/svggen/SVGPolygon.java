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
import java.awt.geom.PathIterator;

import org.w3c.dom.Element;

/**
 * Utility class that converts a Polygon object into
 * an SVG element.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGPolygon.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class SVGPolygon extends SVGGraphicObjectConverter {
    /**
     * @param generatorContext used to build Elements
     */
    public SVGPolygon(SVGGeneratorContext generatorContext) {
        super(generatorContext);
    }

    /**
     * @param polygon polygon object to convert to SVG
     */
    public Element toSVG(Polygon polygon) {
        Element svgPolygon =
            generatorContext.domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                        SVG_POLYGON_TAG);
        StringBuffer points = new StringBuffer(" ");
        PathIterator pi = polygon.getPathIterator(null);
        float[] seg = new float[6];
        while(!pi.isDone()){
            int segType = pi.currentSegment(seg);
            switch(segType){
            case PathIterator.SEG_MOVETO:
                appendPoint(points, seg[0], seg[1]);
                break;
            case PathIterator.SEG_LINETO:
                appendPoint(points, seg[0], seg[1]);
                break;
            case PathIterator.SEG_CLOSE:
                break;
            case PathIterator.SEG_QUADTO:
            case PathIterator.SEG_CUBICTO:
            default:
                throw new Error("invalid segmentType:" + segType );
            }
            pi.next();
        } // while !isDone

        svgPolygon.setAttributeNS(null,
                                  SVG_POINTS_ATTRIBUTE,
                                  points.substring(0, points.length() - 1));

        return svgPolygon;
    }

    /**
     *  Appends a coordinate to the path data
     */
    private void appendPoint(StringBuffer points, float x, float y){
        points.append(doubleString(x));
        points.append(SPACE);
        points.append(doubleString(y));
        points.append(SPACE);
    }
}
