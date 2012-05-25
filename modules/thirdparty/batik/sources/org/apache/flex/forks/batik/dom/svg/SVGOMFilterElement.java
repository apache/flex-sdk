/*

   Copyright 2000-2004  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

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
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAnimatedBoolean;
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;
import org.w3c.flex.forks.dom.svg.SVGAnimatedInteger;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGFilterElement;

/**
 * This class implements {@link SVGFilterElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMFilterElement.java,v 1.16 2004/08/18 07:13:16 vhardy Exp $
 */
public class SVGOMFilterElement
    extends    SVGStylableElement
    implements SVGFilterElement {

    /**
     * The attribute initializer.
     */
    protected final static AttributeInitializer attributeInitializer;
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
    protected final static String[] UNITS_VALUES = {
        "",
        SVG_USER_SPACE_ON_USE_VALUE,
        SVG_OBJECT_BOUNDING_BOX_VALUE
    };

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
        return getAnimatedEnumerationAttribute
            (null, SVG_FILTER_UNITS_ATTRIBUTE, UNITS_VALUES,
             (short)2);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getPrimitiveUnits()}.
     */
    public SVGAnimatedEnumeration getPrimitiveUnits() {
        return getAnimatedEnumerationAttribute
            (null, SVG_PRIMITIVE_UNITS_ATTRIBUTE, UNITS_VALUES,
             (short)1);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getX()}.
     */
    public SVGAnimatedLength getX() {
        return getAnimatedLengthAttribute
            (null, SVG_X_ATTRIBUTE, SVG_FILTER_X_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getY()}.
     */
    public SVGAnimatedLength getY() {
        return getAnimatedLengthAttribute
            (null, SVG_Y_ATTRIBUTE, SVG_FILTER_Y_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getWidth()}.
     */
    public SVGAnimatedLength getWidth() {
        return getAnimatedLengthAttribute
            (null, SVG_WIDTH_ATTRIBUTE, SVG_FILTER_WIDTH_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getHeight()}.
     */
    public SVGAnimatedLength getHeight() {
        return getAnimatedLengthAttribute
            (null, SVG_HEIGHT_ATTRIBUTE, SVG_FILTER_HEIGHT_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getFilterResX()}.
     */
    public SVGAnimatedInteger getFilterResX() {
        throw new RuntimeException(" !!! TODO: getFilterResX()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#getFilterResY()}.
     */
    public SVGAnimatedInteger getFilterResY() {
        throw new RuntimeException(" !!! TODO: getFilterResY()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGFilterElement#setFilterRes(int,int)}.
     */
    public void setFilterRes(int filterResX, int filterResY) {
        throw new RuntimeException(" !!! TODO: setFilterRes()");
    }

    // SVGURIReference support /////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link org.w3c.flex.forks.dom.svg.SVGURIReference#getHref()}.
     */
    public SVGAnimatedString getHref() {
        return SVGURIReferenceSupport.getHref(this);
    }

    // SVGExternalResourcesRequired support /////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGExternalResourcesRequired#getExternalResourcesRequired()}.
     */
    public SVGAnimatedBoolean getExternalResourcesRequired() {
        return SVGExternalResourcesRequiredSupport.
            getExternalResourcesRequired(this);
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
        setAttributeNS(XMLSupport.XML_NAMESPACE_URI,
                       XMLSupport.XML_LANG_ATTRIBUTE,
                       lang);
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
        setAttributeNS(XMLSupport.XML_NAMESPACE_URI,
                       XMLSupport.XML_SPACE_ATTRIBUTE,
                       space);
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
}
