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

import java.util.HashSet;
import java.util.Set;

/**
 * Defines the set of attributes from Exchange SVG that
 * are defined as styling properties in Stylable SVG.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGStylingAttributes.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGStylingAttributes implements SVGSyntax{
    static Set attrSet = new HashSet();

    static {
        attrSet.add(SVG_CLIP_PATH_ATTRIBUTE);
        attrSet.add(SVG_COLOR_INTERPOLATION_ATTRIBUTE);
        attrSet.add(SVG_COLOR_RENDERING_ATTRIBUTE);
        attrSet.add(SVG_ENABLE_BACKGROUND_ATTRIBUTE);
        attrSet.add(SVG_FILL_ATTRIBUTE);
        attrSet.add(SVG_FILL_OPACITY_ATTRIBUTE);
        attrSet.add(SVG_FILL_RULE_ATTRIBUTE);
        attrSet.add(SVG_FILTER_ATTRIBUTE);
        attrSet.add(SVG_FLOOD_COLOR_ATTRIBUTE);
        attrSet.add(SVG_FLOOD_OPACITY_ATTRIBUTE);
        attrSet.add(SVG_FONT_FAMILY_ATTRIBUTE);
        attrSet.add(SVG_FONT_SIZE_ATTRIBUTE);
        attrSet.add(SVG_FONT_WEIGHT_ATTRIBUTE);
        attrSet.add(SVG_FONT_STYLE_ATTRIBUTE);
        attrSet.add(SVG_IMAGE_RENDERING_ATTRIBUTE);
        attrSet.add(SVG_MASK_ATTRIBUTE);
        attrSet.add(SVG_OPACITY_ATTRIBUTE);
        attrSet.add(SVG_SHAPE_RENDERING_ATTRIBUTE);
        attrSet.add(SVG_STOP_COLOR_ATTRIBUTE);
        attrSet.add(SVG_STOP_OPACITY_ATTRIBUTE);
        attrSet.add(SVG_STROKE_ATTRIBUTE);
        attrSet.add(SVG_STROKE_OPACITY_ATTRIBUTE);
        attrSet.add(SVG_STROKE_DASHARRAY_ATTRIBUTE);
        attrSet.add(SVG_STROKE_DASHOFFSET_ATTRIBUTE);
        attrSet.add(SVG_STROKE_LINECAP_ATTRIBUTE);
        attrSet.add(SVG_STROKE_LINEJOIN_ATTRIBUTE);
        attrSet.add(SVG_STROKE_MITERLIMIT_ATTRIBUTE);
        attrSet.add(SVG_STROKE_WIDTH_ATTRIBUTE);
        attrSet.add(SVG_TEXT_RENDERING_ATTRIBUTE);
    }

    /**
     * Attributes that represent styling properties
     */
    public static final Set set = attrSet;
}
