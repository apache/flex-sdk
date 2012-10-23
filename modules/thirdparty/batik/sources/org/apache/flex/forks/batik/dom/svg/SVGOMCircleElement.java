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
import org.w3c.dom.svg.SVGAnimatedLength;
import org.w3c.dom.svg.SVGCircleElement;

/**
 * This class implements {@link SVGCircleElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMCircleElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMCircleElement
    extends    SVGGraphicsElement
    implements SVGCircleElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGGraphicsElement.xmlTraitInformation);
        t.put(null, SVG_CX_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, TraitInformation.PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_CY_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, TraitInformation.PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_R_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, TraitInformation.PERCENTAGE_VIEWPORT_SIZE));
        xmlTraitInformation = t;
    }

    /**
     * The 'cx' attribute value.
     */
    protected SVGOMAnimatedLength cx;

    /**
     * The 'cy' attribute value.
     */
    protected SVGOMAnimatedLength cy;

    /**
     * The 'r' attribute value.
     */
    protected SVGOMAnimatedLength r;

    /**
     * Creates a new SVGOMCircleElement object.
     */
    protected SVGOMCircleElement() {
    }

    /**
     * Creates a new SVGOMCircleElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMCircleElement(String prefix, AbstractDocument owner) {
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
        cx = createLiveAnimatedLength
            (null, SVG_CX_ATTRIBUTE, SVG_CIRCLE_CX_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH, false);
        cy = createLiveAnimatedLength
            (null, SVG_CY_ATTRIBUTE, SVG_CIRCLE_CY_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH, false);
        r = createLiveAnimatedLength
            (null, SVG_R_ATTRIBUTE, null, SVGOMAnimatedLength.OTHER_LENGTH,
             true);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_CIRCLE_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGCircleElement#getCx()}.
     */
    public SVGAnimatedLength getCx() {
        return cx;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGCircleElement#getCy()}.
     */
    public SVGAnimatedLength getCy() {
        return cy;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGCircleElement#getR()}.
     */
    public SVGAnimatedLength getR() {
        return r;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMCircleElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
