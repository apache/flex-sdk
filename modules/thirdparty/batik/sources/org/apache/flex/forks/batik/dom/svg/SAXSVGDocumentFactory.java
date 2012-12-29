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

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.util.MissingResourceException;
import java.util.Properties;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.svg12.SVG12DOMImplementation;
import org.apache.flex.forks.batik.dom.util.SAXDocumentFactory;
import org.apache.flex.forks.batik.util.MimeTypeConstants;
import org.apache.flex.forks.batik.util.ParsedURL;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.svg.SVGDocument;

/**
 * This class contains methods for creating SVGDocument instances
 * from an URI using SAX2.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SAXSVGDocumentFactory.java 579230 2007-09-25 12:52:48Z cam $
 */
public class SAXSVGDocumentFactory
    extends    SAXDocumentFactory
    implements SVGDocumentFactory {

    public static final Object LOCK = new Object();

    /**
     * Key used for public identifiers
     */
    public static final String KEY_PUBLIC_IDS = "publicIds";

    /**
     * Key used for public identifiers
     */
    public static final String KEY_SKIPPABLE_PUBLIC_IDS = "skippablePublicIds";

    /**
     * Key used for the skippable DTD substitution
     */
    public static final String KEY_SKIP_DTD = "skipDTD";

    /**
     * Key used for system identifiers
     */
    public static final String KEY_SYSTEM_ID = "systemId.";

    /**
     * The dtd public IDs resource bundle class name.
     */
    protected static final String DTDIDS =
        "org.apache.flex.forks.batik.dom.svg.resources.dtdids";

    /**
     * Constant for HTTP content type header charset field.
     */
    protected static final String HTTP_CHARSET = "charset";

    /**
     * The accepted DTD public IDs.
     */
    protected static String dtdids;

    /**
     * The DTD public IDs we know we can skip.
     */
    protected static String skippable_dtdids;

    /**
     * The DTD content to use when skipping
     */
    protected static String skip_dtd;

    /**
     * The ResourceBunder for the public and system ids
     */
    protected static Properties dtdProps;

    /**
     * Creates a new SVGDocumentFactory object.
     * @param parser The SAX2 parser classname.
     */
    public SAXSVGDocumentFactory(String parser) {
        super(SVGDOMImplementation.getDOMImplementation(), parser);
    }

    /**
     * Creates a new SVGDocumentFactory object.
     * @param parser The SAX2 parser classname.
     * @param dd Whether a document descriptor must be generated.
     */
    public SAXSVGDocumentFactory(String parser, boolean dd) {
        super(SVGDOMImplementation.getDOMImplementation(), parser, dd);
    }

    public SVGDocument createSVGDocument(String uri) throws IOException {
        return (SVGDocument)createDocument(uri);
    }

    /**
     * Creates a SVG Document instance.
     * @param uri The document URI.
     * @param inp The document input stream.
     * @exception IOException if an error occured while reading the document.
     */
    public SVGDocument createSVGDocument(String uri, InputStream inp)
        throws IOException {
        return (SVGDocument)createDocument(uri, inp);
    }

    /**
     * Creates a SVG Document instance.
     * @param uri The document URI.
     * @param r The document reader.
     * @exception IOException if an error occured while reading the document.
     */
    public SVGDocument createSVGDocument(String uri, Reader r)
        throws IOException {
        return (SVGDocument)createDocument(uri, r);
    }

    /**
     * Creates a SVG Document instance.
     * This method supports gzipped sources.
     * @param uri The document URI.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String uri) throws IOException {
        ParsedURL purl = new ParsedURL(uri);

        InputStream is = purl.openStream(MimeTypeConstants.MIME_TYPES_SVG);

        InputSource isrc = new InputSource(is);

        // now looking for a charset encoding in the content type such
        // as "image/svg+xml; charset=iso8859-1" this is not official
        // for image/svg+xml yet! only for text/xml and maybe
        // for application/xml
        String contentType = purl.getContentType();
        int cindex = -1;
        if (contentType != null) {
            contentType = contentType.toLowerCase();
            cindex = contentType.indexOf(HTTP_CHARSET);
        }

        String charset = null;
        if (cindex != -1) {
            int i                 = cindex + HTTP_CHARSET.length();
            int eqIdx = contentType.indexOf('=', i);
            if (eqIdx != -1) {
                eqIdx++; // no one is interested in the equals sign...

                // The patch had ',' as the terminator but I suspect
                // that is the delimiter between possible charsets,
                // but if another 'attribute' were in the accept header
                // charset would be terminated by a ';'.  So I look
                // for both and take to closer of the two.
                int idx     = contentType.indexOf(',', eqIdx);
                int semiIdx = contentType.indexOf(';', eqIdx);
                if ((semiIdx != -1) && ((semiIdx < idx) || (idx == -1)))
                    idx = semiIdx;
                if (idx != -1)
                    charset = contentType.substring(eqIdx, idx);
                else
                    charset = contentType.substring(eqIdx);
                charset = charset.trim();
                isrc.setEncoding(charset);
            }
        }

        isrc.setSystemId(uri);

        SVGOMDocument doc = (SVGOMDocument) super.createDocument
            (SVGDOMImplementation.SVG_NAMESPACE_URI, "svg", uri, isrc);
        doc.setParsedURL(purl);
        doc.setDocumentInputEncoding(charset);
        doc.setXmlStandalone(isStandalone);
        doc.setXmlVersion(xmlVersion);

        return doc;
    }

    /**
     * Creates a SVG Document instance.
     * @param uri The document URI.
     * @param inp The document input stream.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String uri, InputStream inp)
        throws IOException {
        Document doc;
        InputSource is = new InputSource(inp);
        is.setSystemId(uri);

        try {
            doc = super.createDocument
                (SVGDOMImplementation.SVG_NAMESPACE_URI, "svg", uri, is);
            if (uri != null) {
                ((SVGOMDocument)doc).setParsedURL(new ParsedURL(uri));
            }

            AbstractDocument d = (AbstractDocument) doc;
            d.setDocumentURI(uri);
            d.setXmlStandalone(isStandalone);
            d.setXmlVersion(xmlVersion);
        } catch (MalformedURLException e) {
            throw new IOException(e.getMessage());
        }
        return doc;
    }

    /**
     * Creates a SVG Document instance.
     * @param uri The document URI.
     * @param r The document reader.
     * @exception IOException if an error occured while reading the document.
     */
    public Document createDocument(String uri, Reader r)
        throws IOException {
        Document doc;
        InputSource is = new InputSource(r);
        is.setSystemId(uri);

        try {
            doc = super.createDocument
                (SVGDOMImplementation.SVG_NAMESPACE_URI, "svg", uri, is);
            if (uri != null) {
                ((SVGOMDocument)doc).setParsedURL(new ParsedURL(uri));
            }

            AbstractDocument d = (AbstractDocument) doc;
            d.setDocumentURI(uri);
            d.setXmlStandalone(isStandalone);
            d.setXmlVersion(xmlVersion);
        } catch (MalformedURLException e) {
            throw new IOException(e.getMessage());
        }
        return doc;
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
        if (!SVGDOMImplementation.SVG_NAMESPACE_URI.equals(ns) ||
            !"svg".equals(root)) {
            throw new RuntimeException("Bad root element");
        }
        return createDocument(uri);
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
        if (!SVGDOMImplementation.SVG_NAMESPACE_URI.equals(ns) ||
            !"svg".equals(root)) {
            throw new RuntimeException("Bad root element");
        }
        return createDocument(uri, is);
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
        if (!SVGDOMImplementation.SVG_NAMESPACE_URI.equals(ns) ||
            !"svg".equals(root)) {
            throw new RuntimeException("Bad root element");
        }
        return createDocument(uri, r);
    }

    public DOMImplementation getDOMImplementation(String ver) {
        if (ver == null || ver.length() == 0
                || ver.equals("1.0") || ver.equals("1.1")) {
            return SVGDOMImplementation.getDOMImplementation();
        } else if (ver.equals("1.2")) {
            return SVG12DOMImplementation.getDOMImplementation();
        }
        throw new RuntimeException("Unsupport SVG version '" + ver + "'");
    }

    /**
     * <b>SAX</b>: Implements {@link
     * org.xml.sax.ContentHandler#startDocument()}.
     */
    public void startDocument() throws SAXException {
        super.startDocument();
        // Do not assume namespace declarations when no DTD has been specified.
        // namespaces.put("", SVGDOMImplementation.SVG_NAMESPACE_URI);
        // namespaces.put("xlink", XLinkSupport.XLINK_NAMESPACE_URI);
    }

    /**
     * <b>SAX2</b>: Implements {@link
     * org.xml.sax.EntityResolver#resolveEntity(String,String)}.
     */
    public InputSource resolveEntity(String publicId, String systemId)
        throws SAXException {
        try {
            synchronized (LOCK) {
                // Bootstrap if needed - move to a static block???
                if (dtdProps == null) {
                    dtdProps = new Properties();
                    try {
                        Class cls = SAXSVGDocumentFactory.class;
                        InputStream is = cls.getResourceAsStream
                            ("resources/dtdids.properties");
                        dtdProps.load(is);
                    } catch (IOException ioe) {
                        throw new SAXException(ioe);
                    }
                }

                if (dtdids == null)
                    dtdids = dtdProps.getProperty(KEY_PUBLIC_IDS);

                if (skippable_dtdids == null)
                    skippable_dtdids =
                        dtdProps.getProperty(KEY_SKIPPABLE_PUBLIC_IDS);

                if (skip_dtd == null)
                    skip_dtd = dtdProps.getProperty(KEY_SKIP_DTD);
            }

            if (publicId == null)
                return null; // Let SAX Parser find it.

            if (!isValidating &&
                (skippable_dtdids.indexOf(publicId) != -1)) {
                // We are not validating and this is a DTD we can
                // safely skip so do it...  Here we provide just enough
                // of the DTD to keep stuff running (set svg and
                // xlink namespaces).
                return new InputSource(new StringReader(skip_dtd));
            }

            if (dtdids.indexOf(publicId) != -1) {
                String localSystemId =
                    dtdProps.getProperty(KEY_SYSTEM_ID +
                                         publicId.replace(' ', '_'));

                if (localSystemId != null && !"".equals(localSystemId)) {
                    return new InputSource
                        (getClass().getResource(localSystemId).toString());
                }
            }
        } catch (MissingResourceException e) {
            throw new SAXException(e);
        }
        // Let the SAX parser find the entity.
        return null;
    }
}
