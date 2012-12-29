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

import org.apache.flex.forks.batik.util.SVGConstants;

/**
 * Contains the definition of the SVG tags and attribute names.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGSyntax.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SVGSyntax extends SVGConstants {

    // ID prefix constants.  Generated IDs have the form <prefix><nn>.
    String ID_PREFIX_ALPHA_COMPOSITE_CLEAR = "alphaCompositeClear";
    String ID_PREFIX_ALPHA_COMPOSITE_DST_IN = "alphaCompositeDstIn";
    String ID_PREFIX_ALPHA_COMPOSITE_DST_OUT = "alphaCompositeDstOut";
    String ID_PREFIX_ALPHA_COMPOSITE_DST_OVER = "alphaCompositeDstOver";
    String ID_PREFIX_ALPHA_COMPOSITE_SRC = "alphaCompositeSrc";
    String ID_PREFIX_ALPHA_COMPOSITE_SRC_IN = "alphaCompositeSrcIn";
    String ID_PREFIX_ALPHA_COMPOSITE_SRC_OUT = "alphaCompositeSrcOut";
    String ID_PREFIX_AMBIENT_LIGHT = "ambientLight";
    String ID_PREFIX_BUMP_MAP = "bumpMap";
    String ID_PREFIX_CLIP_PATH = "clipPath";
    String ID_PREFIX_DEFS = "defs";
    String ID_PREFIX_DIFFUSE_ADD = "diffuseAdd";
    String ID_PREFIX_DIFFUSE_LIGHTING_RESULT = "diffuseLightingResult";
    String ID_PREFIX_FE_CONVOLVE_MATRIX = "convolve";
    String ID_PREFIX_FE_COMPONENT_TRANSFER = "componentTransfer";
    String ID_PREFIX_FE_COMPOSITE = "composite";
    String ID_PREFIX_FE_COMPLEX_FILTER = "complexFilter";
    String ID_PREFIX_FE_DIFFUSE_LIGHTING = "diffuseLighting";
    String ID_PREFIX_FE_FLOOD = "flood";
    String ID_PREFIX_FE_GAUSSIAN_BLUR = "feGaussianBlur";
    String ID_PREFIX_FE_LIGHTING_FILTER = "feLightingFilter";
    String ID_PREFIX_FE_SPECULAR_LIGHTING = "feSpecularLighting";
    String ID_PREFIX_FONT = "font";
    String ID_PREFIX_GENERIC_DEFS = "genericDefs";
    String ID_PREFIX_IMAGE = "image";
    String ID_PREFIX_IMAGE_DEFS = "imageDefs";
    String ID_PREFIX_LINEAR_GRADIENT = "linearGradient";
    String ID_PREFIX_MASK = "mask";
    String ID_PREFIX_PATTERN = "pattern";
    String ID_PREFIX_RADIAL_GRADIENT = "radialGradient";
    String ID_PREFIX_SPECULAR_ADD = "specularAdd";
    String ID_PREFIX_SPECULAR_LIGHTING_RESULT = "specularLightingResult";

    // Generic string constants.
    String CLOSE_PARENTHESIS = ")";
    String COMMA = ",";
    String OPEN_PARENTHESIS = "(";
    String RGB_PREFIX = "rgb(";
    String RGB_SUFFIX = ")";
    String SIGN_PERCENT = "%";
    String SIGN_POUND = "#";
    String SPACE = " ";
    String URL_PREFIX = "url(";
    String URL_SUFFIX = ")";

    String DATA_PROTOCOL_PNG_PREFIX = "data:image/png;base64,";
}
