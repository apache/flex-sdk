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

/**
 * Define SVG constants, such as tag names, attribute names and URI
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGConstants.java 598513 2007-11-27 04:21:10Z cam $
 */
public interface SVGConstants extends CSSConstants, XMLConstants {

    /////////////////////////////////////////////////////////////////////////
    // SVG general
    /////////////////////////////////////////////////////////////////////////

    String SVG_PUBLIC_ID =
        "-//W3C//DTD SVG 1.0//EN";
    String SVG_SYSTEM_ID =
        "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd";
    String SVG_NAMESPACE_URI =
        "http://www.w3.org/2000/svg";
    String SVG_VERSION =
        "1.0";

    //////////////////////////////////////////////////////////////////////////
    // Events type and attributes
    //////////////////////////////////////////////////////////////////////////

    /**
     * The event type for MouseEvent.
     */
    String SVG_MOUSEEVENTS_EVENT_TYPE = "MouseEvents";

    /**
     * The event type for UIEvent.
     */
    String SVG_UIEVENTS_EVENT_TYPE = "UIEvents";

    /**
     * The event type for SVGEvent.
     */
    String SVG_SVGEVENTS_EVENT_TYPE = "SVGEvents";

    /**
     * The event type for KeyEvent.
     */
    String SVG_KEYEVENTS_EVENT_TYPE = "KeyEvents";

    // ---------------------------------------------------------------------

    /**
     * The event type for 'keydown' KeyEvent.
     */
    String SVG_KEYDOWN_EVENT_TYPE = "keydown";

    /**
     * The event type for 'keypress' KeyEvent.
     */
    String SVG_KEYPRESS_EVENT_TYPE = "keypress";

    /**
     * The event type for 'keyup' KeyEvent.
     */
    String SVG_KEYUP_EVENT_TYPE = "keyup";

    /**
     * The event type for 'click' MouseEvent.
     */
    String SVG_CLICK_EVENT_TYPE = "click";

    /**
     * The event type for 'mouseup' MouseEvent.
     */
    String SVG_MOUSEUP_EVENT_TYPE = "mouseup";

    /**
     * The event type for 'mousedown' MouseEvent.
     */
    String SVG_MOUSEDOWN_EVENT_TYPE = "mousedown";

    /**
     * The event type for 'mousemove' MouseEvent.
     */
    String SVG_MOUSEMOVE_EVENT_TYPE = "mousemove";

    /**
     * The event type for 'mouseout' MouseEvent.
     */
    String SVG_MOUSEOUT_EVENT_TYPE = "mouseout";

    /**
     * The event type for 'mouseover' MouseEvent.
     */
    String SVG_MOUSEOVER_EVENT_TYPE = "mouseover";

    /**
     * The event type for 'DOMFocusIn' UIEvent.
     */
    String SVG_DOMFOCUSIN_EVENT_TYPE = "DOMFocusIn";

    /**
     * The event type for 'DOMFocusOut' UIEvent.
     */
    String SVG_DOMFOCUSOUT_EVENT_TYPE = "DOMFocusOut";

    /**
     * The event type for 'DOMActivate' UIEvent.
     */
    String SVG_DOMACTIVATE_EVENT_TYPE = "DOMActivate";

    /**
     * The event type for 'SVGLoad' SVGEvent.
     */
    String SVG_SVGLOAD_EVENT_TYPE = "SVGLoad";

    /**
     * The event type for 'SVGUnload' SVGEvent.
     */
    String SVG_SVGUNLOAD_EVENT_TYPE = "SVGUnload";

    /**
     * The event type for 'SVGAbort' SVGEvent.
     */
    String SVG_SVGABORT_EVENT_TYPE = "SVGAbort";

    /**
     * The event type for 'SVGError' SVGEvent.
     */
    String SVG_SVGERROR_EVENT_TYPE = "SVGError";

    /**
     * The event type for 'SVGResize' SVGEvent.
     */
    String SVG_SVGRESIZE_EVENT_TYPE = "SVGResize";

    /**
     * The event type for 'SVGScroll' SVGEvent.
     */
    String SVG_SVGSCROLL_EVENT_TYPE = "SVGScroll";

    /**
     * The event type for 'SVGZoom' SVGEvent.
     */
    String SVG_SVGZOOM_EVENT_TYPE = "SVGZoom";

    // ---------------------------------------------------------------------

    /**
     * The 'onkeyup' attribute name of type KeyEvents.
     */
    String SVG_ONKEYUP_ATTRIBUTE = "onkeyup";

    /**
     * The 'onkeydown' attribute name of type KeyEvents.
     */
    String SVG_ONKEYDOWN_ATTRIBUTE = "onkeydown";

    /**
     * The 'onkeypress' attribute name of type KeyEvents.
     */
    String SVG_ONKEYPRESS_ATTRIBUTE = "onkeypress";

    /**
     * The 'onabort' attribute name of type SVGEvents.
     */
    String SVG_ONABORT_ATTRIBUTE = "onabort";

    /**
     * The 'onabort' attribute name of type SVGEvents.
     */
    String SVG_ONACTIVATE_ATTRIBUTE = "onactivate";

    /**
     * The 'onbegin' attribute name of type SVGEvents.
     */
    String SVG_ONBEGIN_ATTRIBUTE = "onbegin";

    /**
     * The 'onclick' attribute name of type MouseEvents.
     */
    String SVG_ONCLICK_ATTRIBUTE = "onclick";

    /**
     * The 'onend' attribute name of type SVGEvents.
     */
    String SVG_ONEND_ATTRIBUTE = "onend";

    /**
     * The 'onerror' attribute name of type SVGEvents.
     */
    String SVG_ONERROR_ATTRIBUTE = "onerror";

    /**
     * The 'onfocusin' attribute name of type UIEvents.
     */
    String SVG_ONFOCUSIN_ATTRIBUTE = "onfocusin";

    /**
     * The 'onfocusout' attribute name of type UIEvents.
     */
    String SVG_ONFOCUSOUT_ATTRIBUTE = "onfocusout";

    /**
     * The 'onload' attribute name of type SVGEvents.
     */
    String SVG_ONLOAD_ATTRIBUTE = "onload";

    /**
     * The 'onmousedown' attribute name of type MouseEvents.
     */
    String SVG_ONMOUSEDOWN_ATTRIBUTE = "onmousedown";

    /**
     * The 'onmousemove' attribute name of type MouseEvents.
     */
    String SVG_ONMOUSEMOVE_ATTRIBUTE = "onmousemove";

    /**
     * The 'onmouseout' attribute name of type MouseEvents.
     */
    String SVG_ONMOUSEOUT_ATTRIBUTE = "onmouseout";

    /**
     * The 'onmouseover' attribute name of type MouseEvents.
     */
    String SVG_ONMOUSEOVER_ATTRIBUTE = "onmouseover";

    /**
     * The 'onmouseup' attribute name of type MouseEvents.
     */
    String SVG_ONMOUSEUP_ATTRIBUTE = "onmouseup";

    /**
     * The 'onrepeat' attribute name of type SVGEvents.
     */
    String SVG_ONREPEAT_ATTRIBUTE = "onrepeat";

    /**
     * The 'onresize' attribute name of type SVGEvents.
     */
    String SVG_ONRESIZE_ATTRIBUTE = "onresize";

    /**
     * The 'onscroll' attribute name of type SVGEvents.
     */
    String SVG_ONSCROLL_ATTRIBUTE = "onscroll";
 
    /**
     * The 'onunload' attribute name of type SVGEvents.
     */
    String SVG_ONUNLOAD_ATTRIBUTE = "onunload";

    /**
     * The 'onzoom' attribute name of type SVGEvents.
     */
    String SVG_ONZOOM_ATTRIBUTE = "onzoom";

    /////////////////////////////////////////////////////////////////////////
    // SVG features
    /////////////////////////////////////////////////////////////////////////

    // SVG 1.0 feature strings
    String SVG_ORG_W3C_SVG_FEATURE = "org.w3c.svg";
    String SVG_ORG_W3C_SVG_STATIC_FEATURE = "org.w3c.svg.static";
    String SVG_ORG_W3C_SVG_ANIMATION_FEATURE = "org.w3c.svg.animation";
    String SVG_ORG_W3C_SVG_DYNAMIC_FEATURE = "org.w3c.svg.dynamic";
    String SVG_ORG_W3C_SVG_ALL_FEATURE = "org.w3c.svg.all";
    String SVG_ORG_W3C_DOM_SVG_FEATURE = "org.w3c.dom.svg";
    String SVG_ORG_W3C_DOM_SVG_STATIC_FEATURE = "org.w3c.dom.svg.static";
    String SVG_ORG_W3C_DOM_SVG_ANIMATION_FEATURE = "org.w3c.dom.svg.animation";
    String SVG_ORG_W3C_DOM_SVG_DYNAMIC_FEATURE = "org.w3c.dom.svg.dynamic";
    String SVG_ORG_W3C_DOM_SVG_ALL_FEATURE = "org.w3c.dom.svg.all";

    // SVG 1.1 feature strings
    String SVG_SVG11_SVG_FEATURE = "http://www.w3.org/TR/SVG11/feature#SVG";
    String SVG_SVG11_SVG_DOM_FEATURE = "http://www.w3.org/TR/SVG11/feature#SVGDOM";
    String SVG_SVG11_SVG_STATIC_FEATURE = "http://www.w3.org/TR/SVG11/feature#SVG-static";
    String SVG_SVG11_SVG_DOM_STATIC_FEATURE = "http://www.w3.org/TR/SVG11/feature#SVGDOM-static";
    String SVG_SVG11_SVG_ANIMATION_FEATURE = "http://www.w3.org/TR/SVG11/feature#SVG-animation";
    String SVG_SVG11_SVG_DOM_ANIMATION_FEATURE = "http://www.w3.org/TR/SVG11/feature#SVGDOM-animation";
    String SVG_SVG11_SVG_DYNAMIC_FEATURE = "http://www.w3.org/TR/SVG11/feature#SVG-dynamic";
    String SVG_SVG11_SVG_DOM_DYNAMIC_FEATURE = "http://www.w3.org/TR/SVG11/feature#SVGDOM-dynamic";
    String SVG_SVG11_CORE_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#CoreAttribute";
    String SVG_SVG11_STRUCTURE_FEATURE = "http://www.w3.org/TR/SVG11/feature#Structure";
    String SVG_SVG11_BASIC_STRUCTURE_FEATURE = "http://www.w3.org/TR/SVG11/feature#BasicStructure";
    String SVG_SVG11_CONTAINER_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#ContainerAttribute";
    String SVG_SVG11_CONDITIONAL_PROCESSING_FEATURE = "http://www.w3.org/TR/SVG11/feature#ConditionalProcessing";
    String SVG_SVG11_IMAGE_FEATURE = "http://www.w3.org/TR/SVG11/feature#Image";
    String SVG_SVG11_STYLE_FEATURE = "http://www.w3.org/TR/SVG11/feature#Style";
    String SVG_SVG11_VIEWPORT_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#ViewportAttribute";
    String SVG_SVG11_SHAPE_FEATURE = "http://www.w3.org/TR/SVG11/feature#Shape";
    String SVG_SVG11_TEXT_FEATURE = "http://www.w3.org/TR/SVG11/feature#Text";
    String SVG_SVG11_BASIC_TEXT_FEATURE = "http://www.w3.org/TR/SVG11/feature#BasicText";
    String SVG_SVG11_PAINT_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#PaintAttribute";
    String SVG_SVG11_BASIC_PAINT_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#BasicPaintAttribute";
    String SVG_SVG11_OPACITY_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#OpacityAttribute";
    String SVG_SVG11_GRAPHICS_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#GraphicsAttribute";
    String SVG_SVG11_BASIC_GRAPHICS_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#BasicGraphicsAttribute";
    String SVG_SVG11_MARKER_FEATURE = "http://www.w3.org/TR/SVG11/feature#Marker";
    String SVG_SVG11_COLOR_PROFILE_FEATURE = "http://www.w3.org/TR/SVG11/feature#ColorProfile";
    String SVG_SVG11_GRADIENT_FEATURE = "http://www.w3.org/TR/SVG11/feature#Gradient";
    String SVG_SVG11_PATTERN_FEATURE = "http://www.w3.org/TR/SVG11/feature#Pattern";
    String SVG_SVG11_CLIP_FEATURE = "http://www.w3.org/TR/SVG11/feature#Clip";
    String SVG_SVG11_BASIC_CLIP_FEATURE = "http://www.w3.org/TR/SVG11/feature#BasicClip";
    String SVG_SVG11_MASK_FEATURE = "http://www.w3.org/TR/SVG11/feature#Mask";
    String SVG_SVG11_FILTER_FEATURE = "http://www.w3.org/TR/SVG11/feature#Filter";
    String SVG_SVG11_BASIC_FILTER_FEATURE = "http://www.w3.org/TR/SVG11/feature#BasicFilter";
    String SVG_SVG11_DOCUMENT_EVENTS_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#DocumentEventsAttribute";
    String SVG_SVG11_GRAPHICAL_EVENTS_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#GraphicalEventsAttribute";
    String SVG_SVG11_ANIMATION_EVENTS_ATTRIBUTE_FEATURE = "http://www.w3.org/TR/SVG11/feature#AnimationEventsAttribute";
    String SVG_SVG11_CURSOR_FEATURE = "http://www.w3.org/TR/SVG11/feature#Cursor";
    String SVG_SVG11_HYPERLINKING_FEATURE = "http://www.w3.org/TR/SVG11/feature#Hyperlinking";
    String SVG_SVG11_XLINK_FEATURE = "http://www.w3.org/TR/SVG11/feature#Xlink";
    String SVG_SVG11_EXTERNAL_RESOURCES_REQUIRED_FEATURE = "http://www.w3.org/TR/SVG11/feature#ExternalResourcesRequired";
    String SVG_SVG11_VIEW_FEATURE = "http://www.w3.org/TR/SVG11/feature#View";
    String SVG_SVG11_SCRIPT_FEATURE = "http://www.w3.org/TR/SVG11/feature#Script";
    String SVG_SVG11_ANIMATION_FEATURE = "http://www.w3.org/TR/SVG11/feature#Animation";
    String SVG_SVG11_FONT_FEATURE = "http://www.w3.org/TR/SVG11/feature#Font";
    String SVG_SVG11_BASIC_FONT_FEATURE = "http://www.w3.org/TR/SVG11/feature#BasicFont";
    String SVG_SVG11_EXTENSIBILITY_FEATURE = "http://www.w3.org/TR/SVG11/feature#Extensibility";

    // TODO SVG 1.2 feature strings

    /////////////////////////////////////////////////////////////////////////
    // SVG tags
    /////////////////////////////////////////////////////////////////////////

    String SVG_A_TAG = "a";
    String SVG_ALT_GLYPH_TAG = "altGlyph";
    String SVG_ALT_GLYPH_DEF_TAG = "altGlyphDef";
    String SVG_ALT_GLYPH_ITEM_TAG = "altGlyphItem";
    String SVG_ANIMATE_TAG = "animate";
    String SVG_ANIMATE_COLOR_TAG = "animateColor";
    String SVG_ANIMATE_MOTION_TAG = "animateMotion";
    String SVG_ANIMATE_TRANSFORM_TAG = "animateTransform";
    String SVG_CIRCLE_TAG = "circle";
    String SVG_CLIP_PATH_TAG = "clipPath";
    String SVG_COLOR_PROFILE_TAG = "color-profile";
    String SVG_CURSOR_TAG = "cursor";
    String SVG_DEFINITION_SRC_TAG = "definition-src";
    String SVG_DEFS_TAG = "defs";
    String SVG_DESC_TAG = "desc";
    String SVG_ELLIPSE_TAG = "ellipse";
    String SVG_FE_BLEND_TAG = "feBlend";
    String SVG_FE_COLOR_MATRIX_TAG = "feColorMatrix";
    String SVG_FE_COMPONENT_TRANSFER_TAG = "feComponentTransfer";
    String SVG_FE_COMPOSITE_TAG = "feComposite";
    String SVG_FE_CONVOLVE_MATRIX_TAG = "feConvolveMatrix";
    String SVG_FE_DIFFUSE_LIGHTING_TAG = "feDiffuseLighting";
    String SVG_FE_DISPLACEMENT_MAP_TAG = "feDisplacementMap";
    String SVG_FE_DISTANT_LIGHT_TAG = "feDistantLight";
    String SVG_FE_FLOOD_TAG = "feFlood";
    String SVG_FE_FUNC_A_TAG = "feFuncA";
    String SVG_FE_FUNC_B_TAG = "feFuncB";
    String SVG_FE_FUNC_G_TAG = "feFuncG";
    String SVG_FE_FUNC_R_TAG = "feFuncR";
    String SVG_FE_GAUSSIAN_BLUR_TAG = "feGaussianBlur";
    String SVG_FE_IMAGE_TAG = "feImage";
    String SVG_FE_MERGE_NODE_TAG = "feMergeNode";
    String SVG_FE_MERGE_TAG = "feMerge";
    String SVG_FE_MORPHOLOGY_TAG = "feMorphology";
    String SVG_FE_OFFSET_TAG = "feOffset";
    String SVG_FE_POINT_LIGHT_TAG = "fePointLight";
    String SVG_FE_SPECULAR_LIGHTING_TAG = "feSpecularLighting";
    String SVG_FE_SPOT_LIGHT_TAG = "feSpotLight";
    String SVG_FE_TILE_TAG = "feTile";
    String SVG_FE_TURBULENCE_TAG = "feTurbulence";
    String SVG_FILTER_TAG = "filter";
    String SVG_FONT_TAG = "font";
    String SVG_FONT_FACE_TAG = "font-face";
    String SVG_FONT_FACE_FORMAT_TAG = "font-face-format";
    String SVG_FONT_FACE_NAME_TAG = "font-face-name";
    String SVG_FONT_FACE_SRC_TAG = "font-face-src";
    String SVG_FONT_FACE_URI_TAG = "font-face-uri";
    String SVG_FOREIGN_OBJECT_TAG = "foreignObject";
    String SVG_G_TAG = "g";
    String SVG_GLYPH_TAG = "glyph";
    String SVG_GLYPH_REF_TAG = "glyphRef";
    String SVG_HKERN_TAG = "hkern";
    String SVG_IMAGE_TAG = "image";
    String SVG_LINE_TAG = "line";
    String SVG_LINEAR_GRADIENT_TAG = "linearGradient";
    String SVG_MARKER_TAG = "marker";
    String SVG_MASK_TAG = "mask";
    String SVG_METADATA_TAG = "metadata";
    String SVG_MISSING_GLYPH_TAG = "missing-glyph";
    String SVG_MPATH_TAG = "mpath";
    String SVG_PATH_TAG = "path";
    String SVG_PATTERN_TAG = "pattern";
    String SVG_POLYGON_TAG = "polygon";
    String SVG_POLYLINE_TAG = "polyline";
    String SVG_RADIAL_GRADIENT_TAG = "radialGradient";
    String SVG_RECT_TAG = "rect";
    String SVG_SET_TAG = "set";
    String SVG_SCRIPT_TAG = "script";
    String SVG_STOP_TAG = "stop";
    String SVG_STYLE_TAG = "style";
    String SVG_SVG_TAG = "svg";
    String SVG_SWITCH_TAG = "switch";
    String SVG_SYMBOL_TAG = "symbol";
    String SVG_TEXT_PATH_TAG = "textPath";
    String SVG_TEXT_TAG = "text";
    String SVG_TITLE_TAG = "title";
    String SVG_TREF_TAG = "tref";
    String SVG_TSPAN_TAG = "tspan";
    String SVG_USE_TAG = "use";
    String SVG_VIEW_TAG = "view";
    String SVG_VKERN_TAG = "vkern";

    /////////////////////////////////////////////////////////////////////////
    // SVG attributes
    /////////////////////////////////////////////////////////////////////////

    String SVG_ACCENT_HEIGHT_ATTRIBUTE = "accent-height";
    String SVG_ACCUMULATE_ATTRIBUTE = "accumulate";
    String SVG_ADDITIVE_ATTRIBUTE = "additive";
    String SVG_AMPLITUDE_ATTRIBUTE = "amplitude";
    String SVG_ARABIC_FORM_ATTRIBUTE = "arabic-form";
    String SVG_ASCENT_ATTRIBUTE = "ascent";
    String SVG_AZIMUTH_ATTRIBUTE = "azimuth";
    String SVG_ALPHABETIC_ATTRIBUTE = "alphabetic";
    String SVG_ATTRIBUTE_NAME_ATTRIBUTE = "attributeName";
    String SVG_ATTRIBUTE_TYPE_ATTRIBUTE = "attributeType";
    String SVG_BASE_FREQUENCY_ATTRIBUTE = "baseFrequency";
    String SVG_BASE_PROFILE_ATTRIBUTE = "baseProfile";
    String SVG_BEGIN_ATTRIBUTE = "begin";
    String SVG_BBOX_ATTRIBUTE = "bbox";
    String SVG_BIAS_ATTRIBUTE = "bias";
    String SVG_BY_ATTRIBUTE = "by";
    String SVG_CALC_MODE_ATTRIBUTE = "calcMode";
    String SVG_CAP_HEIGHT_ATTRIBUTE = "cap-height";
    String SVG_CLASS_ATTRIBUTE = "class";
    String SVG_CLIP_PATH_ATTRIBUTE = CSS_CLIP_PATH_PROPERTY;
    String SVG_CLIP_PATH_UNITS_ATTRIBUTE = "clipPathUnits";
    String SVG_COLOR_INTERPOLATION_ATTRIBUTE = CSS_COLOR_INTERPOLATION_PROPERTY;
    String SVG_COLOR_RENDERING_ATTRIBUTE = CSS_COLOR_RENDERING_PROPERTY;
    String SVG_CONTENT_SCRIPT_TYPE_ATTRIBUTE = "contentScriptType";
    String SVG_CONTENT_STYLE_TYPE_ATTRIBUTE = "contentStyleType";
    String SVG_CX_ATTRIBUTE = "cx";
    String SVG_CY_ATTRIBUTE = "cy";
    String SVG_DESCENT_ATTRIBUTE = "descent";
    String SVG_DIFFUSE_CONSTANT_ATTRIBUTE = "diffuseConstant";
    String SVG_DIVISOR_ATTRIBUTE = "divisor";
    String SVG_DUR_ATTRIBUTE = "dur";
    String SVG_DX_ATTRIBUTE = "dx";
    String SVG_DY_ATTRIBUTE = "dy";
    String SVG_D_ATTRIBUTE = "d";
    String SVG_EDGE_MODE_ATTRIBUTE = "edgeMode";
    String SVG_ELEVATION_ATTRIBUTE = "elevation";
    String SVG_ENABLE_BACKGROUND_ATTRIBUTE = CSS_ENABLE_BACKGROUND_PROPERTY;
    String SVG_END_ATTRIBUTE = "end";
    String SVG_EXPONENT_ATTRIBUTE = "exponent";
    String SVG_EXTERNAL_RESOURCES_REQUIRED_ATTRIBUTE = "externalResourcesRequired";
    String SVG_FILL_ATTRIBUTE = CSS_FILL_PROPERTY;
    String SVG_FILL_OPACITY_ATTRIBUTE = CSS_FILL_OPACITY_PROPERTY;
    String SVG_FILL_RULE_ATTRIBUTE = CSS_FILL_RULE_PROPERTY;
    String SVG_FILTER_ATTRIBUTE = CSS_FILTER_PROPERTY;
    String SVG_FILTER_RES_ATTRIBUTE = "filterRes";
    String SVG_FILTER_UNITS_ATTRIBUTE = "filterUnits";
    String SVG_FLOOD_COLOR_ATTRIBUTE = CSS_FLOOD_COLOR_PROPERTY;
    String SVG_FLOOD_OPACITY_ATTRIBUTE = CSS_FLOOD_OPACITY_PROPERTY;
    String SVG_FORMAT_ATTRIBUTE = "format";
    String SVG_FONT_FAMILY_ATTRIBUTE = CSS_FONT_FAMILY_PROPERTY;
    String SVG_FONT_SIZE_ATTRIBUTE = CSS_FONT_SIZE_PROPERTY;
    String SVG_FONT_STRETCH_ATTRIBUTE = CSS_FONT_STRETCH_PROPERTY;
    String SVG_FONT_STYLE_ATTRIBUTE = CSS_FONT_STYLE_PROPERTY;
    String SVG_FONT_VARIANT_ATTRIBUTE = CSS_FONT_VARIANT_PROPERTY;
    String SVG_FONT_WEIGHT_ATTRIBUTE = CSS_FONT_WEIGHT_PROPERTY;
    String SVG_FROM_ATTRIBUTE = "from";
    String SVG_FX_ATTRIBUTE = "fx";
    String SVG_FY_ATTRIBUTE = "fy";
    String SVG_G1_ATTRIBUTE = "g1";
    String SVG_G2_ATTRIBUTE = "g2";
    String SVG_GLYPH_NAME_ATTRIBUTE = "glyph-name";
    String SVG_GLYPH_REF_ATTRIBUTE = "glyphRef";
    String SVG_GRADIENT_TRANSFORM_ATTRIBUTE = "gradientTransform";
    String SVG_GRADIENT_UNITS_ATTRIBUTE = "gradientUnits";
    String SVG_HANGING_ATTRIBUTE = "hanging";
    String SVG_HEIGHT_ATTRIBUTE = "height";
    String SVG_HORIZ_ADV_X_ATTRIBUTE = "horiz-adv-x";
    String SVG_HORIZ_ORIGIN_X_ATTRIBUTE = "horiz-origin-x";
    String SVG_HORIZ_ORIGIN_Y_ATTRIBUTE = "horiz-origin-y";
    String SVG_ID_ATTRIBUTE = XMLConstants.XML_ID_ATTRIBUTE;
    String SVG_IDEOGRAPHIC_ATTRIBUTE = "ideographic";
    String SVG_IMAGE_RENDERING_ATTRIBUTE = CSS_IMAGE_RENDERING_PROPERTY;
    String SVG_IN2_ATTRIBUTE = "in2";
    String SVG_INTERCEPT_ATTRIBUTE = "intercept";
    String SVG_IN_ATTRIBUTE = "in";
    String SVG_K_ATTRIBUTE = "k";
    String SVG_K1_ATTRIBUTE = "k1";
    String SVG_K2_ATTRIBUTE = "k2";
    String SVG_K3_ATTRIBUTE = "k3";
    String SVG_K4_ATTRIBUTE = "k4";
    String SVG_KERNEL_MATRIX_ATTRIBUTE = "kernelMatrix";
    String SVG_KERNEL_UNIT_LENGTH_ATTRIBUTE = "kernelUnitLength";
    String SVG_KERNING_ATTRIBUTE = CSS_KERNING_PROPERTY;
    String SVG_KEY_POINTS_ATTRIBUTE = "keyPoints";
    String SVG_KEY_SPLINES_ATTRIBUTE = "keySplines";
    String SVG_KEY_TIMES_ATTRIBUTE = "keyTimes";
    String SVG_LANG_ATTRIBUTE = "lang";
    String SVG_LENGTH_ADJUST_ATTRIBUTE = "lengthAdjust";
    String SVG_LIGHT_COLOR_ATTRIBUTE = "lightColor";
    String SVG_LIGHTING_COLOR_ATTRIBUTE = "lighting-color";
    String SVG_LIMITING_CONE_ANGLE_ATTRIBUTE = "limitingConeAngle";
    String SVG_LOCAL_ATTRIBUTE = "local";
    String SVG_MARKER_HEIGHT_ATTRIBUTE = "markerHeight";
    String SVG_MARKER_UNITS_ATTRIBUTE = "markerUnits";
    String SVG_MARKER_WIDTH_ATTRIBUTE = "markerWidth";
    String SVG_MASK_ATTRIBUTE = CSS_MASK_PROPERTY;
    String SVG_MASK_CONTENT_UNITS_ATTRIBUTE = "maskContentUnits";
    String SVG_MASK_UNITS_ATTRIBUTE = "maskUnits";
    String SVG_MATHEMATICAL_ATTRIBUTE = "mathematical";
    String SVG_MAX_ATTRIBUTE = "max";
    String SVG_MEDIA_ATTRIBUTE = "media";
    String SVG_METHOD_ATTRIBUTE = "method";
    String SVG_MIN_ATTRIBUTE = "min";
    String SVG_MODE_ATTRIBUTE = "mode";
    String SVG_NAME_ATTRIBUTE = "name";
    String SVG_NUM_OCTAVES_ATTRIBUTE = "numOctaves";
    String SVG_OFFSET_ATTRIBUTE = "offset";
    String SVG_OPACITY_ATTRIBUTE = CSS_OPACITY_PROPERTY;
    String SVG_OPERATOR_ATTRIBUTE = "operator";
    String SVG_ORDER_ATTRIBUTE = "order";
    String SVG_ORDER_X_ATTRIBUTE = "orderX";
    String SVG_ORDER_Y_ATTRIBUTE = "orderY";
    String SVG_ORIENT_ATTRIBUTE = "orient";
    String SVG_ORIENTATION_ATTRIBUTE = "orientation";
    String SVG_ORIGIN_ATTRIBUTE = "origin";
    String SVG_OVERLINE_POSITION_ATTRIBUTE = "overline-position";
    String SVG_OVERLINE_THICKNESS_ATTRIBUTE = "overline-thickness";
    String SVG_PANOSE_1_ATTRIBUTE = "panose-1";
    String SVG_PATH_ATTRIBUTE = "path";
    String SVG_PATH_LENGTH_ATTRIBUTE = "pathLength";
    String SVG_PATTERN_CONTENT_UNITS_ATTRIBUTE = "patternContentUnits";
    String SVG_PATTERN_TRANSFORM_ATTRIBUTE = "patternTransform";
    String SVG_PATTERN_UNITS_ATTRIBUTE = "patternUnits";
    String SVG_POINTS_ATTRIBUTE = "points";
    String SVG_POINTS_AT_X_ATTRIBUTE = "pointsAtX";
    String SVG_POINTS_AT_Y_ATTRIBUTE = "pointsAtY";
    String SVG_POINTS_AT_Z_ATTRIBUTE = "pointsAtZ";
    String SVG_PRESERVE_ALPHA_ATTRIBUTE = "preserveAlpha";
    String SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE = "preserveAspectRatio";
    String SVG_PRIMITIVE_UNITS_ATTRIBUTE = "primitiveUnits";
    String SVG_RADIUS_ATTRIBUTE = "radius";
    String SVG_REF_X_ATTRIBUTE = "refX";
    String SVG_REF_Y_ATTRIBUTE = "refY";
    String SVG_RENDERING_INTENT_ATTRIBUTE = "rendering-intent";
    String SVG_REPEAT_COUNT_ATTRIBUTE = "repeatCount";
    String SVG_REPEAT_DUR_ATTRIBUTE = "repeatDur";
    String SVG_REQUIRED_FEATURES_ATTRIBUTE = "requiredFeatures";
    String SVG_REQUIRED_EXTENSIONS_ATTRIBUTE = "requiredExtensions";
    String SVG_RESULT_ATTRIBUTE = "result";
    String SVG_RESULT_SCALE_ATTRIBUTE = "resultScale";
    String SVG_RESTART_ATTRIBUTE = "restart";
    String SVG_RX_ATTRIBUTE = "rx";
    String SVG_RY_ATTRIBUTE = "ry";
    String SVG_R_ATTRIBUTE = "r";
    String SVG_ROTATE_ATTRIBUTE = "rotate";
    String SVG_SCALE_ATTRIBUTE = "scale";
    String SVG_SEED_ATTRIBUTE = "seed";
    String SVG_SHAPE_RENDERING_ATTRIBUTE = CSS_SHAPE_RENDERING_PROPERTY;
    String SVG_SLOPE_ATTRIBUTE = "slope";
    String SVG_SNAPSHOT_TIME_ATTRIBUTE = "snapshotTime";
    String SVG_SPACE_ATTRIBUTE = "space";
    String SVG_SPACING_ATTRIBUTE = "spacing";
    String SVG_SPECULAR_CONSTANT_ATTRIBUTE = "specularConstant";
    String SVG_SPECULAR_EXPONENT_ATTRIBUTE = "specularExponent";
    String SVG_SPREAD_METHOD_ATTRIBUTE = "spreadMethod";
    String SVG_START_OFFSET_ATTRIBUTE = "startOffset";
    String SVG_STD_DEVIATION_ATTRIBUTE = "stdDeviation";
    String SVG_STEMH_ATTRIBUTE = "stemh";
    String SVG_STEMV_ATTRIBUTE = "stemv";
    String SVG_STITCH_TILES_ATTRIBUTE = "stitchTiles";
    String SVG_STOP_COLOR_ATTRIBUTE = "stop-color";
    String SVG_STOP_OPACITY_ATTRIBUTE = CSS_STOP_OPACITY_PROPERTY;
    String SVG_STRIKETHROUGH_POSITION_ATTRIBUTE = "strikethrough-position";
    String SVG_STRIKETHROUGH_THICKNESS_ATTRIBUTE = "strikethrough-thickness";
    String SVG_STRING_ATTRIBUTE = "string";
    String SVG_STROKE_ATTRIBUTE = CSS_STROKE_PROPERTY;
    String SVG_STROKE_DASHARRAY_ATTRIBUTE = CSS_STROKE_DASHARRAY_PROPERTY;
    String SVG_STROKE_DASHOFFSET_ATTRIBUTE = CSS_STROKE_DASHOFFSET_PROPERTY;
    String SVG_STROKE_LINECAP_ATTRIBUTE = CSS_STROKE_LINECAP_PROPERTY;
    String SVG_STROKE_LINEJOIN_ATTRIBUTE = CSS_STROKE_LINEJOIN_PROPERTY;
    String SVG_STROKE_MITERLIMIT_ATTRIBUTE = CSS_STROKE_MITERLIMIT_PROPERTY;
    String SVG_STROKE_OPACITY_ATTRIBUTE = CSS_STROKE_OPACITY_PROPERTY;
    String SVG_STROKE_WIDTH_ATTRIBUTE = CSS_STROKE_WIDTH_PROPERTY;
    String SVG_STYLE_ATTRIBUTE = "style";
    String SVG_SURFACE_SCALE_ATTRIBUTE = "surfaceScale";
    String SVG_SYSTEM_LANGUAGE_ATTRIBUTE = "systemLanguage";
    String SVG_TABLE_ATTRIBUTE = "table";
    String SVG_TABLE_VALUES_ATTRIBUTE = "tableValues";
    String SVG_TARGET_ATTRIBUTE = "target";
    String SVG_TARGET_X_ATTRIBUTE = "targetX";
    String SVG_TARGET_Y_ATTRIBUTE = "targetY";
    String SVG_TEXT_ANCHOR_ATTRIBUTE = CSS_TEXT_ANCHOR_PROPERTY;
    String SVG_TEXT_LENGTH_ATTRIBUTE = "textLength";
    String SVG_TEXT_RENDERING_ATTRIBUTE = CSS_TEXT_RENDERING_PROPERTY;
    String SVG_TITLE_ATTRIBUTE = "title";
    String SVG_TO_ATTRIBUTE = "to";
    String SVG_TRANSFORM_ATTRIBUTE = "transform";
    String SVG_TYPE_ATTRIBUTE = "type";
    String SVG_U1_ATTRIBUTE = "u1";
    String SVG_U2_ATTRIBUTE = "u2";
    String SVG_UNDERLINE_POSITION_ATTRIBUTE = "underline-position";
    String SVG_UNDERLINE_THICKNESS_ATTRIBUTE = "underline-thickness";
    String SVG_UNICODE_ATTRIBUTE = "unicode";
    String SVG_UNICODE_RANGE_ATTRIBUTE = "unicode-range";
    String SVG_UNITS_PER_EM_ATTRIBUTE = "units-per-em";
    String SVG_V_ALPHABETIC_ATTRIBUTE = "v-alphabetic";
    String SVG_V_HANGING_ATTRIBUTE = "v-hanging";
    String SVG_V_IDEOGRAPHIC_ATTRIBUTE = "v-ideographic";
    String SVG_V_MATHEMATICAL_ATTRIBUTE = "v-mathematical";
    String SVG_VALUES_ATTRIBUTE = "values";
    String SVG_VERSION_ATTRIBUTE = "version";
    String SVG_VERT_ADV_Y_ATTRIBUTE = "vert-adv-y";
    String SVG_VERT_ORIGIN_X_ATTRIBUTE = "vert-origin-x";
    String SVG_VERT_ORIGIN_Y_ATTRIBUTE = "vert-origin-y";
    String SVG_VIEW_BOX_ATTRIBUTE = "viewBox";
    String SVG_VIEW_TARGET_ATTRIBUTE = "viewTarget";
    String SVG_WIDTH_ATTRIBUTE = "width";
    String SVG_WIDTHS_ATTRIBUTE = "widths";
    String SVG_X1_ATTRIBUTE = "x1";
    String SVG_X2_ATTRIBUTE = "x2";
    String SVG_X_ATTRIBUTE = "x";
    String SVG_X_CHANNEL_SELECTOR_ATTRIBUTE = "xChannelSelector";
    String SVG_X_HEIGHT_ATTRIBUTE = "xHeight";
    String SVG_Y1_ATTRIBUTE = "y1";
    String SVG_Y2_ATTRIBUTE = "y2";
    String SVG_Y_ATTRIBUTE = "y";
    String SVG_Y_CHANNEL_SELECTOR_ATTRIBUTE = "yChannelSelector";
    String SVG_Z_ATTRIBUTE = "z";
    String SVG_ZOOM_AND_PAN_ATTRIBUTE = "zoomAndPan";

    /////////////////////////////////////////////////////////////////////////
    // SVG attribute value
    /////////////////////////////////////////////////////////////////////////

    String SVG_100_VALUE = "100";
    String SVG_200_VALUE = "200";
    String SVG_300_VALUE = "300";
    String SVG_400_VALUE = "400";
    String SVG_500_VALUE = "500";
    String SVG_600_VALUE = "600";
    String SVG_700_VALUE = "700";
    String SVG_800_VALUE = "800";
    String SVG_900_VALUE = "900";
    String SVG_ABSOLUTE_COLORIMETRIC_VALUE = "absolute-colorimetric";
    String SVG_ALIGN_VALUE = "align";
    String SVG_ALL_VALUE = "all";
    String SVG_ARITHMETIC_VALUE = "arithmetic";
    String SVG_ATOP_VALUE = "atop";
    String SVG_AUTO_VALUE = "auto";
    String SVG_A_VALUE = "A";
    String SVG_BACKGROUND_ALPHA_VALUE = "BackgroundAlpha";
    String SVG_BACKGROUND_IMAGE_VALUE = "BackgroundImage";
    String SVG_BEVEL_VALUE = "bevel";
    String SVG_BOLDER_VALUE = "bolder";
    String SVG_BOLD_VALUE = "bold";
    String SVG_BUTT_VALUE = "butt";
    String SVG_B_VALUE = "B";
    String SVG_COMPOSITE_VALUE = "composite";
    String SVG_CRISP_EDGES_VALUE = "crispEdges";
    String SVG_CROSSHAIR_VALUE = "crosshair";
    String SVG_DARKEN_VALUE = "darken";
    String SVG_DEFAULT_VALUE = "default";
    String SVG_DIGIT_ONE_VALUE = "1";
    String SVG_DILATE_VALUE = "dilate";
    String SVG_DISABLE_VALUE = "disable";
    String SVG_DISCRETE_VALUE = "discrete";
    String SVG_DUPLICATE_VALUE = "duplicate";
    String SVG_END_VALUE = "end";
    String SVG_ERODE_VALUE = "erode";
    String SVG_EVEN_ODD_VALUE = "evenodd";
    String SVG_EXACT_VALUE = "exact";
    String SVG_E_RESIZE_VALUE = "e-resize";
    String SVG_FALSE_VALUE = "false";
    String SVG_FILL_PAINT_VALUE = "FillPaint";
    String SVG_FLOOD_VALUE = "flood";
    String SVG_FRACTAL_NOISE_VALUE = "fractalNoise";
    String SVG_GAMMA_VALUE = "gamma";
    String SVG_GEOMETRIC_PRECISION_VALUE = "geometricPrecision";
    String SVG_G_VALUE = "G";
    String SVG_HELP_VALUE = "help";
    String SVG_HUE_ROTATE_VALUE = "hueRotate";
    String SVG_HUNDRED_PERCENT_VALUE = "100%";
    String SVG_H_VALUE = "h";
    String SVG_IDENTITY_VALUE = "identity";
    String SVG_INITIAL_VALUE = "initial";
    String SVG_IN_VALUE = "in";
    String SVG_ISOLATED_VALUE = "isolated";
    String SVG_ITALIC_VALUE = "italic";
    String SVG_LIGHTEN_VALUE = "lighten";
    String SVG_LIGHTER_VALUE = "lighter";
    String SVG_LINEAR_RGB_VALUE = "linearRGB";
    String SVG_LINEAR_VALUE = "linear";
    String SVG_LUMINANCE_TO_ALPHA_VALUE = "luminanceToAlpha";
    String SVG_MAGNIFY_VALUE = "magnify";
    String SVG_MATRIX_VALUE = "matrix";
    String SVG_MEDIAL_VALUE = "medial";
    String SVG_MEET_VALUE = "meet";
    String SVG_MIDDLE_VALUE = "middle";
    String SVG_MITER_VALUE = "miter";
    String SVG_MOVE_VALUE = "move";
    String SVG_MULTIPLY_VALUE = "multiply";
    String SVG_NEW_VALUE = "new";
    String SVG_NE_RESIZE_VALUE = "ne-resize";
    String SVG_NINETY_VALUE = "90";
    String SVG_NONE_VALUE = "none";
    String SVG_NON_ZERO_VALUE = "nonzero";
    String SVG_NORMAL_VALUE = "normal";
    String SVG_NO_STITCH_VALUE = "noStitch";
    String SVG_NW_RESIZE_VALUE = "nw-resize";
    String SVG_N_RESIZE_VALUE = "n-resize";
    String SVG_OBJECT_BOUNDING_BOX_VALUE = "objectBoundingBox";
    String SVG_OBLIQUE_VALUE = "oblique";
    String SVG_ONE_VALUE = "1";
    String SVG_OPAQUE_VALUE = "1";
    String SVG_OPTIMIZE_LEGIBILITY_VALUE = "optimizeLegibility";
    String SVG_OPTIMIZE_QUALITY_VALUE = "optimizeQuality";
    String SVG_OPTIMIZE_SPEED_VALUE = "optimizeSpeed";
    String SVG_OUT_VALUE = "out";
    String SVG_OVER_VALUE = "over";
    String SVG_PACED_VALUE = "paced";
    String SVG_PAD_VALUE = "pad";
    String SVG_PERCEPTUAL_VALUE = "perceptual";
    String SVG_POINTER_VALUE = "pointer";
    String SVG_PRESERVE_VALUE = "preserve";
    String SVG_REFLECT_VALUE = "reflect";
    String SVG_RELATIVE_COLORIMETRIC_VALUE = "relative-colorimetric";
    String SVG_REPEAT_VALUE = "repeat";
    String SVG_ROUND_VALUE = "round";
    String SVG_R_VALUE = "R";
    String SVG_SATURATE_VALUE = "saturate";
    String SVG_SATURATION_VALUE = "saturation";
    String SVG_SCREEN_VALUE = "screen";
    String SVG_SE_RESIZE_VALUE = "se-resize";
    String SVG_SLICE_VALUE = "slice";
    String SVG_SOURCE_ALPHA_VALUE = "SourceAlpha";
    String SVG_SOURCE_GRAPHIC_VALUE = "SourceGraphic";
    String SVG_SPACING_AND_GLYPHS_VALUE = "spacingAndGlyphs";
    String SVG_SPACING_VALUE = "spacing";
    String SVG_SQUARE_VALUE = "square";
    String SVG_SRGB_VALUE = "sRGB";
    String SVG_START_VALUE = "start";
    String SVG_STITCH_VALUE = "stitch";
    String SVG_STRETCH_VALUE = "stretch";
    String SVG_STROKE_PAINT_VALUE = "StrokePaint";
    String SVG_STROKE_WIDTH_VALUE = "strokeWidth";
    String SVG_SW_RESIZE_VALUE = "sw-resize";
    String SVG_S_RESIZE_VALUE = "s-resize";
    String SVG_TABLE_VALUE = "table";
    String SVG_TERMINAL_VALUE = "terminal";
    String SVG_TEXT_VALUE = "text";
    String SVG_TRANSLATE_VALUE = "translate";
    String SVG_TRUE_VALUE = "true";
    String SVG_TURBULENCE_VALUE = "turbulence";
    String SVG_USER_SPACE_ON_USE_VALUE = "userSpaceOnUse";
    String SVG_V_VALUE = "v";
    String SVG_WAIT_VALUE = "wait";
    String SVG_WRAP_VALUE = "wrap";
    String SVG_W_RESIZE_VALUE = "w-resize";
    String SVG_XMAXYMAX_VALUE = "xMaxYMax";
    String SVG_XMAXYMID_VALUE = "xMaxYMid";
    String SVG_XMAXYMIN_VALUE = "xMaxYMin";
    String SVG_XMIDYMAX_VALUE = "xMidYMax";
    String SVG_XMIDYMID_VALUE = "xMidYMid";
    String SVG_XMIDYMIN_VALUE = "xMidYMin";
    String SVG_XMINYMAX_VALUE = "xMinYMax";
    String SVG_XMINYMID_VALUE = "xMinYMid";
    String SVG_XMINYMIN_VALUE = "xMinYMin";
    String SVG_XOR_VALUE = "xor";
    String SVG_ZERO_PERCENT_VALUE = "0%";
    String SVG_ZERO_VALUE = "0";


    ///////////////////////////////////////////////////////////////////
    // default values for attributes
    ///////////////////////////////////////////////////////////////////

    String SVG_CIRCLE_CX_DEFAULT_VALUE = "0";
    String SVG_CIRCLE_CY_DEFAULT_VALUE = "0";
    String SVG_CLIP_PATH_CLIP_PATH_UNITS_DEFAULT_VALUE = SVG_USER_SPACE_ON_USE_VALUE;
    String SVG_COMPONENT_TRANSFER_FUNCTION_AMPLITUDE_DEFAULT_VALUE = "1";
    String SVG_COMPONENT_TRANSFER_FUNCTION_EXPONENT_DEFAULT_VALUE = "1";
    String SVG_COMPONENT_TRANSFER_FUNCTION_INTERCEPT_DEFAULT_VALUE = "0";
    String SVG_COMPONENT_TRANSFER_FUNCTION_OFFSET_DEFAULT_VALUE = "0";
    String SVG_COMPONENT_TRANSFER_FUNCTION_SLOPE_DEFAULT_VALUE = "1";
    String SVG_COMPONENT_TRANSFER_FUNCTION_TABLE_VALUES_DEFAULT_VALUE = "";
    String SVG_CURSOR_X_DEFAULT_VALUE = "0";
    String SVG_CURSOR_Y_DEFAULT_VALUE = "0";
    String SVG_ELLIPSE_CX_DEFAULT_VALUE = "0";
    String SVG_ELLIPSE_CY_DEFAULT_VALUE = "0";
    String SVG_FE_COMPOSITE_K1_DEFAULT_VALUE = "0";
    String SVG_FE_COMPOSITE_K2_DEFAULT_VALUE = "0";
    String SVG_FE_COMPOSITE_K3_DEFAULT_VALUE = "0";
    String SVG_FE_COMPOSITE_K4_DEFAULT_VALUE = "0";
    String SVG_FE_COMPOSITE_OPERATOR_DEFAULT_VALUE = SVG_OVER_VALUE;
    String SVG_FE_CONVOLVE_MATRIX_EDGE_MODE_DEFAULT_VALUE = SVG_DUPLICATE_VALUE;
    String SVG_FE_DIFFUSE_LIGHTING_DIFFUSE_CONSTANT_DEFAULT_VALUE = "1";
    String SVG_FE_DIFFUSE_LIGHTING_SURFACE_SCALE_DEFAULT_VALUE = "1";
    String SVG_FE_DISPLACEMENT_MAP_SCALE_DEFAULT_VALUE = "0";
    String SVG_FE_DISTANT_LIGHT_AZIMUTH_DEFAULT_VALUE = "0";
    String SVG_FE_DISTANT_LIGHT_ELEVATION_DEFAULT_VALUE = "0";
    String SVG_FE_POINT_LIGHT_X_DEFAULT_VALUE = "0";
    String SVG_FE_POINT_LIGHT_Y_DEFAULT_VALUE = "0";
    String SVG_FE_POINT_LIGHT_Z_DEFAULT_VALUE = "0";
    String SVG_FE_SPECULAR_LIGHTING_SPECULAR_CONSTANT_DEFAULT_VALUE = "1";
    String SVG_FE_SPECULAR_LIGHTING_SPECULAR_EXPONENT_DEFAULT_VALUE = "1";
    String SVG_FE_SPECULAR_LIGHTING_SURFACE_SCALE_DEFAULT_VALUE = "1";
    String SVG_FE_SPOT_LIGHT_LIMITING_CONE_ANGLE_DEFAULT_VALUE = "90";
    String SVG_FE_SPOT_LIGHT_POINTS_AT_X_DEFAULT_VALUE = "0";
    String SVG_FE_SPOT_LIGHT_POINTS_AT_Y_DEFAULT_VALUE = "0";
    String SVG_FE_SPOT_LIGHT_POINTS_AT_Z_DEFAULT_VALUE = "0";
    String SVG_FE_SPOT_LIGHT_SPECULAR_EXPONENT_DEFAULT_VALUE = "1";
    String SVG_FE_SPOT_LIGHT_X_DEFAULT_VALUE = "0";
    String SVG_FE_SPOT_LIGHT_Y_DEFAULT_VALUE = "0";
    String SVG_FE_SPOT_LIGHT_Z_DEFAULT_VALUE = "0";
    String SVG_FE_TURBULENCE_NUM_OCTAVES_DEFAULT_VALUE = "1";
    String SVG_FE_TURBULENCE_SEED_DEFAULT_VALUE = "0";
    String SVG_FILTER_FILTER_UNITS_DEFAULT_VALUE = SVG_USER_SPACE_ON_USE_VALUE;
    String SVG_FILTER_HEIGHT_DEFAULT_VALUE = "120%";
    String SVG_FILTER_PRIMITIVE_X_DEFAULT_VALUE = "0%";
    String SVG_FILTER_PRIMITIVE_Y_DEFAULT_VALUE = "0%";
    String SVG_FILTER_PRIMITIVE_WIDTH_DEFAULT_VALUE = "100%";
    String SVG_FILTER_PRIMITIVE_HEIGHT_DEFAULT_VALUE = "100%";
    String SVG_FILTER_PRIMITIVE_UNITS_DEFAULT_VALUE = SVG_USER_SPACE_ON_USE_VALUE;
    String SVG_FILTER_WIDTH_DEFAULT_VALUE = "120%";
    String SVG_FILTER_X_DEFAULT_VALUE = "-10%";
    String SVG_FILTER_Y_DEFAULT_VALUE = "-10%";
    String SVG_FONT_FACE_FONT_STRETCH_DEFAULT_VALUE = SVG_NORMAL_VALUE;
    String SVG_FONT_FACE_FONT_STYLE_DEFAULT_VALUE = SVG_ALL_VALUE;
    String SVG_FONT_FACE_FONT_VARIANT_DEFAULT_VALUE = SVG_NORMAL_VALUE;
    String SVG_FONT_FACE_FONT_WEIGHT_DEFAULT_VALUE = SVG_ALL_VALUE;
    String SVG_FONT_FACE_PANOSE_1_DEFAULT_VALUE = "0 0 0 0 0 0 0 0 0 0";
    String SVG_FONT_FACE_SLOPE_DEFAULT_VALUE = "0";
    String SVG_FONT_FACE_UNITS_PER_EM_DEFAULT_VALUE = "1000";
    String SVG_FOREIGN_OBJECT_X_DEFAULT_VALUE = "0";
    String SVG_FOREIGN_OBJECT_Y_DEFAULT_VALUE = "0";
    String SVG_HORIZ_ORIGIN_X_DEFAULT_VALUE = "0";
    String SVG_HORIZ_ORIGIN_Y_DEFAULT_VALUE = "0";
    String SVG_KERN_K_DEFAULT_VALUE = "0";
    String SVG_IMAGE_X_DEFAULT_VALUE = "0";
    String SVG_IMAGE_Y_DEFAULT_VALUE = "0";
    String SVG_LINE_X1_DEFAULT_VALUE = "0";
    String SVG_LINE_X2_DEFAULT_VALUE = "0";
    String SVG_LINE_Y1_DEFAULT_VALUE = "0";
    String SVG_LINE_Y2_DEFAULT_VALUE = "0";
    String SVG_LINEAR_GRADIENT_X1_DEFAULT_VALUE = "0%";
    String SVG_LINEAR_GRADIENT_X2_DEFAULT_VALUE = "100%";
    String SVG_LINEAR_GRADIENT_Y1_DEFAULT_VALUE = "0%";
    String SVG_LINEAR_GRADIENT_Y2_DEFAULT_VALUE = "0%";
    String SVG_MARKER_MARKER_HEIGHT_DEFAULT_VALUE = "3";
    String SVG_MARKER_MARKER_UNITS_DEFAULT_VALUE = SVG_STROKE_WIDTH_VALUE;
    String SVG_MARKER_MARKER_WIDTH_DEFAULT_VALUE = "3";
    String SVG_MARKER_ORIENT_DEFAULT_VALUE = "0";
    String SVG_MARKER_REF_X_DEFAULT_VALUE = "0";
    String SVG_MARKER_REF_Y_DEFAULT_VALUE = "0";
    String SVG_MASK_HEIGHT_DEFAULT_VALUE = "120%";
    String SVG_MASK_MASK_UNITS_DEFAULT_VALUE = SVG_USER_SPACE_ON_USE_VALUE;
    String SVG_MASK_WIDTH_DEFAULT_VALUE = "120%";
    String SVG_MASK_X_DEFAULT_VALUE = "-10%";
    String SVG_MASK_Y_DEFAULT_VALUE = "-10%";
    String SVG_PATTERN_X_DEFAULT_VALUE = "0";
    String SVG_PATTERN_Y_DEFAULT_VALUE = "0";
    String SVG_PATTERN_WIDTH_DEFAULT_VALUE = "0";
    String SVG_PATTERN_HEIGHT_DEFAULT_VALUE = "0";
    String SVG_RADIAL_GRADIENT_CX_DEFAULT_VALUE = "50%";
    String SVG_RADIAL_GRADIENT_CY_DEFAULT_VALUE = "50%";
    String SVG_RADIAL_GRADIENT_R_DEFAULT_VALUE = "50%";
    String SVG_RECT_X_DEFAULT_VALUE = "0";
    String SVG_RECT_Y_DEFAULT_VALUE = "0";
    String SVG_SCRIPT_TYPE_ECMASCRIPT = "text/ecmascript";
    String SVG_SCRIPT_TYPE_APPLICATION_ECMASCRIPT = "application/ecmascript";
    String SVG_SCRIPT_TYPE_JAVASCRIPT = "text/javascript";
    String SVG_SCRIPT_TYPE_APPLICATION_JAVASCRIPT = "application/javascript";
    String SVG_SCRIPT_TYPE_DEFAULT_VALUE = SVG_SCRIPT_TYPE_ECMASCRIPT;
    String SVG_SCRIPT_TYPE_JAVA = "application/java-archive";
    String SVG_SVG_X_DEFAULT_VALUE = "0";
    String SVG_SVG_Y_DEFAULT_VALUE = "0";
    String SVG_SVG_HEIGHT_DEFAULT_VALUE = "100%";
    String SVG_SVG_WIDTH_DEFAULT_VALUE = "100%";
    String SVG_TEXT_PATH_START_OFFSET_DEFAULT_VALUE = "0";
    String SVG_USE_X_DEFAULT_VALUE = "0";
    String SVG_USE_Y_DEFAULT_VALUE = "0";
    String SVG_USE_WIDTH_DEFAULT_VALUE = "100%";
    String SVG_USE_HEIGHT_DEFAULT_VALUE = "100%";

    ///////////////////////////////////////////////////////////////////
    // various constants in SVG attributes
    ///////////////////////////////////////////////////////////////////

    String TRANSFORM_TRANSLATE = "translate";
    String TRANSFORM_ROTATE    = "rotate";
    String TRANSFORM_SCALE     = "scale";
    String TRANSFORM_SKEWX     = "skewX";
    String TRANSFORM_SKEWY     = "skewY";
    String TRANSFORM_MATRIX    = "matrix";

    String PATH_ARC                = "A";
    String PATH_CLOSE              = "Z";
    String PATH_CUBIC_TO           = "C";
    String PATH_MOVE               = "M";
    String PATH_LINE_TO            = "L";
    String PATH_VERTICAL_LINE_TO   = "V";
    String PATH_HORIZONTAL_LINE_TO = "H";
    String PATH_QUAD_TO            = "Q";
    String PATH_SMOOTH_QUAD_TO     = "T";

    ///////////////////////////////////////////////////////////////////
    // event constants
    ///////////////////////////////////////////////////////////////////
    
    String SVG_EVENT_CLICK     = "click";
    String SVG_EVENT_KEYDOWN   = "keydown";
    String SVG_EVENT_KEYPRESS  = "keypress";
    String SVG_EVENT_KEYUP     = "keyup";
    String SVG_EVENT_MOUSEDOWN = "mousedown";
    String SVG_EVENT_MOUSEMOVE = "mousemove";
    String SVG_EVENT_MOUSEOUT  = "mouseout";
    String SVG_EVENT_MOUSEOVER = "mouseover";
    String SVG_EVENT_MOUSEUP   = "mouseup";
}
