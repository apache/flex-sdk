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

import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.color.ColorSpace;
import java.awt.color.ICC_Profile;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.InterruptedIOException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.events.DOMMouseEvent;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.svg.AbstractSVGAnimatedLength;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.dom.svg.SVGOMAnimatedPreserveAspectRatio;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;
import org.apache.flex.forks.batik.ext.awt.color.ICCColorSpaceExt;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.spi.BrokenLinkProvider;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageTagRegistry;
import org.apache.flex.forks.batik.gvt.CanvasGraphicsNode;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.ImageNode;
import org.apache.flex.forks.batik.gvt.RasterImageNode;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.util.HaltingThread;
import org.apache.flex.forks.batik.util.MimeTypeConstants;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.svg.SVGDocument;
import org.w3c.dom.svg.SVGImageElement;
import org.w3c.dom.svg.SVGSVGElement;

/**
 * Bridge class for the &lt;image> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGImageElementBridge.java 579487 2007-09-26 06:40:16Z cam $
 */
public class SVGImageElementBridge extends AbstractGraphicsNodeBridge {

    protected SVGDocument imgDocument;
    protected EventListener listener = null;
    protected BridgeContext subCtx = null;
    protected boolean hitCheckChildren = false;
    /**
     * Constructs a new bridge for the &lt;image> element.
     */
    public SVGImageElementBridge() {}

    /**
     * Returns 'image'.
     */
    public String getLocalName() {
        return SVG_IMAGE_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGImageElementBridge();
    }

    /**
     * Creates a graphics node using the specified BridgeContext and for the
     * specified element.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @return a graphics node that represents the specified element
     */
    public GraphicsNode createGraphicsNode(BridgeContext ctx, Element e) {
        ImageNode imageNode = (ImageNode)super.createGraphicsNode(ctx, e);
        if (imageNode == null) {
            return null;
        }

        associateSVGContext(ctx, e, imageNode);

        hitCheckChildren = false;
        GraphicsNode node = buildImageGraphicsNode(ctx,e);

        if (node == null) {
            SVGImageElement ie = (SVGImageElement) e;
            String uriStr = ie.getHref().getAnimVal();
            throw new BridgeException(ctx, e, ERR_URI_IMAGE_INVALID,
                                      new Object[] {uriStr});
        }

        imageNode.setImage(node);
        imageNode.setHitCheckChildren(hitCheckChildren);

        // 'image-rendering' and 'color-rendering'
        RenderingHints hints = null;
        hints = CSSUtilities.convertImageRendering(e, hints);
        hints = CSSUtilities.convertColorRendering(e, hints);
        if (hints != null)
            imageNode.setRenderingHints(hints);

        return imageNode;
    }

    /**
     * Create a Graphics node according to the
     * resource pointed by the href : RasterImageNode
     * for bitmaps, CompositeGraphicsNode for svg files.
     *
     * @param ctx : the bridge context to use
     * @param e the element that describes the graphics node to build
     *
     * @return the graphic node that represent the resource
     *  pointed by the reference
     */
    protected GraphicsNode buildImageGraphicsNode
        (BridgeContext ctx, Element e){

        SVGImageElement ie = (SVGImageElement) e;

        // 'xlink:href' attribute - required
        String uriStr = ie.getHref().getAnimVal();
        if (uriStr.length() == 0) {
            throw new BridgeException(ctx, e, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {"xlink:href"});
        }
        if (uriStr.indexOf('#') != -1) {
            throw new BridgeException(ctx, e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                      new Object[] {"xlink:href", uriStr});
        }

        // Build the URL.
        String baseURI = AbstractNode.getBaseURI(e);
        ParsedURL purl;
        if (baseURI == null) {
            purl = new ParsedURL(uriStr);
        } else {
            purl = new ParsedURL(baseURI, uriStr);
        }

        return createImageGraphicsNode(ctx, e, purl);
    }

    protected GraphicsNode createImageGraphicsNode(BridgeContext ctx,
                                                   Element e,
                                                   ParsedURL purl) {
        Rectangle2D bounds = getImageBounds(ctx, e);
        if ((bounds.getWidth() == 0) || (bounds.getHeight() == 0)) {
            ShapeNode sn = new ShapeNode();
            sn.setShape(bounds);
            return sn;
        }

        SVGDocument svgDoc = (SVGDocument)e.getOwnerDocument();
        String docURL = svgDoc.getURL();
        ParsedURL pDocURL = null;
        if (docURL != null)
            pDocURL = new ParsedURL(docURL);

        UserAgent userAgent = ctx.getUserAgent();

        try {
            userAgent.checkLoadExternalResource(purl, pDocURL);
        } catch (SecurityException secEx ) {
            throw new BridgeException(ctx, e, secEx, ERR_URI_UNSECURE,
                                      new Object[] {purl});
        }

        DocumentLoader loader = ctx.getDocumentLoader();
        ImageTagRegistry reg = ImageTagRegistry.getRegistry();
        ICCColorSpaceExt colorspace = extractColorSpace(e, ctx);
        {
            /**
             *  Before we open the URL we see if we have the
             *  URL already cached and parsed
             */
            try {
                /* Check the document loader cache */
                Document doc = loader.checkCache(purl.toString());
                if (doc != null) {
                    imgDocument = (SVGDocument)doc;
                    return createSVGImageNode(ctx, e, imgDocument);
                }
            } catch (BridgeException ex) {
                throw ex;
            } catch (Exception ex) {
                /* Nothing to do */
            }

            /* Check the ImageTagRegistry Cache */
            Filter img = reg.checkCache(purl, colorspace);
            if (img != null) {
                return createRasterImageNode(ctx, e, img, purl);
            }
        }

        /* The Protected Stream ensures that the stream doesn't
         * get closed unless we want it to. It is also based on
         * a Buffered Reader so in general we can mark the start
         * and reset rather than reopening the stream.  Finally
         * it hides the mark/reset methods so only we get to
         * use them.
         */
        ProtectedStream reference = null;
        try {
            reference = openStream(e, purl);
        } catch (SecurityException secEx ) {
            throw new BridgeException(ctx, e, secEx, ERR_URI_UNSECURE,
                                      new Object[] {purl});
        } catch (IOException ioe) {
            return createBrokenImageNode(ctx, e, purl.toString(),
                                         ioe.getLocalizedMessage());
        }

        {
            /**
             * First see if we can id the file as a Raster via magic
             * number.  This is probably the fastest mechanism.
             * We tell the registry what the source purl is but we
             * tell it not to open that url.
             */
            Filter img = reg.readURL(reference, purl, colorspace,
                                     false, false);
            if (img != null) {
                // It's a bouncing baby Raster...
                return createRasterImageNode(ctx, e, img, purl);
            }
        }

        try {
            // Reset the stream for next try.
            reference.retry();
        } catch (IOException ioe) {
            reference.release();
            reference = null;
            try {
                // Couldn't reset stream so reopen it.
                reference = openStream(e, purl);
            } catch (IOException ioe2) {
                // Since we already opened the stream this is unlikely.
                return createBrokenImageNode(ctx, e, purl.toString(),
                                             ioe2.getLocalizedMessage());
            }
        }

        try {
            /**
             * Next see if it's an XML document.
             */
            Document doc = loader.loadDocument(purl.toString(), reference);
            imgDocument = (SVGDocument)doc;
            return createSVGImageNode(ctx, e, imgDocument);
        } catch (BridgeException ex) {
            throw ex;
        } catch (SecurityException secEx ) {
            throw new BridgeException(ctx, e, secEx, ERR_URI_UNSECURE,
                                      new Object[] {purl});
        } catch (InterruptedIOException iioe) {
            if (HaltingThread.hasBeenHalted())
                throw new InterruptedBridgeException();

        } catch (InterruptedBridgeException ibe) {
            throw ibe;
        } catch (Exception ex) {
            /* Nothing to do */
            // ex.printStackTrace();
        }

        try {
            reference.retry();
        } catch (IOException ioe) {
            reference.release();
            reference = null;
            try {
                // Couldn't reset stream so reopen it.
                reference = openStream(e, purl);
            } catch (IOException ioe2) {
                return createBrokenImageNode(ctx, e, purl.toString(),
                                             ioe2.getLocalizedMessage());
            }
        }

        try {
            // Finally try to load the image as a raster image (JPG or
            // PNG) allowing the registry to open the url (so the
            // JDK readers can be checked).
            Filter img = reg.readURL(reference, purl, colorspace,
                                     true, true);
            if (img != null) {
                // It's a bouncing baby Raster...
                return createRasterImageNode(ctx, e, img, purl);
            }
        } finally {
            reference.release();
        }
        return null;
    }

    public static class ProtectedStream extends BufferedInputStream {
        static final int BUFFER_SIZE = 8192;
        ProtectedStream(InputStream is) {
            super(is, BUFFER_SIZE);
            super.mark(BUFFER_SIZE); // Remember start
        }
        ProtectedStream(InputStream is, int size) {
            super(is, size);
            super.mark(size); // Remember start
        }

        public boolean markSupported() {
            return false;
        }
        public void mark(int sz){
        }
        public void reset() throws IOException {
            throw new IOException("Reset unsupported");
        }

        public void retry() throws IOException {
            super.reset();
        }

        public void close() throws IOException {
            /* do nothing */
        }

        public void release() {
            try {
                super.close();
            } catch (IOException ioe) {
                // Like Duh! what would you do close it again?
            }
        }
    }

    protected ProtectedStream openStream(Element e, ParsedURL purl)
        throws IOException {
        List mimeTypes = new ArrayList
            (ImageTagRegistry.getRegistry().getRegisteredMimeTypes());
        mimeTypes.add(MimeTypeConstants.MIME_TYPES_SVG);
        InputStream reference = purl.openStream(mimeTypes.iterator());
        return new ProtectedStream(reference);
    }

    /**
     * Creates an <tt>ImageNode</tt>.
     */
    protected GraphicsNode instantiateGraphicsNode() {
        return new ImageNode();
    }

    /**
     * Returns false as image is not a container.
     */
    public boolean isComposite() {
        return false;
    }

    // dynamic support

    /**
     * This method is invoked during the build phase if the document
     * is dynamic. The responsability of this method is to ensure that
     * any dynamic modifications of the element this bridge is
     * dedicated to, happen on its associated GVT product.
     */
    protected void initializeDynamicSupport(BridgeContext ctx,
                                            Element e,
                                            GraphicsNode node) {
        if (!ctx.isInteractive())
            return;

        // Bind the nodes for interactive and dynamic
        // HACK due to the way images are represented in GVT
        ctx.bind(e, node);

        if (ctx.isDynamic()) {
            // Only do this for dynamic not interactive.
            this.e = e;
            this.node = node;
            this.ctx = ctx;
            ((SVGOMElement)e).setSVGContext(this);
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
            if (ns == null) {
                if (ln.equals(SVG_X_ATTRIBUTE)
                        || ln.equals(SVG_Y_ATTRIBUTE)) {
                    updateImageBounds();
                    return;
                } else if (ln.equals(SVG_WIDTH_ATTRIBUTE)
                        || ln.equals(SVG_HEIGHT_ATTRIBUTE)) {
                    SVGImageElement ie = (SVGImageElement) e;
                    ImageNode imageNode = (ImageNode) node;
                    AbstractSVGAnimatedLength _attr;
                    if (ln.charAt(0) == 'w') {
                        _attr = (AbstractSVGAnimatedLength) ie.getWidth();
                    } else {
                        _attr = (AbstractSVGAnimatedLength) ie.getHeight();
                    }
                    float val = _attr.getCheckedValue();
                    if (val == 0 || imageNode.getImage() instanceof ShapeNode) {
                        rebuildImageNode();
                    } else {
                        updateImageBounds();
                    }
                    return;
                } else if (ln.equals(SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE)) {
                    updateImageBounds();
                    return;
                }
            } else if (ns.equals(XLINK_NAMESPACE_URI)
                    && ln.equals(XLINK_HREF_ATTRIBUTE)) {
                rebuildImageNode();
                return;
            }
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        }
        super.handleAnimatedAttributeChanged(alav);
    }

    protected void updateImageBounds() {
        //retrieve the new bounds of the image tag
        Rectangle2D bounds = getImageBounds(ctx, e);
        GraphicsNode imageNode = ((ImageNode)node).getImage();
        float[] vb = null;
        if (imageNode instanceof RasterImageNode) {
            //Raster image
            Rectangle2D imgBounds =
                ((RasterImageNode)imageNode).getImageBounds();
            // create the implicit viewBox for the raster
            // image. The viewBox for a raster image is the size
            // of the image
            vb = new float[4];
            vb[0] = 0; // x
            vb[1] = 0; // y
            vb[2] = (float)imgBounds.getWidth(); // width
            vb[3] = (float)imgBounds.getHeight(); // height
        } else {
            if (imgDocument != null) {
                Element svgElement = imgDocument.getRootElement();
                String viewBox = svgElement.getAttributeNS
                    (null, SVG_VIEW_BOX_ATTRIBUTE);
                vb = ViewBox.parseViewBoxAttribute(e, viewBox, ctx);
            }
        }
        if (imageNode != null) {
            // handles the 'preserveAspectRatio', 'overflow' and
            // 'clip' and sets the appropriate AffineTransform to
            // the image node
            initializeViewport(ctx, e, imageNode, vb, bounds);
        }

    }

    protected void rebuildImageNode() {
        // Reference copy of the imgDocument
        if ((imgDocument != null) && (listener != null)) {
            NodeEventTarget tgt = (NodeEventTarget)imgDocument.getRootElement();

            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_CLICK,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYDOWN,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYPRESS,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYUP,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEDOWN,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEMOVE,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOUT,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOVER,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEUP,
                 listener, false);
            listener = null;
        }

        if (imgDocument != null) {
            SVGSVGElement svgElement = imgDocument.getRootElement();
            disposeTree(svgElement);
        }

        imgDocument = null;
        subCtx = null;

        //update of the reference of the image.
        GraphicsNode inode = buildImageGraphicsNode(ctx,e);

        ImageNode imgNode = (ImageNode)node;
        imgNode.setImage(inode);

        if (inode == null) {
            SVGImageElement ie = (SVGImageElement) e;
            String uriStr = ie.getHref().getAnimVal();
            throw new BridgeException(ctx, e, ERR_URI_IMAGE_INVALID,
                                      new Object[] {uriStr});
        }
    }

    /**
     * Invoked for each CSS property that has changed.
     */
    protected void handleCSSPropertyChanged(int property) {
        switch(property) {
        case SVGCSSEngine.IMAGE_RENDERING_INDEX:
        case SVGCSSEngine.COLOR_INTERPOLATION_INDEX:
            RenderingHints hints = CSSUtilities.convertImageRendering(e, null);
            hints = CSSUtilities.convertColorRendering(e, hints);
            if (hints != null) {
                node.setRenderingHints(hints);
            }
            break;
        default:
            super.handleCSSPropertyChanged(property);
        }
    }

    // convenient methods //////////////////////////////////////////////////

    /**
     * Returns a GraphicsNode that represents an raster image in JPEG or PNG
     * format.
     *
     * @param ctx the bridge context
     * @param e the image element
     * @param img the image to use in creating the graphics node
     */
    protected GraphicsNode createRasterImageNode(BridgeContext ctx,
                                                 Element       e,
                                                 Filter        img,
                                                 ParsedURL     purl) {
        Rectangle2D bounds = getImageBounds(ctx, e);
        if ((bounds.getWidth() == 0) || (bounds.getHeight() == 0)) {
            ShapeNode sn = new ShapeNode();
            sn.setShape(bounds);
            return sn;
        }

        if (BrokenLinkProvider.hasBrokenLinkProperty(img)) {
            Object o=img.getProperty(BrokenLinkProvider.BROKEN_LINK_PROPERTY);
            String msg = "unknown";
            if (o instanceof String)
                msg = (String)o;
            SVGDocument doc = ctx.getUserAgent().getBrokenLinkDocument
                (e, purl.toString(), msg);
            return createSVGImageNode(ctx, e, doc);
        }

        RasterImageNode node = new RasterImageNode();
        node.setImage(img);
        Rectangle2D imgBounds = img.getBounds2D();

        // create the implicit viewBox for the raster image. The viewBox for a
        // raster image is the size of the image
        float [] vb = new float[4];
        vb[0] = 0; // x
        vb[1] = 0; // y
        vb[2] = (float)imgBounds.getWidth(); // width
        vb[3] = (float)imgBounds.getHeight(); // height

        // handles the 'preserveAspectRatio', 'overflow' and 'clip' and sets the
        // appropriate AffineTransform to the image node
        initializeViewport(ctx, e, node, vb, bounds);

        return node;
    }

    /**
     * Returns a GraphicsNode that represents a svg document as an image.
     *
     * @param ctx the bridge context
     * @param e the image element
     * @param imgDocument the SVG document that represents the image
     */
    protected GraphicsNode createSVGImageNode(BridgeContext ctx,
                                              Element e,
                                              SVGDocument imgDocument) {
        CSSEngine eng = ((SVGOMDocument)imgDocument).getCSSEngine();
        subCtx = ctx.createSubBridgeContext((SVGOMDocument)imgDocument);

        CompositeGraphicsNode result = new CompositeGraphicsNode();
        // handles the 'preserveAspectRatio', 'overflow' and 'clip' and
        // sets the appropriate AffineTransform to the image node
        Rectangle2D bounds = getImageBounds(ctx, e);

        if ((bounds.getWidth() == 0) || (bounds.getHeight() == 0)) {
            ShapeNode sn = new ShapeNode();
            sn.setShape(bounds);
            result.getChildren().add(sn);
            return result;
        }

        Rectangle2D r = CSSUtilities.convertEnableBackground(e);
        if (r != null) {
            result.setBackgroundEnable(r);
        }

        SVGSVGElement svgElement = imgDocument.getRootElement();
        CanvasGraphicsNode node;
        node = (CanvasGraphicsNode)subCtx.getGVTBuilder().build
            (subCtx, svgElement);

        if ((eng == null) && ctx.isInteractive()) {
            // If we "created" this document then add listerns.
            subCtx.addUIEventListeners(imgDocument);
        }

        // HACK: remove the clip set by the SVGSVGElement as the overflow
        // and clip properties must be ignored. The clip will be set later
        // using the overflow and clip of the <image> element.
        node.setClip(null);
        // HACK: remove the viewingTransform set by the SVGSVGElement
        // as the viewBox must be ignored. The viewingTransform will
        // be set later using the width/height of the image element.
        node.setViewingTransform(new AffineTransform());
        result.getChildren().add(node);

        // create the implicit viewBox for the SVG image. The viewBox for a
        // SVG image is the viewBox of the outermost SVG element of the SVG file
        // XXX Use animated value of 'viewBox' here?
        String viewBox =
            svgElement.getAttributeNS(null, SVG_VIEW_BOX_ATTRIBUTE);
        float[] vb = ViewBox.parseViewBoxAttribute(e, viewBox, ctx);

        initializeViewport(ctx, e, result, vb, bounds);

        // add a listener on the outermost svg element of the SVG image.
        // if an event occured inside the SVG image document, send it
        // to the <image> element (inside the original document).
        if (ctx.isInteractive()) {
            listener = new ForwardEventListener(svgElement, e);
            NodeEventTarget tgt = (NodeEventTarget)svgElement;

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_CLICK,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_CLICK,
                 listener, false);

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYDOWN,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYDOWN,
                 listener, false);

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYPRESS,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYPRESS,
                 listener, false);

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYUP,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYUP,
                 listener, false);

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEDOWN,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEDOWN,
                 listener, false);

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEMOVE,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEMOVE,
                 listener, false);

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOUT,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOUT,
                 listener, false);

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOVER,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOVER,
                 listener, false);

            tgt.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEUP,
                 listener, false, null);
            subCtx.storeEventListenerNS
                (tgt, XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEUP,
                 listener, false);
        }

        return result;
    }

    public void dispose() {
        if ((imgDocument != null) && (listener != null)) {
            NodeEventTarget tgt = (NodeEventTarget)imgDocument.getRootElement();

            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_CLICK,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYDOWN,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYPRESS,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_KEYUP,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEDOWN,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEMOVE,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOUT,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEOVER,
                 listener, false);
            tgt.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, SVG_EVENT_MOUSEUP,
                 listener, false);
            listener = null;
        }

        if (imgDocument != null) {
            SVGSVGElement svgElement = imgDocument.getRootElement();
            disposeTree(svgElement);
            imgDocument = null;
            subCtx = null;
        }
        super.dispose();

    }
    /**
     * A simple DOM listener to forward events from the SVG image document to
     * the original document.
     */
    protected static class ForwardEventListener implements EventListener {

        /**
         * The root element of the SVG image.
         */
        protected Element svgElement;

        /**
         * The image element.
         */
        protected Element imgElement;

        /**
         * Constructs a new <tt>ForwardEventListener</tt>
         */
        public ForwardEventListener(Element svgElement, Element imgElement) {
            this.svgElement = svgElement;
            this.imgElement = imgElement;
        }

        public void handleEvent(Event e) {
            DOMMouseEvent evt = (DOMMouseEvent) e;
            DOMMouseEvent newMouseEvent = (DOMMouseEvent)
                // DOM Level 2 6.5 cast from Document to DocumentEvent is ok
                ((DocumentEvent)imgElement.getOwnerDocument()).createEvent("MouseEvents");

            newMouseEvent.initMouseEventNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI,
                 evt.getType(),
                 evt.getBubbles(),
                 evt.getCancelable(),
                 evt.getView(),
                 evt.getDetail(),
                 evt.getScreenX(),
                 evt.getScreenY(),
                 evt.getClientX(),
                 evt.getClientY(),
                 evt.getButton(),
                 (EventTarget)imgElement,
                 evt.getModifiersString());
            ((EventTarget)imgElement).dispatchEvent(newMouseEvent);
        }
    }

    /**
     * Initializes according to the specified element, the specified graphics
     * node with the specified bounds. This method takes into account the
     * 'viewBox', 'preserveAspectRatio', and 'clip' properties. According to
     * those properties, a AffineTransform and a clip is set.
     *
     * @param ctx the bridge context
     * @param e the image element that defines the properties
     * @param node the graphics node
     * @param vb the implicit viewBox definition
     * @param bounds the bounds of the image element
     */
    protected static void initializeViewport(BridgeContext ctx,
                                             Element e,
                                             GraphicsNode node,
                                             float[] vb,
                                             Rectangle2D bounds) {

        float x = (float)bounds.getX();
        float y = (float)bounds.getY();
        float w = (float)bounds.getWidth();
        float h = (float)bounds.getHeight();

        try {
            SVGImageElement ie = (SVGImageElement) e;
            SVGOMAnimatedPreserveAspectRatio _par =
                (SVGOMAnimatedPreserveAspectRatio) ie.getPreserveAspectRatio();
            _par.check();

            AffineTransform at = ViewBox.getPreserveAspectRatioTransform
                (e, vb, w, h, _par, ctx);
            at.preConcatenate(AffineTransform.getTranslateInstance(x, y));
            node.setTransform(at);

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
                    at = at.createInverse(); // clip in user space
                    Filter filter = node.getGraphicsNodeRable(true);
                    clip = at.createTransformedShape(clip);
                    node.setClip(new ClipRable8Bit(filter, clip));
                } catch (java.awt.geom.NoninvertibleTransformException ex) {}
            }
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        }
    }

    /**
     * Analyzes the color-profile property and builds an ICCColorSpaceExt
     * object from it.
     *
     * @param element the element with the color-profile property
     * @param ctx the bridge context
     */
    protected static ICCColorSpaceExt extractColorSpace(Element element,
                                                        BridgeContext ctx) {

        String colorProfileProperty = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.COLOR_PROFILE_INDEX).getStringValue();

        // The only cases that need special handling are 'sRGB' and 'name'
        ICCColorSpaceExt colorSpace = null;
        if (CSS_SRGB_VALUE.equalsIgnoreCase(colorProfileProperty)) {

            colorSpace = new ICCColorSpaceExt
                (ICC_Profile.getInstance(ColorSpace.CS_sRGB),
                 ICCColorSpaceExt.AUTO);

        } else if (!CSS_AUTO_VALUE.equalsIgnoreCase(colorProfileProperty)
                   && !"".equalsIgnoreCase(colorProfileProperty)){

            // The value is neither 'sRGB' nor 'auto': it is a profile name.
            SVGColorProfileElementBridge profileBridge =
                (SVGColorProfileElementBridge) ctx.getBridge
                (SVG_NAMESPACE_URI, SVG_COLOR_PROFILE_TAG);
            if (profileBridge != null) {
                colorSpace = profileBridge.createICCColorSpaceExt
                    (ctx, element, colorProfileProperty);

            }
        }
        return colorSpace;
    }

    /**
     * Returns the bounds of the specified image element.
     *
     * @param ctx the bridge context
     * @param element the image element
     */
    protected static Rectangle2D getImageBounds(BridgeContext ctx,
                                                Element element) {
        try {
            SVGImageElement ie = (SVGImageElement) element;

            // 'x' attribute - default is 0
            AbstractSVGAnimatedLength _x =
                (AbstractSVGAnimatedLength) ie.getX();
            float x = _x.getCheckedValue();

            // 'y' attribute - default is 0
            AbstractSVGAnimatedLength _y =
                (AbstractSVGAnimatedLength) ie.getY();
            float y = _y.getCheckedValue();

            // 'width' attribute - required
            AbstractSVGAnimatedLength _width =
                (AbstractSVGAnimatedLength) ie.getWidth();
            float w = _width.getCheckedValue();

            // 'height' attribute - required
            AbstractSVGAnimatedLength _height =
                (AbstractSVGAnimatedLength) ie.getHeight();
            float h = _height.getCheckedValue();

            return new Rectangle2D.Float(x, y, w, h);
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        }
    }

    GraphicsNode createBrokenImageNode
        (BridgeContext ctx, Element e, String uri, String message) {
        SVGDocument doc = ctx.getUserAgent().getBrokenLinkDocument
            (e, uri, Messages.formatMessage(URI_IMAGE_ERROR,
                                           new Object[] { message } ));
        return createSVGImageNode(ctx, e, doc);
    }


    static SVGBrokenLinkProvider brokenLinkProvider
        = new SVGBrokenLinkProvider();
    static {
        ImageTagRegistry.setBrokenLinkProvider(brokenLinkProvider);
    }
}
