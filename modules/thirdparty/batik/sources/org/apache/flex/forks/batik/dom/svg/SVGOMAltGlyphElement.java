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
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.dom.util.XMLSupport;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGAltGlyphElement;

/**
 * This class implements {@link SVGAltGlyphElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAltGlyphElement.java 489964 2006-12-24 01:30:23Z cam $
 */
public class SVGOMAltGlyphElement
    extends    SVGURIReferenceTextPositioningElement
    implements SVGAltGlyphElement {

    /**
     * The attribute initializer.
     */
    protected static final AttributeInitializer attributeInitializer;
    static {
        attributeInitializer = new AttributeInitializer(4);
        attributeInitializer.addAttribute(XMLSupport.XMLNS_NAMESPACE_URI,
                                          null, "xmlns:xlink",
                                          XLinkSupport.XLINK_NAMESPACE_URI);
        attributeInitializer.addAttribute(XLinkSupport.XLINK_NAMESPACE_URI,
                                          "xlink", "type", "simple");
        attributeInitializer.addAttribute(XLinkSupport.XLINK_NAMESPACE_URI,
                                          "xlink", "show", "other");
        attributeInitializer.addAttribute(XLinkSupport.XLINK_NAMESPACE_URI,
                                          "xlink", "actuate", "onLoad");
    }

//     /**
//      * Table mapping XML attribute names to TraitInformation objects.
//      */
//     protected static DoublyIndexedTable xmlTraitInformation;
//     static {
//         DoublyIndexedTable t =
//             new DoublyIndexedTable(SVGURIReferenceTextPositioningElement.xmlTraitInformation);
//         t.put(null, SVG_FORMAT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_GLYPH_REF_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         xmlTraitInformation = t;
//     }

    /**
     * Creates a new SVGOMAltGlyphElement object.
     */
    protected SVGOMAltGlyphElement() {
    }

    /**
     * Creates a new SVGOMAltGlyphElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMAltGlyphElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_ALT_GLYPH_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAltGlyphElement#getGlyphRef()}.
     */
    public String getGlyphRef() {
        return getAttributeNS(null, SVG_GLYPH_REF_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAltGlyphElement#setGlyphRef(String)}.
     */
    public void setGlyphRef(String glyphRef) throws DOMException {
        setAttributeNS(null, SVG_GLYPH_REF_ATTRIBUTE, glyphRef);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAltGlyphElement#getFormat()}.
     */
    public String getFormat() {
        return getAttributeNS(null, SVG_FORMAT_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAltGlyphElement#setFormat(String)}.
     */
    public void setFormat(String format) throws DOMException {
        setAttributeNS(null, SVG_FORMAT_ATTRIBUTE, format);
    }

    /**
     * Returns the AttributeInitializer for this element type.
     * @return null if this element has no attribute with a default value.
     */
    protected AttributeInitializer getAttributeInitializer() {
        return attributeInitializer;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMAltGlyphElement();
    }

//     /**
//      * Returns the table of TraitInformation objects for this element.
//      */
//     protected DoublyIndexedTable getTraitInformationTable() {
//         return xmlTraitInformation;
//     }
}
