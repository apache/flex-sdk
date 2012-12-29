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
package org.apache.flex.forks.batik.ext.awt.image.spi;

import java.awt.Image;

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;

/**
 * This interface is to be used to provide alternate ways of
 * generating a placeholder image when the ImageTagRegistry
 * fails to handle a given reference.
 *
 * @version $Id: BrokenLinkProvider.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public abstract class BrokenLinkProvider {

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
     *        the circumstances of the failure.
     */
    public abstract Filter getBrokenLinkImage(Object base,
                                              String code, Object[] params);

    public static boolean hasBrokenLinkProperty(Filter f) {
        Object o = f.getProperty(BROKEN_LINK_PROPERTY);
        if (o == null) return false;
        if (o == Image.UndefinedProperty) return false;
        return true;
    }

}
