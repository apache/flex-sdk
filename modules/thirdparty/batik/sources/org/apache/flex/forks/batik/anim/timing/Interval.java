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
package org.apache.flex.forks.batik.anim.timing;

import java.util.Iterator;
import java.util.LinkedList;

/**
 * A class that represents an interval for a timed element.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: Interval.java 492528 2007-01-04 11:45:47Z cam $
 */
public class Interval {

    /**
     * The begin time for the interval.
     */
    protected float begin;

    /**
     * The end time for the interval.
     */
    protected float end;

    /**
     * The InstanceTime that defined the begin time of the current interval.
     */
    protected InstanceTime beginInstanceTime;

    /**
     * The InstanceTime that defined the end time of the current interval.
     */
    protected InstanceTime endInstanceTime;

    /**
     * The list of {@link InstanceTime} objects that are dependent
     * on the begin time of this Interval.
     */
    protected LinkedList beginDependents = new LinkedList();

    /**
     * The list of {@link InstanceTime} objects that are dependent
     * on the end time of this Interval.
     */
    protected LinkedList endDependents = new LinkedList();

    /**
     * Creates a new Interval.
     * @param begin the begin time of the Interval
     * @param end the end time of the Interval
     * @param beginInstanceTime the {@link InstanceTime} object that defined
     *        the begin time of the Interval
     * @param endInstanceTime the {@link InstanceTime} object that defined
     *        the end time of the Interval
     */
    public Interval(float begin, float end, InstanceTime beginInstanceTime,
                    InstanceTime endInstanceTime) {
        // Trace.enter(this, null, new Object[] { new Float(begin), new Float(end), beginInstanceTime, endInstanceTime } ); try {
        this.begin = begin;
        this.end = end;
        this.beginInstanceTime = beginInstanceTime;
        this.endInstanceTime = endInstanceTime;
        // } finally { Trace.exit(); }
    }

    /**
     * Returns a string representation of this Interval.
     */
    public String toString() {
        return TimedElement.toString(begin) + ".." + TimedElement.toString(end);
    }

    /**
     * Returns the begin time of this interval.
     */
    public float getBegin() {
        return begin;
    }

    /**
     * Returns the end time of this interval.
     */
    public float getEnd() {
        return end;
    }

    /**
     * Returns the {@link InstanceTime} that defined the begin time of this
     * interval.
     */
    public InstanceTime getBeginInstanceTime() {
        return beginInstanceTime;
    }

    /**
     * Returns the {@link InstanceTime} that defined the end time of this
     * interval.
     */
    public InstanceTime getEndInstanceTime() {
        return endInstanceTime;
    }

    /**
     * Adds a dependent InstanceTime for this Interval.
     */
    void addDependent(InstanceTime dependent, boolean forBegin) {
        // Trace.enter(this, "addDependent", new Object[] { dependent, new Boolean(forBegin) } ); try {
        if (forBegin) {
            beginDependents.add(dependent);
        } else {
            endDependents.add(dependent);
        }
        // } finally { Trace.exit(); }
    }

    /**
     * Removes a dependent InstanceTime for this Interval.
     */
    void removeDependent(InstanceTime dependent, boolean forBegin) {
        // Trace.enter(this, "removeDependent", new Object[] { dependent, new Boolean(forBegin) } ); try {
        if (forBegin) {
            beginDependents.remove(dependent);
        } else {
            endDependents.remove(dependent);
        }
        // } finally { Trace.exit(); }
    }

    /**
     * Updates the begin time for this interval.
     */
    float setBegin(float begin) {
        // Trace.enter(this, "setBegin", new Object[] { new Float(begin) } ); try {
        float minTime = Float.POSITIVE_INFINITY;
        this.begin = begin;
        Iterator i = beginDependents.iterator();
        while (i.hasNext()) {
            InstanceTime it = (InstanceTime) i.next();
            float t = it.dependentUpdate(begin);
            if (t < minTime) {
                minTime = t;
            }
        }
        return minTime;
        // } finally { Trace.exit(); }
    }

    /**
     * Updates the end time for this interval.
     */
    float setEnd(float end, InstanceTime endInstanceTime) {
        // Trace.enter(this, "setEnd", new Object[] { new Float(end) } ); try {
        float minTime = Float.POSITIVE_INFINITY;
        this.end = end;
        this.endInstanceTime = endInstanceTime;
        Iterator i = endDependents.iterator();
        while (i.hasNext()) {
            InstanceTime it = (InstanceTime) i.next();
            float t = it.dependentUpdate(end);
            if (t < minTime) {
                minTime = t;
            }
        }
        return minTime;
        // } finally { Trace.exit(); }
    }
}
