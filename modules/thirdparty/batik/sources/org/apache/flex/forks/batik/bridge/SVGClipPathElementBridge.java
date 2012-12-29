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

import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.geom.GeneralPath;

import org.apache.flex.forks.batik.dom.svg.SVGOMUseElement;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.ShapeNode;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * Bridge class for the &lt;clipPath> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGClipPathElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGClipPathElementBridge extends AnimatableGenericSVGBridge
        implements ClipBridge {

    /**
     * Constructs a new bridge for the &lt;clipPath> element.
     */
    public SVGClipPathElementBridge() {}

    /**
     * Returns 'clipPath'.
     */
    public String getLocalName() {
        return SVG_CLIP_PATH_TAG;
    }

    /**
     * Creates a <tt>Clip</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param clipElement the element that defines the clip
     * @param clipedElement the element that references the clip element
     * @param clipedNode the graphics node to clip
     */
    public ClipRable createClip(BridgeContext ctx,
                                Element clipElement,
                                Element clipedElement,
                                GraphicsNode clipedNode) {

        String s;

        // 'transform' attribute
        AffineTransform Tx;
        s = clipElement.getAttributeNS(null, SVG_TRANSFORM_ATTRIBUTE);
        if (s.length() != 0) {
            Tx = SVGUtilities.convertTransform
                (clipElement, SVG_TRANSFORM_ATTRIBUTE, s, ctx);
        } else {
            Tx = new AffineTransform();
        }

        // 'clipPathUnits' attribute - default is userSpaceOnUse
        short coordSystemType;
        s = clipElement.getAttributeNS(null, SVG_CLIP_PATH_UNITS_ATTRIBUTE);
        if (s.length() == 0) {
            coordSystemType = SVGUtilities.USER_SPACE_ON_USE;
        } else {
            coordSystemType = SVGUtilities.parseCoordinateSystem
                (clipElement, SVG_CLIP_PATH_UNITS_ATTRIBUTE, s, ctx);
        }
        // additional transform to move to objectBoundingBox coordinate system
        if (coordSystemType == SVGUtilities.OBJECT_BOUNDING_BOX) {
            Tx = SVGUtilities.toObjectBBox(Tx, clipedNode);
        }

        // Build the GVT tree that represents the clip path
        //
        // The silhouettes of the child elements are logically OR'd
        // together to create a single silhouette which is then used to
        // restrict the region onto which paint can be applied.
        //
        // The 'clipPath' element or any of its children can specify
        // property 'clip-path'.
        //
        Area clipPath = new Area();
        GVTBuilder builder = ctx.getGVTBuilder();
        boolean hasChildren = false;
        for(Node node = clipElement.getFirstChild();
            node != null;
            node = node.getNextSibling()) {

            // check if the node is a valid Element
            if (node.getNodeType() != Node.ELEMENT_NODE) {
                continue;
            }

            Element child = (Element)node;
            GraphicsNode clipNode = builder.build(ctx, child) ;
            // check if a GVT node has been created
            if (clipNode == null) {
                continue;
            }
            hasChildren = true;

            // if this is a 'use' element, get the actual shape used
            if (child instanceof SVGOMUseElement) {
                Node shadowChild
                    = ((SVGOMUseElement) child).getCSSFirstChild();

                if (shadowChild != null
                        && shadowChild.getNodeType() == Node.ELEMENT_NODE) {
                    child = (Element) shadowChild;
                }
            }

            // compute the outline of the current clipPath's child
            int wr = CSSUtilities.convertClipRule(child);
            GeneralPath path = new GeneralPath(clipNode.getOutline());
            path.setWindingRule(wr);

            AffineTransform at = clipNode.getTransform();
            if (at == null)  at = Tx;
            else             at.preConcatenate(Tx);

            Shape outline = at.createTransformedShape(path);

            // apply the 'clip-path' of the current clipPath's child
            ShapeNode outlineNode = new ShapeNode();
            outlineNode.setShape(outline);
            ClipRable clip = CSSUtilities.convertClipPath(child,
                                                          outlineNode,
                                                          ctx);
            if (clip != null) {
                Area area = new Area(outline);
                area.subtract(new Area(clip.getClipPath()));
                outline = area;
            }
            clipPath.add(new Area(outline));
        }
        if (!hasChildren) {
            return null; // empty clipPath
        }

        // construct the shape node that represents the clipPath
        ShapeNode clipPathNode = new ShapeNode();
        clipPathNode.setShape(clipPath);

        // apply the 'clip-path' of the clipPath element (already in user space)
        ClipRable clipElementClipPath =
            CSSUtilities.convertClipPath(clipElement, clipPathNode, ctx);
        if (clipElementClipPath != null) {
            clipPath.subtract(new Area(clipElementClipPath.getClipPath()));
        }

        Filter filter = clipedNode.getFilter();
        if (filter == null) {
            // Make the initial source as a RenderableImage
            filter = clipedNode.getGraphicsNodeRable(true);
        }

        boolean useAA = false;
        RenderingHints hints;
        hints = CSSUtilities.convertShapeRendering(clipElement, null);
        if (hints != null) {
            Object o = hints.get(RenderingHints.KEY_ANTIALIASING);
            useAA = (o == RenderingHints.VALUE_ANTIALIAS_ON);
        }
            
        return new ClipRable8Bit(filter, clipPath, useAA);
    }
}
