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

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStyleSheetNode;
import org.apache.flex.forks.batik.css.engine.StyleSheet;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.StyleSheetFactory;
import org.apache.flex.forks.batik.dom.StyleSheetProcessingInstruction;
import org.apache.flex.forks.batik.dom.util.HashTable;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

/**
 * This class provides an implementation of the 'xml-stylesheet' processing
 * instructions.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGStyleSheetProcessingInstruction.java 579230 2007-09-25 12:52:48Z cam $
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
        SVGOMDocument svgDoc = (SVGOMDocument) getOwnerDocument();
        ParsedURL url = svgDoc.getParsedURL();
        String href = (String)getPseudoAttributes().get("href");
        if (url != null) {
            return new ParsedURL(url, href).toString();
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
                ParsedURL durl = doc.getParsedURL();
                ParsedURL burl = new ParsedURL(durl, href);
                CSSEngine e = doc.getCSSEngine();
                
                styleSheet = e.parseStyleSheet(burl, media);
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
