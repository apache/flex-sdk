/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

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
 * @version $Id: Segment.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public interface Segment extends Cloneable {
    double minX();
    double maxX();
    double minY();
    double maxY();
    Rectangle2D getBounds2D();

    Point2D.Double evalDt(double t);
    Point2D.Double eval(double t);

    Segment getSegment(double t0, double t1);
    Segment splitBefore(double t);
    Segment splitAfter(double t);
    void    subdivide(Segment s0, Segment s1);
    void    subdivide(double t, Segment s0, Segment s1);
    double  getLength();
    double  getLength(double maxErr);

    SplitResults split(double y);

    class SplitResults {
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
