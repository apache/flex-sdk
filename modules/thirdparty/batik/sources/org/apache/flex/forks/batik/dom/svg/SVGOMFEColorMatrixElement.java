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
import org.w3c.dom.svg.SVGAnimatedNumberList;
import org.w3c.dom.svg.SVGAnimatedString;
import org.w3c.dom.svg.SVGFEColorMatrixElement;

/**
 * This class implements {@link SVGFEColorMatrixElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEColorMatrixElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMFEColorMatrixElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEColorMatrixElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMFilterPrimitiveStandardAttributes.xmlTraitInformation);
        t.put(null, SVG_IN_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_CDATA));
        t.put(null, SVG_TYPE_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_VALUES_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_LIST));
        xmlTraitInformation = t;
    }

    /**
     * The 'type' attribute values.
     */
    protected static final String[] TYPE_VALUES = {
        "",
        SVG_MATRIX_VALUE,
        SVG_SATURATE_VALUE,
        SVG_HUE_ROTATE_VALUE,
        SVG_LUMINANCE_TO_ALPHA_VALUE
    };

    /**
     * The 'in' attribute value.
     */
    protected SVGOMAnimatedString in;

    /**
     * The 'type' attribute value.
     */
    protected SVGOMAnimatedEnumeration type;

//     /**
//      * The 'values' attribute value.
//      */
//     protected SVGOMAnimatedNumberList values;

    /**
     * Creates a new SVGOMFEColorMatrixElement object.
     */
    protected SVGOMFEColorMatrixElement() {
    }

    /**
     * Creates a new SVGOMFEColorMatrixElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEColorMatrixElement(String prefix, AbstractDocument owner) {
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
        type =
            createLiveAnimatedEnumeration
                (null, SVG_TYPE_ATTRIBUTE, TYPE_VALUES, (short) 1);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_COLOR_MATRIX_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEColorMatrixElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return in;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEColorMatrixElement#getType()}.
     */
    public SVGAnimatedEnumeration getType() {
        return type;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFEColorMatrixElement#getValues()}.
     */
    public SVGAnimatedNumberList getValues() {
        throw new UnsupportedOperationException
            ("SVGFEColorMatrixElement.getValues is not implemented"); // XXX
        // return values;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEColorMatrixElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
