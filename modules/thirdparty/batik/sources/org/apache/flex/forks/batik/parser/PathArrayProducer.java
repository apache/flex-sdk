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
package org.apache.flex.forks.batik.parser;

import java.util.Iterator;
import java.util.LinkedList;

import org.w3c.dom.svg.SVGPathSeg;

/**
 * A handler class that generates an array of shorts and an array floats from
 * parsing path data.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: PathArrayProducer.java 475685 2006-11-16 11:16:05Z cam $
 */
public class PathArrayProducer implements PathHandler {

    /**
     * List of <code>float[]</code> objects.
     */
    protected LinkedList ps;

    /**
     * The current <code>float[]</code> object.
     */
    protected float[] p;

    /**
     * List of <code>short[]</code> objects.
     */
    protected LinkedList cs;

    /**
     * The current <code>short[]</code> object.
     */
    protected short[] c;

    /**
     * The index in which to store the next path command.
     */
    protected int cindex;

    /**
     * The index in which to store the next path parameter.
     */
    protected int pindex;

    /**
     * The total number of path commands accumulated.
     */
    protected int ccount;

    /**
     * The total number of path parameters accumulated.
     */
    protected int pcount;

    /**
     * Returns the array of path commands accumulated.
     */
    public short[] getPathCommands() {
        return c;
    }

    /**
     * Returns the array of path parameters accumulated.
     */
    public float[] getPathParameters() {
        return p;
    }

    // PathHandler ///////////////////////////////////////////////////////////

    /**
     * Implements {@link PathHandler#startPath()}.
     */
    public void startPath() throws ParseException {
        cs = new LinkedList();
        c = new short[11];
        ps = new LinkedList();
        p = new float[11];
        ccount = 0;
        pcount = 0;
        cindex = 0;
        pindex = 0;
    }

    /**
     * Implements {@link PathHandler#movetoRel(float,float)}.
     */
    public void movetoRel(float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_MOVETO_REL);
        param(x);
        param(y);
    }

    /**
     * Implements {@link PathHandler#movetoAbs(float,float)}.
     */
    public void movetoAbs(float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_MOVETO_ABS);
        param(x);
        param(y);
    }

    /**
     * Implements {@link PathHandler#closePath()}.
     */
    public void closePath() throws ParseException {
        command(SVGPathSeg.PATHSEG_CLOSEPATH);
    }

    /**
     * Implements {@link PathHandler#linetoRel(float,float)}.
     */
    public void linetoRel(float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_LINETO_REL);
        param(x);
        param(y);
    }

    /**
     * Implements {@link PathHandler#linetoAbs(float,float)}.
     */
    public void linetoAbs(float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_LINETO_ABS);
        param(x);
        param(y);
    }

    /**
     * Implements {@link PathHandler#linetoHorizontalRel(float)}.
     */
    public void linetoHorizontalRel(float x) throws ParseException {
        command(SVGPathSeg.PATHSEG_LINETO_HORIZONTAL_REL);
        param(x);
    }

    /**
     * Implements {@link PathHandler#linetoHorizontalAbs(float)}.
     */
    public void linetoHorizontalAbs(float x) throws ParseException {
        command(SVGPathSeg.PATHSEG_LINETO_HORIZONTAL_ABS);
        param(x);
    }

    /**
     * Implements {@link PathHandler#linetoVerticalRel(float)}.
     */
    public void linetoVerticalRel(float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_LINETO_VERTICAL_REL);
        param(y);
    }

    /**
     * Implements {@link PathHandler#linetoVerticalAbs(float)}.
     */
    public void linetoVerticalAbs(float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_LINETO_VERTICAL_ABS);
        param(y);
    }

    /**
     * Implements {@link
     * PathHandler#curvetoCubicRel(float,float,float,float,float,float)}.
     */
    public void curvetoCubicRel(float x1, float y1, 
                                float x2, float y2, 
                                float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_CURVETO_CUBIC_REL);
        param(x1);
        param(y1);
        param(x2);
        param(y2);
        param(x);
        param(y);
    }

    /**
     * Implements {@link
     * PathHandler#curvetoCubicAbs(float,float,float,float,float,float)}.
     */
    public void curvetoCubicAbs(float x1, float y1, 
                                float x2, float y2, 
                                float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_CURVETO_CUBIC_ABS);
        param(x1);
        param(y1);
        param(x2);
        param(y2);
        param(x);
        param(y);
    }

    /**
     * Implements {@link
     * PathHandler#curvetoCubicSmoothRel(float,float,float,float)}.
     */
    public void curvetoCubicSmoothRel(float x2, float y2, 
                                      float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_CURVETO_CUBIC_SMOOTH_REL);
        param(x2);
        param(y2);
        param(x);
        param(y);
    }

    /**
     * Implements {@link
     * PathHandler#curvetoCubicSmoothAbs(float,float,float,float)}.
     */
    public void curvetoCubicSmoothAbs(float x2, float y2, 
                                      float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_CURVETO_CUBIC_SMOOTH_ABS);
        param(x2);
        param(y2);
        param(x);
        param(y);
    }

    /**
     * Implements {@link
     * PathHandler#curvetoQuadraticRel(float,float,float,float)}.
     */
    public void curvetoQuadraticRel(float x1, float y1, 
                                    float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_REL);
        param(x1);
        param(y1);
        param(x);
        param(y);
    }

    /**
     * Implements {@link
     * PathHandler#curvetoQuadraticAbs(float,float,float,float)}.
     */
    public void curvetoQuadraticAbs(float x1, float y1, 
                                    float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_ABS);
        param(x1);
        param(y1);
        param(x);
        param(y);
    }

    /**
     * Implements {@link PathHandler#curvetoQuadraticSmoothRel(float,float)}.
     */
    public void curvetoQuadraticSmoothRel(float x, float y)
        throws ParseException {
        command(SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL);
        param(x);
        param(y);
    }

    /**
     * Implements {@link PathHandler#curvetoQuadraticSmoothAbs(float,float)}.
     */
    public void curvetoQuadraticSmoothAbs(float x, float y)
        throws ParseException {
        command(SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS);
        param(x);
        param(y);
    }

    /**
     * Implements {@link
     * PathHandler#arcRel(float,float,float,boolean,boolean,float,float)}.
     */
    public void arcRel(float rx, float ry, 
                       float xAxisRotation, 
                       boolean largeArcFlag, boolean sweepFlag, 
                       float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_ARC_REL);
        param(rx);
        param(ry);
        param(xAxisRotation);
        param(largeArcFlag ? 1 : 0);
        param(sweepFlag ? 1 : 0);
        param(x);
        param(y);
    }

    /**
     * Implements {@link
     * PathHandler#arcAbs(float,float,float,boolean,boolean,float,float)}.
     */
    public void arcAbs(float rx, float ry, 
                       float xAxisRotation, 
                       boolean largeArcFlag, boolean sweepFlag, 
                       float x, float y) throws ParseException {
        command(SVGPathSeg.PATHSEG_ARC_ABS);
        param(rx);
        param(ry);
        param(xAxisRotation);
        param(largeArcFlag ? 1 : 0);
        param(sweepFlag ? 1 : 0);
        param(x);
        param(y);
    }

    /**
     * Adds a path command to the list.
     */
    protected void command(short val) throws ParseException {
        if (cindex == c.length) {
            cs.add(c);
            c = new short[c.length * 2 + 1];
            cindex = 0;
        }
        c[cindex++] = val;
        ccount++;
    }

    /**
     * Adds a path parameter to the list.
     */
    protected void param(float val) throws ParseException {
        if (pindex == p.length) {
            ps.add(p);
            p = new float[p.length * 2 + 1];
            pindex = 0;
        }
        p[pindex++] = val;
        pcount++;
    }

    /**
     * Implements {@link PathHandler#endPath()}.
     */
    public void endPath() throws ParseException {
        short[] allCommands = new short[ccount];
        int pos = 0;
        Iterator it = cs.iterator();
        while (it.hasNext()) {
            short[] a = (short[]) it.next();
            System.arraycopy(a, 0, allCommands, pos, a.length);
            pos += a.length;
        }
        System.arraycopy(c, 0, allCommands, pos, cindex);
        cs.clear();
        c = allCommands;

        float[] allParams = new float[pcount];
        pos = 0;
        it = ps.iterator();
        while (it.hasNext()) {
            float[] a = (float[]) it.next();
            System.arraycopy(a, 0, allParams, pos, a.length);
            pos += a.length;
        }
        System.arraycopy(p, 0, allParams, pos, pindex);
        ps.clear();
        p = allParams;
    }
}
