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
package org.apache.flex.forks.batik.util;

import java.util.Set;

/**
 * Exposes the SVG feature strings that Batik supports.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id$
 */
public class SVGFeatureStrings {

    /**
     * Adds a <code>String</code> to the specified {@link Set} corresponding
     * to each SVG feature string that Batik supports.
     *
     * @param features The set to add feature strings to.
     */
    public static void addSupportedFeatureStrings(Set features) {
        // SVG 1.0 feature strings
        features.add(SVGConstants.SVG_ORG_W3C_SVG_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_SVG_STATIC_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_SVG_ANIMATION_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_SVG_DYNAMIC_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_SVG_ALL_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_DOM_SVG_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_DOM_SVG_STATIC_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_DOM_SVG_ANIMATION_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_DOM_SVG_DYNAMIC_FEATURE);
        features.add(SVGConstants.SVG_ORG_W3C_DOM_SVG_ALL_FEATURE);

        // SVG 1.1 feature strings
        // Due to SVG_SVG11_VIEWPORT_ATTRIBUTE_FEATURE not being supported
        // features.add(SVGConstants.SVG_SVG11_SVG_FEATURE);
        // features.add(SVGConstants.SVG_SVG11_SVG_STATIC_FEATURE);
        // features.add(SVGConstants.SVG_SVG11_SVG_ANIMATION_FEATURE);
        // features.add(SVGConstants.SVG_SVG11_SVG_DYNAMIC_FEATURE);
        features.add(SVGConstants.SVG_SVG11_SVG_DOM_FEATURE);
        features.add(SVGConstants.SVG_SVG11_SVG_DOM_STATIC_FEATURE);
        features.add(SVGConstants.SVG_SVG11_SVG_DOM_ANIMATION_FEATURE);
        features.add(SVGConstants.SVG_SVG11_SVG_DOM_DYNAMIC_FEATURE);

        features.add(SVGConstants.SVG_SVG11_CORE_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_STRUCTURE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_BASIC_STRUCTURE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_CONTAINER_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_CONDITIONAL_PROCESSING_FEATURE);
        features.add(SVGConstants.SVG_SVG11_IMAGE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_STYLE_FEATURE);
        // 'clip' on various elements not supported
        // features.add(SVGConstants.SVG_SVG11_VIEWPORT_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_SHAPE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_TEXT_FEATURE);
        features.add(SVGConstants.SVG_SVG11_BASIC_TEXT_FEATURE);
        features.add(SVGConstants.SVG_SVG11_PAINT_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_BASIC_PAINT_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_OPACITY_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_GRAPHICS_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_BASIC_GRAPHICS_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_MARKER_FEATURE);
        features.add(SVGConstants.SVG_SVG11_COLOR_PROFILE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_GRADIENT_FEATURE);
        features.add(SVGConstants.SVG_SVG11_PATTERN_FEATURE);
        features.add(SVGConstants.SVG_SVG11_CLIP_FEATURE);
        features.add(SVGConstants.SVG_SVG11_BASIC_CLIP_FEATURE);
        features.add(SVGConstants.SVG_SVG11_MASK_FEATURE);
        features.add(SVGConstants.SVG_SVG11_FILTER_FEATURE);
        features.add(SVGConstants.SVG_SVG11_BASIC_FILTER_FEATURE);
        features.add(SVGConstants.SVG_SVG11_DOCUMENT_EVENTS_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_GRAPHICAL_EVENTS_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_ANIMATION_EVENTS_ATTRIBUTE_FEATURE);
        features.add(SVGConstants.SVG_SVG11_CURSOR_FEATURE);
        features.add(SVGConstants.SVG_SVG11_HYPERLINKING_FEATURE);
        features.add(SVGConstants.SVG_SVG11_XLINK_FEATURE);
        // externalResourcesRequired="" not supported
        // features.add(SVGConstants.SVG_SVG11_EXTERNAL_RESOURCES_REQUIRED_FEATURE);
        features.add(SVGConstants.SVG_SVG11_VIEW_FEATURE);
        features.add(SVGConstants.SVG_SVG11_SCRIPT_FEATURE);
        features.add(SVGConstants.SVG_SVG11_ANIMATION_FEATURE);
        features.add(SVGConstants.SVG_SVG11_FONT_FEATURE);
        features.add(SVGConstants.SVG_SVG11_BASIC_FONT_FEATURE);
        features.add(SVGConstants.SVG_SVG11_EXTENSIBILITY_FEATURE);
    }
}
