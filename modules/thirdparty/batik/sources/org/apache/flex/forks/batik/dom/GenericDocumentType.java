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

import org.w3c.dom.DocumentType;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

/**
 * This class implements the {@link org.w3c.dom.DocumentType} interface.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: GenericDocumentType.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GenericDocumentType
        extends AbstractChildNode 
        implements DocumentType {

    protected String qualifiedName;
    protected String publicId;
    protected String systemId;

    public GenericDocumentType(String qualifiedName,
                                   String publicId,
                                   String systemId) {
        this.qualifiedName = qualifiedName;
        this.publicId      = publicId;
        this.systemId      = systemId;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return The name of the DTD.
     */
    public String getNodeName() { return qualifiedName; }

    public short getNodeType() { return DOCUMENT_TYPE_NODE; }

    public boolean isReadonly() { return true; }
    public void    setReadonly(boolean ro) {}

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.DocumentType#getName()}.
     * @return The name of the DTD.
     */
    public String getName() { return null; }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.DocumentType#getEntities()}.
     * @return null.
     */
    public NamedNodeMap getEntities() {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.DocumentType#getNotations()}.
     * @return null.
     */
    public NamedNodeMap getNotations() {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.DocumentType#getPublicId()}.
     * @return The public id.
     */
    public String getPublicId() { return publicId; }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.DocumentType#getSystemId()}.
     * @return The public id.
     */
    public String getSystemId() { return systemId; }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.DocumentType#getInternalSubset()}.
     * @return The public id.
     */
    public String getInternalSubset() { return null; }


    protected Node newNode() { 
        return new GenericDocumentType(qualifiedName, publicId, systemId); }
}
