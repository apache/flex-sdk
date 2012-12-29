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
package org.apache.flex.forks.batik.gvt.flow;

import java.awt.Shape;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;

import org.apache.flex.forks.batik.ext.awt.geom.SegmentList;
import org.apache.flex.forks.batik.ext.awt.geom.Segment;

/**
 * A class to hold flow region information for a given shape.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: FlowRegions.java 522271 2007-03-25 14:42:45Z dvholten $
 */
public class FlowRegions {
    Shape flowShape;
    SegmentList sl;
    SegmentList.SplitResults sr;
    List validRanges;
    int currentRange;
    double currentY, lineHeight;

    public FlowRegions(Shape s) {
        this(s, s.getBounds2D().getY());
    }

    public FlowRegions(Shape s, double startY) {
        this.flowShape = s;
        sl = new SegmentList(s);
        currentY = startY-1;
        gotoY(startY);
    }

    public double getCurrentY() { return currentY; }
    public double getLineHeight() { return lineHeight; }

    public boolean gotoY(double y) {
        if (y < currentY)
            throw new IllegalArgumentException
                ("New Y can not be lower than old Y\n" +
                 "Old Y: " + currentY + " New Y: " + y);
        if (y == currentY) return false;
        sr = sl.split(y);
        sl = sr.getBelow();
        sr = null;
        currentY = y;
        if (sl == null) return true;

        newLineHeight(lineHeight);
        return false;
    }

    public void newLineHeight(double lineHeight) {
        this.lineHeight = lineHeight;
        sr = sl.split(currentY+lineHeight);

        if (sr.getAbove() != null) {
            sortRow(sr.getAbove());
        }
        currentRange = 0;
    }

    public int getNumRangeOnLine() {
        if (validRanges == null) return 0;
        return validRanges.size();
    }
    public void resetRange() {
        currentRange = 0;
    }

    public double [] nextRange() {
        if (currentRange >= validRanges.size())
            return null;
        return (double [])validRanges.get(currentRange++);
    }
    public void endLine() {
        sl = sr.getBelow();
        sr = null;
        currentY += lineHeight;
    }

    public boolean newLine() {
        return newLine(lineHeight);
    }

    public boolean newLine(double lineHeight) {
        if (sr != null) {
            sl = sr.getBelow();
        }
        sr = null;
        if (sl == null) return false;
        currentY += this.lineHeight;
        newLineHeight(lineHeight);
        return true;
    }

    public boolean newLineAt(double y, double lineHeight) {
        if (sr != null) {
            sl = sr.getBelow();
        }
        sr = null;
        if (sl == null) return false;
        currentY = y;
        newLineHeight(lineHeight);
        return true;
    }


    public boolean done() {
        return (sl == null);
    }

    public void sortRow(SegmentList sl) {
        // System.err.println("sorting: " + sl.size());
        Transition [] segs = new Transition[sl.size()*2];
        Iterator iter = sl.iterator();
        int i=0;
        while (iter.hasNext()) {
            Segment seg = (Segment)iter.next();
            segs[i++] = new Transition(seg.minX(), true);
            segs[i++] = new Transition(seg.maxX(), false);
            // System.err.println("Seg: " + seg.minX() + ", " + seg.maxX());
        }

        Arrays.sort(segs, TransitionComp.COMP);
        validRanges = new ArrayList();
        int count = 1;
        double openStart =0;
        // Skip the first one as it always starts a geometry block.
        for (i=1; i<segs.length; i++) {
            Transition t = segs[i];
            if (t.up) {
                if (count == 0) {
                    double cx = (openStart + t.loc)/2;
                    double cy = currentY + lineHeight/2;
                    // System.err.println("PT: " + cx+", "+cy);
                    if (flowShape.contains( cx, cy )) {
                        validRanges.add(new double[]{openStart, t.loc});
                    }
                }
                count++;
            } else {
                count--;
                if (count == 0)
                    openStart = t.loc;
            }
        }
    }

    static class Transition {
        public double loc;
        public boolean up;
        public Transition(double loc, boolean up) {
            this.loc = loc;
            this.up  = up;
        }
    }

    static class TransitionComp implements Comparator {
        public static Comparator COMP = new TransitionComp();
        TransitionComp() { }
        public int compare(Object o1, Object o2) {
            Transition t1 = (Transition)o1;
            Transition t2 = (Transition)o2;
            if (t1.loc < t2.loc) return -1;
            if (t1.loc > t2.loc) return 1;
            // Locs are equal.
            if (t1.up) {
                if (t2.up) return 0;  // everything equal.
                return -1;            // always list ups first
            }
            if (t2.up) return 1;
            return 0;
        }
        public boolean equals(Object comp) {
            return (this == comp);
        }
    }
}

