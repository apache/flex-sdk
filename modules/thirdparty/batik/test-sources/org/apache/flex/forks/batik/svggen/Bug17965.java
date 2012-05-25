/*

   Copyright 2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.svggen;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;


/**
 * This test validates fix to Bug #17965 and checks that 
 * attributes which do not apply to given element (eg., font-family
 * does not apply to <rect>) are not written out.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: Bug17965.java,v 1.4 2004/08/18 07:16:44 vhardy Exp $
 */
public class Bug17965 implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING,
                           java.awt.RenderingHints.VALUE_ANTIALIAS_ON);

        Font font = new Font("Arial", Font.PLAIN, 30);
        g.setFont(font);
        g.setPaint(Color.blue);
        g.fillRect(0, 0, 50, 50);

        font = new Font("Helvetica", Font.PLAIN, 20);
        g.setFont(font);
        g.fillRect( 50, 50, 50, 50);
    }
}
