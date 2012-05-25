/*

   Copyright 1999-2003  The Apache Software Foundation 

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

import java.net.URL;

import org.apache.flex.forks.batik.css.engine.CSSImportedElementRoot;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.XMLConstants;
import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * This class provides support for the xml:base attribute.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: XMLBaseSupport.java,v 1.6 2004/10/30 18:38:04 deweese Exp $
 */
public class XMLBaseSupport implements XMLConstants {
    
    /**
     * This class does not need to be instanciated.
     */
    protected XMLBaseSupport() {
    }

    /**
     * Returns the xml:base attribute value of the given element.
     */
    public static String getXMLBase(Element elt) {
        return elt.getAttributeNS(XML_NAMESPACE_URI, "base");
    }

    /**
     * Returns the xml:base attribute value of the given element
     * Resolving any dependency on parent bases if needed.
     */
    public static String getCascadedXMLBase(Element elt) {
        String base = null;
        Node n = elt.getParentNode();
        while (n != null) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                base = getCascadedXMLBase((Element)n);
                break;
            }
            if (n instanceof CSSImportedElementRoot) {
                n = ((CSSImportedElementRoot)n).getCSSParentElement();
            } else {
                n = n.getParentNode();
            }
        }
        if (base == null) {
            SVGOMDocument svgDoc;
            svgDoc = (SVGOMDocument)elt.getOwnerDocument();
            URL url = svgDoc.getURLObject();
            if (url != null) {
                base = url.toString();
            }
        }
        Attr attr = elt.getAttributeNodeNS(XML_NAMESPACE_URI, "base");
        if (attr != null) {
            if (base == null) {
                base = attr.getNodeValue();
            } else {
                base = new ParsedURL(base, attr.getNodeValue()).toString();
            }
        }
        return base;
    }

}
