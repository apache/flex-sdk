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

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;

/**
 * This test validates the convertion of Java 2D AffineTransform into SVG
 * Shapes.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ATransform.java,v 1.4 2004/08/18 07:16:43 vhardy Exp $
 */
public class ATransform implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        g.setPaint(Color.black); // new Color(102, 102, 144));

        int legendX = 10, legendY = 12;
        g.translate(0, 30);

        java.awt.geom.AffineTransform defaultTransform = g.getTransform();

        // Define rectangle
        Rectangle rect = new Rectangle(10, 20, 50, 30);

        // Paint with default transform
        g.drawString("Default transform", legendX, legendY);
        g.fill(rect);

        // Paint after translate
        g.translate(0, 90);
        g.drawString("Translate applied", legendX, legendY);
        g.fill(rect);

        // Rotate rectangle about its center
        g.translate(0, 90);
        g.rotate(Math.PI/2, 35, 35);
        g.drawString("Rotate about center", legendX, legendY);
        g.fill(rect);

        // Restore default transform
        g.setTransform(defaultTransform);

        // Paint after scale
        g.translate(150, 0);
        g.drawString("Scale (sx=2, sy=1)", legendX, legendY);
        g.scale(2, 1);
        g.fill(rect);

        // Paint after shear
        g.setTransform(defaultTransform);
        g.translate(150, 90);
        g.drawString("Shear", legendX, legendY);
        g.shear(.2, 1);
        g.fill(rect);

        java.awt.geom.AffineTransform txf = g.getTransform();
        g.setTransform(new java.awt.geom.AffineTransform());
        Shape shearBounds = txf.createTransformedShape(rect).getBounds();
        g.setPaint(new Color(0, 0, 0, 128));
        g.fill(shearBounds);
    }
}
