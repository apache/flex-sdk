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
package org.apache.flex.forks.batik.svggen;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Describes an SVG transform
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGTransformDescriptor.java 475477 2006-11-15 22:44:28Z cam $
 * @see           org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext
 */
public class SVGTransformDescriptor implements SVGDescriptor, SVGSyntax{
    private String transform;

    public SVGTransformDescriptor(String transform){
        this.transform = transform;
    }

    /**
     * @param attrMap if not null, attribute name/value pairs
     *        for this descriptor should be written in this Map.
     *        Otherwise, a new Map will be created and attribute
     *        name/value pairs will be written into it.
     * @return a map containing the SVG attributes needed by the
     *         descriptor.
     */
    public Map getAttributeMap(Map attrMap){
        if(attrMap == null)
            attrMap = new HashMap();

        attrMap.put(SVG_TRANSFORM_ATTRIBUTE, transform);

        return attrMap;
    }

    /**
     * @param defSet if not null, definitions required to provide
     *        targets for the descriptor attribute values will be
     *        copied into defSet. If null, a new Set should be created
     *        and definitions copied into it. The set contains
     *        zero, one or more Elements.
     * @return a set containing Elements that represent the definition
     *         of the descriptor's attribute values
     */
    public List getDefinitionSet(List defSet) {
        if (defSet == null)
            defSet = new LinkedList();

        return defSet;
    }
}
