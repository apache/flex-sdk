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
import org.w3c.dom.svg.SVGFontElement;

/**
 * This class implements {@link SVGFontElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFontElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMFontElement
    extends    SVGStylableElement
    implements SVGFontElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGStylableElement.xmlTraitInformation);
        t.put(null, SVG_EXTERNAL_RESOURCES_REQUIRED_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_BOOLEAN));
//         t.put(null, SVG_HORIZ_ORIGIN_X_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         t.put(null, SVG_HORIZ_ORIGIN_Y_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         t.put(null, SVG_HORIZ_ADV_X_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         t.put(null, SVG_VERT_ORIGIN_X_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         t.put(null, SVG_VERT_ORIGIN_Y_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         t.put(null, SVG_VERT_ADV_Y_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
        xmlTraitInformation = t;
    }

    /**
     * The 'externalResourcesRequired' attribute value.
     */
    protected SVGOMAnimatedBoolean externalResourcesRequired;

    /**
     * Creates a new SVGOMFontElement object.
     */
    protected SVGOMFontElement() {
    }

    /**
     * Creates a new SVGOMFontElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFontElement(String prefix, AbstractDocument owner) {
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
        externalResourcesRequired =
            createLiveAnimatedBoolean
                (null, SVG_EXTERNAL_RESOURCES_REQUIRED_ATTRIBUTE, false);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FONT_TAG;
    }

    // SVGExternalResourcesRequired support /////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGExternalResourcesRequired#getExternalResourcesRequired()}.
     */
    public SVGAnimatedBoolean getExternalResourcesRequired() {
        return externalResourcesRequired;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFontElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
