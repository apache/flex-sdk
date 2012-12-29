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

import java.io.InputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.MissingResourceException;

/**
 * This class describes the XML resources needed to use the various batik
 * modules.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: XMLResourceDescriptor.java 478169 2006-11-22 14:23:24Z dvholten $
 */
public class XMLResourceDescriptor {

    /**
     * The XML parser class name key.
     */
    public static final String XML_PARSER_CLASS_NAME_KEY =
        "org.xml.sax.driver";

    /**
     * The CSS parser class name key.
     */
    public static final String CSS_PARSER_CLASS_NAME_KEY =
        "org.w3c.css.sac.driver";

    /**
     * The resources file name
     */
    public static final String RESOURCES =
        "resources/XMLResourceDescriptor.properties";

    /**
     * The resource bundle
     */
    protected static Properties parserProps = null;

    /**
     * The class name of the XML parser to use.
     */
    protected static String xmlParserClassName;

    /**
     * The class name of the CSS parser to use.
     */
    protected static String cssParserClassName;

    protected static synchronized Properties getParserProps() {
        if (parserProps != null) return parserProps;

        parserProps = new Properties();
        try {
            Class cls = XMLResourceDescriptor.class;
            InputStream is = cls.getResourceAsStream(RESOURCES);
            parserProps.load(is);
        } catch (IOException ioe) {
            throw new MissingResourceException(ioe.getMessage(),
                                               RESOURCES, null);
        }
        return parserProps;
    }

    /**
     * Returns the class name of the XML parser to use.
     *
     * <p>This method first checks if any XML parser has been specified using
     * the <tt>setXMLParserClassName</tt> method. If any, this method will
     * return the value of the property 'org.xml.sax.driver' specified in the
     * <tt>resources/XMLResourceDescriptor.properties</tt> resource file.
     */
    public static String getXMLParserClassName() {
        if (xmlParserClassName == null) {
            xmlParserClassName = getParserProps().getProperty
                (XML_PARSER_CLASS_NAME_KEY);
        }
        return xmlParserClassName;
    }

    /**
     * Sets the class name of the XML parser to use.
     *
     * @param xmlParserClassName the classname of the XML parser
     */
    public static void setXMLParserClassName(String xmlParserClassName) {
        XMLResourceDescriptor.xmlParserClassName = xmlParserClassName;
    }

    /**
     * Returns the class name of the CSS parser to use.
     *
     * <p>This method first checks if any CSS parser has been
     * specified using the <tt>setCSSParserClassName</tt> method. If
     * any, this method will return the value of the property
     * 'org.w3c.css.sac.driver' specified in the
     * <tt>resources/XMLResourceDescriptor.properties</tt> resource
     * file.
     */
    public static String getCSSParserClassName() {
        if (cssParserClassName == null) {
            cssParserClassName = getParserProps().getProperty
                (CSS_PARSER_CLASS_NAME_KEY);
        }
        return cssParserClassName;
    }

    /**
     * Sets the class name of the CSS parser to use.
     *
     * @param cssParserClassName the classname of the CSS parser
     */
    public static void setCSSParserClassName(String cssParserClassName) {
        XMLResourceDescriptor.cssParserClassName = cssParserClassName;
    }
}
