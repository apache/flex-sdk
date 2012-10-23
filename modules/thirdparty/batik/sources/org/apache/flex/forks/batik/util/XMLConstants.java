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
package org.apache.flex.forks.batik.util;

/**
 * Contains common XML constants.
 *
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: XMLConstants.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface XMLConstants {

    // Namespace URIs
    String XML_NAMESPACE_URI = "http://www.w3.org/XML/1998/namespace";
    String XMLNS_NAMESPACE_URI = "http://www.w3.org/2000/xmlns/";
    String XLINK_NAMESPACE_URI = "http://www.w3.org/1999/xlink";
    String XML_EVENTS_NAMESPACE_URI = "http://www.w3.org/2001/xml-events";

    // Namespace prefixes
    String XML_PREFIX = "xml";
    String XMLNS_PREFIX = "xmlns";
    String XLINK_PREFIX = "xlink";

    // xml:{base,id,lang,space} and XML Events attributes
    String XML_BASE_ATTRIBUTE = "base";
    String XML_ID_ATTRIBUTE = "id";
    String XML_LANG_ATTRIBUTE = "lang";
    String XML_SPACE_ATTRIBUTE = "space";

    String XML_BASE_QNAME = XML_PREFIX + ':' + XML_BASE_ATTRIBUTE;
    String XML_ID_QNAME = XML_PREFIX + ':' + XML_ID_ATTRIBUTE;
    String XML_LANG_QNAME = XML_PREFIX + ':' + XML_LANG_ATTRIBUTE;
    String XML_SPACE_QNAME = XML_PREFIX + ':' + XML_SPACE_ATTRIBUTE;

    String XML_DEFAULT_VALUE = "default";
    String XML_PRESERVE_VALUE = "preserve";

    String XML_EVENTS_EVENT_ATTRIBUTE = "event";

    // XLink attributes
    String XLINK_HREF_ATTRIBUTE = "href";
    String XLINK_HREF_QNAME = XLINK_PREFIX + ':' + XLINK_HREF_ATTRIBUTE;

    // Serialization constants
    String XML_TAB = "    ";
    String XML_OPEN_TAG_END_CHILDREN = " >";
    String XML_OPEN_TAG_END_NO_CHILDREN = " />";
    String XML_OPEN_TAG_START = "<";
    String XML_CLOSE_TAG_START = "</";
    String XML_CLOSE_TAG_END = ">";
    String XML_SPACE = " ";
    String XML_EQUAL_SIGN = "=";
    String XML_EQUAL_QUOT = "=\"";
    String XML_DOUBLE_QUOTE = "\"";
    char XML_CHAR_QUOT = '\"';
    char XML_CHAR_LT = '<';
    char XML_CHAR_GT = '>';
    char XML_CHAR_APOS = '\'';
    char XML_CHAR_AMP = '&';
    String XML_ENTITY_QUOT = "&quot;";
    String XML_ENTITY_LT = "&lt;";
    String XML_ENTITY_GT = "&gt;";
    String XML_ENTITY_APOS = "&apos;";
    String XML_ENTITY_AMP = "&amp;";
    String XML_CHAR_REF_PREFIX = "&#x";
    String XML_CHAR_REF_SUFFIX = ";";
    String XML_CDATA_END = "]]>";
    String XML_DOUBLE_DASH = "--";
    String XML_PROCESSING_INSTRUCTION_END = "?>";

    // XML versions
    String XML_VERSION_10 = "1.0";
    String XML_VERSION_11 = "1.1";
}
