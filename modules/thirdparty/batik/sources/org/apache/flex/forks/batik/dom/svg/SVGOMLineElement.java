/*

   Copyright 2000-2003  The Apache Software Foundation 

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
import org.w3c.dom.Node;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGLineElement;

/**
 * This class implements {@link SVGLineElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMLineElement.java,v 1.7 2004/08/18 07:13:17 vhardy Exp $
 */
public class SVGOMLineElement
    extends    SVGGraphicsElement
    implements SVGLineElement {

    /**
     * Creates a new SVGOMLineElement object.
     */
    protected SVGOMLineElement() {
    }

    /**
     * Creates a new SVGOMLineElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMLineElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_LINE_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGLineElement#getX1()}.
     */
    public SVGAnimatedLength getX1() {
        return getAnimatedLengthAttribute
            (null, SVG_X1_ATTRIBUTE, SVG_LINE_X1_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    } 

    /**
     * <b>DOM</b>: Implements {@link SVGLineElement#getY1()}.
     */
    public SVGAnimatedLength getY1() {
        return getAnimatedLengthAttribute
            (null, SVG_Y1_ATTRIBUTE, SVG_LINE_Y1_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGLineElement#getX2()}.
     */
    public SVGAnimatedLength getX2() {
        return getAnimatedLengthAttribute
            (null, SVG_X2_ATTRIBUTE, SVG_LINE_X2_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    } 

    /**
     * <b>DOM</b>: Implements {@link SVGLineElement#getY2()}.
     */
    public SVGAnimatedLength getY2() {
        return getAnimatedLengthAttribute
            (null, SVG_Y2_ATTRIBUTE, SVG_LINE_Y2_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    } 

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMLineElement();
    }
}
