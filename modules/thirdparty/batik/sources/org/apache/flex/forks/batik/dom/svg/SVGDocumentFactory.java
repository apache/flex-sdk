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

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;

import org.apache.flex.forks.batik.dom.util.DocumentFactory;
import org.w3c.dom.svg.SVGDocument;

/**
 * This interface represents an object which can build a SVGDocument.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGDocumentFactory.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SVGDocumentFactory extends DocumentFactory {

    /**
     * Creates a SVG Document instance.
     * @param uri The document URI.
     * @exception IOException if an error occured while reading the document.
     */
    SVGDocument createSVGDocument(String uri) throws IOException;

    /**
     * Creates a SVG Document instance.
     * @param uri The document URI.
     * @param is The document input stream.
     * @exception IOException if an error occured while reading the document.
     */
    SVGDocument createSVGDocument(String uri, InputStream is) 
        throws IOException;

    /**
     * Creates a SVG Document instance.
     * @param uri The document URI.
     * @param r The document reader.
     * @exception IOException if an error occured while reading the document.
     */
    SVGDocument createSVGDocument(String uri, Reader r) throws IOException;

}
