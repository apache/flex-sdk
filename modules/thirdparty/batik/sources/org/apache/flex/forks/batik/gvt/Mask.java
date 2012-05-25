/*

   Copyright 2000-2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.gvt;

import java.awt.geom.Rectangle2D;
import java.awt.image.renderable.RenderableImage;

/**
 * Describes a mask.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: Mask.java,v 1.5 2004/08/18 07:14:27 vhardy Exp $
 */
public interface Mask extends RenderableImage {

    /**
     * Returns the bounds of this mask.
     */
    Rectangle2D getBounds2D();
}
