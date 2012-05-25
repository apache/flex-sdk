/*

   Copyright 2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.transcoder.image;

import java.io.IOException;
import java.net.URL;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;

import org.apache.flex.forks.batik.dom.GenericDOMImplementation;
import org.apache.flex.forks.batik.dom.util.SAXDocumentFactory;
import org.apache.flex.forks.batik.transcoder.TranscoderInput;
import org.apache.flex.forks.batik.util.XMLResourceDescriptor;

/**
 * Test the ImageTranscoder input with a GenericDocument.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GenericDocumentTest.java,v 1.4 2004/08/18 07:17:12 vhardy Exp $
 */
public class GenericDocumentTest extends AbstractImageTranscoderTest {

    /** The URI of the input image. */
    protected String inputURI;

    /** The URI of the reference image. */
    protected String refImageURI;

    /**
     * Constructs a new <tt>GenericDocumentTest</tt>.
     *
     * @param inputURI the URI of the input image
     * @param the URI of the reference image
     */
    public GenericDocumentTest(String inputURI, String refImageURI) {
	this.inputURI    = inputURI;
	this.refImageURI = refImageURI;
    }

    /**
     * Creates the <tt>TranscoderInput</tt>.
     */
    protected TranscoderInput createTranscoderInput() {
	try {
	    URL url = resolveURL(inputURI);
            String parser = XMLResourceDescriptor.getXMLParserClassName();
            DOMImplementation impl = 
                GenericDOMImplementation.getDOMImplementation();
            SAXDocumentFactory f = new SAXDocumentFactory(impl, parser);
            Document doc = f.createDocument(url.toString());
	    TranscoderInput input = new TranscoderInput(doc);
	    input.setURI(url.toString()); // Needed for external resources
	    return input;
	} catch (IOException ex) {
            ex.printStackTrace();
            throw new IllegalArgumentException(inputURI);
	}
    }

    /**
     * Returns the reference image for this test.
     */
    protected byte [] getReferenceImageData() {
	return createBufferedImageData(resolveURL(refImageURI));
    }
}
