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

/**
 * An abstract class for SMIL timing specifiers.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimingSpecifier.java 485485 2006-12-11 04:04:53Z cam $
 */
public abstract class TimingSpecifier {

    /**
     * The element that owns this timing specifier.
     */
    protected TimedElement owner;

    /**
     * Whether this timing specifier is for a begin time or an end time.
     */
    protected boolean isBegin;

    /**
     * Creates a new TimingSpecifier object.
     */
    protected TimingSpecifier(TimedElement owner, boolean isBegin) {
        this.owner = owner;
        this.isBegin = isBegin;
    }

    /**
     * Returns the element that owns this timing specifier.
     */
    public TimedElement getOwner() {
        return owner;
    }

    /**
     * Returns true if this timing specifier is in the owner's begin list,
     * false if it is in the owner's end list.
     */
    public boolean isBegin() {
        return isBegin;
    }

    /**
     * Initializes this timing specifier by adding the initial instance time
     * to the owner's instance time list or setting up any event listeners.
     * This should be overriden in descendant classes.
     */
    public void initialize() {
    }

    /**
     * Deinitializes this timing specifier by removing any event listeners.
     * This should be overriden in descendant classes.
     */
    public void deinitialize() {
    }

    /**
     * Returns whether this timing specifier is event-like (i.e., if it is
     * an eventbase, accesskey or a repeat timing specifier).
     */
    public abstract boolean isEventCondition();

    /**
     * Called by the timebase element when it creates a new Interval.
     * This should be overridden in descendant classes that generate
     * time instances based on the interval of a timebase element.
     */
    float newInterval(Interval interval) {
        return Float.POSITIVE_INFINITY;
    }

    /**
     * Called by the timebase element when it deletes an Interval.
     * This should be overridden in descendant classes that generate
     * time instances based on the interval of a timebase element.
     */
    float removeInterval(Interval interval) {
        return Float.POSITIVE_INFINITY;
    }

    /**
     * Called by an {@link InstanceTime} created by this TimingSpecifier
     * to indicate that its value has changed.  This should be overriden
     * in descendant classes that generate time instances based on the
     * interval of a timebase element.
     */
    float handleTimebaseUpdate(InstanceTime instanceTime, float newTime) {
        return Float.POSITIVE_INFINITY;
    }
}
