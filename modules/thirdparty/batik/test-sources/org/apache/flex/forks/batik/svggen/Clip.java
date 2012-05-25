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
 * This test validates convertion of Java 2D clip inot SVG clipPath
 * definition and attributes.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Clip.java,v 1.3 2004/08/18 07:16:44 vhardy Exp $
 */
public class Clip implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        // Save original clip
        Shape clipShape = g.getClip();
        java.awt.geom.AffineTransform transform = g.getTransform();

        g.setPaint(Color.black);

        Dimension size = new Dimension(300, 400);
        int w=100, h=50;
        int vOffset = h + 20;
        BufferedImage image = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
        Graphics2D gi = image.createGraphics();
        gi.setPaint(Color.white);
        gi.fillRect(0, 0, 100, 50);
        gi.setPaint(Color.green);
        gi.fillRect(0, 0, 50, 25);
        gi.setPaint(Color.black);
        gi.fillRect(50, 0, 50, 25);
        gi.setPaint(Color.red);
        gi.fillRect(50, 25, 50, 25);
        gi.dispose();

        // Set simple clip : does not modify the output
        g.clipRect(0, 0, size.width, size.height);
        g.drawImage(image, 0, 0, null);
        g.setClip(clipShape);

        g.drawString("Clip set to device bounds", 110, 25);

        g.translate(0, vOffset);

        // Intersect current clip with a smaller clip : show only
        // the top right corner of the image
        g.drawString("Clip set to upper right quarter", 110, 25);

        g.clipRect(w/2, 0, w/2, h/2);
        g.drawImage(image, 0, 0, null);

        // Restore
        g.setTransform(transform);
        g.setClip(clipShape);
        g.translate(0, 2*vOffset);

        // Scale before setting the same clip
        g.drawString("Clip set to upper right quarter", 110, 15);
        g.drawString("after .5 scale", 110, 30);
        g.scale(.5, .5);
        g.clipRect(w/2, 0, w/2, h/2);
        g.drawImage(image, 0, 0, null);

        // Restore
        g.setTransform(transform);
        g.setClip(clipShape);

        g.translate(0, 3*vOffset);

        // Use a non-rectangle clipping area
        g.drawString("Non-Rectagular clip", 110, 25);
        Shape circle = new Ellipse2D.Float(0, 0, w, h);
        g.clip(circle);
        g.drawImage(image, 0, 0, null);

        // Restore
        g.setTransform(transform);
        g.setClip(clipShape);

        g.translate(0, 4*vOffset);

        // Use a non-rectangle clipping area again,
        // after setting a scale transform
        g.drawString("Non-Rectagular clip after", 110, 15);
        g.drawString(".5 scale", 110, 30);
        g.scale(.5, .5);
        g.clip(circle);
        g.drawImage(image, 0, 0, null);

        // Restore
        g.setTransform(transform);
        g.setClip(clipShape);
        g.translate(0, 5*vOffset);

        // Use a non-rectangle clipping area again,
        // before setting a scale transform
        g.drawString("Non-Rectagular clip before", 110, 15);
        g.drawString(".5 scale", 110, 30);
        g.clip(circle);
        g.scale(.5, .5);
        g.drawImage(image, 0, 0, null);
    }
}
