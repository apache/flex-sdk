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
import java.awt.image.BufferedImage;

/**
 * This test validates the convertion of Java 2D TexturePaints
 * into SVG patterns and fill and fill-opacity values
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Texture.java,v 1.4 2004/08/18 07:16:45 vhardy Exp $
 */
public class Texture implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);
        Color labelColor = Color.black;

        BufferedImage texture = new BufferedImage(20, 20, BufferedImage.TYPE_INT_RGB);
        Graphics2D bg = texture.createGraphics();
        bg.setPaint(Color.red);
        bg.fillRect(0, 0, 10, 10);
        bg.setPaint(Color.yellow);
        bg.fillRect(10, 10, 10, 10);
        bg.dispose();

        Rectangle anchors[] = { new Rectangle(0, 0, texture.getWidth(), texture.getHeight()),
                                new Rectangle(texture.getWidth()/2, texture.getHeight()/2, texture.getWidth(), texture.getHeight()),
                                new Rectangle(0, 0, texture.getWidth()/2, texture.getHeight()/2) };

        String anchorDesc[] = { "Anchor matches texture image",
                                "Anchor offset to texture image center",
                                "Anchor half the size of texture" };

        // Now, fill a rectangle that is 4 times the size of the texture
        // along each axis, once for each texture.

        g.translate(0, 20);

        for(int i=0; i<anchors.length; i++){
            java.awt.TexturePaint texturePaint = new java.awt.TexturePaint(texture, anchors[i]);
            g.setPaint(texturePaint);
            g.fillRect(0, 0, texture.getWidth()*4, texture.getHeight()*4);
            java.awt.geom.AffineTransform curTxf = g.getTransform();
            g.translate(150, 0);
            g.shear(.5, 0);
            g.fillRect(0, 0, texture.getWidth()*4, texture.getHeight()*4);
            g.setTransform(curTxf);
            g.setPaint(labelColor);
            g.drawString(anchorDesc[i], 10, texture.getHeight()*4 + 20);
            g.translate(0, texture.getHeight()*4 + 40);
        }
    }
}
