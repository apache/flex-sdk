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

import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;

import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGElement;
import org.w3c.dom.svg.SVGException;
import org.w3c.dom.svg.SVGFitToViewBox;
import org.w3c.dom.svg.SVGMatrix;
import org.w3c.dom.svg.SVGRect;

/**
 * This class provides support for the SVGLocatable interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGLocatableSupport.java 489964 2006-12-24 01:30:23Z cam $
 */
public class SVGLocatableSupport {

    /**
     * Creates a new SVGLocatable element.
     */
    public SVGLocatableSupport() {
    }
    
    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGLocatable#getNearestViewportElement()}.
     */
    public static SVGElement getNearestViewportElement(Element e) {
        Element elt = e;
        while (elt != null) {
            elt = SVGCSSEngine.getParentCSSStylableElement(elt);
            if (elt instanceof SVGFitToViewBox) {
                break;
            }
        }
        return (SVGElement)elt;
    }

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGLocatable#getFarthestViewportElement()}.
     */
    public static SVGElement getFarthestViewportElement(Element elt) {
        return (SVGElement)elt.getOwnerDocument().getDocumentElement();
    }

    /**
     * To implement {@link org.w3c.dom.svg.SVGLocatable#getBBox()}.
     */
    public static SVGRect getBBox(Element elt) {
        final SVGOMElement svgelt = (SVGOMElement)elt;
        SVGContext svgctx = svgelt.getSVGContext();
        if (svgctx == null) return null;
        if (svgctx.getBBox() == null) return null;

        return new SVGRect() {
                public float getX() {
                    return (float)svgelt.getSVGContext().getBBox().getX();
                }
                public void setX(float x) throws DOMException {
                    throw svgelt.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.rect", null);
                }
                public float getY() {
                    return (float)svgelt.getSVGContext().getBBox().getY();
                }
                public void setY(float y) throws DOMException {
                    throw svgelt.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.rect", null);
                }
                public float getWidth() {
                    return (float)svgelt.getSVGContext().getBBox().getWidth();
                }
                public void setWidth(float width) throws DOMException {
                    throw svgelt.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.rect", null);
                }
                public float getHeight() {
                    return (float)svgelt.getSVGContext().getBBox().getHeight();
                }
                public void setHeight(float height) throws DOMException {
                    throw svgelt.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.rect", null);
                }
            };
    }

    /**
     * To implement {@link org.w3c.dom.svg.SVGLocatable#getCTM()}.
     */
    public static SVGMatrix getCTM(Element elt) {
        final SVGOMElement svgelt = (SVGOMElement)elt;
        return new AbstractSVGMatrix() {
                protected AffineTransform getAffineTransform() {
                    return svgelt.getSVGContext().getCTM();
            }
        };
    }

    /**
     * To implement {@link org.w3c.dom.svg.SVGLocatable#getScreenCTM()}.
     */
    public static SVGMatrix getScreenCTM(Element elt) {
        final SVGOMElement svgelt  = (SVGOMElement)elt;
        return new AbstractSVGMatrix() {
                protected AffineTransform getAffineTransform() {
                    SVGContext context = svgelt.getSVGContext();
                    AffineTransform ret = context.getGlobalTransform();
                    AffineTransform scrnTrans = context.getScreenTransform();
                    if (scrnTrans != null)
                        ret.preConcatenate(scrnTrans);
                    return ret;
                }
            };
    }

    /**
     * To implement {@link
     * org.w3c.dom.svg.SVGLocatable#getTransformToElement(SVGElement)}.
     */
    public static SVGMatrix getTransformToElement(Element elt,
                                                  SVGElement element)
        throws SVGException {
        final SVGOMElement currentElt = (SVGOMElement)elt;
        final SVGOMElement targetElt = (SVGOMElement)element;
        return new AbstractSVGMatrix() {
                protected AffineTransform getAffineTransform() {
                    AffineTransform cat = 
                        currentElt.getSVGContext().getGlobalTransform();
                    if (cat == null) {
                        cat = new AffineTransform();
                    }
                    AffineTransform tat = 
                        targetElt.getSVGContext().getGlobalTransform();
                    if (tat == null) {
                        tat = new AffineTransform();
                    }
                    AffineTransform at = new AffineTransform(cat);
                    try {
                        at.preConcatenate(tat.createInverse());
                        return at;
                    } catch (NoninvertibleTransformException ex) {
                        throw currentElt.createSVGException
                            (SVGException.SVG_MATRIX_NOT_INVERTABLE,
                             "noninvertiblematrix",
                             null);
                    }
                }
            };
    }
}
