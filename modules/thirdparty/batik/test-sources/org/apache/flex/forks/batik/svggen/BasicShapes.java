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
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: BasicShapes.java,v 1.3 2004/08/18 07:16:43 vhardy Exp $
 */
public class BasicShapes implements Painter {
    public void paint(Graphics2D g){
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, 
                           RenderingHints.VALUE_ANTIALIAS_ON);

        g.setPaint(Color.black);

    // Rectangle
        g.drawString("Rectangle", 10, 20);
        Rectangle rect = new Rectangle(10, 30, 50, 40);
        g.draw(rect);
    
        g.translate(0, 90);

    // Round Rectangle
        g.drawString("RoundRectangle", 10, 20);
        RoundRectangle2D roundRect = new RoundRectangle2D.Double(10, 30, 50, 40, 10, 10);
        g.draw(roundRect);

        g.translate(0, 90);

    // Circle
        g.drawString("Circle", 10, 20);
        Ellipse2D circle = new Ellipse2D.Float(10, 30, 50, 50);
        g.draw(circle);

        g.translate(0, 90);

    // CubicCurve2D
        g.drawString("CubicCurve2D", 10, 20);
        CubicCurve2D curve = new CubicCurve2D.Float(10, 55, 22.5f, 00, 38.5f, 110, 60, 55);
        g.draw(curve);

        g.translate(150, -270);

    // Polygon
        g.drawString("Polygon", 10, 20);
        Polygon polygon = new Polygon(new int[] { 30, 50, 10 },
                                      new int[] { 30, 60, 60 },
                                      3);
        g.draw(polygon);

        g.translate(0, 90);

        // General Path
        g.drawString("GeneralPath", 10, 20);
        GeneralPath path = new GeneralPath();
        path.moveTo(30, 30);
        path.quadTo(30, 50, 50, 60);
        path.quadTo(30, 50, 10, 60);
        path.quadTo(30, 50, 30, 30);
        path.closePath();
        g.draw(path);

        g.translate(0, 90);
    
        // Area
        g.drawString("Area", 10, 20);
        Area area = new Area(new Rectangle(10, 30, 50, 50));
        area.subtract(new Area(new Ellipse2D.Double(12, 32, 46, 46)));
        g.fill(area);

        g.translate(0, 90);
    
        // QuadCurve 2D
        g.drawString("QuadCurve2D", 10, 20);
        QuadCurve2D quad = new QuadCurve2D.Float(10, 55, 35, 105, 60, 55);
        g.draw(quad);

        g.translate(-75, 70);
  
    // Line
        g.drawString("Line2D", 10, 20);
        g.draw(new Line2D.Float(10, 30, 60, 30));
    }
}
