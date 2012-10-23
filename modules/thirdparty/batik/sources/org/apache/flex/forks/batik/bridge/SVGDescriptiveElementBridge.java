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

import org.w3c.dom.Element;
import org.w3c.dom.events.MutationEvent;

import org.apache.flex.forks.batik.css.engine.CSSEngineEvent;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.SVGContext;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;

/**
 * Base class for 'descriptive' elements, mostly title and desc.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: SVGDescriptiveElementBridge.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public abstract class SVGDescriptiveElementBridge extends AbstractSVGBridge
    implements GenericBridge,  BridgeUpdateHandler, SVGContext {

    Element theElt;
    Element parent;
    BridgeContext theCtx;

    public SVGDescriptiveElementBridge() {
    }


    /**
     * Invoked to handle an <tt>Element</tt> for a given
     * <tt>BridgeContext</tt>.  For example, see the
     * <tt>SVGDescElementBridge</tt>.
     *
     * @param ctx the bridge context to use
     * @param e the element to be handled
     */
    public void handleElement(BridgeContext ctx, Element e){
        UserAgent ua = ctx.getUserAgent();
        ua.handleElement(e, Boolean.TRUE);

        if (ctx.isDynamic()) {
            SVGDescriptiveElementBridge b;
            b = (SVGDescriptiveElementBridge)getInstance();
            b.theElt = e;
            b.parent = (Element)e.getParentNode();
            b.theCtx = ctx;
            ((SVGOMElement)e).setSVGContext(b);
        }

    }

    // BridgeUpdateHandler implementation ////////////////////////////////////

    public void dispose() {
        UserAgent ua = theCtx.getUserAgent();
        ((SVGOMElement)theElt).setSVGContext(null);
        ua.handleElement(theElt, parent);
        theElt = null;
        parent = null;
    }
    public void handleDOMNodeInsertedEvent(MutationEvent evt) {
        UserAgent ua = theCtx.getUserAgent();
        ua.handleElement(theElt, Boolean.TRUE);
    }
    public void handleDOMCharacterDataModified(MutationEvent evt) {
        UserAgent ua = theCtx.getUserAgent();
        ua.handleElement(theElt, Boolean.TRUE);
    }

    public void handleDOMNodeRemovedEvent (MutationEvent evt) {
        dispose();
    }

    public void handleDOMAttrModifiedEvent(MutationEvent evt) { }
    public void handleCSSEngineEvent(CSSEngineEvent evt) { }
    public void handleAnimatedAttributeChanged
        (AnimatedLiveAttributeValue alav) { }
    public void handleOtherAnimationChanged(String type) { }


    // SVGContext implementation ///////////////////////////////////////////

    /**
     * Returns the size of a px CSS unit in millimeters.
     */
    public float getPixelUnitToMillimeter() {
        return theCtx.getUserAgent().getPixelUnitToMillimeter();
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
        return theCtx.getUserAgent().getTransform();
    }
    public void setScreenTransform(AffineTransform at) {
        theCtx.getUserAgent().setTransform(at);
    }
    public AffineTransform getCTM() { return null; }
    public AffineTransform getGlobalTransform() { return null; }
    public float getViewportWidth() {
        return theCtx.getBlockWidth(theElt);
    }
    public float getViewportHeight() {
        return theCtx.getBlockHeight(theElt);
    }
    public float getFontSize() { return 0; }
}
