/*

   Copyright 2000-2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.flex.forks.dom.svg.SVGAnimatedTransformList;

/**
 * This class provides support for the SVGTransformable interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGTransformableSupport.java,v 1.7 2004/08/18 07:13:19 vhardy Exp $
 */
public class SVGTransformableSupport {
    /**
     * Creates a new SVGTransformableSupport.
     */
    public SVGTransformableSupport() {
    }
    
    /**
     * Default value for the 'transform' attribute.
     */
    public static final String TRANSFORM_DEFAULT_VALUE
        = "";

    /**
     * To implement {@link
     * org.w3c.flex.forks.dom.svg.SVGTransformable#getTransform()}.
     */
    public static SVGAnimatedTransformList getTransform(AbstractElement elt) {
        SVGOMAnimatedTransformList result =(SVGOMAnimatedTransformList)
            elt.getLiveAttributeValue(null, SVGConstants.SVG_TRANSFORM_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedTransformList(elt, null,
                                                    SVGConstants.SVG_TRANSFORM_ATTRIBUTE,
                                                    TRANSFORM_DEFAULT_VALUE);
            elt.putLiveAttributeValue(null,
                                      SVGConstants.SVG_TRANSFORM_ATTRIBUTE, 
                                      result);
        }
        return result;

    }
}
