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
package org.apache.flex.forks.batik.bridge;

import java.io.IOException;
import java.net.MalformedURLException;

import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGDocument;

/**
 * This class is used to resolve the URI that can be found in a SVG document.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: URIResolver.java 475477 2006-11-15 22:44:28Z cam $
 */
public class URIResolver {
    /**
     * The reference document.
     */
    protected SVGOMDocument document;

    /**
     * The document URI.
     */
    protected String documentURI;

    /**
     * The document loader.
     */
    protected DocumentLoader documentLoader;

    /**
     * Creates a new URI resolver object.
     * @param doc The reference document.
     * @param dl The document loader.
     */
    public URIResolver(SVGDocument doc, DocumentLoader dl) {
        document = (SVGOMDocument)doc;
        documentLoader = dl;
    }

    /**
     * Imports the Element referenced by the given URI on Element
     * <tt>ref</tt>.
     * @param uri The element URI.
     * @param ref The Element in the DOM tree to evaluate <tt>uri</tt>
     *            from.  
     * @return The referenced element or null if element can't be found.
     */
    public Element getElement(String uri, Element ref)
        throws MalformedURLException, IOException {

        Node n = getNode(uri, ref);
        if (n == null) {
            return null;
        } else if (n.getNodeType() == Node.DOCUMENT_NODE) {
            throw new IllegalArgumentException();
        } else {
            return (Element)n;
        }
    }

    /**
     * Imports the Node referenced by the given URI on Element
     * <tt>ref</tt>.
     * @param uri The element URI.
     * @param ref The Element in the DOM tree to evaluate <tt>uri</tt>
     *            from. 
     * @return The referenced Node/Document or null if element can't be found.
     */
    public Node getNode(String uri, Element ref)
        throws MalformedURLException, IOException, SecurityException {

        String baseURI = getRefererBaseURI(ref);
        // System.err.println("baseURI: " + baseURI);
        // System.err.println("URI: " + uri);
        if (baseURI == null && uri.charAt(0) == '#') {
            return getNodeByFragment(uri.substring(1), ref);
        }

        ParsedURL purl = new ParsedURL(baseURI, uri);
        // System.err.println("PURL: " + purl);

        if (documentURI == null)
            documentURI = document.getURL();

        String    frag  = purl.getRef();
        if ((frag != null) && (documentURI != null)) {
            ParsedURL pDocURL = new ParsedURL(documentURI);
            // System.out.println("doc: " + pDocURL);
            // System.out.println("Purl: " + purl);
            if (pDocURL.sameFile(purl)) {
                // System.out.println("match");
                return document.getElementById(frag);
            }
        }

        // uri is not a reference into this document, so load the 
        // document it does reference after doing a security 
        // check with the UserAgent
        ParsedURL pDocURL = null;
        if (documentURI != null) {
            pDocURL = new ParsedURL(documentURI);
        }

        UserAgent userAgent = documentLoader.getUserAgent();
        userAgent.checkLoadExternalResource(purl, pDocURL);

        String purlStr = purl.toString();
        if (frag != null) {
            purlStr = purlStr.substring(0, purlStr.length()-(frag.length()+1));
        }

        Document doc = documentLoader.loadDocument(purlStr);
        if (frag != null)
            return doc.getElementById(frag);
        return doc;
    }

    /**
     * Returns the base URI of the referer element.
     */
    protected String getRefererBaseURI(Element ref) {
        return ((AbstractNode) ref).getBaseURI();
    }

    /**
     * Returns the node referenced by the given fragment identifier.
     * This is called when the whole URI just contains a fragment identifier
     * and there is no XML Base URI in effect.
     * @param frag the URI fragment
     * @param ref  the context element from which to resolve the URI fragment
     */
    protected Node getNodeByFragment(String frag, Element ref) {
        return ref.getOwnerDocument().getElementById(frag);
    }
}
