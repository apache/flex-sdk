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
import org.w3c.dom.svg.SVGFESpecularLightingElement;

/**
 * This class implements {@link SVGFESpecularLightingElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFESpecularLightingElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMFESpecularLightingElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFESpecularLightingElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMFilterPrimitiveStandardAttributes.xmlTraitInformation);
        t.put(null, SVG_IN_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_CDATA));
        t.put(null, SVG_SURFACE_SCALE_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        t.put(null, SVG_SPECULAR_CONSTANT_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        t.put(null, SVG_SPECULAR_EXPONENT_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        xmlTraitInformation = t;
    }

    /**
     * The 'in' attribute value.
     */
    protected SVGOMAnimatedString in;

    /**
     * The 'surfaceScale' attribute value.
     */
    protected SVGOMAnimatedNumber surfaceScale;

    /**
     * The 'specularConstant' attribute value.
     */
    protected SVGOMAnimatedNumber specularConstant;

    /**
     * The 'specularExponent' attribute value.
     */
    protected SVGOMAnimatedNumber specularExponent;

    /**
     * Creates a new SVGOMFESpecularLightingElement object.
     */
    protected SVGOMFESpecularLightingElement() {
    }

    /**
     * Creates a new SVGOMFESpecularLightingElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFESpecularLightingElement(String prefix,
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
        surfaceScale =
            createLiveAnimatedNumber(null, SVG_SURFACE_SCALE_ATTRIBUTE, 1f);
        specularConstant =
            createLiveAnimatedNumber(null, SVG_SPECULAR_CONSTANT_ATTRIBUTE, 1f);
        specularExponent =
            createLiveAnimatedNumber(null, SVG_SPECULAR_EXPONENT_ATTRIBUTE, 1f);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_SPECULAR_LIGHTING_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFESpecularLightingElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return in;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFESpecularLightingElement#getSurfaceScale()}.
     */
    public SVGAnimatedNumber getSurfaceScale() {
        return surfaceScale;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFESpecularLightingElement#getSpecularConstant()}.
     */
    public SVGAnimatedNumber getSpecularConstant() {
        return specularConstant;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFESpecularLightingElement#getSpecularExponent()}.
     */
    public SVGAnimatedNumber getSpecularExponent() {
        return specularExponent;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFESpecularLightingElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
