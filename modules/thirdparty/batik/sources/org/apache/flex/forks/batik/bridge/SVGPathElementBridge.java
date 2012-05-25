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
import java.awt.geom.Point2D;

import org.apache.flex.forks.batik.css.engine.CSSEngineEvent;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.dom.svg.SVGPathContext;
import org.apache.flex.forks.batik.ext.awt.geom.PathLength;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.parser.AWTPathProducer;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.PathParser;

import org.w3c.dom.Element;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for the &lt;path> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGPathElementBridge.java,v 1.20 2005/02/27 02:08:51 deweese Exp $
 */
public class SVGPathElementBridge extends SVGDecoratedShapeElementBridge 
       implements SVGPathContext {

    /**
     * default shape for the update of 'd' when
     * the value is the empty string.
     */
    protected static final Shape DEFAULT_SHAPE = new GeneralPath();

    /**
     * Constructs a new bridge for the &lt;path> element.
     */
    public SVGPathElementBridge() {}

    /**
     * Returns 'path'.
     */
    public String getLocalName() {
        return SVG_PATH_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGPathElementBridge();
    }

    /**
     * Constructs a path according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes a rect element
     * @param shapeNode the shape node to initialize
     */
    protected void buildShape(BridgeContext ctx,
                              Element e,
                              ShapeNode shapeNode) {


        String s = e.getAttributeNS(null, SVG_D_ATTRIBUTE);
        if (s.length() != 0) {
            AWTPathProducer app = new AWTPathProducer();
            app.setWindingRule(CSSUtilities.convertFillRule(e));
            try {
                PathParser pathParser = new PathParser();
                pathParser.setPathHandler(app);
                pathParser.parse(s);
            } catch (ParseException ex) {
                BridgeException bex
                    = new BridgeException(e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                          new Object[] {SVG_D_ATTRIBUTE});
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
        if (attrName.equals(SVG_D_ATTRIBUTE)) {
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

    Shape      pathLengthShape = null;
    PathLength pathLength      = null;

    PathLength getPathLengthObj() {
        Shape s = ((ShapeNode)node).getShape();
        if (pathLengthShape != s) {
            pathLength = new PathLength(s);
            pathLengthShape = s;
        }
        return pathLength;
    }

    // SVGPathContext interface
    public float getTotalLength() {
        PathLength pl = getPathLengthObj();
        return pl.lengthOfPath();
    }

    public Point2D getPointAtLength(float distance) {
        PathLength pl = getPathLengthObj();
        return pl.pointAtLength(distance);
    }
}
