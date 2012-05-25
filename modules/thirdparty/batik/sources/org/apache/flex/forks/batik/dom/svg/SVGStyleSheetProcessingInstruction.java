/*

   Copyright 2001-2003  The Apache Software Foundation 

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

import java.net.MalformedURLException;
import java.net.URL;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStyleSheetNode;
import org.apache.flex.forks.batik.css.engine.StyleSheet;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.StyleSheetFactory;
import org.apache.flex.forks.batik.dom.StyleSheetProcessingInstruction;
import org.apache.flex.forks.batik.dom.util.HashTable;
import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

/**
 * This class provides an implementation of the 'xml-stylesheet' processing
 * instructions.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGStyleSheetProcessingInstruction.java,v 1.8 2004/08/18 07:13:18 vhardy Exp $
 */
public class SVGStyleSheetProcessingInstruction
    extends StyleSheetProcessingInstruction
    implements CSSStyleSheetNode {
    
    /**
     * The style-sheet.
     */
    protected StyleSheet styleSheet;

    /**
     * Creates a new ProcessingInstruction object.
     */
    protected SVGStyleSheetProcessingInstruction() {
    }

    /**
     * Creates a new ProcessingInstruction object.
     */
    public SVGStyleSheetProcessingInstruction(String            data,
                                              AbstractDocument  owner,
                                              StyleSheetFactory f) {
        super(data, owner, f);
    }

    /**
     * Returns the URI of the referenced stylesheet.
     */
    public String getStyleSheetURI() {
        SVGOMDocument svgDoc;
        svgDoc = (SVGOMDocument)getOwnerDocument();
        URL url = svgDoc.getURLObject();
        String href = (String)getPseudoAttributes().get("href");
        if (url != null) {
            try {
                return new URL(url, href).toString();
            } catch (MalformedURLException e) {
            }
        }
        return href;
    }

    /**
     * Returns the associated style-sheet.
     */
    public StyleSheet getCSSStyleSheet() {
        if (styleSheet == null) {
            HashTable attrs = getPseudoAttributes();
            String type = (String)attrs.get("type");

            if ("text/css".equals(type)) {
                String title     = (String)attrs.get("title");
                String media     = (String)attrs.get("media");
                String href      = (String)attrs.get("href");
                String alternate = (String)attrs.get("alternate");
                SVGOMDocument doc = (SVGOMDocument)getOwnerDocument();
                URL durl = doc.getURLObject();
                URL burl = durl;
                try {
                    burl = new URL(durl, href);
                } catch (Exception ex) {
                }
                CSSEngine e = doc.getCSSEngine();
                
                styleSheet = e.parseStyleSheet
                    (burl, media);
                styleSheet.setAlternate("yes".equals(alternate));
                styleSheet.setTitle(title);
            }
        }
        return styleSheet;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.ProcessingInstruction#setData(String)}.
     */
    public void setData(String data) throws DOMException {
	super.setData(data);
        styleSheet = null;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGStyleSheetProcessingInstruction();
    }
}
