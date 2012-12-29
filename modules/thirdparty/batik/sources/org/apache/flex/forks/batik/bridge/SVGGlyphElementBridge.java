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
import java.awt.geom.Point2D;
import java.util.StringTokenizer;
import java.util.List;
import java.util.ArrayList;

import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.font.GVTFontFace;
import org.apache.flex.forks.batik.gvt.font.Glyph;
import org.apache.flex.forks.batik.gvt.text.TextPaintInfo;
import org.apache.flex.forks.batik.parser.AWTPathProducer;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.PathParser;

import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * Bridge class for the &lt;glyph> element.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: SVGGlyphElementBridge.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class SVGGlyphElementBridge extends AbstractSVGBridge
    implements ErrorConstants {

    /**
     * Constructs a new bridge for the &lt;glyph> element.
     */
    protected SVGGlyphElementBridge() {}

    /**
     * Returns 'glyph'.
     */
    public String getLocalName() {
        return SVG_GLYPH_TAG;
    }

    /**
     * Constructs a new Glyph that represents the specified &lt;glyph> element
     * at the requested size.
     *
     * @param ctx The current bridge context.
     * @param glyphElement The glyph element to base the glyph construction on.
     * @param textElement The textElement the glyph will be used for.
     * @param glyphCode The unique id to give to the new glyph.
     * @param fontSize The font size used to determine the size of the glyph.
     * @param fontFace The font face object that contains the font attributes.
     *
     * @return The new Glyph.
     */
    public Glyph createGlyph(BridgeContext ctx,
                             Element glyphElement,
                             Element textElement,
                             int glyphCode,
                             float fontSize,
                             GVTFontFace fontFace,
                             TextPaintInfo tpi) {

        float fontHeight = fontFace.getUnitsPerEm();
        float scale = fontSize/fontHeight;
        AffineTransform scaleTransform
            = AffineTransform.getScaleInstance(scale, -scale);

        // create a shape that represents the d attribute
        String d = glyphElement.getAttributeNS(null, SVG_D_ATTRIBUTE);
        Shape dShape = null;
        if (d.length() != 0) {
            AWTPathProducer app = new AWTPathProducer();
            // Glyph is supposed to use properties from text element.
            app.setWindingRule(CSSUtilities.convertFillRule(textElement));
            try {
                PathParser pathParser = new PathParser();
                pathParser.setPathHandler(app);
                pathParser.parse(d);
            } catch (ParseException pEx) {
                throw new BridgeException(ctx, glyphElement,
                                          pEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                          new Object [] {SVG_D_ATTRIBUTE});
            } finally {
                // transform the shape into the correct coord system
                Shape shape = app.getShape();
                Shape transformedShape
                    = scaleTransform.createTransformedShape(shape);
                dShape = transformedShape;
            }
        }

        // process any glyph children

        // first see if there are any, because don't want to do the following
        // bit of code if we can avoid it

        NodeList glyphChildren = glyphElement.getChildNodes();
        int numChildren = glyphChildren.getLength();
        int numGlyphChildren = 0;
        for (int i = 0; i < numChildren; i++) {
            Node childNode = glyphChildren.item(i);
            if (childNode.getNodeType() == Node.ELEMENT_NODE) {
                numGlyphChildren++;
            }
        }

        CompositeGraphicsNode glyphContentNode = null;

        if (numGlyphChildren > 0) {  // the glyph has child elements

            // build the GVT tree that represents the glyph children
            GVTBuilder builder = ctx.getGVTBuilder();

            glyphContentNode = new CompositeGraphicsNode();

            //
            // need to clone the parent font element and glyph element
            // this is so that the glyph doesn't inherit anything past the font element
            //
            Element fontElementClone
                = (Element)glyphElement.getParentNode().cloneNode(false);

            // copy all font attributes over
            NamedNodeMap fontAttributes
                = glyphElement.getParentNode().getAttributes();

            int numAttributes = fontAttributes.getLength();
            for (int i = 0; i < numAttributes; i++) {
                fontElementClone.setAttributeNode((Attr)fontAttributes.item(i));
            }
            Element clonedGlyphElement = (Element)glyphElement.cloneNode(true);
            fontElementClone.appendChild(clonedGlyphElement);

            textElement.appendChild(fontElementClone);

            CompositeGraphicsNode glyphChildrenNode
                = new CompositeGraphicsNode();

            glyphChildrenNode.setTransform(scaleTransform);

            NodeList clonedGlyphChildren = clonedGlyphElement.getChildNodes();
            int numClonedChildren = clonedGlyphChildren.getLength();
            for (int i = 0; i < numClonedChildren; i++) {
                Node childNode = clonedGlyphChildren.item(i);
                if (childNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element childElement = (Element)childNode;
                    GraphicsNode childGraphicsNode =
                         builder.build(ctx, childElement);
                    glyphChildrenNode.add(childGraphicsNode);
                }
            }
            glyphContentNode.add(glyphChildrenNode);
            textElement.removeChild(fontElementClone);
        }

        // set up glyph attributes

        // unicode
        String unicode
            = glyphElement.getAttributeNS(null, SVG_UNICODE_ATTRIBUTE);

        // glyph-name
        String nameList
            = glyphElement.getAttributeNS(null, SVG_GLYPH_NAME_ATTRIBUTE);
        List names = new ArrayList();
        StringTokenizer st = new StringTokenizer(nameList, " ,");
        while (st.hasMoreTokens()) {
            names.add(st.nextToken());
        }

        // orientation
        String orientation
            = glyphElement.getAttributeNS(null, SVG_ORIENTATION_ATTRIBUTE);

        // arabicForm
        String arabicForm
            = glyphElement.getAttributeNS(null, SVG_ARABIC_FORM_ATTRIBUTE);

        // lang
        String lang = glyphElement.getAttributeNS(null, SVG_LANG_ATTRIBUTE);


        Element parentFontElement = (Element)glyphElement.getParentNode();

        // horz-adv-x
        String s = glyphElement.getAttributeNS(null, SVG_HORIZ_ADV_X_ATTRIBUTE);
        if (s.length() == 0) {
            // look for attribute on parent font element
            s = parentFontElement.getAttributeNS(null, SVG_HORIZ_ADV_X_ATTRIBUTE);
            if (s.length() == 0) {
                // throw an exception since this attribute is required on the font element
                throw new BridgeException
                    (ctx, parentFontElement, ERR_ATTRIBUTE_MISSING,
                     new Object[] {SVG_HORIZ_ADV_X_ATTRIBUTE});
            }
        }
        float horizAdvX;
        try {
            horizAdvX = SVGUtilities.convertSVGNumber(s) * scale;
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, glyphElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object [] {SVG_HORIZ_ADV_X_ATTRIBUTE, s});
        }

        // vert-adv-y
        s = glyphElement.getAttributeNS(null, SVG_VERT_ADV_Y_ATTRIBUTE);
        if (s.length() == 0) {
            // look for attribute on parent font element
            s = parentFontElement.getAttributeNS(null, SVG_VERT_ADV_Y_ATTRIBUTE);
            if (s.length() == 0) {
                // not specified on parent either, use one em
                s = String.valueOf(fontFace.getUnitsPerEm());
            }
        }
        float vertAdvY;
        try {
            vertAdvY = SVGUtilities.convertSVGNumber(s) * scale;
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, glyphElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object [] {SVG_VERT_ADV_Y_ATTRIBUTE, s});
        }

        // vert-origin-x
        s = glyphElement.getAttributeNS(null, SVG_VERT_ORIGIN_X_ATTRIBUTE);
        if (s.length() == 0) {
            // look for attribute on parent font element
            s = parentFontElement.getAttributeNS(null, SVG_VERT_ORIGIN_X_ATTRIBUTE);
            if (s.length() == 0) {
                // not specified so use the default value which is horizAdvX/2
                s = Float.toString(horizAdvX/2);
            }
        }
        float vertOriginX;
        try {
            vertOriginX = SVGUtilities.convertSVGNumber(s) * scale;
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, glyphElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object [] {SVG_VERT_ORIGIN_X_ATTRIBUTE, s});
        }

        // vert-origin-y
        s = glyphElement.getAttributeNS(null, SVG_VERT_ORIGIN_Y_ATTRIBUTE);
        if (s.length() == 0) {
            // look for attribute on parent font element
            s = parentFontElement.getAttributeNS(null, SVG_VERT_ORIGIN_Y_ATTRIBUTE);
            if (s.length() == 0) {
                // not specified so use the default value which is the fonts ascent
                s = String.valueOf(fontFace.getAscent());
            }
        }
        float vertOriginY;
        try {
            vertOriginY = SVGUtilities.convertSVGNumber(s) * -scale;
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, glyphElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object [] {SVG_VERT_ORIGIN_Y_ATTRIBUTE, s});
        }

        Point2D vertOrigin = new Point2D.Float(vertOriginX, vertOriginY);


        // get the horizontal origin from the parent font element

        // horiz-origin-x
        s = parentFontElement.getAttributeNS(null, SVG_HORIZ_ORIGIN_X_ATTRIBUTE);
        if (s.length() == 0) {
            // not specified so use the default value which is 0
            s = SVG_HORIZ_ORIGIN_X_DEFAULT_VALUE;
        }
        float horizOriginX;
        try {
            horizOriginX = SVGUtilities.convertSVGNumber(s) * scale;
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, parentFontElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object [] {SVG_HORIZ_ORIGIN_X_ATTRIBUTE, s});
        }

        // horiz-origin-y
        s = parentFontElement.getAttributeNS(null, SVG_HORIZ_ORIGIN_Y_ATTRIBUTE);
        if (s.length() == 0) {
            // not specified so use the default value which is 0
            s = SVG_HORIZ_ORIGIN_Y_DEFAULT_VALUE;
        }
        float horizOriginY;
        try {
            horizOriginY = SVGUtilities.convertSVGNumber(s) * -scale;
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, glyphElement, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object [] {SVG_HORIZ_ORIGIN_Y_ATTRIBUTE, s});
        }

        Point2D horizOrigin = new Point2D.Float(horizOriginX, horizOriginY);

        // return a new Glyph
        return new Glyph(unicode, names, orientation,
                         arabicForm, lang, horizOrigin, vertOrigin,
                         horizAdvX, vertAdvY, glyphCode,
                         tpi, dShape, glyphContentNode);
    }
}
