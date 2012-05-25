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

/**
 * This test validates the convertion of Java 2D GradientPaints
 * into SVG linearGradient definition and reference.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Gradient.java,v 1.3 2004/08/18 07:16:44 vhardy Exp $
 */
public class Gradient implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        java.awt.geom.AffineTransform defaultTransform = g.getTransform();
        Color labelColor = Color.black;

        //
        // First, define cross hair marker
        //
        GeneralPath crossHair = new GeneralPath();
        crossHair.moveTo(-5, 0);
        crossHair.lineTo(5, 0);
        crossHair.moveTo(0, -5);
        crossHair.lineTo(0, 5);

        //
        // Simple test checking color values and start
        // and end points
        //
        java.awt.GradientPaint gradient = new java.awt.GradientPaint(30, 40, Color.red,
                                                   30, 120, Color.yellow);
        g.setPaint(labelColor);
        g.drawString("Simple vertical gradient", 10, 20);
        g.setPaint(gradient);
        g.fillRect(10, 30, 100, 100);
        g.setPaint(labelColor);
        g.translate(30, 40);
        g.draw(crossHair);
        g.setTransform(defaultTransform);
        g.translate(30, 120);
        g.draw(crossHair);

        g.setTransform(defaultTransform);
        g.translate(0, 140);

        //
        // Now, test cycling behavior
        //
        java.awt.GradientPaint nonCyclicGradient = new java.awt.GradientPaint(0, 0, Color.red,
                                                            20, 0, Color.yellow);
        java.awt.GradientPaint cyclicGradient = new java.awt.GradientPaint(0, 0, Color.red,
                                                         20, 0, Color.yellow, true);

        g.setPaint(labelColor);
        g.drawString("Non Cyclic / Cyclic Gradients", 10, 20);

        g.translate(10, 30);

        g.setPaint(nonCyclicGradient);
        g.fillRect(0, 0, 100, 30);

        g.translate(0, 30);
        g.setPaint(cyclicGradient);
        g.fillRect(0, 0, 100, 30);

        g.setPaint(labelColor);
        g.drawLine(0, 0, 100, 0);

        g.setTransform(defaultTransform);
        g.translate(0, 240);

        //
        // Now, test transformations
        //
        g.setPaint(labelColor);
        g.drawString("Sheared GradientPaint", 10, 20);
        g.translate(10, 25);

        java.awt.GradientPaint shearedGradient = new java.awt.GradientPaint(0, 0, Color.red,
                                                          100, 0, Color.yellow);
        g.setPaint(shearedGradient);
        g.shear(0.5, 0);

        g.fillRect(0, 0, 100, 40);

        g.setTransform(defaultTransform);
        g.translate(0, 320);

        g.setPaint(labelColor);
        g.drawString("Opacity in stop color", 10, 20);

        java.awt.GradientPaint transparentGradient = new java.awt.GradientPaint(10, 30, new Color(255, 0, 0, 0),
                                                                                110, 30, Color.yellow);

        g.setPaint(transparentGradient);
        g.fillRect(10, 30, 100, 30);
    }
}
