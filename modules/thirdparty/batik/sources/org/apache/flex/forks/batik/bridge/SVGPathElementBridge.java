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
import java.awt.geom.Point2D;

import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.dom.svg.SVGAnimatedPathDataSupport;
import org.apache.flex.forks.batik.dom.svg.SVGOMAnimatedPathData;
import org.apache.flex.forks.batik.dom.svg.SVGOMPathElement;
import org.apache.flex.forks.batik.dom.svg.SVGPathContext;
import org.apache.flex.forks.batik.ext.awt.geom.PathLength;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.apache.flex.forks.batik.parser.AWTPathProducer;

import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGPathSegList;

/**
 * Bridge class for the &lt;path> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGPathElementBridge.java 594018 2007-11-12 04:17:41Z cam $
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

        SVGOMPathElement pe = (SVGOMPathElement) e;
        AWTPathProducer app = new AWTPathProducer();
        try {
            // 'd' attribute - required
            SVGOMAnimatedPathData _d = pe.getAnimatedPathData();
            _d.check();
            SVGPathSegList p = _d.getAnimatedPathSegList();
            app.setWindingRule(CSSUtilities.convertFillRule(e));
            SVGAnimatedPathDataSupport.handlePathSegList(p, app);
        } catch (LiveAttributeException ex) {
            throw new BridgeException(ctx, ex);
        } finally {
            shapeNode.setShape(app.getShape());
        }
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when the animated value of an animatable attribute has changed.
     */
    public void handleAnimatedAttributeChanged
            (AnimatedLiveAttributeValue alav) {
        if (alav.getNamespaceURI() == null &&
                alav.getLocalName().equals(SVG_D_ATTRIBUTE)) {
            buildShape(ctx, e, (ShapeNode) node);
            handleGeometryChanged();
        } else {
            super.handleAnimatedAttributeChanged(alav);
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

    // SVGPathContext ////////////////////////////////////////////////////////

    /**
     * The cached Shape used for computing the path length.
     */
    protected Shape pathLengthShape;

    /**
     * The cached PathLength object used for computing the path length.
     */
    protected PathLength pathLength;

    /**
     * Returns the PathLength object that tracks the length of the path.
     */
    protected PathLength getPathLengthObj() {
        Shape s = ((ShapeNode)node).getShape();
        if (pathLengthShape != s) {
            pathLength = new PathLength(s);
            pathLengthShape = s;
        }
        return pathLength;
    }

    /**
     * Returns the total length of the path.
     */
    public float getTotalLength() {
        PathLength pl = getPathLengthObj();
        return pl.lengthOfPath();
    }

    /**
     * Returns the point at the given distance along the path.
     */
    public Point2D getPointAtLength(float distance) {
        PathLength pl = getPathLengthObj();
        return pl.pointAtLength(distance);
    }

    /**
     * Returns the index of the path segment at the given distance along the
     * path.
     */
    public int getPathSegAtLength(float distance) {
        PathLength pl = getPathLengthObj();
        return pl.segmentAtLength(distance);
    }
}
