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

import java.awt.Dimension;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.flex.forks.batik.dom.svg.AbstractSVGAnimatedLength;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.dom.svg.SVGContext;
import org.apache.flex.forks.batik.dom.svg.SVGOMAnimatedRect;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;
import org.apache.flex.forks.batik.dom.svg.SVGOMSVGElement;
import org.apache.flex.forks.batik.dom.svg.SVGSVGContext;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.CanvasGraphicsNode;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.TextNode;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGAnimatedPreserveAspectRatio;
import org.w3c.dom.svg.SVGDocument;
import org.w3c.dom.svg.SVGRect;

/**
 * Bridge class for the &lt;svg> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGSVGElementBridge.java 579487 2007-09-26 06:40:16Z cam $
 */
public class SVGSVGElementBridge 
    extends SVGGElementBridge 
    implements SVGSVGContext {

    /**
     * Constructs a new bridge for the &lt;svg> element.
     */
    public SVGSVGElementBridge() {}

    /**
     * Returns 'svg'.
     */
    public String getLocalName() {
        return SVG_SVG_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance(){
        return new SVGSVGElementBridge();
    }

    /**
     * Creates a <tt>CompositeGraphicsNode</tt>.
     */
    protected GraphicsNode instantiateGraphicsNode() {
        return new CanvasGraphicsNode();
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
        if (!SVGUtilities.matchUserAgent(e, ctx.getUserAgent())) {
            return null;
        }

        CanvasGraphicsNode cgn;
        cgn = (CanvasGraphicsNode)instantiateGraphicsNode();

        associateSVGContext(ctx, e, cgn);

        try {
            // In some cases we converted document fragments which didn't
            // have a parent SVG element, this check makes sure only the
            // real root of the SVG Document tries to do negotiation with
            // the UA.
            SVGDocument doc = (SVGDocument)e.getOwnerDocument();
            SVGOMSVGElement se = (SVGOMSVGElement) e;
            boolean isOutermost = (doc.getRootElement() == e);
            float x = 0;
            float y = 0;
            // x and y have no meaning on the outermost 'svg' element
            if (!isOutermost) {
                // 'x' attribute - default is 0
                AbstractSVGAnimatedLength _x =
                    (AbstractSVGAnimatedLength) se.getX();
                x = _x.getCheckedValue();

                // 'y' attribute - default is 0
                AbstractSVGAnimatedLength _y =
                    (AbstractSVGAnimatedLength) se.getY();
                y = _y.getCheckedValue();
            }

            // 'width' attribute - default is 100%
            AbstractSVGAnimatedLength _width =
                (AbstractSVGAnimatedLength) se.getWidth();
            float w = _width.getCheckedValue();

            // 'height' attribute - default is 100%
            AbstractSVGAnimatedLength _height =
                (AbstractSVGAnimatedLength) se.getHeight();
            float h = _height.getCheckedValue();

            // 'visibility'
            cgn.setVisible(CSSUtilities.convertVisibility(e));

            // 'viewBox' and "preserveAspectRatio' attributes
            SVGOMAnimatedRect vb = (SVGOMAnimatedRect) se.getViewBox();
            SVGAnimatedPreserveAspectRatio par = se.getPreserveAspectRatio();
            AffineTransform viewingTransform =
                ViewBox.getPreserveAspectRatioTransform(e, vb, par, w, h, ctx);

            float actualWidth = w;
            float actualHeight = h;
            try {
                AffineTransform vtInv = viewingTransform.createInverse();
                actualWidth = (float) (w*vtInv.getScaleX());
                actualHeight = (float) (h*vtInv.getScaleY());
            } catch (NoninvertibleTransformException ex) {}

            AffineTransform positionTransform =
                AffineTransform.getTranslateInstance(x, y);
            // The outermost preserveAspectRatio matrix is set by the user
            // agent, so we don't need to set the transform for outermost svg
            if (!isOutermost) {
                // X & Y are ignored on outermost SVG.
                cgn.setPositionTransform(positionTransform);
            } else if (doc == ctx.getDocument()) {
                // <!> FIXME: hack to compute the original document's size
                ctx.setDocumentSize(new Dimension((int) (w + 0.5f),
                                                  (int) (h + 0.5f)));
            }
            // Set the viewing transform, this is often updated when the
            // component prepares for rendering.
            cgn.setViewingTransform(viewingTransform);

            // 'overflow' and 'clip'
            Shape clip = null;
            if (CSSUtilities.convertOverflow(e)) { // overflow:hidden
                float [] offsets = CSSUtilities.convertClip(e);
                if (offsets == null) { // clip:auto
                    clip = new Rectangle2D.Float(x, y, w, h);
                } else { // clip:rect(<x> <y> <w> <h>)
                    // offsets[0] = top
                    // offsets[1] = right
                    // offsets[2] = bottom
                    // offsets[3] = left
                    clip = new Rectangle2D.Float(x+offsets[3],
                                                 y+offsets[0],
                                                 w-offsets[1]-offsets[3],
                                                 h-offsets[2]-offsets[0]);
                }
            }

            if (clip != null) {
                try {
                    AffineTransform at = new AffineTransform(positionTransform);
                    at.concatenate(viewingTransform);
                    at = at.createInverse(); // clip in user space
                    clip = at.createTransformedShape(clip);
                    Filter filter = cgn.getGraphicsNodeRable(true);
                    cgn.setClip(new ClipRable8Bit(filter, clip));
                } catch (NoninvertibleTransformException ex) {}
            }
            RenderingHints hints = null;
            hints = CSSUtilities.convertColorRendering(e, hints);
            if (hints != null)
                cgn.setRenderingHints(hints);

            // 'enable-background'
            Rectangle2D r = CSSUtilities.convertEnableBackground(e);
            if (r != null) {
                cgn.setBackgroundEnable(r);
            }

            if (vb.isSpecified()) {
                SVGRect vbr = vb.getAnimVal();
                actualWidth = vbr.getWidth();
                actualHeight = vbr.getHeight();
            }
            ctx.openViewport
                (e, new SVGSVGElementViewport(actualWidth,
                                              actualHeight));
            return cgn;
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        }
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

        // 'opacity'
        node.setComposite(CSSUtilities.convertOpacity(e));
        // 'filter'
        node.setFilter(CSSUtilities.convertFilter(e, node, ctx));
        // 'mask'
        node.setMask(CSSUtilities.convertMask(e, node, ctx));
        // 'pointer-events'
        node.setPointerEventType(CSSUtilities.convertPointerEvents(e));

        initializeDynamicSupport(ctx, e, node);

        ctx.closeViewport(e);
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Disposes this BridgeUpdateHandler and releases all resources.
     */
    public void dispose() {
        ctx.removeViewport(e);
        super.dispose();
    }

    /**
     * Invoked when the animated value of an animatable attribute has changed.
     */
    public void handleAnimatedAttributeChanged
            (AnimatedLiveAttributeValue alav) {
        try {
            boolean rebuild = false;
            if (alav.getNamespaceURI() == null) {
                String ln = alav.getLocalName();
                if (ln.equals(SVG_WIDTH_ATTRIBUTE)
                        || ln.equals(SVG_HEIGHT_ATTRIBUTE)) {
                    rebuild = true;
                } else if (ln.equals(SVG_X_ATTRIBUTE)
                        || ln.equals(SVG_Y_ATTRIBUTE)) {
                    SVGDocument doc = (SVGDocument)e.getOwnerDocument();
                    SVGOMSVGElement se = (SVGOMSVGElement) e;
                    // X & Y are ignored on outermost SVG.
                    boolean isOutermost = doc.getRootElement() == e;
                    if (!isOutermost) {
                        // 'x' attribute - default is 0
                        AbstractSVGAnimatedLength _x =
                            (AbstractSVGAnimatedLength) se.getX();
                        float x = _x.getCheckedValue();

                        // 'y' attribute - default is 0
                        AbstractSVGAnimatedLength _y =
                            (AbstractSVGAnimatedLength) se.getY();
                        float y = _y.getCheckedValue();

                        AffineTransform positionTransform =
                            AffineTransform.getTranslateInstance(x, y);
                        CanvasGraphicsNode cgn;
                        cgn = (CanvasGraphicsNode)node;

                        cgn.setPositionTransform(positionTransform);
                        return;
                    }
                } else if (ln.equals(SVG_VIEW_BOX_ATTRIBUTE)
                        || ln.equals(SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE)) {
                    SVGDocument doc = (SVGDocument)e.getOwnerDocument();
                    SVGOMSVGElement se = (SVGOMSVGElement) e;
                    boolean isOutermost = doc.getRootElement() == e;

                    // X & Y are ignored on outermost SVG.
                    float x = 0;
                    float y = 0;
                    if (!isOutermost) {
                        // 'x' attribute - default is 0
                        AbstractSVGAnimatedLength _x =
                            (AbstractSVGAnimatedLength) se.getX();
                        x = _x.getCheckedValue();

                        // 'y' attribute - default is 0
                        AbstractSVGAnimatedLength _y =
                            (AbstractSVGAnimatedLength) se.getY();
                        y = _y.getCheckedValue();
                    }
                    
                    // 'width' attribute - default is 100%
                    AbstractSVGAnimatedLength _width =
                        (AbstractSVGAnimatedLength) se.getWidth();
                    float w = _width.getCheckedValue();
                    
                    // 'height' attribute - default is 100%
                    AbstractSVGAnimatedLength _height =
                        (AbstractSVGAnimatedLength) se.getHeight();
                    float h = _height.getCheckedValue();
                    
                    CanvasGraphicsNode cgn;
                    cgn = (CanvasGraphicsNode)node;
                    
                    // 'viewBox' and "preserveAspectRatio' attributes
                    SVGOMAnimatedRect vb = (SVGOMAnimatedRect) se.getViewBox();
                    SVGAnimatedPreserveAspectRatio par = se.getPreserveAspectRatio();
                    AffineTransform newVT = ViewBox.getPreserveAspectRatioTransform
                        (e, vb, par, w, h, ctx);

                    AffineTransform oldVT = cgn.getViewingTransform();
                    if ((newVT.getScaleX() != oldVT.getScaleX()) ||
                        (newVT.getScaleY() != oldVT.getScaleY()) ||
                        (newVT.getShearX() != oldVT.getShearX()) ||
                        (newVT.getShearY() != oldVT.getShearY()))
                        rebuild = true;
                    else {
                        // Only differs in translate.
                        cgn.setViewingTransform(newVT);
                        
                        // 'overflow' and 'clip'
                        Shape clip = null;
                        if (CSSUtilities.convertOverflow(e)) { // overflow:hidden
                            float [] offsets = CSSUtilities.convertClip(e);
                            if (offsets == null) { // clip:auto
                                clip = new Rectangle2D.Float(x, y, w, h);
                            } else { // clip:rect(<x> <y> <w> <h>)
                                // offsets[0] = top
                                // offsets[1] = right
                                // offsets[2] = bottom
                                // offsets[3] = left
                                clip = new Rectangle2D.Float(x+offsets[3],
                                                             y+offsets[0],
                                                             w-offsets[1]-offsets[3],
                                                             h-offsets[2]-offsets[0]);
                            }
                        }
                        
                        if (clip != null) {
                            try {
                                AffineTransform at;
                                at = cgn.getPositionTransform();
                                if (at == null) at = new AffineTransform();
                                else            at = new AffineTransform(at);
                                at.concatenate(newVT);
                                at = at.createInverse(); // clip in user space
                                clip = at.createTransformedShape(clip);
                                Filter filter = cgn.getGraphicsNodeRable(true);
                                cgn.setClip(new ClipRable8Bit(filter, clip));
                            } catch (NoninvertibleTransformException ex) {}
                        }
                    }
                }

                if (rebuild) {
                    CompositeGraphicsNode gn = node.getParent();
                    gn.remove(node);
                    disposeTree(e, false);

                    handleElementAdded(gn, e.getParentNode(), e);
                    return;
                }
            }
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        }
        super.handleAnimatedAttributeChanged(alav);
    }

    /**
     * A viewport defined an &lt;svg> element.
     */
    public static class SVGSVGElementViewport implements Viewport {
        private float width;
        private float height;

        /**
         * Constructs a new viewport with the specified <tt>SVGSVGElement</tt>.
         * @param w the width of the viewport
         * @param h the height of the viewport
         */
        public SVGSVGElementViewport(float w, float h) {
            this.width = w;
            this.height = h;
        }

        /**
         * Returns the width of this viewport.
         */
        public float getWidth(){
            return width;
        }

        /**
         * Returns the height of this viewport.
         */
        public float getHeight(){
            return height;
        }
    }

    public List getIntersectionList(SVGRect svgRect, Element end) {
        List ret = new ArrayList();
        Rectangle2D rect = new Rectangle2D.Float(svgRect.getX(),
                                                 svgRect.getY(),
                                                 svgRect.getWidth(),
                                                 svgRect.getHeight());

        GraphicsNode svgGN = ctx.getGraphicsNode(e);
        if (svgGN == null) return ret;

        Rectangle2D svgBounds = svgGN.getSensitiveBounds();
        if (svgBounds == null)
            return ret;

        // If the svg elem doesn't intersect none of the children
        // will.
        if (!rect.intersects(svgBounds))
            return ret;

        Element base = e;
        AffineTransform ati = svgGN.getGlobalTransform();
        try {
            ati = ati.createInverse();
        } catch (NoninvertibleTransformException e) {
        }
        
        Element curr;
        Node    next = base.getFirstChild();
        while (next != null) {
            if (next instanceof Element) 
                break;
            next = next.getNextSibling();
        }
        if (next == null) return ret;
        curr = (Element)next;

        Set ancestors = null;
        if (end != null) {
            ancestors = getAncestors(end, base);
            if (ancestors == null)
                end = null;
        }
        while (curr != null) {
            String nsURI = curr.getNamespaceURI();
            String tag = curr.getLocalName();
            boolean isGroup;
            isGroup = SVG_NAMESPACE_URI.equals(nsURI)
                && (SVG_G_TAG.equals(tag)
                        || SVG_SVG_TAG.equals(tag)
                        || SVG_A_TAG.equals(tag));

            GraphicsNode gn = ctx.getGraphicsNode(curr);
            if (gn == null) {
                // No graphics node but check if curr is an
                // ancestor of end.
                if ((ancestors != null) && (ancestors.contains(curr)))
                    break;
                curr = getNext(curr, base, end);
                continue;
            }
                

            AffineTransform at = gn.getGlobalTransform();
            Rectangle2D gnBounds = gn.getSensitiveBounds();
            at.preConcatenate(ati);
            if (gnBounds != null)
                gnBounds = at.createTransformedShape(gnBounds).getBounds2D();
                
            if ((gnBounds == null) || 
                (!rect.intersects(gnBounds))) {
                // Graphics node does not intersect check if curr is
                // an ancestor of end.
                if ((ancestors != null) && (ancestors.contains(curr)))
                    break;
                curr = getNext(curr, base, end);
                continue;
            }

            // Check if it is an SVG 'g', or 'svg' element in
            // which case don't add this node but do check it's
            // children.
            if (isGroup) {
                // Check children.
                next = curr.getFirstChild();
                while (next != null) {
                    if (next instanceof Element) 
                        break;
                    next = next.getNextSibling();
                }
                if (next != null) {
                    curr = (Element)next;
                    continue;
                }
            } else {
                if (curr == end) break;
                // Otherwise check this node for intersection more
                // carefully and if it still intersects add it.
                if (SVG_NAMESPACE_URI.equals(nsURI)
                        && SVG_USE_TAG.equals(tag)) {
                    // FIXX: This really isn't right we need to 
                    // Add the proxy children.
                    if (rect.contains(gnBounds))
                        ret.add(curr);
                } if (gn instanceof ShapeNode) {
                    ShapeNode sn = (ShapeNode)gn;
                    Shape sensitive = sn.getSensitiveArea();
                    if (sensitive != null) {
                        sensitive = at.createTransformedShape(sensitive);
                        if (sensitive.intersects(rect))
                            ret.add(curr);
                    }
                } else if (gn instanceof TextNode) {
                    SVGOMElement svgElem = (SVGOMElement)curr;
                    SVGTextElementBridge txtBridge;
                    txtBridge = (SVGTextElementBridge)svgElem.getSVGContext();
                    Set elems = txtBridge.getTextIntersectionSet(at, rect);

                    // filter elems based on who is before end as
                    // children of curr, if needed.
                    if ((ancestors != null) && ancestors.contains(curr))
                        filterChildren(curr, end, elems, ret);
                    else
                        ret.addAll(elems);

                } else {
                    ret.add(curr);
                }
            }

            curr = getNext(curr, base, end);
        }

        return ret;
    }

    public List getEnclosureList(SVGRect svgRect, Element end) {
        List ret = new ArrayList();
        Rectangle2D rect = new Rectangle2D.Float(svgRect.getX(),
                                                 svgRect.getY(),
                                                 svgRect.getWidth(),
                                                 svgRect.getHeight());
        GraphicsNode svgGN     = ctx.getGraphicsNode(e);
        if (svgGN == null) return ret;

        Rectangle2D  svgBounds = svgGN.getSensitiveBounds();
        if (svgBounds == null)
            return ret;

        // If the svg elem doesn't at least intersect none of the
        // children will be enclosed.
        if (!rect.intersects(svgBounds))
            return ret;

        Element base = e;
        AffineTransform ati = svgGN.getGlobalTransform();
        try {
            ati = ati.createInverse();
        } catch (NoninvertibleTransformException e) {
        }
        
        Element curr;
        Node    next = base.getFirstChild();
        while (next != null) {
            if (next instanceof Element) 
                break;
            next = next.getNextSibling();
        }

        if (next == null) return ret;
        curr = (Element)next;

        Set ancestors = null;
        if (end != null) {
            ancestors = getAncestors(end, base);
            if (ancestors == null)
                end = null;
        }

        while (curr != null) {
            String nsURI = curr.getNamespaceURI();
            String tag = curr.getLocalName();
            boolean isGroup;
            isGroup = SVG_NAMESPACE_URI.equals(nsURI)
                && (SVG_G_TAG.equals(tag)
                        || SVG_SVG_TAG.equals(tag)
                        || SVG_A_TAG.equals(tag));

            GraphicsNode gn = ctx.getGraphicsNode(curr);
            if (gn == null) {
                // No graphics node but check if curr is an
                // ancestor of end.
                if ((ancestors != null) && (ancestors.contains(curr)))
                    break;
                curr = getNext(curr, base, end);
                continue;
            }
                

            AffineTransform at = gn.getGlobalTransform();
            Rectangle2D gnBounds = gn.getSensitiveBounds();
            at.preConcatenate(ati);
            if (gnBounds != null)
                gnBounds = at.createTransformedShape(gnBounds).getBounds2D();

            if ((gnBounds == null) || 
                (!rect.intersects(gnBounds))) {
                // Graphics node does not intersect check if curr is
                // an ancestor of end.
                if ((ancestors != null) && (ancestors.contains(curr)))
                    break;
                curr = getNext(curr, base, end);
                continue;
            }

            // If it is a group then don't add this node but do check
            // it's children.
            if (isGroup) {
                // Check children.
                next = curr.getFirstChild();
                while (next != null) {
                    if (next instanceof Element) 
                        break;
                    next = next.getNextSibling();
                }
                if (next != null) {
                    curr = (Element)next;
                    continue;
                }
            } else {
                if (curr == end) break;
                if (SVG_NAMESPACE_URI.equals(nsURI)
                        && SVG_USE_TAG.equals(tag)) {
                    // FIXX: This really isn't right we need to 
                    // Add the proxy children.
                    if (rect.contains(gnBounds))
                        ret.add(curr);
                } else if (gn instanceof TextNode) {
                    // If gnBounds is contained in rect then just add
                    // all the children
                    SVGOMElement svgElem = (SVGOMElement)curr;
                    SVGTextElementBridge txtBridge;
                    txtBridge = (SVGTextElementBridge)svgElem.getSVGContext();
                    Set elems = txtBridge.getTextEnclosureSet(at, rect);
                    
                    // filter elems based on who is before end as
                    // children of curr if needed.
                    if ((ancestors != null) && ancestors.contains(curr))
                        filterChildren(curr, end, elems, ret);
                    else
                        ret.addAll(elems);
                } else if (rect.contains(gnBounds)) {
                    // shape nodes
                    ret.add(curr);
                }
            }

            curr = getNext(curr, base, end);
        }
        return ret;
    }

    public boolean checkIntersection (Element element, SVGRect svgRect ) {

        GraphicsNode svgGN = ctx.getGraphicsNode(e);
        if (svgGN == null) return false; // not in tree?

        Rectangle2D rect = new Rectangle2D.Float
            (svgRect.getX(),     svgRect.getY(), 
             svgRect.getWidth(), svgRect.getHeight());
        AffineTransform ati = svgGN.getGlobalTransform();

        try {
            ati = ati.createInverse();
        } catch (NoninvertibleTransformException e) {  }

        SVGContext svgctx = null;
        if (element instanceof SVGOMElement) {
            svgctx  = ((SVGOMElement)element).getSVGContext();
            if ((svgctx instanceof SVGTextElementBridge) ||
                (svgctx instanceof 
                 SVGTextElementBridge.AbstractTextChildSVGContext)) {
                return SVGTextElementBridge.getTextIntersection
                    (ctx, element, ati, rect, true);
            }
        }

        Rectangle2D gnBounds = null;
        GraphicsNode gn    = ctx.getGraphicsNode(element);
        if (gn != null)
            gnBounds = gn.getSensitiveBounds();

        if (gnBounds == null) return false;


        AffineTransform at = gn.getGlobalTransform();
        at.preConcatenate(ati);

        gnBounds = at.createTransformedShape(gnBounds).getBounds2D();
        if (!rect.intersects(gnBounds))
            return false;

        // Check GN more closely
        if (!(gn instanceof ShapeNode)) 
            return true;

        ShapeNode sn = (ShapeNode)gn;
        Shape sensitive = sn.getSensitiveArea();
        if (sensitive == null) return false;

        sensitive = at.createTransformedShape(sensitive);
        if (sensitive.intersects(rect))
            return true;

        return false;
    }

    public boolean checkEnclosure (Element element, SVGRect svgRect ) {
        GraphicsNode gn    = ctx.getGraphicsNode(element);
        Rectangle2D gnBounds = null;
        SVGContext svgctx = null;
        if (element instanceof SVGOMElement) {
            svgctx  = ((SVGOMElement)element).getSVGContext();
            if ((svgctx instanceof SVGTextElementBridge) ||
                (svgctx instanceof 
                 SVGTextElementBridge.AbstractTextChildSVGContext)) {
                gnBounds = SVGTextElementBridge.getTextBounds
                    (ctx, element, true);
                Element p = (Element)element.getParentNode();
                // Get GN for text children so we can get transform.
                while ((p != null) && (gn == null)) {
                    gn = ctx.getGraphicsNode(p);
                    p = (Element)p.getParentNode();
                }
            } else if (gn != null) 
                gnBounds = gn.getSensitiveBounds();
        } else if (gn != null) 
            gnBounds = gn.getSensitiveBounds();

        if (gnBounds == null) return false;

        GraphicsNode svgGN = ctx.getGraphicsNode(e);
        if (svgGN == null) return false; // not in tree?

        Rectangle2D rect = new Rectangle2D.Float
            (svgRect.getX(),     svgRect.getY(), 
             svgRect.getWidth(), svgRect.getHeight());
        AffineTransform ati = svgGN.getGlobalTransform();
        try {
            ati = ati.createInverse();
        } catch (NoninvertibleTransformException e) {  }

        AffineTransform at = gn.getGlobalTransform();
        at.preConcatenate(ati);

        gnBounds = at.createTransformedShape(gnBounds).getBounds2D();

        return rect.contains(gnBounds);
    }

    public boolean filterChildren(Element curr, Element end,
                                  Set elems, List ret) {
        Node child = curr.getFirstChild();
        while (child != null) {
            if ((child instanceof Element) &&
                filterChildren((Element)child, end, elems, ret))
                return true;
            child = child.getNextSibling();
        }

        if (curr == end) return true;

        if (elems.contains(curr))
            ret.add(curr);

        return false;
    }

    protected Set getAncestors(Element end, Element base) {
        Set ret = new HashSet();
        Element p = end;
        do {
            ret.add(p);
            p = (Element)p.getParentNode();
        } while ((p != null) && (p != base));
        
        if (p == null) // 'end' is not a child of 'base'.
            return null;

        return ret;
    }

    protected Element getNext(Element curr, Element base, Element end) {
        Node next;
        // Check the next element.
        next = curr.getNextSibling();
        while (next != null) {
            if (next instanceof Element) 
                break;
            next = next.getNextSibling();
        }
        while (next == null) {
            // No sibling so check parent's siblings...
            curr = (Element)curr.getParentNode();
            if ((curr == end) || (curr == base)) {
                next = null; // signal we are done!
                break;
            }
            next = curr.getNextSibling();
            while (next != null) {
                if (next instanceof Element) 
                    break;
                next = next.getNextSibling();
            }
        }

        return (Element)next;
    }

    public void deselectAll() {
        ctx.getUserAgent().deselectAll();
    }

    public int          suspendRedraw ( int max_wait_milliseconds ) {
        UpdateManager um = ctx.getUpdateManager();
        if (um != null)
            return um.addRedrawSuspension(max_wait_milliseconds);
        return -1;
    }
    public boolean      unsuspendRedraw ( int suspend_handle_id ) {
        UpdateManager um = ctx.getUpdateManager();
        if (um != null)
            return um.releaseRedrawSuspension(suspend_handle_id);
        return false; // no UM so couldn't have issued an id...
    }
    public void         unsuspendRedrawAll (  ) {
        UpdateManager um = ctx.getUpdateManager();
        if (um != null)
            um.releaseAllRedrawSuspension();
    }

    public void          forceRedraw (  ) {
        UpdateManager um = ctx.getUpdateManager();
        if (um != null)
            um.forceRepaint();
    }
    
    /**
     * Pauses animations in the document.
     */
    public void pauseAnimations() {
        ctx.getAnimationEngine().pause();
    }

    /**
     * Unpauses animations in the document.
     */
    public void unpauseAnimations() {
        ctx.getAnimationEngine().unpause();
    }

    /**
     * Returns whether animations are currently paused.
     */
    public boolean animationsPaused() {
        return ctx.getAnimationEngine().isPaused();
    }

    /**
     * Returns the current document time.
     */
    public float getCurrentTime() {
        return ctx.getAnimationEngine().getCurrentTime();
    }

    /**
     * Sets the current document time.
     */
    public void setCurrentTime(float t) {
        ctx.getAnimationEngine().setCurrentTime(t);
    }
}
