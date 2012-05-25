/*

   Copyright 2004  The Apache Software Foundation 

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
import org.w3c.flex.forks.dom.svg.SVGAnimatedPreserveAspectRatio;

/**
 * Support for the 'preserveAspectRatio' interface on the SVG element.
 * @author  Tonny Kohar
 */
public class SVGPreserveAspectRatioSupport {
    /**
     * To implement getPreserveAspectRatio.
     * Returns the value of the 'preserveAspectRatio' attribute of the
     * given element.
     */
    public static SVGAnimatedPreserveAspectRatio 
        getPreserveAspectRatio(AbstractElement elt) {
        SVGOMAnimatedPreserveAspectRatio ret;
        ret = (SVGOMAnimatedPreserveAspectRatio)elt.getLiveAttributeValue
            (null, SVGConstants.SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE);

        if (ret == null) {
            ret = new SVGOMAnimatedPreserveAspectRatio(elt);
            elt.putLiveAttributeValue
                (null, SVGConstants.SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE, ret);
        }
        return ret;
    }
}
