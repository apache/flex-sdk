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
package org.apache.flex.forks.batik.svggen;

import org.apache.flex.forks.batik.util.SVGConstants;

/**
 * Contains the definition of the SVG tags and attribute names.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGSyntax.java,v 1.8 2004/08/18 07:15:09 vhardy Exp $
 */
public interface SVGSyntax extends SVGConstants{
    /**
     * This is a qualified form for href, using the xlink: namespace prefix
     */
    public static final String ATTR_XLINK_HREF = "xlink:" + SVG_HREF_ATTRIBUTE;

    /**
     * ID Prefix. Generated IDs have the form <prefix><nn>
     */
    public static final String ID_PREFIX_ALPHA_COMPOSITE_CLEAR = "alphaCompositeClear";
    public static final String ID_PREFIX_ALPHA_COMPOSITE_DST_IN = "alphaCompositeDstIn";
    public static final String ID_PREFIX_ALPHA_COMPOSITE_DST_OUT = "alphaCompositeDstOut";
    public static final String ID_PREFIX_ALPHA_COMPOSITE_DST_OVER = "alphaCompositeDstOver";
    public static final String ID_PREFIX_ALPHA_COMPOSITE_SRC = "alphaCompositeSrc";
    public static final String ID_PREFIX_ALPHA_COMPOSITE_SRC_IN = "alphaCompositeSrcIn";
    public static final String ID_PREFIX_ALPHA_COMPOSITE_SRC_OUT = "alphaCompositeSrcOut";
    public static final String ID_PREFIX_AMBIENT_LIGHT = "ambientLight";
    public static final String ID_PREFIX_BUMP_MAP = "bumpMap";
    public static final String ID_PREFIX_CLIP_PATH = "clipPath";
    public static final String ID_PREFIX_DEFS = "defs";
    public static final String ID_PREFIX_DIFFUSE_ADD = "diffuseAdd";
    public static final String ID_PREFIX_DIFFUSE_LIGHTING_RESULT = "diffuseLightingResult";
    public static final String ID_PREFIX_FE_CONVOLVE_MATRIX = "convolve";
    public static final String ID_PREFIX_FE_COMPONENT_TRANSFER = "componentTransfer";
    public static final String ID_PREFIX_FE_COMPOSITE = "composite";
    public static final String ID_PREFIX_FE_COMPLEX_FILTER = "complexFilter";
    public static final String ID_PREFIX_FE_DIFFUSE_LIGHTING = "diffuseLighting";
    public static final String ID_PREFIX_FE_FLOOD = "flood";
    public static final String ID_PREFIX_FE_GAUSSIAN_BLUR = "feGaussianBlur";
    public static final String ID_PREFIX_FE_LIGHTING_FILTER = "feLightingFilter";
    public static final String ID_PREFIX_FE_SPECULAR_LIGHTING = "feSpecularLighting";
    public static final String ID_PREFIX_FONT = "font";
    public static final String ID_PREFIX_GENERIC_DEFS = "genericDefs";
    public static final String ID_PREFIX_IMAGE = "image";
    public static final String ID_PREFIX_IMAGE_DEFS = "imageDefs";
    public static final String ID_PREFIX_LINEAR_GRADIENT = "linearGradient";
    public static final String ID_PREFIX_MASK = "mask";
    public static final String ID_PREFIX_PATTERN = "pattern";
    public static final String ID_PREFIX_RADIAL_GRADIENT = "radialGradient";
    public static final String ID_PREFIX_SPECULAR_ADD = "specularAdd";
    public static final String ID_PREFIX_SPECULAR_LIGHTING_RESULT = "specularLightingResult";

    /**
     * Generic
     */
    public static final String CLOSE_PARENTHESIS = ")";
    public static final String COMMA = ",";
    public static final String OPEN_PARENTHESIS = "(";
    public static final String RGB_PREFIX = "rgb(";
    public static final String RGB_SUFFIX = ")";
    public static final String SIGN_PERCENT = "%";
    public static final String SIGN_POUND = "#";
    public static final String SPACE = " ";
    public static final String URL_PREFIX = "url(";
    public static final String URL_SUFFIX = ")";

    public static final String DATA_PROTOCOL_PNG_PREFIX = "data:image/png;base64,";


}
