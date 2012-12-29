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
import org.w3c.dom.svg.SVGAnimatedLength;
import org.w3c.dom.svg.SVGMaskElement;

/**
 * This class implements {@link org.w3c.dom.svg.SVGMaskElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMMaskElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMMaskElement
    extends    SVGGraphicsElement
    implements SVGMaskElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGGraphicsElement.xmlTraitInformation);
        t.put(null, SVG_X_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_Y_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_WIDTH_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_HEIGHT_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_MASK_UNITS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_MASK_CONTENT_UNITS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        xmlTraitInformation = t;
    }

    /**
     * The units values.
     */
    protected static final String[] UNITS_VALUES = {
        "",
        SVG_USER_SPACE_ON_USE_VALUE,
        SVG_OBJECT_BOUNDING_BOX_VALUE
    };

    /**
     * The 'x' attribute value.
     */
    protected SVGOMAnimatedLength x;

    /**
     * The 'y' attribute value.
     */
    protected SVGOMAnimatedLength y;

    /**
     * The 'width' attribute value.
     */
    protected SVGOMAnimatedLength width;

    /**
     * The 'height' attribute value.
     */
    protected SVGOMAnimatedLength height;

    /**
     * The 'maskUnits' attribute value.
     */
    protected SVGOMAnimatedEnumeration maskUnits;

    /**
     * The 'maskContentUnits' attribute value.
     */
    protected SVGOMAnimatedEnumeration maskContentUnits;

    /**
     * Creates a new SVGOMMaskElement object.
     */
    protected SVGOMMaskElement() {
    }

    /**
     * Creates a new SVGOMMaskElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMMaskElement(String prefix, AbstractDocument owner) {
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
        x = createLiveAnimatedLength
            (null, SVG_X_ATTRIBUTE, SVG_MASK_X_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH, false);
        y = createLiveAnimatedLength
            (null, SVG_Y_ATTRIBUTE, SVG_MASK_Y_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH, false);
        width =
            createLiveAnimatedLength
                (null, SVG_WIDTH_ATTRIBUTE, SVG_MASK_WIDTH_DEFAULT_VALUE,
                 SVGOMAnimatedLength.HORIZONTAL_LENGTH, true);
        height =
            createLiveAnimatedLength
                (null, SVG_HEIGHT_ATTRIBUTE, SVG_MASK_WIDTH_DEFAULT_VALUE,
                 SVGOMAnimatedLength.VERTICAL_LENGTH, true);
        maskUnits =
            createLiveAnimatedEnumeration
                (null, SVG_MASK_UNITS_ATTRIBUTE, UNITS_VALUES, (short) 2);
        maskContentUnits =
            createLiveAnimatedEnumeration
                (null, SVG_MASK_CONTENT_UNITS_ATTRIBUTE, UNITS_VALUES,
                 (short) 1);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_MASK_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getMaskUnits()}.
     */
    public SVGAnimatedEnumeration getMaskUnits() {
        return maskUnits;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getMaskContentUnits()}.
     */
    public SVGAnimatedEnumeration getMaskContentUnits() {
        return maskContentUnits;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getX()}.
     */
    public SVGAnimatedLength getX() {
        return x;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getY()}.
     */
    public SVGAnimatedLength getY() {
        return y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getWidth()}.
     */
    public SVGAnimatedLength getWidth() {
        return width;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMaskElement#getHeight()}.
     */
    public SVGAnimatedLength getHeight() {
        return height;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMMaskElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
