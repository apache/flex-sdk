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

package org.apache.flex.forks.batik.apps.svgbrowser;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import org.apache.flex.forks.batik.dom.GenericDOMImplementation;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.dom.util.DocumentFactory;
import org.apache.flex.forks.batik.dom.util.SAXDocumentFactory;
import org.apache.flex.forks.batik.util.PreferenceManager;
import org.apache.flex.forks.batik.util.XMLResourceDescriptor;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * An extension of {@link PreferenceManager} which store the preference
 * in XML.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: XMLPreferenceManager.java 475477 2006-11-15 22:44:28Z cam $
 */
public class XMLPreferenceManager extends PreferenceManager {
    
    /**
     * The XML parser
     */
    protected String xmlParserClassName;

    /**
     * The XML encoding used to store properties
     */
    public static final String PREFERENCE_ENCODING = "8859_1";

    /**
     * Creates a preference manager.
     * @param prefFileName the name of the preference file.
     */
    public XMLPreferenceManager(String prefFileName){
        this(prefFileName, null, 
             XMLResourceDescriptor.getXMLParserClassName());
    }

    /**
     * Creates a preference manager.
     * @param prefFileName the name of the preference file.
     * @param defaults where to get defaults value if the value is
     * not specified in the file.
     */
    public XMLPreferenceManager(String prefFileName,
                                Map defaults){
        this(prefFileName, defaults, 
             XMLResourceDescriptor.getXMLParserClassName());
    }

    /**
     * Creates a preference manager.
     * @param prefFileName the name of the preference file.
     * @param parser The XML parser class name.
     */
    public XMLPreferenceManager(String prefFileName, String parser) {
        this(prefFileName, null, parser);
    }

    /**
     * Creates a preference manager with a default values
     * initialization map.
     * @param prefFileName the name of the preference file.
     * @param defaults where to get defaults value if the value is
     * not specified in the file.
     * @param parser The XML parser class name.
     */
    public XMLPreferenceManager(String prefFileName, Map defaults, String parser) {
        super(prefFileName, defaults);
        internal = new XMLProperties();
        xmlParserClassName = parser;
    }

    /**
     * To store the preferences.
     */
    protected class XMLProperties extends Properties {

        /**
         * Reads a property list (key and element pairs) from the input stream.
         * The stream is assumed to be using the ISO 8859-1 character encoding.
         */
        public synchronized void load(InputStream is) throws IOException {
            BufferedReader r;
            r = new BufferedReader(new InputStreamReader(is, PREFERENCE_ENCODING));
            DocumentFactory df = new SAXDocumentFactory
                (GenericDOMImplementation.getDOMImplementation(),
                 xmlParserClassName);
            Document doc = df.createDocument("http://xml.apache.org/batik/preferences",
                                             "preferences",
                                             null,
                                             r);
            Element elt = doc.getDocumentElement();
            for (Node n = elt.getFirstChild(); n != null; n = n.getNextSibling()) {
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    if (n.getNodeName().equals("property")) {
                        String name = ((Element)n).getAttributeNS(null, "name");
                        
                        StringBuffer cont = new StringBuffer();
                        for (Node c = n.getFirstChild();
                             c != null;
                             c = c.getNextSibling()) {
                            if (c.getNodeType() == Node.TEXT_NODE) {
                                cont.append(c.getNodeValue());
                            } else {
                                break;
                            }
                        }
                        String val = cont.toString();
                        put(name, val);
                    }
                }
            }
        }

        /**
         * Writes this property list (key and element pairs) in this
         * <code>Properties</code> table to the output stream in a format suitable
         * for loading into a <code>Properties</code> table using the
         * <code>load</code> method.
         * The stream is written using the ISO 8859-1 character encoding.
         */
        public synchronized void store(OutputStream os, String header)
            throws IOException {
            BufferedWriter w;
            w = new BufferedWriter(new OutputStreamWriter(os, PREFERENCE_ENCODING));

            Map m = new HashMap();
            enumerate(m);

            w.write("<preferences xmlns=\"http://xml.apache.org/batik/preferences\">\n");

            Iterator it = m.keySet().iterator();
            while (it.hasNext()) {
                String n = (String)it.next();
                String v = (String)m.get(n);
                
                w.write("<property name=\"" + n + "\">");
                w.write(DOMUtilities.contentToString(v));
                w.write("</property>\n");
            }

            w.write("</preferences>\n");
            w.flush();
        }

        /**
         * Enumerates all key/value pairs in the specified m.
         * @param m the map
         */
        private synchronized void enumerate(Map m) {
            if (defaults != null) {
                Iterator it = m.keySet().iterator();
                while (it.hasNext()) {
                    Object k = it.next();
                    m.put(k, defaults.get(k));
                }
            }
            Iterator it = keySet().iterator();
            while (it.hasNext()) {
                Object k = it.next();
                m.put(k, get(k));
            }
        }
        
    }
}
