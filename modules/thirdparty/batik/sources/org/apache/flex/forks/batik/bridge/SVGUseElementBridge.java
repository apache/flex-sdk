/*

   Copyright 2001-2004  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

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

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.dom.svg.SVGOMCSSImportedElementRoot;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.svg.SVGOMUseElement;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for the &lt;use> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGUseElementBridge.java,v 1.47 2005/03/03 01:19:53 deweese Exp $
 */
public class SVGUseElementBridge extends AbstractGraphicsNodeBridge {
    /*
     * Used to handle mutation of the referenced content. This is
     * only used in dynamic context and only for reference to local
     * content.
     */
    protected ReferencedElementMutationListener l;

    protected BridgeContext subCtx=null;

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
        (BridgeContext ctx, Element e,
         CompositeGraphicsNode gn) {
        // get the referenced element
        String uri = XLinkSupport.getXLinkHref(e);
        if (uri.length() == 0) {
            throw new BridgeException(e, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {"xlink:href"});
        }

        Element refElement = ctx.getReferencedElement(e, uri);

        SVGOMDocument document
            = (SVGOMDocument)e.getOwnerDocument();
        SVGOMDocument refDocument
            = (SVGOMDocument)refElement.getOwnerDocument();
        boolean isLocal = (refDocument == document);

        BridgeContext theCtx = ctx;
        subCtx = null;
        if (!isLocal) {
            CSSEngine eng = refDocument.getCSSEngine();
            subCtx = (BridgeContext)refDocument.getCSSEngine().getCSSContext();
            theCtx = subCtx;
        }
            
        // import or clone the referenced element in current document
        Element localRefElement = 
            (Element)document.importNode(refElement, true, true);

        if (SVG_SYMBOL_TAG.equals(localRefElement.getLocalName())) {
            // The referenced 'symbol' and its contents are deep-cloned into
            // the generated tree, with the exception that the 'symbol'  is
            // replaced by an 'svg'.
            Element svgElement
                = document.createElementNS(SVG_NAMESPACE_URI, SVG_SVG_TAG);
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
            String wStr = e.getAttributeNS(null, SVG_WIDTH_ATTRIBUTE);
            if (wStr.length() != 0) {
                localRefElement.setAttributeNS
                    (null, SVG_WIDTH_ATTRIBUTE, wStr);
            }
            String hStr = e.getAttributeNS(null, SVG_HEIGHT_ATTRIBUTE);
            if (hStr.length() != 0) {
                localRefElement.setAttributeNS
                    (null, SVG_HEIGHT_ATTRIBUTE, hStr);
            }
        }

        // attach the referenced element to the current document
        SVGOMCSSImportedElementRoot root;
        root = new SVGOMCSSImportedElementRoot(document, e, isLocal);
        root.appendChild(localRefElement);

        if (gn == null) {
            gn = new CompositeGraphicsNode();
        } else {
            int s = gn.size();
            for (int i=0; i<s; i++)
                gn.remove(0);
        }

        SVGOMUseElement ue = (SVGOMUseElement)e;
        Node oldRoot = ue.getCSSImportedElementRoot();
        if (oldRoot != null) {
            disposeTree(oldRoot);
        }
        ue.setCSSImportedElementRoot(root);

        Element g = localRefElement;

        // compute URIs and style sheets for the used element
        CSSUtilities.computeStyleAndURIs(refElement, localRefElement, uri);

        GVTBuilder builder = ctx.getGVTBuilder();
        GraphicsNode refNode = builder.build(ctx, g);

        ///////////////////////////////////////////////////////////////////////

        gn.getChildren().add(refNode);

        gn.setTransform(computeTransform(e, ctx));

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
            EventTarget target = l.target;
            target.removeEventListener("DOMAttrModified", l, true);
            target.removeEventListener("DOMNodeInserted", l, true);
            target.removeEventListener("DOMNodeRemoved", l, true);
            target.removeEventListener("DOMCharacterDataModified",l, true);
            l = null;
        }

        ///////////////////////////////////////////////////////////////////////
        
        // Handle mutations on content referenced in the same file if
        // we are in a dynamic context.
        if (isLocal && ctx.isDynamic()) {
            l = new ReferencedElementMutationListener();
        
            EventTarget target = (EventTarget)refElement;
            l.target = target;
            
            target.addEventListener("DOMAttrModified", l, true);
            theCtx.storeEventListener(target, "DOMAttrModified", l, true);
            
            target.addEventListener("DOMNodeInserted", l, true);
            theCtx.storeEventListener(target, "DOMNodeInserted", l, true);
            
            target.addEventListener("DOMNodeRemoved", l, true);
            theCtx.storeEventListener(target, "DOMNodeRemoved", l, true);
            
            target.addEventListener("DOMCharacterDataModified", l, true);
            theCtx.storeEventListener
                (target, "DOMCharacterDataModified", l, true);
        }
        
        return gn;
    }

    public void dispose() {
        if (l != null) {
            // Remove event listeners
            EventTarget target = l.target;
            target.removeEventListener("DOMAttrModified", l, true);
            target.removeEventListener("DOMNodeInserted", l, true);
            target.removeEventListener("DOMNodeRemoved", l, true);
            target.removeEventListener("DOMCharacterDataModified",l, true);
            l = null;
        }

        SVGOMUseElement ue = (SVGOMUseElement)e;
        if ((ue != null) && (ue.getCSSImportedElementRoot() != null)) {
            disposeTree(ue.getCSSImportedElementRoot());
        }

        super.dispose();

        subCtx = null;
    }

    /**
     * Computes the AffineTransform for the node
     */
    protected AffineTransform computeTransform(Element e, BridgeContext ctx) {
        UnitProcessor.Context uctx = UnitProcessor.createContext(ctx, e);

        // 'x' attribute - default is 0
        float x = 0;
        String s = e.getAttributeNS(null, SVG_X_ATTRIBUTE);
        if (s.length() != 0) {
            x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_X_ATTRIBUTE, uctx);
        }

        // 'y' attribute - default is 0
        float y = 0;
        s = e.getAttributeNS(null, SVG_Y_ATTRIBUTE);
        if (s.length() != 0) {
            y = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_Y_ATTRIBUTE, uctx);
        }

        // set an affine transform to take into account the (x, y)
        // coordinates of the <use> element
        s = e.getAttributeNS(null, SVG_TRANSFORM_ATTRIBUTE);
        AffineTransform at = AffineTransform.getTranslateInstance(x, y);

        // 'transform'
        if (s.length() != 0) {
            at.preConcatenate
                (SVGUtilities.convertTransform(e, SVG_TRANSFORM_ATTRIBUTE, s));
        }

        return at;
     }

    /**
     * Creates the GraphicsNode depending on the GraphicsNodeBridge
     * implementation.
     */
    protected GraphicsNode instantiateGraphicsNode() {
        return null; // nothing to do, createGraphicsNode is fully overriden
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
            EventTarget target = (EventTarget)e;
            EventListener l = new CursorMouseOverListener(ctx);
            target.addEventListener(SVG_EVENT_MOUSEOVER, l, false);
            ctx.storeEventListener(target, SVG_EVENT_MOUSEOVER, l, false);
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
    public class ReferencedElementMutationListener implements EventListener {
        EventTarget target;

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
     * Invoked when an MutationEvent of type 'DOMAttrModified' is fired.
     */
    public void handleDOMAttrModifiedEvent(MutationEvent evt) {
        String attrName = evt.getAttrName();
        Node evtNode = evt.getRelatedNode();

        if ((evtNode.getNamespaceURI() == null) &&
            (attrName.equals(SVG_X_ATTRIBUTE) ||
             attrName.equals(SVG_Y_ATTRIBUTE) ||
             attrName.equals(SVG_TRANSFORM_ATTRIBUTE))) {
            node.setTransform(computeTransform(e, ctx));
            handleGeometryChanged();
        } else if (((evtNode.getNamespaceURI() == null) && 
                   (attrName.equals(SVG_WIDTH_ATTRIBUTE) ||
                    attrName.equals(SVG_HEIGHT_ATTRIBUTE))) ||
                   (( XLinkSupport.XLINK_NAMESPACE_URI.equals
                     (evtNode.getNamespaceURI()) ) &&  
                    SVG_HREF_ATTRIBUTE.equals(evtNode.getLocalName()))) {
            buildCompositeGraphicsNode(ctx, e, (CompositeGraphicsNode)node);
        }
    }
}
