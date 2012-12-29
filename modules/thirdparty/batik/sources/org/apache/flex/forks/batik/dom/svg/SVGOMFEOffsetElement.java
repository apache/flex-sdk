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
import org.w3c.dom.svg.SVGFEOffsetElement;

/**
 * This class implements {@link SVGFEOffsetElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFEOffsetElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMFEOffsetElement
    extends    SVGOMFilterPrimitiveStandardAttributes
    implements SVGFEOffsetElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMFilterPrimitiveStandardAttributes.xmlTraitInformation);
        t.put(null, SVG_IN_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_CDATA));
        t.put(null, SVG_DX_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        t.put(null, SVG_DY_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER));
        xmlTraitInformation = t;
    }

    /**
     * The 'in' attribute value.
     */
    protected SVGOMAnimatedString in;

    /**
     * The 'dx' attribute value.
     */
    protected SVGOMAnimatedNumber dx;

    /**
     * The 'dy' attribute value.
     */
    protected SVGOMAnimatedNumber dy;

    /**
     * Creates a new SVGOMFEOffsetElement object.
     */
    protected SVGOMFEOffsetElement() {
    }

    /**
     * Creates a new SVGOMFEOffsetElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFEOffsetElement(String prefix, AbstractDocument owner) {
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
        dx = createLiveAnimatedNumber(null, SVG_DX_ATTRIBUTE, 0f);
        dy = createLiveAnimatedNumber(null, SVG_DY_ATTRIBUTE, 0f);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FE_OFFSET_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGFEOffsetElement#getIn1()}.
     */
    public SVGAnimatedString getIn1() {
        return in;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFEOffsetElement#getDx()}.
     */
    public SVGAnimatedNumber getDx() {
        return dx;
    } 

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFEOffsetElement#getDy()}.
     */
    public SVGAnimatedNumber getDy() {
        return dy;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFEOffsetElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
