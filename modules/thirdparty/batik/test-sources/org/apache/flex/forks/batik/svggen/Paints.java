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
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.TexturePaint;
import java.awt.image.BufferedImage;

/**
 * This test validates the convertion of Java 2D paints
 * into an SVG attributes.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Paints.java,v 1.4 2004/08/18 07:16:45 vhardy Exp $
 */
public class Paints implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        // Get default paint for painting text
        Paint defaultPaint = Color.black;
        g.setPaint(defaultPaint);

        g.translate(0, 30);

        // Define the rectangle that will be drawn multiple
        // times
        Rectangle rect = new Rectangle(10, 20, 100, 60);

        // First, test plain color with transparency
        Color fillColor = new Color(255, 255, 0, 128);
        g.drawString("Semi transparent black", 10, 10);
        g.drawString("Behind Rectangle", 40, 60);
        g.setPaint(fillColor);
        g.fill(rect);

        g.translate(0, 90);

        // Now, test linear gradient
        GradientPaint fillGradient = new GradientPaint(10, 20, Color.red,
                                                       110, 80, Color.yellow);
        g.setPaint(defaultPaint);
        g.drawString("Red to Yellow linear gradient", 10, 10);
        g.setPaint(fillGradient);
        g.fill(rect);

        g.translate(0, 90);

        // Now, test texture paint
        BufferedImage buf = new BufferedImage(20, 20, BufferedImage.TYPE_INT_RGB);
        Graphics2D bg = buf.createGraphics();
        bg.setPaint(Color.red);
        bg.fillRect(0, 0, 10, 10);
        bg.setPaint(Color.yellow);
        bg.fillRect(10, 10, 10, 10);
        bg.dispose();
        TexturePaint fillTexture = new TexturePaint(buf, new Rectangle(10, 20, 20, 20));
        g.setPaint(defaultPaint);
        g.drawString("Texture Paint", 10, 10);
        g.setPaint(fillTexture);
        g.fill(rect);
    }
}
