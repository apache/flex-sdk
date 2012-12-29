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
import org.w3c.dom.svg.SVGAnimatedString;
import org.w3c.dom.svg.SVGGlyphRefElement;

/**
 * This class implements {@link SVGGlyphRefElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMGlyphRefElement.java 489964 2006-12-24 01:30:23Z cam $
 */
public class SVGOMGlyphRefElement
    extends    SVGStylableElement
    implements SVGGlyphRefElement {

//     /**
//      * Table mapping XML attribute names to TraitInformation objects.
//      */
//     protected static DoublyIndexedTable xmlTraitInformation;
//     static {
//         DoublyIndexedTable t = new DoublyIndexedTable(SVGStylableElement.xmlTraitInformation);
//         t.put(XLINK_NAMESPACE_URI, XLINK_HREF_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_URI));
//         t.put(null, SVG_GLYPH_REF_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_FORMAT_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_CDATA));
//         t.put(null, SVG_X_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         t.put(null, SVG_Y_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         t.put(null, SVG_DX_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         t.put(null, SVG_DY_ATTRIBUTE,
//                 new TraitInformation(false, SVGTypes.TYPE_NUMBER));
//         xmlTraitInformation = t;
//     }

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
     * The 'xlink:href' attribute value.  Note that this attribute not
     * actually animatable, according to SVG 1.1.
     */
    protected SVGOMAnimatedString href;

    /**
     * Creates a new SVGOMGlyphRefElement object.
     */
    protected SVGOMGlyphRefElement() {
    }

    /**
     * Creates a new SVGOMGlyphRefElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMGlyphRefElement(String prefix, AbstractDocument owner) {
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
        href =
            createLiveAnimatedString(XLINK_NAMESPACE_URI, XLINK_HREF_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_GLYPH_REF_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.svg.SVGURIReference#getHref()}.
     */
    public SVGAnimatedString getHref() {
        return href;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#getGlyphRef()}.
     */
    public String getGlyphRef() {
        return getAttributeNS(null, SVG_GLYPH_REF_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#setGlyphRef(String)}.
     */
    public void setGlyphRef(String glyphRef) throws DOMException {
        setAttributeNS(null, SVG_GLYPH_REF_ATTRIBUTE, glyphRef);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#getFormat()}.
     */
    public String getFormat() {
        return getAttributeNS(null, SVG_FORMAT_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#setFormat(String)}.
     */
    public void setFormat(String format) throws DOMException {
        setAttributeNS(null, SVG_FORMAT_ATTRIBUTE, format);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#getX()}.
     */
    public float getX() {
        return Float.parseFloat(getAttributeNS(null, SVG_X_ATTRIBUTE));
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#setX(float)}.
     */
    public void setX(float x) throws DOMException {
        setAttributeNS(null, SVG_X_ATTRIBUTE, String.valueOf(x));
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#getY()}.
     */
    public float getY() {
        return Float.parseFloat(getAttributeNS(null, SVG_Y_ATTRIBUTE));
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#setY(float)}.
     */
    public void setY(float y) throws DOMException {
        setAttributeNS(null, SVG_Y_ATTRIBUTE, String.valueOf(y));
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#getDx()}.
     */
    public float getDx() {
        return Float.parseFloat(getAttributeNS(null, SVG_DX_ATTRIBUTE));
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#setDx(float)}.
     */
    public void setDx(float dx) throws DOMException {
        setAttributeNS(null, SVG_DX_ATTRIBUTE, String.valueOf(dx));
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#getDy()}.
     */
    public float getDy() {
        return Float.parseFloat(getAttributeNS(null, SVG_DY_ATTRIBUTE));
    }

    /**
     * <b>DOM</b>: Implements {@link SVGGlyphRefElement#setDy(float)}.
     */
    public void setDy(float dy) throws DOMException {
        setAttributeNS(null, SVG_DY_ATTRIBUTE, String.valueOf(dy));
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
        return new SVGOMGlyphRefElement();
    }

//     /**
//      * Returns the table of TraitInformation objects for this element.
//      */
//     protected DoublyIndexedTable getTraitInformationTable() {
//         return xmlTraitInformation;
//     }
}
