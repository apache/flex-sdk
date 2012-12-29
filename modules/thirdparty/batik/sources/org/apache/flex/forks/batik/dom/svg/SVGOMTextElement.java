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

import org.apache.flex.forks.batik.anim.values.AnimatableMotionPointValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGAnimatedTransformList;
import org.w3c.dom.svg.SVGElement;
import org.w3c.dom.svg.SVGException;
import org.w3c.dom.svg.SVGMatrix;
import org.w3c.dom.svg.SVGRect;
import org.w3c.dom.svg.SVGTextElement;

/**
 * This class implements {@link SVGTextElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMTextElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMTextElement
    extends    SVGOMTextPositioningElement
    implements SVGTextElement,
               SVGMotionAnimatableElement {

    // Default values for attributes on a text element
    protected static final String X_DEFAULT_VALUE = "0";
    protected static final String Y_DEFAULT_VALUE = "0";

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMTextPositioningElement.xmlTraitInformation);
        t.put(null, SVG_TRANSFORM_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_TRANSFORM_LIST));
        xmlTraitInformation = t;
    }

    /**
     * The 'transform' attribute value.
     */
    protected SVGOMAnimatedTransformList transform;

    /**
     * Supplemental transformation due to motion animation.
     */
    protected AffineTransform motionTransform;

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
        transform =
            createLiveAnimatedTransformList(null, SVG_TRANSFORM_ATTRIBUTE, "");
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
     * org.w3c.dom.svg.SVGLocatable#getNearestViewportElement()}.
     */
    public SVGElement getNearestViewportElement() {
        return SVGLocatableSupport.getNearestViewportElement(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGLocatable#getFarthestViewportElement()}.
     */
    public SVGElement getFarthestViewportElement() {
        return SVGLocatableSupport.getFarthestViewportElement(this);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.svg.SVGLocatable#getBBox()}.
     */
    public SVGRect getBBox() {
        return SVGLocatableSupport.getBBox(this);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.svg.SVGLocatable#getCTM()}.
     */
    public SVGMatrix getCTM() {
        return SVGLocatableSupport.getCTM(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGLocatable#getScreenCTM()}.
     */
    public SVGMatrix getScreenCTM() {
        return SVGLocatableSupport.getScreenCTM(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGLocatable#getTransformToElement(SVGElement)}.
     */
    public SVGMatrix getTransformToElement(SVGElement element)
        throws SVGException {
        return SVGLocatableSupport.getTransformToElement(this, element);
    }

    // SVGTransformable support /////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTransformable#getTransform()}.
     */
    public SVGAnimatedTransformList getTransform() {
        return transform;
    }

    /**
     * Returns the default value of the 'x' attribute.
     */
    protected String getDefaultXValue() {
        return X_DEFAULT_VALUE;
    }

    /**
     * Returns the default value of the 'y' attribute.
     */
    protected String getDefaultYValue() {
        return Y_DEFAULT_VALUE;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMTextElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }

    // SVGMotionAnimatableElement ////////////////////////////////////////////

    /**
     * Returns the {@link AffineTransform} representing the current motion
     * animation for this element.
     */
    public AffineTransform getMotionTransform() {
        return motionTransform;
    }

    // AnimationTarget ///////////////////////////////////////////////////////

    /**
     * Updates a 'other' animation value in this target.
     */
    public void updateOtherValue(String type, AnimatableValue val) {
        if (type.equals("motion")) {
            if (motionTransform == null) {
                motionTransform = new AffineTransform();
            }
            if (val == null) {
                motionTransform.setToIdentity();
            } else {
                AnimatableMotionPointValue p = (AnimatableMotionPointValue) val;
                motionTransform.setToTranslation(p.getX(), p.getY());
                motionTransform.rotate(p.getAngle());
            }
            SVGOMDocument d = (SVGOMDocument) ownerDocument;
            d.getAnimatedAttributeListener().otherAnimationChanged(this, type);
        } else {
            super.updateOtherValue(type, val);
        }
    }
}
