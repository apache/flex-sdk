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
package org.apache.flex.forks.batik.bridge;

import java.awt.Color;
import java.awt.Paint;
import java.lang.ref.WeakReference;
import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Arrays;
import java.util.Set;

import org.apache.flex.forks.batik.anim.AnimationEngine;
import org.apache.flex.forks.batik.anim.AnimationException;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.anim.timing.TimedDocumentRoot;
import org.apache.flex.forks.batik.anim.timing.TimedElement;
import org.apache.flex.forks.batik.anim.values.AnimatableAngleValue;
import org.apache.flex.forks.batik.anim.values.AnimatableAngleOrIdentValue;
import org.apache.flex.forks.batik.anim.values.AnimatableBooleanValue;
import org.apache.flex.forks.batik.anim.values.AnimatableIntegerValue;
import org.apache.flex.forks.batik.anim.values.AnimatableLengthValue;
import org.apache.flex.forks.batik.anim.values.AnimatableLengthListValue;
import org.apache.flex.forks.batik.anim.values.AnimatableLengthOrIdentValue;
import org.apache.flex.forks.batik.anim.values.AnimatableNumberValue;
import org.apache.flex.forks.batik.anim.values.AnimatableNumberListValue;
import org.apache.flex.forks.batik.anim.values.AnimatableNumberOrPercentageValue;
import org.apache.flex.forks.batik.anim.values.AnimatablePathDataValue;
import org.apache.flex.forks.batik.anim.values.AnimatablePointListValue;
import org.apache.flex.forks.batik.anim.values.AnimatablePreserveAspectRatioValue;
import org.apache.flex.forks.batik.anim.values.AnimatableNumberOrIdentValue;
import org.apache.flex.forks.batik.anim.values.AnimatableRectValue;
import org.apache.flex.forks.batik.anim.values.AnimatableStringValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.anim.values.AnimatableColorValue;
import org.apache.flex.forks.batik.anim.values.AnimatablePaintValue;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.value.FloatValue;
import org.apache.flex.forks.batik.css.engine.value.StringValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;
import org.apache.flex.forks.batik.dom.svg.SVGStylableElement;
import org.apache.flex.forks.batik.parser.DefaultPreserveAspectRatioHandler;
import org.apache.flex.forks.batik.parser.FloatArrayProducer;
import org.apache.flex.forks.batik.parser.DefaultLengthHandler;
import org.apache.flex.forks.batik.parser.LengthArrayProducer;
import org.apache.flex.forks.batik.parser.LengthHandler;
import org.apache.flex.forks.batik.parser.LengthListParser;
import org.apache.flex.forks.batik.parser.LengthParser;
import org.apache.flex.forks.batik.parser.NumberListParser;
import org.apache.flex.forks.batik.parser.PathArrayProducer;
import org.apache.flex.forks.batik.parser.PathParser;
import org.apache.flex.forks.batik.parser.PointsParser;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.PreserveAspectRatioHandler;
import org.apache.flex.forks.batik.parser.PreserveAspectRatioParser;
import org.apache.flex.forks.batik.util.RunnableQueue;
import org.apache.flex.forks.batik.util.SMILConstants;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.CSSValue;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.svg.SVGAngle;
import org.w3c.dom.svg.SVGLength;
import org.w3c.dom.svg.SVGPreserveAspectRatio;

/**
 * An AnimationEngine for SVG documents.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGAnimationEngine.java 579854 2007-09-27 00:07:53Z cam $
 */
public class SVGAnimationEngine extends AnimationEngine {

    /**
     * The BridgeContext to use for value parsing.
     */
    protected BridgeContext ctx;

    /**
     * The CSSEngine used for CSS value parsing.
     */
    protected CSSEngine cssEngine;

    /**
     * Whether animation processing has started.  This affects whether
     * animation element bridges add their animation on to the initial
     * bridge list, or process them immediately.
     */
    protected boolean started;

    /**
     * The Runnable that ticks the document.
     */
    protected AnimationTickRunnable animationTickRunnable;

    /**
     * The factory for unparsed string values.
     */
    protected UncomputedAnimatableStringValueFactory
        uncomputedAnimatableStringValueFactory =
            new UncomputedAnimatableStringValueFactory();

    /**
     * The factory for length-or-ident values.
     */
    protected AnimatableLengthOrIdentFactory
        animatableLengthOrIdentFactory = new AnimatableLengthOrIdentFactory();

    /**
     * The factory for number-or-ident values.
     */
    protected AnimatableNumberOrIdentFactory
        animatableNumberOrIdentFactory =
            new AnimatableNumberOrIdentFactory(false);

    /**
     * Factories for {@link AnimatableValue} parsing.
     */
    protected Factory[] factories = {
        null, // TYPE_UNKNOWN
        new AnimatableIntegerValueFactory(), // TYPE_INTEGER
        new AnimatableNumberValueFactory(), // TYPE_NUMBER
        new AnimatableLengthValueFactory(), // TYPE_LENGTH
        null, // TYPE_NUMBER_OPTIONAL_NUMBER
        new AnimatableAngleValueFactory(), // TYPE_ANGLE
        new AnimatableColorValueFactory(), // TYPE_COLOR
        new AnimatablePaintValueFactory(), // TYPE_PAINT
        null, // TYPE_PERCENTAGE
        null, // TYPE_TRANSFORM_LIST
        uncomputedAnimatableStringValueFactory, // TYPE_URI
        null, // TYPE_FREQUENCY
        null, // TYPE_TIME
        new AnimatableNumberListValueFactory(), // TYPE_NUMBER_LIST
        new AnimatableLengthListValueFactory(), // TYPE_LENGTH_LIST
        uncomputedAnimatableStringValueFactory, // TYPE_IDENT
        uncomputedAnimatableStringValueFactory, // TYPE_CDATA
        animatableLengthOrIdentFactory, // TYPE_LENGTH_OR_INHERIT
        uncomputedAnimatableStringValueFactory, // TYPE_IDENT_LIST
        uncomputedAnimatableStringValueFactory, // TYPE_CLIP_VALUE
        uncomputedAnimatableStringValueFactory, // TYPE_URI_OR_IDENT
        uncomputedAnimatableStringValueFactory, // TYPE_CURSOR_VALUE
        new AnimatablePathDataFactory(), // TYPE_PATH_DATA
        uncomputedAnimatableStringValueFactory, // TYPE_ENABLE_BACKGROUND_VALUE
        null, // TYPE_TIME_VALUE_LIST
        animatableNumberOrIdentFactory, // TYPE_NUMBER_OR_INHERIT
        uncomputedAnimatableStringValueFactory, // TYPE_FONT_FAMILY_VALUE
        null, // TYPE_FONT_FACE_FONT_SIZE_VALUE
        new AnimatableNumberOrIdentFactory(true), // TYPE_FONT_WEIGHT_VALUE
        new AnimatableAngleOrIdentFactory(), // TYPE_ANGLE_OR_IDENT
        null, // TYPE_KEY_SPLINES_VALUE
        new AnimatablePointListValueFactory(), // TYPE_POINTS_VALUE
        new AnimatablePreserveAspectRatioValueFactory(), // TYPE_PRESERVE_ASPECT_RATIO_VALUE
        null, // TYPE_URI_LIST
        uncomputedAnimatableStringValueFactory, // TYPE_LENGTH_LIST_OR_IDENT
        null, // TYPE_CHARACTER_OR_UNICODE_RANGE_LIST
        null, // TYPE_UNICODE_RANGE_LIST
        null, // TYPE_FONT_VALUE
        null, // TYPE_FONT_DECSRIPTOR_SRC_VALUE
        animatableLengthOrIdentFactory, // TYPE_FONT_SIZE_VALUE
        animatableLengthOrIdentFactory, // TYPE_BASELINE_SHIFT_VALUE
        animatableLengthOrIdentFactory, // TYPE_KERNING_VALUE
        animatableLengthOrIdentFactory, // TYPE_SPACING_VALUE
        animatableLengthOrIdentFactory, // TYPE_LINE_HEIGHT_VALUE
        animatableNumberOrIdentFactory, // TYPE_FONT_SIZE_ADJUST_VALUE
        null, // TYPE_LANG_VALUE
        null, // TYPE_LANG_LIST_VALUE
        new AnimatableNumberOrPercentageValueFactory(), // TYPE_NUMBER_OR_PERCENTAGE
        null, // TYPE_TIMING_SPECIFIER_LIST
        new AnimatableBooleanValueFactory(), // TYPE_BOOLEAN
        new AnimatableRectValueFactory() // TYPE_RECT
    };

    /**
     * Whether the document is an SVG 1.2 document.
     */
    protected boolean isSVG12;

    /**
     * List of bridges that will be initialized when the document is started.
     */
    protected LinkedList initialBridges = new LinkedList();

    /**
     * A StyleMap used by the {@link Factory}s when computing CSS values.
     */
    protected StyleMap dummyStyleMap;

    /**
     * The thread that ticks the animation engine.
     */
    protected AnimationThread animationThread;

    /**
     * The animation limiting mode.
     */
    protected int animationLimitingMode;

    /**
     * The amount of animation limiting.
     */
    protected float animationLimitingAmount;

    /**
     * Set of SMIL animation event names for SVG 1.1.
     */
    protected static final Set animationEventNames11 = new HashSet();

    /**
     * Set of SMIL animation event names for SVG 1.2.
     */
    protected static final Set animationEventNames12 = new HashSet();

    static {
        String[] eventNamesCommon = {
            "click", "mousedown", "mouseup", "mouseover", "mousemove",
            "mouseout", "beginEvent", "endEvent"
        };
        String[] eventNamesSVG11 = {
            "DOMSubtreeModified", "DOMNodeInserted", "DOMNodeRemoved",
            "DOMNodeRemovedFromDocument", "DOMNodeInsertedIntoDocument",
            "DOMAttrModified", "DOMCharacterDataModified", "SVGLoad",
            "SVGUnload", "SVGAbort", "SVGError", "SVGResize", "SVGScroll",
            "repeatEvent"
        };
        String[] eventNamesSVG12 = {
            "load", "resize", "scroll", "zoom"
        };
        for (int i = 0; i < eventNamesCommon.length; i++) {
            animationEventNames11.add(eventNamesCommon[i]);
            animationEventNames12.add(eventNamesCommon[i]);
        }
        for (int i = 0; i < eventNamesSVG11.length; i++) {
            animationEventNames11.add(eventNamesSVG11[i]);
        }
        for (int i = 0; i < eventNamesSVG12.length; i++) {
            animationEventNames12.add(eventNamesSVG12[i]);
        }
    }

    /**
     * Creates a new SVGAnimationEngine.
     */
    public SVGAnimationEngine(Document doc, BridgeContext ctx) {
        super(doc);
        this.ctx = ctx;
        SVGOMDocument d = (SVGOMDocument) doc;
        cssEngine = d.getCSSEngine();
        dummyStyleMap = new StyleMap(cssEngine.getNumberOfProperties());
        isSVG12 = d.isSVG12();
    }

    /**
     * Disposes this animation engine.
     */
    public void dispose() {
        synchronized (this) {
            pause();
            super.dispose();
        }
    }

    /**
     * Adds an animation element bridge to the list of bridges that
     * require initializing when the document is started.
     */
    public void addInitialBridge(SVGAnimationElementBridge b) {
        if (initialBridges != null) {
            initialBridges.add(b);
        }
    }

    /**
     * Returns whether animation processing has begun.
     */
    public boolean hasStarted() {
        return started;
    }

    /**
     * Parses an AnimatableValue.
     */
    public AnimatableValue parseAnimatableValue(Element animElt,
                                                AnimationTarget target,
                                                String ns, String ln,
                                                boolean isCSS,
                                                String s) {
        SVGOMElement elt = (SVGOMElement) target.getElement();
        int type;
        if (isCSS) {
            type = elt.getPropertyType(ln);
        } else {
            type = elt.getAttributeType(ns, ln);
        }
        Factory factory = factories[type];
        if (factory == null) {
            String an = ns == null ? ln : '{' + ns + '}' + ln;
            throw new BridgeException
                (ctx, animElt, "attribute.not.animatable",
                 new Object[] { target.getElement().getNodeName(), an });
        }
        return factories[type].createValue(target, ns, ln, isCSS, s);
    }

    /**
     * Returns an AnimatableValue for the underlying value of a CSS property.
     */
    public AnimatableValue getUnderlyingCSSValue(Element animElt,
                                                 AnimationTarget target,
                                                 String pn) {
        ValueManager[] vms = cssEngine.getValueManagers();
        int idx = cssEngine.getPropertyIndex(pn);
        if (idx != -1) {
            int type = vms[idx].getPropertyType();
            Factory factory = factories[type];
            if (factory == null) {
                throw new BridgeException
                    (ctx, animElt, "attribute.not.animatable",
                     new Object[] { target.getElement().getNodeName(), pn });
            }
            SVGStylableElement e = (SVGStylableElement) target.getElement();
            CSSStyleDeclaration over = e.getOverrideStyle();
            String oldValue = over.getPropertyValue(pn);
            if (oldValue != null) {
                over.removeProperty(pn);
            }
            Value v = cssEngine.getComputedStyle(e, null, idx);
            if (oldValue != null && !oldValue.equals("")) {
                over.setProperty(pn, oldValue, null);
            }
            return factories[type].createValue(target, pn, v);
        }
        // XXX Doesn't handle shorthands.
        return null;
    }

    /**
     * Pauses the animations.
     */
    public void pause() {
        super.pause();
        UpdateManager um = ctx.getUpdateManager();
        if (um != null) {
            um.getUpdateRunnableQueue().setIdleRunnable(null);
        }
    }

    /**
     * Pauses the animations.
     */
    public void unpause() {
        super.unpause();
        UpdateManager um = ctx.getUpdateManager();
        if (um != null) {
            um.getUpdateRunnableQueue().setIdleRunnable(animationTickRunnable);
        }
    }

    /**
     * Returns the current document time.
     */
    public float getCurrentTime() {
        boolean p = pauseTime != 0;
        unpause();
        float t = timedDocumentRoot.getCurrentTime();
        if (p) {
            pause();
        }
        return t;
    }

    /**
     * Sets the current document time.
     */
    public float setCurrentTime(float t) {
        float ret = super.setCurrentTime(t);
        if (animationTickRunnable != null) {
            animationTickRunnable.resume();
        }
        return ret;
    }

    /**
     * Creates a new returns a new TimedDocumentRoot object for the document.
     */
    protected TimedDocumentRoot createDocumentRoot() {
        return new AnimationRoot();
    }

    /**
     * Starts the animation engine.
     */
    public void start(long documentStartTime) {
        if (started) {
            return;
        }
        started = true;
        try {
            try {
                Calendar cal = Calendar.getInstance();
                cal.setTime(new Date(documentStartTime));
                timedDocumentRoot.resetDocument(cal);
                Object[] bridges = initialBridges.toArray();
                initialBridges = null;
                for (int i = 0; i < bridges.length; i++) {
                    SVGAnimationElementBridge bridge =
                        (SVGAnimationElementBridge) bridges[i];
                    bridge.initializeAnimation();
                }
                for (int i = 0; i < bridges.length; i++) {
                    SVGAnimationElementBridge bridge =
                        (SVGAnimationElementBridge) bridges[i];
                    bridge.initializeTimedElement();
                }
                // tick(0, false);
                // animationThread = new AnimationThread();
                // animationThread.start();
                UpdateManager um = ctx.getUpdateManager();
                if (um != null) {
                    RunnableQueue q = um.getUpdateRunnableQueue();
                    animationTickRunnable = new AnimationTickRunnable(q, this);
                    q.setIdleRunnable(animationTickRunnable);
                }
            } catch (AnimationException ex) {
                throw new BridgeException(ctx, ex.getElement().getElement(),
                                          ex.getMessage());
            }
        } catch (Exception ex) {
            if (ctx.getUserAgent() == null) {
                ex.printStackTrace();
            } else {
                ctx.getUserAgent().displayError(ex);
            }
        }
    }

    /**
     * Sets the animation limiting mode to "none".
     */
    public void setAnimationLimitingNone() {
        animationLimitingMode = 0;
    }

    /**
     * Sets the animation limiting mode to a percentage of CPU.
     * @param pc the maximum percentage of CPU to use (0 &lt; pc ≤ 1)
     */
    public void setAnimationLimitingCPU(float pc) {
        animationLimitingMode = 1;
        animationLimitingAmount = pc;
    }

    /**
     * Sets the animation limiting mode to a number of frames per second.
     * @param fps the maximum number of frames per second (fps &gt; 0)
     */
    public void setAnimationLimitingFPS(float fps) {
        animationLimitingMode = 2;
        animationLimitingAmount = fps;
    }

    /**
     * A class for the root time container.
     */
    protected class AnimationRoot extends TimedDocumentRoot {

        /**
         * Creates a new AnimationRoot object.
         */
        public AnimationRoot() {
            super(!isSVG12, isSVG12);
        }

        /**
         * Returns the namespace URI of the event that corresponds to the given
         * animation event name.
         */
        protected String getEventNamespaceURI(String eventName) {
            if (!isSVG12) {
                return null;
            }
            if (eventName.equals("focusin")
                    || eventName.equals("focusout")
                    || eventName.equals("activate")
                    || animationEventNames12.contains(eventName)) {
                return XMLConstants.XML_EVENTS_NAMESPACE_URI;
            }
            return null;
        }

        /**
         * Returns the type of the event that corresponds to the given
         * animation event name.
         */
        protected String getEventType(String eventName) {
            if (eventName.equals("focusin")) {
                return "DOMFocusIn";
            } else if (eventName.equals("focusout")) {
                return "DOMFocusOut";
            } else if (eventName.equals("activate")) {
                return "DOMActivate";
            }
            if (isSVG12) {
                if (animationEventNames12.contains(eventName)) {
                    return eventName;
                }
            } else {
                if (animationEventNames11.contains(eventName)) {
                    return eventName;
                }
            }
            return null;
        }

        /**
         * Returns the name of the repeat event.
         * @return "repeatEvent" for SVG
         */
        protected String getRepeatEventName() {
            return SMILConstants.SMIL_REPEAT_EVENT_NAME;
        }

        /**
         * Fires a TimeEvent of the given type on this element.
         * @param eventType the type of TimeEvent ("beginEvent", "endEvent"
         *                  or "repeatEvent"/"repeat").
         * @param time the timestamp of the event object
         */
        protected void fireTimeEvent(String eventType, Calendar time,
                                     int detail) {
            AnimationSupport.fireTimeEvent
                ((EventTarget) document, eventType, time, detail);
        }

        /**
         * Invoked to indicate this timed element became active at the
         * specified time.
         * @param begin the time the element became active, in document simple time
         */
        protected void toActive(float begin) {
        }

        /**
         * Invoked to indicate that this timed element became inactive.
         * @param stillActive if true, indicates that the element is still
         *                    actually active, but between the end of the
         *                    computed repeat duration and the end of the
         *                    interval
         * @param isFrozen whether the element is frozen or not
         */
        protected void toInactive(boolean stillActive, boolean isFrozen) {
        }

        /**
         * Invoked to indicate that this timed element has had its fill removed.
         */
        protected void removeFill() {
        }

        /**
         * Invoked to indicate that this timed element has been sampled at the
         * given time.
         * @param simpleTime the sample time in local simple time
         * @param simpleDur the simple duration of the element
         * @param repeatIteration the repeat iteration during which the element
         *                        was sampled
         */
        protected void sampledAt(float simpleTime, float simpleDur,
                                 int repeatIteration) {
        }

        /**
         * Invoked to indicate that this timed element has been sampled
         * at the end of its active time, at an integer multiple of the
         * simple duration.  This is the "last" value that will be used
         * for filling, which cannot be sampled normally.
         */
        protected void sampledLastValue(int repeatIteration) {
        }

        /**
         * Returns the timed element with the given ID.
         */
        protected TimedElement getTimedElementById(String id) {
            return AnimationSupport.getTimedElementById(id, document);
        }

        /**
         * Returns the event target with the given ID.
         */
        protected EventTarget getEventTargetById(String id) {
            return AnimationSupport.getEventTargetById(id, document);
        }

        /**
         * Returns the target of this animation as an {@link EventTarget}.  Used
         * for eventbase timing specifiers where the element ID is omitted.
         */
        protected EventTarget getAnimationEventTarget() {
            return null;
        }

        /**
         * Returns the event target that should be listened to for
         * access key events.
         */
        protected EventTarget getRootEventTarget() {
            return (EventTarget) document;
        }

        /**
         * Returns the DOM element that corresponds to this timed element, if
         * such a DOM element exists.
         */
        public Element getElement() {
            return null;
        }

        /**
         * Returns whether this timed element comes before the given timed
         * element in document order.
         */
        public boolean isBefore(TimedElement other) {
            return false;
        }

        /**
         * Invoked by timed elements in this document to indicate that the
         * current interval will be re-evaluated at the next sample.
         */
        protected void currentIntervalWillUpdate() {
            if (animationTickRunnable != null) {
                animationTickRunnable.resume();
            }
        }
    }

    /**
     * Idle runnable to tick the animation, that reads times from System.in.
     */
    protected static class DebugAnimationTickRunnable extends AnimationTickRunnable {

        float t = 0f;

        public DebugAnimationTickRunnable(RunnableQueue q, SVGAnimationEngine eng) {
            super(q, eng);
            waitTime = Long.MAX_VALUE;
            new Thread() {
                public void run() {
                    java.io.BufferedReader r = new java.io.BufferedReader(new java.io.InputStreamReader(System.in));
                    System.out.println("Enter times.");
                    for (;;) {
                        String s;
                        try {
                            s = r.readLine();
                        } catch (java.io.IOException e) {
                            s = null;
                        }
                        if (s == null) {
                            System.exit(0);
                        }
                        t = Float.parseFloat(s);
                        DebugAnimationTickRunnable.this.resume();
                    }
                }
            }.start();
        }

        public void resume() {
            waitTime = 0;
            Object lock = q.getIteratorLock();
            synchronized (lock) {
                lock.notify();
            }
        }

        public long getWaitTime() {
            long wt = waitTime;
            waitTime = Long.MAX_VALUE;
            return wt;
        }

        public void run() {
            SVGAnimationEngine eng = getAnimationEngine();
            synchronized (eng) {
                try {
                    try {
                        eng.tick(t, false);
                    } catch (AnimationException ex) {
                        throw new BridgeException
                            (eng.ctx, ex.getElement().getElement(),
                             ex.getMessage());
                    }
                } catch (Exception ex) {
                    if (eng.ctx.getUserAgent() == null) {
                        ex.printStackTrace();
                    } else {
                        eng.ctx.getUserAgent().displayError(ex);
                    }
                }
            }
        }
    }

    /**
     * Idle runnable to tick the animation.
     */
    protected static class AnimationTickRunnable
            implements RunnableQueue.IdleRunnable {

        /**
         * Calendar instance used for passing current time values to the
         * animation timing system.
         */
        protected Calendar time = Calendar.getInstance();

//         /**
//          * The current document time in seconds, truncated.
//          */
//         protected double second = -1.;

//         /**
//          * The number of frames that have been ticked so far this second.
//          */
//         protected int frames;

        /**
         * The number of milliseconds to wait until the next animation tick.
         * This is returned by {@link #getWaitTime()}.
         */
        protected long waitTime;

        /**
         * The RunnableQueue in which this is the
         * {@link RunnableQueue.IdleRunnable}.
         */
        protected RunnableQueue q;

        /**
         * The number of past tick times to keep, for computing the average
         * time per tick.
         */
        private static final int NUM_TIMES = 8;

        /**
         * The past tick times.
         */
        protected long[] times = new long[NUM_TIMES];

        /**
         * The sum of the times in {@link #times}.
         */
        protected long sumTime;

        /**
         * The current index into {@link #times}.
         */
        protected int timeIndex;

        /**
         * A weak reference to the SVGAnimationEngine this AnimationTickRunnable
         * is for.  We make this a WeakReference so that a ticking animation
         * engine does not prevent from being GCed.
         */
        protected WeakReference engRef;

        /**
         * The maximum number of consecutive exceptions to allow before
         * stopping the report of them.
         */
        protected static final int MAX_EXCEPTION_COUNT = 10;

        /**
         * The number of consecutive exceptions that have been thrown.  This is
         * used to detect when exceptions are occurring every tick, and to stop
         * reporting them when this happens.
         */
        protected int exceptionCount;

        /**
         * Creates a new AnimationTickRunnable.
         */
        public AnimationTickRunnable(RunnableQueue q, SVGAnimationEngine eng) {
            this.q = q;
            this.engRef = new WeakReference(eng);
            // Initialize the past times to 100ms.
            Arrays.fill(times, 100);
            sumTime = 100 * NUM_TIMES;
        }

        /**
         * Forces an animation update, if the {@link RunnableQueue} is
         * currently waiting.
         */
        public void resume() {
            waitTime = 0;
            Object lock = q.getIteratorLock();
            synchronized (lock) {
                lock.notify();
            }
        }

        /**
         * Returns the system time that can be safely waited until before this
         * {@link Runnable} is run again.
         *
         * @return time to wait until, <code>0</code> if no waiting can
         *         be done, or {@link Long#MAX_VALUE} if the {@link Runnable}
         *         should not be run again at this time
         */
        public long getWaitTime() {
            return waitTime;
        }

        /**
         * Performs one tick of the animation.
         */
        public void run() {
            SVGAnimationEngine eng = getAnimationEngine();
            synchronized (eng) {
                int animationLimitingMode = eng.animationLimitingMode;
                float animationLimitingAmount = eng.animationLimitingAmount;
                try {
                    try {
                        long before = System.currentTimeMillis();
                        time.setTime(new Date(before));
                        float t = eng.timedDocumentRoot.convertWallclockTime(time);
//                         if (Math.floor(t) > second) {
//                             second = Math.floor(t);
//                             System.err.println("fps: " + frames);
//                             frames = 0;
//                         }
                        float t2 = eng.tick(t, false);
                        long after = System.currentTimeMillis();
                        long dur = after - before;
                        if (dur == 0) {
                            dur = 1;
                        }
                        sumTime -= times[timeIndex];
                        sumTime += dur;
                        times[timeIndex] = dur;
                        timeIndex = (timeIndex + 1) % NUM_TIMES;

                        if (t2 == Float.POSITIVE_INFINITY) {
                            waitTime = Long.MAX_VALUE;
                        } else {
                            waitTime = before + (long) (t2 * 1000) - 1000;
                            if (waitTime < after) {
                                waitTime = after;
                            }
                            if (animationLimitingMode != 0) {
                                float ave = (float) sumTime / NUM_TIMES;
                                float delay;
                                if (animationLimitingMode == 1) {
                                    // %cpu
                                    delay = ave / animationLimitingAmount - ave;
                                } else {
                                    // fps
                                    delay = 1000f / animationLimitingAmount - ave;
                                }
                                long newWaitTime = after + (long) delay;
                                if (newWaitTime > waitTime) {
                                    waitTime = newWaitTime;
                                }
                            }
                        }
//                         frames++;
                    } catch (AnimationException ex) {
                        throw new BridgeException
                            (eng.ctx, ex.getElement().getElement(),
                             ex.getMessage());
                    }
                    exceptionCount = 0;
                } catch (Exception ex) {
                    if (++exceptionCount < MAX_EXCEPTION_COUNT) {
                        if (eng.ctx.getUserAgent() == null) {
                            ex.printStackTrace();
                        } else {
                            eng.ctx.getUserAgent().displayError(ex);
                        }
                    }
                }

                if (animationLimitingMode == 0) {
                    // so we don't steal too much time from the Swing thread
                    try {
                        Thread.sleep(1);
                    } catch (InterruptedException ie) {
                    }
                }
            }
        }

        /**
         * Returns the SVGAnimationEngine this AnimationTickRunnable is for.
         */
        protected SVGAnimationEngine getAnimationEngine() {
            return (SVGAnimationEngine) engRef.get();
        }
    }

    /**
     * The thread that ticks the animation.
     */
    protected class AnimationThread extends Thread {

        /**
         * The current time.
         */
        protected Calendar time = Calendar.getInstance();

        /**
         * The RunnableQueue to perform the animation in.
         */
        protected RunnableQueue runnableQueue =
            ctx.getUpdateManager().getUpdateRunnableQueue();

        /**
         * The animation ticker Runnable.
         */
        protected Ticker ticker = new Ticker();

        /**
         * Ticks the animation over as fast as possible.
         */
        public void run() {
            if (true) {
                for (;;) {
                    time.setTime(new Date());
                    ticker.t = timedDocumentRoot.convertWallclockTime(time);
                    try {
                        runnableQueue.invokeAndWait(ticker);
                    } catch (InterruptedException e) {
                        return;
                    }
                }
            } else {
                ticker.t = 1;
                while (ticker.t < 10) {
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException ie) {
                    }
                    try {
                        runnableQueue.invokeAndWait(ticker);
                    } catch (InterruptedException e) {
                        return;
                    }
                    ticker.t++;
                }
            }
        }

        /**
         * A runnable that ticks the animation engine.
         */
        protected class Ticker implements Runnable {

            /**
             * The document time to tick at next.
             */
            protected float t;

            /**
             * Ticks the animation over.
             */
            public void run() {
                tick(t, false);
            }
        }
    }

    // AnimatableValue factories

    /**
     * Interface for AnimatableValue factories.
     */
    protected interface Factory {

        /**
         * Creates a new AnimatableValue from a string.
         */
        AnimatableValue createValue(AnimationTarget target, String ns,
                                    String ln, boolean isCSS, String s);

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.
         */
        AnimatableValue createValue(AnimationTarget target, String pn, Value v);
    }

    /**
     * Factory class for AnimatableValues for CSS properties.
     * XXX Shorthand properties are not supported.
     */
    protected abstract class CSSValueFactory implements Factory {

        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            // XXX Always parsing as a CSS value.
            return createValue(target, ln, createCSSValue(target, ln, s));
        }

        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            CSSStylableElement elt = (CSSStylableElement) target.getElement();
            v = computeValue(elt, pn, v);
            return createAnimatableValue(target, pn, v);
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}, after
         * computation and inheritance.
         */
        protected abstract AnimatableValue createAnimatableValue
            (AnimationTarget target, String pn, Value v);

        /**
         * Creates a new CSS {@link Value} from a string.
         */
        protected Value createCSSValue(AnimationTarget t, String pn, String s) {
            CSSStylableElement elt = (CSSStylableElement) t.getElement();
            Value v = cssEngine.parsePropertyValue(elt, pn, s);
            return computeValue(elt, pn, v);
        }

        /**
         * Computes a CSS {@link Value} and performance inheritance if the
         * specified value is 'inherit'.
         */
        protected Value computeValue(CSSStylableElement elt, String pn,
                                     Value v) {
            ValueManager[] vms = cssEngine.getValueManagers();
            int idx = cssEngine.getPropertyIndex(pn);
            if (idx != -1) {
                if (v.getCssValueType() == CSSValue.CSS_INHERIT) {
                    elt = CSSEngine.getParentCSSStylableElement(elt);
                    if (elt != null) {
                        return cssEngine.getComputedStyle(elt, null, idx);
                    }
                    return vms[idx].getDefaultValue();
                }
                v = vms[idx].computeValue(elt, null, cssEngine, idx,
                                          dummyStyleMap, v);
            }
            return v;
        }
    }

    /**
     * Factory class for {@link AnimatableBooleanValue}s.
     */
    protected class AnimatableBooleanValueFactory implements Factory {

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            return new AnimatableBooleanValue(target, "true".equals(s));
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return new AnimatableBooleanValue(target,
                                              "true".equals(v.getCssText()));
        }
    }

    /**
     * Factory class for {@link AnimatableIntegerValue}s.
     */
    protected class AnimatableIntegerValueFactory implements Factory {

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            return new AnimatableIntegerValue(target, Integer.parseInt(s));
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return new AnimatableIntegerValue(target,
                                              Math.round(v.getFloatValue()));
        }
    }

    /**
     * Factory class for {@link AnimatableNumberValue}s.
     */
    protected class AnimatableNumberValueFactory implements Factory {

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            return new AnimatableNumberValue(target, Float.parseFloat(s));
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return new AnimatableNumberValue(target, v.getFloatValue());
        }
    }

    /**
     * Factory class for {@link AnimatableNumberOrPercentageValue}s.
     */
    protected class AnimatableNumberOrPercentageValueFactory
            implements Factory {

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            float v;
            boolean pc;
            if (s.charAt(s.length() - 1) == '%') {
                v = Float.parseFloat(s.substring(0, s.length() - 1));
                pc = true;
            } else {
                v = Float.parseFloat(s);
                pc = false;
            }
            return new AnimatableNumberOrPercentageValue(target, v, pc);
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            switch (v.getPrimitiveType()) {
                case CSSPrimitiveValue.CSS_PERCENTAGE:
                    return new AnimatableNumberOrPercentageValue
                        (target, v.getFloatValue(), true);
                case CSSPrimitiveValue.CSS_NUMBER:
                    return new AnimatableNumberOrPercentageValue
                        (target, v.getFloatValue());
            }
            // XXX Do something better than returning null.
            return null;
        }
    }

    /**
     * Factory class for {@link AnimatablePreserveAspectRatioValue}s.
     */
    protected class AnimatablePreserveAspectRatioValueFactory implements Factory {

        /**
         * The parsed 'align' value.
         */
        protected short align;

        /**
         * The parsed 'meetOrSlice' value.
         */
        protected short meetOrSlice;

        /**
         * Parser for preserveAspectRatio values.
         */
        protected PreserveAspectRatioParser parser =
            new PreserveAspectRatioParser();

        /**
         * Handler for the preserveAspectRatio parser.
         */
        protected DefaultPreserveAspectRatioHandler handler =
            new DefaultPreserveAspectRatioHandler() {

            /**
             * Implements {@link
             * PreserveAspectRatioHandler#startPreserveAspectRatio()}.
             */
            public void startPreserveAspectRatio() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_UNKNOWN;
                meetOrSlice = SVGPreserveAspectRatio.SVG_MEETORSLICE_UNKNOWN;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#none()}.
             */
            public void none() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_NONE;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMaxYMax()}.
             */
            public void xMaxYMax() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMAXYMAX;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMaxYMid()}.
             */
            public void xMaxYMid() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMAXYMID;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMaxYMin()}.
             */
            public void xMaxYMin() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMAXYMIN;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMidYMax()}.
             */
            public void xMidYMax() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMIDYMAX;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMidYMid()}.
             */
            public void xMidYMid() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMIDYMID;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMidYMin()}.
             */
            public void xMidYMin() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMIDYMIN;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMinYMax()}.
             */
            public void xMinYMax() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMINYMAX;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMinYMid()}.
             */
            public void xMinYMid() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMINYMID;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#xMinYMin()}.
             */
            public void xMinYMin() throws ParseException {
                align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMINYMIN;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#meet()}.
             */
            public void meet() throws ParseException {
                meetOrSlice = SVGPreserveAspectRatio.SVG_MEETORSLICE_MEET;
            }

            /**
             * Implements {@link PreserveAspectRatioHandler#slice()}.
             */
            public void slice() throws ParseException {
                meetOrSlice = SVGPreserveAspectRatio.SVG_MEETORSLICE_SLICE;
            }
        };

        /**
         * Creates a new AnimatablePreserveAspectRatioValueFactory.
         */
        public AnimatablePreserveAspectRatioValueFactory() {
            parser.setPreserveAspectRatioHandler(handler);
        }

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            try {
                parser.parse(s);
                return new AnimatablePreserveAspectRatioValue(target, align,
                                                              meetOrSlice);
            } catch (ParseException e) {
                // XXX Do something better than returning null.
                return null;
            }
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.  Returns null
         * since preserveAspectRatio values aren't used in CSS values.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return null;
        }
    }

    /**
     * Factory class for {@link AnimatableLengthValue}s.
     */
    protected class AnimatableLengthValueFactory implements Factory {

        /**
         * The parsed length unit type.
         */
        protected short type;

        /**
         * The parsed length value.
         */
        protected float value;

        /**
         * Parser for lengths.
         */
        protected LengthParser parser = new LengthParser();

        /**
         * Handler for the length parser.
         */
        protected LengthHandler handler = new DefaultLengthHandler() {
            public void startLength() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_NUMBER;
            }
            public void lengthValue(float v) throws ParseException {
                value = v;
            }
            public void em() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_EMS;
            }
            public void ex() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_EXS;
            }
            public void in() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_IN;
            }
            public void cm() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_CM;
            }
            public void mm() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_MM;
            }
            public void pc() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_PC;
            }
            public void pt() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_PT;
            }
            public void px() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_PX;
            }
            public void percentage() throws ParseException {
                type = SVGLength.SVG_LENGTHTYPE_PERCENTAGE;
            }
            public void endLength() throws ParseException {
            }
        };

        /**
         * Creates a new AnimatableLengthValueFactory.
         */
        public AnimatableLengthValueFactory() {
            parser.setLengthHandler(handler);
        }

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            short pcInterp = target.getPercentageInterpretation(ns, ln, isCSS);
            try {
                parser.parse(s);
                return new AnimatableLengthValue
                    (target, type, value, pcInterp);
            } catch (ParseException e) {
                // XXX Do something better than returning null.
                return null;
            }
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return new AnimatableIntegerValue(target,
                                              Math.round(v.getFloatValue()));
        }
    }

    /**
     * Factory class for {@link AnimatableLengthListValue}s.
     */
    protected class AnimatableLengthListValueFactory implements Factory {

        /**
         * Parser for length lists.
         */
        protected LengthListParser parser = new LengthListParser();

        /**
         * The producer class that accumulates the lengths.
         */
        protected LengthArrayProducer producer = new LengthArrayProducer();

        /**
         * Creates a new AnimatableLengthListValueFactory.
         */
        public AnimatableLengthListValueFactory() {
            parser.setLengthListHandler(producer);
        }

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            try {
                short pcInterp = target.getPercentageInterpretation
                    (ns, ln, isCSS);
                parser.parse(s);
                return new AnimatableLengthListValue
                    (target, producer.getLengthTypeArray(),
                     producer.getLengthValueArray(),
                     pcInterp);
            } catch (ParseException e) {
                // XXX Do something better than returning null.
                return null;
            }
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.  Returns null
         * since point lists aren't used in CSS values.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return null;
        }
    }

    /**
     * Factory class for {@link AnimatableNumberListValue}s.
     */
    protected class AnimatableNumberListValueFactory implements Factory {

        /**
         * Parser for number lists.
         */
        protected NumberListParser parser = new NumberListParser();

        /**
         * The producer class that accumulates the numbers.
         */
        protected FloatArrayProducer producer = new FloatArrayProducer();

        /**
         * Creates a new AnimatableNumberListValueFactory.
         */
        public AnimatableNumberListValueFactory() {
            parser.setNumberListHandler(producer);
        }

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            try {
                parser.parse(s);
                return new AnimatableNumberListValue(target,
                                                     producer.getFloatArray());
            } catch (ParseException e) {
                // XXX Do something better than returning null.
                return null;
            }
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.  Returns null
         * since number lists aren't used in CSS values.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return null;
        }
    }

    /**
     * Factory class for {@link AnimatableNumberListValue}s.
     */
    protected class AnimatableRectValueFactory implements Factory {

        /**
         * Parser for number lists.
         */
        protected NumberListParser parser = new NumberListParser();

        /**
         * The producer class that accumulates the numbers.
         */
        protected FloatArrayProducer producer = new FloatArrayProducer();

        /**
         * Creates a new AnimatableNumberListValueFactory.
         */
        public AnimatableRectValueFactory() {
            parser.setNumberListHandler(producer);
        }

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            try {
                parser.parse(s);
                float[] r = producer.getFloatArray();
                if (r.length != 4) {
                    // XXX Do something better than returning null.
                    return null;
                }
                return new AnimatableRectValue(target, r[0], r[1], r[2], r[3]);
            } catch (ParseException e) {
                // XXX Do something better than returning null.
                return null;
            }
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.  Returns null
         * since rects aren't used in CSS values.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return null;
        }
    }

    /**
     * Factory class for {@link AnimatablePointListValue}s.
     */
    protected class AnimatablePointListValueFactory implements Factory {

        /**
         * Parser for point lists.
         */
        protected PointsParser parser = new PointsParser();

        /**
         * The producer class that accumulates the points.
         */
        protected FloatArrayProducer producer = new FloatArrayProducer();

        /**
         * Creates a new AnimatablePointListValueFactory.
         */
        public AnimatablePointListValueFactory() {
            parser.setPointsHandler(producer);
        }

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            try {
                parser.parse(s);
                return new AnimatablePointListValue(target,
                                                    producer.getFloatArray());
            } catch (ParseException e) {
                // XXX Do something better than returning null.
                return null;
            }
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.  Returns null
         * since point lists aren't used in CSS values.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return null;
        }
    }

    /**
     * Factory class for {@link AnimatablePathDataValue}s.
     */
    protected class AnimatablePathDataFactory implements Factory {

        /**
         * Parser for path data.
         */
        protected PathParser parser = new PathParser();

        /**
         * The producer class that accumulates the path segments.
         */
        protected PathArrayProducer producer = new PathArrayProducer();

        /**
         * Creates a new AnimatablePathDataFactory.
         */
        public AnimatablePathDataFactory() {
            parser.setPathHandler(producer);
        }

        /**
         * Creates a new AnimatableValue from a string.
         */
        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            try {
                parser.parse(s);
                return new AnimatablePathDataValue
                    (target, producer.getPathCommands(),
                     producer.getPathParameters());
            } catch (ParseException e) {
                // XXX Do something better than returning null.
                return null;
            }
        }

        /**
         * Creates a new AnimatableValue from a CSS {@link Value}.  Returns null
         * since point lists aren't used in CSS values.
         */
        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return null;
        }
    }

    /**
     * Factory class for {@link AnimatableStringValue}s.
     */
    protected class UncomputedAnimatableStringValueFactory implements Factory {

        public AnimatableValue createValue(AnimationTarget target, String ns,
                                           String ln, boolean isCSS, String s) {
            return new AnimatableStringValue(target, s);
        }

        public AnimatableValue createValue(AnimationTarget target, String pn,
                                           Value v) {
            return new AnimatableStringValue(target, v.getCssText());
        }
    }

    /**
     * Factory class for {@link AnimatableLengthOrIdentValue}s.
     */
    protected class AnimatableLengthOrIdentFactory extends CSSValueFactory {

        protected AnimatableValue createAnimatableValue(AnimationTarget target,
                                                        String pn, Value v) {
            if (v instanceof StringValue) {
                return new AnimatableLengthOrIdentValue(target,
                                                        v.getStringValue());
            }
            short pcInterp = target.getPercentageInterpretation(null, pn, true);
            FloatValue fv = (FloatValue) v;
            return new AnimatableLengthOrIdentValue
                (target, fv.getPrimitiveType(), fv.getFloatValue(), pcInterp);
        }
    }

    /**
     * Factory class for {@link AnimatableNumberOrIdentValue}s.
     */
    protected class AnimatableNumberOrIdentFactory extends CSSValueFactory {

        /**
         * Whether numbers are actually numeric keywords, as with the
         * font-weight property.
         */
        protected boolean numericIdents;

        public AnimatableNumberOrIdentFactory(boolean numericIdents) {
            this.numericIdents = numericIdents;
        }

        protected AnimatableValue createAnimatableValue(AnimationTarget target,
                                                        String pn, Value v) {
            if (v instanceof StringValue) {
                return new AnimatableNumberOrIdentValue(target,
                                                        v.getStringValue());
            }
            FloatValue fv = (FloatValue) v;
            return new AnimatableNumberOrIdentValue(target, fv.getFloatValue(),
                                                    numericIdents);
        }
    }

    /**
     * Factory class for {@link AnimatableAngleValue}s.
     */
    protected class AnimatableAngleValueFactory extends CSSValueFactory {

        protected AnimatableValue createAnimatableValue(AnimationTarget target,
                                                        String pn, Value v) {
            FloatValue fv = (FloatValue) v;
            short unit;
            switch (fv.getPrimitiveType()) {
                case CSSPrimitiveValue.CSS_NUMBER:
                case CSSPrimitiveValue.CSS_DEG:
                    unit = SVGAngle.SVG_ANGLETYPE_DEG;
                    break;
                case CSSPrimitiveValue.CSS_RAD:
                    unit = SVGAngle.SVG_ANGLETYPE_RAD;
                    break;
                case CSSPrimitiveValue.CSS_GRAD:
                    unit = SVGAngle.SVG_ANGLETYPE_GRAD;
                    break;
                default:
                    // XXX Do something better than returning null.
                    return null;
            }
            return new AnimatableAngleValue(target, fv.getFloatValue(), unit);
        }
    }

    /**
     * Factory class for {@link AnimatableAngleOrIdentValue}s.
     */
    protected class AnimatableAngleOrIdentFactory extends CSSValueFactory {

        protected AnimatableValue createAnimatableValue(AnimationTarget target,
                                                        String pn, Value v) {
            if (v instanceof StringValue) {
                return new AnimatableAngleOrIdentValue(target,
                                                       v.getStringValue());
            }
            FloatValue fv = (FloatValue) v;
            short unit;
            switch (fv.getPrimitiveType()) {
                case CSSPrimitiveValue.CSS_NUMBER:
                case CSSPrimitiveValue.CSS_DEG:
                    unit = SVGAngle.SVG_ANGLETYPE_DEG;
                    break;
                case CSSPrimitiveValue.CSS_RAD:
                    unit = SVGAngle.SVG_ANGLETYPE_RAD;
                    break;
                case CSSPrimitiveValue.CSS_GRAD:
                    unit = SVGAngle.SVG_ANGLETYPE_GRAD;
                    break;
                default:
                    // XXX Do something better than returning null.
                    return null;
            }
            return new AnimatableAngleOrIdentValue(target, fv.getFloatValue(),
                                                   unit);
        }
    }

    /**
     * Factory class for {@link AnimatableColorValue}s.
     */
    protected class AnimatableColorValueFactory extends CSSValueFactory {

        protected AnimatableValue createAnimatableValue(AnimationTarget target,
                                                        String pn, Value v) {
            Paint p = PaintServer.convertPaint
                (target.getElement(), null, v, 1.0f, ctx);
            if (p instanceof Color) {
                Color c = (Color) p;
                return new AnimatableColorValue(target,
                                                c.getRed() / 255f,
                                                c.getGreen() / 255f,
                                                c.getBlue() / 255f);
            }
            // XXX Indicate that the parsed value wasn't a Color?
            return null;
        }
    }

    /**
     * Factory class for {@link AnimatablePaintValue}s.
     */
    protected class AnimatablePaintValueFactory extends CSSValueFactory {

        /**
         * Creates a new {@link AnimatablePaintValue} from a {@link Color}
         * object.
         */
        protected AnimatablePaintValue createColorPaintValue(AnimationTarget t,
                                                             Color c) {
            return AnimatablePaintValue.createColorPaintValue
                (t, c.getRed() / 255f, c.getGreen() / 255f, c.getBlue() / 255f);

        }

        protected AnimatableValue createAnimatableValue(AnimationTarget target,
                                                        String pn, Value v) {
            if (v.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE) {
                switch (v.getPrimitiveType()) {
                    case CSSPrimitiveValue.CSS_IDENT:
                        return AnimatablePaintValue.createNonePaintValue(target);
                    case CSSPrimitiveValue.CSS_RGBCOLOR: {
                        Paint p = PaintServer.convertPaint
                            (target.getElement(), null, v, 1.0f, ctx);
                        return createColorPaintValue(target, (Color) p);
                    }
                    case CSSPrimitiveValue.CSS_URI:
                        return AnimatablePaintValue.createURIPaintValue
                            (target, v.getStringValue());
                }
            } else {
                Value v1 = v.item(0);
                switch (v1.getPrimitiveType()) {
                    case CSSPrimitiveValue.CSS_RGBCOLOR: {
                        Paint p = PaintServer.convertPaint
                            (target.getElement(), null, v, 1.0f, ctx);
                        return createColorPaintValue(target, (Color) p);
                    }
                    case CSSPrimitiveValue.CSS_URI: {
                        Value v2 = v.item(1);
                        switch (v2.getPrimitiveType()) {
                            case CSSPrimitiveValue.CSS_IDENT:
                                return AnimatablePaintValue.createURINonePaintValue
                                    (target, v1.getStringValue());
                            case CSSPrimitiveValue.CSS_RGBCOLOR: {
                                Paint p = PaintServer.convertPaint
                                    (target.getElement(), null, v.item(1), 1.0f, ctx);
                                return createColorPaintValue(target, (Color) p);
                            }
                        }
                    }
                }
            }
            // XXX Indicate that the specified Value wasn't a Color?
            return null;
        }
    }

    /**
     * Factory class for computed CSS {@link AnimatableStringValue}s.
     */
    protected class AnimatableStringValueFactory extends CSSValueFactory {

        protected AnimatableValue createAnimatableValue(AnimationTarget target,
                                                        String pn, Value v) {
            return new AnimatableStringValue(target, v.getCssText());
        }
    }
}
