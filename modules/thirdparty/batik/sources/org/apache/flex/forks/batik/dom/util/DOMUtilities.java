/*

   Copyright 2000-2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom.util;

import java.io.IOException;
import java.io.Writer;

import org.apache.flex.forks.batik.xml.XMLUtilities;
import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

/**
 * A collection of utility functions for the DOM.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DOMUtilities.java,v 1.13 2005/02/22 09:13:02 cam Exp $
 */
public class DOMUtilities extends XMLUtilities {
    /**
     * Do not need to be instantiated.
     */
    protected DOMUtilities() {
    }

    /**
     * Writes the given document using the given writer.
     */
    public static void writeDocument(Document doc, Writer w) throws IOException {
        for (Node n = doc.getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            writeNode(n, w);
        }
    }

    /**
     * Writes a node using the given writer.
     */
    public static void writeNode(Node n, Writer w) throws IOException {
        switch (n.getNodeType()) {
        case Node.ELEMENT_NODE:
            w.write("<");
            w.write(n.getNodeName());

            if (n.hasAttributes()) {
                NamedNodeMap attr = n.getAttributes();
                int len = attr.getLength();
                for (int i = 0; i < len; i++) {
                    Attr a = (Attr)attr.item(i);
                    w.write(" ");
                    w.write(a.getNodeName());
                    w.write("=\"");
                    w.write(contentToString(a.getNodeValue()));
                    w.write("\"");
                }
            }

            Node c = n.getFirstChild();
            if (c != null) {
                w.write(">");
                for (; c != null;
                     c = c.getNextSibling()) {
                    writeNode(c, w);
                }
                w.write("</");
                w.write(n.getNodeName());
                w.write(">");
            } else {
                w.write("/>");
            }
            break;
        case Node.TEXT_NODE:
            w.write(contentToString(n.getNodeValue()));
            break;
        case Node.CDATA_SECTION_NODE:
            w.write("<![CDATA[");
            w.write(n.getNodeValue());
            w.write("]]>");
            break;
        case Node.ENTITY_REFERENCE_NODE:
            w.write("&");
            w.write(n.getNodeName());
            w.write(";");
            break;
        case Node.PROCESSING_INSTRUCTION_NODE:
            w.write("<?");
            w.write(n.getNodeName());
            // TD: Bug #19392
            w.write(" ");
            w.write(n.getNodeValue());
            w.write("?>");
            break;
        case Node.COMMENT_NODE:
            w.write("<!--");
            w.write(n.getNodeValue());
            w.write("-->");
            break;
        case Node.DOCUMENT_TYPE_NODE: {
            DocumentType dt = (DocumentType)n;
            w.write ("<!DOCTYPE "); 
            w.write (n.getOwnerDocument().getDocumentElement().getNodeName());
            String pubID = dt.getPublicId();
            if (pubID != null) {
                w.write (" PUBLIC \"" + dt.getNodeName() + "\" \"" +
                           pubID + "\">");
            } else {
                String sysID = dt.getSystemId();
                if (sysID != null) 
                    w.write (" SYSTEM \"" + sysID + "\">");
            }
        }
            break;
        default:
            throw new Error("Internal error (" + n.getNodeType() + ")");
        }
    }

    /**
     * Returns the given content value transformed to replace invalid
     * characters with entities.
     */
    public static String contentToString(String s) {
        StringBuffer result = new StringBuffer();

        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);

            switch (c) {
            case '<':
                result.append("&lt;");
                break;
            case '>':
                result.append("&gt;");
                break;
            case '&':
                result.append("&amp;");
                break;
            case '"':
                result.append("&quot;");
                break;
            case '\'':
                result.append("&apos;");
                break;
            default:
                result.append(c);
            }
        }
        
        return result.toString();
    }

    /**
     * Deep clones a document using the given DOM implementation.
     */
    public static Document deepCloneDocument(Document doc, DOMImplementation impl) {
        Element root = doc.getDocumentElement();
        Document result = impl.createDocument(root.getNamespaceURI(),
                                              root.getNodeName(),
                                              null);
        Element rroot = result.getDocumentElement();
        boolean before = true;
        for (Node n = doc.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (n == root) {
                before = false;
                if (root.hasAttributes()) {
                    NamedNodeMap attr = root.getAttributes();
                    int len = attr.getLength();
                    for (int i = 0; i < len; i++) {
                        rroot.setAttributeNode((Attr)result.importNode(attr.item(i),
                                                                       true));
                    }
                }
                for (Node c = root.getFirstChild();
                     c != null;
                     c = c.getNextSibling()) {
                    rroot.appendChild(result.importNode(c, true));
                }
            } else {
                if (n.getNodeType() != Node.DOCUMENT_TYPE_NODE) {
                    if (before) {
                        result.insertBefore(result.importNode(n, true), rroot);
                    } else {
                        result.appendChild(result.importNode(n, true));
                    }
                }
            }
        }
        return result;
    }

    /**
     * Tests whether the given string is a valid name.
     */
    public static boolean isValidName(String s) {
	char c = s.charAt(0);
        int d = c / 32;
        int m = c % 32;
	if ((NAME_FIRST_CHARACTER[d] & (1 << m)) == 0) {
	    return false;
	}
	int len = s.length();
	for (int i = 1; i < len; i++) {
	    c = s.charAt(i);
	    d = c / 32;
	    m = c % 32;
	    if ((NAME_CHARACTER[d] & (1 << m)) == 0) {
		return false;
	    }
	}
	return true;
    }
    
    /**
     * Tests whether the given string is a valid prefix.
     * This method assume that isValidName(s) is true.
     */
    public static boolean isValidPrefix(String s) {
	return s.indexOf(':') == -1;
    }

    /**
     * Gets the prefix from the given qualified name.
     * This method assume that isValidName(s) is true.
     */
    public static String getPrefix(String s) {
	int i = s.indexOf(':');
	return (i == -1 || i == s.length()-1)
	    ? null
	    : s.substring(0, i);
    }
    
    /**
     * Gets the local name from the given qualified name.
     * This method assume that isValidName(s) is true.
     */
    public static String getLocalName(String s) {
	int i = s.indexOf(':');
	return (i == -1 || i == s.length()-1)
	    ? s
	    : s.substring(i + 1);
    }

    /**
     * Parses a 'xml-stylesheet' processing instruction data section and
     * puts the pseudo attributes in the given table.
     */
    public static void parseStyleSheetPIData(String data, HashTable table) {
        // !!! Internationalization
	char c;
	int i = 0;
	// Skip leading whitespaces
	while (i < data.length()) {
	    c = data.charAt(i);
	    if (!XMLUtilities.isXMLSpace(c)) {
		break;
	    }
	    i++;
	}
	while (i < data.length()) {
	    // Parse the pseudo attribute name
	    c = data.charAt(i);
	    int d = c / 32;
	    int m = c % 32;
	    if ((NAME_FIRST_CHARACTER[d] & (1 << m)) == 0) {
		throw new DOMException(DOMException.INVALID_CHARACTER_ERR,
				       "Wrong name initial:  " + c);
	    }
	    StringBuffer ident = new StringBuffer();
	    ident.append(c);
	    while (++i < data.length()) {
		c = data.charAt(i);
		d = c / 32;
		m = c % 32;
		if ((NAME_CHARACTER[d] & (1 << m)) == 0) {
		    break;
		}
		ident.append(c);
	    }
	    if (i >= data.length()) {
		throw new DOMException(DOMException.SYNTAX_ERR,
				       "Wrong xml-stylesheet data: " + data);
	    }
	    // Skip whitespaces
	    while (i < data.length()) {
		c = data.charAt(i);
		if (!XMLUtilities.isXMLSpace(c)) {
		    break;
		}
		i++;
	    }
	    if (i >= data.length()) {
		throw new DOMException(DOMException.SYNTAX_ERR,
				       "Wrong xml-stylesheet data: " + data);
	    }
	    // The next char must be '='
	    if (data.charAt(i) != '=') {
		throw new DOMException(DOMException.SYNTAX_ERR,
				       "Wrong xml-stylesheet data: " + data);
	    }
	    i++;
	    // Skip whitespaces
	    while (i < data.length()) {
		c = data.charAt(i);
		if (!XMLUtilities.isXMLSpace(c)) {
		    break;
		}
		i++;
	    }
	    if (i >= data.length()) {
		throw new DOMException(DOMException.SYNTAX_ERR,
				       "Wrong xml-stylesheet data: " + data);
	    }
	    // The next char must be '\'' or '"'
	    c = data.charAt(i);
	    i++;
	    StringBuffer value = new StringBuffer();
	    if (c == '\'') {
		while (i < data.length()) {
		    c = data.charAt(i);
		    if (c == '\'') {
			break;
		    }
		    value.append(c);
		    i++;
		}
		if (i >= data.length()) {
		    throw new DOMException(DOMException.SYNTAX_ERR,
					   "Wrong xml-stylesheet data: " +
                                           data);
		}
	    } else if (c == '"') {
		while (i < data.length()) {
		    c = data.charAt(i);
		    if (c == '"') {
			break;
		    }
		    value.append(c);
		    i++;
		}
		if (i >= data.length()) {
		    throw new DOMException(DOMException.SYNTAX_ERR,
					   "Wrong xml-stylesheet data: " +
                                           data);
		}
	    } else {
		throw new DOMException(DOMException.SYNTAX_ERR,
				       "Wrong xml-stylesheet data: " + data);
	    }
	    table.put(ident.toString().intern(), value.toString());
	    i++;
	    // Skip whitespaces
	    while (i < data.length()) {
		c = data.charAt(i);
		if (!XMLUtilities.isXMLSpace(c)) {
		    break;
		}
		i++;
	    }
	}
    }
}
