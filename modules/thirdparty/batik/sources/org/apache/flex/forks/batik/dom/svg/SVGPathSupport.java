/*

   Copyright 2005 The Apache Software Foundation 

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

import java.awt.geom.Point2D;

import org.w3c.flex.forks.dom.svg.SVGPoint;
import org.w3c.flex.forks.dom.svg.SVGMatrix;
import org.w3c.dom.DOMException;

/**
 * The clas provides support for the SVGPath interface.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: SVGPathSupport.java,v 1.3 2005/04/02 14:26:09 deweese Exp $
 */
public class SVGPathSupport {

    /**
     * To implement {@link org.w3c.flex.forks.dom.svg.SVGPathElement#getTotalLength()}.
     */
    public static float getTotalLength(SVGOMPathElement path) {
        SVGPathContext pathCtx = (SVGPathContext)path.getSVGContext();
        return pathCtx.getTotalLength();
    }


    /**
     * To implement {@link org.w3c.flex.forks.dom.svg.SVGPathElement#getPointAtLength(float)}.
     */
    public static SVGPoint getPointAtLength(final SVGOMPathElement path,
                                            final float distance) {
        final SVGPathContext pathCtx = (SVGPathContext)path.getSVGContext();
        if (pathCtx == null) return null;

        return new SVGPoint() {
                public float getX() {
                    Point2D pt = pathCtx.getPointAtLength(distance);
                    return (float)pt.getX();
                }
                public float getY() {
                    Point2D pt = pathCtx.getPointAtLength(distance);
                    return (float)pt.getY();
                }
                public void setX(float x) throws DOMException {
                    throw path.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.point", null);
                }
                public void setY(float y) throws DOMException {
                    throw path.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.point", null);
                }
                public SVGPoint matrixTransform ( SVGMatrix matrix ) {
                    throw path.createDOMException
                        (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                         "readonly.point", null);
                }
            };
    }
};
