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

import org.w3c.dom.CharacterData;
import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

/**
 * This class implements the {@link org.w3c.dom.CharacterData} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractCharacterData.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class AbstractCharacterData
    extends    AbstractChildNode
    implements CharacterData {

    /**
     * The value of this node.
     */
    protected String nodeValue = "";

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeValue()}.
     * @return {@link #nodeValue}.
     */
    public String getNodeValue() throws DOMException {
        return nodeValue;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#setNodeValue(String)}.
     */
    public void setNodeValue(String nodeValue) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        // Node modification
        String val = this.nodeValue;
        this.nodeValue = (nodeValue == null) ? "" : nodeValue;

        // Mutation event
        fireDOMCharacterDataModifiedEvent(val, this.nodeValue);
        if (getParentNode() != null) {
            ((AbstractParentNode)getParentNode()).
                fireDOMSubtreeModifiedEvent();
        }
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.CharacterData#getData()}.
     * @return {@link #getNodeValue()}.
     */
    public String getData() throws DOMException {
        return getNodeValue();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.CharacterData#setData(String)}.
     */
    public void setData(String data) throws DOMException {
        setNodeValue(data);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.CharacterData#getLength()}.
     * @return {@link #nodeValue}.length().
     */
    public int getLength() {
        return nodeValue.length();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.CharacterData#substringData(int,int)}.
     */
    public String substringData(int offset, int count) throws DOMException {
        checkOffsetCount(offset, count);

        String v = getNodeValue();
        return v.substring(offset, Math.min(v.length(), offset + count));
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.CharacterData#appendData(String)}.
     */
    public void appendData(String arg) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        setNodeValue(getNodeValue() + ((arg == null) ? "" : arg));
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.CharacterData#insertData(int,String)}.
     */
    public void insertData(int offset, String arg) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        if (offset < 0 || offset > getLength()) {
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                                     "offset",
                                     new Object[] { new Integer(offset) });
        }
        String v = getNodeValue();
        setNodeValue(v.substring(0, offset) + 
                     arg + v.substring(offset, v.length()));
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.CharacterData#deleteData(int,int)}.
     */
    public void deleteData(int offset, int count) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        checkOffsetCount(offset, count);

        String v = getNodeValue();
        setNodeValue(v.substring(0, offset) +
                     v.substring(Math.min(v.length(), offset + count),
                                 v.length()));
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.CharacterData#replaceData(int,int,String)}.
     */
    public void replaceData(int offset, int count, String arg)
        throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        checkOffsetCount(offset, count);

        String v = getNodeValue();
        setNodeValue(v.substring(0, offset) +
                     arg +
                     v.substring(Math.min(v.length(), offset + count),
                                 v.length()));
    }

    /**
     * Checks the given offset and count validity.
     */
    protected void checkOffsetCount(int offset, int count)
        throws DOMException {
        if (offset < 0 || offset >= getLength()) {
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                                     "offset",
                                     new Object[] { new Integer(offset) });
        }
        if (count < 0) {
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                                     "negative.count",
                                     new Object[] { new Integer(count) });
        }
    }

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        super.export(n, d);
        AbstractCharacterData cd = (AbstractCharacterData)n;
        cd.nodeValue = nodeValue;
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        super.deepExport(n, d);
        AbstractCharacterData cd = (AbstractCharacterData)n;
        cd.nodeValue = nodeValue;
        return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        super.copyInto(n);
        AbstractCharacterData cd = (AbstractCharacterData)n;
        cd.nodeValue = nodeValue;
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        super.deepCopyInto(n);
        AbstractCharacterData cd = (AbstractCharacterData)n;
        cd.nodeValue = nodeValue;
        return n;
    }
}
