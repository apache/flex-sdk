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

import java.awt.Shape;
import java.awt.geom.GeneralPath;
import java.awt.geom.PathIterator;

import org.w3c.dom.Element;

/**
 * Utility class that converts a Shape object into an SVG
 * path element. Note that this class does not attempt to
 * find out what type of object (e.g., whether the input
 * Shape is a Rectangle or an Ellipse. This type of analysis
 * is done by the SVGShape class).
 * Note that this class assumes that the parent of the
 * path element it generates defines the fill-rule as
 * nonzero. This is not the SVG default value. However,
 * because it is the GeneralPath's default, it is preferable
 * to have this attribute specified once to set the default
 * (in the parent element, e.g., a group) and then only in
 * the rare instance where the winding rule is different
 * than the default. Otherwise, the attribute would have
 * to be specified in the majority of path elements.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGPath.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class SVGPath extends SVGGraphicObjectConverter {
    /**
     * @param generatorContext used to build Elements
     */
    public SVGPath(SVGGeneratorContext generatorContext) {
        super(generatorContext);
    }

    /**
     * @param path the Shape that should be converted to an SVG path
     *        element.
     * @return a path Element.
     */
    public Element toSVG(Shape path) {
        // Create the path element and process its
        // d attribute.
        String dAttr = toSVGPathData(path, generatorContext);
        if (dAttr==null || dAttr.length() == 0){
            // be careful not to append null to the DOM tree
            // because it will crash
            return null;
        }

        Element svgPath = generatorContext.domFactory.createElementNS
            (SVG_NAMESPACE_URI, SVG_PATH_TAG);
        svgPath.setAttributeNS(null, SVG_D_ATTRIBUTE, dAttr);

        // Set winding rule if different than SVG's default
        if (path.getPathIterator(null).getWindingRule() == GeneralPath.WIND_EVEN_ODD)
            svgPath.setAttributeNS(null, SVG_FILL_RULE_ATTRIBUTE, SVG_EVEN_ODD_VALUE);

        return svgPath;
    }

    /**
     * @param path the GeneralPath to convert
     * @return the value of the corresponding d attribute
     */
     public static String toSVGPathData(Shape path, SVGGeneratorContext gc) {
        StringBuffer d = new StringBuffer( 40 );
        PathIterator pi = path.getPathIterator(null);
        float[] seg = new float[6];
        int segType = 0;
        while (!pi.isDone()) {
            segType = pi.currentSegment(seg);
            switch(segType) {
            case PathIterator.SEG_MOVETO:
                d.append(PATH_MOVE);
                appendPoint(d, seg[0], seg[1], gc);
                break;
            case PathIterator.SEG_LINETO:
                d.append(PATH_LINE_TO);
                appendPoint(d, seg[0], seg[1], gc);
                break;
            case PathIterator.SEG_CLOSE:
                d.append(PATH_CLOSE);
                break;
            case PathIterator.SEG_QUADTO:
                d.append(PATH_QUAD_TO);
                appendPoint(d, seg[0], seg[1], gc);
                appendPoint(d, seg[2], seg[3], gc);
                break;
            case PathIterator.SEG_CUBICTO:
                d.append(PATH_CUBIC_TO);
                appendPoint(d, seg[0], seg[1], gc);
                appendPoint(d, seg[2], seg[3], gc);
                appendPoint(d, seg[4], seg[5], gc);
                break;
            default:
                throw new Error("invalid segmentType:" + segType );
            }
            pi.next();
        } // while !isDone

        if (d.length() > 0)
            return d.toString().trim();
        else {
            // This is a degenerate case: there was no initial moveTo
            // in the path and no data at all. However, this happens
            // in the Java 2D API (e.g., when clipping to a rectangle
            // with negative height/width, the clip will be a GeneralPath
            // with no data, which causes everything to be clipped)
            // It is the responsibility of the users of SVGPath to detect
            // instances where the converted element (see #toSVG above)
            // returns null, which only happens for degenerate cases.
            return "";
        }
    }

    /**
     * Appends a coordinate to the path data
     */
    private static void appendPoint(StringBuffer d, float x, float y, SVGGeneratorContext gc) {
        d.append(gc.doubleString(x));
        d.append(SPACE);
        d.append(gc.doubleString(y));
        d.append(SPACE);
    }
}
