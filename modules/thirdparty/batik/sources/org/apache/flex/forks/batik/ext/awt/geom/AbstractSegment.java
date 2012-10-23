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
import java.util.Arrays;

/**
 * An abstract class for path segments.
 *
 * @version $Id: AbstractSegment.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public abstract class AbstractSegment implements Segment {

    protected abstract int findRoots(double y, double [] roots);

    public Segment.SplitResults split(double y) {
        double [] roots = { 0, 0, 0 };
        int numSol = findRoots(y, roots);
        if (numSol == 0) return null; // No split

        Arrays.sort(roots, 0, numSol);
        double [] segs = new double[numSol+2];
        int numSegments=0;
        segs[numSegments++] = 0;
        for (int i=0; i<numSol; i++) {
            double r = roots[i];
            if (r <= 0.0) continue;
            if (r >= 1.0) break;
            if (segs[numSegments-1] != r)
                segs[numSegments++] = r;
        }
        segs[numSegments++] = 1.0;

        if (numSegments == 2) return null;
        // System.err.println("Y: " + y + "#Seg: " + numSegments +
        //                    " Seg: " + this);

        Segment [] parts = new Segment[numSegments];
        double pT = 0.0;
        int pIdx = 0;
        boolean firstAbove=false, prevAbove=false;
        for (int i=1; i<numSegments; i++) {
            // System.err.println("Segs: " + segs[i-1]+", "+segs[i]);
            parts[pIdx] = getSegment(segs[i-1], segs[i]);
            Point2D.Double pt = parts[pIdx].eval(0.5);
            // System.err.println("Pt: " + pt);
            if (pIdx == 0) {
                pIdx++;
                firstAbove = prevAbove = (pt.y < y);
                continue;
            }
            boolean above = (pt.y < y);
            if (prevAbove == above) {
                // Merge segments
                parts[pIdx-1] = getSegment(pT, segs[i]);
            } else {
                pIdx++;
                pT=segs[i-1];
                prevAbove = above;
            }
        }
        if (pIdx == 1) return null;
        Segment [] below, above;
        if (firstAbove) {
            above = new Segment[(pIdx+1)/2];
            below = new Segment[pIdx/2];
        } else {
            above = new Segment[pIdx/2];
            below = new Segment[(pIdx+1)/2];
        }
        int ai=0, bi=0;
        for (int i=0; i<pIdx; i++) {
            if (firstAbove) above[ai++] = parts[i];
            else            below[bi++] = parts[i];
            firstAbove = !firstAbove;
        }
        return new SplitResults(below, above);
    }

    public Segment splitBefore(double t) {
        return getSegment(0.0, t);
    }

    public Segment splitAfter(double t) {
        return getSegment(t, 1.0);
    }

    // Doubles have 48bit precision
    static final double eps = 1/(double)(1L<<48);
    static final double tol = 4.0*eps;

    public static int solveLine(double a, double b,
                                 double [] roots) {
        if (a == 0) {
            if (b != 0)
                // No intersection.
                return 0;
            // All pts intersect just return 0.
            roots[0] = 0;
            return 1;
        }

        roots[0] = -b/a;
        return 1;
    }

    public static int solveQuad(double a, double b, double c,
                                 double [] roots) {
        // System.err.println("Quad: " + a +"t^2 + " + b +"t + " + c);
        if (a == 0) {
            // no square term.
            return solveLine(b, c, roots);
        }

        double det = b*b-4*a*c;
        // System.err.println("Det: " + det);

        if (Math.abs(det) <= tol*b*b) {
            // one real root (det doesn't contain any useful info)
            roots[0] =  -b/(2*a);
            return 1;
        }

        if (det < 0)
            return 0; // No real roots

        // Two real roots
        det = Math.sqrt(det);
        double w = -(b + matchSign(det, b));
        roots[0] = (2*c)/w;
        roots[1] = w/(2*a);
        return 2;
    }

    public static double matchSign(double a, double b) {
        if (b < 0) return (a < 0)?a:-a;
        return (a > 0)?a:-a;
    }

    public static int solveCubic(double a3, double a2,
                                  double a1, double a0,
                                  double [] roots) {

        // System.err.println("Cubic: " + a3 + "t^3 + " +
        //                    a2 +"t^2 + " +
        //                    a1 +"t + " + a0);

        double [] dRoots = { 0, 0};
        int dCnt = solveQuad(3*a3, 2*a2, a1, dRoots);
        double [] yVals = {0, 0, 0, 0};
        double [] tVals = {0, 0, 0, 0};
        int yCnt=0;
        yVals[yCnt]   = a0;
        tVals[yCnt++] = 0;
        double r;
        switch (dCnt) {
        case 1:
            r = dRoots[0];
            if ((r > 0) && (r < 1)) {
                yVals[yCnt]   = ((a3*r+a2)*r+a1)*r+a0;
                tVals[yCnt++] = r;
            }
            break;
        case 2:
            if (dRoots[0] > dRoots[1]) {
                double t  = dRoots[0];
                dRoots[0] = dRoots[1];
                dRoots[1] = t;
            }
            r = dRoots[0];
            if ((r > 0) && (r < 1)) {
                yVals[yCnt]   = ((a3*r+a2)*r+a1)*r+a0;
                tVals[yCnt++] = r;
            }
            r = dRoots[1];
            if ((r > 0) && (r < 1)) {
                yVals[yCnt]   = ((a3*r+a2)*r+a1)*r+a0;
                tVals[yCnt++] = r;
            }
            break;
        default: break;
        }
        yVals[yCnt]   = a3+a2+a1+a0;
        tVals[yCnt++] = 1.0;

        int ret=0;
        for (int i=0; i<yCnt-1; i++) {
            double y0 = yVals[i],   t0 = tVals[i];
            double y1 = yVals[i+1], t1 = tVals[i+1];
            if ((y0 < 0) && (y1 < 0)) continue;
            if ((y0 > 0) && (y1 > 0)) continue;

            if (y0 > y1) { // swap so y0 < 0 and y1 > 0
                double t;
                t = y0; y0=y1; y1=t;
                t = t0; t0=t1; t1=t;
            }

            if (-y0 < tol*y1) { roots[ret++] = t0;      continue; }
            if (y1 < -tol*y0) { roots[ret++] = t1; i++; continue; }

            double epsZero = tol*(y1-y0);
            int cnt;
            for (cnt=0; cnt<20; cnt++) {
                double dt = t1-t0;
                double dy = y1-y0;
                // double t = (t0+t1)/2;
                // double t= t0+Math.abs(y0/dy)*dt;
                // This tends to make sure that we come up
                // a little short each time this generaly allows
                // you to eliminate as much of the range as possible
                // without overshooting (in which case you may eliminate
                // almost nothing).
                double t= t0+(Math.abs(y0/dy)*99+.5)*dt/100;
                double v = ((a3*t+a2)*t+a1)*t+a0;
                if (Math.abs(v) < epsZero) {
                    roots[ret++] = t; break;
                }
                if (v < 0) { t0 = t; y0=v;}
                else       { t1 = t; y1=v;}
            }
            if (cnt == 20)
                roots[ret++] = (t0+t1)/2;
        }
        return ret;
    }

    /*
    public static void check(Segment seg, float y, PrintStream ps) {
        ps.println("<path fill=\"none\" stroke=\"black\" " +
                   " stroke-width=\"3\" d=\"" + seg + "\"/>");

        ps.println("<line x1=\"-1000\" y1=\""+y+
                   "\" x2=\"1000\" y2=\""+y+"\" fill=\"none\" stroke=\"orange\"/>\n");

        SplitResults sr = seg.split(y);
        if (sr == null) return;
        Segment [] above = sr.getAbove();
        Segment [] below = sr.getBelow();
        for (int i=0; i<above.length; i++) {
            ps.println("<path fill=\"none\" stroke=\"blue\" " +
                       " stroke-width=\"2.5\" " +
                       " d=\"" + above[i] + "\"/>");
        }
        for (int i=0; i<below.length; i++) {
            ps.println("<path fill=\"none\" stroke=\"red\" " +
                       " stroke-width=\"2\" " +
                       "d=\"" + below[i] + "\"/>");
        }
    }
    public static void main(String [] args) {
        PrintStream ps;
        double [] roots = { 0, 0, 0 };
        int n = solveCubic (-0.10000991821289062, 9.600013732910156,
                            -35.70000457763672, 58.0, roots);
        for (int i=0; i<n; i++)
            System.err.println("Root: " + roots[i]);
        Cubic c;
        c = new Cubic(new Point2D.Double(153.6999969482422,5.099999904632568),
                      new Point2D.Double(156.6999969482422,4.099999904632568),
                      new Point2D.Double(160.39999389648438,2.3999998569488525),
                      new Point2D.Double(164.6999969482422,0.0));
        c.split(0);

        c = new Cubic(new Point2D.Double(24.899999618530273,23.10000228881836),
                      new Point2D.Double(41.5,8.399999618530273),
                      new Point2D.Double(64.69999694824219,1.0),
                      new Point2D.Double(94.5999984741211,1.0));
        c.split(0);

        try {
            ps = new PrintStream(new FileOutputStream(args[0]));
        } catch(java.io.IOException ioe) {
            ioe.printStackTrace();
            return;
        }

        ps.println("<?xml version=\"1.0\" standalone=\"no\"?>\n" +
                   "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\"\n" +
                   "\"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">\n" +
                   "<svg width=\"450\" height=\"500\"\n" +
                   "     viewBox=\"-100 -100 450 500\"\n" +
                   "     xmlns=\"http://www.w3.org/2000/svg\"\n" +
                   "     xmlns:xlink=\"http://www.w3.org/1999/xlink\">");

        check(new Cubic(new Point2D.Double(0, 0),
                        new Point2D.Double(100, 100),
                        new Point2D.Double(-50, 100),
                        new Point2D.Double(50, 0)), 40, ps);

        check(new Cubic(new Point2D.Double(100, 0),
                        new Point2D.Double(200, 100),
                        new Point2D.Double(50, -50),
                        new Point2D.Double(150, 30)), 20, ps);

        check(new Cubic(new Point2D.Double(200, 0),
                        new Point2D.Double(300, 100),
                        new Point2D.Double(150, 100),
                        new Point2D.Double(250, 0)), 75, ps);

        check(new Quadradic(new Point2D.Double(0, 100),
                            new Point2D.Double(50,150),
                            new Point2D.Double(10,100)), 115, ps);

        check(new Linear(new Point2D.Double(100, 100),
                         new Point2D.Double(150,150)), 115, ps);
        ps.println("</svg>");
    }
    */
}
