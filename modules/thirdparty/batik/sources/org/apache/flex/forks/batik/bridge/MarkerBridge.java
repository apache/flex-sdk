/*

   Copyright 2001-2002  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.gvt.Marker;
import org.w3c.dom.Element;

/**
 * Factory class for vending <tt>Marker</tt> objects.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: MarkerBridge.java,v 1.5 2004/08/18 07:12:32 vhardy Exp $
 */
public interface MarkerBridge extends Bridge {

    /**
     * Creates a <tt>Marker</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param markerElement the element that represents the marker
     * @param paintedElement the element that references the marker element
     */
    Marker createMarker(BridgeContext ctx,
                        Element markerElement,
                        Element paintedElement);
}

