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

import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.ext.awt.image.ConcreteComponentTransferFunction;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ComponentTransferRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.AbstractGraphicsNode;
import org.apache.flex.forks.batik.gvt.RootGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.PatternPaint;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * Bridge class for the &lt;pattern> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGPatternElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGPatternElementBridge extends AnimatableGenericSVGBridge
        implements PaintBridge, ErrorConstants {

    /**
     * Constructs a new SVGPatternElementBridge.
     */
    public SVGPatternElementBridge() {}

    /**
     * Returns 'pattern'.
     */
    public String getLocalName() {
        return SVG_PATTERN_TAG;
    }

    /**
     * Creates a <tt>Paint</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param patternElement the pattern element that defines a Paint
     * @param paintedElement the element referencing the paint
     * @param paintedNode the graphics node on which the Paint will be applied
     * @param opacity the opacity of the Paint to create
     */
    public Paint createPaint(BridgeContext ctx,
                             Element patternElement,
                             Element paintedElement,
                             GraphicsNode paintedNode,
                             float opacity) {


        // extract pattern content
        RootGraphicsNode patternContentNode;
        patternContentNode = (RootGraphicsNode)
            ctx.getElementData(patternElement);

        if (patternContentNode == null) {
            patternContentNode = extractPatternContent(patternElement, ctx);
            ctx.setElementData(patternElement, patternContentNode);
        }
        if (patternContentNode == null) {
            return null; // no content means no paint
        }

        // get pattern region using 'patternUnits'. Pattern region is
        // in tile pace.
        Rectangle2D patternRegion = SVGUtilities.convertPatternRegion
            (patternElement, paintedElement, paintedNode, ctx);

        String s;

        // 'patternTransform' attribute - default is an Identity matrix
        AffineTransform patternTransform;
        s = SVGUtilities.getChainableAttributeNS
            (patternElement, null, SVG_PATTERN_TRANSFORM_ATTRIBUTE, ctx);
        if (s.length() != 0) {
            patternTransform = SVGUtilities.convertTransform
                (patternElement, SVG_PATTERN_TRANSFORM_ATTRIBUTE, s, ctx);
        } else {
            patternTransform = new AffineTransform();
        }

        // 'overflow' on the pattern element
        boolean overflowIsHidden = CSSUtilities.convertOverflow(patternElement);

        // 'patternContentUnits' - default is userSpaceOnUse
        short contentCoordSystem;
        s = SVGUtilities.getChainableAttributeNS
            (patternElement, null, SVG_PATTERN_CONTENT_UNITS_ATTRIBUTE, ctx);
        if (s.length() == 0) {
            contentCoordSystem = SVGUtilities.USER_SPACE_ON_USE;
        } else {
            contentCoordSystem = SVGUtilities.parseCoordinateSystem
                (patternElement, SVG_PATTERN_CONTENT_UNITS_ATTRIBUTE, s, ctx);
        }

        // Compute a transform according to viewBox,  preserveAspectRatio
        // and patternContentUnits and the pattern transform attribute.
        //
        // The stack of transforms is:
        //
        // +-------------------------------+
        // | viewPortTranslation           |
        // +-------------------------------+
        // | preserveAspectRatioTransform  |
        // +-------------------------------+
        // + patternContentUnitsTransform  |
        // +-------------------------------+
        //
        // where:
        //   - viewPortTranslation is the transform that translate to
        //     the viewPort's origin.
        //   - preserveAspectRatioTransform is the transformed implied by the
        //     preserveAspectRatio attribute.
        //   - patternContentUnitsTransform is the transform implied by the
        //     patternContentUnits attribute.
        //
        // Note that there is an additional transform from the tiling
        // space to the user space (patternTransform) that is passed
        // separately to the PatternPaintContext.
        //
        AffineTransform patternContentTransform = new AffineTransform();

        //
        // Process viewPortTranslation
        //
        patternContentTransform.translate(patternRegion.getX(),
                                          patternRegion.getY());

        //
        // Process preserveAspectRatioTransform
        //

        // 'viewBox' attribute
        String viewBoxStr = SVGUtilities.getChainableAttributeNS
            (patternElement, null, SVG_VIEW_BOX_ATTRIBUTE, ctx);

        if (viewBoxStr.length() > 0) {
            // There is a viewBox attribute. Then, take
            // preserveAspectRatio into account.
            String aspectRatioStr = SVGUtilities.getChainableAttributeNS
               (patternElement, null, SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE, ctx);
            float w = (float)patternRegion.getWidth();
            float h = (float)patternRegion.getHeight();
            AffineTransform preserveAspectRatioTransform
                = ViewBox.getPreserveAspectRatioTransform
                (patternElement, viewBoxStr, aspectRatioStr, w, h, ctx);

            patternContentTransform.concatenate(preserveAspectRatioTransform);
        } else {
            //
            // Process patternContentUnitsTransform
            //
            if (contentCoordSystem == SVGUtilities.OBJECT_BOUNDING_BOX){
                AffineTransform patternContentUnitsTransform
                    = new AffineTransform();
                Rectangle2D objectBoundingBox = 
                    paintedNode.getGeometryBounds();
                patternContentUnitsTransform.translate
                    (objectBoundingBox.getX(),
                     objectBoundingBox.getY());

                patternContentUnitsTransform.scale
                    (objectBoundingBox.getWidth(),
                     objectBoundingBox.getHeight());

                patternContentTransform.concatenate
                    (patternContentUnitsTransform);
            }
        }

        //
        // Apply transform
        //
        // RootGraphicsNode gn = new RootGraphicsNode();
        // gn.getChildren().add(patternContentNode);
        GraphicsNode gn = new PatternGraphicsNode(patternContentNode);
        
        gn.setTransform(patternContentTransform);
        
        // take the opacity into account. opacity is implemented by a Filter
        if (opacity != 1) {
            Filter filter = gn.getGraphicsNodeRable(true);
            filter = new ComponentTransferRable8Bit
                (filter,
                 ConcreteComponentTransferFunction.getLinearTransfer
                 (opacity, 0), //alpha
                 ConcreteComponentTransferFunction.getIdentityTransfer(), //Red
                 ConcreteComponentTransferFunction.getIdentityTransfer(), //Grn
                 ConcreteComponentTransferFunction.getIdentityTransfer());//Blu
            gn.setFilter(filter);
        }

        

        return new PatternPaint(gn,
                                patternRegion,
                                !overflowIsHidden,
                                patternTransform);

    }

    /**
     * Returns the content of the specified pattern element. The
     * content of the pattern can be specified as children of the
     * patternElement or children of one of its 'ancestor' (linked with
     * the xlink:href attribute).
     *
     * @param patternElement the gradient element
     * @param ctx the bridge context to use
     */
    protected static
        RootGraphicsNode extractPatternContent(Element patternElement,
                                               BridgeContext ctx) {

        List refs = new LinkedList();
        for (;;) {
            RootGraphicsNode content
                = extractLocalPatternContent(patternElement, ctx);
            if (content != null) {
                return content; // pattern content found, exit
            }
            String uri = XLinkSupport.getXLinkHref(patternElement);
            if (uri.length() == 0) {
                return null; // no xlink:href found, exit
            }
            // check if there is circular dependencies
            SVGOMDocument doc =
                (SVGOMDocument)patternElement.getOwnerDocument();
            ParsedURL purl = new ParsedURL(doc.getURL(), uri);
            if (!purl.complete())
                throw new BridgeException(ctx, patternElement,
                                          ERR_URI_MALFORMED,
                                          new Object[] {uri});

            if (contains(refs, purl)) {
                throw new BridgeException(ctx, patternElement,
                                          ERR_XLINK_HREF_CIRCULAR_DEPENDENCIES,
                                          new Object[] {uri});
            }
            refs.add(purl);
            patternElement = ctx.getReferencedElement(patternElement, uri);
        }
    }

    /**
     * Returns the content of the specified pattern element or null if any.
     *
     * @param e the pattern element
     * @param ctx the bridge context
     */
    protected static
        RootGraphicsNode extractLocalPatternContent(Element e,
                                                         BridgeContext ctx) {

        GVTBuilder builder = ctx.getGVTBuilder();
        RootGraphicsNode content = null;
        for (Node n = e.getFirstChild(); n != null; n = n.getNextSibling()) {
            // check if the Node is valid
            if (n.getNodeType() != Node.ELEMENT_NODE) {
                continue;
            }

            GraphicsNode gn = builder.build(ctx, (Element)n);
            // check if a GraphicsNode has been created
            if (gn != null) {
                // lazy instantation of the grouping element.
                if (content == null) {
                    content = new RootGraphicsNode();
                }
                content.getChildren().add(gn);
            }
        }
        return content;
    }

    /**
     * Returns true if the specified list of ParsedURLs contains the
     * specified url.
     *
     * @param urls the list of ParsedURLs
     * @param key the url to search for */
    private static boolean contains(List urls, ParsedURL key) {
        Iterator iter = urls.iterator();
        while (iter.hasNext()) {
            if (key.equals(iter.next()))
                return true;
        }
        return false;
    }

    public static class PatternGraphicsNode extends AbstractGraphicsNode {
        GraphicsNode pcn;
        Rectangle2D pBounds;
        Rectangle2D gBounds;
        Rectangle2D sBounds;
        Shape       oShape;
        public PatternGraphicsNode(GraphicsNode gn) {
            this.pcn = gn;
        }
        public void primitivePaint(Graphics2D g2d) {
            pcn.paint(g2d);
        }
        public Rectangle2D getPrimitiveBounds() {
            if (pBounds != null) return pBounds;
            pBounds = pcn.getTransformedBounds(IDENTITY);
            return pBounds;
        }
        public Rectangle2D getGeometryBounds() {
            if (gBounds != null) return gBounds;
            gBounds = pcn.getTransformedGeometryBounds(IDENTITY);
            return gBounds;
        }
        public Rectangle2D getSensitiveBounds() {
            if (sBounds != null) return sBounds;
            sBounds = pcn.getTransformedSensitiveBounds(IDENTITY);
            return sBounds;
        }
        public Shape getOutline() {
            if (oShape != null) return oShape;
            oShape = pcn.getOutline();
            AffineTransform tr = pcn.getTransform();
            if (tr != null)
                oShape = tr.createTransformedShape(oShape);
            return oShape;
        }
        protected void invalidateGeometryCache() {
            pBounds = null;
            gBounds = null;
            sBounds = null;
            oShape  = null;
            super.invalidateGeometryCache();
        }

    }
}
