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
import java.awt.geom.GeneralPath;

import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.dom.svg.SVGOMAnimatedPoints;
import org.apache.flex.forks.batik.dom.svg.SVGOMPolylineElement;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.parser.AWTPolylineProducer;

import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGPoint;
import org.w3c.dom.svg.SVGPointList;

/**
 * Bridge class for the &lt;polyline> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGPolylineElementBridge.java 594018 2007-11-12 04:17:41Z cam $
 */
public class SVGPolylineElementBridge extends SVGDecoratedShapeElementBridge {

    /**
     * default shape for the update of 'points' when
     * the value is the empty string.
     */
    protected static final Shape DEFAULT_SHAPE = new GeneralPath();

    /**
     * Constructs a new bridge for the &lt;polyline> element.
     */
    public SVGPolylineElementBridge() {}

    /**
     * Returns 'polyline'.
     */
    public String getLocalName() {
        return SVG_POLYLINE_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGPolylineElementBridge();
    }

    /**
     * Constructs a polyline according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes a rect element
     * @param shapeNode the shape node to initialize
     */
    protected void buildShape(BridgeContext ctx,
                              Element e,
                              ShapeNode shapeNode) {

        SVGOMPolylineElement pe = (SVGOMPolylineElement) e;
        try {
            SVGOMAnimatedPoints _points = pe.getSVGOMAnimatedPoints();
            _points.check();
            SVGPointList pl = _points.getAnimatedPoints();
            int size = pl.getNumberOfItems();
            if (size == 0) {
                shapeNode.setShape(DEFAULT_SHAPE);
            } else {
                AWTPolylineProducer app = new AWTPolylineProducer();
                app.setWindingRule(CSSUtilities.convertFillRule(e));
                app.startPoints();
                for (int i = 0; i < size; i++) {
                    SVGPoint p = pl.getItem(i);
                    app.point(p.getX(), p.getY());
                }
                app.endPoints();
                shapeNode.setShape(app.getShape());
            }
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
            if (ln.equals(SVG_POINTS_ATTRIBUTE)) {
                buildShape(ctx, e, (ShapeNode)node);
                handleGeometryChanged();
                return;
            }
        }
        super.handleAnimatedAttributeChanged(alav);
    }

    protected void handleCSSPropertyChanged(int property) {
        switch(property) {
        case SVGCSSEngine.FILL_RULE_INDEX:
            buildShape(ctx, e, (ShapeNode) node);
            handleGeometryChanged();
            break;
        default:
            super.handleCSSPropertyChanged(property);
        }
    }
}
