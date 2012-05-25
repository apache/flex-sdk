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

import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.ShapePainter;
import org.w3c.dom.Element;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for the &lt;circle> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGCircleElementBridge.java,v 1.15 2004/08/18 07:12:33 vhardy Exp $
 */
public class SVGCircleElementBridge extends SVGShapeElementBridge {

    /**
     * Constructs a new bridge for the &lt;circle> element.
     */
    public SVGCircleElementBridge() {}

    /**
     * Returns 'circle'.
     */
    public String getLocalName() {
        return SVG_CIRCLE_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGCircleElementBridge();
    }

    /**
     * Constructs a circle according to the specified parameters.
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

        // 'cx' attribute - default is 0
        s = e.getAttributeNS(null, SVG_CX_ATTRIBUTE);
        float cx = 0;
        if (s.length() != 0) {
            cx = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_CX_ATTRIBUTE, uctx);
        }

        // 'cy' attribute - default is 0
        s = e.getAttributeNS(null, SVG_CY_ATTRIBUTE);
        float cy = 0;
        if (s.length() != 0) {
            cy = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_CY_ATTRIBUTE, uctx);
        }

        // 'r' attribute - required
        s = e.getAttributeNS(null, SVG_R_ATTRIBUTE);
        float r;
        if (s.length() != 0) {
            r = UnitProcessor.svgOtherLengthToUserSpace
                (s, SVG_R_ATTRIBUTE, uctx);
        } else {
            throw new BridgeException(e, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {SVG_R_ATTRIBUTE, s});
        }
        float x = cx - r;
        float y = cy - r;
        float w = r * 2;
        shapeNode.setShape(new Ellipse2D.Float(x, y, w, w));
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when an MutationEvent of type 'DOMAttrModified' is fired.
     */
    public void handleDOMAttrModifiedEvent(MutationEvent evt) {
        String attrName = evt.getAttrName();
        if (attrName.equals(SVG_CX_ATTRIBUTE) ||
            attrName.equals(SVG_CY_ATTRIBUTE) ||
            attrName.equals(SVG_R_ATTRIBUTE)) {

            buildShape(ctx, e, (ShapeNode)node);
            handleGeometryChanged();
        } else {
            super.handleDOMAttrModifiedEvent(evt);
        }
    }

    protected ShapePainter createShapePainter(BridgeContext ctx,
                                              Element e,
                                              ShapeNode shapeNode) {
        Rectangle2D r2d = shapeNode.getShape().getBounds2D();
        if ((r2d.getWidth() == 0) || (r2d.getHeight() == 0))
            return null;
        return super.createShapePainter(ctx, e, shapeNode);
    }
}
