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
package org.apache.flex.forks.batik.gvt.renderer;

import java.awt.Graphics2D;
import java.awt.font.TextLayout;
import java.awt.geom.Point2D;
import java.text.AttributedCharacterIterator;

import org.apache.flex.forks.batik.gvt.TextNode;

/**
 * Renders the attributed character iterator of a <tt>TextNode</tt>.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ConcreteTextPainter.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class ConcreteTextPainter extends BasicTextPainter {

    /**
     * Paints the specified attributed character iterator using the
     * specified Graphics2D and context and font context.
     * @param aci the AttributedCharacterIterator containing the text
     * @param location the location to paint the text
     * @param anchor the text anchor position
     * @param g2d the Graphics2D to use
     */
    public void paint(AttributedCharacterIterator aci, Point2D location, 
                      TextNode.Anchor anchor, Graphics2D g2d) {
        // Compute aci size to be able to draw it
        TextLayout layout = new TextLayout(aci, fontRenderContext);
        float advance = layout.getAdvance();
        float tx = 0;

        switch(anchor.getType()){
        case TextNode.Anchor.ANCHOR_MIDDLE:
            tx = -advance/2;
            break;
        case TextNode.Anchor.ANCHOR_END:
            tx = -advance;
        }
        layout.draw(g2d, (float)(location.getX() + tx), (float)(location.getY()));
    }

}
