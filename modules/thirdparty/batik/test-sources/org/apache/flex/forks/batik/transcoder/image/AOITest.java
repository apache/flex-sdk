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

import java.awt.geom.Rectangle2D;

import java.util.Map;
import java.util.HashMap;

import org.apache.flex.forks.batik.transcoder.TranscoderInput;

/**
 * Test the ImageTranscoder with the KEY_AOI transcoding hint.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: AOITest.java,v 1.5 2004/08/18 07:17:12 vhardy Exp $ 
 */
public class AOITest extends AbstractImageTranscoderTest {

    /** The URI of the input image. */
    protected String inputURI;

    /** The URI of the reference image. */
    protected String refImageURI;

    /** The area of interest. */
    protected Rectangle2D aoi;

    /** The width of the image. */
    protected Float imgWidth;

    /** The height of the image. */
    protected Float imgHeight;

    /**
     * Constructs a new <tt>AOITest</tt>.
     *
     * @param inputURI the URI of the input image
     * @param the URI of the reference image
     * @param x the x coordinate of the area of interest
     * @param y the y coordinate of the area of interest
     * @param width the width of the area of interest
     * @param height the height of the area of interest
     */
    public AOITest(String inputURI, 
		   String refImageURI, 
		   Float x,
		   Float y,
		   Float width,
		   Float height) {
	this(inputURI, 
	     refImageURI, 
	     x, 
	     y, 
	     width, 
	     height, 
	     new Float(-1), 
	     new Float(-1));
    }

    /**
     * Constructs a new <tt>AOITest</tt>.
     *
     * @param inputURI the URI of the input image
     * @param the URI of the reference image
     * @param x the x coordinate of the area of interest
     * @param y the y coordinate of the area of interest
     * @param width the width of the area of interest
     * @param height the height of the area of interest
     * @param imgWidth the width of the image to generate
     * @param imgHeight the height of the image to generate
     */
    public AOITest(String inputURI, 
		   String refImageURI, 
		   Float x,
		   Float y,
		   Float width,
		   Float height,
		   Float imgWidth,
		   Float imgHeight) {
	this.inputURI = inputURI;
	this.refImageURI = refImageURI;
	this.aoi = new Rectangle2D.Float(x.floatValue(),
					 y.floatValue(),
					 width.floatValue(),
					 height.floatValue());
	this.imgWidth = imgWidth;
	this.imgHeight = imgHeight;
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
	Map hints = new HashMap(11);
	hints.put(ImageTranscoder.KEY_AOI, aoi);
	if (imgWidth.floatValue() > 0) {
	    hints.put(ImageTranscoder.KEY_WIDTH, imgWidth);
	}
	if (imgHeight.floatValue() > 0) {
	    hints.put(ImageTranscoder.KEY_HEIGHT, imgHeight);
	}
	return hints;
    }

    /**
     * Returns the reference image for this test.
     */
    protected byte [] getReferenceImageData() {
	return createBufferedImageData(resolveURL(refImageURI));
    }
}
