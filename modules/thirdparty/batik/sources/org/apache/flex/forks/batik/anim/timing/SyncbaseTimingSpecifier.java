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

import java.lang.ref.WeakReference;
import java.util.HashMap;

/**
 * A class to handle syncbase SMIL timing specifiers.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SyncbaseTimingSpecifier.java 580338 2007-09-28 13:13:46Z cam $
 */
public class SyncbaseTimingSpecifier extends OffsetTimingSpecifier {

    /**
     * The ID of the syncbase element.
     */
    protected String syncbaseID;

    /**
     * The syncbase element.
     */
    protected TimedElement syncbaseElement;

    /**
     * Whether this specifier specifies a sync to the begin or the end
     * of the syncbase element.
     */
    protected boolean syncBegin;

    /**
     * Map of {@link Interval}s to <!--a {@link WeakReference} to -->an
     * {@link InstanceTime}.
     */
    protected HashMap instances = new HashMap();

    /**
     * Creates a new SyncbaseTimingSpecifier object.
     */
    public SyncbaseTimingSpecifier(TimedElement owner, boolean isBegin,
                                   float offset, String syncbaseID,
                                   boolean syncBegin) {
        super(owner, isBegin, offset);
        // Trace.enter(this, null, new Object[] { owner, new Boolean(isBegin), new Float(offset), syncbaseID, new Boolean(syncBegin) } ); try {
        this.syncbaseID = syncbaseID;
        this.syncBegin = syncBegin;
        this.syncbaseElement = owner.getTimedElementById(syncbaseID);
        syncbaseElement.addDependent(this, syncBegin);
        // } finally { Trace.exit(); }
    }

    /**
     * Returns a string representation of this timing specifier.
     */
    public String toString() {
        return syncbaseID + "." + (syncBegin ? "begin" : "end")
            + (offset != 0 ? super.toString() : "");
    }

    /**
     * Initializes this timing specifier by adding the initial instance time
     * to the owner's instance time list or setting up any event listeners.
     */
    public void initialize() {
    }

    /**
     * Returns whether this timing specifier is event-like (i.e., if it is
     * an eventbase, accesskey or a repeat timing specifier).
     */
    public boolean isEventCondition() {
        return false;
    }

    /**
     * Called by the timebase element when it creates a new Interval.
     */
    float newInterval(Interval interval) {
        // Trace.enter(this, "newInterval", new Object[] { interval } ); try {
        if (owner.hasPropagated) {
            return Float.POSITIVE_INFINITY;
        }
        InstanceTime instance =
            new InstanceTime(this, (syncBegin ? interval.getBegin()
                                              : interval.getEnd()) + offset,
                             true);
        instances.put(interval, instance);
        interval.addDependent(instance, syncBegin);
        return owner.addInstanceTime(instance, isBegin);
        // } finally { Trace.exit(); }
    }

    /**
     * Called by the timebase element when it deletes an Interval.
     */
    float removeInterval(Interval interval) {
        // Trace.enter(this, "removeInterval", new Object[] { interval } ); try {
        if (owner.hasPropagated) {
            return Float.POSITIVE_INFINITY;
        }
        InstanceTime instance = (InstanceTime) instances.get(interval);
        interval.removeDependent(instance, syncBegin);
        return owner.removeInstanceTime(instance, isBegin);
        // } finally { Trace.exit(); }
    }

    /**
     * Called by an {@link InstanceTime} created by this TimingSpecifier
     * to indicate that its value has changed.
     */
    float handleTimebaseUpdate(InstanceTime instanceTime, float newTime) {
        // Trace.enter(this, "handleTimebaseUpdate", new Object[] { instanceTime, new Float(newTime) } ); try {
        if (owner.hasPropagated) {
            return Float.POSITIVE_INFINITY;
        }
        return owner.instanceTimeChanged(instanceTime, isBegin);
        // } finally { Trace.exit(); }
    }
}
