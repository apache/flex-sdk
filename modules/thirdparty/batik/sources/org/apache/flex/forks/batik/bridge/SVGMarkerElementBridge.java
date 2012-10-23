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
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.Marker;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * Bridge class for the &lt;marker> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGMarkerElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class SVGMarkerElementBridge extends AnimatableGenericSVGBridge
        implements MarkerBridge, ErrorConstants {

    /**
     * Constructs a new bridge for the &lt;marker> element.
     */
    protected SVGMarkerElementBridge() {}

    /**
     * Returns 'marker'.
     */
    public String getLocalName() {
        return SVG_MARKER_TAG;
    }

    /**
     * Creates a <tt>Marker</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param markerElement the element that represents the marker
     * @param paintedElement the element that references the marker element
     */
    public Marker createMarker(BridgeContext ctx,
                               Element markerElement,
                               Element paintedElement) {

        GVTBuilder builder = ctx.getGVTBuilder();

        CompositeGraphicsNode markerContentNode
            = new CompositeGraphicsNode();

        // build the GVT tree that represents the marker
        boolean hasChildren = false;
        for(Node n = markerElement.getFirstChild();
            n != null;
            n = n.getNextSibling()) {

            // check if the node is a valid Element
            if (n.getNodeType() != Node.ELEMENT_NODE) {
                continue;
            }
            Element child = (Element)n;
            GraphicsNode markerNode = builder.build(ctx, child) ;
            // check if a GVT node has been created
            if (markerNode == null) {
                continue; // skip element as <marker> can contain <defs>...
            }
            hasChildren = true;
            markerContentNode.getChildren().add(markerNode);
        }
        if (!hasChildren) {
            return null; // no marker content defined
        }

        String s;
        UnitProcessor.Context uctx
            = UnitProcessor.createContext(ctx, paintedElement);

        // 'markerWidth' attribute - default is 3
        float markerWidth = 3;
        s = markerElement.getAttributeNS(null, SVG_MARKER_WIDTH_ATTRIBUTE);
        if (s.length() != 0) {
            markerWidth = UnitProcessor.svgHorizontalLengthToUserSpace
                (s, SVG_MARKER_WIDTH_ATTRIBUTE, uctx);
        }
        if (markerWidth == 0) {
            // A value of zero disables rendering of the element.
            return null;
        }

        // 'markerHeight' attribute - default is 3
        float markerHeight = 3;
        s = markerElement.getAttributeNS(null, SVG_MARKER_HEIGHT_ATTRIBUTE);
        if (s.length() != 0) {
            markerHeight = UnitProcessor.svgVerticalLengthToUserSpace
                (s, SVG_MARKER_HEIGHT_ATTRIBUTE, uctx);
        }
        if (markerHeight == 0) {
            // A value of zero disables rendering of the element.
            return null;
        }

        // 'orient' attribute - default is '0'
        double orient;
        s = markerElement.getAttributeNS(null, SVG_ORIENT_ATTRIBUTE);
        if (s.length() == 0) {
            orient = 0;
        } else if (SVG_AUTO_VALUE.equals(s)) {
            orient = Double.NaN;
        } else {
            try {
                orient = SVGUtilities.convertSVGNumber(s);
            } catch (NumberFormatException nfEx ) {
                throw new BridgeException
                    (ctx, markerElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object [] {SVG_ORIENT_ATTRIBUTE, s});
            }
        }

        // 'stroke-width' property
        Value val = CSSUtilities.getComputedStyle
            (paintedElement, SVGCSSEngine.STROKE_WIDTH_INDEX);
        float strokeWidth = val.getFloatValue();

        // 'markerUnits' attribute - default is 'strokeWidth'
        short unitsType;
        s = markerElement.getAttributeNS(null, SVG_MARKER_UNITS_ATTRIBUTE);
        if (s.length() == 0) {
            unitsType = SVGUtilities.STROKE_WIDTH;
        } else {
            unitsType = SVGUtilities.parseMarkerCoordinateSystem
                (markerElement, SVG_MARKER_UNITS_ATTRIBUTE, s, ctx);
        }

        //
        //
        //

        // compute an additional transform for 'strokeWidth' coordinate system
        AffineTransform markerTxf;
        if (unitsType == SVGUtilities.STROKE_WIDTH) {
            markerTxf = new AffineTransform();
            markerTxf.scale(strokeWidth, strokeWidth);
        } else {
            markerTxf = new AffineTransform();
        }

        // 'viewBox' and 'preserveAspectRatio' attributes
        // viewBox -> viewport(0, 0, markerWidth, markerHeight)
        AffineTransform preserveAspectRatioTransform
            = ViewBox.getPreserveAspectRatioTransform(markerElement,
                                                      markerWidth,
                                                      markerHeight, ctx);
        if (preserveAspectRatioTransform == null) {
            // disable the rendering of the element
            return null;
        } else {
            markerTxf.concatenate(preserveAspectRatioTransform);
        }
        // now we can set the transform to the 'markerContentNode'
        markerContentNode.setTransform(markerTxf);

        // 'overflow' property
        if (CSSUtilities.convertOverflow(markerElement)) { // overflow:hidden
            Rectangle2D markerClip;
            float [] offsets = CSSUtilities.convertClip(markerElement);
            if (offsets == null) { // clip:auto
                markerClip
                    = new Rectangle2D.Float(0,
                                            0,
                                            strokeWidth * markerWidth,
                                            strokeWidth * markerHeight);
            } else { // clip:rect(<x>, <y>, <w>, <h>)
                // offsets[0] = top
                // offsets[1] = right
                // offsets[2] = bottom
                // offsets[3] = left
                markerClip = new Rectangle2D.Float
                    (offsets[3],
                     offsets[0],
                     strokeWidth * markerWidth - offsets[1] - offsets[3],
                     strokeWidth * markerHeight - offsets[2] - offsets[0]);
            }

            CompositeGraphicsNode comp = new CompositeGraphicsNode();
            comp.getChildren().add(markerContentNode);
            Filter clipSrc = comp.getGraphicsNodeRable(true);
            comp.setClip(new ClipRable8Bit(clipSrc, markerClip));
            markerContentNode = comp;
        }

        // 'refX' attribute - default is 0
        float refX = 0;
        s = markerElement.getAttributeNS(null, SVG_REF_X_ATTRIBUTE);
        if (s.length() != 0) {
            refX = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_REF_X_ATTRIBUTE, uctx);
        }

        // 'refY' attribute - default is 0
        float refY = 0;
        s = markerElement.getAttributeNS(null, SVG_REF_Y_ATTRIBUTE);
        if (s.length() != 0) {
            refY = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_REF_Y_ATTRIBUTE, uctx);
        }

        // TK: Warning at this time, refX and refY are relative to the
        // paintedElement's coordinate system. We need to move the
        // reference point to the marker's coordinate system

        // Watch out: the reference point is defined a little weirdly in the
        // SVG spec., but the bottom line is that the marker content should
        // not be translated. Rather, the reference point should be computed
        // in viewport space (this  is what the following transform
        // does) and used when placing the marker.
        //
        float[] ref = {refX, refY};
        markerTxf.transform(ref, 0, ref, 0, 1);
        Marker marker = new Marker(markerContentNode,
                                   new Point2D.Float(ref[0], ref[1]),
                                   orient);

        return marker;
    }
}
