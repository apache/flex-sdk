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

import org.w3c.dom.svg.SVGAnimatedLengthList;
import org.w3c.dom.svg.SVGAnimatedNumberList;
import org.w3c.dom.svg.SVGTextPositioningElement;

/**
 * This class implements {@link org.w3c.dom.svg.SVGTextPositioningElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMTextPositioningElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public abstract class SVGOMTextPositioningElement
    extends    SVGOMTextContentElement
    implements SVGTextPositioningElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMTextContentElement.xmlTraitInformation);
        t.put(null, SVG_X_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH_LIST, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_Y_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH_LIST, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_DX_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH_LIST, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_DY_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH_LIST, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_ROTATE_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_LIST));
        xmlTraitInformation = t;
    }

    /**
     * The 'x' attribute value.
     */
    protected SVGOMAnimatedLengthList x;

    /**
     * The 'y' attribute value.
     */
    protected SVGOMAnimatedLengthList y;

    /**
     * The 'dx' attribute value.
     */
    protected SVGOMAnimatedLengthList dx;

    /**
     * The 'dy' attribute value.
     */
    protected SVGOMAnimatedLengthList dy;

    /**
     * The 'rotate' attribute value.
     */
    protected SVGOMAnimatedNumberList rotate;

    /**
     * Creates a new SVGOMTextPositioningElement object.
     */
    protected SVGOMTextPositioningElement() {
    }

    /**
     * Creates a new SVGOMTextPositioningElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGOMTextPositioningElement(String prefix,
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
        x = createLiveAnimatedLengthList
            (null, SVG_X_ATTRIBUTE, getDefaultXValue(), true,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
        y = createLiveAnimatedLengthList
            (null, SVG_Y_ATTRIBUTE, getDefaultYValue(), true,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
        dx = createLiveAnimatedLengthList
            (null, SVG_DX_ATTRIBUTE, "", true,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
        dy = createLiveAnimatedLengthList
            (null, SVG_DY_ATTRIBUTE, "", true,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
        rotate =
            createLiveAnimatedNumberList(null, SVG_ROTATE_ATTRIBUTE, "", true);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getX()}.
     */
    public SVGAnimatedLengthList getX() {
        return x;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getY()}.
     */
    public SVGAnimatedLengthList getY() {
        return y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getDx()}.
     */
    public SVGAnimatedLengthList getDx() {
        return dx;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getDy()}.
     */
    public SVGAnimatedLengthList getDy() {
        return dy;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getRotate()}.
     */
    public SVGAnimatedNumberList getRotate() {
        return rotate;
    }

    /**
     * Returns the default value of the 'x' attribute.
     */
    protected String getDefaultXValue() {
        return "";
    }

    /**
     * Returns the default value of the 'y' attribute.
     */
    protected String getDefaultYValue() {
        return "";
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
