/*

   Copyright 2000-2004  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.util;

/**
 * Define SVG 1.2 constants, such as tag names, attribute names and URI
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVG12Constants.java,v 1.2 2005/03/27 08:58:36 cam Exp $
 */
public interface SVG12Constants extends SVGConstants {

    /** Tag name for Batik's flowRoot extension (SVG 1.2). */
    public static final String SVG_FLOW_ROOT_TAG = 
        "flowRoot";

    /** Tag name for Batik's flowRoot extension Region element (SVG 1.2). */
    public static final String SVG_FLOW_REGION_TAG = 
        "flowRegion";

    /** Tag name for Batik's flowRoot extension Region element (SVG 1.2). */
    public static final String SVG_FLOW_REGION_EXCLUDE_TAG = 
        "flowRegionExclude";

    /** Tag name for Batik's flowRoot extension div element SVG 1.2). */
    public static final String SVG_FLOW_DIV_TAG = 
        "flowDiv";

    /** Tag name for Batik's flowRoot extension p element SVG 1.2). */
    public static final String SVG_FLOW_PARA_TAG = 
        "flowPara";

    /** Tag name for Batik's flowRoot extension flow Region break 
     *  element SVG 1.2). */
    public static final String SVG_FLOW_REGION_BREAK_TAG = 
        "flowRegionBreak";

    /** Tag name for Batik's flowRoot extension line element SVG 1.2). */
    public static final String SVG_FLOW_LINE_TAG = 
        "flowLine";

    /** Tag name for Batik's flowRoot extension span element SVG 1.2). */
    public static final String SVG_FLOW_SPAN_TAG = 
        "flowSpan";

    /** Tag name for Batik's solid color extension (SVG 1.2). */
    public static final String SVG_SOLID_COLOR_TAG = 
        "solidColor";

    /** Tag name for Batik's multiImage extension. */
    public static final String SVG_MULTI_IMAGE_TAG =
        "multiImage";

    /** Tag name for Batik's subImage multiImage extension. */
    public static final String SVG_SUB_IMAGE_TAG =
        "subImage";
    /** Tag name for Batik's subImageRef multiImage extension. */
    public static final String SVG_SUB_IMAGE_REF_TAG =
        "subImageRef";

    /** Attribute name for pixel-width attribute */
    public static final String SVG_MIN_PIXEL_SIZE_ATTRIBUTE = 
        "min-pixel-size";

    /** Attribute name for pixel-height attribute */
    public static final String SVG_MAX_PIXEL_SIZE_ATTRIBUTE = 
        "max-pixel-size";


    /** Attribute name for filter mx attribute */
    public static final String SVG_MX_ATRIBUTE =
        "mx";
    
    /** Attribute name for filter my attribute */
    public static final String SVG_MY_ATRIBUTE =
        "my";
    
    /** Attribute name for filter mw attribute */
    public static final String SVG_MW_ATRIBUTE =
        "mw";
    
    /** Attribute name for filter mh attribute */
    public static final String SVG_MH_ATRIBUTE =
        "mh";

    /** Attribute name for filterPrimitiveMarginsUnits */
    public static final String SVG_FILTER_PRIMITIVE_MARGINS_UNITS_ATTRIBUTE
        = "filterPrimitiveMarginsUnits";

    /** Attribute name for filterMarginsUnits */
    public static final String SVG_FILTER_MARGINS_UNITS_ATTRIBUTE
        = "filterMarginsUnits";

    /** Default value for filter mx */
    public static final String SVG_FILTER_MX_DEFAULT_VALUE = "0";

    /** Default value for filter my */
    public static final String SVG_FILTER_MY_DEFAULT_VALUE = "0";

    /** Default value for filter mw */
    public static final String SVG_FILTER_MW_DEFAULT_VALUE = "0";

    /** Default value for filter mh */
    public static final String SVG_FILTER_MH_DEFAULT_VALUE = "0";
}
