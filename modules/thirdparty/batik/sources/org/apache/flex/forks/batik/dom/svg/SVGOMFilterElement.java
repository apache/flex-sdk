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
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGAnimatedBoolean;
import org.w3c.dom.svg.SVGAnimatedEnumeration;
import org.w3c.dom.svg.SVGAnimatedInteger;
import org.w3c.dom.svg.SVGAnimatedLength;
import org.w3c.dom.svg.SVGAnimatedString;
import org.w3c.dom.svg.SVGFilterElement;

/**
 * This class implements {@link SVGFilterElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFilterElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMFilterElement
    extends    SVGStylableElement
    implements SVGFilterElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGStylableElement.xmlTraitInformation);
        t.put(null, SVG_FILTER_UNITS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_PRIMITIVE_UNITS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_X_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_Y_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_WIDTH_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_HEIGHT_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_FILTER_RES_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_OPTIONAL_NUMBER));
        xmlTraitInformation = t;
    }

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

    /**
     * The units values.
     */
    protected static final String[] UNITS_VALUES = {
        "",
        SVG_USER_SPACE_ON_USE_VALUE,
        SVG_OBJECT_BOUNDING_BOX_VALUE
    };

    /**
     * The 'filterUnits' attribute value.
     */
    protected SVGOMAnimatedEnumeration filterUnits;

    /**
     * The 'primitiveUnits' attribute value.
     */
    protected SVGOMAnimatedEnumeration primitiveUnits;

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
     * The 'xlink:href' attribute value.
     */
    protected SVGOMAnimatedString href;

    /**
     * The 'externalResourcesRequired' attribute value.
     */
    protected SVGOMAnimatedBoolean externalResourcesRequired;

    /**
     * Creates a new SVGOMFilterElement object.
     */
    protected SVGOMFilterElement() {
    }

    /**
     * Creates a new SVGOMFilterElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMFilterElement(String prefix, AbstractDocument owner) {
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
        filterUnits =
            createLiveAnimatedEnumeration
                (null, SVG_FILTER_UNITS_ATTRIBUTE, UNITS_VALUES, (short) 2);
        primitiveUnits =
            createLiveAnimatedEnumeration
                (null, SVG_PRIMITIVE_UNITS_ATTRIBUTE, UNITS_VALUES, (short) 1);
        x = createLiveAnimatedLength
            (null, SVG_X_ATTRIBUTE, SVG_FILTER_X_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH, false);
        y = createLiveAnimatedLength
            (null, SVG_Y_ATTRIBUTE, SVG_FILTER_Y_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH, false);
        width =
            createLiveAnimatedLength
                (null, SVG_WIDTH_ATTRIBUTE, SVG_FILTER_WIDTH_DEFAULT_VALUE,
                 SVGOMAnimatedLength.HORIZONTAL_LENGTH, true);
        height =
            createLiveAnimatedLength
                (null, SVG_HEIGHT_ATTRIBUTE, SVG_FILTER_HEIGHT_DEFAULT_VALUE,
                 SVGOMAnimatedLength.VERTICAL_LENGTH, true);
        href =
            createLiveAnimatedString(XLINK_NAMESPACE_URI, XLINK_HREF_ATTRIBUTE);
        externalResourcesRequired =
            createLiveAnimatedBoolean
                (null, SVG_EXTERNAL_RESOURCES_REQUIRED_ATTRIBUTE, false);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_FILTER_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getFilterUnits()}.
     */
    public SVGAnimatedEnumeration getFilterUnits() {
        return filterUnits;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getPrimitiveUnits()}.
     */
    public SVGAnimatedEnumeration getPrimitiveUnits() {
        return primitiveUnits;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getX()}.
     */
    public SVGAnimatedLength getX() {
        return x;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getY()}.
     */
    public SVGAnimatedLength getY() {
        return y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getWidth()}.
     */
    public SVGAnimatedLength getWidth() {
        return width;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getHeight()}.
     */
    public SVGAnimatedLength getHeight() {
        return height;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getFilterResX()}.
     */
    public SVGAnimatedInteger getFilterResX() {
        throw new UnsupportedOperationException
            ("SVGFilterElement.getFilterResX is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getFilterResY()}.
     */
    public SVGAnimatedInteger getFilterResY() {
        throw new UnsupportedOperationException
            ("SVGFilterElement.getFilterResY is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#setFilterRes(int,int)}.
     */
    public void setFilterRes(int filterResX, int filterResY) {
        throw new UnsupportedOperationException
            ("SVGFilterElement.setFilterRes is not implemented"); // XXX
    }

    // SVGURIReference support /////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.svg.SVGURIReference#getHref()}.
     */
    public SVGAnimatedString getHref() {
        return href;
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
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }

    // SVGLangSpace support //////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Returns the xml:lang attribute value.
     */
    public String getXMLlang() {
        return XMLSupport.getXMLLang(this);
    }

    /**
     * <b>DOM</b>: Sets the xml:lang attribute value.
     */
    public void setXMLlang(String lang) {
        setAttributeNS(XML_NAMESPACE_URI, XML_LANG_QNAME, lang);
    }

    /**
     * <b>DOM</b>: Returns the xml:space attribute value.
     */
    public String getXMLspace() {
        return XMLSupport.getXMLSpace(this);
    }

    /**
     * <b>DOM</b>: Sets the xml:space attribute value.
     */
    public void setXMLspace(String space) {
        setAttributeNS(XML_NAMESPACE_URI, XML_SPACE_QNAME, space);
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
        return new SVGOMFilterElement();
    }

    // AnimationTarget ///////////////////////////////////////////////////////

// XXX TBD
//     /**
//      * Updates an attribute value in this target.
//      */
//     public void updateAttributeValue(String ns, String ln,
//                                      AnimatableValue val) {
//         if (ns == null) {
//             if (ln.equals(SVG_FILTER_RES_ATTRIBUTE)) {
//                 // XXX Needs testing.
//                 if (val == null) {
//                     updateIntegerAttributeValue(getFilterResX(), null);
//                     updateIntegerAttributeValue(getFilterResY(), null);
//                 } else {
//                     AnimatableNumberOptionalNumberValue anonv =
//                         (AnimatableNumberOptionalNumberValue) val;
//                     SVGOMAnimatedInteger ai =
//                         (SVGOMAnimatedInteger) getFilterResX();
//                     ai.setAnimatedValue(Math.round(anonv.getNumber()));
//                     ai = (SVGOMAnimatedInteger) getFilterResY();
//                     if (anonv.hasOptionalNumber()) {
//                         ai.setAnimatedValue
//                             (Math.round(anonv.getOptionalNumber()));
//                     } else {
//                         ai.setAnimatedValue(Math.round(anonv.getNumber()));
//                     }
//                 }
//                 return;
//             }
//         }
//         super.updateAttributeValue(ns, ln, val);
//     }
// 
//     /**
//      * Returns the underlying value of an animatable XML attribute.
//      */
//     public AnimatableValue getUnderlyingValue(String ns, String ln) {
//         if (ns == null) {
//             if (ln.equals(SVG_FILTER_RES_ATTRIBUTE)) {
//                 return getBaseValue(getFilterResX(), getFilterResY());
//             }
//         }
//         return super.getUnderlyingValue(ns, ln);
//     }
}
