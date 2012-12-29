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

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGAnimatedNumber;
import org.w3c.dom.svg.SVGPathElement;
import org.w3c.dom.svg.SVGPathSeg;
import org.w3c.dom.svg.SVGPathSegArcAbs;
import org.w3c.dom.svg.SVGPathSegArcRel;
import org.w3c.dom.svg.SVGPathSegClosePath;
import org.w3c.dom.svg.SVGPathSegCurvetoCubicAbs;
import org.w3c.dom.svg.SVGPathSegCurvetoCubicRel;
import org.w3c.dom.svg.SVGPathSegCurvetoCubicSmoothAbs;
import org.w3c.dom.svg.SVGPathSegCurvetoCubicSmoothRel;
import org.w3c.dom.svg.SVGPathSegCurvetoQuadraticAbs;
import org.w3c.dom.svg.SVGPathSegCurvetoQuadraticRel;
import org.w3c.dom.svg.SVGPathSegCurvetoQuadraticSmoothAbs;
import org.w3c.dom.svg.SVGPathSegCurvetoQuadraticSmoothRel;
import org.w3c.dom.svg.SVGPathSegLinetoAbs;
import org.w3c.dom.svg.SVGPathSegLinetoHorizontalAbs;
import org.w3c.dom.svg.SVGPathSegLinetoHorizontalRel;
import org.w3c.dom.svg.SVGPathSegLinetoRel;
import org.w3c.dom.svg.SVGPathSegLinetoVerticalAbs;
import org.w3c.dom.svg.SVGPathSegLinetoVerticalRel;
import org.w3c.dom.svg.SVGPathSegList;
import org.w3c.dom.svg.SVGPathSegMovetoAbs;
import org.w3c.dom.svg.SVGPathSegMovetoRel;
import org.w3c.dom.svg.SVGPoint;

/**
 * This class implements {@link SVGPathElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMPathElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMPathElement
    extends    SVGGraphicsElement
    implements SVGPathElement,
               SVGPathSegConstants {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGGraphicsElement.xmlTraitInformation);
        t.put(null, SVG_D_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_PATH_DATA));
        t.put(null, SVG_PATH_LENGTH_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        xmlTraitInformation = t;
    }

    /**
     * The 'd' attribute value.
     */
    protected SVGOMAnimatedPathData d;

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
        initializeLiveAttributes();
    }

    /**
     * Initializes all live attributes for this element.
     */
    protected void initializeAllLiveAttributes() {
        super.initializeAllLiveAttributes();
        initializeLiveAttributes();
    }

    /**
     * Initializes the live attribute values of this element.
     */
    private void initializeLiveAttributes() {
        d = createLiveAnimatedPathData(null, SVG_D_ATTRIBUTE, "");
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_PATH_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getPathLength()}.
     */
    public SVGAnimatedNumber getPathLength() {
        throw new UnsupportedOperationException
            ("SVGPathElement.getPathLength is not implemented"); // XXX
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
        return SVGPathSupport.getPathSegAtLength(this, distance);
    }

    /**
     * Returns the {@link SVGOMAnimatedPathData} object that manages the
     * path data for this element.
     */
    public SVGOMAnimatedPathData getAnimatedPathData() {
        return d;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getPathSegList()}.
     */
    public SVGPathSegList getPathSegList() {
        return d.getPathSegList();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getNormalizedPathSegList()}.
     */
    public SVGPathSegList getNormalizedPathSegList() {
        return d.getNormalizedPathSegList();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPathElement#getAnimatedPathSegList()}.
     */
    public SVGPathSegList getAnimatedPathSegList() {
        return d.getAnimatedPathSegList();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPathElement#getAnimatedNormalizedPathSegList()}.
     */
    public SVGPathSegList getAnimatedNormalizedPathSegList() {
        return d.getAnimatedNormalizedPathSegList();
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

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
