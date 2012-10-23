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

import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.dom.svg.AbstractSVGAnimatedLength;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.dom.svg.SVGOMCircleElement;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.ShapePainter;

import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;circle> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGCircleElementBridge.java 527382 2007-04-11 04:31:58Z cam $
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
        try {
            SVGOMCircleElement ce = (SVGOMCircleElement) e;

            // 'cx' attribute - default is 0
            AbstractSVGAnimatedLength _cx =
                (AbstractSVGAnimatedLength) ce.getCx();
            float cx = _cx.getCheckedValue();

            // 'cy' attribute - default is 0
            AbstractSVGAnimatedLength _cy =
                (AbstractSVGAnimatedLength) ce.getCy();
            float cy = _cy.getCheckedValue();

            // 'r' attribute - required
            AbstractSVGAnimatedLength _r =
                (AbstractSVGAnimatedLength) ce.getR();
            float r = _r.getCheckedValue();

            float x = cx - r;
            float y = cy - r;
            float w = r * 2;
            shapeNode.setShape(new Ellipse2D.Float(x, y, w, w));
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
            if (ln.equals(SVG_CX_ATTRIBUTE)
                    || ln.equals(SVG_CY_ATTRIBUTE)
                    || ln.equals(SVG_R_ATTRIBUTE)) {
                buildShape(ctx, e, (ShapeNode)node);
                handleGeometryChanged();
                return;
            }
        }
        super.handleAnimatedAttributeChanged(alav);
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
