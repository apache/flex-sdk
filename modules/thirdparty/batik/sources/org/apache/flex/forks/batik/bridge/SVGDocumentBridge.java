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
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.RootGraphicsNode;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for an SVGDocument node.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGDocumentBridge.java 582434 2007-10-06 02:11:51Z cam $
 */
public class SVGDocumentBridge implements DocumentBridge, BridgeUpdateHandler,
                                          SVGContext {

    /**
     * The document node this bridge is associated with.
     */
    protected Document document;

    /**
     * The graphics node constructed by this bridge.
     */
    protected RootGraphicsNode node;

    /**
     * The bridge context.
     */
    protected BridgeContext ctx;

    /**
     * Constructs a new bridge the SVG document.
     */
    public SVGDocumentBridge() {
    }

    // Bridge ////////////////////////////////////////////////////////////////

    /**
     * Returns the namespace URI of the element this <tt>Bridge</tt> is
     * dedicated to.  Returns <code>null</code>, as a Document node has no
     * namespace URI.
     */
    public String getNamespaceURI() {
        return null;
    }

    /**
     * Returns the local name of the element this <tt>Bridge</tt> is dedicated
     * to.  Returns <code>null</code>, as a Document node has no local name.
     */
    public String getLocalName() {
        return null;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGDocumentBridge();
    }

    // DocumentBridge ////////////////////////////////////////////////////////

    /**
     * Creates a <tt>GraphicsNode</tt> according to the specified parameters.
     * This is called before children have been added to the
     * returned GraphicsNode (obviously since you construct and return it).
     *
     * @param ctx the bridge context to use
     * @param doc the document node that describes the graphics node to build
     * @return a graphics node that represents the specified document node
     */
    public RootGraphicsNode createGraphicsNode(BridgeContext ctx,
                                               Document doc) {
        RootGraphicsNode gn = new RootGraphicsNode();
        this.document = doc;
        this.node = gn;
        this.ctx = ctx;
        ((SVGOMDocument) doc).setSVGContext(this);
        return gn;
    }

    /**
     * Builds using the specified BridgeContext and element, the
     * specified graphics node.  This is called after all the children
     * of the node have been constructed and added, so it is safe to
     * do work that depends on being able to see your children nodes
     * in this method.
     *
     * @param ctx the bridge context to use
     * @param doc the document node that describes the graphics node to build
     * @param node the graphics node to build
     */
    public void buildGraphicsNode(BridgeContext ctx,
                                  Document doc,
                                  RootGraphicsNode node) {
        if (ctx.isDynamic()) {
            ctx.bind(doc, node);
        }
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
        if (evt.getTarget() instanceof Element) {
            Element childElt = (Element) evt.getTarget();

            GVTBuilder builder = ctx.getGVTBuilder();
            GraphicsNode childNode = builder.build(ctx, childElt);
            if (childNode == null) {
                return;
            }

            // There can only be one document element.
            node.add(childNode);
        }
    }

    /**
     * Invoked when an MutationEvent of type 'DOMNodeRemoved' is fired.
     */
    public void handleDOMNodeRemovedEvent(MutationEvent evt) {
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
     * Invoked when the animated value of an animated attribute has changed.
     */
    public void handleAnimatedAttributeChanged(AnimatedLiveAttributeValue alav) {
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
        ((SVGOMDocument) document).setSVGContext(null);
        ctx.unbind(document);
    }

    // SVGContext //////////////////////////////////////////////////////////

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
    public float getViewportWidth() { return 0f; }
    public float getViewportHeight() { return 0f; }
    public float getFontSize() { return 0; }
}
