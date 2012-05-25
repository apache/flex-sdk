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

import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.BufferedImageOp;
import java.awt.image.ColorModel;

class NullOp implements BufferedImageOp {
    public BufferedImage filter(BufferedImage src, BufferedImage dest){
        java.awt.Graphics2D g = dest.createGraphics();
        g.drawImage(src, 0, 0, null);
        g.dispose();
        return dest;
    }

    public Rectangle2D getBounds2D(BufferedImage src){
        return new Rectangle(0, 0, src.getWidth(), src.getHeight());
    }


    /**
     * Creates a destination image compatible with the source.
     */
    public BufferedImage createCompatibleDestImage (BufferedImage src,
                                                    ColorModel destCM){
        BufferedImage dest = null;
        if(destCM==null)
            destCM = src.getColorModel();

        dest = new BufferedImage(destCM, destCM.createCompatibleWritableRaster(src.getWidth(), src.getHeight()),
                                 destCM.isAlphaPremultiplied(), null);

        return dest;
    }

    /**
     * Returns the location of the destination point given a
     * point in the source image.  If DestPt is non-null, it
     * will be used to hold the return value.
     */
    public Point2D getPoint2D (Point2D srcPt, Point2D destPt){
        // This operation does not affect pixel location
        if(destPt==null)
            destPt = new Point2D.Double();
        destPt.setLocation(srcPt.getX(), srcPt.getY());
        return destPt;
    }

    /**
     * Returns the rendering hints for this BufferedImageOp.  Returns
     * null if no hints have been set.
     */
    public RenderingHints getRenderingHints(){
        return null;
    }
}

