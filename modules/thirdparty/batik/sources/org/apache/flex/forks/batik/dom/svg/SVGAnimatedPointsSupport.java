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
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.flex.forks.dom.svg.SVGPointList;

/**
 * This class provide support for the SVGAnimatedPoints 
 * interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGAnimatedPointsSupport.java,v 1.5 2004/08/18 07:13:13 vhardy Exp $
 */
public class SVGAnimatedPointsSupport {

    /**
     * Default value for the 'points' attribute.
     */
    public static final String POINTS_DEFAULT_VALUE
        = "";

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGAnimatedPoints#getPoints()}.
     */
    public static SVGPointList getPoints(AbstractElement e){
        SVGOMAnimatedPoints result =(SVGOMAnimatedPoints)
            e.getLiveAttributeValue(null, SVGConstants.SVG_POINTS_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedPoints(e, null,
                                             SVGConstants.SVG_POINTS_ATTRIBUTE,
                                             POINTS_DEFAULT_VALUE);
            e.putLiveAttributeValue(null,
                                    SVGConstants.SVG_POINTS_ATTRIBUTE, result);
        }
        return result.getPoints();
    }


    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGAnimatedPoints#getAnimatedPoints()}.
     */
    public static SVGPointList getAnimatedPoints(AbstractElement e){

        SVGOMAnimatedPoints result =(SVGOMAnimatedPoints)
            e.getLiveAttributeValue(null, SVGConstants.SVG_POINTS_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedPoints(e, null,
                                             SVGConstants.SVG_POINTS_ATTRIBUTE,
                                             POINTS_DEFAULT_VALUE);
            e.putLiveAttributeValue(null,
                                    SVGConstants.SVG_POINTS_ATTRIBUTE, result);
        }
        return result.getAnimatedPoints();
    }

}
