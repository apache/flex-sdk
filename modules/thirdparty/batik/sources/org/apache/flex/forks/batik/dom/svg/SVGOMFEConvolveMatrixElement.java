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
import org.w3c.dom.svg.SVGAnimatedBoolean;
import org.w3c.dom.svg.SVGAnimatedEnumeration;
import org.w3c.dom.svg.SVGAnimatedInteger;
import org.w3c.dom.svg.SVGAnimatedNumber;
import org.w3c.dom.svg.SVGAnimatedNumberList;
import org.w3c.dom.svg.SVGAnimatedString;
import org.w3c.dom.svg.SVGFEConvolveMatrixElement;

/**
 * This class implements {@link SVGFEConvolveMatrixElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEConvolveMatrixElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMFEConvolveMatrixElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEConvolveMatrixElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMFilterPrimitiveStandardAttributes.xmlTraitInformation);
        t.put(null, SVG_IN_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_CDATA));
        t.put(null, SVG_ORDER_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_OPTIONAL_NUMBER));
        t.put(null, SVG_KERNEL_UNIT_LENGTH_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_OPTIONAL_NUMBER));
        t.put(null, SVG_KERNEL_MATRIX_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_LIST));
        t.put(null, SVG_DIVISOR_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        t.put(null, SVG_BIAS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        t.put(null, SVG_TARGET_X_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_INTEGER));
        t.put(null, SVG_TARGET_Y_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_INTEGER));
        t.put(null, SVG_EDGE_MODE_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_PRESERVE_ALPHA_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_BOOLEAN));
        xmlTraitInformation = t;
    }

    /**
     * The 'edgeMode' attribute values.
     */
    protected static final String[] EDGE_MODE_VALUES = {
        "",
        SVG_DUPLICATE_VALUE,
        SVG_WRAP_VALUE,
        SVG_NONE_VALUE
    };

    /**
     * The 'in' attribute value.
     */
    protected SVGOMAnimatedString in;

    /**
     * The 'edgeMode' attribute value.
     */
    protected SVGOMAnimatedEnumeration edgeMode;

    /**
     * The 'bias' attribute value.
     */
    protected SVGOMAnimatedNumber bias;

    /**
     * The 'preserveAlpha' attribute value.
     */
    protected SVGOMAnimatedBoolean preserveAlpha;

    /**
     * Creates a new SVGOMFEConvolveMatrixElement object.
     */
    protected SVGOMFEConvolveMatrixElement() {
    }

    /**
     * Creates a new SVGOMFEConvolveMatrixElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEConvolveMatrixElement(String prefix,
                                        AbstractDocument owner) {
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
        edgeMode =
            createLiveAnimatedEnumeration
                (null, SVG_EDGE_MODE_ATTRIBUTE, EDGE_MODE_VALUES, (short) 1);
        bias = createLiveAnimatedNumber(null, SVG_BIAS_ATTRIBUTE, 0f);
        preserveAlpha =
            createLiveAnimatedBoolean
                (null, SVG_PRESERVE_ALPHA_ATTRIBUTE, false);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_CONVOLVE_MATRIX_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return in;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getEdgeMode()}.
     */
    public SVGAnimatedEnumeration getEdgeMode() {
        return edgeMode;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getKernelMatrix()}.
     */
    public SVGAnimatedNumberList getKernelMatrix() {
        throw new UnsupportedOperationException
            ("SVGFEConvolveMatrixElement.getKernelMatrix is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getOrderX()}.
     */
    public SVGAnimatedInteger getOrderX() {
        throw new UnsupportedOperationException
            ("SVGFEConvolveMatrixElement.getOrderX is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getOrderY()}.
     */
    public SVGAnimatedInteger getOrderY() {
        throw new UnsupportedOperationException
            ("SVGFEConvolveMatrixElement.getOrderY is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getTargetX()}.
     */
    public SVGAnimatedInteger getTargetX() {
        // Default value relative to orderX...
        throw new UnsupportedOperationException
            ("SVGFEConvolveMatrixElement.getTargetX is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getTargetY()}.
     */
    public SVGAnimatedInteger getTargetY() {
        // Default value relative to orderY...
        throw new UnsupportedOperationException
            ("SVGFEConvolveMatrixElement.getTargetY is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEConvolveMatrixElement#getDivisor()}.
     */
    public SVGAnimatedNumber getDivisor() {
        // Default value relative to kernel matrix...
        throw new UnsupportedOperationException
            ("SVGFEConvolveMatrixElement.getDivisor is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFEConvolveMatrixElement#getBias()}.
     */
    public SVGAnimatedNumber getBias() {
        return bias;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFEConvolveMatrixElement#getKernelUnitLengthX()}.
     */
    public SVGAnimatedNumber getKernelUnitLengthX() {
        throw new UnsupportedOperationException
            ("SVGFEConvolveMatrixElement.getKernelUnitLengthX is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFEConvolveMatrixElement#getKernelUnitLengthY()}.
     */
    public SVGAnimatedNumber getKernelUnitLengthY() {
        throw new UnsupportedOperationException
            ("SVGFEConvolveMatrixElement.getKernelUnitLengthY is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFEConvolveMatrixElement#getPreserveAlpha()}.
     */
    public SVGAnimatedBoolean getPreserveAlpha() {
        return preserveAlpha;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEConvolveMatrixElement();
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
//             if (ln.equals(SVG_ORDER_ATTRIBUTE)) {
//                 if (val == null) {
//                 // XXX Needs testing.
//                     updateIntegerAttributeValue(getOrderX(), null);
//                     updateIntegerAttributeValue(getOrderY(), null);
//                 } else {
//                     AnimatableNumberOptionalNumberValue anonv =
//                         (AnimatableNumberOptionalNumberValue) val;
//                     SVGOMAnimatedInteger ai =
//                         (SVGOMAnimatedInteger) getOrderX();
//                     ai.setAnimatedValue(Math.round(anonv.getNumber()));
//                     ai = (SVGOMAnimatedInteger) getOrderY();
//                     if (anonv.hasOptionalNumber()) {
//                         ai.setAnimatedValue
//                             (Math.round(anonv.getOptionalNumber()));
//                     } else {
//                         ai.setAnimatedValue(Math.round(anonv.getNumber()));
//                     }
//                 }
//                 return;
//             } else if (ln.equals(SVG_KERNEL_UNIT_LENGTH_ATTRIBUTE)) {
//                 // XXX Needs testing.
//                 if (val == null) {
//                     updateNumberAttributeValue(getKernelUnitLengthX(), null);
//                     updateNumberAttributeValue(getKernelUnitLengthY(), null);
//                 } else {
//                     AnimatableNumberOptionalNumberValue anonv =
//                         (AnimatableNumberOptionalNumberValue) val;
//                     SVGOMAnimatedNumber an =
//                         (SVGOMAnimatedNumber) getKernelUnitLengthX();
//                     an.setAnimatedValue(anonv.getNumber());
//                     an = (SVGOMAnimatedNumber) getKernelUnitLengthY();
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
//             if (ln.equals(SVG_KERNEL_UNIT_LENGTH_ATTRIBUTE)) {
//                 return getBaseValue(getKernelUnitLengthX(),
//                                     getKernelUnitLengthY());
//             } else if (ln.equals(SVG_ORDER_ATTRIBUTE)) {
//                 return getBaseValue(getOrderX(), getOrderY());
//             }
//         }
//         return super.getUnderlyingValue(ns, ln);
//     }
}
