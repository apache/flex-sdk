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

import java.util.*;

import org.apache.flex.forks.batik.anim.AnimationException;
import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.parser.ClockHandler;
import org.apache.flex.forks.batik.parser.ClockParser;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.util.SMILConstants;

import org.w3c.dom.Element;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventTarget;

/**
 * An abstract base class for elements that can have timing applied to them.
 * The concrete versions of this class do not necessarily have to be the
 * same as the DOM class, and in fact, this will mostly be impossible unless
 * creating new DOM classes that inherit from these elements.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimedElement.java 592593 2007-11-07 00:44:30Z cam $
 */
public abstract class TimedElement implements SMILConstants {

    // Constants for fill mode.
    public static final int FILL_REMOVE = 0;
    public static final int FILL_FREEZE = 1;

    // Constants for restart mode.
    public static final int RESTART_ALWAYS          = 0;
    public static final int RESTART_WHEN_NOT_ACTIVE = 1;
    public static final int RESTART_NEVER           = 2;

    // Constants for time values.
    public static final float INDEFINITE = Float.POSITIVE_INFINITY;
    public static final float UNRESOLVED = Float.NaN;

    /**
     * The root time container.
     */
    protected TimedDocumentRoot root;

    /**
     * The parent time container.
     */
    protected TimeContainer parent;

    /**
     * Timing specifiers for the begin times of this element.
     */
    protected TimingSpecifier[] beginTimes;

    /**
     * Timing specifiers for the end times of this element.
     */
    protected TimingSpecifier[] endTimes;

    /**
     * Duration of this element, if {@link #durMedia} <code>= false</code>.
     * If unspecified, it will be {@link #UNRESOLVED}.
     */
    protected float simpleDur;

    /**
     * Whether the simple duration of this element should be equal
     * to the implicit duration.
     */
    protected boolean durMedia;

    /**
     * The number of repeats.  If unspecified, it will be
     * {@link #UNRESOLVED}.
     */
    protected float repeatCount;

    /**
     * The duration of repeats.  If unspecified, it will be
     * {@link #UNRESOLVED}.
     */
    protected float repeatDur;

    /**
     * The current repeat iteration.
     */
    protected int currentRepeatIteration;

    /**
     * The local active time of the last repeat.
     */
    protected float lastRepeatTime;

    /**
     * The fill mode for this element.  Uses the FILL_* constants
     * defined in this class.
     */
    protected int fillMode;

    /**
     * The restart mode for this element.  Uses the RESTART_* constants
     * defined in this class.
     */
    protected int restartMode;

    /**
     * The minimum active duration of this element.  If {@link #minMedia}
     * <code>= true</code>, it will be <code>0f</code>.
     */
    protected float min;

    /**
     * Whether the min value was specified as 'media'.
     */
    protected boolean minMedia;

    /**
     * The maximum active duration of this element.  If {@link #maxMedia}
     * <code>= true</code>, it will be {@link #INDEFINITE}.
     */
    protected float max;

    /**
     * Whether the max value was specified as 'media'.
     */
    protected boolean maxMedia;

    /**
     * Whether the element is currently active.
     */
    protected boolean isActive;

    /**
     * Whether the element is currently frozen.
     */
    protected boolean isFrozen;

    /**
     * The current time of this element in local active time.
     */
    protected float lastSampleTime;

    /**
     * The computed repeat duration of the element.
     */
    protected float repeatDuration;

    /**
     * List of begin InstanceTimes.
     */
    protected List beginInstanceTimes = new ArrayList();

    /**
     * List of end InstanceTimes.
     */
    protected List endInstanceTimes = new ArrayList();

    /**
     * The current Interval.
     */
    protected Interval currentInterval;

    /**
     * The end time of the previous interval, initially
     * {@link Float#NEGATIVE_INFINITY}.
     */
    protected float lastIntervalEnd;

    /**
     * List of previous intervals.
     */
    // protected LinkedList previousIntervals = new LinkedList();

    /**
     * The previous interval.
     */
    protected Interval previousInterval;

    /**
     * List of TimingSpecifiers on other elements that depend on this
     * element's begin times.
     */
    protected LinkedList beginDependents = new LinkedList();

    /**
     * List of TimingSpecifiers on other elements that depend on this
     * element's end times.
     */
    protected LinkedList endDependents = new LinkedList();

    /**
     * Whether the list of instance times should be checked to update
     * the current interval.
     */
    protected boolean shouldUpdateCurrentInterval = true;

    /**
     * Whether this timed element has parsed its timing attributes yet.
     */
    protected boolean hasParsed;

    /**
     * Map of {@link Event} objects to {@link HashSet}s of {@link
     * TimingSpecifier}s that caught them.
     */
    protected Map handledEvents = new HashMap();

    /**
     * Whether this timed element is currently being sampled.
     */
    protected boolean isSampling;

    /**
     * Whether an instance time update message has already been propagated to
     * this timed element.
     */
    protected boolean hasPropagated;

    /**
     * Creates a new TimedElement.
     */
    public TimedElement() {
        beginTimes = new TimingSpecifier[0];
        endTimes = beginTimes;
        simpleDur = UNRESOLVED;
        repeatCount = UNRESOLVED;
        repeatDur = UNRESOLVED;
        lastRepeatTime = UNRESOLVED;
        max = INDEFINITE;
        lastSampleTime = UNRESOLVED;
        lastIntervalEnd = Float.NEGATIVE_INFINITY;
    }

    /**
     * Returns the root time container of this timed element.
     */
    public TimedDocumentRoot getRoot() {
        return root;
    }

    /**
     * Returns the current active time of this element.
     */
    public float getActiveTime() {
        return lastSampleTime;
    }

    /**
     * Returns the current simple time of this element.
     */
    public float getSimpleTime() {
        return lastSampleTime - lastRepeatTime;
    }

    /**
     * Called by a TimingSpecifier of this element when a new
     * InstanceTime is created.  This will be in response to an event
     * firing, a DOM method being called or a new Instance being
     * created by a syncbase element.
     */
    protected float addInstanceTime(InstanceTime time, boolean isBegin) {
        // Trace.enter(this, "addInstanceTime", new Object[] { time, new Boolean(isBegin) } ); try {
        hasPropagated = true;
        List instanceTimes = isBegin ? beginInstanceTimes : endInstanceTimes;
        int index = Collections.binarySearch(instanceTimes, time);
        if (index < 0) {
            index = -(index + 1);
        }
        instanceTimes.add(index, time);
        shouldUpdateCurrentInterval = true;
        float ret;
        if (root.isSampling() && !isSampling) {
            ret = sampleAt(root.getCurrentTime(), root.isHyperlinking());
        } else {
            ret = Float.POSITIVE_INFINITY;
        }
        hasPropagated = false;
        root.currentIntervalWillUpdate();
        return ret;
        // } finally { Trace.exit(); }
    }

    /**
     * Called by a TimingSpecifier of this element when an InstanceTime
     * should be removed.  This will be in response to the pruning of an
     * Interval.
     */
    protected float removeInstanceTime(InstanceTime time, boolean isBegin) {
        // Trace.enter(this, "removeInstanceTime", new Object[] { time, new Boolean(isBegin) } ); try {
        hasPropagated = true;
        List instanceTimes = isBegin ? beginInstanceTimes : endInstanceTimes;
        int index = Collections.binarySearch(instanceTimes, time);
        for (int i = index; i >= 0; i--) {
            InstanceTime it = (InstanceTime) instanceTimes.get(i);
            if (it == time) {
                instanceTimes.remove(i);
                break;
            }
            if (it.compareTo(time) != 0) {
                break;
            }
        }
        int len = instanceTimes.size();
        for (int i = index + 1; i < len; i++) {
            InstanceTime it = (InstanceTime) instanceTimes.get(i);
            if (it == time) {
                instanceTimes.remove(i);
                break;
            }
            if (it.compareTo(time) != 0) {
                break;
            }
        }
        shouldUpdateCurrentInterval = true;
        float ret;
        if (root.isSampling() && !isSampling) {
            ret = sampleAt(root.getCurrentTime(), root.isHyperlinking());
        } else {
            ret = Float.POSITIVE_INFINITY;
        }
        hasPropagated = false;
        root.currentIntervalWillUpdate();
        return ret;
        // } finally { Trace.exit(); }
    }

    /**
     * Called by a TimingSpecifier of this element when an InstanceTime
     * has been updated.  This will be in response to a dependent
     * syncbase change.
     */
    protected float instanceTimeChanged(InstanceTime time, boolean isBegin) {
        // Trace.enter(this, "instanceTimeChanged", new Object[] { time, new Boolean(isBegin) } ); try {
        hasPropagated = true;
        shouldUpdateCurrentInterval = true;
        float ret;
        if (root.isSampling() && !isSampling) {
            ret = sampleAt(root.getCurrentTime(), root.isHyperlinking());
        } else {
            ret = Float.POSITIVE_INFINITY;
        }
        hasPropagated = false;
        return ret;
        // } finally { Trace.exit(); }
    }

    /**
     * Adds a dependent TimingSpecifier for this element.
     */
    protected void addDependent(TimingSpecifier dependent, boolean forBegin) {
        // Trace.enter(this, "addDependent", new Object[] { dependent, new Boolean(forBegin) } ); try {
        if (forBegin) {
            beginDependents.add(dependent);
        } else {
            endDependents.add(dependent);
        }
        // } finally { Trace.exit(); }
    }

    /**
     * Removes a dependent TimingSpecifier for this element.
     */
    protected void removeDependent(TimingSpecifier dependent,
                                   boolean forBegin) {
        // Trace.enter(this, "removeDependent", new Object[] { dependent, new Boolean(forBegin) } ); try {
        if (forBegin) {
            beginDependents.remove(dependent);
        } else {
            endDependents.remove(dependent);
        }
        // } finally { Trace.exit(); }
    }

    /**
     * Returns the simple duration time of this element.
     */
    public float getSimpleDur() {
        if (durMedia) {
            return getImplicitDur();
        } else if (isUnresolved(simpleDur)) {
            if (isUnresolved(repeatCount) && isUnresolved(repeatDur)
                    && endTimes.length > 0) {
                return INDEFINITE;
            }
            return getImplicitDur();
        } else {
            return simpleDur;
        }
    }

    /**
     * Returns whether the given time value is equal to the
     * {@link #UNRESOLVED} value.
     */
    public static boolean isUnresolved(float t) {
        return Float.isNaN(t);
    }

    /**
     * Returns the active duration time of this element.
     */
    public float getActiveDur(float B, float end) {
        float d = getSimpleDur();
        float PAD;
        if (!isUnresolved(end) && d == INDEFINITE) {
            PAD = minusTime(end, B);
            repeatDuration = minTime(max, maxTime(min, PAD));
            return repeatDuration;
        }

        float IAD;
        if (d == 0) {
            IAD = 0;
        } else {
            if (isUnresolved(repeatDur) && isUnresolved(repeatCount)) {
                IAD = d;
            } else {
                float p1 = isUnresolved(repeatCount)
                                ? INDEFINITE
                                : multiplyTime(d, repeatCount);
                float p2 = isUnresolved(repeatDur)
                                ? INDEFINITE
                                : repeatDur;
                IAD = minTime(minTime(p1, p2), INDEFINITE);
            }
        }
        if (isUnresolved(end) || end == INDEFINITE) {
            PAD = IAD;
        } else {
            PAD = minTime(IAD, minusTime(end, B));
        }
        repeatDuration = IAD;
        return minTime(max, maxTime(min, PAD));
    }

    /**
     * Subtracts one simple time from another.
     */
    protected float minusTime(float t1, float t2) {
        if (isUnresolved(t1) || isUnresolved(t2)) {
            return UNRESOLVED;
        }
        if (t1 == INDEFINITE || t2 == INDEFINITE) {
            return INDEFINITE;
        }
        return t1 - t2;
    }

    /**
     * Multiplies one simple time by n.
     */
    protected float multiplyTime(float t, float n) {
        if (isUnresolved(t) || t == INDEFINITE) {
            return t;
        }
        return t * n;
    }

    /**
     * Returns the minimum of two time values.
     */
    protected float minTime(float t1, float t2) {
        if (t1 == 0.0f || t2 == 0.0f) {
            return 0.0f;
        }
        if ((t1 == INDEFINITE || isUnresolved(t1))
                && t2 != INDEFINITE && !isUnresolved(t2)) {
            return t2;
        }
        if ((t2 == INDEFINITE || isUnresolved(t2))
                && t1 != INDEFINITE && !isUnresolved(t1)) {
            return t1;
        }
        if (t1 == INDEFINITE && isUnresolved(t2)
                || isUnresolved(t1) && t2 == INDEFINITE) {
            return INDEFINITE;
        }
        if (t1 < t2) {
            return t1;
        }
        return t2;
    }

    /**
     * Returns the maximum of two time values.
     */
    protected float maxTime(float t1, float t2) {
        if ((t1 == INDEFINITE || isUnresolved(t1))
                && t2 != INDEFINITE && !isUnresolved(t2)) {
            return t1;
        }
        if ((t2 == INDEFINITE || isUnresolved(t2))
                && t1 != INDEFINITE && !isUnresolved(t1)) {
            return t2;
        }
        if (t1 == INDEFINITE && isUnresolved(t2)
                || isUnresolved(t1) && t2 == INDEFINITE) {
            return UNRESOLVED;
        }
        if (t1 > t2) {
            return t1;
        }
        return t2;
    }

    /**
     * Returns the implicit duration of the element.  Currently, nested time
     * containers are not supported by SVG so this just returns
     * {@link #UNRESOLVED} by default.  This should be overriden in derived
     * classes that play media, since they will have an implicit duration.
     */
    protected float getImplicitDur() {
        return UNRESOLVED;
    }

    /**
     * Notifies dependents of a new interval.
     */
    protected float notifyNewInterval(Interval interval) {
        // Trace.enter(this, "notifyNewInterval", new Object[] { interval } ); try {
        float dependentMinTime = Float.POSITIVE_INFINITY;
        Iterator i = beginDependents.iterator();
        while (i.hasNext()) {
            TimingSpecifier ts = (TimingSpecifier) i.next();
            // Trace.print(ts.owner + "'s " + (ts.isBegin ? "begin" : "end" ) + ": " + ts);
            float t = ts.newInterval(interval);
            if (t < dependentMinTime) {
                dependentMinTime = t;
            }
        }
        i = endDependents.iterator();
        while (i.hasNext()) {
            TimingSpecifier ts = (TimingSpecifier) i.next();
            // Trace.print(ts.owner + "'s " + (ts.isBegin ? "begin" : "end" ) + ": " + ts);
            float t = ts.newInterval(interval);
            if (t < dependentMinTime) {
                dependentMinTime = t;
            }
        }
        return dependentMinTime;
        // } finally { Trace.exit(); }
    }

    /**
     * Notifies dependents of a removed interval.
     */
    protected float notifyRemoveInterval(Interval interval) {
        // Trace.enter(this, "notifyRemoveInterval", new Object[] { interval } ); try {
        float dependentMinTime = Float.POSITIVE_INFINITY;
        Iterator i = beginDependents.iterator();
        while (i.hasNext()) {
            TimingSpecifier ts = (TimingSpecifier) i.next();
            float t = ts.removeInterval(interval);
            if (t < dependentMinTime) {
                dependentMinTime = t;
            }
        }
        i = endDependents.iterator();
        while (i.hasNext()) {
            TimingSpecifier ts = (TimingSpecifier) i.next();
            float t = ts.removeInterval(interval);
            if (t < dependentMinTime) {
                dependentMinTime = t;
            }
        }
        return dependentMinTime;
        // } finally { Trace.exit(); }
    }

    /**
     * Calculates the local simple time.  Currently the hyperlinking parameter
     * is ignored, so DOM timing events are fired during hyperlinking seeks.
     * If we were following SMIL 2.1 rather than SMIL Animation, then these
     * events would have to be suppressed.
     *
     * @return the number of seconds until this element becomes active again
     *         if it currently is not, {@link Float#POSITIVE_INFINITY} if this
     *         element will become active at some undetermined point in the
     *         future (because of unresolved begin times, for example) or
     *         will never become active again, or <code>0f</code> if the
     *         element is currently active.
     */
    protected float sampleAt(float parentSimpleTime, boolean hyperlinking) {
        // Trace.enter(this, "sampleAt", new Object[] { new Float(parentSimpleTime) } ); try {
        isSampling = true;

        float time = parentSimpleTime; // No time containers in SVG.

        // First, process any events that occurred since the last sampling,
        // taking into account event sensitivity.
        Iterator i = handledEvents.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            Event evt = (Event) e.getKey();
            Set ts = (Set) e.getValue();
            Iterator j = ts.iterator();
            boolean hasBegin = false, hasEnd = false;
            while (j.hasNext() && !(hasBegin && hasEnd)) {
                EventLikeTimingSpecifier t =
                    (EventLikeTimingSpecifier) j.next();
                if (t.isBegin()) {
                    hasBegin = true;
                } else {
                    hasEnd = true;
                }
            }
            boolean useBegin, useEnd;
            if (hasBegin && hasEnd) {
                useBegin = !isActive || restartMode == RESTART_ALWAYS;
                useEnd = !useBegin;
            } else if (hasBegin && (!isActive ||
                        restartMode == RESTART_ALWAYS)) {
                useBegin = true;
                useEnd = false;
            } else if (hasEnd && isActive) {
                useBegin = false;
                useEnd = true;
            } else {
                continue;
            }
            j = ts.iterator();
            while (j.hasNext()) {
                EventLikeTimingSpecifier t =
                    (EventLikeTimingSpecifier) j.next();
                boolean isBegin = t.isBegin();
                if (isBegin && useBegin || !isBegin && useEnd) {
                    t.resolve(evt);
                    shouldUpdateCurrentInterval = true;
                }
            }
        }
        handledEvents.clear();

        // Now process intervals.
        if (currentInterval != null) {
            float begin = currentInterval.getBegin();
            if (lastSampleTime < begin && time >= begin) {
                if (!isActive) {
                    toActive(begin);
                }
                isActive = true;
                isFrozen = false;
                lastRepeatTime = begin;
                fireTimeEvent
                    (SMIL_BEGIN_EVENT_NAME, currentInterval.getBegin(), 0);
            }
        }
        // For each sample, we might need to update the current interval's
        // begin and end times, or end the current interval and compute
        // a new one.
        boolean hasEnded = currentInterval != null
            && time >= currentInterval.getEnd();
        // Fire any repeat events that should have been fired since the
        // last sample.
        if (currentInterval != null) {
            float begin = currentInterval.getBegin();
            if (time >= begin) {
                float d = getSimpleDur();
                while (time - lastRepeatTime >= d
                        && lastRepeatTime + d < begin + repeatDuration) {
                    lastRepeatTime += d;
                    currentRepeatIteration++;
                    fireTimeEvent(root.getRepeatEventName(), lastRepeatTime,
                                  currentRepeatIteration);
                }
            }
        }

        // Trace.print("begin loop");
        float dependentMinTime = Float.POSITIVE_INFINITY;
        if (hyperlinking) {
            shouldUpdateCurrentInterval = true;
        }
        while (shouldUpdateCurrentInterval || hasEnded) {
            if (hasEnded) {
                // previousIntervals.add(currentInterval);
                previousInterval = currentInterval;
                isActive = false;
                isFrozen = fillMode == FILL_FREEZE;
                toInactive(false, isFrozen);
                fireTimeEvent(SMIL_END_EVENT_NAME, currentInterval.getEnd(), 0);
            }
            boolean first =
                // currentInterval == null && previousIntervals.isEmpty();
                currentInterval == null && previousInterval == null;
            if (currentInterval != null && hyperlinking) {
                // Hyperlinking, so remove the current interval and force a new
                // one to be computed.
                isActive = false;
                isFrozen = false;
                toInactive(false, false);
                currentInterval = null;
                // fireTimeEvent(SMIL_END_EVENT_NAME, currentInterval.getEnd(), 0);
            }
            if (currentInterval == null || hasEnded) {
                if (first || hyperlinking || restartMode != RESTART_NEVER) {
                    float beginAfter;
                    boolean incl = true;
                    if (first || hyperlinking) {
                        beginAfter = Float.NEGATIVE_INFINITY;
                    } else {
                        // beginAfter = ((Interval) previousIntervals.getLast()).getEnd();
                        beginAfter = previousInterval.getEnd();
                        incl = beginAfter != previousInterval.getBegin();
                    }
                    Interval interval =
                        computeInterval(first, false, beginAfter, incl);
                    if (interval == null) {
                        currentInterval = null;
                    } else {
                        float dmt = selectNewInterval(time, interval);
                        if (dmt < dependentMinTime) {
                            dependentMinTime = dmt;
                        }
                    }
                } else {
                    currentInterval = null;
                }
            } else {
                float currentBegin = currentInterval.getBegin();
                if (currentBegin > time) {
                    // Interval hasn't started yet.
                    float beginAfter;
                    boolean incl = true;
                    // if (previousIntervals.isEmpty()) {
                    if (previousInterval == null) {
                        beginAfter = Float.NEGATIVE_INFINITY;
                    } else {
                        // beginAfter = ((Interval) previousIntervals.getLast()).getEnd();
                        beginAfter = previousInterval.getEnd();
                        incl = beginAfter != previousInterval.getBegin();
                    }
                    Interval interval =
                        computeInterval(false, false, beginAfter, incl);
                    float dmt = notifyRemoveInterval(currentInterval);
                    if (dmt < dependentMinTime) {
                        dependentMinTime = dmt;
                    }
                    if (interval == null) {
                        currentInterval = null;
                    } else {
                        dmt = selectNewInterval(time, interval);
                        if (dmt < dependentMinTime) {
                            dependentMinTime = dmt;
                        }
                    }
                } else {
                    // Interval has already started.
                    Interval interval =
                        computeInterval(false, true, currentBegin, true);
                    float newEnd = interval.getEnd();
                    if (currentInterval.getEnd() != newEnd) {
                        float dmt =
                            currentInterval.setEnd
                                (newEnd, interval.getEndInstanceTime());
                        if (dmt < dependentMinTime) {
                            dependentMinTime = dmt;
                        }
                    }
                }
            }
            shouldUpdateCurrentInterval = false;
            hyperlinking = false;
            hasEnded = currentInterval != null && time >= currentInterval.getEnd();
        }
        // Trace.print("end loop");

        float d = getSimpleDur();
        if (isActive && !isFrozen) {
            if (time - currentInterval.getBegin() >= repeatDuration) {
                // Trace.print("element between repeat and active duration");
                isFrozen = fillMode == FILL_FREEZE;
                toInactive(true, isFrozen);
            } else {
                // Trace.print("element active, sampling at simple time " + (time - lastRepeatTime));
                sampledAt(time - lastRepeatTime, d, currentRepeatIteration);
            }
        }
        if (isFrozen) {
            float t;
            boolean atLast;
            if (isActive) {
                t = currentInterval.getBegin() + repeatDuration - lastRepeatTime;
                atLast = lastRepeatTime + d == currentInterval.getBegin() + repeatDuration;
            } else {
                // Interval previousInterval = (Interval) previousIntervals.getLast();
                t = previousInterval.getEnd() - lastRepeatTime;
                atLast = lastRepeatTime + d == previousInterval.getEnd();
            }
            if (atLast) {
                // Trace.print("element frozen" + (isActive ? " (but still active)" : "") + ", sampling last value");
                sampledLastValue(currentRepeatIteration);
            } else {
                // Trace.print("element frozen" + (isActive ? " (but still active)" : "") + ", sampling at simple time " + (t % d));
                sampledAt(t % d, d, currentRepeatIteration);
            }
        } else if (!isActive) {
            // Trace.print("element not sampling");
        }

        isSampling = false;

        lastSampleTime = time;
        if (currentInterval != null) {
            float t = currentInterval.getBegin() - time;
            if (t <= 0) {
                t = isConstantAnimation() || isFrozen ? currentInterval.getEnd() - time : 0;
            }
            if (dependentMinTime < t) {
                return dependentMinTime;
            }
            return t;
        }
        return dependentMinTime;
        // } finally { Trace.exit(); }
    }

    /**
     * Returns whether the end timing specifier list contains any eventbase,
     * accesskey or repeat timing specifiers.
     */
    protected boolean endHasEventConditions() {
        for (int i = 0; i < endTimes.length; i++) {
            if (endTimes[i].isEventCondition()) {
                return true;
            }
        }
        return false;
    }

    /**
     * Sets the current interval to the one specified.  This will notify
     * dependents and fire the 'begin' and any necessary 'repeat' events.
     * @param time the current sampling time
     * @param interval the Interval object to select to be current
     * @return the minimum time the animation engine can safely wait, as
     *         determined by dependents of the interval
     */
    protected float selectNewInterval(float time, Interval interval) {
        // Trace.enter(this, "selectNewInterval", new Object[] { interval }); try {
        currentInterval = interval;
        float dmt = notifyNewInterval(currentInterval);
        float beginEventTime = currentInterval.getBegin();
        if (time >= beginEventTime) {
            lastRepeatTime = beginEventTime;
            if (beginEventTime < 0) {
                beginEventTime = 0;
            }
            toActive(beginEventTime);
            isActive = true;
            isFrozen = false;
            fireTimeEvent(SMIL_BEGIN_EVENT_NAME, beginEventTime, 0);
            float d = getSimpleDur();
            float end = currentInterval.getEnd();
            while (time - lastRepeatTime >= d
                    && lastRepeatTime + d < end) {
                lastRepeatTime += d;
                currentRepeatIteration++;
                fireTimeEvent(root.getRepeatEventName(), lastRepeatTime,
                              currentRepeatIteration);
            }
        }
        return dmt;
        // } finally { Trace.exit(); }
    }

    /**
     * Computes an interval from the begin and end instance time lists.
     * @param first indicates whether this is the first interval to compute
     * @param fixedBegin if true, specifies that the value given for
     *                   <code>beginAfter</code> is taken to be the actual begin
     *                   time for the interval; only the end value is computed.
     * @param beginAfter the earliest possible begin time for the computed
     *                   interval.
     * @param incl if true (and <code>!fixedBegin</code>), specifies that the
     *             new interval's begin time must be greater than
     *             <code>beginAfter</code>; otherwise, the begin time must be
     *             greater than or equal to <code>beginAfter</code>.
     */
    protected Interval computeInterval(boolean first, boolean fixedBegin,
                                       float beginAfter, boolean incl) {
        // Trace.enter(this, "computeInterval", new Object[] { new Boolean(first), new Boolean(fixedBegin), new Float(beginAfter)} ); try {
        // Trace.print("computing interval from begins=" + beginInstanceTimes + ", ends=" + endInstanceTimes);
        Iterator beginIterator = beginInstanceTimes.iterator();
        Iterator endIterator = endInstanceTimes.iterator();
        float parentSimpleDur = parent.getSimpleDur();
        InstanceTime endInstanceTime = endIterator.hasNext()
            ? (InstanceTime) endIterator.next()
            : null;
        boolean firstEnd = true;
        InstanceTime beginInstanceTime = null;
        InstanceTime nextBeginInstanceTime = null;
        for (;;) {
            float tempBegin;
            if (fixedBegin) {
                tempBegin = beginAfter;
                while (beginIterator.hasNext()) {
                    nextBeginInstanceTime = (InstanceTime) beginIterator.next();
                    if (nextBeginInstanceTime.getTime() > tempBegin) {
                        break;
                    }
                }
            } else {
                for (;;) {
                    if (!beginIterator.hasNext()) {
                        // ran out of begin values
                        // Trace.print("returning null interval");
                        return null;
                    }
                    beginInstanceTime = (InstanceTime) beginIterator.next();
                    tempBegin = beginInstanceTime.getTime();
                    if (incl && tempBegin >= beginAfter
                            || !incl && tempBegin > beginAfter) {
                        if (beginIterator.hasNext()) {
                            nextBeginInstanceTime =
                                (InstanceTime) beginIterator.next();
                            if (beginInstanceTime.getTime()
                                    == nextBeginInstanceTime.getTime()) {
                                // XXX Not sure if this is exactly correct to
                                //     skip past these identical times, but it
                                //     avoids an infinite loop of 0s intervals
                                //     being created.
                                nextBeginInstanceTime = null;
                                continue;
                            }
                        }
                        break;
                    }
                }
            }
            if (tempBegin >= parentSimpleDur) {
                // the begin value is after the parent has ended
                // Trace.print("returning null interval");
                return null;
            }
            float tempEnd;
            if (endTimes.length == 0) {
                // no 'end' attribute specified
                tempEnd = tempBegin + getActiveDur(tempBegin, INDEFINITE);
                // Trace.print("no end specified, so tempEnd = " + tempEnd);
            } else {
                if (endInstanceTimes.isEmpty()) {
                    tempEnd = UNRESOLVED;
                } else {
                    tempEnd = endInstanceTime.getTime();
                    if (first && !firstEnd && tempEnd == tempBegin
                            || !first && currentInterval != null
                                && tempEnd == currentInterval.getEnd()
                                && (incl && beginAfter >= tempEnd
                                        || !incl && beginAfter > tempEnd)) {
                        for (;;) {
                            if (!endIterator.hasNext()) {
                                if (endHasEventConditions()) {
                                    tempEnd = UNRESOLVED;
                                    break;
                                }
                                // Trace.print("returning null interval");
                                return null;
                            }
                            endInstanceTime = (InstanceTime) endIterator.next();
                            tempEnd = endInstanceTime.getTime();
                            if (tempEnd > tempBegin) {
                                break;
                            }
                        }
                    }
                    firstEnd = false;
                    for (;;) {
                        if (tempEnd >= tempBegin) {
                            break;
                        }
                        if (!endIterator.hasNext()) {
                            if (endHasEventConditions()) {
                                tempEnd = UNRESOLVED;
                                break;
                            }
                            // Trace.print("returning null interval");
                            return null;
                        }
                        endInstanceTime = (InstanceTime) endIterator.next();
                        tempEnd = endInstanceTime.getTime();
                    }
                }
                float ad = getActiveDur(tempBegin, tempEnd);
                tempEnd = tempBegin + ad;
            }
            if (!first || tempEnd > 0 || tempBegin == 0 && tempEnd == 0
                    || isUnresolved(tempEnd)) {
                // Trace.print("considering restart semantics");
                if (restartMode == RESTART_ALWAYS
                        && nextBeginInstanceTime != null) {
                    float nextBegin = nextBeginInstanceTime.getTime();
                    // Trace.print("nextBegin == " + nextBegin);
                    if (nextBegin < tempEnd || isUnresolved(tempEnd)) {
                        tempEnd = nextBegin;
                        endInstanceTime = nextBeginInstanceTime;
                    }
                }
                Interval i = new Interval(tempBegin, tempEnd,
                                          beginInstanceTime, endInstanceTime);
                // Trace.print("returning interval: " + i);
                return i;
            }
            if (fixedBegin) {
                // Trace.print("returning null interval");
                return null;
            }
            beginAfter = tempEnd;
        }
        // } finally { Trace.exit(); }
    }

    /**
     * Resets this element.
     */
    protected void reset(boolean clearCurrentBegin) {
        Iterator i = beginInstanceTimes.iterator();
        while (i.hasNext()) {
            InstanceTime it = (InstanceTime) i.next();
            if (it.getClearOnReset() &&
                    (clearCurrentBegin
                        || currentInterval == null
                        || currentInterval.getBeginInstanceTime() != it)) {
                i.remove();
            }
        }
        i = endInstanceTimes.iterator();
        while (i.hasNext()) {
            InstanceTime it = (InstanceTime) i.next();
            if (it.getClearOnReset()) {
                i.remove();
            }
        }
        if (isFrozen) {
            removeFill();
        }
        currentRepeatIteration = 0;
        lastRepeatTime = UNRESOLVED;
        isActive = false;
        isFrozen = false;
        lastSampleTime = UNRESOLVED;
        // XXX should reconvert resolved syncbase/wallclock/media-marker time
        //     instances into the parent simple timespace
    }

    /**
     * Parses the animation attributes for this timed element.
     */
    public void parseAttributes(String begin, String dur, String end,
                                String min, String max, String repeatCount,
                                String repeatDur, String fill,
                                String restart) {
        if (!hasParsed) {
            parseBegin(begin);
            parseDur(dur);
            parseEnd(end);
            parseMin(min);
            parseMax(max);
            if (this.min > this.max) {
                this.min = 0f;
                this.max = INDEFINITE;
            }
            parseRepeatCount(repeatCount);
            parseRepeatDur(repeatDur);
            parseFill(fill);
            parseRestart(restart);
            hasParsed = true;
        }
    }

    /**
     * Parses a new 'begin' attribute.
     */
    protected void parseBegin(String begin) {
        try {
            if (begin.length() == 0) {
                begin = SMIL_BEGIN_DEFAULT_VALUE;
            }
            beginTimes = TimingSpecifierListProducer.parseTimingSpecifierList
                (TimedElement.this, true, begin,
                 root.useSVG11AccessKeys, root.useSVG12AccessKeys);
        } catch (ParseException ex) {
            throw createException
                ("attribute.malformed",
                 new Object[] { null, SMIL_BEGIN_ATTRIBUTE });
        }
    }

    /**
     * Parses a new 'dur' attribute.
     */
    protected void parseDur(String dur) {
        if (dur.equals(SMIL_MEDIA_VALUE)) {
            durMedia = true;
            simpleDur = UNRESOLVED;
        } else {
            durMedia = false;
            if (dur.length() == 0 || dur.equals(SMIL_INDEFINITE_VALUE)) {
                simpleDur = INDEFINITE;
            } else {
                try {
                    simpleDur = parseClockValue(dur, false);
                } catch (ParseException e) {
                    throw createException
                        ("attribute.malformed",
                         new Object[] { null, SMIL_DUR_ATTRIBUTE });
                }
                if (simpleDur < 0) {
                    simpleDur = INDEFINITE;
                }
            }
        }
    }

    /**
     * Parses a clock value or offset and returns it as a float.
     */
    protected float parseClockValue(String s, boolean parseOffset)
            throws ParseException {
        ClockParser p = new ClockParser(parseOffset);
        class Handler implements ClockHandler {
            protected float v = 0;
            public void clockValue(float newClockValue) {
                v = newClockValue;
            }
        }

        Handler h = new Handler();
        p.setClockHandler(h);
        p.parse(s);
        return h.v;
    }

    /**
     * Parses a new 'end' attribute.
     */
    protected void parseEnd(String end) {
        try {
            endTimes = TimingSpecifierListProducer.parseTimingSpecifierList
                (TimedElement.this, false, end,
                 root.useSVG11AccessKeys, root.useSVG12AccessKeys);
        } catch (ParseException ex) {
            throw createException
                ("attribute.malformed",
                 new Object[] { null, SMIL_END_ATTRIBUTE });
        }
    }

    /**
     * Parses a new 'min' attribute.
     */
    protected void parseMin(String min) {
        if (min.equals(SMIL_MEDIA_VALUE)) {
            this.min = 0;
            minMedia = true;
        } else {
            minMedia = false;
            if (min.length() == 0) {
                this.min = 0;
            } else {
                try {
                    this.min = parseClockValue(min, false);
                } catch (ParseException ex) {
                	this.min = 0;
                }
                if (this.min < 0) {
                    this.min = 0;
                }
            }
        }
    }

    /**
     * Parses a new 'max' attribute.
     */
    protected void parseMax(String max) {
        if (max.equals(SMIL_MEDIA_VALUE)) {
            this.max = INDEFINITE;
            maxMedia = true;
        } else {
            maxMedia = false;
            if (max.length() == 0 || max.equals(SMIL_INDEFINITE_VALUE)) {
                this.max = INDEFINITE;
            } else {
                try {
                    this.max = parseClockValue(max, false);
                } catch (ParseException ex) {
                	this.max = INDEFINITE;
                }
                if (this.max < 0) {
                    this.max = 0;
                }
            }
        }
    }

    /**
     * Parses a new 'repeatCount' attribute.
     */
    protected void parseRepeatCount(String repeatCount) {
        if (repeatCount.length() == 0) {
            this.repeatCount = UNRESOLVED;
        } else if (repeatCount.equals(SMIL_INDEFINITE_VALUE)) {
            this.repeatCount = INDEFINITE;
        } else {
            try {
                this.repeatCount = Float.parseFloat(repeatCount);
                if (this.repeatCount > 0) {
                    return;
                }
            } catch (NumberFormatException ex) {
                throw createException
                    ("attribute.malformed",
                     new Object[] { null, SMIL_REPEAT_COUNT_ATTRIBUTE });
            }
        }
    }

    /**
     * Parses a new 'repeatDur' attribute.
     */
    protected void parseRepeatDur(String repeatDur) {
        try {
            if (repeatDur.length() == 0) {
                this.repeatDur = UNRESOLVED;
            } else if (repeatDur.equals(SMIL_INDEFINITE_VALUE)) {
                this.repeatDur = INDEFINITE;
            } else {
                this.repeatDur = parseClockValue(repeatDur, false);
            }
        } catch (ParseException ex) {
            throw createException
                ("attribute.malformed",
                 new Object[] { null, SMIL_REPEAT_DUR_ATTRIBUTE });
        }
    }

    /**
     * Parses a new 'fill' attribute.
     */
    protected void parseFill(String fill) {
        if (fill.length() == 0 || fill.equals(SMIL_REMOVE_VALUE)) {
            fillMode = FILL_REMOVE;
        } else if (fill.equals(SMIL_FREEZE_VALUE)) {
            fillMode = FILL_FREEZE;
        } else {
            throw createException
                ("attribute.malformed",
                 new Object[] { null, SMIL_FILL_ATTRIBUTE });
        }
    }

    /**
     * Parses a new 'restart' attribute.
     */
    protected void parseRestart(String restart) {
        if (restart.length() == 0 || restart.equals(SMIL_ALWAYS_VALUE)) {
            restartMode = RESTART_ALWAYS;
        } else if (restart.equals(SMIL_WHEN_NOT_ACTIVE_VALUE)) {
            restartMode = RESTART_WHEN_NOT_ACTIVE;
        } else if (restart.equals(SMIL_NEVER_VALUE)) {
            restartMode = RESTART_NEVER;
        } else {
            throw createException
                ("attribute.malformed",
                 new Object[] { null, SMIL_RESTART_ATTRIBUTE });
        }
    }

    /**
     * Initializes this timed element.
     */
    public void initialize() {
        for (int i = 0; i < beginTimes.length; i++) {
            beginTimes[i].initialize();
        }
        for (int i = 0; i < endTimes.length; i++) {
            endTimes[i].initialize();
        }
    }

    /**
     * Deinitializes this timed element.
     */
    public void deinitialize() {
        for (int i = 0; i < beginTimes.length; i++) {
            beginTimes[i].deinitialize();
        }
        for (int i = 0; i < endTimes.length; i++) {
            endTimes[i].deinitialize();
        }
    }

    /**
     * Adds a time to the begin time instance list that will cause
     * the element to begin immediately (if restart semantics allow it).
     */
    public void beginElement() {
        beginElement(0);
    }

    /**
     * Adds a time to the begin time instance list that will cause
     * the element to begin at some offset to the current time (if restart
     * semantics allow it).
     */
    public void beginElement(float offset) {
        float t = root.convertWallclockTime( Calendar.getInstance());
        InstanceTime it = new InstanceTime(null, t + offset, true);
        addInstanceTime(it, true);
    }

    /**
     * Adds a time to the end time instance list that will cause
     * the element to end immediately (if restart semantics allow it).
     */
    public void endElement() {
        endElement(0);
    }

    /**
     * Adds a time to the end time instance list that will cause
     * the element to end at some offset to the current time (if restart
     * semantics allow it).
     */
    public void endElement(float offset) {
        float t = root.convertWallclockTime(Calendar.getInstance());
        InstanceTime it = new InstanceTime(null, t + offset, true);
        addInstanceTime(it, false);
    }

    /**
     * Returns the last sample time of this element, in local active time.
     */
    public float getLastSampleTime() {
        return lastSampleTime;
    }

    /**
     * Returns the begin time of the current interval, in parent simple time,
     * or <code>Float.NaN</code> if the element is not active.
     */
    public float getCurrentBeginTime() {
        float begin;
        if (currentInterval == null
                || (begin = currentInterval.getBegin()) < lastSampleTime) {
            return Float.NaN;
        }
        return begin;
    }

    /**
     * Returns whether this element can be begun or restarted currently.
     */
    public boolean canBegin() {
        return currentInterval == null
            || isActive && restartMode != RESTART_NEVER;
    }

    /**
     * Returns whether this element can be ended currently.
     */
    public boolean canEnd() {
        return isActive;
    }

    /**
     * Returns the time that the document would seek to if this animation
     * element were hyperlinked to, or <code>NaN</code> if there is no
     * such begin time.
     */
    public float getHyperlinkBeginTime() {
        if (isActive) {
            return currentInterval.getBegin();
        }
        if (!beginInstanceTimes.isEmpty()) {
            return ((InstanceTime) beginInstanceTimes.get(0)).getTime();
        }
        return Float.NaN;
    }

    /**
     * Fires a TimeEvent of the given type on this element.
     * @param eventType the type of TimeEvent ("beginEvent", "endEvent"
     *                  or "repeatEvent").
     * @param time the timestamp of the event object
     * @param detail the repeat iteration, if this event is a repeat event
     */
    protected void fireTimeEvent(String eventType, float time, int detail) {
        Calendar t = (Calendar) root.getDocumentBeginTime().clone();
        t.add(Calendar.MILLISECOND, (int) Math.round(time * 1e3));
        fireTimeEvent(eventType, t, detail);
    }

    /**
     * Invoked by a {@link TimingSpecifier} to indicate that an event occurred
     * that would create a new instance time for this timed element.  These
     * will be processed at the beginning of the next tick.
     */
    void eventOccurred(TimingSpecifier t, Event e) {
        Set ts = (HashSet) handledEvents.get(e);
        if (ts == null) {
            ts = new HashSet();
            handledEvents.put(e, ts);
        }
        ts.add(t);
        root.currentIntervalWillUpdate();
    }

    /**
     * Fires a TimeEvent of the given type on this element.
     * @param eventType the type of TimeEvent ("beginEvent", "endEvent"
     *                  or "repeatEvent").
     * @param time the timestamp of the event object
     */
    protected abstract void fireTimeEvent(String eventType, Calendar time,
                                          int detail);

    /**
     * Invoked to indicate this timed element became active at the
     * specified time.
     * @param begin the time the element became active, in document simple time
     */
    protected abstract void toActive(float begin);

    /**
     * Invoked to indicate that this timed element became inactive.
     * @param stillActive if true, indicates that the element is still actually
     *                    active, but between the end of the computed repeat
     *                    duration and the end of the interval
     * @param isFrozen whether the element is frozen or not
     */
    protected abstract void toInactive(boolean stillActive, boolean isFrozen);

    /**
     * Invoked to indicate that this timed element has had its fill removed.
     */
    protected abstract void removeFill();

    /**
     * Invoked to indicate that this timed element has been sampled at the
     * given time.
     * @param simpleTime the sample time in local simple time
     * @param simpleDur the simple duration of the element
     * @param repeatIteration the repeat iteration during which the element
     *                        was sampled
     */
    protected abstract void sampledAt(float simpleTime, float simpleDur,
                                      int repeatIteration);

    /**
     * Invoked to indicate that this timed element has been sampled
     * at the end of its active time, at an integer multiple of the
     * simple duration.  This is the "last" value that will be used
     * for filling, which cannot be sampled normally.
     */
    protected abstract void sampledLastValue(int repeatIteration);

    /**
     * Returns the timed element with the given ID.
     */
    protected abstract TimedElement getTimedElementById(String id);

    /**
     * Returns the event target with the given ID.
     */
    protected abstract EventTarget getEventTargetById(String id);

    /**
     * Returns the event target that should be listened to for
     * access key events.
     */
    protected abstract EventTarget getRootEventTarget();

    /**
     * Returns the DOM element that corresponds to this timed element, if
     * such a DOM element exists.
     */
    public abstract Element getElement();

    /**
     * Returns the target of this animation as an {@link EventTarget}.  Used
     * for eventbase timing specifiers where the element ID is omitted.
     */
    protected abstract EventTarget getAnimationEventTarget();

    /**
     * Returns whether this timed element comes before the given timed element
     * in document order.
     */
    public abstract boolean isBefore(TimedElement other);

    /**
     * Returns whether this timed element is for a constant animation (i.e., a
     * 'set' animation.
     */
    protected abstract boolean isConstantAnimation();

    /**
     * Creates and returns a new {@link AnimationException}.
     */
    public AnimationException createException(String code, Object[] params) {
        Element e = getElement();
        if (e != null) {
            params[0] = e.getNodeName();
        }
        return new AnimationException(this, code, params);
    }

    /**
     * The error messages bundle class name.
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.anim.resources.Messages";

    /**
     * The localizable support for the error messages.
     */
    protected static LocalizableSupport localizableSupport =
        new LocalizableSupport(RESOURCES, TimedElement.class.getClassLoader());

    /**
     * Implements {@link org.apache.flex.forks.batik.i18n.Localizable#setLocale(java.util.Locale)}.
     */
    public static void setLocale( Locale l) {
        localizableSupport.setLocale(l);
    }

    /**
     * Implements {@link org.apache.flex.forks.batik.i18n.Localizable#getLocale()}.
     */
    public static Locale getLocale() {
        return localizableSupport.getLocale();
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.Localizable#formatMessage(String,Object[])}.
     */
    public static String formatMessage(String key, Object[] args)
        throws MissingResourceException {
        return localizableSupport.formatMessage(key, args);
    }

    /**
     * Returns a string representation of the given time value.
     */
    public static String toString(float time) {
        if (Float.isNaN(time)) {
            return "UNRESOLVED";
        } else if (time == Float.POSITIVE_INFINITY) {
            return "INDEFINITE";
        } else {
            return Float.toString(time);
        }
    }
}
