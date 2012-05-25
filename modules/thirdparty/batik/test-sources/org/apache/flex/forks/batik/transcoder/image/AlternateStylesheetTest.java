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

import java.util.Map;
import java.util.HashMap;

import org.apache.flex.forks.batik.transcoder.TranscoderInput;

/**
 * Test the ImageTranscoder with the KEY_ALTERNATE_STYLESHEET transcoding hint.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: AlternateStylesheetTest.java,v 1.5 2004/08/18 07:17:12 vhardy Exp $ 
 */
public class AlternateStylesheetTest extends AbstractImageTranscoderTest {

    /** The URI of the input image. */
    protected String inputURI;

    /** The URI of the reference image. */
    protected String refImageURI;

    /** The alternate stylesheet to use. */
    protected String alternateStylesheet;

    /**
     * Constructs a new <tt>AlternateStylesheetTest</tt>.
     *
     * @param inputURI the URI of the input image
     * @param the URI of the reference image
     * @param alternateStylesheet the alternate stylesheet CSS media
     */
    public AlternateStylesheetTest(String inputURI, 
				   String refImageURI, 
				   String alternateStylesheet) {
	this.inputURI = inputURI;
	this.refImageURI = refImageURI;
	this.alternateStylesheet = alternateStylesheet;
    }

    /**
     * Creates the <tt>TranscoderInput</tt>.
     */
    protected TranscoderInput createTranscoderInput() {
	return new TranscoderInput(resolveURL(inputURI).toString());
    }
    
    /**
     * Creates a Map that contains additional transcoding hints.
     */
    protected Map createTranscodingHints() {
	Map hints = new HashMap(3);
	hints.put(ImageTranscoder.KEY_ALTERNATE_STYLESHEET, 
		  alternateStylesheet);
	return hints;
    }

    /**
     * Returns the reference image for this test.
     */
    protected byte [] getReferenceImageData() {
	return createBufferedImageData(resolveURL(refImageURI));
    }
}
