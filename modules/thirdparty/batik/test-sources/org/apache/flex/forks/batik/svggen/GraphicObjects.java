/*

   Copyright 2001  The Apache Software Foundation 

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

import java.awt.*;
import java.awt.geom.*;
import java.awt.image.*;

/**
 * This test validates the convertion of the three elementary
 * thypes of Java 2D API graphic objects: shapes, text and
 * images
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GraphicObjects.java,v 1.6 2004/08/18 07:16:44 vhardy Exp $
 */
public class GraphicObjects implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        // Text
        g.setPaint(Color.black);
        g.setFont(new Font("Times New Roman", Font.PLAIN, 20));
        g.drawString("Hello SVG drawString(...)", 20, 40);

        g.translate(0, 70);

        // Shapes
        Ellipse2D ellipse = new Ellipse2D.Float(20, 0, 60, 60);
        g.setPaint(new Color(176, 22, 40));
        g.fill(ellipse);
        g.translate(60, 0);
        g.setPaint(new Color(208, 170, 119));
        g.fill(ellipse);
        g.translate(60, 0);
        g.setPaint(new Color(221, 229, 111));
        g.fill(ellipse);
        g.translate(60, 0);
        g.setPaint(new Color(240, 165, 0));
        g.fill(ellipse);

        g.translate(-180, 60);

        // Draw background pattern
        BufferedImage pattern = new BufferedImage(10, 10, BufferedImage.TYPE_INT_RGB);
        Graphics2D ig = pattern.createGraphics();
        ig.setPaint(Color.white);
        ig.fillRect(0, 0, 10, 10);
        ig.setPaint(new Color(0xaaaaaa));
        ig.fillRect(0, 0, 5, 5);
        ig.fillRect(5, 5, 5, 50);
        TexturePaint texture = new TexturePaint(pattern, new Rectangle(0, 0, 10, 10));

        // Image
        BufferedImage image = new BufferedImage(200, 150, BufferedImage.TYPE_INT_ARGB);
        ig = image.createGraphics();
        ig.setPaint(texture);
        ig.fillRect(0, 0, 200, 150);
        g.drawImage(image, 40, 40, null);

        image = new BufferedImage(200, 150, BufferedImage.TYPE_INT_ARGB);
        ig = image.createGraphics();
        GradientPaint paint = new GradientPaint(0, 0, new Color(103, 103, 152),
                                                        200, 150, new Color(103, 103, 152, 0));
        ig.setPaint(paint);
        ig.fillRect(0, 0, 200, 150);
        ig.setPaint(Color.black);
        ig.setFont(new Font("Arial", Font.PLAIN, 10));
        ig.drawString("This is an image with alpha", 10, 30);
        ig.dispose();

        g.drawImage(image, 40, 40, null);
    }
}
