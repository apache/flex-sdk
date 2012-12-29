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
import org.w3c.dom.svg.SVGAnimatedString;
import org.w3c.dom.svg.SVGFEGaussianBlurElement;

/**
 * This class implements {@link SVGFEGaussianBlurElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEGaussianBlurElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMFEGaussianBlurElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEGaussianBlurElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMFilterPrimitiveStandardAttributes.xmlTraitInformation);
        t.put(null, SVG_IN_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_CDATA));
        t.put(null, SVG_STD_DEVIATION_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_OPTIONAL_NUMBER));
        xmlTraitInformation = t;
    }

    /**
     * The 'in' attribute value.
     */
    protected SVGOMAnimatedString in;

    /**
     * Creates a new SVGOMFEGaussianBlurElement object.
     */
    protected SVGOMFEGaussianBlurElement() {
    }

    /**
     * Creates a new SVGOMFEGaussianBlurElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEGaussianBlurElement(String prefix, AbstractDocument owner) {
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
        in = createLiveAnimatedString(null, SVG_IN_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_GAUSSIAN_BLUR_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEGaussianBlurElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return in;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEGaussianBlurElement#getStdDeviationX()}.
     */
    public SVGAnimatedNumber getStdDeviationX() {
        throw new UnsupportedOperationException
            ("SVGFEGaussianBlurElement.getStdDeviationX is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEGaussianBlurElement#getStdDeviationY()}.
     */
    public SVGAnimatedNumber getStdDeviationY() {
        throw new UnsupportedOperationException
            ("SVGFEGaussianBlurElement.getStdDeviationY is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEGaussianBlurElement#setStdDeviation(float,float)}.
     */
    public void setStdDeviation(float devX, float devY) {
        setAttributeNS(null, SVG_STD_DEVIATION_ATTRIBUTE,
                       Float.toString(devX) + " " + Float.toString(devY));
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEGaussianBlurElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }

    // AnimationTarget ///////////////////////////////////////////////////////

// XXX TBD
//
//     /**
//      * Updates an attribute value in this target.
//      */
//     public void updateAttributeValue(String ns, String ln,
//                                      AnimatableValue val) {
//         if (ns == null) {
//             if (ln.equals(SVG_STD_DEVIATION_ATTRIBUTE)) {
//                 // XXX Needs testing.
//                 if (val == null) {
//                     updateNumberAttributeValue(getStdDeviationX(), null);
//                     updateNumberAttributeValue(getStdDeviationY(), null);
//                 } else {
//                     AnimatableNumberOptionalNumberValue anonv =
//                         (AnimatableNumberOptionalNumberValue) val;
//                     SVGOMAnimatedNumber an =
//                         (SVGOMAnimatedNumber) getStdDeviationX();
//                     an.setAnimatedValue(anonv.getNumber());
//                     an = (SVGOMAnimatedNumber) getStdDeviationY();
//                     if (anonv.hasOptionalNumber()) {
//                         an.setAnimatedValue(anonv.getOptionalNumber());
//                     } else {
//                         an.setAnimatedValue(anonv.getNumber());
//                     }
//                 }
//                 return;
//             }
//         }
//         super.updateAttributeValue(ns, ln, val);
//     }
// 
//     /**
//      * Returns the underlying value of an animatable XML attribute.
//      */
//     public AnimatableValue getUnderlyingValue(String ns, String ln) {
//         if (ns == null) {
//             if (ln.equals(SVG_STD_DEVIATION_ATTRIBUTE)) {
//                 return getBaseValue(getStdDeviationX(), getStdDeviationY());
//             }
//         }
//         return super.getUnderlyingValue(ns, ln);
//     }
}
