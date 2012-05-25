/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.test.svg;

/**
 * Preconfigured test for SVG files under the xml-batik/../beSuite
 * directory.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: BERenderingTest.java,v 1.6 2005/03/27 08:58:37 cam Exp $
 */
public class BERenderingTest extends PreconfiguredRenderingTest {
    public static final String SVG_URL_PREFIX 
        = "test-references/../../beSuite/";

    public static final String REF_IMAGE_PREFIX 
        = "test-references/svgbe/";

    public static final String REF_IMAGE_SUFFIX
        = "";

    public static final String VARIATION_PREFIX
        = "test-references/svgbe/";

    public static final String VARIATION_SUFFIX
        = "accepted-variation/";

    public static final String SAVE_VARIATION_PREFIX
        = "test-references/svgbe/";

    public static final String SAVE_VARIATION_SUFFIX
        = "candidate-variation/";

    public static final String SAVE_CANDIDATE_REFERENCE_PREFIX
        = "test-references/svgbe/";

    public static final String SAVE_CANDIDATE_REFERENCE_SUFFIX
        = "candidate-reference/";


    protected String getSVGURLPrefix(){
        return SVG_URL_PREFIX;
    }

    protected String getRefImagePrefix(){
        return REF_IMAGE_PREFIX;
    }

    protected String getRefImageSuffix(){
        return REF_IMAGE_SUFFIX;
    }

    protected String getVariationPrefix(){
        return VARIATION_PREFIX;
    }

    protected String getVariationSuffix(){
        return VARIATION_SUFFIX;
    }

    protected String getSaveVariationPrefix(){
        return SAVE_VARIATION_PREFIX;
    }

    protected String getSaveVariationSuffix(){
        return SAVE_VARIATION_SUFFIX;
    }

    protected String getCandidateReferencePrefix(){
        return SAVE_CANDIDATE_REFERENCE_PREFIX;
    }

    protected String getCandidateReferenceSuffix(){
        return SAVE_CANDIDATE_REFERENCE_SUFFIX;
    }

    public BERenderingTest(){
	setValidating(new Boolean(true));
    }
}
