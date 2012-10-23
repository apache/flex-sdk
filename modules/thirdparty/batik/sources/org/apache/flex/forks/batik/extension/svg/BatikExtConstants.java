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
package org.apache.flex.forks.batik.extension.svg;

/**
 * Batik extension constants.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: BatikExtConstants.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface BatikExtConstants {

    /** Namespace for batik extentions. */
    String BATIK_EXT_NAMESPACE_URI =
        "http://xml.apache.org/batik/ext";

    /** Namespace for batik experimental svg 1.2 elements. */
    String BATIK_12_NAMESPACE_URI =
        "http://xml.apache.org/batik/ext";

    /** Namespace for batik experimental svg 1.2 attributes. */
    String BATIK_12_ATTR_NAMESPACE_URI =
        "http://xml.apache.org/batik/ext";
        // null;

    /** Tag name for Batik's regular poly extension. */
    String BATIK_EXT_REGULAR_POLYGON_TAG =
        "regularPolygon";

    /** Tag name for Batik's star extension. */
    String BATIK_EXT_STAR_TAG =
        "star";

    /** Tag name for Batik's color switch extension. */
    String BATIK_EXT_COLOR_SWITCH_TAG =
        "colorSwitch";

    /** Tag name for Batik's histogram normalization extension. */
    String BATIK_EXT_HISTOGRAM_NORMALIZATION_TAG =
        "histogramNormalization";

    /** Attribute name for sides attribute */
    String BATIK_EXT_SIDES_ATTRIBUTE =
        "sides";

    /** Attribute name for inner radius attribute */
    String BATIK_EXT_IR_ATTRIBUTE =
        "ir";

    /** Attribute name for trim percent attribute */
    String BATIK_EXT_TRIM_ATTRIBUTE =
        "trim";


    /** Tag name for Batik's flowText extension (SVG 1.2). */
    String BATIK_EXT_FLOW_TEXT_TAG =
        "flowText";

    /** Tag name for Batik's flowText extension Region element (SVG 1.2). */
    String BATIK_EXT_FLOW_REGION_TAG =
        "flowRegion";

    /** Tag name for Batik's flowText extension Region element (SVG 1.2). */
    String BATIK_EXT_FLOW_REGION_EXCLUDE_TAG =
        "flowRegionExclude";

    /** Tag name for Batik's flowText extension div element SVG 1.2). */
    String BATIK_EXT_FLOW_DIV_TAG =
        "flowDiv";

    /** Tag name for Batik's flowText extension p element SVG 1.2). */
    String BATIK_EXT_FLOW_PARA_TAG =
        "flowPara";

    /** Tag name for Batik's flowText extension flow Region break
     *  element SVG 1.2). */
    String BATIK_EXT_FLOW_REGION_BREAK_TAG =
        "flowRegionBreak";

    /** Tag name for Batik's flowText extension line element SVG 1.2). */
    String BATIK_EXT_FLOW_LINE_TAG =
        "flowLine";

    /** Tag name for Batik's flowText extension span element SVG 1.2). */
    String BATIK_EXT_FLOW_SPAN_TAG =
        "flowSpan";


    /** Attribute name for x attribute */
    String BATIK_EXT_X_ATTRIBUTE =
        "x";
    /** Attribute name for y attribute */
    String BATIK_EXT_Y_ATTRIBUTE =
        "y";
    /** Attribute name for width attribute */
    String BATIK_EXT_WIDTH_ATTRIBUTE =
        "width";
    /** Attribute name for height attribute */
    String BATIK_EXT_HEIGHT_ATTRIBUTE =
        "height";

    /** Attribute name for margin psudo-attribute */
    String BATIK_EXT_MARGIN_ATTRIBUTE =
        "margin";
    /** Attribute name for top-margin attribute */
    String BATIK_EXT_TOP_MARGIN_ATTRIBUTE =
        "top-margin";
    /** Attribute name for right-margin attribute */
    String BATIK_EXT_RIGHT_MARGIN_ATTRIBUTE =
        "right-margin";
    /** Attribute name for bottom-margin attribute */
    String BATIK_EXT_BOTTOM_MARGIN_ATTRIBUTE =
        "bottom-margin";
    /** Attribute name for left-margin attribute */
    String BATIK_EXT_LEFT_MARGIN_ATTRIBUTE =
        "left-margin";
    /** Attribute name for indent attribute/property */
    String BATIK_EXT_INDENT_ATTRIBUTE =
        "indent";
    /** Attribute name for justification */
    String BATIK_EXT_JUSTIFICATION_ATTRIBUTE =
        "justification";
    /** Value for justification to start of region */
    String BATIK_EXT_JUSTIFICATION_START_VALUE  = "start";
    /** Value for justification to middle of region */
    String BATIK_EXT_JUSTIFICATION_MIDDLE_VALUE = "middle";
    /** Value for justification to end of region */
    String BATIK_EXT_JUSTIFICATION_END_VALUE    = "end";
    /** Value for justification to both edges of region */
    String BATIK_EXT_JUSTIFICATION_FULL_VALUE = "full";


    /** Attribute name for preformated data */
    String BATIK_EXT_PREFORMATTED_ATTRIBUTE =
        "preformatted";

   /** Attribute name for preformated data */
   String BATIK_EXT_VERTICAL_ALIGN_ATTRIBUTE =
        "vertical-align";

    /** Value for vertical-align to top of region */
    String BATIK_EXT_ALIGN_TOP_VALUE    = "top";
    /** Value for vertical-align to middle of region */
    String BATIK_EXT_ALIGN_MIDDLE_VALUE = "middle";
    /** Value for vertical-align to bottom of region */
    String BATIK_EXT_ALIGN_BOTTOM_VALUE = "bottom";

}







