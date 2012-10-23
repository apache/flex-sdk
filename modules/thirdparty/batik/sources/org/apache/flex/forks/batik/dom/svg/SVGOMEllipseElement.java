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
import org.w3c.dom.svg.SVGEllipseElement;

/**
 * This class implements {@link SVGEllipseElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMEllipseElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMEllipseElement
    extends    SVGGraphicsElement
    implements SVGEllipseElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGGraphicsElement.xmlTraitInformation);
        t.put(null, SVG_CX_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_CY_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_RX_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_RY_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
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
     * The 'rx' attribute value.
     */
    protected SVGOMAnimatedLength rx;

    /**
     * The 'ry' attribute value.
     */
    protected SVGOMAnimatedLength ry;

    /**
     * Creates a new SVGOMEllipseElement object.
     */
    protected SVGOMEllipseElement() {
    }

    /**
     * Creates a new SVGOMEllipseElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMEllipseElement(String prefix, AbstractDocument owner) {
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
            (null, SVG_CX_ATTRIBUTE, SVG_ELLIPSE_CX_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH, false);
        cy = createLiveAnimatedLength
            (null, SVG_CY_ATTRIBUTE, SVG_ELLIPSE_CY_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH, false);
        rx = createLiveAnimatedLength
            (null, SVG_RX_ATTRIBUTE, null,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH, true);
        ry = createLiveAnimatedLength
            (null, SVG_RY_ATTRIBUTE, null, SVGOMAnimatedLength.VERTICAL_LENGTH,
             true);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_ELLIPSE_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGEllipseElement#getCx()}.
     */
    public SVGAnimatedLength getCx() {
        return cx;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGEllipseElement#getCy()}.
     */
    public SVGAnimatedLength getCy() {
        return cy;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGEllipseElement#getRx()}.
     */
    public SVGAnimatedLength getRx() {
        return rx;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGEllipseElement#getRy()}.
     */
    public SVGAnimatedLength getRy() {
        return ry;
   }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMEllipseElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
