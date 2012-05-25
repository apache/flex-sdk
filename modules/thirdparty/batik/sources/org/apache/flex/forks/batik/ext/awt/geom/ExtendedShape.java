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
package org.apache.flex.forks.batik.ext.awt.geom;

import java.awt.Shape;

/**
 * The <code>ExtendedShape</code> class represents a geometric
 * path constructed from straight lines, quadratic and cubic (Bezier)
 * curves and elliptical arcs.
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: ExtendedShape.java,v 1.4 2004/08/18 07:13:47 vhardy Exp $
 */
public interface ExtendedShape extends Shape {
    /**
     * Get an extended Path iterator that may return SEG_ARCTO commands
     */
    public ExtendedPathIterator getExtendedPathIterator();

}
