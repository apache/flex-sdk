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
import java.util.Map;

import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.AffineRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageTagRegistry;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;feImage> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFeImageElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class SVGFeImageElementBridge
    extends AbstractSVGFilterPrimitiveElementBridge {

    /**
     * Constructs a new bridge for the &lt;feImage> element.
     */
    public SVGFeImageElementBridge() {}

    /**
     * Returns 'feImage'.
     */
    public String getLocalName() {
        return SVG_FE_IMAGE_TAG;
    }

    /**
     * Creates a <tt>Filter</tt> primitive according to the specified
     * parameters.
     *
     * @param ctx the bridge context to use
     * @param filterElement the element that defines a filter
     * @param filteredElement the element that references the filter
     * @param filteredNode the graphics node to filter
     *
     * @param inputFilter the <tt>Filter</tt> that represents the current
     *        filter input if the filter chain.
     * @param filterRegion the filter area defined for the filter chain
     *        the new node will be part of.
     * @param filterMap a map where the mediator can map a name to the
     *        <tt>Filter</tt> it creates. Other <tt>FilterBridge</tt>s
     *        can then access a filter node from the filterMap if they
     *        know its name.
     */
    public Filter createFilter(BridgeContext ctx,
                               Element filterElement,
                               Element filteredElement,
                               GraphicsNode filteredNode,
                               Filter inputFilter,
                               Rectangle2D filterRegion,
                               Map filterMap) {

        // 'xlink:href' attribute
        String uriStr = XLinkSupport.getXLinkHref(filterElement);
        if (uriStr.length() == 0) {
            throw new BridgeException(ctx, filterElement, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {"xlink:href"});
        }

        //
        // According the the SVG specification, feImage behaves like
        // <image> if it references an SVG document or a raster image
        // and it behaves like a <use> if it references a document
        // fragment.
        //
        // To provide this behavior, depending on whether the uri
        // contains a fragment identifier, we create either an
        // <image> or a <use> element and request the corresponding
        // bridges to build the corresponding GraphicsNode for us.
        //
        // Then, we take care of the possible transformation needed
        // from objectBoundingBox space to user space.
        //

        Document document = filterElement.getOwnerDocument();
        boolean isUse = uriStr.indexOf('#') != -1;
        Element contentElement = null;
        if (isUse) {
            contentElement = document.createElementNS(SVG_NAMESPACE_URI,
                                                      SVG_USE_TAG);
        } else {
            contentElement = document.createElementNS(SVG_NAMESPACE_URI,
                                                      SVG_IMAGE_TAG);
        }


        contentElement.setAttributeNS(XLINK_NAMESPACE_URI,
                                      XLINK_HREF_QNAME,
                                      uriStr);

        Element proxyElement = document.createElementNS(SVG_NAMESPACE_URI,
                                                        SVG_G_TAG);
        proxyElement.appendChild(contentElement);

        // feImage's default region is that of the filter chain.
        Rectangle2D defaultRegion = filterRegion;
        Element filterDefElement = (Element)(filterElement.getParentNode());

        Rectangle2D primitiveRegion =
            SVGUtilities.getBaseFilterPrimitiveRegion(filterElement,
                                                      filteredElement,
                                                      filteredNode,
                                                      defaultRegion,
                                                      ctx);

        // System.err.println(">>>>>>>> primitiveRegion : " + primitiveRegion);

        contentElement.setAttributeNS(null, SVG_X_ATTRIBUTE,      String.valueOf( primitiveRegion.getX() ) );
        contentElement.setAttributeNS(null, SVG_Y_ATTRIBUTE,      String.valueOf( primitiveRegion.getY() ) );
        contentElement.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE,  String.valueOf( primitiveRegion.getWidth() ) );
        contentElement.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE, String.valueOf( primitiveRegion.getHeight() ) );


        GraphicsNode node = ctx.getGVTBuilder().build(ctx, proxyElement);
        Filter filter = node.getGraphicsNodeRable(true);

        // 'primitiveUnits' attribute - default is userSpaceOnUse
        short coordSystemType;
        String s = SVGUtilities.getChainableAttributeNS
            (filterDefElement, null, SVG_PRIMITIVE_UNITS_ATTRIBUTE, ctx);
        if (s.length() == 0) {
            coordSystemType = SVGUtilities.USER_SPACE_ON_USE;
        } else {
            coordSystemType = SVGUtilities.parseCoordinateSystem
                (filterDefElement, SVG_PRIMITIVE_UNITS_ATTRIBUTE, s, ctx);
        }

        // Compute the transform from object bounding box to user
        // space if needed.
        AffineTransform at = new AffineTransform();
        if (coordSystemType == SVGUtilities.OBJECT_BOUNDING_BOX) {
            at = SVGUtilities.toObjectBBox(at, filteredNode);
        }
        filter = new AffineRable8Bit(filter, at);

        // handle the 'color-interpolation-filters' property
        handleColorInterpolationFilters(filter, filterElement);

        // get filter primitive chain region
        Rectangle2D primitiveRegionUserSpace
            = SVGUtilities.convertFilterPrimitiveRegion(filterElement,
                                                        filteredElement,
                                                        filteredNode,
                                                        defaultRegion,
                                                        filterRegion,
                                                        ctx);
        filter = new PadRable8Bit(filter, primitiveRegionUserSpace,
                                  PadMode.ZERO_PAD);

        // update the filter Map
        updateFilterMap(filterElement, filter, filterMap);

        return filter;
    }

    /**
     * Returns a Filter that represents a svg document or element as an image.
     *
     * @param ctx the bridge context
     * @param primitiveRegion the primitive region
     * @param refElement the referenced element
     * @param toBBoxNeeded true if there is a need to transform to ObjectBoundingBox
     *        space
     * @param filterElement parent filter element
     * @param filteredNode node to which the filter applies
     */
    protected static Filter createSVGFeImage(BridgeContext ctx,
                                             Rectangle2D primitiveRegion,
                                             Element refElement,
                                             boolean toBBoxNeeded,
                                             Element filterElement,
                                             GraphicsNode filteredNode) {

        //
        // <!> FIX ME
        // Unresolved issue on the feImage behavior when referencing an
        // image (PNG, JPEG or SVG image).
        // VH & TK, 03/08/2002
        // Furthermore, for feImage referencing doc fragment, should act
        // like a <use>, i.e., CSS cascading and the whole zing bang.
        //
        GraphicsNode node = ctx.getGVTBuilder().build(ctx, refElement);
        Filter filter = node.getGraphicsNodeRable(true);

        AffineTransform at = new AffineTransform();

        if (toBBoxNeeded){
            // 'primitiveUnits' attribute - default is userSpaceOnUse
            short coordSystemType;
            Element filterDefElement = (Element)(filterElement.getParentNode());
            String s = SVGUtilities.getChainableAttributeNS
                (filterDefElement, null, SVG_PRIMITIVE_UNITS_ATTRIBUTE, ctx);
            if (s.length() == 0) {
                coordSystemType = SVGUtilities.USER_SPACE_ON_USE;
            } else {
                coordSystemType = SVGUtilities.parseCoordinateSystem
                    (filterDefElement, SVG_PRIMITIVE_UNITS_ATTRIBUTE, s, ctx);
            }

            if (coordSystemType == SVGUtilities.OBJECT_BOUNDING_BOX) {
                at = SVGUtilities.toObjectBBox(at, filteredNode);
            }

            Rectangle2D bounds = filteredNode.getGeometryBounds();
            at.preConcatenate(AffineTransform.getTranslateInstance
                              (primitiveRegion.getX() - bounds.getX(),
                               primitiveRegion.getY() - bounds.getY()));

        } else {

            // Need to translate the image to the x, y coordinate to
            // have the same behavior as the <use> element
            at.translate(primitiveRegion.getX(), primitiveRegion.getY());
        }

        return new AffineRable8Bit(filter, at);
    }

    /**
     * Returns a Filter that represents an raster image (JPG or PNG).
     *
     * @param ctx the bridge context
     * @param primitiveRegion the primitive region
     * @param purl the url of the image
     */
    protected static Filter createRasterFeImage(BridgeContext ctx,
                                                Rectangle2D   primitiveRegion,
                                                ParsedURL     purl) {

        // Need to fit the raster image to the filter region so that
        // we have the same behavior as raster images in the <image> element.
        Filter filter = ImageTagRegistry.getRegistry().readURL(purl);

        Rectangle2D bounds = filter.getBounds2D();
        AffineTransform scale = new AffineTransform();
        scale.translate(primitiveRegion.getX(), primitiveRegion.getY());
        scale.scale(primitiveRegion.getWidth()/(bounds.getWidth()-1),
                    primitiveRegion.getHeight()/(bounds.getHeight()-1));
        scale.translate(-bounds.getX(), -bounds.getY());

        return new AffineRable8Bit(filter, scale);
    }
}
