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
import org.w3c.dom.Node;
import org.w3c.dom.ProcessingInstruction;

/**
 * This class implements the {@link org.w3c.dom.ProcessingInstruction}
 * interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractProcessingInstruction.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class AbstractProcessingInstruction
    extends    AbstractChildNode
    implements ProcessingInstruction {

    /**
     * The data.
     */
    protected String data;

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return {@link #getTarget()}.
     */
    public String getNodeName() {
        return getTarget();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeType()}.
     * @return {@link org.w3c.dom.Node#PROCESSING_INSTRUCTION_NODE}
     */
    public short getNodeType() {
        return PROCESSING_INSTRUCTION_NODE;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeValue()}.
     * @return {@link #getData()}.
     */
    public String getNodeValue() throws DOMException {
        return getData();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#setNodeValue(String)}.
     */
    public void setNodeValue(String nodeValue) throws DOMException {
        setData(nodeValue);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.ProcessingInstruction#getData()}.
     * @return {@link #data}.
     */
    public String getData() {
        return data;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.ProcessingInstruction#setData(String)}.
     */
    public void setData(String data) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        String val = this.data;
        this.data = data;

        // Mutation event
        fireDOMCharacterDataModifiedEvent(val, this.data);
        if (getParentNode() != null) {
            ((AbstractParentNode)getParentNode()).
                fireDOMSubtreeModifiedEvent();
        }
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getTextContent()}.
     */
    public String getTextContent() {
        return getNodeValue();
    }

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        AbstractProcessingInstruction p;
        p = (AbstractProcessingInstruction)super.export(n, d);
        p.data = data;
        return p;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        AbstractProcessingInstruction p;
        p = (AbstractProcessingInstruction)super.deepExport(n, d);
        p.data = data;
        return p;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        AbstractProcessingInstruction p;
        p = (AbstractProcessingInstruction)super.copyInto(n);
        p.data = data;
        return p;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        AbstractProcessingInstruction p;
        p = (AbstractProcessingInstruction)super.deepCopyInto(n);
        p.data = data;
        return p;
    }
}
