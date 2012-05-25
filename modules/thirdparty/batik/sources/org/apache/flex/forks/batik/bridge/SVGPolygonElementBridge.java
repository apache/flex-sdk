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

import java.awt.Shape;
import java.awt.geom.GeneralPath;

import org.apache.flex.forks.batik.css.engine.CSSEngineEvent;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.parser.AWTPolygonProducer;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.PointsParser;
import org.w3c.dom.Element;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for the &lt;polygon> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGPolygonElementBridge.java,v 1.20 2004/08/18 07:12:35 vhardy Exp $
 */
public class SVGPolygonElementBridge extends SVGDecoratedShapeElementBridge {

    /**
     * default shape for the update of 'points' when
     * the value is the empty string.
     */
    protected static final Shape DEFAULT_SHAPE = new GeneralPath();

    /**
     * Constructs a new bridge for the &lt;polygon> element.
     */
    public SVGPolygonElementBridge() {}

    /**
     * Returns 'polygon'.
     */
    public String getLocalName() {
        return SVG_POLYGON_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGPolygonElementBridge();
    }

    /**
     * Constructs a polygon according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes a rect element
     * @param shapeNode the shape node to initialize
     */
    protected void buildShape(BridgeContext ctx,
                              Element e,
                              ShapeNode shapeNode) {

        String s = e.getAttributeNS(null, SVG_POINTS_ATTRIBUTE);
        if (s.length() != 0) {
            AWTPolygonProducer app = new AWTPolygonProducer();
            app.setWindingRule(CSSUtilities.convertFillRule(e));
            try {
                PointsParser pp = new PointsParser();
                pp.setPointsHandler(app);
                pp.parse(s);
            } catch (ParseException ex) {
                BridgeException bex
                    = new BridgeException(e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                          new Object[] {SVG_POINTS_ATTRIBUTE});
                bex.setGraphicsNode(shapeNode);
                throw bex;
            } finally {
                shapeNode.setShape(app.getShape());
            }
        }
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when an MutationEvent of type 'DOMAttrModified' is fired.
     */
    public void handleDOMAttrModifiedEvent(MutationEvent evt) {
        String attrName = evt.getAttrName();
        if (attrName.equals(SVG_POINTS_ATTRIBUTE)) {
            if ( evt.getNewValue().length() == 0 ){
                ((ShapeNode)node).setShape(DEFAULT_SHAPE);
            }
            else{
                buildShape(ctx, e, (ShapeNode)node);
            }
            handleGeometryChanged();
        } else {
            super.handleDOMAttrModifiedEvent(evt);
        }
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
