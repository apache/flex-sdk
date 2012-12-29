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
import org.w3c.dom.svg.SVGAnimatedLength;
import org.w3c.dom.svg.SVGElementInstance;
import org.w3c.dom.svg.SVGUseElement;

/**
 * This class implements {@link org.w3c.dom.svg.SVGUseElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMUseElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public class SVGOMUseElement
    extends    SVGURIReferenceGraphicsElement
    implements SVGUseElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGURIReferenceGraphicsElement.xmlTraitInformation);
        t.put(null, SVG_X_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_Y_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
        t.put(null, SVG_WIDTH_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_WIDTH));
        t.put(null, SVG_HEIGHT_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_LENGTH, PERCENTAGE_VIEWPORT_HEIGHT));
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
                                          "xlink", "show", "embed");
        attributeInitializer.addAttribute(XLinkSupport.XLINK_NAMESPACE_URI,
                                          "xlink", "actuate", "onLoad");
    }

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
     * Store the shadow tree of the use element.
     */
    protected SVGOMUseShadowRoot shadowTree;

    /**
     * Creates a new SVGOMUseElement object.
     */
    protected SVGOMUseElement() {
    }

    /**
     * Creates a new SVGOMUseElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMUseElement(String prefix, AbstractDocument owner) {
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
            (null, SVG_X_ATTRIBUTE, SVG_USE_X_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH, false);
        y = createLiveAnimatedLength
            (null, SVG_Y_ATTRIBUTE, SVG_USE_Y_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH, false);
        width =
            createLiveAnimatedLength
                (null, SVG_WIDTH_ATTRIBUTE, null,
                 SVGOMAnimatedLength.HORIZONTAL_LENGTH, true);
        height =
            createLiveAnimatedLength
                (null, SVG_HEIGHT_ATTRIBUTE, null,
                 SVGOMAnimatedLength.VERTICAL_LENGTH, true);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_USE_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGUseElement#getX()}.
     */
    public SVGAnimatedLength getX() {
        return x;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGUseElement#getY()}.
     */
    public SVGAnimatedLength getY() {
        return y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGUseElement#getWidth()}.
     */
    public SVGAnimatedLength getWidth() {
        return width;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGUseElement#getHeight()}.
     */
    public SVGAnimatedLength getHeight() {
        return height;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGUseElement#getInstanceRoot()}.
     */
    public SVGElementInstance getInstanceRoot() {
        throw new UnsupportedOperationException
            ("SVGUseElement.getInstanceRoot is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link SVGUseElement#getAnimatedInstanceRoot()}.
     */
    public SVGElementInstance getAnimatedInstanceRoot() {
        throw new UnsupportedOperationException
            ("SVGUseElement.getAnimatedInstanceRoot is not implemented"); // XXX
    }

    // CSSNavigableNode ///////////////////////////////////////////////

    /**
     * Returns the CSS first child node of this node.
     */
    public Node getCSSFirstChild() {
        if (shadowTree != null) {
            return shadowTree.getFirstChild();
        }
        return null;
    }

    /**
     * Returns the CSS last child of this stylable element.
     */
    public Node getCSSLastChild() {
        // use element shadow trees only ever have a single element
        return getCSSFirstChild();
    }

    /**
     * Returns whether this node is the root of a (conceptual) hidden tree
     * that selectors will not work across.  Returns true here, since CSS
     * selectors cannot work in the conceptual cloned sub-tree of the
     * content referenced by the 'use' element.
     */
    public boolean isHiddenFromSelectors() {
        return true;
    }

    /**
     * Sets the shadow tree for this 'use' element.
     */
    public void setUseShadowTree(SVGOMUseShadowRoot r) {
        shadowTree = r;
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
        return new SVGOMUseElement();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
