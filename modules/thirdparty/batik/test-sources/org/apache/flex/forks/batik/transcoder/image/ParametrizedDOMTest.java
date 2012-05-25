/*

   Copyright 2001-2003  The Apache Software Foundation 

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

import org.w3c.dom.Document;

import org.apache.flex.forks.batik.dom.svg.SAXSVGDocumentFactory;
import org.apache.flex.forks.batik.transcoder.TranscoderInput;
import org.apache.flex.forks.batik.util.XMLResourceDescriptor;

/**
 * Test the ImageTranscoder input with a DOM tree.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: ParametrizedDOMTest.java,v 1.5 2004/08/18 07:17:13 vhardy Exp $
 */
public class ParametrizedDOMTest extends AbstractImageTranscoderTest {

    /** The URI of the input image. */
    protected String inputURI;

    /** The URI of the reference image. */
    protected String refImageURI;

    /**
     * Constructs a new <tt>ParametrizedDOMTest</tt>.
     *
     * @param inputURI the URI of the input image
     * @param the URI of the reference image
     */
    public ParametrizedDOMTest(String inputURI, String refImageURI) {
	this.inputURI = inputURI;
	this.refImageURI = refImageURI;
    }

    /**
     * Creates the <tt>TranscoderInput</tt>.
     */
    protected TranscoderInput createTranscoderInput() {
	try {
	    String parser = XMLResourceDescriptor.getXMLParserClassName();
	    SAXSVGDocumentFactory f = new SAXSVGDocumentFactory(parser);
	    Document doc = f.createDocument(resolveURL(inputURI).toString());
	    return new TranscoderInput(doc);
	} catch (IOException ex) {
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
