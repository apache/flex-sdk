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

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.util.XMLSupport;

/**
 * This class provides a common superclass for elements which contain
 * descriptive text.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGDescriptiveElement.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class SVGDescriptiveElement extends SVGStylableElement {

    /**
     * Creates a new SVGDescriptiveElement object.
     */
    protected SVGDescriptiveElement() {
    }

    /**
     * Creates a new SVGDescriptiveElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGDescriptiveElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }
    
    // SVGLangSpace support //////////////////////////////////////////////////
    
    /**
     * <b>DOM</b>: Returns the xml:lang attribute value.
     */
    public String getXMLlang() {
        return XMLSupport.getXMLLang(this);
    }

    /**
     * <b>DOM</b>: Sets the xml:lang attribute value.
     */
    public void setXMLlang(String lang) {
        setAttributeNS(XML_NAMESPACE_URI, XML_LANG_QNAME, lang);
    }
    
    /**
     * <b>DOM</b>: Returns the xml:space attribute value.
     */
    public String getXMLspace() {
        return XMLSupport.getXMLSpace(this);
    }

    /**
     * <b>DOM</b>: Sets the xml:space attribute value.
     */
    public void setXMLspace(String space) {
        setAttributeNS(XML_NAMESPACE_URI, XML_SPACE_QNAME, space);
    }
}
