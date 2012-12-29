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
import org.w3c.dom.svg.SVGAnimatedEnumeration;
import org.w3c.dom.svg.SVGAnimatedInteger;
import org.w3c.dom.svg.SVGAnimatedNumber;
import org.w3c.dom.svg.SVGFETurbulenceElement;

/**
 * This class implements {@link SVGFETurbulenceElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFETurbulenceElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMFETurbulenceElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFETurbulenceElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMFilterPrimitiveStandardAttributes.xmlTraitInformation);
        t.put(null, SVG_BASE_FREQUENCY_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_OPTIONAL_NUMBER));
        t.put(null, SVG_NUM_OCTAVES_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_INTEGER));
        t.put(null, SVG_SEED_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        t.put(null, SVG_STITCH_TILES_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_TYPE_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        xmlTraitInformation = t;
    }

    /**
     * The 'stitchTiles' attribute values.
     */
    protected static final String[] STITCH_TILES_VALUES = {
        "",
        SVG_STITCH_VALUE,
        SVG_NO_STITCH_VALUE
    };

    /**
     * The 'type' attribute values.
     */
    protected static final String[] TYPE_VALUES = {
        "",
        SVG_FRACTAL_NOISE_VALUE,
        SVG_TURBULENCE_VALUE
    };

    /**
     * The 'numOctaves' attribute value.
     */
    protected SVGOMAnimatedInteger numOctaves;

    /**
     * The 'seed' attribute value.
     */
    protected SVGOMAnimatedNumber seed;

    /**
     * The 'stitchTiles' attribute value.
     */
    protected SVGOMAnimatedEnumeration stitchTiles;

    /**
     * The 'type' attribute value.
     */
    protected SVGOMAnimatedEnumeration type;

    /**
     * Creates a new SVGOMFETurbulence object.
     */
    protected SVGOMFETurbulenceElement() {
    }

    /**
     * Creates a new SVGOMFETurbulenceElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFETurbulenceElement(String prefix,
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
        numOctaves =
            createLiveAnimatedInteger(null, SVG_NUM_OCTAVES_ATTRIBUTE, 1);
        seed = createLiveAnimatedNumber(null, SVG_SEED_ATTRIBUTE, 0f);
        stitchTiles =
            createLiveAnimatedEnumeration
                (null, SVG_STITCH_TILES_ATTRIBUTE, STITCH_TILES_VALUES,
                 (short) 2);
        type =
            createLiveAnimatedEnumeration
                (null, SVG_TYPE_ATTRIBUTE, TYPE_VALUES, (short) 2);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_TURBULENCE_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFETurbulenceElement#getBaseFrequencyX()}.
     */
    public SVGAnimatedNumber getBaseFrequencyX() {
        throw new UnsupportedOperationException
            ("SVGFETurbulenceElement.getBaseFrequencyX is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFETurbulenceElement#getBaseFrequencyY()}.
     */
    public SVGAnimatedNumber getBaseFrequencyY() {
        throw new UnsupportedOperationException
            ("SVGFETurbulenceElement.getBaseFrequencyY is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFETurbulenceElement#getNumOctaves()}.
     */
    public SVGAnimatedInteger getNumOctaves() {
        return numOctaves;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFETurbulenceElement#getSeed()}.
     */
    public SVGAnimatedNumber getSeed() {
        return seed;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFETurbulenceElement#getStitchTiles()}.
     */
    public SVGAnimatedEnumeration getStitchTiles() {
        return stitchTiles;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFETurbulenceElement#getType()}.
     */
    public SVGAnimatedEnumeration getType() {
        return type;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFETurbulenceElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }

    // AnimationTarget ///////////////////////////////////////////////////////

// XXX TBD
//     /**
//      * Updates an attribute value in this target.
//      */
//     public void updateAttributeValue(String ns, String ln,
//                                      AnimatableValue val) {
//         if (ns == null) {
//             if (ln.equals(SVG_BASE_FREQUENCY_ATTRIBUTE)) {
//                 // XXX Needs testing.
//                 if (val == null) {
//                     updateNumberAttributeValue(getBaseFrequencyX(), null);
//                     updateNumberAttributeValue(getBaseFrequencyY(), null);
//                 } else {
//                     AnimatableNumberOptionalNumberValue anonv =
//                         (AnimatableNumberOptionalNumberValue) val;
//                     SVGOMAnimatedNumber an =
//                         (SVGOMAnimatedNumber) getBaseFrequencyX();
//                     an.setAnimatedValue(anonv.getNumber());
//                     an = (SVGOMAnimatedNumber) getBaseFrequencyY();
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
//             if (ln.equals(SVG_BASE_FREQUENCY_ATTRIBUTE)) {
//                 return getBaseValue(getBaseFrequencyX(), getBaseFrequencyY());
//             }
//         }
//         return super.getUnderlyingValue(ns, ln);
//     }
}
