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
package org.apache.flex.forks.batik.dom.svg;

import java.awt.geom.AffineTransform;

import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGMatrix;

/**
 * This class is the implementation of the SVGTransform interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGOMTransform.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGOMTransform extends AbstractSVGTransform {

    /**
     * Creates a new SVGOMTransform.
     */
    public SVGOMTransform() {
        affineTransform = new AffineTransform();
    }

    /**
     * Creates a new, modifiable SVGMatrix.
     */
    protected SVGMatrix createMatrix() {
        return new AbstractSVGMatrix() {
            protected AffineTransform getAffineTransform() {
                return SVGOMTransform.this.affineTransform;
            }
            public void setA(float a) throws DOMException {
                SVGOMTransform.this.setType(SVG_TRANSFORM_MATRIX);
                super.setA(a);
            }
            public void setB(float b) throws DOMException {
                SVGOMTransform.this.setType(SVG_TRANSFORM_MATRIX);
                super.setB(b);
            }
            public void setC(float c) throws DOMException {
                SVGOMTransform.this.setType(SVG_TRANSFORM_MATRIX);
                super.setC(c);
            }
            public void setD(float d) throws DOMException {
                SVGOMTransform.this.setType(SVG_TRANSFORM_MATRIX);
                super.setD(d);
            }
            public void setE(float e) throws DOMException {
                SVGOMTransform.this.setType(SVG_TRANSFORM_MATRIX);
                super.setE(e);
            }
            public void setF(float f) throws DOMException {
                SVGOMTransform.this.setType(SVG_TRANSFORM_MATRIX);
                super.setF(f);
            }
        };
    }
}
