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

import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGAngle;
import org.w3c.dom.svg.SVGAnimatedAngle;
import org.w3c.dom.svg.SVGAnimatedBoolean;
import org.w3c.dom.svg.SVGAnimatedEnumeration;
import org.w3c.dom.svg.SVGAnimatedLength;
import org.w3c.dom.svg.SVGAnimatedPreserveAspectRatio;
import org.w3c.dom.svg.SVGAnimatedRect;
import org.w3c.dom.svg.SVGMarkerElement;

/**
 * This class implements {@link org.w3c.dom.svg.SVGMarkerElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMMarkerElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMMarkerElement
    extends    SVGStylableElement
    implements SVGMarkerElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGStylableElement.xmlTraitInformation);
        t.put(null, SVG_REF_X_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_REF_Y_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_MARKER_WIDTH_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_MARKER_HEIGHT_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_MARKER_UNITS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
        t.put(null, SVG_ORIENT_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_IDENT));
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
        attributeInitializer = new AttributeInitializer(1);
        attributeInitializer.addAttribute(null,
                                          null,
                                          SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE,
                                          "xMidYMid meet");
    }

    /**
     * The units values.
     */
    protected static final String[] UNITS_VALUES = {
        "",
        SVG_USER_SPACE_ON_USE_VALUE,
        SVG_STROKE_WIDTH_ATTRIBUTE
    };

    /**
     * The orient type values.
     */
    protected static final String[] ORIENT_TYPE_VALUES = {
        "",
        SVG_AUTO_VALUE,
        ""
    };

    /**
     * The 'refX' attribute value.
     */
    protected SVGOMAnimatedLength refX;

    /**
     * The 'refY' attribute value.
     */
    protected SVGOMAnimatedLength refY;

    /**
     * The 'markerWidth' attribute value.
     */
    protected SVGOMAnimatedLength markerWidth;

    /**
     * The 'markerHeight' attribute value.
     */
    protected SVGOMAnimatedLength markerHeight;

    /**
     * The 'orient' attribute value.
     */
    protected SVGOMAnimatedMarkerOrientValue orient;

    /**
     * The 'markerUnits' attribute value.
     */
    protected SVGOMAnimatedEnumeration markerUnits;

    /**
     * The 'preserveAspectRatio' attribute value.
     */
    protected SVGOMAnimatedPreserveAspectRatio preserveAspectRatio;

    /**
     * The 'viewBox' attribute value.
     */
    protected SVGOMAnimatedRect viewBox;

    /**
     * The 'externalResourcesRequired' attribute value.
     */
    protected SVGOMAnimatedBoolean externalResourcesRequired;

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
        refX =
            createLiveAnimatedLength
                (null, SVG_REF_X_ATTRIBUTE, SVG_MARKER_REF_X_DEFAULT_VALUE,
                 SVGOMAnimatedLength.HORIZONTAL_LENGTH, false);
        refY =
            createLiveAnimatedLength
                (null, SVG_REF_Y_ATTRIBUTE, SVG_MARKER_REF_Y_DEFAULT_VALUE,
                 SVGOMAnimatedLength.VERTICAL_LENGTH, false);
        markerWidth =
            createLiveAnimatedLength
                (null, SVG_MARKER_WIDTH_ATTRIBUTE,
                 SVG_MARKER_MARKER_WIDTH_DEFAULT_VALUE,
                 SVGOMAnimatedLength.HORIZONTAL_LENGTH, true);
        markerHeight =
            createLiveAnimatedLength
                (null, SVG_MARKER_HEIGHT_ATTRIBUTE,
                 SVG_MARKER_MARKER_WIDTH_DEFAULT_VALUE,
                 SVGOMAnimatedLength.VERTICAL_LENGTH, true);
        orient =
            createLiveAnimatedMarkerOrientValue(null, SVG_ORIENT_ATTRIBUTE);
        markerUnits =
            createLiveAnimatedEnumeration
                (null, SVG_MARKER_UNITS_ATTRIBUTE, UNITS_VALUES, (short) 2);
        preserveAspectRatio =
            createLiveAnimatedPreserveAspectRatio();
        viewBox = createLiveAnimatedRect(null, SVG_VIEW_BOX_ATTRIBUTE, null);
        externalResourcesRequired =
            createLiveAnimatedBoolean
                (null, SVG_EXTERNAL_RESOURCES_REQUIRED_ATTRIBUTE, false);
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
        return refX;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getRefY()}.
     */
    public SVGAnimatedLength getRefY() {
        return refY;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getMarkerUnits()}.
     */
    public SVGAnimatedEnumeration getMarkerUnits() {
        return markerUnits;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getMarkerWidth()}.
     */
    public SVGAnimatedLength getMarkerWidth() {
        return markerWidth;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getMarkerHeight()}.
     */
    public SVGAnimatedLength getMarkerHeight() {
        return markerHeight;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getOrientType()}.
     */
    public SVGAnimatedEnumeration getOrientType() {
        return orient.getAnimatedEnumeration();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#getOrientAngle()}.
     */
    public SVGAnimatedAngle getOrientAngle() {
        return orient.getAnimatedAngle();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGMarkerElement#setOrientToAuto()}.
     */
    public void setOrientToAuto() {
        setAttributeNS(null, SVG_ORIENT_ATTRIBUTE, SVG_AUTO_VALUE);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGMarkerElement#setOrientToAngle(SVGAngle)}.
     */
    public void setOrientToAngle(SVGAngle angle) {
        setAttributeNS(null, SVG_ORIENT_ATTRIBUTE, angle.getValueAsString());
    }

    // SVGFitToViewBox support ////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGFitToViewBox#getViewBox()}.
     */
    public SVGAnimatedRect getViewBox() {
        return viewBox;
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

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }

    // AnimationTarget ///////////////////////////////////////////////////////

// XXX TBD
//     /**
//      * Updates an attribute value in this target.
//      */
//     public void updateAttributeValue(String ns, String ln,
//                                      AnimatableValue val) {
//         if (ns == null) {
//             if (ln.equals(SVG_ORIENT_ATTRIBUTE)) {
//                 // XXX Needs testing.  Esp with the LiveAttributeValues updating
//                 //     the DOM attributes.
//                 SVGOMAnimatedMarkerOrientValue orient =
//                     (SVGOMAnimatedMarkerOrientValue)
//                     getLiveAttributeValue(null, ln);
//                 if (val == null) {
//                     orient.resetAnimatedValue();
//                 } else {
//                     AnimatableAngleOrIdentValue aloiv =
//                         (AnimatableAngleOrIdentValue) val;
//                     if (aloiv.isIdent()
//                             && aloiv.getIdent().equals(SVG_AUTO_VALUE)) {
//                         orient.setAnimatedValueToAuto();
//                     } else {
//                         orient.setAnimatedValueToAngle(aloiv.getUnit(),
//                                                        aloiv.getValue());
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
//             if (ln.equals(SVG_ORIENT_ATTRIBUTE)) {
//                 SVGOMAnimatedMarkerOrientValue orient =
//                     (SVGOMAnimatedMarkerOrientValue)
//                     getLiveAttributeValue(null, ln);
//                 if (orient.getAnimatedEnumeration().getBaseVal() ==
//                         SVGMarkerElement.SVG_MARKER_ORIENT_ANGLE) {
//                     SVGAngle a = orient.getAnimatedAngle().getBaseVal();
//                     return new AnimatableAngleOrIdentValue(this, a.getValue(),
//                                                            a.getUnitType());
//                 } else {
//                     return new AnimatableAngleOrIdentValue(this,
//                                                            SVG_AUTO_VALUE);
//                 }
//             }
//         }
//         return super.getUnderlyingValue(ns, ln);
//     }
}
