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

import java.awt.Shape;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RoundRectangle2D;

import org.apache.flex.forks.batik.dom.svg.AbstractSVGAnimatedLength;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.dom.svg.SVGOMRectElement;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.ShapePainter;

import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;rect> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGRectElementBridge.java 527382 2007-04-11 04:31:58Z cam $
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

        try {
            SVGOMRectElement re = (SVGOMRectElement) e;

            // 'x' attribute - default is 0
            AbstractSVGAnimatedLength _x =
                (AbstractSVGAnimatedLength) re.getX();
            float x = _x.getCheckedValue();

            // 'y' attribute - default is 0
            AbstractSVGAnimatedLength _y =
                (AbstractSVGAnimatedLength) re.getY();
            float y = _y.getCheckedValue();

            // 'width' attribute - required
            AbstractSVGAnimatedLength _width =
                (AbstractSVGAnimatedLength) re.getWidth();
            float w = _width.getCheckedValue();

            // 'height' attribute - required
            AbstractSVGAnimatedLength _height =
                (AbstractSVGAnimatedLength) re.getHeight();
            float h = _height.getCheckedValue();

            // 'rx' attribute - default is 0
            AbstractSVGAnimatedLength _rx =
                (AbstractSVGAnimatedLength) re.getRx();
            float rx = _rx.getCheckedValue();
            if (rx > w / 2) {
                rx = w / 2;
            }

            // 'ry' attribute - default is rx
            AbstractSVGAnimatedLength _ry =
                (AbstractSVGAnimatedLength) re.getRy();
            float ry = _ry.getCheckedValue();
            if (ry > h / 2) {
                ry = h / 2;
            }

            Shape shape;
            if (rx == 0 || ry == 0) {
                shape = new Rectangle2D.Float(x, y, w, h);
            } else {
                shape = new RoundRectangle2D.Float(x, y, w, h, rx * 2, ry * 2);
            }
            shapeNode.setShape(shape);
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
            if (ln.equals(SVG_X_ATTRIBUTE)
                    || ln.equals(SVG_Y_ATTRIBUTE)
                    || ln.equals(SVG_WIDTH_ATTRIBUTE)
                    || ln.equals(SVG_HEIGHT_ATTRIBUTE)
                    || ln.equals(SVG_RX_ATTRIBUTE)
                    || ln.equals(SVG_RY_ATTRIBUTE)) {
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
        Shape shape = shapeNode.getShape();
        Rectangle2D r2d = shape.getBounds2D();
        if ((r2d.getWidth() == 0) || (r2d.getHeight() == 0))
            return null;
        return super.createShapePainter(ctx, e, shapeNode);
    }
}
