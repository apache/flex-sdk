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
package org.apache.flex.forks.batik.dom.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InterruptedIOException;
import java.io.Reader;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.flex.forks.batik.util.HaltingThread;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.xml.sax.Attributes;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.SAXNotRecognizedException;
import org.xml.sax.SAXParseException;
import org.xml.sax.XMLReader;
import org.xml.sax.ext.LexicalHandler;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * This class contains methods for creating Document instances
 * from an URI using SAX2.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SAXDocumentFactory.java 509851 2007-02-21 01:12:30Z deweese $
 */
public class SAXDocumentFactory
    extends    DefaultHandler
    implements LexicalHandler,
               DocumentFactory {

    /**
     * The DOM implementation used to create the document.
     */
    protected DOMImplementation implementation;

    /**
     * The SAX2 parser classname.
     */
    protected String parserClassName;

    /**
     * The SAX2 parser object.
     */
    protected XMLReader parser;

    /**
     * The created document.
     */
    protected Document document;

    /**
     * The created document descriptor.
     */
    protected DocumentDescriptor documentDescriptor;

    /**
     * Whether a document descriptor must be generated.
     */
    protected boolean createDocumentDescriptor;

    /**
     * The current node.
     */
    protected Node currentNode;

    /**
     * The locator.
     */
    protected Locator locator;

    /**
     * Contains collected string data.  May be Text, CDATA or Comment.
     */
    protected StringBuffer stringBuffer = new StringBuffer();
    /**
     * Indicates if stringBuffer has content, needed in case of
     * zero sized "text" content.
     */
    protected boolean stringContent;

    /**
     * True if the parser is currently parsing a DTD.
     */
    protected boolean inDTD;

    /**
     * True if the parser is currently parsing a CDATA section.
     */
    protected boolean inCDATA;

    /**
     * Whether the parser still hasn't read the document element's
     * opening tag.
     */
    protected boolean inProlog;

    /**
     * Whether the parser is in validating mode.
     */
    protected boolean isValidating;

    /**
     * Whether the document just parsed was standalone.
     */
    protected boolean isStandalone;

    /**
     * XML version of the document just parsed.
     */
    protected String xmlVersion;

    /**
     * The stack used to store the namespace URIs.
     */
    protected HashTableStack namespaces;

    /**
     * The error handler.
     */
    protected ErrorHandler errorHandler;

    protected interface PreInfo {
        Node createNode(Document doc);
    }

    static class ProcessingInstructionInfo implements PreInfo {
        public String target, data;
        public ProcessingInstructionInfo(String target, String data) {
            this.target = target;
            this.data = data;
        }
        public Node createNode(Document doc) {
            return doc.createProcessingInstruction(target, data);
        }
    }

    static class CommentInfo implements PreInfo {
        public String comment;
        public CommentInfo(String comment) {
            this.comment = comment;
        }
        public Node createNode(Document doc) {
            return doc.createComment(comment);
        }
    }

    static class CDataInfo implements PreInfo {
        public String cdata;
        public CDataInfo(String cdata) {
            this.cdata = cdata;
        }
        public Node createNode(Document doc) {
            return doc.createCDATASection(cdata);
        }
    }

    static class TextInfo implements PreInfo {
        public String text;
        public TextInfo(String text) {
            this.text = text;
        }
        public Node createNode(Document doc) {
            return doc.createTextNode(text);
        }
    }

    /**
     * Various elements encountered prior to real document root element.
     * List of PreInfo objects.
     */
    protected List preInfo;

    /**
     * Creates a new SAXDocumentFactory object.
     * No document descriptor will be created while generating a document.
     * @param impl The DOM implementation to use for building the DOM tree.
     * @param parser The SAX2 parser classname.
     */
    public SAXDocumentFactory(DOMImplementation impl,
                              String parser) {
        implementation           = impl;
        parserClassName          = parser;
    }

    /**
     * Creates a new SAXDocumentFactory object.
     * @param impl The DOM implementation to use for building the DOM tree.
     * @param parser The SAX2 parser classname.
     * @param dd Whether a document descriptor must be generated.
     */
    public SAXDocumentFactory(DOMImplementation impl,
                              String parser,
                              boolean dd) {
        implementation           = impl;
        parserClassName          = parser;
        createDocumentDescriptor = dd;
    }

    /**
     * Creates a Document instance.
     * @param ns The namespace URI of the root element of the document.
     * @param root The name of the root element of the document.
     * @param uri The document URI.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String ns, String root, String uri)
        throws IOException {
        return createDocument(ns, root, uri, new InputSource(uri));
    }

    /**
     * Creates a Document instance.
     * @param uri The document URI.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String uri)
        throws IOException {
        return createDocument(new InputSource(uri));
    }

    /**
     * Creates a Document instance.
     * @param ns The namespace URI of the root element of the document.
     * @param root The name of the root element of the document.
     * @param uri The document URI.
     * @param is The document input stream.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String ns, String root, String uri,
                                   InputStream is) throws IOException {
        InputSource inp = new InputSource(is);
        inp.setSystemId(uri);
        return createDocument(ns, root, uri, inp);
    }

    /**
     * Creates a Document instance.
     * @param uri The document URI.
     * @param is The document input stream.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String uri, InputStream is)
        throws IOException {
        InputSource inp = new InputSource(is);
        inp.setSystemId(uri);
        return createDocument(inp);
    }

    /**
     * Creates a Document instance.
     * @param ns The namespace URI of the root element of the document.
     * @param root The name of the root element of the document.
     * @param uri The document URI.
     * @param r The document reader.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String ns, String root, String uri,
                                   Reader r) throws IOException {
        InputSource inp = new InputSource(r);
        inp.setSystemId(uri);
        return createDocument(ns, root, uri, inp);
    }

    /**
     * Creates a Document instance.
     * @param ns The namespace URI of the root element of the document.
     * @param root The name of the root element of the document.
     * @param uri The document URI.
     * @param r an XMLReaderInstance
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String ns, String root, String uri,
                                   XMLReader r) throws IOException {
        r.setContentHandler(this);
        r.setDTDHandler(this);
        r.setEntityResolver(this);
        try {
            r.parse(uri);
        } catch (SAXException e) {
            Exception ex = e.getException();
            if (ex != null && ex instanceof InterruptedIOException) {
                throw (InterruptedIOException) ex;
            }
            throw new SAXIOException(e);
        }
        currentNode = null;
        Document ret = document;
        document = null;
        return ret;
    }

    /**
     * Creates a Document instance.
     * @param uri The document URI.
     * @param r The document reader.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String uri, Reader r) throws IOException {
        InputSource inp = new InputSource(r);
        inp.setSystemId(uri);
        return createDocument(inp);
    }

    /**
     * Creates a Document.
     * @param ns The namespace URI of the root element.
     * @param root The name of the root element.
     * @param uri The document URI.
     * @param is  The document input source.
     * @exception IOException if an error occured while reading the document.
     */
    protected Document createDocument(String ns, String root, String uri,
                                      InputSource is)
        throws IOException {
        Document ret = createDocument(is);
        Element docElem = ret.getDocumentElement();

        String lname = root;
        String nsURI = ns;
        if (ns == null) {
            int idx = lname.indexOf(':');
            String nsp = (idx == -1 || idx == lname.length()-1)
                ? ""
                : lname.substring(0, idx);
            nsURI = namespaces.get(nsp);
            if (idx != -1 && idx != lname.length()-1) {
                lname = lname.substring(idx+1);
            }
        }


        String docElemNS = docElem.getNamespaceURI();
        if ((docElemNS != nsURI) &&
            ((docElemNS == null) || (!docElemNS.equals(nsURI))))
            throw new IOException
                ("Root element namespace does not match that requested:\n" +
                 "Requested: " + nsURI + "\n" +
                 "Found: " + docElemNS);

        if (docElemNS != null) {
            if (!docElem.getLocalName().equals(lname))
                throw new IOException
                    ("Root element does not match that requested:\n" +
                     "Requested: " + lname + "\n" +
                     "Found: " + docElem.getLocalName());
        } else {
            if (!docElem.getNodeName().equals(lname))
                throw new IOException
                    ("Root element does not match that requested:\n" +
                     "Requested: " + lname + "\n" +
                     "Found: " + docElem.getNodeName());
        }

        return ret;
    }

    static SAXParserFactory saxFactory;
    static {
        saxFactory = SAXParserFactory.newInstance();
    }

    /**
     * Creates a Document.
     * @param is  The document input source.
     * @exception IOException if an error occured while reading the document.
     */
    protected Document createDocument(InputSource is)
        throws IOException {
        try {
            if (parserClassName != null) {
                parser = XMLReaderFactory.createXMLReader(parserClassName);
            } else {
                SAXParser saxParser;
                try {
                    saxParser = saxFactory.newSAXParser();
                } catch (ParserConfigurationException pce) {
                    throw new IOException("Could not create SAXParser: "
                            + pce.getMessage());
                }
                parser = saxParser.getXMLReader();
            }

            parser.setContentHandler(this);
            parser.setDTDHandler(this);
            parser.setEntityResolver(this);
            parser.setErrorHandler((errorHandler == null) ?
                                   this : errorHandler);

            parser.setFeature("http://xml.org/sax/features/namespaces",
                              true);
            parser.setFeature("http://xml.org/sax/features/namespace-prefixes",
                              true);
            parser.setFeature("http://xml.org/sax/features/validation",
                              isValidating);
            parser.setProperty("http://xml.org/sax/properties/lexical-handler",
                               this);
            parser.parse(is);
        } catch (SAXException e) {
            Exception ex = e.getException();
            if (ex != null && ex instanceof InterruptedIOException) {
                throw (InterruptedIOException)ex;
            }
            throw new SAXIOException(e);
        }

        currentNode  = null;
        Document ret = document;
        document     = null;
        locator      = null;
        parser       = null;
        return ret;
    }

    /**
     * Returns the document descriptor associated with the latest created
     * document.
     * @return null if no document or descriptor was previously generated.
     */
    public DocumentDescriptor getDocumentDescriptor() {
        return documentDescriptor;
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ContentHandler#setDocumentLocator(Locator)}.
     */
    public void setDocumentLocator(Locator l) {
        locator = l;
    }

    /**
     * Sets whether or not the XML parser will validate the XML document
     * depending on the specified parameter.
     *
     * @param isValidating indicates that the XML parser will validate the XML
     * document
     */
    public void setValidating(boolean isValidating) {
        this.isValidating = isValidating;
    }

    /**
     * Returns true if the XML parser validates the XML stream, false
     * otherwise.
     */
    public boolean isValidating() {
        return isValidating;
    }

    /**
     * Sets a custom error handler.
     */
    public void setErrorHandler(ErrorHandler eh) {
        errorHandler = eh;
    }

    public DOMImplementation getDOMImplementation(String ver) {
        return implementation;
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ErrorHandler#fatalError(SAXParseException)}.
     */
    public void fatalError(SAXParseException ex) throws SAXException {
        throw ex;
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ErrorHandler#error(SAXParseException)}.
     */
    public void error(SAXParseException ex) throws SAXException {
        throw ex;
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ErrorHandler#warning(SAXParseException)}.
     */
    public void warning(SAXParseException ex) throws SAXException {
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ContentHandler#startDocument()}.
     */
    public void startDocument() throws SAXException {
        preInfo    = new LinkedList();
        namespaces = new HashTableStack();
        namespaces.put("xml", XMLSupport.XML_NAMESPACE_URI);
        namespaces.put("xmlns", XMLSupport.XMLNS_NAMESPACE_URI);
        namespaces.put("", null);

        inDTD        = false;
        inCDATA      = false;
        inProlog     = true;
        currentNode  = null;
        document     = null;
        isStandalone = false;
        xmlVersion   = XMLConstants.XML_VERSION_10;

        stringBuffer.setLength(0);
        stringContent = false;

        if (createDocumentDescriptor) {
            documentDescriptor = new DocumentDescriptor();
        } else {
            documentDescriptor = null;
        }
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ContentHandler#startElement(String,String,String,Attributes)}.
     */
    public void startElement(String     uri,
                             String     localName,
                             String     rawName,
                             Attributes attributes) throws SAXException {
        // Check If we should halt early.
        if (HaltingThread.hasBeenHalted()) {
            throw new SAXException(new InterruptedIOException());
        }

        if (inProlog) {
            inProlog = false;
            try {
                isStandalone = parser.getFeature
                    ("http://xml.org/sax/features/is-standalone");
            } catch (SAXNotRecognizedException ex) {
            }
            try {
                xmlVersion = (String) parser.getProperty
                    ("http://xml.org/sax/properties/document-xml-version");
            } catch (SAXNotRecognizedException ex) {
            }
        }

        // Namespaces resolution
        int len = attributes.getLength();
        namespaces.push();
        String version = null;
        for (int i = 0; i < len; i++) {
            String aname = attributes.getQName(i);
            int slen = aname.length();
            if (slen < 5)
                continue;
            if (aname.equals("version")) {
                version = attributes.getValue(i);
                continue;
            }
            if (!aname.startsWith("xmlns"))
                continue;
            if (slen == 5) {
                String ns = attributes.getValue(i);
                if (ns.length() == 0)
                    ns = null;
                namespaces.put("", ns);
            } else if (aname.charAt(5) == ':') {
                String ns = attributes.getValue(i);
                if (ns.length() == 0) {
                    ns = null;
                }
                namespaces.put(aname.substring(6), ns);
            }
        }

        // Add any collected String Data before element.
        appendStringData();

        // Element creation
        Element e;
        int idx = rawName.indexOf(':');
        String nsp = (idx == -1 || idx == rawName.length()-1)
            ? ""
            : rawName.substring(0, idx);
        String nsURI = namespaces.get(nsp);
        if (currentNode == null) {
            implementation = getDOMImplementation(version);
            document = implementation.createDocument(nsURI, rawName, null);
            Iterator i = preInfo.iterator();
            currentNode = e = document.getDocumentElement();
            while (i.hasNext()) {
                PreInfo pi = (PreInfo)i.next();
                Node n = pi.createNode(document);
                document.insertBefore(n, e);
            }
            preInfo = null;
        } else {
            e = document.createElementNS(nsURI, rawName);
            currentNode.appendChild(e);
            currentNode = e;
        }

        // Storage of the line number.
        if (createDocumentDescriptor && locator != null) {
            documentDescriptor.setLocation(e,
                                           locator.getLineNumber(),
                                           locator.getColumnNumber());
        }

        // Attributes creation
        for (int i = 0; i < len; i++) {
            String aname = attributes.getQName(i);
            if (aname.equals("xmlns")) {
                e.setAttributeNS(XMLSupport.XMLNS_NAMESPACE_URI,
                                 aname,
                                 attributes.getValue(i));
            } else {
                idx = aname.indexOf(':');
                nsURI = (idx == -1)
                    ? null
                    : namespaces.get(aname.substring(0, idx));
                e.setAttributeNS(nsURI, aname, attributes.getValue(i));
            }
        }
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ContentHandler#endElement(String,String,String)}.
     */
    public void endElement(String uri, String localName, String rawName)
        throws SAXException {
        appendStringData(); // add string data if any.

        if (currentNode != null)
            currentNode = currentNode.getParentNode();
        namespaces.pop();
    }

    public void appendStringData() {
        if (!stringContent) return;

        String str = stringBuffer.toString();
        stringBuffer.setLength(0); // reuse buffer.
        stringContent = false;
        if (currentNode == null) {
            if (inCDATA) preInfo.add(new CDataInfo(str));
            else         preInfo.add(new TextInfo(str));
        } else {
            Node n;
            if (inCDATA) n = document.createCDATASection(str);
            else         n = document.createTextNode(str);
            currentNode.appendChild(n);
        }
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ContentHandler#characters(char[],int,int)}.
     */
    public void characters(char[] ch, int start, int length)
        throws SAXException {
        stringBuffer.append(ch, start, length);
        stringContent = true;
    }


    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ContentHandler#ignorableWhitespace(char[],int,int)}.
     */
    public void ignorableWhitespace(char[] ch,
                                    int start,
                                    int length)
        throws SAXException {
        stringBuffer.append(ch, start, length);
        stringContent = true;
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ContentHandler#processingInstruction(String,String)}.
     */
    public void processingInstruction(String target, String data)
        throws SAXException {
        if (inDTD)
            return;

        appendStringData(); // Add any collected String Data before PI

        if (currentNode == null)
            preInfo.add(new ProcessingInstructionInfo(target, data));
        else
            currentNode.appendChild
                (document.createProcessingInstruction(target, data));
    }

    // LexicalHandler /////////////////////////////////////////////////////////

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ext.LexicalHandler#startDTD(String,String,String)}.
     */
    public void startDTD(String name, String publicId, String systemId)
        throws SAXException {
        appendStringData(); // Add collected string data before entering DTD
        inDTD = true;
    }

    /**
     * <b>SAX</b>: Implements {@link org.xml.sax.ext.LexicalHandler#endDTD()}.
     */
    public void endDTD() throws SAXException {
        inDTD = false;
    }

    /**
     * <b>SAX</b>: Implements
     * {@link org.xml.sax.ext.LexicalHandler#startEntity(String)}.
     */
    public void startEntity(String name) throws SAXException {
    }

    /**
     * <b>SAX</b>: Implements
     * {@link org.xml.sax.ext.LexicalHandler#endEntity(String)}.
     */
    public void endEntity(String name) throws SAXException {
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ext.LexicalHandler#startCDATA()}.
     */
    public void startCDATA() throws SAXException {
        appendStringData(); // Add any collected String Data before CData
        inCDATA       = true;
        stringContent = true; // always create CDATA even if empty.
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ext.LexicalHandler#endCDATA()}.
     */
    public void endCDATA() throws SAXException {
        appendStringData(); // Add the CDATA section
        inCDATA = false;
    }

    /**
     * <b>SAX</b>: Implements
     * {@link org.xml.sax.ext.LexicalHandler#comment(char[],int,int)}.
     */
    public void comment(char[] ch, int start, int length) throws SAXException {
        if (inDTD) return;
        appendStringData();

        String str = new String(ch, start, length);
        if (currentNode == null) {
            preInfo.add(new CommentInfo(str));
        } else {
            currentNode.appendChild(document.createComment(str));
        }
    }
}
