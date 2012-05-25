/*

   Copyright 2000-2001,2003-2004  The Apache Software Foundation 

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
import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAnimatedBoolean;
import org.w3c.flex.forks.dom.svg.SVGScriptElement;

/**
 * This class implements {@link org.w3c.flex.forks.dom.svg.SVGScriptElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMScriptElement.java,v 1.8 2004/08/18 07:13:18 vhardy Exp $
 */
public class SVGOMScriptElement
    extends    SVGOMURIReferenceElement
    implements SVGScriptElement {

    /**
     * The attribute initializer.
     */
    protected final static AttributeInitializer attributeInitializer;
    static {
        attributeInitializer = new AttributeInitializer(1);
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
     * Creates a new SVGOMScriptElement object.
     */
    protected SVGOMScriptElement() {
    }

    /**
     * Creates a new SVGOMScriptElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMScriptElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);

    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_SCRIPT_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGScriptElement#getType()}.
     */
    public String getType() {
	return getAttributeNS(null, SVG_TYPE_ATTRIBUTE);
    }
 
    /**
     * <b>DOM</b>: Implements {@link SVGScriptElement#setType(String)}.
     */
    public void setType(String type) throws DOMException {
	setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
    }

    // SVGExternalResourcesRequired support /////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGExternalResourcesRequired}.
     */
    public SVGAnimatedBoolean getExternalResourcesRequired() {
	return SVGExternalResourcesRequiredSupport.
            getExternalResourcesRequired(this);
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
        return new SVGOMScriptElement();
    }
}
