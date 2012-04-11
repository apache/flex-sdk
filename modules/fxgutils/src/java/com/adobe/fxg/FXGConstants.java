/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package com.adobe.fxg;

/**
 * Constants for the FXG document format.
 * 
 * Currently covers FXG 1.0 and FXG 2.0 for the "http://ns.adobe.com/fxg/2008" namespace.
 * 
 * @author Peter Farland
 * @author Sujata Das
 */
public final class FXGConstants
{
    private FXGConstants()
    {
    }
    
    // Namespaces
    public static final String FXG_NAMESPACE = "http://ns.adobe.com/fxg/2008";
    
    //Profiles
    public static final String FXG_PROFILE_DESKTOP = "desktop";
    public static final String FXG_PROFILE_MOBILE = "mobile";

    // Top Level Tag
    public static final String FXG_GRAPHIC_ELEMENT = "Graphic";

    // Special Tags
    public static final String FXG_DEFINITION_ELEMENT = "Definition";
    public static final String FXG_LIBRARY_ELEMENT = "Library";
    public static final String FXG_PRIVATE_ELEMENT = "Private";

    // Graphical Tags
    public static final String FXG_A_ELEMENT = "a";
    public static final String FXG_BEVELFILTER_ELEMENT = "BevelFilter";
    public static final String FXG_BITMAPFILL_ELEMENT = "BitmapFill";
    public static final String FXG_BITMAPGRAPHIC_ELEMENT = "BitmapGraphic";
    public static final String FXG_BITMAPIMAGE_ELEMENT = "BitmapImage";
    public static final String FXG_BLURFILTER_ELEMENT = "BlurFilter";
    public static final String FXG_BR_ELEMENT = "br";
    public static final String FXG_COLORMATRIXFILTER_ELEMENT = "ColorMatrixFilter";
    public static final String FXG_COLORTRANSFORM_ELEMENT = "ColorTransform";
    public static final String FXG_DIV_ELEMENT = "div";
    public static final String FXG_DROPSHADOWFILTER_ELEMENT = "DropShadowFilter";
    public static final String FXG_ELLIPSE_ELEMENT = "Ellipse";
    public static final String FXG_GLOWFILTER_ELEMENT = "GlowFilter";
    public static final String FXG_GRADIENTENTRY_ELEMENT = "GradientEntry";
    public static final String FXG_GRADIENTBEVELFILTER_ELEMENT = "GradientBevelFilter";
    public static final String FXG_GRADIENTGLOWFILTER_ELEMENT = "GradientGlowFilter";
    public static final String FXG_GROUP_ELEMENT = "Group";
    public static final String FXG_IMG_ELEMENT = "img";    
    public static final String FXG_LINE_ELEMENT = "Line";
    public static final String FXG_LINEARGRADIENT_ELEMENT = "LinearGradient";
    public static final String FXG_LINEARGRADIENTSTROKE_ELEMENT = "LinearGradientStroke";
    public static final String FXG_MASK_ELEMENT = "mask";
    public static final String FXG_MATRIX_ELEMENT = "Matrix";
    public static final String FXG_P_ELEMENT = "p";
    public static final String FXG_PATH_ELEMENT = "Path";
    public static final String FXG_PLACEOBJECT_ELEMENT = "PlaceObject";
    public static final String FXG_RADIALGRADIENT_ELEMENT = "RadialGradient";
    public static final String FXG_RADIALGRADIENTSTROKE_ELEMENT = "RadialGradientStroke";
    public static final String FXG_RECT_ELEMENT = "Rect";
    public static final String FXG_RICHTEXT_ELEMENT = "RichText";    
    public static final String FXG_SOLIDCOLOR_ELEMENT = "SolidColor";
    public static final String FXG_SOLIDCOLORSTROKE_ELEMENT = "SolidColorStroke";
    public static final String FXG_SPAN_ELEMENT = "span";
    public static final String FXG_TAB_ELEMENT = "tab";    
    public static final String FXG_TCY_ELEMENT = "tcy";     
    public static final String FXG_TEXTGRAPHIC_ELEMENT = "TextGraphic";
    public static final String FXG_TRANSFORM_ELEMENT = "Transform";

    // Graphical Property Tags
    public static final String FXG_COLORTRANSFORM_PROPERTY_ELEMENT = "colorTransform";
    public static final String FXG_CONTENT_PROPERTY_ELEMENT = "content";
    public static final String FXG_FILL_PROPERTY_ELEMENT = "fill";
    public static final String FXG_FILTERS_PROPERTY_ELEMENT = "filters";
    public static final String FXG_FORMAT_PROPERTY_ELEMENT = "format";  
    public static final String FXG_LINKACTIVEFORMAT_PROPERTY_ELEMENT = "linkActiveFormat";
    public static final String FXG_LINKHOVERFORMAT_PROPERTY_ELEMENT = "linkHoverFormat";    
    public static final String FXG_LINKNORMALFORMAT_PROPERTY_ELEMENT = "linkNormalFormat";    
    public static final String FXG_MASK_PROPERTY_ELEMENT = "mask";
    public static final String FXG_MATRIX_PROPERTY_ELEMENT = "matrix";
    public static final String FXG_STROKE_PROPERTY_ELEMENT = "stroke";
    public static final String FXG_TEXTLAYOUTFORMAT_ELEMENT = "TextLayoutFormat";
    public static final String FXG_TRANSFORM_PROPERTY_ELEMENT = "transform";

    // Attributes
    public static final String FXG_A_ATTRIBUTE = "a";
    public static final String FXG_ALIGNMENTBASELINE_ATTRIBUTE = "alignmentBaseline";    
    public static final String FXG_ALPHA_ATTRIBUTE = "alpha";
    public static final String FXG_ALPHAMULTIPLIER_ATTRIBUTE = "alphaMultiplier";
    public static final String FXG_ALPHAOFFSET_ATTRIBUTE = "alphaOffset";
    public static final String FXG_ANGLE_ATTRIBUTE = "angle";
    public static final String FXG_B_ATTRIBUTE = "b";
    public static final String FXG_BACKGROUNDALPHA_ATTRIBUTE = "backgroundAlpha";  
    public static final String FXG_BACKGROUNDCOLOR_ATTRIBUTE = "backgroundColor"; 
    public static final String FXG_BASELINESHIFT_ATTRIBUTE = "baselineShift"; 
    public static final String FXG_BLENDMODE_ATTRIBUTE = "blendMode";
    public static final String FXG_BLOCKPROGRESSION_ATTRIBUTE = "blockProgression";
    public static final String FXG_BLUEMULTIPLIER_ATTRIBUTE = "blueMultiplier";
    public static final String FXG_BLUEOFFSET_ATTRIBUTE = "blueOffset";
    public static final String FXG_BLURX_ATTRIBUTE = "blurX";
    public static final String FXG_BLURY_ATTRIBUTE = "blurY";
    public static final String FXG_BOTTOMLEFTRADIUSX_ATTRIBUTE = "bottomLeftRadiusX";
    public static final String FXG_BOTTOMLEFTRADIUSY_ATTRIBUTE = "bottomLeftRadiusY";
    public static final String FXG_BOTTOMRIGHTRADIUSX_ATTRIBUTE = "bottomRightRadiusX";
    public static final String FXG_BOTTOMRIGHTRADIUSY_ATTRIBUTE = "bottomRightRadiusY";
    public static final String FXG_BREAKOPPORTUNITY_ATTRIBUTE = "breakOpportunity"; 
    public static final String FXG_C_ATTRIBUTE = "c";
    public static final String FXG_CAPS_ATTRIBUTE = "caps";
    public static final String FXG_COLOR_ATTRIBUTE = "color";
    public static final String FXG_COLUMNCOUNT_ATTRIBUTE = "columnCount";
    public static final String FXG_COLUMNGAP_ATTRIBUTE = "columnGap";
    public static final String FXG_COLUMNWIDTH_ATTRIBUTE = "columnWidth";   
    public static final String FXG_D_ATTRIBUTE = "d";
    public static final String FXG_DATA_ATTRIBUTE = "data";
    public static final String FXG_DIGITCASE_ATTRIBUTE = "digitCase"; 
    public static final String FXG_DIGITWIDTH_ATTRIBUTE = "digitWidth"; 
    public static final String FXG_DIRECTION_ATTRIBUTE = "direction";
    public static final String FXG_DISTANCE_ATTRIBUTE = "distance";
    public static final String FXG_DOMINANTBASELINE_ATTRIBUTE = "dominantBaseline";
    public static final String FXG_FILLMODE_ATTRIBUTE = "fillMode";
    public static final String FXG_FIRSTBASELINEOFFSET_ATTRIBUTE = "firstBaselineOffset";
    public static final String FXG_FOCALPOINTRATIO_ATTRIBUTE = "focalPointRatio";
    public static final String FXG_FONTFAMILY_ATTRIBUTE = "fontFamily";
    public static final String FXG_FONTSIZE_ATTRIBUTE = "fontSize";
    public static final String FXG_FONTSTYLE_ATTRIBUTE = "fontStyle";
    public static final String FXG_FONTWEIGHT_ATTRIBUTE = "fontWeight";
    public static final String FXG_FORMAT_ATTRIBUTE = "format";    
    public static final String FXG_GREENMULTIPLIER_ATTRIBUTE = "greenMultiplier";
    public static final String FXG_GREENOFFSET_ATTRIBUTE = "greenOffset";
    public static final String FXG_HEIGHT_ATTRIBUTE = "height";
    public static final String FXG_HIDEOBJECT_ATTRIBUTE = "hideObject";
    public static final String FXG_HIGHLIGHTALPHA_ATTRIBUTE = "highlightAlpha";    
    public static final String FXG_HIGHLIGHTCOLOR_ATTRIBUTE = "highlightColor";
    public static final String FXG_HREF_ATTRIBUTE = "href";
    public static final String FXG_ID_ATTRIBUTE = "id";    
    public static final String FXG_INNER_ATTRIBUTE = "inner";
    public static final String FXG_INTERPOLATIONMETHOD_ATTRIBUTE = "interpolationMethod";
    public static final String FXG_JOINTS_ATTRIBUTE = "joints";
    public static final String FXG_JUSTIFICATIONRULE_ATTRIBUTE = "justificationRule";
    public static final String FXG_JUSTIFICATIONSTYLE_ATTRIBUTE = "justificationStyle";
    public static final String FXG_KERNING_ATTRIBUTE = "kerning";
    public static final String FXG_KNOCKOUT_ATTRIBUTE = "knockout";
    public static final String FXG_LEADINGMODEL_ATTRIBUTE = "leadingModel";
    public static final String FXG_LIGATURELEVEL_ATTRIBUTE = "ligatureLevel";
    public static final String FXG_LINEBREAK_ATTRIBUTE = "lineBreak";
    public static final String FXG_LINEHEIGHT_ATTRIBUTE = "lineHeight";
    public static final String FXG_LINETHROUGH_ATTRIBUTE = "lineThrough"; 
    public static final String FXG_LOCALE_ATTRIBUTE = "locale"; 
    public static final String FXG_LUMINOSITYCLIP_ATTRIBUTE = "luminosityClip";
    public static final String FXG_LUMINOSITYINVERT_ATTRIBUTE = "luminosityInvert";
    public static final String FXG_MATRIX_ATTRIBUTE = "matrix";
    public static final String FXG_MARGINBOTTOM_ATTRIBUTE = "marginBottom";
    public static final String FXG_MARGINLEFT_ATTRIBUTE = "marginLeft";
    public static final String FXG_MARGINRIGHT_ATTRIBUTE = "marginRight";
    public static final String FXG_MARGINTOP_ATTRIBUTE = "marginTop";
    public static final String FXG_MASKTYPE_ATTRIBUTE = "maskType";
    public static final String FXG_MITERLIMIT_ATTRIBUTE = "miterLimit";
    public static final String FXG_NAME_ATTRIBUTE = "name";
    public static final String FXG_PADDINGBOTTOM_ATTRIBUTE = "paddingBottom";
    public static final String FXG_PADDINGLEFT_ATTRIBUTE = "paddingLeft";
    public static final String FXG_PADDINGRIGHT_ATTRIBUTE = "paddingRight";
    public static final String FXG_PADDINGTOP_ATTRIBUTE = "paddingTop";
    public static final String FXG_PARAGRAPHSTARTINDENT_ATTRIBUTE = "paragraphStartIndent";
    public static final String FXG_PARAGRAPHENDINDENT_ATTRIBUTE = "paragraphEndIndent";
    public static final String FXG_PARAGRAPHSPACEBEFORE_ATTRIBUTE = "paragraphSpaceBefore";
    public static final String FXG_PARAGRAPHSPACEAFTER_ATTRIBUTE = "paragraphSpaceAfter";    
    public static final String FXG_PIXELHINTING_ATTRIBUTE = "pixelHinting";
    public static final String FXG_QUALITY_ATTRIBUTE = "quality";
    public static final String FXG_RADIUSX_ATTRIBUTE = "radiusX";
    public static final String FXG_RADIUSY_ATTRIBUTE = "radiusY";
    public static final String FXG_RATIO_ATTRIBUTE = "ratio";
    public static final String FXG_REDMULTIPLIER_ATTRIBUTE = "redMultiplier";
    public static final String FXG_REDOFFSET_ATTRIBUTE = "redOffset";
    public static final String FXG_REPEAT_ATTRIBUTE = "repeat";
    public static final String FXG_ROTATION_ATTRIBUTE = "rotation";
    public static final String FXG_SCALEGRIDBOTTOM_ATTRIBUTE = "scaleGridBottom";
    public static final String FXG_SCALEGRIDLEFT_ATTRIBUTE = "scaleGridLeft";
    public static final String FXG_SCALEGRIDRIGHT_ATTRIBUTE = "scaleGridRight";
    public static final String FXG_SCALEGRIDTOP_ATTRIBUTE = "scaleGridTop";
    public static final String FXG_SCALEMODE_ATTRIBUTE = "scaleMode";
    public static final String FXG_SCALEX_ATTRIBUTE = "scaleX";
    public static final String FXG_SCALEY_ATTRIBUTE = "scaleY";
    public static final String FXG_SHADOWALPHA_ATTRIBUTE = "shadowAlpha";
    public static final String FXG_SHADOWCOLOR_ATTRIBUTE = "shadowColor";
    public static final String FXG_SOURCE_ATTRIBUTE = "source";
    public static final String FXG_SPREADMETHOD_ATTRIBUTE = "spreadMethod";
    public static final String FXG_STRENGTH_ATTRIBUTE = "strength";
    public static final String FXG_TABSTOPS_ATTRIBUTE = "tabStops";  
    public static final String FXG_TARGET_ATTRIBUTE = "target";
    public static final String FXG_TEXTALIGN_ATTRIBUTE = "textAlign";
    public static final String FXG_TEXTALIGNLAST_ATTRIBUTE = "textAlignLast";
    public static final String FXG_TEXTALPHA_ATTRIBUTE = "textAlpha";
    public static final String FXG_TEXTDECORATION_ATTRIBUTE = "textDecoration";
    public static final String FXG_TEXTINDENT_ATTRIBUTE = "textIndent";
    public static final String FXG_TEXTJUSTIFY_ATTRIBUTE = "textJustify";
    public static final String FXG_TEXTROTATION_ATTRIBUTE = "textRotation";
    public static final String FXG_TOPLEFTRADIUSX_ATTRIBUTE = "topLeftRadiusX";
    public static final String FXG_TOPLEFTRADIUSY_ATTRIBUTE = "topLeftRadiusY";
    public static final String FXG_TOPRIGHTRADIUSX_ATTRIBUTE = "topRightRadiusX";
    public static final String FXG_TOPRIGHTRADIUSY_ATTRIBUTE = "topRightRadiusY";
    public static final String FXG_TRACKING_ATTRIBUTE = "tracking";
    public static final String FXG_TRACKINGLEFT_ATTRIBUTE = "trackingLeft";    
    public static final String FXG_TRACKINGRIGHT_ATTRIBUTE = "trackingRight"; 
    public static final String FXG_TX_ATTRIBUTE = "tx";
    public static final String FXG_TY_ATTRIBUTE = "ty";
    public static final String FXG_TYPE_ATTRIBUTE = "type";
    public static final String FXG_TYPOGRAPHICCASE_ATTRIBUTE = "typographicCase";
    public static final String FXG_VERTICALALIGN_ATTRIBUTE = "verticalAlign";
    public static final String FXG_VERSION_ATTRIBUTE = "version";
    public static final String FXG_VIEWHEIGHT_ATTRIBUTE = "viewHeight";
    public static final String FXG_VIEWWIDTH_ATTRIBUTE = "viewWidth";
    public static final String FXG_VISIBLE_ATTRIBUTE = "visible";
    public static final String FXG_WEIGHT_ATTRIBUTE = "weight";
    public static final String FXG_WHITESPACECOLLAPSE_ATTRIBUTE = "whiteSpaceCollapse";
    public static final String FXG_WIDTH_ATTRIBUTE = "width";
    public static final String FXG_WINDING_ATTRIBUTE = "winding";
    public static final String FXG_X_ATTRIBUTE = "x";
    public static final String FXG_XFROM_ATTRIBUTE = "xFrom";
    public static final String FXG_XTO_ATTRIBUTE = "xTo";
    public static final String FXG_Y_ATTRIBUTE = "y";
    public static final String FXG_YFROM_ATTRIBUTE = "yFrom";
    public static final String FXG_YTO_ATTRIBUTE = "yTo";

    // FXG Values
    public static final String FXG_ALIGNMENTBASELINE_USEDOMINANTBASELINE_VALUE = "useDominantBaseline";    
    public static final String FXG_ALIGNMENTBASELINE_ROMAN_VALUE = "roman";
    public static final String FXG_ALIGNMENTBASELINE_ASCENT_VALUE = "ascent";    
    public static final String FXG_ALIGNMENTBASELINE_DESCENT_VALUE = "descent";      
    public static final String FXG_ALIGNMENTBASELINE_IDEOGRAPHICTOP_VALUE = "ideographicTop"; 
    public static final String FXG_ALIGNMENTBASELINE_IDEOGRAPHICCENTER_VALUE = "ideographicCenter"; 
    public static final String FXG_ALIGNMENTBASELINE_IDEOGRAPHICBOTTOM_VALUE = "ideographicBottom"; 
    
    public static final String FXG_BASELINEOFFSET_AUTO_VALUE = "auto";     
    public static final String FXG_BASELINEOFFSET_ASCENT_VALUE = "ascent";     
    public static final String FXG_BASELINEOFFSET_LINEHEIGHT_VALUE = "lineHeight";     
    
    public static final String FXG_BASELINESHIFT_SUPERSCRIPT_VALUE = "superscript"; 
    public static final String FXG_BASELINESHIFT_SUBSCRIPT_VALUE = "subscript"; 
     
    public static final String FXG_BEVEL_FULL_VALUE = "full";
    public static final String FXG_BEVEL_INNER_VALUE = "inner";
    public static final String FXG_BEVEL_OUTER_VALUE = "outer";

    public static final String FXG_BLENDMODE_ADD_VALUE = "add";
    public static final String FXG_BLENDMODE_ALPHA_VALUE = "alpha";
    public static final String FXG_BLENDMODE_AUTO_VALUE = "auto";
    public static final String FXG_BLENDMODE_DARKEN_VALUE = "darken";
    public static final String FXG_BLENDMODE_DIFFERENCE_VALUE = "difference";
    public static final String FXG_BLENDMODE_ERASE_VALUE = "erase";
    public static final String FXG_BLENDMODE_HARDLIGHT_VALUE = "hardlight";
    public static final String FXG_BLENDMODE_INVERT_VALUE = "invert";
    public static final String FXG_BLENDMODE_LAYER_VALUE = "layer";
    public static final String FXG_BLENDMODE_LIGHTEN_VALUE = "lighten";
    public static final String FXG_BLENDMODE_MULTIPLY_VALUE = "multiply";
    public static final String FXG_BLENDMODE_NORMAL_VALUE = "normal";
    public static final String FXG_BLENDMODE_SUBTRACT_VALUE = "subtract";
    public static final String FXG_BLENDMODE_SCREEN_VALUE = "screen";
    public static final String FXG_BLENDMODE_OVERLAY_VALUE = "overlay";
    public static final String FXG_BLENDMODE_COLORDOGE_VALUE = "colordodge";
    public static final String FXG_BLENDMODE_COLORBURN_VALUE = "colorburn";
    public static final String FXG_BLENDMODE_EXCLUSION_VALUE = "exclusion";
    public static final String FXG_BLENDMODE_SOFTLIGHT_VALUE = "softlight";
    public static final String FXG_BLENDMODE_HUE_VALUE = "hue";
    public static final String FXG_BLENDMODE_SATURATION_VALUE = "saturation";
    public static final String FXG_BLENDMODE_COLOR_VALUE = "color";
    public static final String FXG_BLENDMODE_LUMINOSITY_VALUE = "luminosity";
    
    public static final String FXG_BLOCKPROGRESSION_TB_VALUE = "tb";
    public static final String FXG_BLOCKPROGRESSION_RL_VALUE = "rl";
    
    public static final String FXG_BREAKOPPORTUNITY_AUTO_VALUE = "auto";
    public static final String FXG_BREAKOPPORTUNITY_ANY_VALUE = "any";
    public static final String FXG_BREAKOPPORTUNITY_NONE_VALUE = "none";
    public static final String FXG_BREAKOPPORTUNITY_ALL_VALUE = "all";  

    public static final String FXG_CAPS_ROUND_VALUE = "round";
    public static final String FXG_CAPS_SQUARE_VALUE = "square";
    public static final String FXG_CAPS_NONE_VALUE = "none";
    
    public static final String FXG_COLORWITHENUM_TRANSPARENT_VALUE = "transparent";
    
    public static final String FXG_DIGITCASE_DEFAULT_VALUE = "default";
    public static final String FXG_DIGITCASE_LINING_VALUE = "lining";
    public static final String FXG_DIGITCASE_OLDSTYLE_VALUE = "oldStyle";
    
    public static final String FXG_DIGITWIDTH_DEFAULT_VALUE = "default";
    public static final String FXG_DIGITWIDTH_PROPORTIONAL_VALUE = "proportional";
    public static final String FXG_DIGITWIDTH_TABULAR_VALUE = "tabular";

    public static final String FXG_DIRECTION_LTR_VALUE = "ltr";
    public static final String FXG_DIRECTION_RTL_VALUE = "rtl";
    
    public static final String FXG_DOMINANTBASELINE_AUTO_VALUE = "auto";    
    public static final String FXG_DOMINANTBASELINE_ROMAN_VALUE = "roman";
    public static final String FXG_DOMINANTBASELINE_ASCENT_VALUE = "ascent";    
    public static final String FXG_DOMINANTBASELINE_DESCENT_VALUE = "descent";      
    public static final String FXG_DOMINANTBASELINE_IDEOGRAPHICTOP_VALUE = "ideographicTop"; 
    public static final String FXG_DOMINANTBASELINE_IDEOGRAPHICCENTER_VALUE = "ideographicCenter"; 
    public static final String FXG_DOMINANTBASELINE_IDEOGRAPHICBOTTOM_VALUE = "ideographicBottom";     

    public static final String FXG_FONTSTYLE_NORMAL_VALUE = "normal";     
    public static final String FXG_FONTSTYLE_ITALIC_VALUE = "italic"; 

    public static final String FXG_FONTWEIGHT_NORMAL_VALUE = "normal";     
    public static final String FXG_FONTWEIGHT_BOLD_VALUE = "bold"; 
    
    public static final String FXG_INHERIT_VALUE = "inherit";

    public static final String FXG_INTERPOLATION_RGB_VALUE = "rgb";
    public static final String FXG_INTERPOLATION_LINEARRGB_VALUE = "linearRGB";

    public static final String FXG_JOINTS_ROUND_VALUE = "round";
    public static final String FXG_JOINTS_MITER_VALUE = "miter";
    public static final String FXG_JOINTS_BEVEL_VALUE = "bevel";
    
    public static final String FXG_JUSTIFICATIONRULE_AUTO_VALUE = "auto";
    public static final String FXG_JUSTIFICATIONRULE_SPACE_VALUE = "space";
    public static final String FXG_JUSTIFICATIONRULE_EASTASIAN_VALUE = "eastAsian";

    public static final String FXG_JUSTIFICATIONSTYLE_AUTO_VALUE = "auto";
    public static final String FXG_JUSTIFICATIONSTYLE_PRIORITIZELEASTADJUSTMENT_VALUE = "prioritizeLeastAdjustment";
    public static final String FXG_JUSTIFICATIONSTYLE_PUSHINKINSOKU_VALUE = "pushInKinsoku";
    public static final String FXG_JUSTIFICATIONSTYLE_PUSHOUTONLY_VALUE = "pushOutOnly";
    
    public static final String FXG_KERNING_AUTO_VALUE = "auto";
    public static final String FXG_KERNING_OFF_VALUE = "off";
    public static final String FXG_KERNING_ON_VALUE = "on";
    
    public static final String FXG_LEADINGMODEL_APPROXIMATETEXTFIELD_VALUE = "approximateTextField";
    public static final String FXG_LEADINGMODEL_AUTO_VALUE = "auto";
    public static final String FXG_LEADINGMODEL_ROMANUP_VALUE = "romanUp";
    public static final String FXG_LEADINGMODEL_IDEOGRAPHICTOPUP_VALUE = "ideographicTopUp";
    public static final String FXG_LEADINGMODEL_IDEOGRAPHICCENTERUP_VALUE = "ideographicCenterUp";
    public static final String FXG_LEADINGMODEL_ASCENTDESCENTUP_VALUE = "ascentDescentUp";
    public static final String FXG_LEADINGMODEL_IDEOGRAPHICTOPDOWN_VALUE = "ideographicTopDown";
    public static final String FXG_LEADINGMODEL_IDEOGRAPHICCENTERDOWN_VALUE = "ideographicCenterDown";

    public static final String FXG_LIGATURELEVEL_MINIMUM_VALUE = "minimum";
    public static final String FXG_LIGATURELEVEL_COMMON_VALUE = "common";
    public static final String FXG_LIGATURELEVEL_UNCOMMON_VALUE = "uncommon";
    public static final String FXG_LIGATURELEVEL_EXOTIC_VALUE = "exotic";
    
    public static final String FXG_LINEBREAK_EXPLICIT_VALUE = "explicit";
    public static final String FXG_LINEBREAK_TOFIT_VALUE = "toFit";
    
    public static final String FXG_MASK_CLIP_VALUE = "clip";
    public static final String FXG_MASK_ALPHA_VALUE = "alpha";
    public static final String FXG_MASK_LUMINOSITY_VALUE = "luminosity";
    
    public static final String FXG_NUMBERAUTO_AUTO_VALUE = "auto";

    public static final String FXG_NUMBERPERCENAUTO_AUTO_VALUE = "auto";
    
    public static final String FXG_FILLMODE_CLIP_VALUE = "clip";
    public static final String FXG_FILLMODE_REPEAT_VALUE = "repeat";
    public static final String FXG_FILLMODE_SCALE_VALUE = "scale";    

    public static final String FXG_SCALEMODE_NONE_VALUE = "none";
    public static final String FXG_SCALEMODE_VERTICAL_VALUE = "vertical";
    public static final String FXG_SCALEMODE_NORMAL_VALUE = "normal";
    public static final String FXG_SCALEMODE_HORIZONTAL_VALUE = "horizontal";

    public static final String FXG_SPREADMETHOD_PAD_VALUE = "pad";
    public static final String FXG_SPREADMETHOD_REFLECT_VALUE = "reflect";
    public static final String FXG_SPREADMETHOD_REPEAT_VALUE = "repeat";
    
    public static final String FXG_TARGET_SELF_VALUE = "_self";
    public static final String FXG_TARGET_BLANK_VALUE = "_blank";
    public static final String FXG_TARGET_PARENT_VALUE = "_parent";
    public static final String FXG_TARGET_TOP_VALUE = "_top"; 

    public static final String FXG_TEXTALIGN_START_VALUE = "start";
    public static final String FXG_TEXTALIGN_END_VALUE = "end";
    public static final String FXG_TEXTALIGN_LEFT_VALUE = "left";
    public static final String FXG_TEXTALIGN_CENTER_VALUE = "center";
    public static final String FXG_TEXTALIGN_RIGHT_VALUE = "right";
    public static final String FXG_TEXTALIGN_JUSTIFY_VALUE = "justify";
    
    public static final String FXG_TEXTDECORATION_NONE_VALUE = "none";
    public static final String FXG_TEXTDECORATION_UNDERLINE_VALUE = "underline";
    
    public static final String FXG_TEXTJUSTIFY_INTERWORD_VALUE = "interWord";
    public static final String FXG_TEXTJUSTIFY_DISTRIBUTE_VALUE = "distribute";
    
    public static final String FXG_TEXTROTATION_AUTO_VALUE = "auto";
    public static final String FXG_TEXTROTATION_ROTATE_0_VALUE = "rotate0";
    public static final String FXG_TEXTROTATION_ROTATE_90_VALUE = "rotate90";
    public static final String FXG_TEXTROTATION_ROTATE_180_VALUE = "rotate180";
    public static final String FXG_TEXTROTATION_ROTATE_270_VALUE = "rotate270";

    public static final String FXG_TYPOGRAPHICCASE_DEFAULT_VALUE = "default";
    public static final String FXG_TYPOGRAPHICCASE_CAPSTOSMALLCAPS_VALUE = "capsToSmallCaps";
    public static final String FXG_TYPOGRAPHICCASE_UPPERCASE_VALUE = "uppercase";
    public static final String FXG_TYPOGRAPHICCASE_LOWERCASE_VALUE = "lowercase";
    public static final String FXG_TYPOGRAPHICCASE_LOWERCASETOSMALLCAPS_VALUE = "lowercaseToSmallCaps";
       
    public static final String FXG_VERTICALALIGN_TOP_VALUE = "top";
    public static final String FXG_VERTICALALIGN_MIDDLE_VALUE = "middle";
    public static final String FXG_VERTICALALIGN_BOTTOM_VALUE = "bottom";
    public static final String FXG_VERTICALALIGN_JUSTIFY_VALUE = "justify";
    
    public static final String FXG_WHITESPACE_PRESERVE_VALUE = "preserve";
    public static final String FXG_WHITESPACE_COLLAPSE_VALUE = "collapse";

    public static final String FXG_WINDING_EVENODD_VALUE = "evenOdd";
    public static final String FXG_WINDING_NONZERO_VALUE = "nonZero";
    
    // A special case needed to short circuit GroupNode creation inside a
    // Definition as such Groups are not the same as those in the graphics
    // tree.
    public static final String FXG_GROUP_DEFINITION_ELEMENT = "[GroupDefinition]";
    
    // A special tag referencing a character data content in a FXG text node.
    public static String FXG_CDATA = "CDATA";
    
}
