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

import java.io.IOException;
import java.io.ObjectInputStream;
import java.net.URL;
import java.util.Locale;
import java.util.MissingResourceException;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.dom.AbstractStylableDocument;
import org.apache.flex.forks.batik.dom.GenericAttr;
import org.apache.flex.forks.batik.dom.GenericAttrNS;
import org.apache.flex.forks.batik.dom.GenericCDATASection;
import org.apache.flex.forks.batik.dom.GenericComment;
import org.apache.flex.forks.batik.dom.GenericDocumentFragment;
import org.apache.flex.forks.batik.dom.GenericDocumentType;
import org.apache.flex.forks.batik.dom.GenericElement;
import org.apache.flex.forks.batik.dom.GenericEntityReference;
import org.apache.flex.forks.batik.dom.GenericProcessingInstruction;
import org.apache.flex.forks.batik.dom.GenericText;
import org.apache.flex.forks.batik.dom.StyleSheetFactory;
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.i18n.Localizable;
import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.CDATASection;
import org.w3c.dom.Comment;
import org.w3c.dom.DOMException;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentFragment;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Element;
import org.w3c.dom.EntityReference;
import org.w3c.dom.Node;
import org.w3c.dom.ProcessingInstruction;
import org.w3c.dom.Text;
import org.w3c.flex.forks.dom.svg.SVGDocument;
import org.w3c.flex.forks.dom.svg.SVGLangSpace;
import org.w3c.flex.forks.dom.svg.SVGSVGElement;

/**
 * This class implements {@link SVGDocument}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMDocument.java,v 1.58 2005/03/27 08:58:32 cam Exp $
 */
public class SVGOMDocument
    extends    AbstractStylableDocument
    implements SVGDocument,
               SVGConstants {
    
    /**
     * The error messages bundle class name.
     */
    protected final static String RESOURCES =
        "org.apache.flex.forks.batik.dom.svg.resources.Messages";

    /**
     * The localizable support for the error messages.
     */
    protected transient LocalizableSupport localizableSupport =
        new LocalizableSupport(RESOURCES, getClass().getClassLoader());

    /**
     * The string representing the referrer.
     */
    protected String referrer = "";

    /**
     * The url of the document.
     */
    protected URL url;

    /**
     * Is this document immutable?
     */
    protected transient boolean readonly;

    /**
     * Creates a new uninitialized document.
     */
    protected SVGOMDocument() {
    }

    /**
     * Creates a new document.
     */
    public SVGOMDocument(DocumentType dt, DOMImplementation impl) {
        super(dt, impl);
    }

    /**
     * Implements {@link Localizable#setLocale(Locale)}.
     */
    public void setLocale(Locale l) {
        super.setLocale(l);
        localizableSupport.setLocale(l);
    }

    /**
     * Implements {@link Localizable#formatMessage(String,Object[])}.
     */
    public String formatMessage(String key, Object[] args)
        throws MissingResourceException {
        try {
            return super.formatMessage(key, args);
        } catch (MissingResourceException e) {
            return localizableSupport.formatMessage(key, args);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getTitle()}.
     */
    public String getTitle() {
        StringBuffer sb = new StringBuffer();
        boolean preserve = false;

        for (Node n = getDocumentElement().getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            String ns = n.getNamespaceURI();
            if (ns != null && ns.equals(SVG_NAMESPACE_URI)) {
                if (n.getLocalName().equals(SVG_TITLE_TAG)) {
                    preserve = ((SVGLangSpace)n).getXMLspace().equals("preserve");
                    for (n = n.getFirstChild();
                         n != null;
                         n = n.getNextSibling()) {
                        if (n.getNodeType() == Node.TEXT_NODE) {
                            sb.append(n.getNodeValue());
                        }
                    }
                    break;
                }
            }
        }

        String s = sb.toString();
        return (preserve)
            ? XMLSupport.preserveXMLSpace(s)
            : XMLSupport.defaultXMLSpace(s);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getReferrer()}.
     */
    public String getReferrer() {
        return referrer;
    }

    /**
     * Sets the referrer string.
     */
    public void setReferrer(String s) {
        referrer = s;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getDomain()}.
     */
    public String getDomain() {
        return (url == null) ? null : url.getHost();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getRootElement()}.
     */
    public SVGSVGElement getRootElement() {
        return (SVGSVGElement)getDocumentElement();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getURL()}
     */
    public String getURL() {
        return (url == null) ? null : url.toString();
    }

    /**
     * Returns the URI of the document.
     */
    public URL getURLObject() {
        return url;
    }

    /**
     * Sets the URI of the document.
     */
    public void setURLObject(URL url) {
        this.url = url;
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createElement(String)}.
     */
    public Element createElement(String tagName) throws DOMException {
        return new GenericElement(tagName.intern(), this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createDocumentFragment()}.
     */
    public DocumentFragment createDocumentFragment() {
        return new GenericDocumentFragment(this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createTextNode(String)}.
     */
    public Text createTextNode(String data) {
        return new GenericText(data, this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createComment(String)}.
     */
    public Comment createComment(String data) {
        return new GenericComment(data, this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createCDATASection(String)}
     */
    public CDATASection createCDATASection(String data) throws DOMException {
        return new GenericCDATASection(data, this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * Document#createProcessingInstruction(String,String)}.
     * @return a SVGStyleSheetProcessingInstruction if target is
     *         "xml-stylesheet" or a GenericProcessingInstruction otherwise.
     */
    public ProcessingInstruction createProcessingInstruction(String target,
                                                             String data)
        throws DOMException {
        if ("xml-stylesheet".equals(target)) {
            return new SVGStyleSheetProcessingInstruction
                (data, this, (StyleSheetFactory)getImplementation());
        }
        return new GenericProcessingInstruction(target, data, this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createAttribute(String)}.
     */
    public Attr createAttribute(String name) throws DOMException {
        return new GenericAttr(name.intern(), this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createEntityReference(String)}.
     */
    public EntityReference createEntityReference(String name)
        throws DOMException {
        return new GenericEntityReference(name, this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createAttributeNS(String,String)}.
     */
    public Attr createAttributeNS(String namespaceURI, String qualifiedName)
        throws DOMException {
        if (namespaceURI == null) {
            return new GenericAttr(qualifiedName.intern(), this);
        } else {
            return new GenericAttrNS(namespaceURI.intern(),
                                     qualifiedName.intern(),
                                     this);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createElementNS(String,String)}.
     */
    public Element createElementNS(String namespaceURI, String qualifiedName)
        throws DOMException {
        SVGDOMImplementation impl = (SVGDOMImplementation)implementation;
        return impl.createElementNS(this, namespaceURI, qualifiedName);
    }

    /**
     * Returns true if the given Attr node represents an 'id' 
     * for this document.
     */
    public boolean isId(Attr node) {
        if (node.getNamespaceURI() != null) return false;
        return SVG_ID_ATTRIBUTE.equals(node.getNodeName());
    }

    // AbstractDocument ///////////////////////////////////////////////

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
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMDocument();
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
	super.copyInto(n);
	SVGOMDocument sd = (SVGOMDocument)n;
        sd.localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
        sd.referrer = referrer;
        sd.url = url;
	return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
	super.deepCopyInto(n);
        SVGOMDocument sd = (SVGOMDocument)n;
        sd.localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
        sd.referrer = referrer;
        sd.url = url;
	return n;
    }

    // Serialization //////////////////////////////////////////////////////

    /**
     * Reads the object from the given stream.
     */
    private void readObject(ObjectInputStream s) 
        throws IOException, ClassNotFoundException {
        s.defaultReadObject();
        
        localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
    }        
}
