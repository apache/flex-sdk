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
package org.apache.flex.forks.batik.dom.svg;

/**
 * Constants for the SVGPathSeg interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGPathSegConstants.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SVGPathSegConstants {

    String PATHSEG_ARC_ABS_LETTER
        = "A";

    String PATHSEG_ARC_REL_LETTER
        = "a";

    String PATHSEG_CLOSEPATH_LETTER
        = "z";

    String PATHSEG_CURVETO_CUBIC_ABS_LETTER
        = "C";

    String PATHSEG_CURVETO_CUBIC_REL_LETTER
        = "c";

    String PATHSEG_CURVETO_CUBIC_SMOOTH_ABS_LETTER
        = "S";

    String PATHSEG_CURVETO_CUBIC_SMOOTH_REL_LETTER
        = "s";

    String PATHSEG_CURVETO_QUADRATIC_ABS_LETTER
        = "Q";

    String PATHSEG_CURVETO_QUADRATIC_REL_LETTER
        = "q";

    String PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS_LETTER
        = "T";

    String PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL_LETTER
        = "t";

    String PATHSEG_LINETO_ABS_LETTER
        = "L";

    String PATHSEG_LINETO_HORIZONTAL_ABS_LETTER
        = "H";

    String PATHSEG_LINETO_HORIZONTAL_REL_LETTER
        = "h";
        
    String PATHSEG_LINETO_REL_LETTER
        = "l";

    String PATHSEG_LINETO_VERTICAL_ABS_LETTER
        = "V";

    String PATHSEG_LINETO_VERTICAL_REL_LETTER
        = "v";

    String PATHSEG_MOVETO_ABS_LETTER
        = "M";

    String PATHSEG_MOVETO_REL_LETTER
        = "m";

    /**
     * Path segment letters.
     */
    String[] PATHSEG_LETTERS = {
        null,
        PATHSEG_CLOSEPATH_LETTER,
        PATHSEG_MOVETO_ABS_LETTER,
        PATHSEG_MOVETO_REL_LETTER,
        PATHSEG_LINETO_ABS_LETTER,
        PATHSEG_LINETO_REL_LETTER,
        PATHSEG_CURVETO_CUBIC_ABS_LETTER,
        PATHSEG_CURVETO_CUBIC_REL_LETTER,
        PATHSEG_CURVETO_QUADRATIC_ABS_LETTER,
        PATHSEG_CURVETO_QUADRATIC_REL_LETTER,
        PATHSEG_ARC_ABS_LETTER,
        PATHSEG_ARC_REL_LETTER,
        PATHSEG_LINETO_HORIZONTAL_ABS_LETTER,
        PATHSEG_LINETO_HORIZONTAL_REL_LETTER,
        PATHSEG_LINETO_VERTICAL_ABS_LETTER,
        PATHSEG_LINETO_VERTICAL_REL_LETTER,
        PATHSEG_CURVETO_CUBIC_SMOOTH_ABS_LETTER,
        PATHSEG_CURVETO_CUBIC_SMOOTH_REL_LETTER,
        PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS_LETTER,
        PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL_LETTER,
    };
}
