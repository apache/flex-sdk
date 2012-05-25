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

import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGMatrix;
import org.w3c.flex.forks.dom.svg.SVGPoint;

/**
 * This class provides an abstract implementation of the {@link SVGMatrix}
 * interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMPoint.java,v 1.5 2004/08/18 07:13:17 vhardy Exp $
 */
public class SVGOMPoint implements SVGPoint {
    float x, y;
    public SVGOMPoint() { x=0; y=0; }
    public SVGOMPoint(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public float getX( )                             { return x; }
    public void  setX( float x ) throws DOMException { this.x = x; }
    public float getY( )                             { return y; }
    public void  setY( float y ) throws DOMException { this.y = y; }

    public SVGPoint matrixTransform ( SVGMatrix matrix ) {
        float newX = matrix.getA()*getX() + matrix.getC()*getY() + matrix.getE();
        float newY = matrix.getB()*getX() + matrix.getD()*getY() + matrix.getF();
        return new SVGOMPoint(newX, newY);
    }
}
