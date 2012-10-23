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
package org.apache.flex.forks.batik.extension.svg;

import java.awt.geom.GeneralPath;

import org.apache.flex.forks.batik.bridge.Bridge;
import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.BridgeException;
import org.apache.flex.forks.batik.bridge.SVGDecoratedShapeElementBridge;
import org.apache.flex.forks.batik.bridge.SVGUtilities;
import org.apache.flex.forks.batik.bridge.UnitProcessor;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.w3c.dom.Element;

/**
 * Bridge class for a star element.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas Deweese</a>
 * @version $Id: BatikStarElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class BatikStarElementBridge
    extends SVGDecoratedShapeElementBridge
    implements BatikExtConstants {

    /**
     * Constructs a new bridge for the &lt;rect> element.
     */
    public BatikStarElementBridge() { /* nothing */ }

    /**
     * Returns the SVG namespace URI.
     */
    public String getNamespaceURI() {
        return BATIK_EXT_NAMESPACE_URI;
    }

    /**
     * Returns 'rect'.
     */
    public String getLocalName() {
        return BATIK_EXT_STAR_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new BatikStarElementBridge();
    }

    /**
     * Constructs a star polygone according to the specified parameters.
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
        if (s.length() == 0)
            throw new BridgeException(ctx, e, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {SVG_R_ATTRIBUTE, s});
        r = UnitProcessor.svgOtherLengthToUserSpace
            (s, SVG_R_ATTRIBUTE, uctx);

        // 'ir' attribute - required
        s = e.getAttributeNS(null, BATIK_EXT_IR_ATTRIBUTE);
        float ir;
        if (s.length() == 0)
            throw new BridgeException
                (ctx, e, ERR_ATTRIBUTE_MISSING,
                 new Object[] {BATIK_EXT_IR_ATTRIBUTE, s});

        ir = UnitProcessor.svgOtherLengthToUserSpace
            (s, BATIK_EXT_IR_ATTRIBUTE, uctx);

        // 'sides' attribute - default is 3
        int sides = convertSides(e, BATIK_EXT_SIDES_ATTRIBUTE, 3, ctx);

        GeneralPath gp = new GeneralPath();
        double angle, x, y;
        final double SECTOR = 2.0 * Math.PI/sides;
        final double HALF_PI = Math.PI / 2.0;

        for (int i=0; i<sides; i++) {
            angle    = i * SECTOR - HALF_PI;
            x = cx + ir*Math.cos(angle);
            y = cy - ir*Math.sin(angle);
            if (i==0)
                gp.moveTo((float)x, (float)y);
            else
                gp.lineTo((float)x, (float)y);

            angle    = (i+0.5) * SECTOR - HALF_PI;
            x = cx + r*Math.cos(angle);
            y = cy - r*Math.sin(angle);
            gp.lineTo((float)x, (float)y);
        }
        gp.closePath();

        shapeNode.setShape(gp);
    }

    /**
     * Stolen from AbstractSVGFilterPrimitiveElementBridge.
     * Converts on the specified filter primitive element, the specified
     * attribute that represents an integer and with the specified
     * default value.
     *
     * @param filterElement the filter primitive element
     * @param attrName the name of the attribute
     * @param defaultValue the default value of the attribute
     * @param ctx the BridgeContext to use for error information
     */
    protected static int convertSides(Element filterElement,
                                      String attrName,
                                      int defaultValue,
                                      BridgeContext ctx) {
        String s = filterElement.getAttributeNS(null, attrName);
        if (s.length() == 0) {
            return defaultValue;
        } else {
            int ret = 0;
            try {
                ret = SVGUtilities.convertSVGInteger(s);
            } catch (NumberFormatException nfEx ) {
                throw new BridgeException
                    (ctx, filterElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {attrName, s});
            }

            if (ret <3)
                throw new BridgeException
                    (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {attrName, s});
            return ret;
        }
    }
}
