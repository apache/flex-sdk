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
 * This interface defines constants for CSS with SVG12.
 * Important: Constants must not contain uppercase characters.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: SVG12CSSConstants.java 478169 2006-11-22 14:23:24Z dvholten $
 */
public interface SVG12CSSConstants extends CSSConstants {

    /** Property name for margin shorthand */
    String CSS_MARGIN_PROPERTY        = "margin";
    /** Property name for top-margin */
    String CSS_MARGIN_TOP_PROPERTY    = "margin-top";
    /** Property name for right-margin */
    String CSS_MARGIN_RIGHT_PROPERTY  = "margin-right";
    /** Property name for bottom-margin */
    String CSS_MARGIN_BOTTOM_PROPERTY = "margin-bottom";
    /** Property name for left-margin */
    String CSS_MARGIN_LEFT_PROPERTY   = "margin-left";
    /** property name for indent */
    String CSS_INDENT_PROPERTY        = "indent";
    /** propery name for text-align */
    String CSS_TEXT_ALIGN_PROPERTY    = "text-align";
    /** property name for color attribute */
    String CSS_SOLID_COLOR_PROPERTY  ="solid-color";
    /** property name for opacity attribute */
    String CSS_SOLID_OPACITY_PROPERTY="solid-opacity";


    /** Value for text-align to start of text on line */
    String CSS_START_VALUE  = "start";
    /** Value for text-align to middle of text on line */
    String CSS_MIDDLE_VALUE = "middle";
    /** Value for text-align to end of region */
    String CSS_END_VALUE    = "end";
    /** Value for text-align to both edges of region */
    String CSS_FULL_VALUE = "full";
    /** Value for line-height for 'normal' line height */
    String CSS_NORMAL_VALUE = "normal";

}
