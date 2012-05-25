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
import org.w3c.flex.forks.dom.svg.SVGAnimatedLengthList;

/**
 * This class provide support for the SVGTextPositionningElement 
 * interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGTextPositioningElementSupport.java,v 1.6 2004/08/18 07:13:19 vhardy Exp $
 */
public class SVGTextPositioningElementSupport {

    public final static String X_DEFAULT_VALUE
        = "";
    public final static String Y_DEFAULT_VALUE
        = "";
    public final static String DX_DEFAULT_VALUE
        = "";
    public final static String DY_DEFAULT_VALUE
        = "";

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextPositioningElement#getX()}.
     */
    public static SVGAnimatedLengthList getX(AbstractElement e){

        SVGOMAnimatedLengthList result =(SVGOMAnimatedLengthList)
            e.getLiveAttributeValue(null, SVGConstants.SVG_X_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedLengthList(e, null,
                                                 SVGConstants.SVG_X_ATTRIBUTE,
                                                 X_DEFAULT_VALUE,
                                                 AbstractSVGLength.HORIZONTAL_LENGTH);
            e.putLiveAttributeValue(null,
                                    SVGConstants.SVG_X_ATTRIBUTE, result);
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextPositioningElement#getY()}.
     */
    public static SVGAnimatedLengthList getY(AbstractElement e){

        SVGOMAnimatedLengthList result =(SVGOMAnimatedLengthList)
            e.getLiveAttributeValue(null, SVGConstants.SVG_Y_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedLengthList(e, null,
                                                 SVGConstants.SVG_Y_ATTRIBUTE,
                                                 Y_DEFAULT_VALUE,
                                                 AbstractSVGLength.VERTICAL_LENGTH);
            e.putLiveAttributeValue(null,
                                    SVGConstants.SVG_Y_ATTRIBUTE, result);
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextPositioningElement#getDx()}.
     */
    public static SVGAnimatedLengthList getDx(AbstractElement e){

        SVGOMAnimatedLengthList result =(SVGOMAnimatedLengthList)
            e.getLiveAttributeValue(null, SVGConstants.SVG_DX_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedLengthList(e, null,
                                                 SVGConstants.SVG_DX_ATTRIBUTE,
                                                 DX_DEFAULT_VALUE,
                                                 AbstractSVGLength.HORIZONTAL_LENGTH);
            e.putLiveAttributeValue(null,
                                    SVGConstants.SVG_DX_ATTRIBUTE, result);
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextPositioningElement#getDy()}.
     */
    public static SVGAnimatedLengthList getDy(AbstractElement e){

        SVGOMAnimatedLengthList result =(SVGOMAnimatedLengthList)
            e.getLiveAttributeValue(null, SVGConstants.SVG_DY_ATTRIBUTE);
        if (result == null) {
            result = new SVGOMAnimatedLengthList(e, null,
                                                 SVGConstants.SVG_DY_ATTRIBUTE,
                                                 DY_DEFAULT_VALUE,
                                                 AbstractSVGLength.VERTICAL_LENGTH);
            e.putLiveAttributeValue(null,
                                    SVGConstants.SVG_DY_ATTRIBUTE, result);
        }
        return result;
    }
}
