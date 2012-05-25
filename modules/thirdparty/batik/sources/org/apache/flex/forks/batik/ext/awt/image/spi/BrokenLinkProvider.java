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
package org.apache.flex.forks.batik.ext.awt.image.spi;

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;

/**
 * This interface is to be used to provide alternate ways of 
 * generating a placeholder image when the ImageTagRegistry
 * fails to handle a given reference.
 */
public interface BrokenLinkProvider {

    /**
     * The image returned by getBrokenLinkImage should always
     * return some value when queried for the BROKEN_LINK_PROPERTY.
     * This allows code the determine if the image is the 'real'
     * image or the broken link image, which may be important for
     * the application of profiles etc.
     */
    public static final String BROKEN_LINK_PROPERTY = 
        "org.apache.flex.forks.batik.BrokenLinkImage";

    /**
     * This method is responsbile for constructing an image that will
     * represent the missing image in the document.  This method
     * recives information about the reason a broken link image is
     * being requested in the <tt>code</tt> and <tt>params</tt>
     * parameters. These parameters may be used to generate nicely
     * localized messages for insertion into the broken link image, or
     * for selecting the broken link image returned.
     *
     * @param base The object to use for Message decoding.
     * @param code This is the reason the image is unavailable should
     *             be taken from ErrorConstants.
     * @param params This is more detailed information about
     *        the circumstances of the failure.  */
    public Filter getBrokenLinkImage(Object base,
                                     String code, Object[] params);
}
