/*

   Copyright 2000-2003  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.XMLConstants;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;
import org.w3c.flex.forks.dom.svg.SVGAnimatedInteger;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumber;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGElement;
import org.w3c.flex.forks.dom.svg.SVGException;
import org.w3c.flex.forks.dom.svg.SVGFitToViewBox;
import org.w3c.flex.forks.dom.svg.SVGSVGElement;

/**
 * This class implements the {@link SVGElement} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMElement.java,v 1.18 2005/02/22 09:13:01 cam Exp $
 */
public abstract class SVGOMElement
    extends    AbstractElement
    implements SVGElement,
               SVGConstants {

    /**
     * Is this element immutable?
     */
    protected transient boolean readonly;

    /**
     * The element prefix.
     */
    protected String prefix;

    /**
     * The SVG context to get SVG specific informations.
     */
    protected transient SVGContext svgContext;

    /**
     * Creates a new Element object.
     */
    protected SVGOMElement() {
    }

    /**
     * Creates a new Element object.
     * @param prefix The namespace prefix.
     * @param owner  The owner document.
     */
    protected SVGOMElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGElement#getId()}.
     */
    public String getId() {
        return getAttributeNS(null, "id");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGElement#setId(String)}.
     */
    public void setId(String id) {
        setAttributeNS(null, "id", id);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGElement#getXMLbase()}.
     */
    public String getXMLbase() {
        return XMLBaseSupport.getXMLBase(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGElement#setXMLbase(String)}.
     */
    public void setXMLbase(String xmlbase) throws DOMException {
        setAttributeNS(XMLConstants.XML_NAMESPACE_URI, "xml:base", xmlbase);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGElement#getOwnerSVGElement()}.
     */
    public SVGSVGElement getOwnerSVGElement() {
        for (Element e = CSSEngine.getParentCSSStylableElement(this);
             e != null;
             e = CSSEngine.getParentCSSStylableElement(e)) {
            if (e instanceof SVGSVGElement) {
                return (SVGSVGElement)e;
            }
        }
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGElement#getViewportElement()}.
     */
    public SVGElement getViewportElement() {
        for (Element e = CSSEngine.getParentCSSStylableElement(this);
             e != null;
             e = CSSEngine.getParentCSSStylableElement(e)) {
            if (e instanceof SVGFitToViewBox) {
                return (SVGElement)e;
            }
        }
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getNodeName()}.
     */
    public String getNodeName() {
        if (prefix == null || prefix.equals("")) {
            return getLocalName();
        }
        String ln = getLocalName();
        StringBuffer sb = new StringBuffer(prefix.length() + ln.length() + 1);
        sb.append(prefix).append(':').append(ln);
        return sb.toString();
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getNamespaceURI()}.
     */
    public String getNamespaceURI() {
        return SVGDOMImplementation.SVG_NAMESPACE_URI;
    }

    /**
     * <b>DOM</b>: Implements {@link Node#setPrefix(String)}.
     */
    public void setPrefix(String prefix) throws DOMException {
        if (isReadonly()) {
	    throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
				     "readonly.node",
				     new Object[] { new Integer(getNodeType()),
						    getNodeName() });
        }
        if (prefix != null &&
            !prefix.equals("") &&
            !DOMUtilities.isValidName(prefix)) {
	    throw createDOMException(DOMException.INVALID_CHARACTER_ERR,
				     "prefix",
				     new Object[] { new Integer(getNodeType()),
						    getNodeName(),
						    prefix });
        }
        this.prefix = prefix;
    }

    // SVGContext ////////////////////////////////////////////////////

    /**
     * Sets the SVG context to use to get SVG specific informations.
     *
     * @param ctx the SVG context
     */
    public void setSVGContext(SVGContext ctx) {
        svgContext = ctx;
    }

    /**
     * Returns the SVG context used to get SVG specific informations.
     */
    public SVGContext getSVGContext() {
        return svgContext;
    }

    // ExtendedNode //////////////////////////////////////////////////

    /**
     * Creates an SVGException with the appropriate error message.
     */
    public SVGException createSVGException(short type, 
                                           String key, 
                                           Object [] args) {
        try {
            return new SVGOMException
                (type, getCurrentDocument().formatMessage(key, args));
        } catch (Exception e) {
            return new SVGOMException(type, key);
        }
    }

    /**
     * Tests whether this node is readonly.
     */
    public boolean isReadonly() {
        return readonly;
    }

    /**
     * Sets this node readonly attribute.
     */
    public void setReadonly(boolean v) {
        readonly = v;
    }

    /**
     * Manages the query of an SVGAnimatedString.
     * @param ns The namespace of the attribute.
     * @param ln The local name of the attribute.
     */
    protected SVGAnimatedString getAnimatedStringAttribute(String ns,
                                                           String ln) {
        SVGAnimatedString result =
            (SVGAnimatedString)getLiveAttributeValue(ns, ln);
        if (result == null) {
            result = new SVGOMAnimatedString(this, ns, ln);
            putLiveAttributeValue(ns, ln, (LiveAttributeValue)result);
        }
        return result;
    }

    /**
     * Manages the query of an SVGAnimatedNumber.
     * @param ns The namespace of the attribute.
     * @param ln The local name of the attribute.
     * @param val The value if the attribute is not specified.
     */
    protected SVGAnimatedNumber getAnimatedNumberAttribute(String ns,
                                                           String ln,
                                                           float  val) {
        SVGAnimatedNumber result =
            (SVGAnimatedNumber)getLiveAttributeValue(ns, ln);
        if (result == null) {
            result = new SVGOMAnimatedNumber(this, ns, ln, val);
            putLiveAttributeValue(ns, ln, (LiveAttributeValue)result);
        }
        return result;
    }

    /**
     * Manages the query of an SVGAnimatedInteger.
     * @param ns The namespace of the attribute.
     * @param ln The local name of the attribute.
     * @param val The value if the attribute is not specified.
     */
    protected SVGAnimatedInteger getAnimatedIntegerAttribute(String ns,
                                                             String ln,
                                                             int    val) {
        SVGAnimatedInteger result =
            (SVGAnimatedInteger)getLiveAttributeValue(ns, ln);
        if (result == null) {
            result = new SVGOMAnimatedInteger(this, ns, ln, val);
            putLiveAttributeValue(ns, ln, (LiveAttributeValue)result);
        }
        return result;
    }

    /**
     * Manages the query of an SVGAnimatedEnumeration.
     * @param ns The namespace of the attribute.
     * @param ln The local name of the attribute.
     * @param val The values in the enumeration.
     * @param def The value if the attribute is not specified.
     */
    protected SVGAnimatedEnumeration
        getAnimatedEnumerationAttribute(String ns, String ln,
                                        String[] val, short def) {
        SVGAnimatedEnumeration result =
            (SVGAnimatedEnumeration)getLiveAttributeValue(ns, ln);
        if (result == null) {
            result = new SVGOMAnimatedEnumeration(this, ns, ln, val, def);
            putLiveAttributeValue(ns, ln, (LiveAttributeValue)result);
        }
        return result;
    }

    /**
     * Manages the query of an SVGAnimatedNumber.
     * @param ns The namespace of the attribute.
     * @param ln The local name of the attribute.
     * @param val The value if the attribute is not specified.
     * @param dir The length direction.
     */
    protected SVGAnimatedLength getAnimatedLengthAttribute(String ns,
                                                           String ln,
                                                           String val,
                                                           short  dir) {
        SVGAnimatedLength result =
            (SVGAnimatedLength)getLiveAttributeValue(ns, ln);
        if (result == null) {
            result = new SVGOMAnimatedLength(this, ns, ln, val, dir);
            putLiveAttributeValue(ns, ln, (LiveAttributeValue)result);
        }
        return result;
    }

    // Importation/Cloning ///////////////////////////////////////////

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
	super.export(n, d);
	SVGOMElement e = (SVGOMElement)n;
	e.prefix = prefix;
	return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
	super.deepExport(n, d);
	SVGOMElement e = (SVGOMElement)n;
	e.prefix = prefix;
	return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
	super.copyInto(n);
	SVGOMElement e = (SVGOMElement)n;
	e.prefix = prefix;
	return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
	super.deepCopyInto(n);
	SVGOMElement e = (SVGOMElement)n;
	e.prefix = prefix;
	return n;
    }
}
