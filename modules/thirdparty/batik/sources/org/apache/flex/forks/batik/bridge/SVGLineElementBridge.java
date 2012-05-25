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

import java.awt.geom.Line2D;

import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.ShapePainter;
import org.w3c.dom.Element;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for the &lt;line> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGLineElementBridge.java,v 1.14 2004/08/18 07:12:35 vhardy Exp $
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

        UnitProcessor.Context uctx = UnitProcessor.createContext(ctx, e);
        String s;

        // 'x1' attribute - default is 0
        s = e.getAttributeNS(null, SVG_X1_ATTRIBUTE);
        float x1 = 0;
        if (s.length() != 0) {
            x1 = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_X1_ATTRIBUTE, uctx);
        }

        // 'y1' attribute - default is 0
        s = e.getAttributeNS(null, SVG_Y1_ATTRIBUTE);
        float y1 = 0;
        if (s.length() != 0) {
            y1 = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_Y1_ATTRIBUTE, uctx);
        }

        // 'x2' attribute - default is 0
        s = e.getAttributeNS(null, SVG_X2_ATTRIBUTE);
        float x2 = 0;
        if (s.length() != 0) {
            x2 = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_X2_ATTRIBUTE, uctx);
        }

        // 'y2' attribute - default is 0
        s = e.getAttributeNS(null, SVG_Y2_ATTRIBUTE);
        float y2 = 0;
        if (s.length() != 0) {
            y2 = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_Y2_ATTRIBUTE, uctx);
        }

        shapeNode.setShape(new Line2D.Float(x1, y1, x2, y2));
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when an MutationEvent of type 'DOMAttrModified' is fired.
     */
    public void handleDOMAttrModifiedEvent(MutationEvent evt) {
        String attrName = evt.getAttrName();
        if (attrName.equals(SVG_X1_ATTRIBUTE) ||
            attrName.equals(SVG_Y1_ATTRIBUTE) ||
            attrName.equals(SVG_X2_ATTRIBUTE) ||
            attrName.equals(SVG_Y2_ATTRIBUTE)) {

            buildShape(ctx, e, (ShapeNode)node);
            handleGeometryChanged();
        } else {
            super.handleDOMAttrModifiedEvent(evt);
        }
    }
}
