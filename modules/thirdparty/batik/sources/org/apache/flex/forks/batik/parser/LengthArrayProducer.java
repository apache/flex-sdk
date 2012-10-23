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

import org.w3c.dom.svg.SVGLength;

/**
 * A handler class that generates an array of shorts and an array floats from
 * parsing a length list.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: LengthArrayProducer.java 475477 2006-11-15 22:44:28Z cam $
 */
public class LengthArrayProducer extends DefaultLengthListHandler {

    /**
     * List of <code>float[]</code> objects.
     */
    protected LinkedList vs;

    /**
     * The current <code>float[]</code> object.
     */
    protected float[] v;

    /**
     * List of <code>short[]</code> objects.
     */
    protected LinkedList us;

    /**
     * The current <code>short[]</code> object.
     */
    protected short[] u;

    /**
     * The index in which to store the next length.
     */
    protected int index;

    /**
     * The total number of lengths accumulated.
     */
    protected int count;

    /**
     * The unit for the current length.
     */
    protected short currentUnit;

    /**
     * Returns the array of length units accumulated.
     */
    public short[] getLengthTypeArray() {
        return u;
    }

    /**
     * Returns the array of length values accumulated.
     */
    public float[] getLengthValueArray() {
        return v;
    }

    // LengthListHandler /////////////////////////////////////////////////////

    /**
     * Invoked when the length list attribute starts.
     * @exception ParseException if an error occures while processing the
     *                           number list.
     */
    public void startLengthList() throws ParseException {
        us = new LinkedList();
        u = new short[11];
        vs = new LinkedList();
        v = new float[11];
        count = 0;
        index = 0;
    }

    /**
     * Invoked when a float value has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the number
     */
    public void numberValue(float v) throws ParseException {
    }

    /**
     * Implements {@link LengthHandler#lengthValue(float)}.
     */
    public void lengthValue(float val) throws ParseException {
        if (index == v.length) {
            vs.add(v);
            v = new float[v.length * 2 + 1];
            us.add(u);
            u = new short[u.length * 2 + 1];
            index = 0;
        }
        v[index] = val;
    }

    /**
     * Implements {@link LengthHandler#startLength()}.
     */
    public void startLength() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_NUMBER;
    }

    /**
     * Implements {@link LengthHandler#endLength()}.
     */
    public void endLength() throws ParseException {
        u[index++] = currentUnit;
        count++;
    }

    /**
     * Implements {@link LengthHandler#em()}.
     */
    public void em() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_EMS;
    }

    /**
     * Implements {@link LengthHandler#ex()}.
     */
    public void ex() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_EXS;
    }

    /**
     * Implements {@link LengthHandler#in()}.
     */
    public void in() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_IN;
    }

    /**
     * Implements {@link LengthHandler#cm()}.
     */
    public void cm() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_CM;
    }

    /**
     * Implements {@link LengthHandler#mm()}.
     */
    public void mm() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_MM;
    }

    /**
     * Implements {@link LengthHandler#pc()}.
     */
    public void pc() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_PC;
    }

    /**
     * Implements {@link LengthHandler#pt()}.
     */
    public void pt() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_PT;
    }

    /**
     * Implements {@link LengthHandler#px()}.
     */
    public void px() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_PX;
    }

    /**
     * Implements {@link LengthHandler#percentage()}.
     */
    public void percentage() throws ParseException {
        currentUnit = SVGLength.SVG_LENGTHTYPE_PERCENTAGE;
    }

    /**
     * Invoked when the length list attribute ends.
     * @exception ParseException if an error occures while processing the
     *                           number list.
     */
    public void endLengthList() throws ParseException {
        float[] allValues = new float[count];
        int pos = 0;
        Iterator it = vs.iterator();
        while (it.hasNext()) {
            float[] a = (float[]) it.next();
            System.arraycopy(a, 0, allValues, pos, a.length);
            pos += a.length;
        }
        System.arraycopy(v, 0, allValues, pos, index);
        vs.clear();
        v = allValues;

        short[] allUnits = new short[count];
        pos = 0;
        it = us.iterator();
        while (it.hasNext()) {
            short[] a = (short[]) it.next();
            System.arraycopy(a, 0, allUnits, pos, a.length);
            pos += a.length;
        }
        System.arraycopy(u, 0, allUnits, pos, index);
        us.clear();
        u = allUnits;
    }
}
