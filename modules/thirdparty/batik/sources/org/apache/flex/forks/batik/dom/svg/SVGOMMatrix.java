/*

   Copyright 2002-2003  The Apache Software Foundation 

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

import java.awt.geom.AffineTransform;

/**
 * This class provides an implementation of the {@link
 * org.w3c.flex.forks.dom.svg.SVGMatrix} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMMatrix.java,v 1.5 2005/03/27 08:58:32 cam Exp $
 */
public class SVGOMMatrix extends AbstractSVGMatrix {
    
    /**
     * The AffineTransform used to implement the matrix.
     */
    protected AffineTransform affineTransform;

    /**
     * Creates a new SVGMatrix.
     */
    public SVGOMMatrix(AffineTransform at) {
        affineTransform = at;
    }

    /**
     * Returns the associated AffineTransform.
     */
    protected AffineTransform getAffineTransform() {
        return affineTransform;
    }
}
