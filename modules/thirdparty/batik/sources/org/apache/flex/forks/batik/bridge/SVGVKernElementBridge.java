/*

   Copyright 2001  The Apache Software Foundation 

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

/**
 * Bridge class for the &lt;vkern> element.
 *
 * @author <a href="mailto:dean.jackson@cmis.csiro.au">Dean Jackson</a>
 * @version $Id: SVGVKernElementBridge.java,v 1.3 2004/08/18 07:12:36 vhardy Exp $
 */
public class SVGVKernElementBridge extends SVGKernElementBridge {

    /**
     * Constructs a new bridge for the &lt;vkern> element.
     */
    public SVGVKernElementBridge() {}

    /**
     * Returns 'vkern'.
     */
    public String getLocalName() {
        return SVG_VKERN_TAG;
    }

}
