/*

   Copyright 2004 The Apache Software Foundation 

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
 * This interface defines constants for CSS with SVG12.
 * Important: Constants must not contain uppercase characters.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: SVG12CSSConstants.java,v 1.2 2005/03/27 08:58:36 cam Exp $
 */
public interface SVG12CSSConstants extends CSSConstants {

    /** Property name for margin shorthand */
    public static final String CSS_MARGIN_PROPERTY        = "margin";
    /** Property name for top-margin */
    public static final String CSS_MARGIN_TOP_PROPERTY    = "margin-top";
    /** Property name for right-margin */
    public static final String CSS_MARGIN_RIGHT_PROPERTY  = "margin-right";
    /** Property name for bottom-margin */
    public static final String CSS_MARGIN_BOTTOM_PROPERTY = "margin-bottom";
    /** Property name for left-margin */
    public static final String CSS_MARGIN_LEFT_PROPERTY   = "margin-left";
    /** property name for indent */
    public static final String CSS_INDENT_PROPERTY        = "indent";
    /** propery name for text-align */
    public static final String CSS_TEXT_ALIGN_PROPERTY    = "text-align";
    /** property name for color attribute */
    public static final String CSS_SOLID_COLOR_PROPERTY  ="solid-color";
    /** property name for opacity attribute */
    public static final String CSS_SOLID_OPACITY_PROPERTY="solid-opacity";


    /** Value for text-align to start of text on line */
    public static final String CSS_START_VALUE  = "start";
    /** Value for text-align to middle of text on line */
    public static final String CSS_MIDDLE_VALUE = "middle";
    /** Value for text-align to end of region */
    public static final String CSS_END_VALUE    = "end";
    /** Value for text-align to both edges of region */
    public static final String CSS_FULL_VALUE = "full";
    /** Value for line-height for 'normal' line height */
    public static final String CSS_NORMAL_VALUE = "normal";

};

