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
package org.apache.flex.forks.batik.anim;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.apache.flex.forks.batik.anim.timing.TimedDocumentRoot;
import org.apache.flex.forks.batik.anim.timing.TimedElement;
import org.apache.flex.forks.batik.anim.timing.TimegraphListener;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.dom.anim.AnimationTargetListener;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;

import org.w3c.dom.Document;

/**
 * An abstract base class for managing animation in a document.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimationEngine.java 592621 2007-11-07 05:58:12Z cam $
 */
public abstract class AnimationEngine {

    // Constants to identify the type of animation.
    public static final short ANIM_TYPE_XML   = 0;
    public static final short ANIM_TYPE_CSS   = 1;
    public static final short ANIM_TYPE_OTHER = 2;

    /**
     * The document this AnimationEngine is managing animation for.
     */
    protected Document document;

    /**
     * The root time container for the document.
     */
    protected TimedDocumentRoot timedDocumentRoot;

    /**
     * The time at which the document was paused, or 0 if the document is not
     * paused.
     */
    protected long pauseTime;

    /**
     * Map of AnimationTargets to TargetInfo objects.
     */
    protected HashMap targets = new HashMap();

    /**
     * Map of AbstractAnimations to AnimationInfo objects.
     */
    protected HashMap animations = new HashMap();

    /**
     * The listener object for animation target base value changes.
     */
    protected Listener targetListener = new Listener();

    /**
     * Creates a new AnimationEngine for the given document.
     */
    public AnimationEngine(Document doc) {
        this.document = doc;
        timedDocumentRoot = createDocumentRoot();
    }

    /**
     * Disposes this animation engine.
     */
    public void dispose() {
        // Remove any target listeners that are registered.
        Iterator i = targets.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            AnimationTarget target = (AnimationTarget) e.getKey();
            TargetInfo info = (TargetInfo) e.getValue();

            Iterator j = info.xmlAnimations.iterator();
            while (j.hasNext()) {
                DoublyIndexedTable.Entry e2 =
                    (DoublyIndexedTable.Entry) j.next();
                String namespaceURI = (String) e2.getKey1();
                String localName = (String) e2.getKey2();
                Sandwich sandwich = (Sandwich) e2.getValue();
                if (sandwich.listenerRegistered) {
                    target.removeTargetListener(namespaceURI, localName, false,
                                                targetListener);
                }
            }

            j = info.cssAnimations.entrySet().iterator();
            while (j.hasNext()) {
                Map.Entry e2 = (Map.Entry) j.next();
                String propertyName = (String) e2.getKey();
                Sandwich sandwich = (Sandwich) e2.getValue();
                if (sandwich.listenerRegistered) {
                    target.removeTargetListener(null, propertyName, true,
                                                targetListener);
                }
            }
        }
    }

    /**
     * Pauses the animations.
     */
    public void pause() {
        if (pauseTime == 0) {
            pauseTime = System.currentTimeMillis();
        }
    }

    /**
     * Unpauses the animations.
     */
    public void unpause() {
        if (pauseTime != 0) {
            Calendar begin = timedDocumentRoot.getDocumentBeginTime();
            int dt = (int) (System.currentTimeMillis() - pauseTime);
            begin.add(Calendar.MILLISECOND, dt);
            pauseTime = 0;
        }
    }

    /**
     * Returns whether animations are currently paused.
     */
    public boolean isPaused() {
        return pauseTime != 0;
    }

    /**
     * Returns the current document time.
     */
    public float getCurrentTime() {
        return timedDocumentRoot.getCurrentTime();
    }

    /**
     * Sets the current document time.
     */
    public float setCurrentTime(float t) {
        boolean p = pauseTime != 0;
        unpause();
        Calendar begin = timedDocumentRoot.getDocumentBeginTime();
        float now =
            timedDocumentRoot.convertEpochTime(System.currentTimeMillis());
        begin.add(Calendar.MILLISECOND, (int) ((now - t) * 1000));
        if (p) {
            pause();
        }
        return tick(t, true);
    }

    /**
     * Adds an animation to the document.
     * @param target the target element of the animation
     * @param type the type of animation (must be one of the
     *             <code>ANIM_TYPE_*</code> constants defined in this class
     * @param ns the namespace URI of the attribute being animated, if
     *           <code>type == </code>{@link #ANIM_TYPE_XML}
     * @param an the attribute name if <code>type == </code>{@link
     *           #ANIM_TYPE_XML}, the property name if <code>type == </code>
     *           {@link #ANIM_TYPE_CSS}, and the animation type otherwise
     * @param anim the animation
     */
    public void addAnimation(AnimationTarget target, short type, String ns,
                             String an, AbstractAnimation anim) {
        // org.apache.flex.forks.batik.anim.timing.Trace.enter(this, "addAnimation", new Object[] { target, new Short[type], ns, an, anim } ); try {
        timedDocumentRoot.addChild(anim.getTimedElement());

        AnimationInfo animInfo = getAnimationInfo(anim);
        animInfo.type = type;
        animInfo.attributeNamespaceURI = ns;
        animInfo.attributeLocalName = an;
        animInfo.target = target;
        animations.put(anim, animInfo);

        Sandwich sandwich = getSandwich(target, type, ns, an);
        if (sandwich.animation == null) {
            anim.lowerAnimation = null;
            anim.higherAnimation = null;
        } else {
            sandwich.animation.higherAnimation = anim;
            anim.lowerAnimation = sandwich.animation;
            anim.higherAnimation = null;
        }
        sandwich.animation = anim;
        if (anim.lowerAnimation == null) {
            sandwich.lowestAnimation = anim;
        }
        // } finally { org.apache.flex.forks.batik.anim.timing.Trace.exit(); }
    }

    /**
     * Removes an animation from the document.
     */
    public void removeAnimation(AbstractAnimation anim) {
        // org.apache.flex.forks.batik.anim.timing.Trace.enter(this, "removeAnimation", new Object[] { anim } ); try {
        timedDocumentRoot.removeChild(anim.getTimedElement());
        AbstractAnimation nextHigher = anim.higherAnimation;
        if (nextHigher != null) {
            nextHigher.markDirty();
        }
        moveToBottom(anim);
        if (anim.higherAnimation != null) {
            anim.higherAnimation.lowerAnimation = null;
        }
        AnimationInfo animInfo = getAnimationInfo(anim);
        Sandwich sandwich = getSandwich(animInfo.target, animInfo.type,
                                        animInfo.attributeNamespaceURI,
                                        animInfo.attributeLocalName);
        if (sandwich.animation == anim) {
            sandwich.animation = null;
            sandwich.lowestAnimation = null;
            sandwich.shouldUpdate = true;
        }
        // } finally { org.apache.flex.forks.batik.anim.timing.Trace.exit(); }
    }

    /**
     * Returns the Sandwich for the given animation type/attribute.
     */
    protected Sandwich getSandwich(AnimationTarget target, short type,
                                   String ns, String an) {
        TargetInfo info = getTargetInfo(target);
        Sandwich sandwich;
        if (type == ANIM_TYPE_XML) {
            sandwich = (Sandwich) info.xmlAnimations.get(ns, an);
            if (sandwich == null) {
                sandwich = new Sandwich();
                info.xmlAnimations.put(ns, an, sandwich);
            }
        } else if (type == ANIM_TYPE_CSS) {
            sandwich = (Sandwich) info.cssAnimations.get(an);
            if (sandwich == null) {
                sandwich = new Sandwich();
                info.cssAnimations.put(an, sandwich);
            }
        } else {
            sandwich = (Sandwich) info.otherAnimations.get(an);
            if (sandwich == null) {
                sandwich = new Sandwich();
                info.otherAnimations.put(an, sandwich);
            }
        }
        return sandwich;
    }

    /**
     * Returns the TargetInfo for the given AnimationTarget.
     */
    protected TargetInfo getTargetInfo(AnimationTarget target) {
        TargetInfo info = (TargetInfo) targets.get(target);
        if (info == null) {
            info = new TargetInfo();
            targets.put(target, info);
        }
        return info;
    }

    /**
     * Returns the AnimationInfo for the given AbstractAnimation.
     */
    protected AnimationInfo getAnimationInfo(AbstractAnimation anim) {
        AnimationInfo info = (AnimationInfo) animations.get(anim);
        if (info == null) {
            info = new AnimationInfo();
            animations.put(anim, info);
        }
        return info;
    }

    protected static final Map.Entry[] MAP_ENTRY_ARRAY = new Map.Entry[0];

    /**
     * Updates the animations in the document to the given document time.
     * @param time the document time to sample at
     * @param hyperlinking whether the document should be seeked to the given
     *                     time, as with hyperlinking
     */
    protected float tick(float time, boolean hyperlinking) {
        float waitTime = timedDocumentRoot.seekTo(time, hyperlinking);
        Map.Entry[] targetEntries =
            (Map.Entry[]) targets.entrySet().toArray(MAP_ENTRY_ARRAY);
        for (int i = 0; i < targetEntries.length; i++) {
            Map.Entry e = targetEntries[i];
            AnimationTarget target = (AnimationTarget) e.getKey();
            TargetInfo info = (TargetInfo) e.getValue();

            // Update the XML animations.
            Iterator j = info.xmlAnimations.iterator();
            while (j.hasNext()) {
                DoublyIndexedTable.Entry e2 =
                    (DoublyIndexedTable.Entry) j.next();
                String namespaceURI = (String) e2.getKey1();
                String localName = (String) e2.getKey2();
                Sandwich sandwich = (Sandwich) e2.getValue();
                if (sandwich.shouldUpdate ||
                        sandwich.animation != null
                            && sandwich.animation.isDirty) {
                    AnimatableValue av = null;
                    boolean usesUnderlying = false;
                    AbstractAnimation anim = sandwich.animation;
                    if (anim != null) {
                        av = anim.getComposedValue();
                        usesUnderlying =
                            sandwich.lowestAnimation.usesUnderlyingValue();
                        anim.isDirty = false;
                    }
                    if (usesUnderlying && !sandwich.listenerRegistered) {
                        target.addTargetListener(namespaceURI, localName, false,
                                                 targetListener);
                        sandwich.listenerRegistered = true;
                    } else if (!usesUnderlying && sandwich.listenerRegistered) {
                        target.removeTargetListener(namespaceURI, localName,
                                                    false, targetListener);
                        sandwich.listenerRegistered = false;
                    }
                    target.updateAttributeValue(namespaceURI, localName, av);
                    sandwich.shouldUpdate = false;
                }
            }

            // Update the CSS animations.
            j = info.cssAnimations.entrySet().iterator();
            while (j.hasNext()) {
                Map.Entry e2 = (Map.Entry) j.next();
                String propertyName = (String) e2.getKey();
                Sandwich sandwich = (Sandwich) e2.getValue();
                if (sandwich.shouldUpdate ||
                        sandwich.animation != null
                            && sandwich.animation.isDirty) {
                    AnimatableValue av = null;
                    boolean usesUnderlying = false;
                    AbstractAnimation anim = sandwich.animation;
                    if (anim != null) {
                        av = anim.getComposedValue();
                        usesUnderlying =
                            sandwich.lowestAnimation.usesUnderlyingValue();
                        anim.isDirty = false;
                    }
                    if (usesUnderlying && !sandwich.listenerRegistered) {
                        target.addTargetListener(null, propertyName, true,
                                                 targetListener);
                        sandwich.listenerRegistered = true;
                    } else if (!usesUnderlying && sandwich.listenerRegistered) {
                        target.removeTargetListener(null, propertyName, true,
                                                    targetListener);
                        sandwich.listenerRegistered = false;
                    }
                    if (usesUnderlying) {
                        target.updatePropertyValue(propertyName, null);
                    }
                    if (!(usesUnderlying && av == null)) {
                        target.updatePropertyValue(propertyName, av);
                    }
                    sandwich.shouldUpdate = false;
                }
            }

            // Update the other animations.
            j = info.otherAnimations.entrySet().iterator();
            while (j.hasNext()) {
                Map.Entry e2 = (Map.Entry) j.next();
                String type = (String) e2.getKey();
                Sandwich sandwich = (Sandwich) e2.getValue();
                if (sandwich.shouldUpdate || sandwich.animation.isDirty) {
                    AnimatableValue av = null;
                    AbstractAnimation anim = sandwich.animation;
                    if (anim != null) {
                        av = sandwich.animation.getComposedValue();
                        anim.isDirty = false;
                    }
                    target.updateOtherValue(type, av);
                    sandwich.shouldUpdate = false;
                }
            }
        }
        return waitTime;
    }

    /**
     * Invoked to indicate an animation became active at the specified time.
     *
     * @param anim the animation
     * @param begin the time the element became active, in document simple time
     */
    public void toActive(AbstractAnimation anim, float begin) {
        moveToTop(anim);
        anim.isActive = true;
        anim.beginTime = begin;
        anim.isFrozen = false;
        // Move the animation down, in case it began at the same time as another
        // animation in the sandwich and it's earlier in document order.
        pushDown(anim);
        anim.markDirty();
    }

    /**
     * Moves the animation down the sandwich such that it is in the right
     * position according to begin time and document order.
     */
    protected void pushDown(AbstractAnimation anim) {
        TimedElement e = anim.getTimedElement();
        AbstractAnimation top = null;
        boolean moved = false;
        while (anim.lowerAnimation != null
                && (anim.lowerAnimation.isActive
                    || anim.lowerAnimation.isFrozen)
                && (anim.lowerAnimation.beginTime > anim.beginTime
                    || anim.lowerAnimation.beginTime == anim.beginTime
                        && e.isBefore(anim.lowerAnimation.getTimedElement()))) {
            AbstractAnimation higher = anim.higherAnimation;
            AbstractAnimation lower = anim.lowerAnimation;
            AbstractAnimation lowerLower = lower.lowerAnimation;
            if (higher != null) {
                higher.lowerAnimation = lower;
            }
            if (lowerLower != null) {
                lowerLower.higherAnimation = anim;
            }
            lower.lowerAnimation = anim;
            lower.higherAnimation = higher;
            anim.lowerAnimation = lowerLower;
            anim.higherAnimation = lower;
            if (!moved) {
                top = lower;
                moved = true;
            }
        }
        if (moved) {
            AnimationInfo animInfo = getAnimationInfo(anim);
            Sandwich sandwich = getSandwich(animInfo.target, animInfo.type,
                                            animInfo.attributeNamespaceURI,
                                            animInfo.attributeLocalName);
            if (sandwich.animation == anim) {
                sandwich.animation = top;
            }
            if (anim.lowerAnimation == null) {
                sandwich.lowestAnimation = anim;
            }
        }
    }

    /**
     * Invoked to indicate that this timed element became inactive.
     *
     * @param anim the animation
     * @param isFrozen whether the element is frozen or not
     */
    public void toInactive(AbstractAnimation anim, boolean isFrozen) {
        anim.isActive = false;
        anim.isFrozen = isFrozen;
        anim.beginTime = Float.NEGATIVE_INFINITY;
        anim.markDirty();
        if (!isFrozen) {
            anim.value = null;
            moveToBottom(anim);
        } else {
            pushDown(anim);
        }
    }

    /**
     * Invoked to indicate that this timed element has had its fill removed.
     */
    public void removeFill(AbstractAnimation anim) {
        anim.isActive = false;
        anim.isFrozen = false;
        anim.value = null;
        anim.markDirty();
        moveToBottom(anim);
    }

    /**
     * Moves the given animation to the top of the sandwich.
     */
    protected void moveToTop(AbstractAnimation anim) {
        AnimationInfo animInfo = getAnimationInfo(anim);
        Sandwich sandwich = getSandwich(animInfo.target, animInfo.type,
                                        animInfo.attributeNamespaceURI,
                                        animInfo.attributeLocalName);
        sandwich.shouldUpdate = true;
        if (anim.higherAnimation == null) {
            return;
        }
        if (anim.lowerAnimation == null) {
            sandwich.lowestAnimation = anim.higherAnimation;
        } else {
            anim.lowerAnimation.higherAnimation = anim.higherAnimation;
        }
        anim.higherAnimation.lowerAnimation = anim.lowerAnimation;
        if (sandwich.animation != null) {
            sandwich.animation.higherAnimation = anim;
        }
        anim.lowerAnimation = sandwich.animation;
        anim.higherAnimation = null;
        sandwich.animation = anim;
    }

    /**
     * Moves the given animation to the bottom of the sandwich.
     */
    protected void moveToBottom(AbstractAnimation anim) {
        if (anim.lowerAnimation == null) {
            return;
        }
        AnimationInfo animInfo = getAnimationInfo(anim);
        Sandwich sandwich = getSandwich(animInfo.target, animInfo.type,
                                        animInfo.attributeNamespaceURI,
                                        animInfo.attributeLocalName);
        AbstractAnimation nextLower = anim.lowerAnimation;
        nextLower.markDirty();
        anim.lowerAnimation.higherAnimation = anim.higherAnimation;
        if (anim.higherAnimation != null) {
            anim.higherAnimation.lowerAnimation = anim.lowerAnimation;
        } else {
            sandwich.animation = nextLower;
            sandwich.shouldUpdate = true;
        }
        sandwich.lowestAnimation.lowerAnimation = anim;
        anim.higherAnimation = sandwich.lowestAnimation;
        anim.lowerAnimation = null;
        sandwich.lowestAnimation = anim;
        if (sandwich.animation.isDirty) {
            sandwich.shouldUpdate = true;
        }
    }

    /**
     * Adds a {@link TimegraphListener} to the document.
     */
    public void addTimegraphListener(TimegraphListener l) {
        timedDocumentRoot.addTimegraphListener(l);
    }

    /**
     * Removes a {@link TimegraphListener} from the document.
     */
    public void removeTimegraphListener(TimegraphListener l) {
        timedDocumentRoot.removeTimegraphListener(l);
    }

    /**
     * Invoked to indicate that this timed element has been sampled at the given
     * time.
     *
     * @param anim the animation
     * @param simpleTime the sample time in local simple time
     * @param simpleDur the simple duration of the element
     * @param repeatIteration the repeat iteration during which the element was
     *                        sampled
     */
    public void sampledAt(AbstractAnimation anim, float simpleTime,
                          float simpleDur, int repeatIteration) {
        anim.sampledAt(simpleTime, simpleDur, repeatIteration);
    }

    /**
     * Invoked to indicate that this timed element has been sampled at the end
     * of its active time, at an integer multiple of the simple duration. This
     * is the "last" value that will be used for filling, which cannot be
     * sampled normally.
     */
    public void sampledLastValue(AbstractAnimation anim, int repeatIteration) {
        anim.sampledLastValue(repeatIteration);
    }

    /**
     * Creates a new returns a new TimedDocumentRoot object for the document.
     */
    protected abstract TimedDocumentRoot createDocumentRoot();

    /**
     * Listener class for changes to base values on a target element.
     */
    protected class Listener implements AnimationTargetListener {

        /**
         * Invoked to indicate that base value of the specified attribute
         * or property has changed.
         */
        public void baseValueChanged(AnimationTarget t, String ns, String ln,
                                     boolean isCSS) {
            short type = isCSS ? ANIM_TYPE_CSS : ANIM_TYPE_XML;
            Sandwich sandwich = getSandwich(t, type, ns, ln);
            sandwich.shouldUpdate = true;
            AbstractAnimation anim = sandwich.animation;
            while (anim.lowerAnimation != null) {
                anim = anim.lowerAnimation;
            }
            anim.markDirty();
        }
    }

    /**
     * Class to hold XML and CSS animations for a target element.
     */
    protected static class TargetInfo {

        /**
         * Map of XML attribute names to the corresponding {@link Sandwich}
         * objects.
         */
        public DoublyIndexedTable xmlAnimations = new DoublyIndexedTable();

        /**
         * Map of CSS attribute names to the corresponding {@link Sandwich}
         * objects.
         */
        public HashMap cssAnimations = new HashMap();

        /**
         * Map of other animation types to the corresponding {@link Sandwich}
         * objects.
         */
        public HashMap otherAnimations = new HashMap();
    }

    /**
     * Class to hold an animation sandwich for a particular attribute.
     */
    protected static class Sandwich {

        /**
         * The top-most animation in the sandwich.
         */
        public AbstractAnimation animation;

        /**
         * The bottom-most animation in the sandwich.
         */
        public AbstractAnimation lowestAnimation;

        /**
         * Whether the animation needs to have its value copied into the
         * document.
         */
        public boolean shouldUpdate;

        /**
         * Whether an {@link AnimationTargetListener} has been registered to
         * listen for changes to the base value.
         */
        public boolean listenerRegistered;
    }

    /**
     * Class to hold target information of an animation.
     */
    protected static class AnimationInfo {

        /**
         * The target of the animation.
         */
        public AnimationTarget target;

        /**
         * The type of animation.  Must be one of the <code>ANIM_TYPE_*</code>
         * constants defined in {@link AnimationEngine}.
         */
        public short type;

        /**
         * The namespace URI of the attribute to animate, if this is an XML
         * attribute animation.
         */
        public String attributeNamespaceURI;

        /**
         * The local name of the attribute or the name of the CSS property to
         * animate.
         */
        public String attributeLocalName;
    }
}
