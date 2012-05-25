/*

   Copyright 2000,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.dom;

import org.w3c.dom.DOMException;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentType;

/**
 * This class implements the {@link org.w3c.dom.DOMImplementation}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GenericDOMImplementation.java,v 1.6 2005/02/22 09:12:58 cam Exp $
 */
public class GenericDOMImplementation extends AbstractDOMImplementation {
    /**
     * The default instance of this class.
     */
    protected final static DOMImplementation DOM_IMPLEMENTATION =
        new GenericDOMImplementation();

    /**
     * Creates a new GenericDOMImplementation object.
     */
    public GenericDOMImplementation() {
    }

    /**
     * Returns the default instance of this class.
     */
    public static DOMImplementation getDOMImplementation() {
        return DOM_IMPLEMENTATION;
    }

    // DOMImplementation //////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * DOMImplementation#createDocumentType(String,String,String)}.
     */
    public DocumentType createDocumentType(String qualifiedName, 
                                           String publicId, 
                                           String systemId) {
	throw new DOMException(DOMException.NOT_SUPPORTED_ERR,
                               "Doctype not supported");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * DOMImplementation#createDocument(String,String,DocumentType)}
.
     */
    public Document createDocument(String namespaceURI, 
                                   String qualifiedName, 
                                   DocumentType doctype) throws DOMException {
        Document result = new GenericDocument(doctype, this);
        result.appendChild(result.createElementNS(namespaceURI,
                                                  qualifiedName));
        return result;
    }
}
