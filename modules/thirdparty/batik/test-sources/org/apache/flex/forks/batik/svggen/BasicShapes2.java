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
 * This test validates the convertion of Java 2D shapes into SVG
 * Shapes.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: BasicShapes2.java,v 1.3 2004/08/18 07:16:43 vhardy Exp $
 */
public class BasicShapes2 implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        g.setPaint(Color.black);

        // Arc2D
        g.drawString("Arc2D", 10, 20);
        Arc2D arc = new Arc2D.Float(10, 30, 50, 40, 0, 270, Arc2D.PIE);
        g.draw(arc);

        g.translate(0, 90);

        // Ellipse
        g.drawString("Ellipse", 10, 20);
        Ellipse2D ellipse = new Ellipse2D.Double(10, 30, 100, 40);
        g.draw(ellipse);

        g.translate(150, -90);

        // GeneralPath lineTo
        g.drawString("GeneralPath, lineTo", 10, 20);
        GeneralPath lineToPath = new GeneralPath();
        lineToPath.moveTo(10, 30);
        lineToPath.lineTo(60, 30);
        lineToPath.lineTo(60, 70);
        lineToPath.lineTo(10, 30);
        lineToPath.closePath();
        g.draw(lineToPath);

        g.translate(0, 90);

        // GeneralPath curveTo
        g.drawString("GeneralPath, curveTo", 10, 20);
        GeneralPath curveToPath = new GeneralPath();
        curveToPath.moveTo(10, 30);
        curveToPath.curveTo(35, 10, 35, 50, 60, 30);
        curveToPath.curveTo(80, 55, 40, 55, 60, 80);
        curveToPath.curveTo(35, 60, 35, 100, 10, 80);
        curveToPath.curveTo(-10, 55, 30, 55, 10, 30);
        curveToPath.closePath();
        g.draw(curveToPath);
    }
}
