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

import java.awt.geom.Line2D;

import org.apache.flex.forks.batik.dom.svg.AbstractSVGAnimatedLength;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.dom.svg.SVGOMLineElement;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.ShapePainter;

import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;line> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGLineElementBridge.java 527382 2007-04-11 04:31:58Z cam $
 */
public class SVGLineElementBridge extends SVGDecoratedShapeElementBridge {

    /**
     * Constructs a new bridge for the &lt;line> element.
     */
    public SVGLineElementBridge() {}

    /**
     * Returns 'line'.
     */
    public String getLocalName() {
        return SVG_LINE_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGLineElementBridge();
    }

    /**
     * Creates the shape painter associated to the specified element.
     * This implementation creates a shape painter considering the
     * various fill and stroke properties.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the shape painter to use
     * @param shapeNode the shape node that is interested in its shape painter
     */
    protected ShapePainter createFillStrokePainter(BridgeContext ctx,
                                                   Element e,
                                                   ShapeNode shapeNode) {
        // 'fill'           - ignored
        // 'fill-opacity'   - ignored
        // 'stroke'
        // 'stroke-opacity',
        // 'stroke-width'
        // 'stroke-linecap'
        // 'stroke-linejoin'
        // 'stroke-miterlimit'
        // 'stroke-dasharray'
        // 'stroke-dashoffset'
        return PaintServer.convertStrokePainter(e, shapeNode, ctx);
    }

    /**
     * Constructs a line according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes a rect element
     * @param shapeNode the shape node to initialize
     */
    protected void buildShape(BridgeContext ctx,
                              Element e,
                              ShapeNode shapeNode) {

        try {
            SVGOMLineElement le = (SVGOMLineElement) e;

            // 'x1' attribute - default is 0
            AbstractSVGAnimatedLength _x1 =
                (AbstractSVGAnimatedLength) le.getX1();
            float x1 = _x1.getCheckedValue();

            // 'y1' attribute - default is 0
            AbstractSVGAnimatedLength _y1 =
                (AbstractSVGAnimatedLength) le.getY1();
            float y1 = _y1.getCheckedValue();

            // 'x2' attribute - default is 0
            AbstractSVGAnimatedLength _x2 =
                (AbstractSVGAnimatedLength) le.getX2();
            float x2 = _x2.getCheckedValue();

            // 'y2' attribute - default is 0
            AbstractSVGAnimatedLength _y2 =
                (AbstractSVGAnimatedLength) le.getY2();
            float y2 = _y2.getCheckedValue();

            shapeNode.setShape(new Line2D.Float(x1, y1, x2, y2));
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        }
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when the animated value of an animatable attribute has changed.
     */
    public void handleAnimatedAttributeChanged
            (AnimatedLiveAttributeValue alav) {
        if (alav.getNamespaceURI() == null) {
            String ln = alav.getLocalName();
            if (ln.equals(SVG_X1_ATTRIBUTE)
                    || ln.equals(SVG_Y1_ATTRIBUTE)
                    || ln.equals(SVG_X2_ATTRIBUTE)
                    || ln.equals(SVG_Y2_ATTRIBUTE)) {
                buildShape(ctx, e, (ShapeNode)node);
                handleGeometryChanged();
                return;
            }
        }
        super.handleAnimatedAttributeChanged(alav);
    }
}
