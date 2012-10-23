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
package org.apache.flex.forks.batik.extension;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.w3c.dom.DOMException;

/**
 * This class implements a simple method for handling the node 'prefix'.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas Deweese</a>
 * @version $Id: PrefixableStylableExtensionElement.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public abstract class PrefixableStylableExtensionElement
    extends StylableExtensionElement {

    /**
     * The element prefix.
     */
    protected String prefix = null;

    /**
     * Creates a new BatikStarElement object.
     */
    protected PrefixableStylableExtensionElement() {
    }

    /**
     * Creates a new BatikStarElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public PrefixableStylableExtensionElement(String prefix,
                                              AbstractDocument owner) {
        super(prefix, owner);
        setPrefix(prefix);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     */
    public String getNodeName() {
        return (prefix == null || prefix.equals(""))
            ? getLocalName() : prefix + ':' + getLocalName();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#setPrefix(String)}.
     */
    public void setPrefix(String prefix) throws DOMException {
        if (isReadonly()) {
            throw createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.node",
                 new Object[] { new Integer(getNodeType()), getNodeName() });
        }

        if (prefix != null &&
            !prefix.equals("") &&
            !DOMUtilities.isValidName(prefix)) {
            throw createDOMException
                (DOMException.INVALID_CHARACTER_ERR, "prefix",
                 new Object[] { new Integer(getNodeType()),
                                getNodeName(),
                                prefix });
        }

        this.prefix = prefix;
    }
}
