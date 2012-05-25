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

/**
 * Context class for the SVG path element to support extra
 * methods.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: SVGPathContext.java,v 1.2 2005/03/27 08:58:32 cam Exp $
 */
public interface SVGPathContext extends SVGContext {

    public float getTotalLength();

    public Point2D getPointAtLength(float distance);
};
