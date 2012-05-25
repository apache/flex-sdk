/*

   Copyright 2001-2002  The Apache Software Foundation 

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
 * This test validates the convertion of Java 2D negative length values:<br />
 * - On rectangles: a negative width or height makes the rectangle invisible.<br />
 * - On rounded rectangles: a negative width or height makes the rectangle invisible.<br />
 * - On ellipses: a negative width or height makes the ellipse invisible<br />
 * - On 3D rect: a negative width *and* height makes the rectangle invisible. A
 *               negative width or height makes the rectangle display as a line.<br />
 * The above behavior is that of the default Graphics2D implementations.
 *
 * @author <a href="mailto:vhardy@sun.com">Vincent Hardy</a>
 * @version $Id: NegativeLengths.java,v 1.5 2004/08/18 07:16:45 vhardy Exp $
 */
public class NegativeLengths implements Painter {
    public void paint(Graphics2D g){
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, 
                           RenderingHints.VALUE_ANTIALIAS_ON);

        g.setPaint(Color.black);

        // Rectangle
        g.drawString("Rectangle", 10, 20);

        // w negative, h negative
        Rectangle rect = new Rectangle(10, 30, -10, -8);
        g.draw(rect);

        // w negative, h zero
        rect = new Rectangle(30, 30, -10, 0);
        g.draw(rect);

        // w negative, h positive
        rect = new Rectangle(50, 30, -10, 8);
        g.draw(rect);

        // w zero, h negative
        rect = new Rectangle(70, 30, 0, -8);
        g.draw(rect);    

        // w zero, h zero
        rect = new Rectangle(90, 30, 0, 0);
        g.draw(rect);    

        // w zero, h positive
        rect = new Rectangle(110, 30, 0, 8);
        g.draw(rect);    

        // w positive, h negative
        rect = new Rectangle(130, 30, 10, -8);
        g.draw(rect);    

        // w positive, h zero
        rect = new Rectangle(150, 30, 5, 0);
        g.draw(rect);    

        // w positive, h positive
        rect = new Rectangle(170, 30, 5, 8);
        g.draw(rect);    


        g.translate(0, 35);
        
        //
        // Round Rectangle
        //
        g.drawString("RoundRectangle2D", 10, 20);

        // w negative, h negative
        RoundRectangle2D rrect = new RoundRectangle2D.Double(10, 30, -10, -8, 2, 2);
        g.draw(rrect);

        // w negative, h zero
        rrect = new RoundRectangle2D.Double(30, 30, -10, 0, 2, 2);
        g.draw(rrect);

        // w negative, h positive
        rrect = new RoundRectangle2D.Double(50, 30, -10, 8, 2, 2);
        g.draw(rrect);

        // w zero, h negative
        rrect = new RoundRectangle2D.Double(70, 30, 0, -8, 2, 2);
        g.draw(rrect);    

        // w zero, h zero
        rrect = new RoundRectangle2D.Double(90, 30, 0, 0, 2, 2);
        g.draw(rrect);    

        // w zero, h positive
        rrect = new RoundRectangle2D.Double(110, 30, 0, 8, 2, 2);
        g.draw(rrect);    

        // w positive, h negative
        rrect = new RoundRectangle2D.Double(130, 30, 5, -8, 2, 2);
        g.draw(rrect);    

        // w positive, h zero
        rrect = new RoundRectangle2D.Double(150, 30, 5, 0, 2, 2);
        g.draw(rrect);    

        // w positive, h positive
        rrect = new RoundRectangle2D.Double(170, 30, 5, 8, 2, 2);
        g.draw(rrect);    


        g.translate(0, 35);

        //
        // Round Rectangle 2
        //
        g.drawString("RoundRectangle2D, negative radius", 10, 20);

        // w negative, h negative
        rrect = new RoundRectangle2D.Double(10, 30, -10, -8, -2, -2);
        g.draw(rrect);

        // w negative, h zero
        rrect = new RoundRectangle2D.Double(30, 30, -10, 0, -2, -2);
        g.draw(rrect);

        // w negative, h positive
        rrect = new RoundRectangle2D.Double(50, 30, -10, 8, -2, -2);
        g.draw(rrect);

        // w zero, h negative
        rrect = new RoundRectangle2D.Double(70, 30, 0, -8, -2, -2);
        g.draw(rrect);    

        // w zero, h zero
        rrect = new RoundRectangle2D.Double(90, 30, 0, 0, -2, -2);
        g.draw(rrect);    

        // w zero, h positive
        rrect = new RoundRectangle2D.Double(110, 30, 0, 8, -2, -2);
        g.draw(rrect);    

        // w positive, h negative
        rrect = new RoundRectangle2D.Double(130, 30, 5, -8, -2, -2);
        g.draw(rrect);    

        // w positive, h zero
        rrect = new RoundRectangle2D.Double(150, 30, 5, 0, -2, -2);
        g.draw(rrect);    

        // w positive, h positive
        rrect = new RoundRectangle2D.Double(170, 30, 5, 8, -2, -2);
        g.draw(rrect);    
        
        g.translate(0, 35);

        //
        // Circle
        //
        g.drawString("Circle", 10, 20);

        // w negative
        Ellipse2D circle = new Ellipse2D.Double(10, 30, -10, -10);
        g.draw(circle);

        // w zero, h negative
        circle = new Ellipse2D.Double(30, 30, 0, 0);
        g.draw(circle);    

        // w positive, h negative
        circle = new Ellipse2D.Double(50, 30, 5, 5);
        g.draw(circle);    

        g.translate(0, 35);

        //
        // Ellipse
        //
        g.drawString("Ellipse", 10, 20);

        // w negative, h negative
        Ellipse2D ellipse = new Ellipse2D.Double(10, 30, -10, -8);
        g.draw(ellipse);

        // w negative, h zero
        ellipse = new Ellipse2D.Double(30, 30, -10, 0);
        g.draw(ellipse);

        // w negative, h positive
        ellipse = new Ellipse2D.Double(50, 30, -10, 8);
        g.draw(ellipse);

        // w zero, h negative
        ellipse = new Ellipse2D.Double(70, 30, 0, -8);
        g.draw(ellipse);    

        // w zero, h zero
        ellipse = new Ellipse2D.Double(90, 30, 0, 0);
        g.draw(ellipse);    

        // w zero, h positive
        ellipse = new Ellipse2D.Double(110, 30, 0, 8);
        g.draw(ellipse);    

        // w positive, h negative
        ellipse = new Ellipse2D.Double(130, 30, 5, -8);
        g.draw(ellipse);    

        // w positive, h zero
        ellipse = new Ellipse2D.Double(150, 30, 5, 0);
        g.draw(ellipse);    

        // w positive, h positive
        ellipse = new Ellipse2D.Double(170, 30, 5, 8);
        g.draw(ellipse);    


        g.translate(0, 35);

        // 3D Rect
        g.drawString("fill3Drect", 10, 20);

        // w negative, h negative
        g.setColor(new Color(192, 192, 192));
        g.fill3DRect(10, 30, -10, -8, true);

        // w negative, h zero
        g.fill3DRect(30, 30, -10, 0, true);

        // w negative, h positive
        g.fill3DRect(50, 30, -10, 8, true);

        // w zero, h negative
        g.fill3DRect(70, 30, 0, -8, true);    

        // w zero, h zero
        g.fill3DRect(90, 30, 0, 0, true);    

        // w zero, h positive
        g.fill3DRect(110, 30, 0, 8, true);    

        // w positive, h negative
        g.fill3DRect(130, 30, 5, -8, true);    
        
        // w positive, h zero
        g.fill3DRect(150, 30, 5, 0, true);    
        
        // w positive, h positive
        g.fill3DRect(170, 30, 5, 8, true);    

        g.translate(0, 40);

        // Clip
        rect = new Rectangle(10, 30, 10, -30);
        g.setPaint(Color.gray);
        g.fill(rect);
        g.setPaint(Color.black);
        g.clip(rect);
        g.drawString("Hello There", 10, 25);
    }
}


