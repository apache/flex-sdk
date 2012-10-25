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

import java.awt.Shape;
import java.awt.geom.PathIterator;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;

/**
 * A class representing a list of path segments.
 *
 * @version $Id: SegmentList.java 522271 2007-03-25 14:42:45Z dvholten $
 */
public class SegmentList {
    List segments = new LinkedList();

    public SegmentList() {
    }

    public SegmentList(Shape s) {
        PathIterator pi = s.getPathIterator(null);
        float[] pts  = new float[6];
        int type;
        Point2D.Double loc = null;
        Point2D.Double openLoc = null;
        while (!pi.isDone()) {
            type = pi.currentSegment(pts);
            switch (type) {
            case PathIterator.SEG_MOVETO:
                openLoc = loc = new Point2D.Double(pts[0], pts[1] );
                break;
            case PathIterator.SEG_LINETO: {
                Point2D.Double p0 = new Point2D.Double(pts[0], pts[1] );
                segments.add(new Linear(loc, p0));
                loc = p0;
            }
                break;

            case PathIterator.SEG_QUADTO: {
                Point2D.Double p0 = new Point2D.Double(pts[0], pts[1] );
                Point2D.Double p1 = new Point2D.Double(pts[2], pts[3] );
                segments.add(new Quadradic(loc, p0, p1));
                loc = p1;
            }
                break;

            case PathIterator.SEG_CUBICTO: {
                Point2D.Double p0 = new Point2D.Double(pts[0], pts[1] );
                Point2D.Double p1 = new Point2D.Double(pts[2], pts[3] );
                Point2D.Double p2 = new Point2D.Double(pts[4], pts[5] );
                segments.add(new Cubic(loc, p0, p1, p2));
                loc = p2;
            }
                break;

            case PathIterator.SEG_CLOSE:
                segments.add(new Linear(loc, openLoc));
                loc = openLoc;
                break;
            }
            pi.next();
        }
    }

    public Rectangle2D getBounds2D() {
        Iterator iter = iterator();
        if (!iter.hasNext()) return null;

        Rectangle2D ret;
        ret = (Rectangle2D)((Segment)iter.next()).getBounds2D().clone();
        while (iter.hasNext()) {
            Segment seg = (Segment)iter.next();
            Rectangle2D segB = seg.getBounds2D();
            Rectangle2D.union(segB, ret, ret);
        }
        return ret;
    }

    public void add(Segment s) {
        segments.add(s);
    }

    public Iterator iterator() { return segments.iterator(); }

    public int size() { return segments.size(); }

    public SegmentList.SplitResults split(double y) {
        Iterator iter = segments.iterator();
        SegmentList above = new SegmentList();
        SegmentList below = new SegmentList();
        while (iter.hasNext()) {
            Segment seg = (Segment)iter.next();
            Segment.SplitResults results = seg.split(y);
            if (results == null) {
                Rectangle2D bounds = seg.getBounds2D();
                if (bounds.getY() > y) {
                    below.add(seg);
                } else if (bounds.getY() == y) {
                    if (bounds.getHeight() != 0) {
                        below.add(seg);
                    }
                } else {
                    above.add(seg);
                }
                continue;
            }

            Segment [] resAbove = results.getAbove();
            for(int i=0; i<resAbove.length; i++) {
                above.add(resAbove[i]);
            }

            Segment [] resBelow = results.getBelow();
            for(int i=0; i<resBelow.length; i++) {
                below.add(resBelow[i]);
            }
        }
        return new SegmentList.SplitResults(above, below);
    }

    /**
     * read-only helper class to represent a split-result.
     * So far, used only by FlowRegions.
     */
    public static class SplitResults {

        /**
         * is <code>null</code>, when the list is empty.
         */
        final SegmentList above;
        final SegmentList below;

        public SplitResults(SegmentList above, SegmentList below) {

            if ( above != null && above.size() > 0 ){
                this.above = above;
            } else {
                this.above = null;
            }
            if ( below != null && below.size() > 0 ){
                this.below = below;
            } else {
                this.below = null;
            }
        }

        /**
         * @return the list of segments above some split-point - can be null
         */
        public SegmentList getAbove() { return above; }

        /**
         * @return the list of segments below some split-point - can be null
         */
        public SegmentList getBelow() { return below; }
    }
}
