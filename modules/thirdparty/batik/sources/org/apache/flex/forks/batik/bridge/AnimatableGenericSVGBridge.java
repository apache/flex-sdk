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

import org.apache.flex.forks.batik.css.engine.CSSEngineEvent;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.SVGContext;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;

import org.w3c.dom.Element;
import org.w3c.dom.events.MutationEvent;

/**
 * Abstract bridge class for animatable elements that do not produce
 * a GraphicsNode.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableGenericSVGBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class AnimatableGenericSVGBridge
        extends AnimatableSVGBridge
        implements GenericBridge, BridgeUpdateHandler, SVGContext {

    /**
     * Invoked to handle an <tt>Element</tt> for a given <tt>BridgeContext</tt>.
     * For example, see the <tt>SVGTitleElementBridge</tt>.
     *
     * @param ctx the bridge context to use
     * @param e the element being handled
     */
    public void handleElement(BridgeContext ctx, Element e) {
        if (ctx.isDynamic()) {
            this.e = e;
            this.ctx = ctx;
            ((SVGOMElement) e).setSVGContext(this);
        }
    }

    // SVGContext ////////////////////////////////////////////////////////////

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

    /**
     * Returns the tight bounding box in current user space (i.e.,
     * after application of the transform attribute, if any) on the
     * geometry of all contained graphics elements, exclusive of
     * stroke-width and filter effects).
     */
    public Rectangle2D getBBox() {
        return null;
    }

    /**
     * Returns the transform from the global transform space to pixels.
     */
    public AffineTransform getScreenTransform() {
        return ctx.getUserAgent().getTransform();
    }

    /**
     * Sets the transform to be used from the global transform space to pixels.
     */
    public void setScreenTransform(AffineTransform at) {
        ctx.getUserAgent().setTransform(at);
    }

    /**
     * Returns the transformation matrix from current user units
     * (i.e., after application of the transform attribute, if any) to
     * the viewport coordinate system for the nearestViewportElement.
     */
    public AffineTransform getCTM() {
        return null;
    }

    /**
     * Returns the global transformation matrix from the current
     * element to the root.
     */
    public AffineTransform getGlobalTransform() {
        return null;
    }

    /**
     * Returns the width of the viewport which directly contains the
     * associated element.
     */
    public float getViewportWidth() {
        return 0f;
    }

    /**
     * Returns the height of the viewport which directly contains the
     * associated element.
     */
    public float getViewportHeight() {
        return 0f;
    }

    /**
     * Returns the font-size on the associated element.
     */
    public float getFontSize() {
        return 0f;
    }

    // BridgeUpdateHandler ///////////////////////////////////////////////////

    public void dispose() {
        ((SVGOMElement) e).setSVGContext(null);
    }

    public void handleDOMNodeInsertedEvent(MutationEvent evt) { 
    }

    public void handleDOMCharacterDataModified(MutationEvent evt) { 
    }

    public void handleDOMNodeRemovedEvent(MutationEvent evt) { 
        dispose();
    }

    public void handleDOMAttrModifiedEvent(MutationEvent evt) {
    }

    public void handleCSSEngineEvent(CSSEngineEvent evt) {
    }

    public void handleAnimatedAttributeChanged
            (AnimatedLiveAttributeValue alav) {
    }

    public void handleOtherAnimationChanged(String type) {
    }
}
