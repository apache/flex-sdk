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
package org.apache.flex.forks.batik.dom;

import org.w3c.dom.CDATASection;
import org.w3c.dom.Node;
import org.w3c.dom.Text;

/**
 * This class implements the {@link org.w3c.dom.CDATASection} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GenericCDATASection.java 475685 2006-11-16 11:16:05Z cam $
 */
public class GenericCDATASection
        extends AbstractText
        implements CDATASection {

    /**
     * Is this element immutable?
     */
    protected boolean readonly;

    /**
     * Creates a new CDATASection object.
     */
    protected GenericCDATASection() {
    }

    /**
     * Creates a new CDATASection object.
     */
    public GenericCDATASection(String value, AbstractDocument owner) {
        ownerDocument = owner;
        setNodeValue(value);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return "#cdata-section".
     */
    public String getNodeName() {
        return "#cdata-section";
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeType()}.
     * @return {@link org.w3c.dom.Node#CDATA_SECTION_NODE}
     */
    public short getNodeType() {
        return CDATA_SECTION_NODE;
    }

    /**
     * Tests whether this node is readonly.
     */
    public boolean isReadonly() {
        return readonly;
    }

    /**
     * Sets this node readonly attribute.
     */
    public void setReadonly(boolean v) {
        readonly = v;
    }

    /**
     * Creates a text node of the current type.
     */
    protected Text createTextNode(String text) {
        return getOwnerDocument().createCDATASection(text);
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new GenericCDATASection();
    }
}
