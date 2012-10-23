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
package org.apache.flex.forks.batik.dom.svg;

import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Arc2D;
import java.awt.geom.PathIterator;

import org.apache.flex.forks.batik.ext.awt.geom.ExtendedGeneralPath;
import org.apache.flex.forks.batik.parser.DefaultPathHandler;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.PathParser;
import org.w3c.dom.svg.SVGPathSeg;

/**
 * This class is the implementation of the normalized
 * <code>SVGPathSegList</code>.
 *
 * @author <a href="mailto:andrest@world-affair.com">Andres Toussaint</a>
 * @version $Id: AbstractSVGNormPathSegList.java 2005-07-28$
 */
public abstract class AbstractSVGNormPathSegList extends AbstractSVGPathSegList {

    /**
     * Creates a new SVGNormPathSegList.
     */
    protected AbstractSVGNormPathSegList() {
        super();
    }

    /**
     * Parse the 'd' attribute.
     *
     * @param value 'd' attribute value
     * @param handler : list handler
     */
    protected void doParse(String value, ListHandler handler) throws ParseException {
        PathParser pathParser = new PathParser();

        NormalizedPathSegListBuilder builder = new NormalizedPathSegListBuilder(handler);

        pathParser.setPathHandler(builder);
        pathParser.parse(value);
    }

    protected class NormalizedPathSegListBuilder extends DefaultPathHandler {

        protected ListHandler listHandler;
        protected SVGPathSegGenericItem lastAbs;

        public NormalizedPathSegListBuilder(ListHandler listHandler){
            this.listHandler  = listHandler;
        }
        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#startPath()}.
         */
        public void startPath() throws ParseException {
            listHandler.startList();
            lastAbs = new SVGPathSegGenericItem(SVGPathSeg.PATHSEG_MOVETO_ABS,
                    PATHSEG_MOVETO_ABS_LETTER, 0,0,0,0,0,0);
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#endPath()}.
         */
        public void endPath() throws ParseException {
            listHandler.endList();
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#movetoRel(float,float)}.
         */
        public void movetoRel(float x, float y) throws ParseException {
            movetoAbs(lastAbs.getX() + x, lastAbs.getY() + y);
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#movetoAbs(float,float)}.
         */
        public void movetoAbs(float x, float y) throws ParseException {
            listHandler.item(new SVGPathSegMovetoLinetoItem
                    (SVGPathSeg.PATHSEG_MOVETO_ABS,PATHSEG_MOVETO_ABS_LETTER,
                            x,y));
            lastAbs.setX(x);
            lastAbs.setY(y);
            lastAbs.setPathSegType(SVGPathSeg.PATHSEG_MOVETO_ABS);
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#closePath()}.
         */
        public void closePath() throws ParseException {
            listHandler.item(new SVGPathSegItem
                    (SVGPathSeg.PATHSEG_CLOSEPATH,PATHSEG_CLOSEPATH_LETTER));
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#linetoRel(float,float)}.
         */
        public void linetoRel(float x, float y) throws ParseException {
            linetoAbs(lastAbs.getX() + x, lastAbs.getY() + y);
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#linetoAbs(float,float)}.
         */
        public void linetoAbs(float x, float y) throws ParseException {
            listHandler.item(new SVGPathSegMovetoLinetoItem
                    (SVGPathSeg.PATHSEG_LINETO_ABS,PATHSEG_LINETO_ABS_LETTER,
                            x,y));
            lastAbs.setX(x);
            lastAbs.setY(y);
            lastAbs.setPathSegType(SVGPathSeg.PATHSEG_LINETO_ABS);
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#linetoHorizontalRel(float)}.
         */
        public void linetoHorizontalRel(float x) throws ParseException {
            linetoAbs(lastAbs.getX() + x, lastAbs.getY());
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#linetoHorizontalAbs(float)}.
         */
        public void linetoHorizontalAbs(float x) throws ParseException {
            linetoAbs(x, lastAbs.getY());
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#linetoVerticalRel(float)}.
         */
        public void linetoVerticalRel(float y) throws ParseException {
            linetoAbs(lastAbs.getX(), lastAbs.getY() + y);
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#linetoVerticalAbs(float)}.
         */
        public void linetoVerticalAbs(float y) throws ParseException {
            linetoAbs(lastAbs.getX(), y);
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.parser.PathHandler#curvetoCubicRel(float,float,float,float,float,float)}.
         */
        public void curvetoCubicRel(float x1, float y1,
                float x2, float y2,
                float x, float y) throws ParseException {
            curvetoCubicAbs(lastAbs.getX() +x1, lastAbs.getY() + y1,
                    lastAbs.getX() +x2, lastAbs.getY() + y2,
                    lastAbs.getX() +x, lastAbs.getY() + y);
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.parser.PathHandler#curvetoCubicAbs(float,float,float,float,float,float)}.
         */
        public void curvetoCubicAbs(float x1, float y1,
                float x2, float y2,
                float x, float y) throws ParseException {
            listHandler.item(new SVGPathSegCurvetoCubicItem
                    (SVGPathSeg.PATHSEG_CURVETO_CUBIC_ABS,PATHSEG_CURVETO_CUBIC_ABS_LETTER,
                            x1,y1,x2,y2,x,y));
            lastAbs.setValue(x1,y1,x2,y2,x,y);
            lastAbs.setPathSegType(SVGPathSeg.PATHSEG_CURVETO_CUBIC_ABS);
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.parser.PathHandler#curvetoCubicSmoothRel(float,float,float,float)}.
         */
        public void curvetoCubicSmoothRel(float x2, float y2,
                float x, float y) throws ParseException {
            curvetoCubicSmoothAbs(lastAbs.getX() + x2, lastAbs.getY() + y2,
                    lastAbs.getX() + x, lastAbs.getY() + y);

        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.parser.PathHandler#curvetoCubicSmoothAbs(float,float,float,float)}.
         */
        public void curvetoCubicSmoothAbs(float x2, float y2,
                float x, float y) throws ParseException {
            if (lastAbs.getPathSegType()==SVGPathSeg.PATHSEG_CURVETO_CUBIC_ABS) {
                curvetoCubicAbs(lastAbs.getX() + (lastAbs.getX() - lastAbs.getX2()),
                        lastAbs.getY() + (lastAbs.getY() - lastAbs.getY2()),
                        x2, y2, x, y);
            } else {
                curvetoCubicAbs(lastAbs.getX(), lastAbs.getY(), x2, y2, x, y);
            }
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.parser.PathHandler#curvetoQuadraticRel(float,float,float,float)}.
         */
        public void curvetoQuadraticRel(float x1, float y1,
                float x, float y) throws ParseException {
            curvetoQuadraticAbs(lastAbs.getX() + x1, lastAbs.getY() + y1,
                    lastAbs.getX() + x, lastAbs.getY() + y);
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.parser.PathHandler#curvetoQuadraticAbs(float,float,float,float)}.
         */
        public void curvetoQuadraticAbs(float x1, float y1,
                float x, float y) throws ParseException {
                        curvetoCubicAbs(lastAbs.getX() + 2 * (x1 - lastAbs.getX()) / 3,
                                                        lastAbs.getY() + 2 * (y1 - lastAbs.getY()) / 3,
                                                        x + 2 * (x1 - x) / 3,
                                                        y + 2 * (y1 - y) / 3,
                                                        x, y);
                        lastAbs.setX1(x1);
                        lastAbs.setY1(y1);
                        lastAbs.setPathSegType(SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_ABS);
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#curvetoQuadraticSmoothRel(float,float)}.
         */
        public void curvetoQuadraticSmoothRel(float x, float y)
        throws ParseException {
            curvetoQuadraticSmoothAbs(lastAbs.getX() + x, lastAbs.getY() + y);
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.PathHandler#curvetoQuadraticSmoothAbs(float,float)}.
         */
        public void curvetoQuadraticSmoothAbs(float x, float y)
        throws ParseException {
            if (lastAbs.getPathSegType()==SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_ABS) {
                curvetoQuadraticAbs(lastAbs.getX() + (lastAbs.getX() - lastAbs.getX1()),
                        lastAbs.getY() + (lastAbs.getY() - lastAbs.getY1()),
                        x, y);
            } else {
                curvetoQuadraticAbs(lastAbs.getX(), lastAbs.getY(), x, y);
            }

        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.parser.PathHandler#arcRel(float,float,float,boolean,boolean,float,float)}.
         */
        public void arcRel(float rx, float ry,
                float xAxisRotation,
                boolean largeArcFlag, boolean sweepFlag,
                float x, float y) throws ParseException {
            arcAbs(rx,ry,xAxisRotation, largeArcFlag, sweepFlag, lastAbs.getX() + x, lastAbs.getY() + y);
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.parser.PathHandler#arcAbs(float,float,float,boolean,boolean,float,float)}.
         */
        public void arcAbs(float rx, float ry,
                float xAxisRotation,
                boolean largeArcFlag, boolean sweepFlag,
                float x, float y) throws ParseException {

                        //         Ensure radii are valid
                        if (rx == 0 || ry == 0) {
                                linetoAbs(x, y);
                                return;
                        }

                        // Get the current (x, y) coordinates of the path
                        double x0 = lastAbs.getX();
                        double y0 = lastAbs.getY();
                        if (x0 == x && y0 == y) {
                                // If the endpoints (x, y) and (x0, y0) are identical, then this
                                // is equivalent to omitting the elliptical arc segment entirely.
                                return;
                        }

                        Arc2D arc = ExtendedGeneralPath.computeArc(x0, y0, rx, ry, xAxisRotation,
                                        largeArcFlag, sweepFlag, x, y);
                        if (arc == null) return;

                        AffineTransform t = AffineTransform.getRotateInstance
                        (Math.toRadians(xAxisRotation), arc.getCenterX(), arc.getCenterY());
                        Shape s = t.createTransformedShape(arc);

                        PathIterator pi = s.getPathIterator(new AffineTransform());
                        float[] d = {0,0,0,0,0,0};
                        int i = -1;

                        while (!pi.isDone()) {
                                i = pi.currentSegment(d);

                                switch (i) {
                                case PathIterator.SEG_CUBICTO:
                                        curvetoCubicAbs(d[0],d[1],d[2],d[3],d[4],d[5]);
                                        break;
                                }
                                pi.next();
                        }
                        lastAbs.setPathSegType(SVGPathSeg.PATHSEG_ARC_ABS);
        }
    }


    protected class SVGPathSegGenericItem extends SVGPathSegItem {

        public SVGPathSegGenericItem(short type, String letter,
                float x1, float y1, float x2, float y2, float x, float y){
            super(type,letter);
            this.x1 = x2;
            this.y1 = y2;
            this.x2 = x2;
            this.y2 = y2;
            this.x = x;
            this.y = y;
        }

        public void setValue(float x1, float y1, float x2, float y2, float x, float y) {
            this.x1 = x2;
            this.y1 = y2;
            this.x2 = x2;
            this.y2 = y2;
            this.x = x;
            this.y = y;
        }

        public void setValue(float x, float y) {
            this.x = x;
            this.y = y;
        }

        public void setPathSegType(short type) {
            this.type = type;
        }

        public float getX(){
            return x;
        }
        public float getY(){
            return y;
        }

        public void setX(float x){
            this.x = x;
        }
        public void setY(float y){
            this.y = y;
        }

        public float getX1(){
            return x1;
        }
        public float getY1(){
            return y1;
        }

        public void setX1(float x){
            this.x1 = x;
        }
        public void setY1(float y){
            this.y1 = y;
        }
        public float getX2(){
            return x2;
        }
        public float getY2(){
            return y2;
        }

        public void setX2(float x){
            this.x2 = x;
        }
        public void setY2(float y){
            this.y2 = y;
        }
    }
}
