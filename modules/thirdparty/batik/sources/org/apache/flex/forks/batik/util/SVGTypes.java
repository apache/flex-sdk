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
 * Abstract class for SVG type related constants.  These maybe should
 * move into o.a.b.util.SVGConstants.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGTypes.java 579487 2007-09-26 06:40:16Z cam $
 */
public abstract class SVGTypes {

    // Constants for SVG attribute and property types.
    public static final int TYPE_UNKNOWN                         = 0;
    public static final int TYPE_INTEGER                         = 1;
    public static final int TYPE_NUMBER                          = 2;
    public static final int TYPE_LENGTH                          = 3;
    public static final int TYPE_NUMBER_OPTIONAL_NUMBER          = 4;
    public static final int TYPE_ANGLE                           = 5;
    public static final int TYPE_COLOR                           = 6;
    public static final int TYPE_PAINT                           = 7;
    public static final int TYPE_PERCENTAGE                      = 8;
    public static final int TYPE_TRANSFORM_LIST                  = 9;
    public static final int TYPE_URI                             = 10;
    public static final int TYPE_FREQUENCY                       = 11;
    public static final int TYPE_TIME                            = 12;
    public static final int TYPE_NUMBER_LIST                     = 13;
    public static final int TYPE_LENGTH_LIST                     = 14;
    public static final int TYPE_IDENT                           = 15;
    public static final int TYPE_CDATA                           = 16;
    public static final int TYPE_LENGTH_OR_INHERIT               = 17;
    public static final int TYPE_IDENT_LIST                      = 18;
    public static final int TYPE_CLIP_VALUE                      = 19;
    public static final int TYPE_URI_OR_IDENT                    = 20;
    public static final int TYPE_CURSOR_VALUE                    = 21;
    public static final int TYPE_PATH_DATA                       = 22;
    public static final int TYPE_ENABLE_BACKGROUND_VALUE         = 23;
    public static final int TYPE_TIME_VALUE_LIST                 = 24;
    public static final int TYPE_NUMBER_OR_INHERIT               = 25;
    public static final int TYPE_FONT_FAMILY_VALUE               = 26;
    public static final int TYPE_FONT_FACE_FONT_SIZE_VALUE       = 27;
    public static final int TYPE_FONT_WEIGHT_VALUE               = 28;
    public static final int TYPE_ANGLE_OR_IDENT                  = 29;
    public static final int TYPE_KEY_SPLINES_VALUE               = 30;
    public static final int TYPE_POINTS_VALUE                    = 31;
    public static final int TYPE_PRESERVE_ASPECT_RATIO_VALUE     = 32;
    public static final int TYPE_URI_LIST                        = 33;
    public static final int TYPE_LENGTH_LIST_OR_IDENT            = 34;
    public static final int TYPE_CHARACTER_OR_UNICODE_RANGE_LIST = 35;
    public static final int TYPE_UNICODE_RANGE_LIST              = 36;
    public static final int TYPE_FONT_VALUE                      = 37;
    public static final int TYPE_FONT_DESCRIPTOR_SRC_VALUE       = 38;
    public static final int TYPE_FONT_SIZE_VALUE                 = 39;
    public static final int TYPE_BASELINE_SHIFT_VALUE            = 40;
    public static final int TYPE_KERNING_VALUE                   = 41;
    public static final int TYPE_SPACING_VALUE                   = 42;
    public static final int TYPE_LINE_HEIGHT_VALUE               = 43;
    public static final int TYPE_FONT_SIZE_ADJUST_VALUE          = 44;
    public static final int TYPE_LANG                            = 45;
    public static final int TYPE_LANG_LIST                       = 46;
    public static final int TYPE_NUMBER_OR_PERCENTAGE            = 47;
    public static final int TYPE_TIMING_SPECIFIER_LIST           = 48;
    public static final int TYPE_BOOLEAN                         = 49;
    public static final int TYPE_RECT                            = 50;
}
