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

import java.util.Calendar;
import java.util.Iterator;
import java.util.LinkedList;

import org.apache.flex.forks.batik.util.DoublyIndexedSet;

/**
 * An abstract base class for the root time container element
 * for a document.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimedDocumentRoot.java 580685 2007-09-30 09:07:29Z cam $
 */
public abstract class TimedDocumentRoot extends TimeContainer {

    /**
     * The wallclock time that the document began.
     */
    protected Calendar documentBeginTime;

    /**
     * Allows the use of accessKey() timing specifiers with a single
     * character, as specified in SVG 1.1.
     */
    protected boolean useSVG11AccessKeys;

    /**
     * Allows the use of accessKey() timing specifiers with a DOM 3
     * key name, as specified in SVG 1.2.
     */
    protected boolean useSVG12AccessKeys;

    /**
     * A set to determine when propagation of new Instance times should
     * be stopped.
     */
    protected DoublyIndexedSet propagationFlags = new DoublyIndexedSet();

    /**
     * List of {link TimegraphListener}s to be notified of changes to the
     * timed elements in this document.
     */
    protected LinkedList listeners = new LinkedList();

    /**
     * Whether the document is currently being sampled.
     */
    protected boolean isSampling;

    /**
     * Whether the document is currently being sampled for a hyperlink.
     */
    protected boolean isHyperlinking;

    /**
     * Creates a new TimedDocumentRoot.
     * @param useSVG11AccessKeys allows the use of accessKey() timing
     *                           specifiers with a single character
     * @param useSVG12AccessKeys allows the use of accessKey() with a
     *                           DOM 3 key name
     */
    public TimedDocumentRoot(boolean useSVG11AccessKeys,
                             boolean useSVG12AccessKeys) {
        root = this;
        this.useSVG11AccessKeys = useSVG11AccessKeys;
        this.useSVG12AccessKeys = useSVG12AccessKeys;
    }

    /**
     * Returns the implicit duration of the element.  The document root
     * has an {@link #INDEFINITE} implicit duration.
     */
    protected float getImplicitDur() {
        return INDEFINITE;
    }

    /**
     * Returns the default begin time for the given child
     * timed element.  In SVG, this is always 0, since the
     * only time container is the root SVG element, which acts
     * like a 'par'.
     */
    public float getDefaultBegin(TimedElement child) {
        return 0.0f;
    }

    /**
     * Returns the last sampled document time.
     */
    public float getCurrentTime() {
        return lastSampleTime;
    }

    /**
     * Returns whether the document is currently being sampled.
     */
    public boolean isSampling() {
        return isSampling;
    }

    /**
     * Returns whether the document is currently being sampled for a hyperlink.
     */
    public boolean isHyperlinking() {
        return isHyperlinking;
    }

    /**
     * Samples the entire timegraph at the given time.
     */
    public float seekTo(float time, boolean hyperlinking) {
        // Trace.enter(this, "seekTo", new Object[] { new Float(time) } ); try {
        isSampling = true;
        lastSampleTime = time;
        isHyperlinking = hyperlinking;
        propagationFlags.clear();
        // No time containers in SVG, so we don't have to worry
        // about a partial ordering of timed elements to sample.
        float mint = Float.POSITIVE_INFINITY;
        TimedElement[] es = getChildren();
        for (int i = 0; i < es.length; i++) {
            float t = es[i].sampleAt(time, hyperlinking);
            if (t < mint) {
                mint = t;
            }
        }
        boolean needsUpdates;
        do {
            needsUpdates = false;
            for (int i = 0; i < es.length; i++) {
                if (es[i].shouldUpdateCurrentInterval) {
                    needsUpdates = true;
                    // System.err.print("{" + ((Test.AnimateElement) es[i]).id + "} ");
                    float t = es[i].sampleAt(time, hyperlinking);
                    if (t < mint) {
                        mint = t;
                    }
                }
            }
        } while (needsUpdates);
        isSampling = false;
        if (hyperlinking) {
            root.currentIntervalWillUpdate();
        }
        return mint;
        // } finally { Trace.exit(); }
    }

    /**
     * Resets the entire timegraph.
     */
    public void resetDocument(Calendar documentBeginTime) {
        if (documentBeginTime == null) {
            this.documentBeginTime = Calendar.getInstance();
        } else {
            this.documentBeginTime = documentBeginTime;
        }
        reset(true);
    }

    /**
     * Returns the wallclock time that the document began.
     */
    public Calendar getDocumentBeginTime() {
        return documentBeginTime;
    }

    /**
     * Converts an epoch time to document time.
     */
    public float convertEpochTime(long t) {
        long begin = documentBeginTime.getTime().getTime();
        return (t - begin) / 1000f;
    }

    /**
     * Converts a wallclock time to document time.
     */
    public float convertWallclockTime(Calendar time) {
        long begin = documentBeginTime.getTime().getTime();
        long t = time.getTime().getTime();
        return (t - begin) / 1000f;
    }

    /**
     * Adds a {@link TimegraphListener} to the document.
     */
    public void addTimegraphListener(TimegraphListener l) {
        listeners.add(l);
    }

    /**
     * Removes a {@link TimegraphListener} from the document.
     */
    public void removeTimegraphListener(TimegraphListener l) {
        listeners.remove(l);
    }

    /**
     * Fires an {@link TimegraphListener#elementAdded} event on all
     * timegraph listeners.
     */
    void fireElementAdded(TimedElement e) {
        Iterator i = listeners.iterator();
        while (i.hasNext()) {
            ((TimegraphListener) i.next()).elementAdded(e);
        }
    }

    /**
     * Fires an {@link TimegraphListener#elementRemoved} event on all
     * timegraph listeners.
     */
    void fireElementRemoved(TimedElement e) {
        Iterator i = listeners.iterator();
        while (i.hasNext()) {
            ((TimegraphListener) i.next()).elementRemoved(e);
        }
    }

    // XXX Add fire* methods for the other events in TimegraphListener, and make
    //     TimedElement fire them.

    /**
     * Returns whether the specified newly created {@link Interval} should 
     * propagate its times to the given {@link TimingSpecifier}.
     * @param i the Interval that has just been created
     * @param ts the TimingSpecifier that is a dependent of the Interval
     * @param isBegin whether the dependency is on the begin or end time of
     *        the Interval
     */
    boolean shouldPropagate(Interval i, TimingSpecifier ts, boolean isBegin) {
        InstanceTime it = isBegin ? i.getBeginInstanceTime()
                                  : i.getEndInstanceTime();
        if (propagationFlags.contains(it, ts)) {
            return false;
        }
        propagationFlags.add(it, ts);
        return true;
    }

    /**
     * Invoked by timed elements in this document to indicate that the current
     * interval will be re-evaluated at the next sample.  This should be
     * overridden in a concrete class so that ticks can be scheduled immediately
     * if they are currently paused due to no animations being active.
     */
    protected void currentIntervalWillUpdate() {
    }

    /**
     * Returns the namespace URI of the event that corresponds to the given
     * animation event name.
     */
    protected abstract String getEventNamespaceURI(String eventName);

    /**
     * Returns the type of the event that corresponds to the given
     * animation event name.
     */
    protected abstract String getEventType(String eventName);

    /**
     * Returns the name of the repeat event.
     * @return either "repeat" or "repeatEvent"
     */
    protected abstract String getRepeatEventName();
}
