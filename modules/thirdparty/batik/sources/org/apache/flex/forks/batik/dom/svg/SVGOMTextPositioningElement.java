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

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLengthList;
import org.w3c.flex.forks.dom.svg.SVGAnimatedNumberList;
import org.w3c.flex.forks.dom.svg.SVGTextPositioningElement;

/**
 * This class implements {@link org.w3c.flex.forks.dom.svg.SVGTextPositioningElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMTextPositioningElement.java,v 1.8 2004/08/18 07:13:18 vhardy Exp $
 */
public abstract class SVGOMTextPositioningElement
    extends    SVGOMTextContentElement
    implements SVGTextPositioningElement {

    /**
     * Creates a new SVGOMTextPositioningElement object.
     */
    protected SVGOMTextPositioningElement() {
    }

    /**
     * Creates a new SVGOMTextPositioningElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGOMTextPositioningElement(String prefix,
                                          AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getX()}.
     */
    public SVGAnimatedLengthList getX() {
        //throw new RuntimeException(" !!! SVGOMTextPositioningElement.getX()");
        return SVGTextPositioningElementSupport.getX(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getY()}.
     */
    public SVGAnimatedLengthList getY() {
        //throw new RuntimeException(" !!! SVGOMTextPositioningElement.getY()");
        return SVGTextPositioningElementSupport.getY(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getDx()}.
     */
    public SVGAnimatedLengthList getDx() {
        //throw new RuntimeException(" !!! SVGOMTextPositioningElement.getDx()");
        return SVGTextPositioningElementSupport.getDx(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getDy()}.
     */
    public SVGAnimatedLengthList getDy() {
        //throw new RuntimeException(" !!! SVGOMTextPositioningElement.getDy()");
        return SVGTextPositioningElementSupport.getDy(this);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTextPositioningElement#getRotate()}.
     */
    public SVGAnimatedNumberList getRotate() {
        throw new RuntimeException(" !!! SVGOMTextPositioningElement.getRotate()");
    }

}
