/*

   Copyright 2000-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumber;
import org.w3c.flex.forks.dom.svg.SVGPathElement;
import org.w3c.flex.forks.dom.svg.SVGPathSeg;
import org.w3c.flex.forks.dom.svg.SVGPathSegArcAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegArcRel;
import org.w3c.flex.forks.dom.svg.SVGPathSegClosePath;
import org.w3c.flex.forks.dom.svg.SVGPathSegCurvetoCubicAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegCurvetoCubicRel;
import org.w3c.flex.forks.dom.svg.SVGPathSegCurvetoCubicSmoothAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegCurvetoCubicSmoothRel;
import org.w3c.flex.forks.dom.svg.SVGPathSegCurvetoQuadraticAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegCurvetoQuadraticRel;
import org.w3c.flex.forks.dom.svg.SVGPathSegCurvetoQuadraticSmoothAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegCurvetoQuadraticSmoothRel;
import org.w3c.flex.forks.dom.svg.SVGPathSegLinetoAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegLinetoHorizontalAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegLinetoHorizontalRel;
import org.w3c.flex.forks.dom.svg.SVGPathSegLinetoRel;
import org.w3c.flex.forks.dom.svg.SVGPathSegLinetoVerticalAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegLinetoVerticalRel;
import org.w3c.flex.forks.dom.svg.SVGPathSegList;
import org.w3c.flex.forks.dom.svg.SVGPathSegMovetoAbs;
import org.w3c.flex.forks.dom.svg.SVGPathSegMovetoRel;
import org.w3c.flex.forks.dom.svg.SVGPoint;

/**
 * This class implements {@link SVGPathElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMPathElement.java,v 1.10 2005/02/27 02:08:51 deweese Exp $
 */
public class SVGOMPathElement
    extends    SVGGraphicsElement
    implements SVGPathElement,
               SVGPathSegConstants {

    /**
     * Creates a new SVGOMPathElement object.
     */
    protected SVGOMPathElement() {
    }

    /**
     * Creates a new SVGOMPathElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMPathElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return "path";
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getPathLength()}.
     */
    public SVGAnimatedNumber getPathLength() {
        throw new RuntimeException(" !!! getPathLength() Not Yet Implemented");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getTotalLength()}.
     */
    public float getTotalLength() {
        return SVGPathSupport.getTotalLength(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getPointAtLength(float)}.
     */
    public SVGPoint getPointAtLength(float distance) {
        return SVGPathSupport.getPointAtLength(this, distance);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getPathSegAtLength(float)}.
     */
    public int getPathSegAtLength(float distance) {
        throw new RuntimeException
            (" !!! getPathSegAtLength() Not Yet Implemented");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getPathSegList()}.
     */
    public SVGPathSegList getPathSegList() {
        return SVGAnimatedPathDataSupport.getPathSegList(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getNormalizedPathSegList()}.
     */
    public SVGPathSegList getNormalizedPathSegList() {
        return SVGAnimatedPathDataSupport.getNormalizedPathSegList(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getAnimatedPathSegList()}.
     */
    public SVGPathSegList getAnimatedPathSegList() {
        return SVGAnimatedPathDataSupport.getAnimatedNormalizedPathSegList(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getAnimatedNormalizedPathSegList()}.
     */
    public SVGPathSegList getAnimatedNormalizedPathSegList() {
        return SVGAnimatedPathDataSupport.getAnimatedNormalizedPathSegList
            (this);
    }

    // Factory methods /////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#createSVGPathSegClosePath()}.
     */
    public SVGPathSegClosePath createSVGPathSegClosePath() {
        return new SVGPathSegClosePath(){
                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CLOSEPATH;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CLOSEPATH_LETTER;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegMovetoAbs(float,float)}.
     */
    public SVGPathSegMovetoAbs createSVGPathSegMovetoAbs(final float x_value, final float y_value) {
        //throw new RuntimeException(" !!! createSVGPathSegMovetoAbs()");
        return new SVGPathSegMovetoAbs(){
                protected float x = x_value;
                protected float y = y_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_MOVETO_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_MOVETO_ABS_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegMovetoRel(float,float)}.
     */
    public SVGPathSegMovetoRel createSVGPathSegMovetoRel(final float x_value, final float y_value) {
        //throw new RuntimeException(" !!! createSVGPathSegMovetoRel()");
        return new SVGPathSegMovetoRel(){
                protected float x = x_value;
                protected float y = y_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_MOVETO_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_MOVETO_REL_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
            };

    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegLinetoAbs(float,float)}.
     */
    public SVGPathSegLinetoAbs createSVGPathSegLinetoAbs(final float x_value, final float y_value) {
        //throw new RuntimeException(" !!! createSVGPathSegLinetoAbs()");
        return new SVGPathSegLinetoAbs(){
                protected float x = x_value;
                protected float y = y_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_LINETO_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_LINETO_ABS_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegLinetoRel(float,float)}.
     */
    public SVGPathSegLinetoRel createSVGPathSegLinetoRel(final float x_value, final float y_value) {
        //throw new RuntimeException(" !!! createSVGPathSegLinetoRel()");
        return new SVGPathSegLinetoRel(){
                protected float x = x_value;
                protected float y = y_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_LINETO_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_LINETO_REL_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegLinetoHorizontalAbs(float)}.
     */
    public SVGPathSegLinetoHorizontalAbs createSVGPathSegLinetoHorizontalAbs(final float x_value) {
        //throw new RuntimeException(" !!! createSVGPathSegLinetoHorizontalAbs()");
        return new SVGPathSegLinetoHorizontalAbs(){
                protected float x = x_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_LINETO_HORIZONTAL_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_LINETO_HORIZONTAL_ABS_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
            };

    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegLinetoHorizontalRel(float)}.
     */
    public SVGPathSegLinetoHorizontalRel createSVGPathSegLinetoHorizontalRel(final float x_value) {
        //throw new RuntimeException(" !!! createSVGPathSegLinetoHorizontalRel()");
        return new SVGPathSegLinetoHorizontalRel(){
                protected float x = x_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_LINETO_HORIZONTAL_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_LINETO_HORIZONTAL_REL_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
            };

    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegLinetoVerticalAbs(float)}.
     */
    public SVGPathSegLinetoVerticalAbs createSVGPathSegLinetoVerticalAbs(final float y_value) {
        //throw new RuntimeException(" !!! createSVGPathSegLinetoVerticalAbs()");
        return new SVGPathSegLinetoVerticalAbs(){
                protected float y = y_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_LINETO_VERTICAL_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_LINETO_VERTICAL_ABS_LETTER;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
            };

    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegLinetoVerticalRel(float)}.
     */
    public SVGPathSegLinetoVerticalRel createSVGPathSegLinetoVerticalRel(final float y_value) {
        //throw new RuntimeException(" !!! createSVGPathSegLinetoVerticalRel()");
        return new SVGPathSegLinetoVerticalRel(){
                protected float y = y_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_LINETO_VERTICAL_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_LINETO_VERTICAL_REL_LETTER;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
            };

    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegCurvetoCubicAbs(float,float,float,float,float,float)}.
     */
    public SVGPathSegCurvetoCubicAbs createSVGPathSegCurvetoCubicAbs
        (final float x_value, final float y_value, 
         final float x1_value, final float y1_value, 
         final float x2_value, final float y2_value) {
        //throw new RuntimeException(" !!! createSVGPathSegCurvetoCubicAbs()");
        return new SVGPathSegCurvetoCubicAbs(){
                protected float x = x_value;
                protected float y = y_value;
                protected float x1 = x1_value;
                protected float y1 = y1_value;
                protected float x2 = x2_value;
                protected float y2 = y2_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CURVETO_CUBIC_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CURVETO_CUBIC_ABS_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
                public float getX1(){
                    return x1;
                }
                public void setX1(float x1){
                    this.x1 = x1;
                }
                public float getY1(){
                    return y1;
                }
                public void setY1(float y1){
                    this.y1 = y1;
                }
                public float getX2(){
                    return x2;
                }
                public void setX2(float x2){
                    this.x2 = x2;
                }
                public float getY2(){
                    return y2;
                }
                public void setY2(float y2){
                    this.y2 = y2;
                }
            };

    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegCurvetoCubicRel(float,float,float,float,float,float)}.
     */
    public SVGPathSegCurvetoCubicRel createSVGPathSegCurvetoCubicRel
        (final float x_value, final float y_value, 
         final float x1_value, final float y1_value, 
         final float x2_value, final float y2_value) {
        //throw new RuntimeException(" !!! createSVGPathSegCurvetoCubicAbs()");
        return new SVGPathSegCurvetoCubicRel(){
                protected float x = x_value;
                protected float y = y_value;
                protected float x1 = x1_value;
                protected float y1 = y1_value;
                protected float x2 = x2_value;
                protected float y2 = y2_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CURVETO_CUBIC_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CURVETO_CUBIC_REL_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
                public float getX1(){
                    return x1;
                }
                public void setX1(float x1){
                    this.x1 = x1;
                }
                public float getY1(){
                    return y1;
                }
                public void setY1(float y1){
                    this.y1 = y1;
                }
                public float getX2(){
                    return x2;
                }
                public void setX2(float x2){
                    this.x2 = x2;
                }
                public float getY2(){
                    return y2;
                }
                public void setY2(float y2){
                    this.y2 = y2;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegCurvetoQuadraticAbs(float,float,float,float)}.
     */
    public SVGPathSegCurvetoQuadraticAbs createSVGPathSegCurvetoQuadraticAbs
        (final float x_value, final float y_value, 
         final float x1_value, final float y1_value) {
        //throw new RuntimeException(" !!! createSVGPathSegCurvetoCubicAbs()");
        return new SVGPathSegCurvetoQuadraticAbs(){
                protected float x = x_value;
                protected float y = y_value;
                protected float x1 = x1_value;
                protected float y1 = y1_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CURVETO_QUADRATIC_ABS_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
                public float getX1(){
                    return x1;
                }
                public void setX1(float x1){
                    this.x1 = x1;
                }
                public float getY1(){
                    return y1;
                }
                public void setY1(float y1){
                    this.y1 = y1;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegCurvetoQuadraticRel(float,float,float,float)}.
     */
    public SVGPathSegCurvetoQuadraticRel createSVGPathSegCurvetoQuadraticRel
        (final float x_value, final float y_value, 
         final float x1_value, final float y1_value) {
        //throw new RuntimeException(" !!! createSVGPathSegCurvetoCubicAbs()");
        return new SVGPathSegCurvetoQuadraticRel(){
                protected float x = x_value;
                protected float y = y_value;
                protected float x1 = x1_value;
                protected float y1 = y1_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CURVETO_QUADRATIC_REL_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
                public float getX1(){
                    return x1;
                }
                public void setX1(float x1){
                    this.x1 = x1;
                }
                public float getY1(){
                    return y1;
                }
                public void setY1(float y1){
                    this.y1 = y1;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegCurvetoCubicSmoothAbs(float,float,float,float)}.
     */
    public SVGPathSegCurvetoCubicSmoothAbs
            createSVGPathSegCurvetoCubicSmoothAbs
        (final float x_value, final float y_value, 
         final float x2_value, final float y2_value) {
        //throw new RuntimeException(" !!! createSVGPathSegCurvetoCubicAbs()");
        return new SVGPathSegCurvetoCubicSmoothAbs(){
                protected float x = x_value;
                protected float y = y_value;
                protected float x2 = x2_value;
                protected float y2 = y2_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CURVETO_CUBIC_SMOOTH_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CURVETO_CUBIC_SMOOTH_ABS_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
                public float getX2(){
                    return x2;
                }
                public void setX2(float x2){
                    this.x2 = x2;
                }
                public float getY2(){
                    return y2;
                }
                public void setY2(float y2){
                    this.y2 = y2;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegCurvetoCubicSmoothRel(float,float,float,float)}.
     */
    public SVGPathSegCurvetoCubicSmoothRel
            createSVGPathSegCurvetoCubicSmoothRel
        (final float x_value, final float y_value, 
         final float x2_value, final float y2_value) {
        //throw new RuntimeException(" !!! createSVGPathSegCurvetoCubicAbs()");
        return new SVGPathSegCurvetoCubicSmoothRel(){
                protected float x = x_value;
                protected float y = y_value;
                protected float x2 = x2_value;
                protected float y2 = y2_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CURVETO_CUBIC_SMOOTH_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CURVETO_CUBIC_SMOOTH_REL_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
                public float getX2(){
                    return x2;
                }
                public void setX2(float x2){
                    this.x2 = x2;
                }
                public float getY2(){
                    return y2;
                }
                public void setY2(float y2){
                    this.y2 = y2;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegCurvetoQuadraticSmoothAbs(float,float)}.
     */
    public SVGPathSegCurvetoQuadraticSmoothAbs
            createSVGPathSegCurvetoQuadraticSmoothAbs
        (final float x_value, final float y_value) {
        //throw new RuntimeException(" !!! createSVGPathSegLinetoAbs()");
        return new SVGPathSegCurvetoQuadraticSmoothAbs(){
                protected float x = x_value;
                protected float y = y_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
            };

    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegCurvetoQuadraticSmoothRel(float,float)}.
     */
    public SVGPathSegCurvetoQuadraticSmoothRel
            createSVGPathSegCurvetoQuadraticSmoothRel
        (final float x_value, final float y_value) {
        //throw new RuntimeException(" !!! createSVGPathSegLinetoAbs()");
        return new SVGPathSegCurvetoQuadraticSmoothRel(){
                protected float x = x_value;
                protected float y = y_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegArcAbs(float,float,float,float,float,boolean,boolean)}.
     */
    public SVGPathSegArcAbs createSVGPathSegArcAbs
        (final float x_value, final float y_value, 
         final float r1_value, final float r2_value, 
         final float angle_value,
         final boolean largeArcFlag_value, 
         final boolean sweepFlag_value) {
        //throw new RuntimeException(" !!! createSVGPathSegArcAbs()");
        return new SVGPathSegArcAbs(){
                protected float x = x_value;
                protected float y = y_value;
                protected float r1 = r1_value;
                protected float r2 = r2_value;
                protected float angle = angle_value;
                protected boolean largeArcFlag = largeArcFlag_value;
                protected boolean sweepFlag = sweepFlag_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_ARC_ABS;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_ARC_ABS_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
                public float getR1(){
                    return r1;
                }
                public void setR1(float r1){
                    this.r1 = r1;
                }
                public float getR2(){
                    return r2;
                }
                public void setR2(float r2){
                    this.r2 = r2;
                }
                public float getAngle(){
                    return angle;
                }
                public void setAngle(float angle){
                    this.angle = angle;
                }
                public boolean getLargeArcFlag(){
                    return largeArcFlag;
                }
                public void setLargeArcFlag(boolean largeArcFlag){
                    this.largeArcFlag = largeArcFlag;
                }
                public boolean getSweepFlag(){
                    return sweepFlag;
                }
                public void setSweepFlag(boolean sweepFlag){
                    this.sweepFlag = sweepFlag;
                }


            };
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#createSVGPathSegArcRel(float,float,float,float,float,boolean,boolean)}.
     */
    public SVGPathSegArcRel createSVGPathSegArcRel
        (final float x_value, final float y_value, 
         final float r1_value, final float r2_value, 
         final float angle_value,
         final boolean largeArcFlag_value, 
         final boolean sweepFlag_value) {
        //throw new RuntimeException(" !!! createSVGPathSegArcAbs()");
        return new SVGPathSegArcRel(){
                protected float x = x_value;
                protected float y = y_value;
                protected float r1 = r1_value;
                protected float r2 = r2_value;
                protected float angle = angle_value;
                protected boolean largeArcFlag = largeArcFlag_value;
                protected boolean sweepFlag = sweepFlag_value;

                public short getPathSegType(){
                    return SVGPathSeg.PATHSEG_ARC_REL;
                }
                public String getPathSegTypeAsLetter(){
                    return PATHSEG_ARC_REL_LETTER;
                }
                public float getX(){
                    return x;
                }
                public void setX(float x){
                    this.x = x;
                }
                public float getY(){
                    return y;
                }
                public void setY(float y){
                    this.y = y;
                }
                public float getR1(){
                    return r1;
                }
                public void setR1(float r1){
                    this.r1 = r1;
                }
                public float getR2(){
                    return r2;
                }
                public void setR2(float r2){
                    this.r2 = r2;
                }
                public float getAngle(){
                    return angle;
                }
                public void setAngle(float angle){
                    this.angle = angle;
                }
                public boolean getLargeArcFlag(){
                    return largeArcFlag;
                }
                public void setLargeArcFlag(boolean largeArcFlag){
                    this.largeArcFlag = largeArcFlag;
                }
                public boolean getSweepFlag(){
                    return sweepFlag;
                }
                public void setSweepFlag(boolean sweepFlag){
                    this.sweepFlag = sweepFlag;
                }


            };
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMPathElement();
    }
}
