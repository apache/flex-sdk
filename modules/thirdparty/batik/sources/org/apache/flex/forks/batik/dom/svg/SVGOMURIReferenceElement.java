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
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.SVGTypes;
import org.w3c.dom.svg.SVGAnimatedString;
import org.w3c.dom.svg.SVGURIReference;

/**
 * This class implements {@link SVGURIReference}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMURIReferenceElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public abstract class SVGOMURIReferenceElement
    extends    SVGOMElement
    implements SVGURIReference {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMElement.xmlTraitInformation);
        t.put(XLINK_NAMESPACE_URI, XLINK_HREF_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_URI));
        xmlTraitInformation = t;
    }

    /**
     * The 'xlink:href' attribute value.
     */
    protected SVGOMAnimatedString href;

    /**
     * Creates a new SVGOMURIReferenceElement object.
     */
    protected SVGOMURIReferenceElement() {
    }

    /**
     * Creates a new SVGOMURIReferenceElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGOMURIReferenceElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
        initializeLiveAttributes();
    }

    /**
     * Initializes all live attributes for this element.
     */
    protected void initializeAllLiveAttributes() {
        super.initializeAllLiveAttributes();
        initializeLiveAttributes();
    }

    /**
     * Initializes the live attribute values of this element.
     */
    private void initializeLiveAttributes() {
        href =
            createLiveAnimatedString(XLINK_NAMESPACE_URI, XLINK_HREF_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.svg.SVGURIReference#getHref()}.
     */
    public SVGAnimatedString getHref() {
        return href;
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
