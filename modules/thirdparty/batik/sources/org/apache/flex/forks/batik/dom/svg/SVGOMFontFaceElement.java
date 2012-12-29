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
import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGFontFaceElement;

/**
 * This class implements {@link SVGFontFaceElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFontFaceElement.java 489964 2006-12-24 01:30:23Z cam $
 */
public class SVGOMFontFaceElement
    extends    SVGOMElement
    implements SVGFontFaceElement {

//     /**
//      * Table mapping XML attribute names to TraitInformation objects.
//      */
//     protected static DoublyIndexedTable xmlTraitInformation;
//     static {
//         DoublyIndexedTable t = new DoublyIndexedTable(SVGOMElement.xmlTraitInformation);
//         t.put(null, SVG_FONT_FAMILY_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_FONT_STYLE_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_FONT_VARIANT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_FONT_WEIGHT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_FONT_STRETCH_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_FONT_SIZE_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_UNICODE_RANGE_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_UNITS_PER_EM_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_PANOSE_1_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_STEMV_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_STEMH_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_SLOPE_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_CAP_HEIGHT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_X_HEIGHT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_ACCENT_HEIGHT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_ASCENT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_DESCENT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_WIDTHS_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_BBOX_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_IDEOGRAPHIC_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_ALPHABETIC_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_MATHEMATICAL_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_HANGING_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_V_IDEOGRAPHIC_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_V_ALPHABETIC_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_V_MATHEMATICAL_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_V_HANGING_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_UNDERLINE_POSITION_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_UNDERLINE_THICKNESS_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_STRIKETHROUGH_POSITION_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_STRIKETHROUGH_THICKNESS_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_OVERLINE_POSITION_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_OVERLINE_THICKNESS_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         xmlTraitInformation = t;
//     }

    /**
     * Creates a new SVGOMFontFaceElement object.
     */
    protected SVGOMFontFaceElement() {
    }

    /**
     * Creates a new SVGOMFontFaceElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFontFaceElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FONT_FACE_TAG;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMFontFaceElement();
    }

//     /**
//      * Returns the table of TraitInformation objects for this element.
//      */
//     protected DoublyIndexedTable getTraitInformationTable() {
//         return xmlTraitInformation;
//     }
}
