/*

   Copyright 2001-2003  The Apache Software Foundation 

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
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAngle;
import org.w3c.flex.forks.dom.svg.SVGAnimatedAngle;
import org.w3c.flex.forks.dom.svg.SVGAnimatedBoolean;
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGAnimatedPreserveAspectRatio;
import org.w3c.flex.forks.dom.svg.SVGAnimatedRect;
import org.w3c.flex.forks.dom.svg.SVGMarkerElement;

/**
 * This class implements {@link org.w3c.flex.forks.dom.svg.SVGMarkerElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMMarkerElement.java,v 1.9 2004/09/01 09:35:22 deweese Exp $
 */
public class SVGOMMarkerElement
    extends    SVGStylableElement
    implements SVGMarkerElement {
    
    /**
     * The attribute initializer.
     */
    protected final static AttributeInitializer attributeInitializer;
    static {
        attributeInitializer = new AttributeInitializer(1);
        attributeInitializer.addAttribute(null,
                                          null,
                                          SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE,
                                          "xMidYMid meet");
    }

    /**
     * The units values.
     */
    protected final static String[] UNITS_VALUES = {
        "",
        SVG_USER_SPACE_ON_USE_VALUE,
        SVG_STROKE_WIDTH_ATTRIBUTE
    };

    /**
     * Creates a new SVGOMMarkerElement object.
     */
    protected SVGOMMarkerElement() {
    }

    /**
     * Creates a new SVGOMMarkerElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMMarkerElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_MARKER_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getRefX()}.
     */
    public SVGAnimatedLength getRefX() {
        return getAnimatedLengthAttribute
            (null, SVG_REF_X_ATTRIBUTE, SVG_MARKER_REF_X_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getRefY()}.
     */
    public SVGAnimatedLength getRefY() {
        return getAnimatedLengthAttribute
            (null, SVG_REF_Y_ATTRIBUTE, SVG_MARKER_REF_Y_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getMarkerUnits()}.
     */
    public SVGAnimatedEnumeration getMarkerUnits() {
        return getAnimatedEnumerationAttribute
            (null, SVG_MARKER_UNITS_ATTRIBUTE, UNITS_VALUES,
             (short)2);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getMarkerWidth()}.
     */
    public SVGAnimatedLength getMarkerWidth() {
        return getAnimatedLengthAttribute
            (null, SVG_MARKER_WIDTH_ATTRIBUTE,
             SVG_MARKER_MARKER_WIDTH_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getMarkerHeight()}.
     */
    public SVGAnimatedLength getMarkerHeight() {
        return getAnimatedLengthAttribute
            (null, SVG_MARKER_HEIGHT_ATTRIBUTE,
             SVG_MARKER_MARKER_HEIGHT_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getOrientType()}.
     */
    public SVGAnimatedEnumeration getOrientType() {
	throw new RuntimeException(" !!! TODO: getOrientType()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getOrientAngle()}.
     */
    public SVGAnimatedAngle getOrientAngle() {
	throw new RuntimeException(" !!! TODO: getOrientAngle()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#setOrientToAuto()}.
     */
    public void setOrientToAuto() {
	throw new RuntimeException(" !!! TODO: setOrientToAuto()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGMarkerElement#setOrientToAngle(SVGAngle)}.
     */
    public void setOrientToAngle(SVGAngle angle) {
	throw new RuntimeException(" !!! TODO: setOrientToAngle()");
    }

    // SVGFitToViewBox support ////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFitToViewBox#getViewBox()}.
     */
    public SVGAnimatedRect getViewBox() {
	throw new RuntimeException(" !!! TODO: getViewBox()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFitToViewBox#getPreserveAspectRatio()}.
     */
    public SVGAnimatedPreserveAspectRatio getPreserveAspectRatio() {
        return SVGPreserveAspectRatioSupport.getPreserveAspectRatio(this);
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
        return new SVGOMMarkerElement();
    }
}
