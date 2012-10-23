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
package org.apache.flex.forks.batik.bridge.svg12;

import java.awt.Dimension;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;

import org.apache.flex.forks.batik.bridge.Bridge;
import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.BridgeException;
import org.apache.flex.forks.batik.bridge.CSSUtilities;
import org.apache.flex.forks.batik.bridge.SVGImageElementBridge;
import org.apache.flex.forks.batik.bridge.SVGUtilities;
import org.apache.flex.forks.batik.bridge.UnitProcessor;
import org.apache.flex.forks.batik.bridge.Viewport;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.ImageNode;
import org.apache.flex.forks.batik.gvt.svg12.MultiResGraphicsNode;

import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVG12Constants;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

/**
 * Bridge class for the &lt;multiImage> element.
 *
 * The 'multiImage' element is similar to the 'image' element (supports
 * all the same attributes and properties) except.
 * <ol>
 *    <li>It can only be used to reference raster content (this is an
 *        implementation thing really)</li>
 *    <li>It has two addtional attributes: 'pixel-width' and
 *        'pixel-height' which are the maximum width and height of the
 *        image referenced by the xlink:href attribute.</li>
 *    <li>It can contain a child element 'subImage' which has only
 *        three attributes, pixel-width, pixel-height and xlink:href.
 *        The image displayed is the smallest image such that
 *        pixel-width and pixel-height are greater than or equal to the
 *        required image size for display.</li>
 * </ol>
 *
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: SVGMultiImageElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGMultiImageElementBridge extends SVGImageElementBridge {

    public SVGMultiImageElementBridge() { }

    /**
     * Returns the Batik Extension namespace URI.
     */
    public String getNamespaceURI() {
        return SVG12Constants.SVG_NAMESPACE_URI;
    }

    /**
     * Returns 'multiImage'.
     */
    public String getLocalName() {
        return SVG12Constants.SVG_MULTI_IMAGE_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGMultiImageElementBridge();
    }

     /**
      * Creates a graphics node using the specified BridgeContext and for the
      * specified element.
      *  
      * @param  ctx the bridge context to use
      * @param  e   the element that describes the graphics node to build
      * @return a graphics node that represents the specified element
      */
    public GraphicsNode createGraphicsNode(BridgeContext ctx, Element e) {
        // 'requiredFeatures', 'requiredExtensions' and 'systemLanguage'
        if (!SVGUtilities.matchUserAgent(e, ctx.getUserAgent())) {
            return null;
        }

        ImageNode imgNode = (ImageNode)instantiateGraphicsNode();
        if (imgNode == null) {
            return null;
        }

        associateSVGContext(ctx, e, imgNode);

        Rectangle2D b = getImageBounds(ctx, e);

        // 'transform'
        AffineTransform at = null;
        String s = e.getAttribute(SVG_TRANSFORM_ATTRIBUTE);
        if (s.length() != 0) {
            at = SVGUtilities.convertTransform(e, SVG_TRANSFORM_ATTRIBUTE, s,
                                               ctx);
        } else {
            at = new AffineTransform();
        }

        at.translate(b.getX(), b.getY());
        imgNode.setTransform(at);
        
        // 'visibility'
        imgNode.setVisible(CSSUtilities.convertVisibility(e));

        Rectangle2D clip;
        clip = new Rectangle2D.Double(0,0,b.getWidth(), b.getHeight());
        Filter filter = imgNode.getGraphicsNodeRable(true);
        imgNode.setClip(new ClipRable8Bit(filter, clip));

        // 'enable-background'
        Rectangle2D r = CSSUtilities.convertEnableBackground(e);
        if (r != null) {
            imgNode.setBackgroundEnable(r);
        }
        ctx.openViewport(e, new MultiImageElementViewport
                         ((float)b.getWidth(), (float)b.getHeight()));


        List elems  = new LinkedList();
        List minDim = new LinkedList();
        List maxDim = new LinkedList();

        for (Node n = e.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (n.getNodeType() != Node.ELEMENT_NODE)
                continue;
            
            Element se = (Element)n;
            if (!getNamespaceURI().equals(se.getNamespaceURI()))
                continue;
            if (se.getLocalName().equals(SVG12Constants.SVG_SUB_IMAGE_TAG)) {
                addInfo(se, elems, minDim, maxDim, b);
            }
            if (se.getLocalName().equals(SVG12Constants.SVG_SUB_IMAGE_REF_TAG)) {
                addRefInfo(se, elems, minDim, maxDim, b);
            }
        }

        Dimension [] mindary = new Dimension[elems.size()];
        Dimension [] maxdary = new Dimension[elems.size()];
        Element   [] elemary = new Element  [elems.size()];
        Iterator mindi = minDim.iterator();
        Iterator maxdi = maxDim.iterator();
        Iterator ei = elems.iterator();
        int n=0;
        while (mindi.hasNext()) {
            Dimension minD = (Dimension)mindi.next();
            Dimension maxD = (Dimension)maxdi.next();
            int i =0;
            if (minD != null) {
                for (; i<n; i++) {
                    if ((mindary[i] != null) &&
                        (minD.width < mindary[i].width)) {
                        break;
                    }
                }
            }
            for (int j=n; j>i; j--) {
                elemary[j] = elemary[j-1];
                mindary[j] = mindary[j-1];
                maxdary[j] = maxdary[j-1];
            }
            
            elemary[i] = (Element)ei.next();
            mindary[i] = minD;
            maxdary[i] = maxD;
            n++;
        }

        GraphicsNode node = new MultiResGraphicsNode(e, clip, elemary, 
                                                     mindary, maxdary,
                                                     ctx);
        imgNode.setImage(node);

        return imgNode;
    }

    /**
     * Returns false as shapes are not a container.
     */
    public boolean isComposite() {
        return false;
    }

    public void buildGraphicsNode(BridgeContext ctx,
                                  Element e,
                                  GraphicsNode node) {
        initializeDynamicSupport(ctx, e, node);

        // Handle children elements such as <title>
        //SVGUtilities.bridgeChildren(ctx, e);
        //super.buildGraphicsNode(ctx, e, node);
        ctx.closeViewport(e);
    }

    /**
     * This method is invoked during the build phase if the document
     * is dynamic. The responsability of this method is to ensure that
     * any dynamic modifications of the element this bridge is
     * dedicated to, happen on its associated GVT product.
     */
    protected void initializeDynamicSupport(BridgeContext ctx,
                                            Element e,
                                            GraphicsNode node) {
        if (ctx.isInteractive()) {
            // HACK due to the way images are represented in GVT
            ImageNode imgNode = (ImageNode)node;
            ctx.bind(e, imgNode.getImage());
        }
    }

    /**
     * Disposes this BridgeUpdateHandler and releases all resources.
     */
    public void dispose() {
        ctx.removeViewport(e);
        super.dispose();
    }

    /**
     * Returns the bounds of the specified image element.
     *
     * @param ctx the bridge context
     * @param element the image element
     */
    protected static
        Rectangle2D getImageBounds(BridgeContext ctx, Element element) {

        UnitProcessor.Context uctx = UnitProcessor.createContext(ctx, element);

        // 'x' attribute - default is 0
        String s = element.getAttributeNS(null, SVG_X_ATTRIBUTE);
        float x = 0;
        if (s.length() != 0) {
            x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_X_ATTRIBUTE, uctx);
        }

        // 'y' attribute - default is 0
        s = element.getAttributeNS(null, SVG_Y_ATTRIBUTE);
        float y = 0;
        if (s.length() != 0) {
            y = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_Y_ATTRIBUTE, uctx);
        }

        // 'width' attribute - required
        s = element.getAttributeNS(null, SVG_WIDTH_ATTRIBUTE);
        float w;
        if (s.length() == 0) {
            throw new BridgeException(ctx, element, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {SVG_WIDTH_ATTRIBUTE});
        } else {
            w = UnitProcessor.svgHorizontalLengthToUserSpace
                (s, SVG_WIDTH_ATTRIBUTE, uctx);
        }

        // 'height' attribute - required
        s = element.getAttributeNS(null, SVG_HEIGHT_ATTRIBUTE);
        float h;
        if (s.length() == 0) {
            throw new BridgeException(ctx, element, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {SVG_HEIGHT_ATTRIBUTE});
        } else {
            h = UnitProcessor.svgVerticalLengthToUserSpace
                (s, SVG_HEIGHT_ATTRIBUTE, uctx);
        }

        return new Rectangle2D.Float(x, y, w, h);
    }

    protected void addInfo(Element e, Collection elems, 
                           Collection minDim, Collection maxDim,
                           Rectangle2D bounds) {
        Document doc   = e.getOwnerDocument();
        Element  gElem = doc.createElementNS(SVG_NAMESPACE_URI, 
                                              SVG_G_TAG);
        NamedNodeMap attrs = e.getAttributes();
        int len = attrs.getLength();
        for (int i = 0; i < len; i++) {
            Attr attr = (Attr)attrs.item(i);
            gElem.setAttributeNS(attr.getNamespaceURI(),
                                 attr.getName(),
                                 attr.getValue());
        }
        // move the children from <subImage> to the <g> element
        for (Node n = e.getFirstChild();
             n != null;
             n = e.getFirstChild()) {
            gElem.appendChild(n);
        }
        e.appendChild(gElem);
        elems.add(gElem);
        minDim.add(getElementMinPixel(e, bounds));
        maxDim.add(getElementMaxPixel(e, bounds));
    }

    protected void addRefInfo(Element e, Collection elems, 
                              Collection minDim, Collection maxDim,
                              Rectangle2D bounds) {
        String uriStr = XLinkSupport.getXLinkHref(e);
        if (uriStr.length() == 0) {
            throw new BridgeException(ctx, e, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {"xlink:href"});
        }
        String baseURI = AbstractNode.getBaseURI(e);
        ParsedURL purl;
        if (baseURI == null) purl = new ParsedURL(uriStr);
        else                 purl = new ParsedURL(baseURI, uriStr);
        Document doc = e.getOwnerDocument();
        Element imgElem = doc.createElementNS(SVG_NAMESPACE_URI, 
                                              SVG_IMAGE_TAG);
        imgElem.setAttributeNS(XLINK_NAMESPACE_URI, 
                               XLINK_HREF_ATTRIBUTE, purl.toString());
        // move the attributes from <subImageRef> to the <image> element
        NamedNodeMap attrs = e.getAttributes();
        int len = attrs.getLength();
        for (int i = 0; i < len; i++) {
            Attr attr = (Attr)attrs.item(i);
            imgElem.setAttributeNS(attr.getNamespaceURI(),
                                   attr.getName(),
                                   attr.getValue());
        }
        String s;
        s = e.getAttribute("x");
        if (s.length() == 0) imgElem.setAttribute("x", "0");
        s = e.getAttribute("y");
        if (s.length() == 0) imgElem.setAttribute("y", "0");
        s = e.getAttribute("width");
        if (s.length() == 0) imgElem.setAttribute("width", "100%");
        s = e.getAttribute("height");
        if (s.length() == 0) imgElem.setAttribute("height", "100%");
        e.appendChild(imgElem);
        elems.add(imgElem);

        minDim.add(getElementMinPixel(e, bounds));
        maxDim.add(getElementMaxPixel(e, bounds));
    }

    protected Dimension getElementMinPixel(Element e, Rectangle2D bounds) {
        return getElementPixelSize
            (e, SVG12Constants.SVG_MAX_PIXEL_SIZE_ATTRIBUTE, bounds);
    }
    protected Dimension getElementMaxPixel(Element e, Rectangle2D bounds) {
        return getElementPixelSize
            (e, SVG12Constants.SVG_MIN_PIXEL_SIZE_ATTRIBUTE, bounds);
    }

    protected Dimension getElementPixelSize(Element e, 
                                            String attr,
                                            Rectangle2D bounds) {
        String s;
        s = e.getAttribute(attr);
        if (s.length() == 0) return null;

        Float[] vals = SVGUtilities.convertSVGNumberOptionalNumber
            (e, attr, s, ctx);

        if (vals[0] == null) return null;

        float xPixSz = vals[0].floatValue();
        float yPixSz = xPixSz;
        if (vals[1] != null)
            yPixSz = vals[1].floatValue();
        
        return new Dimension((int)(bounds.getWidth()/xPixSz+0.5), 
                             (int)(bounds.getHeight()/yPixSz+0.5)); 
    }

    /**
     * A viewport defined an &lt;svg> element.
     */
    public static class MultiImageElementViewport implements Viewport {
        private float width;
        private float height;

        /**
         * Constructs a new viewport with the specified <tt>SVGSVGElement</tt>.
         * @param w the width of the viewport
         * @param h the height of the viewport
         */
        public MultiImageElementViewport(float w, float h) {
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
}
