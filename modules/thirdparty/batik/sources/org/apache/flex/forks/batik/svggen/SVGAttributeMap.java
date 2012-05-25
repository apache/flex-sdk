/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.svggen;

import java.util.HashMap;
import java.util.Map;

/**
 * Repository of SVG attribute descriptions, accessible by
 * name.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGAttributeMap.java,v 1.6 2005/03/27 08:58:35 cam Exp $
 */
public class SVGAttributeMap{
    /**
     * Map of attribute name to SVGAttribute objects
     */
    private static Map attrMap = new HashMap();

    /**
     * @param attrName SVG name of the requested attribute
     * @return attribute with requested name
     */
    public static SVGAttribute get(String attrName) {
        return (SVGAttribute)attrMap.get(attrName);
    }
}
