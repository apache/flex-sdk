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

import org.w3c.dom.Element;

/**
 * Used to represent an SVG Paint. This can be achieved with
 * to values: an SVG paint value and an SVG opacity value
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGPaintDescriptor.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGPaintDescriptor implements SVGDescriptor, SVGSyntax{
    private Element def;
    private String paintValue;
    private String opacityValue;

    public SVGPaintDescriptor(String paintValue,
                              String opacityValue){
        this.paintValue = paintValue;
        this.opacityValue = opacityValue;
    }

    public SVGPaintDescriptor(String paintValue,
                              String opacityValue,
                              Element def){
        this(paintValue, opacityValue);
        this.def = def;
    }

    public String getPaintValue(){
        return paintValue;
    }

    public String getOpacityValue(){
        return opacityValue;
    }

    public Element getDef(){
        return def;
    }

    public Map getAttributeMap(Map attrMap){
        if(attrMap == null)
            attrMap = new HashMap();

        attrMap.put(SVG_FILL_ATTRIBUTE, paintValue);
        attrMap.put(SVG_STROKE_ATTRIBUTE, paintValue);
        attrMap.put(SVG_FILL_OPACITY_ATTRIBUTE, opacityValue);
        attrMap.put(SVG_STROKE_OPACITY_ATTRIBUTE, opacityValue);

        return attrMap;
    }

    public List getDefinitionSet(List defSet){
        if(defSet == null)
            defSet = new LinkedList();

        if(def != null)
            defSet.add(def);

        return defSet;
    }
}
