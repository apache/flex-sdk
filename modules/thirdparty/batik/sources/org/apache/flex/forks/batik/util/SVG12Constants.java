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
 * Define SVG 1.2 constants, such as tag names, attribute names and URI
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVG12Constants.java 478169 2006-11-22 14:23:24Z dvholten $
 */
public interface SVG12Constants extends SVGConstants {

    // SVG 1.2 element tag names ////////////////////////////////////////////

    /** Tag name for Batik's flowRoot extension (SVG 1.2). */
    String SVG_FLOW_ROOT_TAG =
        "flowRoot";

    /** Tag name for Batik's flowRoot extension Region element (SVG 1.2). */
    String SVG_FLOW_REGION_TAG =
        "flowRegion";

    /** Tag name for Batik's flowRoot extension Region element (SVG 1.2). */
    String SVG_FLOW_REGION_EXCLUDE_TAG =
        "flowRegionExclude";

    /** Tag name for Batik's flowRoot extension div element SVG 1.2). */
    String SVG_FLOW_DIV_TAG =
        "flowDiv";

    /** Tag name for Batik's flowRoot extension p element SVG 1.2). */
    String SVG_FLOW_PARA_TAG =
        "flowPara";

    /** Tag name for Batik's flowRoot extension flow Region break
     *  element SVG 1.2). */
    String SVG_FLOW_REGION_BREAK_TAG =
        "flowRegionBreak";

    /** Tag name for Batik's flowRoot extension line element SVG 1.2). */
    String SVG_FLOW_LINE_TAG =
        "flowLine";

    /** Tag name for Batik's flowRoot extension span element SVG 1.2). */
    String SVG_FLOW_SPAN_TAG =
        "flowSpan";

    /** SVG 1.2 'handler' element tag name. */
    String SVG_HANDLER_TAG =
        "handler";

    /** Tag name for Batik's multiImage extension. */
    String SVG_MULTI_IMAGE_TAG =
        "multiImage";

    /** Tag name for Batik's solid color extension (SVG 1.2). */
    String SVG_SOLID_COLOR_TAG =
        "solidColor";

    /** Tag name for Batik's subImage multiImage extension. */
    String SVG_SUB_IMAGE_TAG =
        "subImage";

    /** Tag name for Batik's subImageRef multiImage extension. */
    String SVG_SUB_IMAGE_REF_TAG =
        "subImageRef";

    // SVG 1.2 attribute names ///////////////////////////////////////////////

    /** Attribute name for filterPrimitiveMarginsUnits */
    String SVG_FILTER_PRIMITIVE_MARGINS_UNITS_ATTRIBUTE =
        "filterPrimitiveMarginsUnits";

    /** Attribute name for filterMarginsUnits */
    String SVG_FILTER_MARGINS_UNITS_ATTRIBUTE =
        "filterMarginsUnits";

    /** Attribute name for pixel-height attribute */
    String SVG_MAX_PIXEL_SIZE_ATTRIBUTE =
        "max-pixel-size";

    /** Attribute name for pixel-width attribute */
    String SVG_MIN_PIXEL_SIZE_ATTRIBUTE =
        "min-pixel-size";

    /** Attribute name for filter mx attribute */
    String SVG_MX_ATRIBUTE =
        "mx";

    /** Attribute name for filter my attribute */
    String SVG_MY_ATRIBUTE =
        "my";

    /** Attribute name for filter mw attribute */
    String SVG_MW_ATRIBUTE =
        "mw";

    /** Attribute name for filter mh attribute */
    String SVG_MH_ATRIBUTE =
        "mh";

    // SVG 1.2 attribute default values //////////////////////////////////////

    /** Default value for filter mx */
    String SVG_FILTER_MX_DEFAULT_VALUE = "0";

    /** Default value for filter my */
    String SVG_FILTER_MY_DEFAULT_VALUE = "0";

    /** Default value for filter mw */
    String SVG_FILTER_MW_DEFAULT_VALUE = "0";

    /** Default value for filter mh */
    String SVG_FILTER_MH_DEFAULT_VALUE = "0";
}
