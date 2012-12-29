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
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;

import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.gvt.text.TextPath;
import org.apache.flex.forks.batik.parser.AWTPathProducer;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.PathParser;
import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;textPath> element.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: SVGTextPathElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class SVGTextPathElementBridge extends AnimatableGenericSVGBridge
                                      implements ErrorConstants {

    /**
     * Constructs a new bridge for the &lt;textPath> element.
     */
    public SVGTextPathElementBridge() {}

    /**
     * Returns 'textPath'.
     */
    public String getLocalName() {
        return SVG_TEXT_PATH_TAG;
    }

    public void handleElement(BridgeContext ctx, Element e) {
        // We don't want to take over from the text content element.
    }

    /**
     * Creates a TextPath object that represents the path along which the text
     * is to be rendered.
     *
     * @param ctx The bridge context.
     * @param textPathElement The &lt;textPath> element.
     *
     * @return The new TextPath.
     */
    public TextPath createTextPath(BridgeContext ctx, Element textPathElement) {

        // get the referenced element
        String uri = XLinkSupport.getXLinkHref(textPathElement);
        Element pathElement = ctx.getReferencedElement(textPathElement, uri);

        if ((pathElement == null) ||
            (!SVG_NAMESPACE_URI.equals(pathElement.getNamespaceURI())) ||
            (!pathElement.getLocalName().equals(SVG_PATH_TAG))) {
            // couldn't find the referenced element
            // or the referenced element was not a path
            throw new BridgeException(ctx, textPathElement, ERR_URI_BAD_TARGET,
                                      new Object[] {uri});
        }

        // construct a shape for the referenced path element
        String s = pathElement.getAttributeNS(null, SVG_D_ATTRIBUTE);
        Shape pathShape = null;
        if (s.length() != 0) {
            AWTPathProducer app = new AWTPathProducer();
            app.setWindingRule(CSSUtilities.convertFillRule(pathElement));
            try {
                PathParser pathParser = new PathParser();
                pathParser.setPathHandler(app);
                pathParser.parse(s);
            } catch (ParseException pEx ) {
               throw new BridgeException
                   (ctx, pathElement, pEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                    new Object[] {SVG_D_ATTRIBUTE});
            } finally {
                pathShape = app.getShape();
            }
        } else {
            throw new BridgeException(ctx, pathElement, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {SVG_D_ATTRIBUTE});
        }

        // if the reference path element has a transform apply the transform
        // to the path shape
        s = pathElement.getAttributeNS(null, SVG_TRANSFORM_ATTRIBUTE);
        if (s.length() != 0) {
            AffineTransform tr =
                SVGUtilities.convertTransform(pathElement,
                                              SVG_TRANSFORM_ATTRIBUTE, s, ctx);
            pathShape = tr.createTransformedShape(pathShape);
        }

        // create the TextPath object that we are going to return
        TextPath textPath = new TextPath(new GeneralPath(pathShape));

        // set the start offset if specified
        s = textPathElement.getAttributeNS(null, SVG_START_OFFSET_ATTRIBUTE);
        if (s.length() > 0) {
            float startOffset = 0;
            int percentIndex = s.indexOf('%');
            if (percentIndex != -1) {
                // its a percentage of the length of the path
                float pathLength = textPath.lengthOfPath();
                String percentString = s.substring(0,percentIndex);
                float startOffsetPercent = 0;
                try {
                    startOffsetPercent = SVGUtilities.convertSVGNumber(percentString);
                } catch (NumberFormatException e) {
                    startOffsetPercent = -1;
                }
                if (startOffsetPercent < 0) {
                    throw new BridgeException
                        (ctx, textPathElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                         new Object[] {SVG_START_OFFSET_ATTRIBUTE, s});
                }
                startOffset = (float)(startOffsetPercent * pathLength/100.0);

            } else {
                // its an absolute length
                UnitProcessor.Context uctx = UnitProcessor.createContext(ctx, textPathElement);
                startOffset = UnitProcessor.svgOtherLengthToUserSpace(s, SVG_START_OFFSET_ATTRIBUTE, uctx);
            }
            textPath.setStartOffset(startOffset);
        }

        return textPath;
    }
}
