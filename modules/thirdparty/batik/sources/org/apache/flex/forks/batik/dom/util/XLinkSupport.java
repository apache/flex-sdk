/*

   Copyright 2000-2001  The Apache Software Foundation 

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

import org.w3c.dom.DOMException;
import org.w3c.dom.Element;

/**
 * This class provides support for XLink features.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: XLinkSupport.java,v 1.4 2004/08/18 07:13:37 vhardy Exp $
 */
public class XLinkSupport {
    /**
     * The xlink namespace URI.
     */
    public final static String XLINK_NAMESPACE_URI =
	"http://www.w3.org/1999/xlink";

    /**
     * Returns the value of the 'xlink:type' attribute of the given element.
     */
    public static String getXLinkType(Element elt) {
	return elt.getAttributeNS(XLINK_NAMESPACE_URI, "type");
    }

    /**
     * Sets the value of the 'xlink:type' attribute of the given element.
     */
    public static void setXLinkType(Element elt, String str) {
	if (!"simple".equals(str)   &&
	    !"extended".equals(str) &&
	    !"locator".equals(str)  &&
	    !"arc".equals(str)) {
	    throw new DOMException(DOMException.SYNTAX_ERR,
                                   "xlink:type='" + str + "'");
	}
	elt.setAttributeNS(XLINK_NAMESPACE_URI, "type", str);
    }

    /**
     * Returns the value of the 'xlink:role' attribute of the given element.
     */
    public static String getXLinkRole(Element elt) {
	return elt.getAttributeNS(XLINK_NAMESPACE_URI, "role");
    }

    /**
     * Sets the value of the 'xlink:role' attribute of the given element.
     */
    public static void setXLinkRole(Element elt, String str) {
	elt.setAttributeNS(XLINK_NAMESPACE_URI, "role", str);
    }

    /**
     * Returns the value of the 'xlink:arcrole' attribute of the given element.
     */
    public static String getXLinkArcRole(Element elt) {
	return elt.getAttributeNS(XLINK_NAMESPACE_URI, "arcrole");
    }

    /**
     * Sets the value of the 'xlink:arcrole' attribute of the given element.
     */
    public static void setXLinkArcRole(Element elt, String str) {
	elt.setAttributeNS(XLINK_NAMESPACE_URI, "arcrole", str);
    }

    /**
     * Returns the value of the 'xlink:title' attribute of the given element.
     */
    public static String getXLinkTitle(Element elt) {
	return elt.getAttributeNS(XLINK_NAMESPACE_URI, "title");
    }

    /**
     * Sets the value of the 'xlink:title' attribute of the given element.
     */
    public static void setXLinkTitle(Element elt, String str) {
	elt.setAttributeNS(XLINK_NAMESPACE_URI, "title", str);
    }

    /**
     * Returns the value of the 'xlink:show' attribute of the given element.
     */
    public static String getXLinkShow(Element elt) {
	return elt.getAttributeNS(XLINK_NAMESPACE_URI, "show");
    }

    /**
     * Sets the value of the 'xlink:show' attribute of the given element.
     */
    public static void setXLinkShow(Element elt, String str) {
	if (!"new".equals(str)   &&
	    !"replace".equals(str)  &&
	    !"embed".equals(str)) {
	    throw new DOMException(DOMException.SYNTAX_ERR,
                                   "xlink:show='" + str + "'");
	}
	elt.setAttributeNS(XLINK_NAMESPACE_URI, "show", str);
    }

    /**
     * Returns the value of the 'xlink:actuate' attribute of the given element.
     */
    public static String getXLinkActuate(Element elt) {
	return elt.getAttributeNS(XLINK_NAMESPACE_URI, "actuate");
    }

    /**
     * Sets the value of the 'xlink:actuate' attribute of the given element.
     */
    public static void setXLinkActuate(Element elt, String str) {
	if (!"onReplace".equals(str) && !"onLoad".equals(str)) {
	    throw new DOMException(DOMException.SYNTAX_ERR,
                                   "xlink:actuate='" + str + "'");
	}
	elt.setAttributeNS(XLINK_NAMESPACE_URI, "actuate", str);
    }

    /**
     * Returns the value of the 'xlink:href' attribute of the given element.
     */
    public static String getXLinkHref(Element elt) {
        return elt.getAttributeNS(XLINK_NAMESPACE_URI, "href");
    }

    /**
     * Sets the value of the 'xlink:href' attribute of the given element.
     */
    public static void setXLinkHref(Element elt, String str) {
	elt.setAttributeNS(XLINK_NAMESPACE_URI, "href", str);
    }
}
