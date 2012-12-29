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

import java.awt.Cursor;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.svg.AbstractSVGAnimatedLength;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.dom.svg.SVGOMAnimatedLength;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.svg.SVGOMUseElement;
import org.apache.flex.forks.batik.dom.svg.SVGOMUseShadowRoot;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.svg.SVGTransformable;
import org.w3c.dom.svg.SVGUseElement;

/**
 * Bridge class for the &lt;use> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGUseElementBridge.java 580678 2007-09-30 05:10:20Z cam $
 */
public class SVGUseElementBridge extends AbstractGraphicsNodeBridge {

    /**
     * Used to handle mutation of the referenced content. This is
     * only used in dynamic context and only for reference to local
     * content.
     */
    protected ReferencedElementMutationListener l;

    /**
     * The bridge context for the referenced document.
     */
    protected BridgeContext subCtx;

    /**
     * Constructs a new bridge for the &lt;use> element.
     */
    public SVGUseElementBridge() {}

    /**
     * Returns 'use'.
     */
    public String getLocalName() {
        return SVG_USE_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance(){
        return new SVGUseElementBridge();
    }

    /**
     * Creates a <tt>GraphicsNode</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @return a graphics node that represents the specified element
     */
    public GraphicsNode createGraphicsNode(BridgeContext ctx, Element e) {
        // 'requiredFeatures', 'requiredExtensions' and 'systemLanguage'
        if (!SVGUtilities.matchUserAgent(e, ctx.getUserAgent()))
            return null;

        CompositeGraphicsNode gn = buildCompositeGraphicsNode(ctx, e, null);
        associateSVGContext(ctx, e, gn);

        return gn;
    }

    /**
     * Creates a <tt>GraphicsNode</tt> from the input element and
     * populates the input <tt>CompositeGraphicsNode</tt>
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @param gn the CompositeGraphicsNode where the use graphical 
     *        content will be appended. The composite node is emptied
     *        before appending new content.
     */
    public CompositeGraphicsNode buildCompositeGraphicsNode
            (BridgeContext ctx, Element e, CompositeGraphicsNode gn) {
        // get the referenced element
        SVGOMUseElement ue = (SVGOMUseElement) e;
        String uri = ue.getHref().getAnimVal();
        if (uri.length() == 0) {
            throw new BridgeException(ctx, e, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {"xlink:href"});
        }

        Element refElement = ctx.getReferencedElement(e, uri);

        SVGOMDocument document, refDocument;
        document    = (SVGOMDocument)e.getOwnerDocument();
        refDocument = (SVGOMDocument)refElement.getOwnerDocument();
        boolean isLocal = (refDocument == document);

        BridgeContext theCtx = ctx;
        subCtx = null;
        if (!isLocal) {
            subCtx = (BridgeContext)refDocument.getCSSEngine().getCSSContext();
            theCtx = subCtx;
        }
            
        // import or clone the referenced element in current document
        Element localRefElement;
        localRefElement = (Element)document.importNode(refElement, true, true);

        if (SVG_SYMBOL_TAG.equals(localRefElement.getLocalName())) {
            // The referenced 'symbol' and its contents are deep-cloned into
            // the generated tree, with the exception that the 'symbol'  is
            // replaced by an 'svg'.
            Element svgElement = document.createElementNS(SVG_NAMESPACE_URI, 
                                                          SVG_SVG_TAG);

            // move the attributes from <symbol> to the <svg> element
            NamedNodeMap attrs = localRefElement.getAttributes();
            int len = attrs.getLength();
            for (int i = 0; i < len; i++) {
                Attr attr = (Attr)attrs.item(i);
                svgElement.setAttributeNS(attr.getNamespaceURI(),
                                          attr.getName(),
                                          attr.getValue());
            }
            // move the children from <symbol> to the <svg> element
            for (Node n = localRefElement.getFirstChild();
                 n != null;
                 n = localRefElement.getFirstChild()) {
                svgElement.appendChild(n);
            }
            localRefElement = svgElement;
        }

        if (SVG_SVG_TAG.equals(localRefElement.getLocalName())) {
            // The referenced 'svg' and its contents are deep-cloned into the
            // generated tree. If attributes width and/or height are provided
            // on the 'use' element, then these values will override the
            // corresponding attributes on the 'svg' in the generated tree.
            try {
                SVGOMAnimatedLength al = (SVGOMAnimatedLength) ue.getWidth();
                if (al.isSpecified()) {
                    localRefElement.setAttributeNS
                        (null, SVG_WIDTH_ATTRIBUTE,
                         al.getAnimVal().getValueAsString());
                }
                al = (SVGOMAnimatedLength) ue.getHeight();
                if (al.isSpecified()) {
                    localRefElement.setAttributeNS
                        (null, SVG_HEIGHT_ATTRIBUTE,
                         al.getAnimVal().getValueAsString());
                }
            } catch (LiveAttributeException ex) {
                throw new BridgeException(ctx, ex);
            }
        }

        // attach the referenced element to the current document
        SVGOMUseShadowRoot root;
        root = new SVGOMUseShadowRoot(document, e, isLocal);
        root.appendChild(localRefElement);

        if (gn == null) {
            gn = new CompositeGraphicsNode();
            associateSVGContext(ctx, e, node);
        } else {
            int s = gn.size();
            for (int i=0; i<s; i++)
                gn.remove(0);
        }

        Node oldRoot = ue.getCSSFirstChild();
        if (oldRoot != null) {
            disposeTree(oldRoot);
        }
        ue.setUseShadowTree(root);

        Element g = localRefElement;

        // compute URIs and style sheets for the used element
        CSSUtilities.computeStyleAndURIs(refElement, localRefElement, uri);

        GVTBuilder builder = ctx.getGVTBuilder();
        GraphicsNode refNode = builder.build(ctx, g);

        ///////////////////////////////////////////////////////////////////////

        gn.getChildren().add(refNode);

        gn.setTransform(computeTransform((SVGTransformable) e, ctx));

        // set an affine transform to take into account the (x, y)
        // coordinates of the <use> element

        // 'visibility'
        gn.setVisible(CSSUtilities.convertVisibility(e));

        RenderingHints hints = null;
        hints = CSSUtilities.convertColorRendering(e, hints);
        if (hints != null)
            gn.setRenderingHints(hints);

        // 'enable-background'
        Rectangle2D r = CSSUtilities.convertEnableBackground(e);
        if (r != null)
            gn.setBackgroundEnable(r);

        if (l != null) {
            // Remove event listeners
            NodeEventTarget target = l.target;
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
                 l, true);
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
                 l, true);
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
                 l, true);
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMCharacterDataModified",
                 l, true);
            l = null;
        }

        ///////////////////////////////////////////////////////////////////////
        
        // Handle mutations on content referenced in the same file if
        // we are in a dynamic context.
        if (isLocal && ctx.isDynamic()) {
            l = new ReferencedElementMutationListener();
        
            NodeEventTarget target = (NodeEventTarget)refElement;
            l.target = target;
            
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
                 l, true, null);
            theCtx.storeEventListenerNS
                (target, XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
                 l, true);
            
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
                 l, true, null);
            theCtx.storeEventListenerNS
                (target, XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
                 l, true);
            
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
                 l, true, null);
            theCtx.storeEventListenerNS
                (target, XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
                 l, true);
            
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMCharacterDataModified",
                 l, true, null);
            theCtx.storeEventListenerNS
                (target, XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMCharacterDataModified",
                 l, true);
        }
        
        return gn;
    }

    public void dispose() {
        if (l != null) {
            // Remove event listeners
            NodeEventTarget target = l.target;
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
                 l, true);
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
                 l, true);
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
                 l, true);
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMCharacterDataModified",
                 l, true);
            l = null;
        }

        SVGOMUseElement ue = (SVGOMUseElement)e;
        if (ue != null && ue.getCSSFirstChild() != null) {
            disposeTree(ue.getCSSFirstChild());
        }

        super.dispose();

        subCtx = null;
    }

    /**
     * Returns an {@link AffineTransform} that is the transformation to
     * be applied to the node.
     */
    protected AffineTransform computeTransform(SVGTransformable e,
                                               BridgeContext ctx) {
        AffineTransform at = super.computeTransform(e, ctx);
        SVGUseElement ue = (SVGUseElement) e;
        try {
            // 'x' attribute - default is 0
            AbstractSVGAnimatedLength _x =
                (AbstractSVGAnimatedLength) ue.getX();
            float x = _x.getCheckedValue();

            // 'y' attribute - default is 0
            AbstractSVGAnimatedLength _y =
                (AbstractSVGAnimatedLength) ue.getY();
            float y = _y.getCheckedValue();

            AffineTransform xy = AffineTransform.getTranslateInstance(x, y);
            xy.preConcatenate(at);
            return xy;
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        }
     }

    /**
     * Creates the GraphicsNode depending on the GraphicsNodeBridge
     * implementation.
     */
    protected GraphicsNode instantiateGraphicsNode() {
        return null; // nothing to do, createGraphicsNode is fully overridden
    }

    /**
     * Returns false as the &lt;use> element is a not container.
     */
    public boolean isComposite() {
        return false;
    }

    /**
     * Builds using the specified BridgeContext and element, the
     * specified graphics node.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @param node the graphics node to build
     */
    public void buildGraphicsNode(BridgeContext ctx,
                                  Element e,
                                  GraphicsNode node) {

        super.buildGraphicsNode(ctx, e, node);

        if (ctx.isInteractive()) {
            NodeEventTarget target = (NodeEventTarget)e;
            EventListener l = new CursorMouseOverListener(ctx);
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOVER,
                 l, false, null);
            ctx.storeEventListenerNS
                (target, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOVER,
                 l, false);
        }
    }

    /**
     * To handle a mouseover on an anchor and set the cursor.
     */
    public static class CursorMouseOverListener implements EventListener {

        protected BridgeContext ctx;
        public CursorMouseOverListener(BridgeContext ctx) {
            this.ctx = ctx;
        }

        public void handleEvent(Event evt) {
            //
            // Only modify the cursor if the current target's (i.e., the <use>) cursor 
            // property is *not* 'auto'.
            //
            Element currentTarget = (Element)evt.getCurrentTarget();

            if (!CSSUtilities.isAutoCursor(currentTarget)) {
                Cursor cursor;
                cursor = CSSUtilities.convertCursor(currentTarget, ctx);
                if (cursor != null) {
                    ctx.getUserAgent().setSVGCursor(cursor);
                }
            }
        }
    }

    /**
     * Used to handle modifications to the referenced content
     */
    protected class ReferencedElementMutationListener implements EventListener {
        protected NodeEventTarget target;

        public void handleEvent(Event evt) {
            // We got a mutation in the referenced content. We need to 
            // build the content again, just in case.
            // Note that this is way sub-optimal, because multiple changes
            // to the referenced content will cause multiple updates to the
            // referencing <use>. However, this provides the desired behavior
            buildCompositeGraphicsNode(ctx, e, (CompositeGraphicsNode)node);
        }
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when the animated value of an animatable attribute has changed.
     */
    public void handleAnimatedAttributeChanged
            (AnimatedLiveAttributeValue alav) {
        try {
            String ns = alav.getNamespaceURI();
            String ln = alav.getLocalName();
            if (ns == null
                    && (ln.equals(SVG_X_ATTRIBUTE)
                        || ln.equals(SVG_Y_ATTRIBUTE)
                        || ln.equals(SVG_TRANSFORM_ATTRIBUTE))) {
                node.setTransform(computeTransform((SVGTransformable) e, ctx));
                handleGeometryChanged();
            } else if (ns == null
                    && (ln.equals(SVG_WIDTH_ATTRIBUTE)
                        || ln.equals(SVG_HEIGHT_ATTRIBUTE))
                    || ns.equals(XLINK_NAMESPACE_URI)
                        && (ln.equals(XLINK_HREF_ATTRIBUTE))) {
                buildCompositeGraphicsNode(ctx, e, (CompositeGraphicsNode)node);
            }
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        }
        super.handleAnimatedAttributeChanged(alav);
    }
}
