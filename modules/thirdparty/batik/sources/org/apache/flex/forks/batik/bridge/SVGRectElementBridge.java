/*

   Copyright 2001-2003  The Apache Software Foundation 

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

import java.awt.Shape;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RoundRectangle2D;

import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.ShapePainter;

import org.w3c.dom.Element;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for the &lt;rect> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGRectElementBridge.java,v 1.16 2004/08/18 07:12:35 vhardy Exp $
 */
public class SVGRectElementBridge extends SVGShapeElementBridge {

    /**
     * Constructs a new bridge for the &lt;rect> element.
     */
    public SVGRectElementBridge() {}

    /**
     * Returns 'rect'.
     */
    public String getLocalName() {
        return SVG_RECT_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGRectElementBridge();
    }

    /**
     * Constructs a rectangle according to the specified parameters.
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

        // 'x' attribute - default is 0
        s = e.getAttributeNS(null, SVG_X_ATTRIBUTE);
        float x = 0;
        if (s.length() != 0) {
            x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_X_ATTRIBUTE, uctx);
        }

        // 'y' attribute - default is 0
        s = e.getAttributeNS(null, SVG_Y_ATTRIBUTE);
        float y = 0;
        if (s.length() != 0) {
            y = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_Y_ATTRIBUTE, uctx);
        }

        // 'width' attribute - required
        s = e.getAttributeNS(null, SVG_WIDTH_ATTRIBUTE);
        float w;
        if (s.length() != 0) {
            w = UnitProcessor.svgHorizontalLengthToUserSpace
                (s, SVG_WIDTH_ATTRIBUTE, uctx);
        } else {
            throw new BridgeException(e, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {SVG_WIDTH_ATTRIBUTE, s});
        }

        // 'height' attribute - required
        s = e.getAttributeNS(null, SVG_HEIGHT_ATTRIBUTE);
        float h;
        if (s.length() != 0) {
            h = UnitProcessor.svgVerticalLengthToUserSpace
                (s, SVG_HEIGHT_ATTRIBUTE, uctx);
        } else {
            throw new BridgeException(e, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {SVG_HEIGHT_ATTRIBUTE, s});
        }

        // 'rx' attribute - default is 0
        s = e.getAttributeNS(null, SVG_RX_ATTRIBUTE);
        boolean rxs = (s.length() != 0);
        float rx = 0;
        if (rxs) {
            rx = UnitProcessor.svgHorizontalLengthToUserSpace
                (s, SVG_RX_ATTRIBUTE, uctx);
        }
        rx = (rx > w / 2) ? w / 2 : rx;

        // 'ry' attribute - default is 0
        s = e.getAttributeNS(null, SVG_RY_ATTRIBUTE);
        boolean rys = (s.length() != 0);
        float ry = 0;
        if (rys) {
            ry = UnitProcessor.svgVerticalLengthToUserSpace
                (s, SVG_RY_ATTRIBUTE, uctx);
        }
        ry = (ry > h / 2) ? h / 2 : ry;

        Shape shape = null;
        if (rxs && rys) {
            if (rx == 0 || ry == 0) {
                shape = new Rectangle2D.Float(x, y, w, h);
            } else {
                shape = new RoundRectangle2D.Float(x, y, w, h, rx*2, ry*2);
            }
        } else if (rxs) {
            if (rx == 0) {
                shape = new Rectangle2D.Float(x, y, w, h);
            } else {
                shape = new RoundRectangle2D.Float(x, y, w, h, rx*2, rx*2);
            }
        } else if (rys) {
            if (ry == 0) {
                shape = new Rectangle2D.Float(x, y, w, h);
            } else {
                shape = new RoundRectangle2D.Float(x, y, w, h, ry*2, ry*2);
            }
        } else {
            shape = new Rectangle2D.Float(x, y, w, h);
        }
        shapeNode.setShape(shape);
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when an MutationEvent of type 'DOMAttrModified' is fired.
     */
    public void handleDOMAttrModifiedEvent(MutationEvent evt) {
        String attrName = evt.getAttrName();
        if (attrName.equals(SVG_X_ATTRIBUTE) ||
            attrName.equals(SVG_Y_ATTRIBUTE) ||
            attrName.equals(SVG_WIDTH_ATTRIBUTE) ||
            attrName.equals(SVG_HEIGHT_ATTRIBUTE) ||
            attrName.equals(SVG_RX_ATTRIBUTE) ||
            attrName.equals(SVG_RY_ATTRIBUTE)) {

            buildShape(ctx, e, (ShapeNode)node);
            handleGeometryChanged();
        } else {
            super.handleDOMAttrModifiedEvent(evt);
        }
    }


    protected ShapePainter createShapePainter(BridgeContext ctx,
                                              Element e,
                                              ShapeNode shapeNode) {
        Shape shape = shapeNode.getShape();
        Rectangle2D r2d = shape.getBounds2D();
        if ((r2d.getWidth() == 0) || (r2d.getHeight() == 0))
            return null;
        return super.createShapePainter(ctx, e, shapeNode);
    }
}
