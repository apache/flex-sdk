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

package org.apache.flex.forks.batik.gvt.flow;

import java.awt.font.FontRenderContext;
import java.awt.geom.Point2D;
import java.text.AttributedCharacterIterator;

import org.apache.flex.forks.batik.gvt.text.GlyphLayout;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: FlowGlyphLayout.java 475477 2006-11-15 22:44:28Z cam $
 */
public class FlowGlyphLayout extends GlyphLayout {

    public static final char SOFT_HYPHEN       = 0x00AD;
    public static final char ZERO_WIDTH_SPACE  = 0x200B;
    public static final char ZERO_WIDTH_JOINER = 0x200D;
    public static final char SPACE             = ' ';


    public FlowGlyphLayout(AttributedCharacterIterator aci,
                           int [] charMap,
                           Point2D offset,
                           FontRenderContext frc) {
        super(aci, charMap, offset, frc);
    }


}
