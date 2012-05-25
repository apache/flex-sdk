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
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGTextPathElement;

/**
 * This class implements {@link org.w3c.flex.forks.dom.svg.SVGTextPathElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMTextPathElement.java,v 1.8 2004/08/18 07:13:18 vhardy Exp $
 */
public class SVGOMTextPathElement
    extends    SVGOMTextContentElement
    implements SVGTextPathElement {

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
     * The 'method' attribute values.
     */
    protected final static String[] METHOD_VALUES = {
        "",
        SVG_ALIGN_VALUE,
        SVG_STRETCH_VALUE
    };

    /**
     * The 'spacing' attribute values.
     */
    protected final static String[] SPACING_VALUES = {
        "",
        SVG_AUTO_VALUE,
        SVG_EXACT_VALUE
    };

    /**
     * Creates a new SVGOMTextPathElement object.
     */
    protected SVGOMTextPathElement() {
    }

    /**
     * Creates a new SVGOMTextPathElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMTextPathElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_TEXT_PATH_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPathElement#getStartOffset()}.
     */
    public SVGAnimatedLength getStartOffset() {
        return getAnimatedLengthAttribute
            (null, SVG_START_OFFSET_ATTRIBUTE,
             SVG_TEXT_PATH_START_OFFSET_DEFAULT_VALUE,
             SVGOMAnimatedLength.OTHER_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPathElement#getMethod()}.
     */
    public SVGAnimatedEnumeration getMethod() {
        return getAnimatedEnumerationAttribute
            (null, SVG_METHOD_ATTRIBUTE, METHOD_VALUES, (short)1);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPathElement#getSpacing()}.
     */
    public SVGAnimatedEnumeration getSpacing() {
        return getAnimatedEnumerationAttribute
            (null, SVG_SPACING_ATTRIBUTE, SPACING_VALUES, (short)2);
    }


    // XLink support //////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGURIReference#getHref()}.
     */
    public SVGAnimatedString getHref() {
        return SVGURIReferenceSupport.getHref(this);
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
        return new SVGOMTextPathElement();
    }
}
