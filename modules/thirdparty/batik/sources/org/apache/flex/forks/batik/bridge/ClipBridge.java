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
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Factory class for vending <tt>Shape</tt> objects that represents a
 * clipping area.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: ClipBridge.java,v 1.11 2004/08/18 07:12:31 vhardy Exp $
 */
public interface ClipBridge extends Bridge {

    /**
     * Creates a <tt>Clip</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param clipElement the element that defines the clip
     * @param clipedElement the element that references the clip element
     * @param clipedNode the graphics node to clip
     */
    ClipRable createClip(BridgeContext ctx,
                         Element clipElement,
                         Element clipedElement,
                         GraphicsNode clipedNode);
}
