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
 * This test validates convertion of BasicStroke
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: BStroke.java,v 1.3 2004/08/18 07:16:43 vhardy Exp $
 */
public class BStroke implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        /*
         * Strokes of varying width
         */
        java.awt.BasicStroke strokesWidth[] = {
            new java.awt.BasicStroke(2.f),
            new java.awt.BasicStroke(4.f),
            new java.awt.BasicStroke(8.f),
            new java.awt.BasicStroke(16.f)
                };


        /*
         * Strokes of varying termination styles
         */
        java.awt.BasicStroke strokesCap[] = {
            new java.awt.BasicStroke(15.f, java.awt.BasicStroke.CAP_BUTT, java.awt.BasicStroke.JOIN_BEVEL), // No decoration
            new java.awt.BasicStroke(15.f, java.awt.BasicStroke.CAP_SQUARE, java.awt.BasicStroke.JOIN_BEVEL), // Square end
            new java.awt.BasicStroke(15.f, java.awt.BasicStroke.CAP_ROUND, java.awt.BasicStroke.JOIN_BEVEL), // Rounded end
        };

        /*
         * Strokes of varying segment connection styles
         */
        java.awt.BasicStroke strokesJoin[] = {
            new java.awt.BasicStroke(10.f, java.awt.BasicStroke.CAP_SQUARE, java.awt.BasicStroke.JOIN_BEVEL), // Connected with a straight segment
            new java.awt.BasicStroke(10.f, java.awt.BasicStroke.CAP_SQUARE, java.awt.BasicStroke.JOIN_MITER), // Extend outlines until they meet
            new java.awt.BasicStroke(10.f, java.awt.BasicStroke.CAP_SQUARE, java.awt.BasicStroke.JOIN_ROUND), // Round of corner.
        };
        /*
         * Strokes of varying miterlimits
         */
        java.awt.BasicStroke strokesMiter[] = {
            new java.awt.BasicStroke(6.f, java.awt.BasicStroke.CAP_SQUARE, java.awt.BasicStroke.JOIN_MITER, 1),   // Actually cuts of all angles
            new java.awt.BasicStroke(6.f, java.awt.BasicStroke.CAP_SQUARE, java.awt.BasicStroke.JOIN_MITER, 2f),  // Cuts off angles less than 60degrees
            new java.awt.BasicStroke(6.f, java.awt.BasicStroke.CAP_SQUARE, java.awt.BasicStroke.JOIN_MITER, 10f), // Cuts off angles less than 11 degrees
        };

        /*
         * Srokes with varying dash styles
         */
        java.awt.BasicStroke strokesDash[] = {
            new java.awt.BasicStroke(8.f,
                            java.awt.BasicStroke.CAP_BUTT,
                            java.awt.BasicStroke.JOIN_BEVEL,
                            8.f,
                            new float[]{ 6.f, 6.f },
                            0.f),

            new java.awt.BasicStroke(8.f,
                            java.awt.BasicStroke.CAP_BUTT,
                            java.awt.BasicStroke.JOIN_BEVEL,
                            8.f,
                            new float[]{ 10.f, 4.f },
                            0.f),

            new java.awt.BasicStroke(8.f,
                            java.awt.BasicStroke.CAP_BUTT,
                            java.awt.BasicStroke.JOIN_BEVEL,
                            8.f,
                            new float[]{ 4.f, 4.f, 10.f, 4.f },
                            0.f),

            new java.awt.BasicStroke(8.f,
                            java.awt.BasicStroke.CAP_BUTT,
                            java.awt.BasicStroke.JOIN_BEVEL,
                            8.f,
                            new float[]{ 4.f, 4.f, 10.f, 4.f },
                            4.f)
                };

        java.awt.geom.AffineTransform defaultTransform = g.getTransform();

        // Varying width
        g.setPaint(Color.black);
        g.drawString("Varying width", 10, 10);
        for(int i=0; i<strokesWidth.length; i++){
            g.setStroke(strokesWidth[i]);
            g.drawLine(10, 30, 10, 80);
            g.translate(20, 0);
        }

        // Varying end caps
        g.setTransform(defaultTransform);
        g.translate(0, 120);
        g.drawString("Varying end caps", 10, 10);
        for(int i=0; i<strokesCap.length; i++){
            g.setStroke(strokesCap[i]);
            g.drawLine(15, 30, 15, 80);
            g.translate(30, 0);
        }

        // Varying line joins
        GeneralPath needle = new GeneralPath();
        needle.moveTo(0, 60);
        needle.lineTo(10, 20);
        needle.lineTo(20, 60);
        g.setTransform(defaultTransform);
        g.translate(0, 240);
        g.drawString("Varying line joins", 10, 10);
        g.translate(20, 20);
        for(int i=0; i<strokesJoin.length; i++){
            g.setStroke(strokesJoin[i]);
            g.draw(needle);
            g.translate(35, 0);
        }

        // Varying miter limit
        g.setTransform(defaultTransform);
        g.translate(150, 120);
        GeneralPath miterShape = new GeneralPath();
        miterShape.moveTo(0, 0);
        miterShape.lineTo(30, 0);
        miterShape.lineTo(30, 60); // 90 degree elbow
        miterShape.lineTo(0, 30); // 45 degree elbow.
        g.drawString("Varying miter limit", 10, 10);
        g.translate(10, 30);
        for(int i=0; i<strokesMiter.length; i++){
            g.setStroke(strokesMiter[i]);
            g.draw(miterShape);
            g.translate(40, 0);
        }

        // Varing dashing patterns
        g.setTransform(defaultTransform);
        g.translate(150, 0);
        g.drawString("Varying dash patterns", 10, 10);
        g.translate(20, 0);
        for(int i=0; i<strokesDash.length; i++){
            g.setStroke(strokesDash[i]);
            g.drawLine(10, 20, 10, 80);
            g.translate(20, 0);
        }

    }
}
