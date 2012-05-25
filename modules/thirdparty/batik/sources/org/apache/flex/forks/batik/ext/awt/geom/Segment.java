/*

   Copyright 2003 The Apache Software Foundation 

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
package org.apache.flex.forks.batik.ext.awt.geom;

import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

/**
 * An interface that path segments must implement.
 *
 * @version $Id: Segment.java,v 1.2 2005/03/27 08:58:32 cam Exp $
 */
public interface Segment extends Cloneable {
    public double minX();
    public double maxX();
    public double minY();
    public double maxY();
    public Rectangle2D getBounds2D();

    public Point2D.Double evalDt(double t);
    public Point2D.Double eval(double t);

    public Segment getSegment(double t0, double t1);
    public Segment splitBefore(double t);
    public Segment splitAfter(double t);
    public void    subdivide(Segment s0, Segment s1);
    public void    subdivide(double t, Segment s0, Segment s1);
    public double  getLength();
    public double  getLength(double maxErr);

    public SplitResults split(double y);

    public static class SplitResults {
        Segment [] above;
        Segment [] below;
        SplitResults(Segment []below, Segment []above) {
            this.below = below;
            this.above = above;
        }

        Segment [] getBelow() {
            return below;
        }
        Segment [] getAbove() {
            return above;
        }
    }
}
