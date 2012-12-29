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

import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGPoint;
import org.w3c.dom.svg.SVGRect;

/**
 * This class provides support for the SVGTextContentElement interface.
 *
 * @author nicolas.socheleau@bitflash.com
 * @version $Id: SVGTextContentSupport.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGTextContentSupport {

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#getNumberOfChars()}.
     */
    public static int getNumberOfChars(Element elt)
    {
        final SVGOMElement svgelt = (SVGOMElement)elt;

        return (((SVGTextContent)svgelt.getSVGContext()).getNumberOfChars());
    }

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#getExtentOfChar(int charnum)}.
     */
    public static SVGRect getExtentOfChar(Element elt, final int charnum ) {
        final SVGOMElement svgelt = (SVGOMElement)elt;

        if ( (charnum < 0) || 
             (charnum >= getNumberOfChars(elt)) ){
            throw svgelt.createDOMException
                (DOMException.INDEX_SIZE_ERR,
                 "",null);
        }
        
        final SVGTextContent context = (SVGTextContent)svgelt.getSVGContext();
        
        return new SVGRect() {
                public float getX() {
                    return (float)SVGTextContentSupport.getExtent
                        (svgelt, context, charnum).getX();
                }
                public void setX(float x) throws DOMException {
                    throw svgelt.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.rect", null);
                }

                public float getY() {
                    return (float)SVGTextContentSupport.getExtent
                        (svgelt, context, charnum).getY();
                }
                public void setY(float y) throws DOMException {
                    throw svgelt.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.rect", null);
                }

                public float getWidth() {
                    return (float)SVGTextContentSupport.getExtent
                        (svgelt, context, charnum).getWidth();
                }
                public void setWidth(float width) throws DOMException {
                    throw svgelt.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.rect", null);
                }

                public float getHeight() {
                    return (float)SVGTextContentSupport.getExtent
                        (svgelt, context, charnum).getHeight();
                }
                public void setHeight(float height) throws DOMException {
                    throw svgelt.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.rect", null);
                }
            };
    }

    protected static Rectangle2D getExtent
        (SVGOMElement svgelt, SVGTextContent context, int charnum) {
        Rectangle2D r2d = context.getExtentOfChar(charnum);
        if (r2d == null) throw svgelt.createDOMException
                             (DOMException.INDEX_SIZE_ERR, "",null);
        return r2d;
    }
    
    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#getStartPositionOfChar(int charnum)}.
     */
    public static SVGPoint getStartPositionOfChar
        (Element elt, final int charnum) throws DOMException {

        final SVGOMElement svgelt = (SVGOMElement)elt;

        if ( (charnum < 0) || 
             (charnum >= getNumberOfChars(elt)) ){
            throw svgelt.createDOMException
                (DOMException.INDEX_SIZE_ERR,
                 "",null);
        }
        
        final SVGTextContent context = (SVGTextContent)svgelt.getSVGContext();

        return new SVGTextPoint(svgelt){
                public float getX(){
                    return (float)SVGTextContentSupport.getStartPos
                        (this.svgelt, context, charnum).getX();
                }
                public float getY(){
                    return (float)SVGTextContentSupport.getStartPos
                        (this.svgelt, context, charnum).getY();
                }
            };
    }

    protected static Point2D getStartPos
        (SVGOMElement svgelt, SVGTextContent context, int charnum) {
        Point2D p2d = context.getStartPositionOfChar(charnum);
        if (p2d == null) throw svgelt.createDOMException
                             (DOMException.INDEX_SIZE_ERR, "",null);
        return p2d;
    }
    
    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#getEndPositionOfChar(int charnum)}.
     */
    public static SVGPoint getEndPositionOfChar
        (Element elt,final int charnum) throws DOMException {

        final SVGOMElement svgelt = (SVGOMElement)elt;

        if ( (charnum < 0) || 
             (charnum >= getNumberOfChars(elt)) ){
            throw svgelt.createDOMException
                (DOMException.INDEX_SIZE_ERR,
                 "",null);
        }
        
        final SVGTextContent context = (SVGTextContent)svgelt.getSVGContext();

        return new SVGTextPoint(svgelt){
                public float getX(){
                    return (float)SVGTextContentSupport.getEndPos
                        (this.svgelt, context, charnum).getX();
                }
                public float getY(){
                    return (float)SVGTextContentSupport.getEndPos
                        (this.svgelt, context, charnum).getY();
                }
            };
    }

    protected static Point2D getEndPos
        (SVGOMElement svgelt, SVGTextContent context, int charnum) {
        Point2D p2d = context.getEndPositionOfChar(charnum);
        if (p2d == null) throw svgelt.createDOMException
                             (DOMException.INDEX_SIZE_ERR, "",null);
        return p2d;
    }

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#selectSubString(int charnum, int nchars)}.
     */
    public static void selectSubString(Element elt, int charnum, int nchars){

        final SVGOMElement svgelt = (SVGOMElement)elt;

        if ( (charnum < 0) || 
             (charnum >= getNumberOfChars(elt)) ){
            throw svgelt.createDOMException
                (DOMException.INDEX_SIZE_ERR,
                 "",null);
        }
        
        final SVGTextContent context = (SVGTextContent)svgelt.getSVGContext();

        context.selectSubString(charnum, nchars);
    }

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#getRotationOfChar(int charnum)}.
     */
    public static float getRotationOfChar(Element elt, final int charnum ) {
        final SVGOMElement svgelt = (SVGOMElement)elt;

        if ( (charnum < 0) || 
             (charnum >= getNumberOfChars(elt)) ){
            throw svgelt.createDOMException
                (DOMException.INDEX_SIZE_ERR,
                 "",null);
        }
        
        final SVGTextContent context = (SVGTextContent)svgelt.getSVGContext();
        
        return context.getRotationOfChar(charnum);
    }

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#selectSubString(int charnum, int nchars)}.
     */
    public static float getComputedTextLength(Element elt){

        final SVGOMElement svgelt = (SVGOMElement)elt;

        final SVGTextContent context = (SVGTextContent)svgelt.getSVGContext();

        return context.getComputedTextLength();
    }

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#selectSubString(int charnum, int nchars)}.
     */
    public static float getSubStringLength(Element elt, int charnum, int nchars){

        final SVGOMElement svgelt = (SVGOMElement)elt;

        if ( (charnum < 0) || 
             (charnum >= getNumberOfChars(elt)) ){
            throw svgelt.createDOMException
                (DOMException.INDEX_SIZE_ERR,
                 "",null);
        }
        
        final SVGTextContent context = (SVGTextContent)svgelt.getSVGContext();

        return context.getSubStringLength(charnum,nchars);
    }

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGTextContentElement#getCharNumAtPosition(SVGPoint point)}.
     */
    public static int getCharNumAtPosition(Element elt, final float x, final float y) throws DOMException {

        final SVGOMElement svgelt = (SVGOMElement)elt;

        final SVGTextContent context = (SVGTextContent)svgelt.getSVGContext();
        
        return context.getCharNumAtPosition(x,y);
    }

    public static class SVGTextPoint extends SVGOMPoint {
        SVGOMElement svgelt;
        SVGTextPoint(SVGOMElement elem) {
            svgelt = elem;
        }
        public void setX(float x) throws DOMException {
            throw svgelt.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.point", null);
        }
        public void setY(float y) throws DOMException {
            throw svgelt.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.point", null);
        }
    }
}
