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

import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;

import java.util.Calendar;

import org.apache.flex.forks.batik.anim.AbstractAnimation;
import org.apache.flex.forks.batik.anim.AnimationEngine;
import org.apache.flex.forks.batik.anim.timing.TimedElement;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.css.engine.CSSEngineEvent;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.anim.AnimatableElement;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.dom.anim.AnimationTargetListener;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.SVGAnimationContext;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.events.MutationEvent;
import org.w3c.dom.svg.SVGElement;

/**
 * An abstract base class for the SVG animation element bridges.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGAnimationElementBridge.java 580684 2007-09-30 09:05:57Z cam $
 */
public abstract class SVGAnimationElementBridge extends AbstractSVGBridge
        implements GenericBridge,
                   BridgeUpdateHandler,
                   SVGAnimationContext,
                   AnimatableElement {

    /**
     * The animation element.
     */
    protected SVGOMElement element;

    /**
     * The BridgeContext to be used.
     */
    protected BridgeContext ctx;

    /**
     * The AnimationEngine that manages all of the animations in the document.
     */
    protected SVGAnimationEngine eng;

    /**
     * The TimedElement object that provides the timing for the animation.
     */
    protected TimedElement timedElement;

    /**
     * The animation object that provides the values for the animation.
     */
    protected AbstractAnimation animation;

    /**
     * The namespace URI of the attribute being animated.
     */
    protected String attributeNamespaceURI;

    /**
     * The local name of the attribute or the name of the property being
     * animated.
     */
    protected String attributeLocalName;

    /**
     * The animation type.  Must be one of the <code>ANIM_TYPE_*</code>
     * constants defined in {@link AnimationEngine}.
     */
    protected short animationType;

    /**
     * The target element of the animation.
     */
    protected SVGOMElement targetElement;

    /**
     * The AnimationTarget the provides a context to the animation engine.
     */
    protected AnimationTarget animationTarget;

    /**
     * Returns the TimedElement for the animation.
     */
    public TimedElement getTimedElement() {
        return timedElement;
    }

    // AnimatableElement /////////////////////////////////////////////////////

    /**
     * Returns the underlying value of the animated attribute.  Used for
     * composition of additive animations.  This should be overridden in
     * descendant classes that are for 'other' animations.
     */
    public AnimatableValue getUnderlyingValue() {
        if (animationType == AnimationEngine.ANIM_TYPE_XML) {
            return animationTarget.getUnderlyingValue(attributeNamespaceURI,
                                                      attributeLocalName);
        } else {
            return eng.getUnderlyingCSSValue(element,
                                             animationTarget,
                                             attributeLocalName);
        }
    }

    // GenericBridge /////////////////////////////////////////////////////////

    /**
     * Handles this animation element.
     *
     * @param ctx the bridge context to use
     * @param e the element being handled
     */
    public void handleElement(BridgeContext ctx, Element e) {
        if (ctx.isDynamic() && BridgeContext.getSVGContext(e) == null) {
            SVGAnimationElementBridge b =
                (SVGAnimationElementBridge) getInstance();
            b.element = (SVGOMElement) e;
            b.ctx = ctx;
            b.eng = ctx.getAnimationEngine();
            b.element.setSVGContext(b);
            if (b.eng.hasStarted()) {
                b.initializeAnimation();
                b.initializeTimedElement();
            } else {
                b.eng.addInitialBridge(b);
            }
        }
    }

    /**
     * Parses the animation element's target attributes and adds it to the
     * document's AnimationEngine.
     */
    protected void initializeAnimation() {
        // Determine the target element.
        String uri = XLinkSupport.getXLinkHref(element);
        Node t;
        if (uri.length() == 0) {
            t = element.getParentNode();
        } else {
            t = ctx.getReferencedElement(element, uri);
            if (t.getOwnerDocument() != element.getOwnerDocument()) {
                throw new BridgeException
                    (ctx, element, ErrorConstants.ERR_URI_BAD_TARGET,
                     new Object[] { uri });
            }
        }
        animationTarget = null;
        if (t instanceof SVGOMElement) {
            targetElement = (SVGOMElement) t;
            animationTarget = targetElement;
        }
        if (animationTarget == null) {
            throw new BridgeException
                (ctx, element, ErrorConstants.ERR_URI_BAD_TARGET,
                 new Object[] { uri });
        }

        // Get the attribute/property name.
        String an = element.getAttributeNS(null, SVG_ATTRIBUTE_NAME_ATTRIBUTE);
        int ci = an.indexOf(':');
        if (ci == -1) {
            if (element.hasProperty(an)) {
                animationType = AnimationEngine.ANIM_TYPE_CSS;
                attributeLocalName = an;
            } else {
                animationType = AnimationEngine.ANIM_TYPE_XML;
                attributeLocalName = an;
            }
        } else {
            animationType = AnimationEngine.ANIM_TYPE_XML;
            String prefix = an.substring(0, ci);
            attributeNamespaceURI = element.lookupNamespaceURI(prefix);
            attributeLocalName = an.substring(ci + 1);
        }
        if (animationType == AnimationEngine.ANIM_TYPE_CSS
                && !targetElement.isPropertyAnimatable(attributeLocalName)
            || animationType == AnimationEngine.ANIM_TYPE_XML
                && !targetElement.isAttributeAnimatable(attributeNamespaceURI,
                                                        attributeLocalName)) {
            throw new BridgeException
                (ctx, element, "attribute.not.animatable",
                 new Object[] { targetElement.getNodeName(), an });
        }

        // Check that the attribute/property is animatable with this
        // animation element.
        int type;
        if (animationType == AnimationEngine.ANIM_TYPE_CSS) {
            type = targetElement.getPropertyType(attributeLocalName);
        } else {
            type = targetElement.getAttributeType(attributeNamespaceURI,
                                                  attributeLocalName);
        }
        if (!canAnimateType(type)) {
            throw new BridgeException
                (ctx, element, "type.not.animatable",
                 new Object[] { targetElement.getNodeName(), an,
                                element.getNodeName() });
        }

        // Add the animation.
        timedElement = createTimedElement();
        animation = createAnimation(animationTarget);
        eng.addAnimation(animationTarget, animationType, attributeNamespaceURI,
                         attributeLocalName, animation);
    }

    /**
     * Returns whether the animation element being handled by this bridge can
     * animate attributes of the specified type.
     * @param type one of the TYPE_ constants defined in {@link SVGTypes}.
     */
    protected abstract boolean canAnimateType(int type);

    /**
     * Returns whether the specified {@link AnimatableValue} is of a type allowed
     * by this animation.
     */
    protected boolean checkValueType(AnimatableValue v) {
        return true;
    }

    /**
     * Parses the animation element's timing attributes and initializes the
     * {@link TimedElement} object.
     */
    protected void initializeTimedElement() {
        initializeTimedElement(timedElement);
        timedElement.initialize();
    }

    /**
     * Creates a TimedElement for the animation element.
     */
    protected TimedElement createTimedElement() {
        return new SVGTimedElement();
    }

    /**
     * Creates the animation object for the animation element.
     */
    protected abstract AbstractAnimation createAnimation(AnimationTarget t);

    /**
     * Parses an attribute as an AnimatableValue.
     */
    protected AnimatableValue parseAnimatableValue(String an) {
        if (!element.hasAttributeNS(null, an)) {
            return null;
        }
        String s = element.getAttributeNS(null, an);
        AnimatableValue val = eng.parseAnimatableValue
            (element, animationTarget, attributeNamespaceURI,
             attributeLocalName, animationType == AnimationEngine.ANIM_TYPE_CSS,
             s);
        if (!checkValueType(val)) {
            throw new BridgeException
                (ctx, element, ErrorConstants.ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] { an, s });
        }
        return val;
    }

    /**
     * Initializes the timing attributes of the timed element.
     */
    protected void initializeTimedElement(TimedElement timedElement) {
        timedElement.parseAttributes
            (element.getAttributeNS(null, "begin"),
             element.getAttributeNS(null, "dur"),
             element.getAttributeNS(null, "end"),
             element.getAttributeNS(null, "min"),
             element.getAttributeNS(null, "max"),
             element.getAttributeNS(null, "repeatCount"),
             element.getAttributeNS(null, "repeatDur"),
             element.getAttributeNS(null, "fill"),
             element.getAttributeNS(null, "restart"));
    }

    // BridgeUpdateHandler ///////////////////////////////////////////////////

    /**
     * Invoked when an MutationEvent of type 'DOMAttrModified' is fired.
     */
    public void handleDOMAttrModifiedEvent(MutationEvent evt) {
    }

    /**
     * Invoked when an MutationEvent of type 'DOMNodeInserted' is fired.
     */
    public void handleDOMNodeInsertedEvent(MutationEvent evt) {
    }

    /**
     * Invoked when an MutationEvent of type 'DOMNodeRemoved' is fired.
     */
    public void handleDOMNodeRemovedEvent(MutationEvent evt) {
        element.setSVGContext(null);
        dispose();
    }

    /**
     * Invoked when an MutationEvent of type 'DOMCharacterDataModified' 
     * is fired.
     */
    public void handleDOMCharacterDataModified(MutationEvent evt) {
    }

    /**
     * Invoked when an CSSEngineEvent is fired.
     */
    public void handleCSSEngineEvent(CSSEngineEvent evt) {
    }

    /**
     * Invoked when the animated value of an animatable attribute has changed.
     */
    public void handleAnimatedAttributeChanged
            (AnimatedLiveAttributeValue alav) {
    }

    /**
     * Invoked when an 'other' animation value has changed.
     */
    public void handleOtherAnimationChanged(String type) {
    }

    /**
     * Disposes this BridgeUpdateHandler and releases all resources.
     */
    public void dispose() {
        if (element.getSVGContext() == null) {
            // Only remove the animation if this is not part of a rebuild.
            eng.removeAnimation(animation);
            timedElement.deinitialize();
            timedElement = null;
            element = null;
        }
    }

    // SVGContext ///////////////////////////////////////////////////////////

    /**
     * Returns the size of a px CSS unit in millimeters.
     */
    public float getPixelUnitToMillimeter() {
        return ctx.getUserAgent().getPixelUnitToMillimeter();
    }

    /**
     * Returns the size of a px CSS unit in millimeters.
     * This will be removed after next release.
     * @see #getPixelUnitToMillimeter()
     */
    public float getPixelToMM() {
        return getPixelUnitToMillimeter();
            
    }

    public Rectangle2D getBBox() { return null; }
    public AffineTransform getScreenTransform() { 
        return ctx.getUserAgent().getTransform();
    }
    public void setScreenTransform(AffineTransform at) { 
        ctx.getUserAgent().setTransform(at);
    }
    public AffineTransform getCTM() { return null; }
    public AffineTransform getGlobalTransform() { return null; }
    public float getViewportWidth() {
        return ctx.getBlockWidth(element);
    }
    public float getViewportHeight() {
        return ctx.getBlockHeight(element);
    }
    public float getFontSize() { return 0; }
    public float svgToUserSpace(float v, int type, int pcInterp) {
        return 0;
    }

    /**
     * Adds a listener for changes to the given attribute value.
     */
    public void addTargetListener(String pn, AnimationTargetListener l) {
    }

    /**
     * Removes a listener for changes to the given attribute value.
     */
    public void removeTargetListener(String pn, AnimationTargetListener l) {
    }

    // SVGAnimationContext ///////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimationElement#getTargetElement()}.
     */
    public SVGElement getTargetElement() {
        return targetElement;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimationElement#getStartTime()}.
     */
    public float getStartTime() {
        return timedElement.getCurrentBeginTime();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimationElement#getCurrentTime()}.
     */
    public float getCurrentTime() {
        return timedElement.getLastSampleTime();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimationElement#getSimpleDuration()}.  With the
     * difference that an indefinite simple duration is returned as
     * {@link TimedElement#INDEFINITE}, rather than throwing an exception.
     */
    public float getSimpleDuration() {
        return timedElement.getSimpleDur();
    }

    /**
     * Returns the time that the document would seek to if this animation
     * element were hyperlinked to, or <code>NaN</code> if there is no
     * such begin time.
     */
    public float getHyperlinkBeginTime() {
        return timedElement.getHyperlinkBeginTime();
    }

    // ElementTimeControl ////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.smil.ElementTimeControl#beginElement()}.
     */
    public boolean beginElement() throws DOMException {
        timedElement.beginElement();
        return timedElement.canBegin();
    }
    
    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.smil.ElementTimeControl#beginElementAt(float)}.
     */
    public boolean beginElementAt(float offset) throws DOMException {
        timedElement.beginElement(offset);
        // XXX Not right, but who knows if it is possible to begin
        //     at some arbitrary point in the future.
        return true;
    }
    
    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.smil.ElementTimeControl#endElement()}.
     */
    public boolean endElement() throws DOMException {
        timedElement.endElement();
        return timedElement.canEnd();
    }
    
    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.smil.ElementTimeControl#endElementAt(float)}.
     */
    public boolean endElementAt(float offset) throws DOMException {
        timedElement.endElement(offset);
        // XXX Not right, but who knows if it is possible to begin
        //     at some arbitrary point in the future.
        return true;
    }

    /**
     * Returns whether this is a constant animation (i.e., a 'set' animation).
     */
    protected boolean isConstantAnimation() {
        return false;
    }

    /**
     * A TimedElement class for SVG animation elements.
     */
    protected class SVGTimedElement extends TimedElement {

        /**
         * Returns the DOM element this timed element is for.
         */
        public Element getElement() {
            return element;
        }

        /**
         * Fires a TimeEvent of the given type on this element.
         * @param eventType the type of TimeEvent ("beginEvent", "endEvent"
         *                  or "repeatEvent").
         * @param time the timestamp of the event object
         */
        protected void fireTimeEvent(String eventType, Calendar time,
                                     int detail) {
            AnimationSupport.fireTimeEvent(element, eventType, time, detail);
        }

        /**
         * Invoked to indicate this timed element became active at the
         * specified time.
         * @param begin the time the element became active, in document
         *              simple time
         */
        protected void toActive(float begin) {
            eng.toActive(animation, begin);
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
            eng.toInactive(animation, isFrozen);
        }

        /**
         * Invoked to indicate that this timed element has had its fill removed.
         */
        protected void removeFill() {
            eng.removeFill(animation);
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
            eng.sampledAt(animation, simpleTime, simpleDur, repeatIteration);
        }

        /**
         * Invoked to indicate that this timed element has been sampled
         * at the end of its active time, at an integer multiple of the
         * simple duration.  This is the "last" value that will be used
         * for filling, which cannot be sampled normally.
         */
        protected void sampledLastValue(int repeatIteration) {
            eng.sampledLastValue(animation, repeatIteration);
        }

        /**
         * Returns the timed element with the given ID.
         */
        protected TimedElement getTimedElementById(String id) {
            return AnimationSupport.getTimedElementById(id, element);
        }

        /**
         * Returns the event target with the given ID.
         */
        protected EventTarget getEventTargetById(String id) {
            return AnimationSupport.getEventTargetById(id, element);
        }

        /**
         * Returns the event target that should be listened to for
         * access key events.
         */
        protected EventTarget getRootEventTarget() {
            return (EventTarget) element.getOwnerDocument();
        }

        /**
         * Returns the target of this animation as an {@link EventTarget}.  Used
         * for eventbase timing specifiers where the element ID is omitted.
         */
        protected EventTarget getAnimationEventTarget() {
            return targetElement;
        }

        /**
         * Returns whether this timed element comes before the given timed
         * element in document order.
         */
        public boolean isBefore(TimedElement other) {
            Element e = ((SVGTimedElement) other).getElement();
            int pos = ((AbstractNode) element).compareDocumentPosition(e);
            return (pos & AbstractNode.DOCUMENT_POSITION_PRECEDING) != 0;
        }

        /**
         * Returns a string representation of this animation.
         */
        public String toString() {
            if (element != null) {
                String id = element.getAttributeNS(null, "id");
                if (id.length() != 0) {
                    return id;
                }
            }
            return super.toString();
        }

        /**
         * Returns whether this timed element is for a constant animation (i.e.,
         * a 'set' animation.
         */
        protected boolean isConstantAnimation() {
            return SVGAnimationElementBridge.this.isConstantAnimation();
        }
    }
}
