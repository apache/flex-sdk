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
 * This test validates drawImage conversions.
 *
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: DrawImage.java,v 1.4 2004/08/18 07:16:44 vhardy Exp $
 */
public class DrawImage implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        // Create an Image
        BufferedImage image = new BufferedImage(100, 75, BufferedImage.TYPE_INT_ARGB);
        Graphics2D ig = image.createGraphics();
        ig.scale(.5, .5);
        ig.setPaint(new Color(128,0,0));
        ig.fillRect(0, 0, 100, 50);
        ig.setPaint(Color.orange);
        ig.fillRect(100, 0, 100, 50);
        ig.setPaint(Color.yellow);
        ig.fillRect(0, 50, 100, 50);
        ig.setPaint(Color.red);
        ig.fillRect(100, 50, 100, 50);
        ig.setPaint(new Color(255, 127, 127));
        ig.fillRect(0, 100, 100, 50);
        ig.setPaint(Color.black);
        ig.draw(new Rectangle2D.Double(0.5, 0.5, 199, 149));
        ig.dispose();

        // drawImage(img,x,y,bgcolor,observer);
        g.drawImage(image, 5, 10, Color.gray, null);
        g.translate(150, 0);
        
        // drawImage(img,x,y,w,h,observer)
        g.drawImage(image, 5, 10, 50, 40, null);
        g.translate(-150, 80);
        
        // drawImage(img,dx1,dy1,dx2,dy2,sx1,sy1,sx2,sy2,observer);
        g.drawImage(image, 5, 10, 45, 40, 50, 0, 100, 25, null);
        g.translate(150, 0);
        
        // drawImage(img,dx1,dy1,dx2,dy2,sx1,sy1,sx2,sy2,bgcolor,observer);
        g.drawImage(image, 5, 10, 45, 40,   50, 50, 100, 75, Color.gray, null);
        g.translate(-150, 80);
        
        // drawImage(img,xform,obs)
        AffineTransform at = new AffineTransform();
        at.scale(.5, .3);
        at.translate(5, 10);
        g.drawImage(image, at, null);
        
        g.translate(150, 0);

        // drawImage(img,op,x,y);
        RescaleOp op = new RescaleOp(.5f, 0f, null);
        g.drawImage(image,op,5,10);
        
        g.translate(-150, 0);

        g.translate(0, 80);

        // drawImage(x,y,w,y,bgcolor,observer)
        g.drawImage(image, 5, 10, 50, 40, Color.gray, null);

    }
}
