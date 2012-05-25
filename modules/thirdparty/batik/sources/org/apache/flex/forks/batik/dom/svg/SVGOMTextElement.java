/*

   Copyright 2000-2004  The Apache Software Foundation 

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
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLengthList;
import org.w3c.flex.forks.dom.svg.SVGAnimatedTransformList;
import org.w3c.flex.forks.dom.svg.SVGElement;
import org.w3c.flex.forks.dom.svg.SVGException;
import org.w3c.flex.forks.dom.svg.SVGMatrix;
import org.w3c.flex.forks.dom.svg.SVGRect;
import org.w3c.flex.forks.dom.svg.SVGTextElement;

/**
 * This class implements {@link SVGTextElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMTextElement.java,v 1.13 2004/08/18 07:13:18 vhardy Exp $
 */
public class SVGOMTextElement
    extends    SVGOMTextPositioningElement
    implements SVGTextElement {

    // Default values for attributes on a text element
    public static final String X_DEFAULT_VALUE = "0";
    public static final String Y_DEFAULT_VALUE = "0";

    /**
     * Creates a new SVGOMTextElement object.
     */
    protected SVGOMTextElement() {
    }

    /**
     * Creates a new SVGOMTextElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMTextElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_TEXT_TAG;
    }

    // SVGLocatable support /////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getNearestViewportElement()}.
     */
    public SVGElement getNearestViewportElement() {
	return SVGLocatableSupport.getNearestViewportElement(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getFarthestViewportElement()}.
     */
    public SVGElement getFarthestViewportElement() {
	return SVGLocatableSupport.getFarthestViewportElement(this);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.flex.forks.dom.svg.SVGLocatable#getBBox()}.
     */
    public SVGRect getBBox() {
	return SVGLocatableSupport.getBBox(this);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.flex.forks.dom.svg.SVGLocatable#getCTM()}.
     */
    public SVGMatrix getCTM() {
	return SVGLocatableSupport.getCTM(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getScreenCTM()}.
     */
    public SVGMatrix getScreenCTM() {
	return SVGLocatableSupport.getScreenCTM(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getTransformToElement(SVGElement)}.
     */
    public SVGMatrix getTransformToElement(SVGElement element)
	throws SVGException {
	return SVGLocatableSupport.getTransformToElement(this, element);
    }

    // SVGTransformable support /////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTransformable#getTransform()}.
     */
    public SVGAnimatedTransformList getTransform() {
	return SVGTransformableSupport.getTransform(this);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMTextElement();
    }

    // SVGTextPositioningElement support ////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextPositioningElement#getX()}.
     */
    public SVGAnimatedLengthList getX() {
        SVGOMAnimatedLengthList result = (SVGOMAnimatedLengthList)
            getLiveAttributeValue(null, SVGConstants.SVG_X_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedLengthList(this, null,
                                                 SVGConstants.SVG_X_ATTRIBUTE,
                                                 X_DEFAULT_VALUE,
                                                 AbstractSVGLength.HORIZONTAL_LENGTH);
            putLiveAttributeValue(null,
                                  SVGConstants.SVG_X_ATTRIBUTE, result);
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextPositioningElement#getY()}.
     */
    public SVGAnimatedLengthList getY() {
        SVGOMAnimatedLengthList result = (SVGOMAnimatedLengthList)
            getLiveAttributeValue(null, SVGConstants.SVG_Y_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedLengthList(this, null,
                                                 SVGConstants.SVG_Y_ATTRIBUTE,
                                                 Y_DEFAULT_VALUE,
                                                 AbstractSVGLength.VERTICAL_LENGTH);
            putLiveAttributeValue(null,
                                  SVGConstants.SVG_Y_ATTRIBUTE, result);
        }
        return result;
    }
}
