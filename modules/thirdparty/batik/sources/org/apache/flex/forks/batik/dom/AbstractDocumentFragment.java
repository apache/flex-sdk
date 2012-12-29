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

import org.w3c.dom.DOMException;
import org.w3c.dom.DocumentFragment;
import org.w3c.dom.Node;

/**
 * This class implements {@link org.w3c.dom.DocumentFragment} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractDocumentFragment.java 475685 2006-11-16 11:16:05Z cam $
 */

public abstract class AbstractDocumentFragment
    extends AbstractParentNode
    implements DocumentFragment {

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return "#document-fragment".
     */
    public String getNodeName() {
        return "#document-fragment";
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeType()}.
     * @return {@link org.w3c.dom.Node#DOCUMENT_FRAGMENT_NODE}
     */
    public short getNodeType() {
        return DOCUMENT_FRAGMENT_NODE;
    }

    /**
     * Checks the validity of a node to be inserted.
     */
    protected void checkChildType(Node n, boolean replace) {
        switch (n.getNodeType()) {
        case ELEMENT_NODE:
        case PROCESSING_INSTRUCTION_NODE:
        case COMMENT_NODE:
        case TEXT_NODE:
        case CDATA_SECTION_NODE:
        case ENTITY_REFERENCE_NODE:
        case DOCUMENT_FRAGMENT_NODE:
            break;
        default:
            throw createDOMException
                (DOMException.HIERARCHY_REQUEST_ERR,
                 "child.type",
                 new Object[] { new Integer(getNodeType()),
                                getNodeName(),
                                new Integer(n.getNodeType()),
                                n.getNodeName() });
        }
    }
}
