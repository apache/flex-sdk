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
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGAnimatedBoolean;
import org.w3c.dom.svg.SVGAnimatedEnumeration;
import org.w3c.dom.svg.SVGAnimatedLength;
import org.w3c.dom.svg.SVGLength;
import org.w3c.dom.svg.SVGPoint;
import org.w3c.dom.svg.SVGRect;
import org.w3c.dom.svg.SVGStringList;

/**
 * This class provides a common superclass for all graphics elements.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMTextContentElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public abstract class SVGOMTextContentElement
    extends    SVGStylableElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGStylableElement.xmlTraitInformation);
        t.put(null, SVG_TEXT_LENGTH_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_SIZE));
        t.put(null, SVG_LENGTH_ADJUST_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_EXTERNAL_RESOURCES_REQUIRED_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_BOOLEAN));
        xmlTraitInformation = t;
    }

    /**
     * The 'lengthAdjust' attribute values.
     */
    protected static final String[] LENGTH_ADJUST_VALUES = {
        "",
        SVG_SPACING_ATTRIBUTE,
        SVG_SPACING_AND_GLYPHS_VALUE
    };

    /**
     * The 'externalResourcesRequired' attribute value.
     */
    protected SVGOMAnimatedBoolean externalResourcesRequired;

    /**
     * The 'textLength' attribute value.
     */
    protected AbstractSVGAnimatedLength textLength;

    /**
     * The 'lengthAdjust' attribute value.
     */
    protected SVGOMAnimatedEnumeration lengthAdjust;

    /**
     * Creates a new SVGOMTextContentElement.
     */
    protected SVGOMTextContentElement() {
    }

    /**
     * Creates a new SVGOMTextContentElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGOMTextContentElement(String prefix, AbstractDocument owner) {
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
        lengthAdjust =
            createLiveAnimatedEnumeration
                (null, SVG_LENGTH_ADJUST_ATTRIBUTE, LENGTH_ADJUST_VALUES,
                 (short) 1);
        textLength = new AbstractSVGAnimatedLength
            (this, null, SVG_TEXT_LENGTH_ATTRIBUTE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH, true) {
                boolean usedDefault;

                protected String getDefaultValue() {
                    usedDefault = true;
                    return String.valueOf( getComputedTextLength() );
                }

                public SVGLength getBaseVal() {
                    if (baseVal == null) {
                        baseVal = new SVGTextLength(direction);
                    }
                    return baseVal;
                }

                class SVGTextLength extends BaseSVGLength {
                    public SVGTextLength(short direction) {
                        super(direction);
                    }
                    protected void revalidate() {
                        usedDefault = false;

                        super.revalidate();

                        // Since the default value can change w/o notice
                        // always recompute it.
                        if (usedDefault) valid = false;
                    }
                }
            };

        liveAttributeValues.put(null, SVG_TEXT_LENGTH_ATTRIBUTE, textLength);
        textLength.addAnimatedAttributeListener
            (((SVGOMDocument) ownerDocument).getAnimatedAttributeListener());
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getTextLength()}.
     */
    public SVGAnimatedLength getTextLength() {
        return textLength;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getLengthAdjust()}.
     */
    public SVGAnimatedEnumeration getLengthAdjust() {
        return lengthAdjust;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getNumberOfChars()}.
     */
    public int getNumberOfChars() {
        return SVGTextContentSupport.getNumberOfChars(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getComputedTextLength()}.
     */
    public float getComputedTextLength() {
        return SVGTextContentSupport.getComputedTextLength(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getSubStringLength(int,int)}.
     */
    public float getSubStringLength(int charnum, int nchars)
        throws DOMException {
        return SVGTextContentSupport.getSubStringLength(this, charnum, nchars);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getStartPositionOfChar(int)}.
     */
    public SVGPoint getStartPositionOfChar(int charnum) throws DOMException {
        return SVGTextContentSupport.getStartPositionOfChar(this, charnum);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getEndPositionOfChar(int)}.
     */
    public SVGPoint getEndPositionOfChar(int charnum) throws DOMException {
        return SVGTextContentSupport.getEndPositionOfChar(this, charnum);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getExtentOfChar(int)}.
     */
    public SVGRect getExtentOfChar(int charnum) throws DOMException {
        return SVGTextContentSupport.getExtentOfChar(this, charnum);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getRotationOfChar(int)}.
     */
    public float getRotationOfChar(int charnum) throws DOMException {
        return SVGTextContentSupport.getRotationOfChar(this, charnum);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#getCharNumAtPosition(SVGPoint)}.
     */
    public int getCharNumAtPosition(SVGPoint point) {
        return SVGTextContentSupport.getCharNumAtPosition
            (this, point.getX(), point.getY());
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGTextContentElement#selectSubString(int,int)}.
     */
    public void selectSubString(int charnum, int nchars)
        throws DOMException {
        SVGTextContentSupport.selectSubString(this, charnum, nchars);
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
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
