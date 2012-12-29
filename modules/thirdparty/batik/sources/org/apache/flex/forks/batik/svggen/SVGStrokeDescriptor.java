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
 * Used to represent an SVG Paint. This can be achieved with
 * to values: an SVG paint value and an SVG opacity value
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGStrokeDescriptor.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGStrokeDescriptor implements SVGDescriptor, SVGSyntax{
    private String strokeWidth;
    private String capStyle;
    private String joinStyle;
    private String miterLimit;
    private String dashArray;
    private String dashOffset;


    public SVGStrokeDescriptor(String strokeWidth, String capStyle,
                               String joinStyle, String miterLimit,
                               String dashArray, String dashOffset){
        if(strokeWidth == null ||
           capStyle == null    ||
           joinStyle == null   ||
           miterLimit == null  ||
           dashArray == null   ||
           dashOffset == null)
            throw new SVGGraphics2DRuntimeException(ErrorConstants.ERR_STROKE_NULL);

        this.strokeWidth = strokeWidth;
        this.capStyle = capStyle;
        this.joinStyle = joinStyle;
        this.miterLimit = miterLimit;
        this.dashArray = dashArray;
        this.dashOffset = dashOffset;
    }

    String getStrokeWidth(){ return strokeWidth; }
    String getCapStyle(){ return capStyle; }
    String getJoinStyle(){ return joinStyle; }
    String getMiterLimit(){ return miterLimit; }
    String getDashArray(){ return dashArray; }
    String getDashOffset(){ return dashOffset; }

    public Map getAttributeMap(Map attrMap){
        if(attrMap == null)
            attrMap = new HashMap();

        attrMap.put(SVG_STROKE_WIDTH_ATTRIBUTE, strokeWidth);
        attrMap.put(SVG_STROKE_LINECAP_ATTRIBUTE, capStyle);
        attrMap.put(SVG_STROKE_LINEJOIN_ATTRIBUTE, joinStyle);
        attrMap.put(SVG_STROKE_MITERLIMIT_ATTRIBUTE, miterLimit);
        attrMap.put(SVG_STROKE_DASHARRAY_ATTRIBUTE, dashArray);
        attrMap.put(SVG_STROKE_DASHOFFSET_ATTRIBUTE, dashOffset);

        return attrMap;
    }

    public List getDefinitionSet(List defSet){
        if(defSet == null)
            defSet = new LinkedList();

        return defSet;
    }
}
