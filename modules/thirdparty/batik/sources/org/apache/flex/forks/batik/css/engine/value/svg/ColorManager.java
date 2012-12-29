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
package org.apache.flex.forks.batik.css.engine.value.svg;

import org.apache.flex.forks.batik.css.engine.value.AbstractColorManager;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.SVGTypes;

/**
 * This class provides a manager for the 'color' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ColorManager.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class ColorManager extends AbstractColorManager {

    /**
     * The default color value.
     */
    protected static final Value DEFAULT_VALUE =
        SVGValueConstants.BLACK_RGB_VALUE;

    //
    // Add some identifier values.
    //
    static {
        values.put(CSSConstants.CSS_ALICEBLUE_VALUE,
                   SVGValueConstants.ALICEBLUE_VALUE);
        values.put(CSSConstants.CSS_ANTIQUEWHITE_VALUE,
                   SVGValueConstants.ANTIQUEWHITE_VALUE);
        values.put(CSSConstants.CSS_AQUAMARINE_VALUE,
                   SVGValueConstants.AQUAMARINE_VALUE);
        values.put(CSSConstants.CSS_AZURE_VALUE,
                   SVGValueConstants.AZURE_VALUE);
        values.put(CSSConstants.CSS_BEIGE_VALUE,
                   SVGValueConstants.BEIGE_VALUE);
        values.put(CSSConstants.CSS_BISQUE_VALUE,
                   SVGValueConstants.BISQUE_VALUE);
        values.put(CSSConstants.CSS_BLANCHEDALMOND_VALUE,
                   SVGValueConstants.BLANCHEDALMOND_VALUE);
        values.put(CSSConstants.CSS_BLUEVIOLET_VALUE,
                   SVGValueConstants.BLUEVIOLET_VALUE);
        values.put(CSSConstants.CSS_BROWN_VALUE,
                   SVGValueConstants.BROWN_VALUE);
        values.put(CSSConstants.CSS_BURLYWOOD_VALUE,
                   SVGValueConstants.BURLYWOOD_VALUE);
        values.put(CSSConstants.CSS_CADETBLUE_VALUE,
                   SVGValueConstants.CADETBLUE_VALUE);
        values.put(CSSConstants.CSS_CHARTREUSE_VALUE,
                   SVGValueConstants.CHARTREUSE_VALUE);
        values.put(CSSConstants.CSS_CHOCOLATE_VALUE,
                   SVGValueConstants.CHOCOLATE_VALUE);
        values.put(CSSConstants.CSS_CORAL_VALUE,
                   SVGValueConstants.CORAL_VALUE);
        values.put(CSSConstants.CSS_CORNFLOWERBLUE_VALUE,
                   SVGValueConstants.CORNFLOWERBLUE_VALUE);
        values.put(CSSConstants.CSS_CORNSILK_VALUE,
                   SVGValueConstants.CORNSILK_VALUE);
        values.put(CSSConstants.CSS_CRIMSON_VALUE,
                   SVGValueConstants.CRIMSON_VALUE);
        values.put(CSSConstants.CSS_CYAN_VALUE,
                   SVGValueConstants.CYAN_VALUE);
        values.put(CSSConstants.CSS_DARKBLUE_VALUE,
                   SVGValueConstants.DARKBLUE_VALUE);
        values.put(CSSConstants.CSS_DARKCYAN_VALUE,
                   SVGValueConstants.DARKCYAN_VALUE);
        values.put(CSSConstants.CSS_DARKGOLDENROD_VALUE,
                   SVGValueConstants.DARKGOLDENROD_VALUE);
        values.put(CSSConstants.CSS_DARKGRAY_VALUE,
                   SVGValueConstants.DARKGRAY_VALUE);
        values.put(CSSConstants.CSS_DARKGREEN_VALUE,
                   SVGValueConstants.DARKGREEN_VALUE);
        values.put(CSSConstants.CSS_DARKGREY_VALUE,
                   SVGValueConstants.DARKGREY_VALUE);
        values.put(CSSConstants.CSS_DARKKHAKI_VALUE,
                   SVGValueConstants.DARKKHAKI_VALUE);
        values.put(CSSConstants.CSS_DARKMAGENTA_VALUE,
                   SVGValueConstants.DARKMAGENTA_VALUE);
        values.put(CSSConstants.CSS_DARKOLIVEGREEN_VALUE,
                   SVGValueConstants.DARKOLIVEGREEN_VALUE);
        values.put(CSSConstants.CSS_DARKORANGE_VALUE,
                   SVGValueConstants.DARKORANGE_VALUE);
        values.put(CSSConstants.CSS_DARKORCHID_VALUE,
                   SVGValueConstants.DARKORCHID_VALUE);
        values.put(CSSConstants.CSS_DARKRED_VALUE,
                   SVGValueConstants.DARKRED_VALUE);
        values.put(CSSConstants.CSS_DARKSALMON_VALUE,
                   SVGValueConstants.DARKSALMON_VALUE);
        values.put(CSSConstants.CSS_DARKSEAGREEN_VALUE,
                   SVGValueConstants.DARKSEAGREEN_VALUE);
        values.put(CSSConstants.CSS_DARKSLATEBLUE_VALUE,
                   SVGValueConstants.DARKSLATEBLUE_VALUE);
        values.put(CSSConstants.CSS_DARKSLATEGRAY_VALUE,
                   SVGValueConstants.DARKSLATEGRAY_VALUE);
        values.put(CSSConstants.CSS_DARKSLATEGREY_VALUE,
                   SVGValueConstants.DARKSLATEGREY_VALUE);
        values.put(CSSConstants.CSS_DARKTURQUOISE_VALUE,
                   SVGValueConstants.DARKTURQUOISE_VALUE);
        values.put(CSSConstants.CSS_DARKVIOLET_VALUE,
                   SVGValueConstants.DARKVIOLET_VALUE);
        values.put(CSSConstants.CSS_DEEPPINK_VALUE,
                   SVGValueConstants.DEEPPINK_VALUE);
        values.put(CSSConstants.CSS_DEEPSKYBLUE_VALUE,
                   SVGValueConstants.DEEPSKYBLUE_VALUE);
        values.put(CSSConstants.CSS_DIMGRAY_VALUE,
                   SVGValueConstants.DIMGRAY_VALUE);
        values.put(CSSConstants.CSS_DIMGREY_VALUE,
                   SVGValueConstants.DIMGREY_VALUE);
        values.put(CSSConstants.CSS_DODGERBLUE_VALUE,
                   SVGValueConstants.DODGERBLUE_VALUE);
        values.put(CSSConstants.CSS_FIREBRICK_VALUE,
                   SVGValueConstants.FIREBRICK_VALUE);
        values.put(CSSConstants.CSS_FLORALWHITE_VALUE,
                   SVGValueConstants.FLORALWHITE_VALUE);
        values.put(CSSConstants.CSS_FORESTGREEN_VALUE,
                   SVGValueConstants.FORESTGREEN_VALUE);
        values.put(CSSConstants.CSS_GAINSBORO_VALUE,
                   SVGValueConstants.GAINSBORO_VALUE);
        values.put(CSSConstants.CSS_GHOSTWHITE_VALUE,
                   SVGValueConstants.GHOSTWHITE_VALUE);
        values.put(CSSConstants.CSS_GOLD_VALUE,
                   SVGValueConstants.GOLD_VALUE);
        values.put(CSSConstants.CSS_GOLDENROD_VALUE,
                   SVGValueConstants.GOLDENROD_VALUE);
        values.put(CSSConstants.CSS_GREENYELLOW_VALUE,
                   SVGValueConstants.GREENYELLOW_VALUE);
        values.put(CSSConstants.CSS_GREY_VALUE,
                   SVGValueConstants.GREY_VALUE);
        values.put(CSSConstants.CSS_HONEYDEW_VALUE,
                   SVGValueConstants.HONEYDEW_VALUE);
        values.put(CSSConstants.CSS_HOTPINK_VALUE,
                   SVGValueConstants.HOTPINK_VALUE);
        values.put(CSSConstants.CSS_INDIANRED_VALUE,
                   SVGValueConstants.INDIANRED_VALUE);
        values.put(CSSConstants.CSS_INDIGO_VALUE,
                   SVGValueConstants.INDIGO_VALUE);
        values.put(CSSConstants.CSS_IVORY_VALUE,
                   SVGValueConstants.IVORY_VALUE);
        values.put(CSSConstants.CSS_KHAKI_VALUE,
                   SVGValueConstants.KHAKI_VALUE);
        values.put(CSSConstants.CSS_LAVENDER_VALUE,
                   SVGValueConstants.LAVENDER_VALUE);
        values.put(CSSConstants.CSS_LAVENDERBLUSH_VALUE,
                   SVGValueConstants.LAVENDERBLUSH_VALUE);
        values.put(CSSConstants.CSS_LAWNGREEN_VALUE,
                   SVGValueConstants.LAWNGREEN_VALUE);
        values.put(CSSConstants.CSS_LEMONCHIFFON_VALUE,
                   SVGValueConstants.LEMONCHIFFON_VALUE);
        values.put(CSSConstants.CSS_LIGHTBLUE_VALUE,
                   SVGValueConstants.LIGHTBLUE_VALUE);
        values.put(CSSConstants.CSS_LIGHTCORAL_VALUE,
                   SVGValueConstants.LIGHTCORAL_VALUE);
        values.put(CSSConstants.CSS_LIGHTCYAN_VALUE,
                   SVGValueConstants.LIGHTCYAN_VALUE);
        values.put(CSSConstants.CSS_LIGHTGOLDENRODYELLOW_VALUE,
                   SVGValueConstants.LIGHTGOLDENRODYELLOW_VALUE);
        values.put(CSSConstants.CSS_LIGHTGRAY_VALUE,
                   SVGValueConstants.LIGHTGRAY_VALUE);
        values.put(CSSConstants.CSS_LIGHTGREEN_VALUE,
                   SVGValueConstants.LIGHTGREEN_VALUE);
        values.put(CSSConstants.CSS_LIGHTGREY_VALUE,
                   SVGValueConstants.LIGHTGREY_VALUE);
        values.put(CSSConstants.CSS_LIGHTPINK_VALUE,
                   SVGValueConstants.LIGHTPINK_VALUE);
        values.put(CSSConstants.CSS_LIGHTSALMON_VALUE,
                   SVGValueConstants.LIGHTSALMON_VALUE);
        values.put(CSSConstants.CSS_LIGHTSEAGREEN_VALUE,
                   SVGValueConstants.LIGHTSEAGREEN_VALUE);
        values.put(CSSConstants.CSS_LIGHTSKYBLUE_VALUE,
                   SVGValueConstants.LIGHTSKYBLUE_VALUE);
        values.put(CSSConstants.CSS_LIGHTSLATEGRAY_VALUE,
                   SVGValueConstants.LIGHTSLATEGRAY_VALUE);
        values.put(CSSConstants.CSS_LIGHTSLATEGREY_VALUE,
                   SVGValueConstants.LIGHTSLATEGREY_VALUE);
        values.put(CSSConstants.CSS_LIGHTSTEELBLUE_VALUE,
                   SVGValueConstants.LIGHTSTEELBLUE_VALUE);
        values.put(CSSConstants.CSS_LIGHTYELLOW_VALUE,
                   SVGValueConstants.LIGHTYELLOW_VALUE);
        values.put(CSSConstants.CSS_LIMEGREEN_VALUE,
                   SVGValueConstants.LIMEGREEN_VALUE);
        values.put(CSSConstants.CSS_LINEN_VALUE,
                   SVGValueConstants.LINEN_VALUE);
        values.put(CSSConstants.CSS_MAGENTA_VALUE,
                   SVGValueConstants.MAGENTA_VALUE);
        values.put(CSSConstants.CSS_MEDIUMAQUAMARINE_VALUE,
                   SVGValueConstants.MEDIUMAQUAMARINE_VALUE);
        values.put(CSSConstants.CSS_MEDIUMBLUE_VALUE,
                   SVGValueConstants.MEDIUMBLUE_VALUE);
        values.put(CSSConstants.CSS_MEDIUMORCHID_VALUE,
                   SVGValueConstants.MEDIUMORCHID_VALUE);
        values.put(CSSConstants.CSS_MEDIUMPURPLE_VALUE,
                   SVGValueConstants.MEDIUMPURPLE_VALUE);
        values.put(CSSConstants.CSS_MEDIUMSEAGREEN_VALUE,
                   SVGValueConstants.MEDIUMSEAGREEN_VALUE);
        values.put(CSSConstants.CSS_MEDIUMSLATEBLUE_VALUE,
                   SVGValueConstants.MEDIUMSLATEBLUE_VALUE);
        values.put(CSSConstants.CSS_MEDIUMSPRINGGREEN_VALUE,
                   SVGValueConstants.MEDIUMSPRINGGREEN_VALUE);
        values.put(CSSConstants.CSS_MEDIUMTURQUOISE_VALUE,
                   SVGValueConstants.MEDIUMTURQUOISE_VALUE);
        values.put(CSSConstants.CSS_MEDIUMVIOLETRED_VALUE,
                   SVGValueConstants.MEDIUMVIOLETRED_VALUE);
        values.put(CSSConstants.CSS_MIDNIGHTBLUE_VALUE,
                   SVGValueConstants.MIDNIGHTBLUE_VALUE);
        values.put(CSSConstants.CSS_MINTCREAM_VALUE,
                   SVGValueConstants.MINTCREAM_VALUE);
        values.put(CSSConstants.CSS_MISTYROSE_VALUE,
                   SVGValueConstants.MISTYROSE_VALUE);
        values.put(CSSConstants.CSS_MOCCASIN_VALUE,
                   SVGValueConstants.MOCCASIN_VALUE);
        values.put(CSSConstants.CSS_NAVAJOWHITE_VALUE,
                   SVGValueConstants.NAVAJOWHITE_VALUE);
        values.put(CSSConstants.CSS_OLDLACE_VALUE,
                   SVGValueConstants.OLDLACE_VALUE);
        values.put(CSSConstants.CSS_OLIVEDRAB_VALUE,
                   SVGValueConstants.OLIVEDRAB_VALUE);
        values.put(CSSConstants.CSS_ORANGE_VALUE,
                   SVGValueConstants.ORANGE_VALUE);
        values.put(CSSConstants.CSS_ORANGERED_VALUE,
                   SVGValueConstants.ORANGERED_VALUE);
        values.put(CSSConstants.CSS_ORCHID_VALUE,
                   SVGValueConstants.ORCHID_VALUE);
        values.put(CSSConstants.CSS_PALEGOLDENROD_VALUE,
                   SVGValueConstants.PALEGOLDENROD_VALUE);
        values.put(CSSConstants.CSS_PALEGREEN_VALUE,
                   SVGValueConstants.PALEGREEN_VALUE);
        values.put(CSSConstants.CSS_PALETURQUOISE_VALUE,
                   SVGValueConstants.PALETURQUOISE_VALUE);
        values.put(CSSConstants.CSS_PALEVIOLETRED_VALUE,
                   SVGValueConstants.PALEVIOLETRED_VALUE);
        values.put(CSSConstants.CSS_PAPAYAWHIP_VALUE,
                   SVGValueConstants.PAPAYAWHIP_VALUE);
        values.put(CSSConstants.CSS_PEACHPUFF_VALUE,
                   SVGValueConstants.PEACHPUFF_VALUE);
        values.put(CSSConstants.CSS_PERU_VALUE,
                   SVGValueConstants.PERU_VALUE);
        values.put(CSSConstants.CSS_PINK_VALUE,
                   SVGValueConstants.PINK_VALUE);
        values.put(CSSConstants.CSS_PLUM_VALUE,
                   SVGValueConstants.PLUM_VALUE);
        values.put(CSSConstants.CSS_POWDERBLUE_VALUE,
                   SVGValueConstants.POWDERBLUE_VALUE);
        values.put(CSSConstants.CSS_PURPLE_VALUE,
                   SVGValueConstants.PURPLE_VALUE);
        values.put(CSSConstants.CSS_ROSYBROWN_VALUE,
                   SVGValueConstants.ROSYBROWN_VALUE);
        values.put(CSSConstants.CSS_ROYALBLUE_VALUE,
                   SVGValueConstants.ROYALBLUE_VALUE);
        values.put(CSSConstants.CSS_SADDLEBROWN_VALUE,
                   SVGValueConstants.SADDLEBROWN_VALUE);
        values.put(CSSConstants.CSS_SALMON_VALUE,
                   SVGValueConstants.SALMON_VALUE);
        values.put(CSSConstants.CSS_SANDYBROWN_VALUE,
                   SVGValueConstants.SANDYBROWN_VALUE);
        values.put(CSSConstants.CSS_SEAGREEN_VALUE,
                   SVGValueConstants.SEAGREEN_VALUE);
        values.put(CSSConstants.CSS_SEASHELL_VALUE,
                   SVGValueConstants.SEASHELL_VALUE);
        values.put(CSSConstants.CSS_SIENNA_VALUE,
                   SVGValueConstants.SIENNA_VALUE);
        values.put(CSSConstants.CSS_SKYBLUE_VALUE,
                   SVGValueConstants.SKYBLUE_VALUE);
        values.put(CSSConstants.CSS_SLATEBLUE_VALUE,
                   SVGValueConstants.SLATEBLUE_VALUE);
        values.put(CSSConstants.CSS_SLATEGRAY_VALUE,
                   SVGValueConstants.SLATEGRAY_VALUE);
        values.put(CSSConstants.CSS_SLATEGREY_VALUE,
                   SVGValueConstants.SLATEGREY_VALUE);
        values.put(CSSConstants.CSS_SNOW_VALUE,
                   SVGValueConstants.SNOW_VALUE);
        values.put(CSSConstants.CSS_SPRINGGREEN_VALUE,
                   SVGValueConstants.SPRINGGREEN_VALUE);
        values.put(CSSConstants.CSS_STEELBLUE_VALUE,
                   SVGValueConstants.STEELBLUE_VALUE);
        values.put(CSSConstants.CSS_TAN_VALUE,
                   SVGValueConstants.TAN_VALUE);
        values.put(CSSConstants.CSS_THISTLE_VALUE,
                   SVGValueConstants.THISTLE_VALUE);
        values.put(CSSConstants.CSS_TOMATO_VALUE,
                   SVGValueConstants.TOMATO_VALUE);
        values.put(CSSConstants.CSS_TURQUOISE_VALUE,
                   SVGValueConstants.TURQUOISE_VALUE);
        values.put(CSSConstants.CSS_VIOLET_VALUE,
                   SVGValueConstants.VIOLET_VALUE);
        values.put(CSSConstants.CSS_WHEAT_VALUE,
                   SVGValueConstants.WHEAT_VALUE);
        values.put(CSSConstants.CSS_WHITESMOKE_VALUE,
                   SVGValueConstants.WHITESMOKE_VALUE);
        values.put(CSSConstants.CSS_YELLOWGREEN_VALUE,
                   SVGValueConstants.YELLOWGREEN_VALUE);
    }

    //
    // Add and replace some computed colors.
    //
    static {
        computedValues.put(CSSConstants.CSS_BLACK_VALUE,
                           SVGValueConstants.BLACK_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SILVER_VALUE,
                           SVGValueConstants.SILVER_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GRAY_VALUE,
                           SVGValueConstants.GRAY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_WHITE_VALUE,
                           SVGValueConstants.WHITE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MAROON_VALUE,
                           SVGValueConstants.MAROON_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_RED_VALUE,
                           SVGValueConstants.RED_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PURPLE_VALUE,
                           SVGValueConstants.PURPLE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_FUCHSIA_VALUE,
                           SVGValueConstants.FUCHSIA_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GREEN_VALUE,
                           SVGValueConstants.GREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIME_VALUE,
                           SVGValueConstants.LIME_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_OLIVE_VALUE,
                           SVGValueConstants.OLIVE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_YELLOW_VALUE,
                           SVGValueConstants.YELLOW_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_NAVY_VALUE,
                           SVGValueConstants.NAVY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_BLUE_VALUE,
                           SVGValueConstants.BLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_TEAL_VALUE,
                           SVGValueConstants.TEAL_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_AQUA_VALUE,
                           SVGValueConstants.AQUA_RGB_VALUE);

        computedValues.put(CSSConstants.CSS_ALICEBLUE_VALUE,
                           SVGValueConstants.ALICEBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_ANTIQUEWHITE_VALUE,
                           SVGValueConstants.ANTIQUEWHITE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_AQUAMARINE_VALUE,
                           SVGValueConstants.AQUAMARINE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_AZURE_VALUE,
                           SVGValueConstants.AZURE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_BEIGE_VALUE,
                           SVGValueConstants.BEIGE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_BISQUE_VALUE,
                           SVGValueConstants.BISQUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_BLANCHEDALMOND_VALUE,
                           SVGValueConstants.BLANCHEDALMOND_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_BLUEVIOLET_VALUE,
                           SVGValueConstants.BLUEVIOLET_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_BROWN_VALUE,
                           SVGValueConstants.BROWN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_BURLYWOOD_VALUE,
                           SVGValueConstants.BURLYWOOD_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_CADETBLUE_VALUE,
                           SVGValueConstants.CADETBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_CHARTREUSE_VALUE,
                           SVGValueConstants.CHARTREUSE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_CHOCOLATE_VALUE,
                           SVGValueConstants.CHOCOLATE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_CORAL_VALUE,
                           SVGValueConstants.CORAL_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_CORNFLOWERBLUE_VALUE,
                           SVGValueConstants.CORNFLOWERBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_CORNSILK_VALUE,
                           SVGValueConstants.CORNSILK_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_CRIMSON_VALUE,
                           SVGValueConstants.CRIMSON_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_CYAN_VALUE,
                           SVGValueConstants.CYAN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKBLUE_VALUE,
                           SVGValueConstants.DARKBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKCYAN_VALUE,
                           SVGValueConstants.DARKCYAN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKGOLDENROD_VALUE,
                           SVGValueConstants.DARKGOLDENROD_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKGRAY_VALUE,
                           SVGValueConstants.DARKGRAY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKGREEN_VALUE,
                           SVGValueConstants.DARKGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKGREY_VALUE,
                           SVGValueConstants.DARKGREY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKKHAKI_VALUE,
                           SVGValueConstants.DARKKHAKI_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKMAGENTA_VALUE,
                           SVGValueConstants.DARKMAGENTA_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKOLIVEGREEN_VALUE,
                           SVGValueConstants.DARKOLIVEGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKORANGE_VALUE,
                           SVGValueConstants.DARKORANGE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKORCHID_VALUE,
                           SVGValueConstants.DARKORCHID_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKRED_VALUE,
                           SVGValueConstants.DARKRED_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKSALMON_VALUE,
                           SVGValueConstants.DARKSALMON_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKSEAGREEN_VALUE,
                           SVGValueConstants.DARKSEAGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKSLATEBLUE_VALUE,
                           SVGValueConstants.DARKSLATEBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKSLATEGRAY_VALUE,
                           SVGValueConstants.DARKSLATEGRAY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKSLATEGREY_VALUE,
                           SVGValueConstants.DARKSLATEGREY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKTURQUOISE_VALUE,
                           SVGValueConstants.DARKTURQUOISE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DARKVIOLET_VALUE,
                           SVGValueConstants.DARKVIOLET_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DEEPPINK_VALUE,
                           SVGValueConstants.DEEPPINK_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DEEPSKYBLUE_VALUE,
                           SVGValueConstants.DEEPSKYBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DIMGRAY_VALUE,
                           SVGValueConstants.DIMGRAY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DIMGREY_VALUE,
                           SVGValueConstants.DIMGREY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_DODGERBLUE_VALUE,
                           SVGValueConstants.DODGERBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_FIREBRICK_VALUE,
                           SVGValueConstants.FIREBRICK_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_FLORALWHITE_VALUE,
                           SVGValueConstants.FLORALWHITE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_FORESTGREEN_VALUE,
                           SVGValueConstants.FORESTGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GAINSBORO_VALUE,
                           SVGValueConstants.GAINSBORO_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GHOSTWHITE_VALUE,
                           SVGValueConstants.GHOSTWHITE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GOLD_VALUE,
                           SVGValueConstants.GOLD_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GOLDENROD_VALUE,
                           SVGValueConstants.GOLDENROD_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GREY_VALUE,
                           SVGValueConstants.GREY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GREENYELLOW_VALUE,
                           SVGValueConstants.GREENYELLOW_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_HONEYDEW_VALUE,
                           SVGValueConstants.HONEYDEW_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_HOTPINK_VALUE,
                           SVGValueConstants.HOTPINK_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_INDIANRED_VALUE,
                           SVGValueConstants.INDIANRED_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_INDIGO_VALUE,
                           SVGValueConstants.INDIGO_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_IVORY_VALUE,
                           SVGValueConstants.IVORY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_KHAKI_VALUE,
                           SVGValueConstants.KHAKI_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LAVENDER_VALUE,
                           SVGValueConstants.LAVENDER_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LAVENDERBLUSH_VALUE,
                           SVGValueConstants.LAVENDERBLUSH_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LAWNGREEN_VALUE,
                           SVGValueConstants.LAWNGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LEMONCHIFFON_VALUE,
                           SVGValueConstants.LEMONCHIFFON_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTBLUE_VALUE,
                           SVGValueConstants.LIGHTBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTCORAL_VALUE,
                           SVGValueConstants.LIGHTCORAL_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTCYAN_VALUE,
                           SVGValueConstants.LIGHTCYAN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTGOLDENRODYELLOW_VALUE,
                           SVGValueConstants.LIGHTGOLDENRODYELLOW_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTGRAY_VALUE,
                           SVGValueConstants.LIGHTGRAY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTGREEN_VALUE,
                           SVGValueConstants.LIGHTGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTGREY_VALUE,
                           SVGValueConstants.LIGHTGREY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTPINK_VALUE,
                           SVGValueConstants.LIGHTPINK_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTSALMON_VALUE,
                           SVGValueConstants.LIGHTSALMON_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTSEAGREEN_VALUE,
                           SVGValueConstants.LIGHTSEAGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTSKYBLUE_VALUE,
                           SVGValueConstants.LIGHTSKYBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTSLATEGRAY_VALUE,
                           SVGValueConstants.LIGHTSLATEGRAY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTSLATEGREY_VALUE,
                           SVGValueConstants.LIGHTSLATEGREY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTSTEELBLUE_VALUE,
                           SVGValueConstants.LIGHTSTEELBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIGHTYELLOW_VALUE,
                           SVGValueConstants.LIGHTYELLOW_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIMEGREEN_VALUE,
                           SVGValueConstants.LIMEGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LINEN_VALUE,
                           SVGValueConstants.LINEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MAGENTA_VALUE,
                           SVGValueConstants.MAGENTA_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMAQUAMARINE_VALUE,
                           SVGValueConstants.MEDIUMAQUAMARINE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMBLUE_VALUE,
                           SVGValueConstants.MEDIUMBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMORCHID_VALUE,
                           SVGValueConstants.MEDIUMORCHID_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMPURPLE_VALUE,
                           SVGValueConstants.MEDIUMPURPLE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMSEAGREEN_VALUE,
                           SVGValueConstants.MEDIUMSEAGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMSLATEBLUE_VALUE,
                           SVGValueConstants.MEDIUMSLATEBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMSPRINGGREEN_VALUE,
                           SVGValueConstants.MEDIUMSPRINGGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMTURQUOISE_VALUE,
                           SVGValueConstants.MEDIUMTURQUOISE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MEDIUMVIOLETRED_VALUE,
                           SVGValueConstants.MEDIUMVIOLETRED_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MIDNIGHTBLUE_VALUE,
                           SVGValueConstants.MIDNIGHTBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MINTCREAM_VALUE,
                           SVGValueConstants.MINTCREAM_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MISTYROSE_VALUE,
                           SVGValueConstants.MISTYROSE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MOCCASIN_VALUE,
                           SVGValueConstants.MOCCASIN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_NAVAJOWHITE_VALUE,
                           SVGValueConstants.NAVAJOWHITE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_OLDLACE_VALUE,
                           SVGValueConstants.OLDLACE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_OLIVEDRAB_VALUE,
                           SVGValueConstants.OLIVEDRAB_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_ORANGE_VALUE,
                           SVGValueConstants.ORANGE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_ORANGERED_VALUE,
                           SVGValueConstants.ORANGERED_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_ORCHID_VALUE,
                           SVGValueConstants.ORCHID_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PALEGOLDENROD_VALUE,
                           SVGValueConstants.PALEGOLDENROD_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PALEGREEN_VALUE,
                           SVGValueConstants.PALEGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PALETURQUOISE_VALUE,
                           SVGValueConstants.PALETURQUOISE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PALEVIOLETRED_VALUE,
                           SVGValueConstants.PALEVIOLETRED_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PAPAYAWHIP_VALUE,
                           SVGValueConstants.PAPAYAWHIP_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PEACHPUFF_VALUE,
                           SVGValueConstants.PEACHPUFF_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PERU_VALUE,
                           SVGValueConstants.PERU_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PINK_VALUE,
                           SVGValueConstants.PINK_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PLUM_VALUE,
                           SVGValueConstants.PLUM_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_POWDERBLUE_VALUE,
                           SVGValueConstants.POWDERBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PURPLE_VALUE,
                           SVGValueConstants.PURPLE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_ROSYBROWN_VALUE,
                           SVGValueConstants.ROSYBROWN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_ROYALBLUE_VALUE,
                           SVGValueConstants.ROYALBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SADDLEBROWN_VALUE,
                           SVGValueConstants.SADDLEBROWN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SALMON_VALUE,
                           SVGValueConstants.SALMON_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SANDYBROWN_VALUE,
                           SVGValueConstants.SANDYBROWN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SEAGREEN_VALUE,
                           SVGValueConstants.SEAGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SEASHELL_VALUE,
                           SVGValueConstants.SEASHELL_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SIENNA_VALUE,
                           SVGValueConstants.SIENNA_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SKYBLUE_VALUE,
                           SVGValueConstants.SKYBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SLATEBLUE_VALUE,
                           SVGValueConstants.SLATEBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SLATEGRAY_VALUE,
                           SVGValueConstants.SLATEGRAY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SLATEGREY_VALUE,
                           SVGValueConstants.SLATEGREY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SNOW_VALUE,
                           SVGValueConstants.SNOW_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SPRINGGREEN_VALUE,
                           SVGValueConstants.SPRINGGREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_STEELBLUE_VALUE,
                           SVGValueConstants.STEELBLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_TAN_VALUE,
                           SVGValueConstants.TAN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_THISTLE_VALUE,
                           SVGValueConstants.THISTLE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_TOMATO_VALUE,
                           SVGValueConstants.TOMATO_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_TURQUOISE_VALUE,
                           SVGValueConstants.TURQUOISE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_VIOLET_VALUE,
                           SVGValueConstants.VIOLET_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_WHEAT_VALUE,
                           SVGValueConstants.WHEAT_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_WHITESMOKE_VALUE,
                           SVGValueConstants.WHITESMOKE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_YELLOWGREEN_VALUE,
                           SVGValueConstants.YELLOWGREEN_RGB_VALUE);

    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
        return true;
    }

    /**
     * Implements {@link ValueManager#isAnimatableProperty()}.
     */
    public boolean isAnimatableProperty() {
        return true;
    }

    /**
     * Implements {@link ValueManager#isAdditiveProperty()}.
     */
    public boolean isAdditiveProperty() {
        return true;
    }

    /**
     * Implements {@link ValueManager#getPropertyType()}.
     */
    public int getPropertyType() {
        return SVGTypes.TYPE_COLOR;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return CSSConstants.CSS_COLOR_PROPERTY;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return DEFAULT_VALUE;
    }


}
