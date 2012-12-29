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
import org.w3c.dom.svg.SVGAnimatedLength;
import org.w3c.dom.svg.SVGAnimatedPreserveAspectRatio;
import org.w3c.dom.svg.SVGAnimatedRect;
import org.w3c.dom.svg.SVGAnimatedString;
import org.w3c.dom.svg.SVGAnimatedTransformList;
import org.w3c.dom.svg.SVGPatternElement;
import org.w3c.dom.svg.SVGStringList;

/**
 * This class implements {@link org.w3c.dom.svg.SVGStopElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMPatternElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMPatternElement
    extends    SVGStylableElement
    implements SVGPatternElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGStylableElement.xmlTraitInformation);
        t.put(null, SVG_X_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_Y_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_WIDTH_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_HEIGHT_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_PATTERN_UNITS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_PATTERN_CONTENT_UNITS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_PATTERN_TRANSFORM_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_TRANSFORM_LIST));
        t.put(null, SVG_VIEW_BOX_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_NUMBER_LIST));
        t.put(null, SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_PRESERVE_ASPECT_RATIO_VALUE));
        t.put(null, SVG_EXTERNAL_RESOURCES_REQUIRED_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_BOOLEAN));
        xmlTraitInformation = t;
    }

    /**
     * The attribute initializer.
     */
    protected static final AttributeInitializer attributeInitializer;
    static {
        attributeInitializer = new AttributeInitializer(5);
        attributeInitializer.addAttribute(null, null,
                                          SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE,
                                          "xMidYMid meet");
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
     * The 'patternUnits' attribute value.
     */
    protected SVGOMAnimatedEnumeration patternUnits;

    /**
     * The 'patternContentUnits' attribute value.
     */
    protected SVGOMAnimatedEnumeration patternContentUnits;

    /**
     * The 'xlink:href' attribute value.
     */
    protected SVGOMAnimatedString href;

    /**
     * The 'externalResourcesRequired' attribute value.
     */
    protected SVGOMAnimatedBoolean externalResourcesRequired;

    /**
     * The 'preserveAspectRatio' attribute value.
     */
    protected SVGOMAnimatedPreserveAspectRatio preserveAspectRatio;

    /**
     * Creates a new SVGOMPatternElement object.
     */
    protected SVGOMPatternElement() {
    }

    /**
     * Creates a new SVGOMPatternElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMPatternElement(String prefix,
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
        x = createLiveAnimatedLength
            (null, SVG_X_ATTRIBUTE, SVG_PATTERN_X_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH, false);
        y = createLiveAnimatedLength
            (null, SVG_Y_ATTRIBUTE, SVG_PATTERN_Y_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH, false);
        width =
            createLiveAnimatedLength
                (null, SVG_WIDTH_ATTRIBUTE, SVG_PATTERN_WIDTH_DEFAULT_VALUE,
                 SVGOMAnimatedLength.HORIZONTAL_LENGTH, true);
        height =
            createLiveAnimatedLength
                (null, SVG_HEIGHT_ATTRIBUTE, SVG_PATTERN_WIDTH_DEFAULT_VALUE,
                 SVGOMAnimatedLength.VERTICAL_LENGTH, true);
        patternUnits =
            createLiveAnimatedEnumeration
                (null, SVG_PATTERN_UNITS_ATTRIBUTE, UNITS_VALUES, (short) 2);
        patternContentUnits =
            createLiveAnimatedEnumeration
                (null, SVG_PATTERN_CONTENT_UNITS_ATTRIBUTE, UNITS_VALUES,
                 (short) 1);
        href =
            createLiveAnimatedString(XLINK_NAMESPACE_URI, XLINK_HREF_ATTRIBUTE);
        externalResourcesRequired =
            createLiveAnimatedBoolean
                (null, SVG_EXTERNAL_RESOURCES_REQUIRED_ATTRIBUTE, false);
        preserveAspectRatio = createLiveAnimatedPreserveAspectRatio();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_PATTERN_TAG;
    }

    /**
     * To implement {@link SVGPatternElement#getPatternTransform()}.
     */
    public SVGAnimatedTransformList getPatternTransform() {
        throw new UnsupportedOperationException
            ("SVGPatternElement.getPatternTransform is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPatternElement#getPatternUnits()}.
     */
    public SVGAnimatedEnumeration getPatternUnits() {
        return patternUnits;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGPatternElement#getPatternContentUnits()}.
     */
    public SVGAnimatedEnumeration getPatternContentUnits() {
        return patternContentUnits;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPatternElement#getX()}.
     */
    public SVGAnimatedLength getX() {
        return x;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPatternElement#getY()}.
     */
    public SVGAnimatedLength getY() {
        return y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPatternElement#getWidth()}.
     */
    public SVGAnimatedLength getWidth() {
        return width;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGPatternElement#getHeight()}.
     */
    public SVGAnimatedLength getHeight() {
        return height;
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }

    // XLink support //////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGURIReference#getHref()}.
     */
    public SVGAnimatedString getHref() {
        return href;
    }

    // SVGFitToViewBox support ////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFitToViewBox#getViewBox()}.
     */
    public SVGAnimatedRect getViewBox() {
        throw new UnsupportedOperationException
            ("SVGFitToViewBox.getViewBox is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFitToViewBox#getPreserveAspectRatio()}.
     */
    public SVGAnimatedPreserveAspectRatio getPreserveAspectRatio() {
        return preserveAspectRatio;
    }

    // SVGExternalResourcesRequired support /////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGExternalResourcesRequired#getExternalResourcesRequired()}.
     */
    public SVGAnimatedBoolean getExternalResourcesRequired() {
        return externalResourcesRequired;
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

    // SVGTests support ///////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTests#getRequiredFeatures()}.
     */
    public SVGStringList getRequiredFeatures() {
        return SVGTestsSupport.getRequiredFeatures(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTests#getRequiredExtensions()}.
     */
    public SVGStringList getRequiredExtensions() {
        return SVGTestsSupport.getRequiredExtensions(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTests#getSystemLanguage()}.
     */
    public SVGStringList getSystemLanguage() {
        return SVGTestsSupport.getSystemLanguage(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTests#hasExtension(String)}.
     */
    public boolean hasExtension(String extension) {
        return SVGTestsSupport.hasExtension(this, extension);
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
        return new SVGOMPatternElement();
    }
}
