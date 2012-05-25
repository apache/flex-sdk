/*

   Copyright 2001,2003  The Apache Software Foundation 

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

import java.awt.Graphics2D;
import java.awt.Font;
import java.awt.geom.AffineTransform;

/**
 * This test validates fix to Bug #4945 which checks that 
 * the generator handles Font transform.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: Bug4945.java,v 1.4 2004/08/18 07:16:44 vhardy Exp $
 */
public class Bug4945 implements Painter {
    public void paint(Graphics2D g){
        Font origFont = g.getFont(); 

        g.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING,
                           java.awt.RenderingHints.VALUE_ANTIALIAS_ON);
       
        // 1) create scaled font
        Font font = origFont.deriveFont(AffineTransform.getScaleInstance(1.5, 3));
        g.setFont(font);
        g.drawString("Scaled Font", 20, 40);

        // 2) create translated font
        font = origFont.deriveFont(AffineTransform.getTranslateInstance(50, 20));
        g.setFont(font);
        g.drawString("Translated Font", 20, 80);
        g.drawLine(20, 80, 120, 80);

        // 3) create sheared font
        font = origFont.deriveFont(AffineTransform.getShearInstance(.5, .5));
        g.setFont(font);
        g.drawString("Sheared Font", 20, 120);

        // 4) create rotated font 
        font = origFont.deriveFont(AffineTransform.getRotateInstance(Math.PI/4));
        g.setFont(font);
        g.drawString("Rotated Font", 220, 120);
    }
}

