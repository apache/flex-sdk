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

import org.apache.flex.forks.batik.util.XMLConstants;
import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * This class provides support for XML features.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: XMLSupport.java 476924 2006-11-19 21:13:26Z dvholten $
 */
public final class XMLSupport implements XMLConstants {

    /**
     * This class does not need to be instanciated.
     */
    private XMLSupport() {
    }

    /**
     * Returns the xml:lang attribute value of the given element.
     */
    public static String getXMLLang(Element elt) {
        Attr attr = elt.getAttributeNodeNS(XML_NAMESPACE_URI, "lang");
        if (attr != null) {
            return attr.getNodeValue();
        }
        for (Node n = elt.getParentNode(); n != null; n = n.getParentNode()) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                attr = ((Element)n).getAttributeNodeNS(XML_NAMESPACE_URI,
                                                       "lang");
                if (attr != null) {
                    return attr.getNodeValue();
                }
            }
        }
        return "en";
    }

    /**
     * Returns the xml:space attribute value of the given element.
     */
    public static String getXMLSpace(Element elt) {
        Attr attr = elt.getAttributeNodeNS(XML_NAMESPACE_URI, "space");
        if (attr != null) {
            return attr.getNodeValue();
        }
        for (Node n = elt.getParentNode(); n != null; n = n.getParentNode()) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                attr = ((Element)n).getAttributeNodeNS(XML_NAMESPACE_URI,
                                                       "space");
                if (attr != null) {
                    return attr.getNodeValue();
                }
            }
        }
        return "default";
    }

    /**
     * Strips the white spaces in the given string according to the xml:space
     * attribute recommended behaviour when it has the 'default' value.
     */
    public static String defaultXMLSpace(String data) {
        int nChars = data.length();
        StringBuffer result = new StringBuffer( nChars );
        boolean space = false;
        for (int i = 0; i < nChars; i++) {
            char c = data.charAt(i);
            switch (c) {
            case 10:               // fallthrough is intended
            case 13:
                space = false;
                break;
            case ' ':              // fallthrough is intended
            case '\t':
                if (!space) {
                    result.append(' ');
                    space = true;
                }
                break;
            default:
                result.append(c);
                space = false;
            }
        }
        return result.toString().trim();
    }

    /**
     * Strips the white spaces in the given string according to the xml:space
     * attribute recommended behaviour when it has the 'preserve' value.
     */
    public static String preserveXMLSpace(String data) {
        int nChars = data.length();
        StringBuffer result = new StringBuffer( nChars );
        for (int i = 0; i < data.length(); i++) {
            char c = data.charAt(i);
            switch (c) {
            case 10:               // fallthrough is intended
            case 13:
            case '\t':
                result.append(' ');
                break;
            default:
                result.append(c);
            }
        }
        return result.toString();
    }
}
