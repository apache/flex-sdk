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

import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.gvt.CompositeShapePainter;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.gvt.ShapePainter;
import org.w3c.dom.Element;

/**
 * The base bridge class for decorated shapes. Decorated shapes can be
 * filled, stroked and can have markers.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGDecoratedShapeElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class SVGDecoratedShapeElementBridge
        extends SVGShapeElementBridge {

    /**
     * Constructs a new bridge for SVG decorated shapes.
     */
    protected SVGDecoratedShapeElementBridge() {}


    ShapePainter createFillStrokePainter(BridgeContext ctx, 
                                         Element e,
                                         ShapeNode shapeNode) {
        // 'fill'
        // 'fill-opacity'
        // 'stroke'
        // 'stroke-opacity',
        // 'stroke-width'
        // 'stroke-linecap'
        // 'stroke-linejoin'
        // 'stroke-miterlimit'
        // 'stroke-dasharray'
        // 'stroke-dashoffset'
        return super.createShapePainter(ctx, e, shapeNode);
    }

    ShapePainter createMarkerPainter(BridgeContext ctx, 
                                     Element e,
                                     ShapeNode shapeNode) {
        // marker-start
        // marker-mid
        // marker-end
        return PaintServer.convertMarkers(e, shapeNode, ctx);
    }

    /**
     * Creates the shape painter associated to the specified element.
     * This implementation creates a shape painter considering the
     * various fill and stroke properties in addition to the marker
     * properties.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the shape painter to use
     * @param shapeNode the shape node that is interested in its shape painter
     */
    protected ShapePainter createShapePainter(BridgeContext ctx,
                                              Element e,
                                              ShapeNode shapeNode) {
        ShapePainter fillAndStroke;
        fillAndStroke = createFillStrokePainter(ctx, e, shapeNode);

        ShapePainter markerPainter = createMarkerPainter(ctx, e, shapeNode);

        Shape shape = shapeNode.getShape();
        ShapePainter painter;

        if (markerPainter != null) {
            if (fillAndStroke != null) {
                CompositeShapePainter cp = new CompositeShapePainter(shape);
                cp.addShapePainter(fillAndStroke);
                cp.addShapePainter(markerPainter);
                painter = cp;
            } else {
                painter = markerPainter;
            }
        } else {
            painter = fillAndStroke;
        }
        return painter;
    }

    protected void handleCSSPropertyChanged(int property) {
        switch(property) {
        case SVGCSSEngine.MARKER_START_INDEX:
        case SVGCSSEngine.MARKER_MID_INDEX:
        case SVGCSSEngine.MARKER_END_INDEX:
            if (!hasNewShapePainter) {
                hasNewShapePainter = true;
                ShapeNode shapeNode = (ShapeNode)node;
                shapeNode.setShapePainter(createShapePainter(ctx, e, shapeNode));
            }
            break;
        default:
            super.handleCSSPropertyChanged(property);
        }
    }
}

