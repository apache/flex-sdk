/*

   Copyright 2002  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */package org.apache.flex.forks.batik.transcoder.image;

import java.util.Map;
import java.util.HashMap;

import org.apache.flex.forks.batik.transcoder.TranscoderInput;

/**
 * Test the ImageTranscoder with the KEY_MAX_WIDTH and/or the KEY_MAX_HEIGHT 
 * transcoding hint.
 *
 * @author <a href="mailto:ruini@iki.fi">Henri Ruini</a>
 * @version $Id: MaxDimensionTest.java,v 1.3 2004/08/18 07:17:12 vhardy Exp $ 
 */
public class MaxDimensionTest extends AbstractImageTranscoderTest {

    //-- Variables -----------------------------------------------------------
    /** The URI of the input image. */
    protected String inputURI;
    /** The URI of the reference image. */
    protected String refImageURI;
    /** The maximum width of the image. */
    protected Float maxWidth = new Float(Float.NaN);
    /** The maximum height of the image. */
    protected Float maxHeight = new Float(Float.NaN);
    /** The width of the image. */
    protected Float width = new Float(Float.NaN);
    /** The height of the image. */
    protected Float height = new Float(Float.NaN);


    //-- Constructors --------------------------------------------------------
    /**
     * Constructs a new <tt>MaxDimensionTest</tt>.
     *
     * @param inputURI URI of the input image.
     * @param refImageURI URI of the reference image.
     * @param maxWidth Maximum image width (KEY_MAX_WIDTH value).
     * @param maxHeight Maximum image height (KEY_MAX_HEIGHT value).
     */
    public MaxDimensionTest(String inputURI, String refImageURI, Float maxWidth, Float maxHeight) {
        this.inputURI = inputURI;
        this.refImageURI = refImageURI;
        this.maxWidth = maxWidth;
        this.maxHeight = maxHeight;
    }

    /**
     * Constructs a new <tt>MaxDimensionTest</tt>.
     *
     * @param inputURI URI of the input image.
     * @param refImageURI URI of the reference image.
     * @param maxWidth Maximum image width (KEY_MAX_WIDTH value).
     * @param maxHeight Maximum image height (KEY_MAX_HEIGHT value).
     * @param width Image width (KEY_WIDTH value).
     * @param height Image height (KEY_HEIGH value).
     */
    public MaxDimensionTest(String inputURI, String refImageURI, Float maxWidth, Float maxHeight, Float width, Float height) {
        this.inputURI = inputURI;
        this.refImageURI = refImageURI;
        this.maxWidth = maxWidth;
        this.maxHeight = maxHeight;
        this.width = width;
        this.height = height;
    }


    //-- Methods -------------------------------------------------------------
    /**
     * Creates the <tt>TranscoderInput</tt>.
     */
    protected TranscoderInput createTranscoderInput() {
        return new TranscoderInput(resolveURL(inputURI).toString());
    }
    
    /**
     * Creates a Map that contains additional transcoding hints.
     *
     * @return Transcoding hint values.
     */
    protected Map createTranscodingHints() {
        Map hints = new HashMap(7);
        if (!width.isNaN() && width.floatValue() > 0) {
            hints.put(ImageTranscoder.KEY_WIDTH, width);
        }
        if (!height.isNaN() && height.floatValue() > 0) {
            hints.put(ImageTranscoder.KEY_HEIGHT, height);
        }
        if (maxWidth.floatValue() > 0) {
            hints.put(ImageTranscoder.KEY_MAX_WIDTH, maxWidth);
        }
        if (maxHeight.floatValue() > 0) {
            hints.put(ImageTranscoder.KEY_MAX_HEIGHT, maxHeight);
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

