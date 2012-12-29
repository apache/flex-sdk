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

import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Image;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Toolkit;
import java.awt.geom.AffineTransform;
import java.awt.geom.Point2D;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.util.Hashtable;
import java.util.Map;

import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.AffineRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.spi.BrokenLinkProvider;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageTagRegistry;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.Platform;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.SoftReferenceCache;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.css.CSSValue;
import org.w3c.dom.svg.SVGDocument;
import org.w3c.dom.svg.SVGPreserveAspectRatio;


/**
 * The CursorManager class is a helper class which preloads the cursors
 * corresponding to the SVG built in cursors.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: CursorManager.java 594367 2007-11-13 00:40:53Z cam $
 */
public class CursorManager implements SVGConstants, ErrorConstants {
    /**
     * Maps SVG Cursor Values to Java Cursors
     */
    protected static Map cursorMap;

    /**
     * Default cursor when value is not found
     */
    public static final Cursor DEFAULT_CURSOR
        = Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR);

    /**
     * Cursor used over anchors
     */
    public static final Cursor ANCHOR_CURSOR
        = Cursor.getPredefinedCursor(Cursor.HAND_CURSOR);

    /**
     * Cursor used over text
     */
    public static final Cursor TEXT_CURSOR
        = Cursor.getPredefinedCursor(Cursor.TEXT_CURSOR);

    /**
     * Default preferred cursor size, used for SVG images
     */
    public static final int DEFAULT_PREFERRED_WIDTH = 32;
    public static final int DEFAULT_PREFERRED_HEIGHT = 32;

    /**
     * Static initialization of the cursorMap
     */
    static {
        Toolkit toolkit = Toolkit.getDefaultToolkit();
        cursorMap = new Hashtable();
        cursorMap.put(SVG_CROSSHAIR_VALUE,
                      Cursor.getPredefinedCursor(Cursor.CROSSHAIR_CURSOR));
        cursorMap.put(SVG_DEFAULT_VALUE,
                      Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
        cursorMap.put(SVG_POINTER_VALUE,
                      Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        cursorMap.put(SVG_E_RESIZE_VALUE,
                      Cursor.getPredefinedCursor(Cursor.E_RESIZE_CURSOR));
        cursorMap.put(SVG_NE_RESIZE_VALUE,
                      Cursor.getPredefinedCursor(Cursor.NE_RESIZE_CURSOR));
        cursorMap.put(SVG_NW_RESIZE_VALUE,
                      Cursor.getPredefinedCursor(Cursor.NW_RESIZE_CURSOR));
        cursorMap.put(SVG_N_RESIZE_VALUE,
                      Cursor.getPredefinedCursor(Cursor.N_RESIZE_CURSOR));
        cursorMap.put(SVG_SE_RESIZE_VALUE,
                      Cursor.getPredefinedCursor(Cursor.SE_RESIZE_CURSOR));
        cursorMap.put(SVG_SW_RESIZE_VALUE,
                      Cursor.getPredefinedCursor(Cursor.SW_RESIZE_CURSOR));
        cursorMap.put(SVG_S_RESIZE_VALUE,
                      Cursor.getPredefinedCursor(Cursor.S_RESIZE_CURSOR));
        cursorMap.put(SVG_W_RESIZE_VALUE,
                      Cursor.getPredefinedCursor(Cursor.W_RESIZE_CURSOR));
        cursorMap.put(SVG_TEXT_VALUE,
                      Cursor.getPredefinedCursor(Cursor.TEXT_CURSOR));
        cursorMap.put(SVG_WAIT_VALUE,
                      Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        Cursor moveCursor = Cursor.getPredefinedCursor(Cursor.MOVE_CURSOR);
        if (Platform.isOSX) {
            try {
                Image img = toolkit.createImage
                    (CursorManager.class.getResource("resources/move.gif"));
                moveCursor = toolkit.createCustomCursor
                    (img, new Point(11, 11), "move");
            } catch (Exception ex) {
            }
        }
        cursorMap.put(SVG_MOVE_VALUE, moveCursor);
        Cursor helpCursor;
        try {
            Image img = toolkit.createImage
                (CursorManager.class.getResource("resources/help.gif"));
            helpCursor = toolkit.createCustomCursor
                (img, new Point(1, 3), "help");
        } catch (Exception ex) {
            helpCursor = Cursor.getPredefinedCursor(Cursor.HAND_CURSOR);
        }
        cursorMap.put(SVG_HELP_VALUE, helpCursor);
    }

    /**
     * BridgeContext associated with this CursorManager
     */
    protected BridgeContext ctx;

    /**
     * Cache used to hold references to cursors
     */
    protected CursorCache cursorCache = new CursorCache();

    /**
     * Creates a new CursorManager object.
     *
     * @param ctx the BridgeContext associated to this CursorManager
     */
    public CursorManager(BridgeContext ctx) {
        this.ctx = ctx;
    }

    /**
     * Returns a Cursor object for a given cursor value. This initial
     * implementation does not handle user-defined cursors, so it
     * always uses the cursor at the end of the list
     */
    public static Cursor getPredefinedCursor(String cursorName){
        return (Cursor)cursorMap.get(cursorName);
    }

    /**
     * Returns the Cursor corresponding to the input element's cursor property
     *
     * @param e the element on which the cursor property is set
     */
    public Cursor convertCursor(Element e) {
        Value cursorValue = CSSUtilities.getComputedStyle
            (e, SVGCSSEngine.CURSOR_INDEX);

        String cursorStr = SVGConstants.SVG_AUTO_VALUE;

        if (cursorValue != null) {
            if (cursorValue.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE
                &&
                cursorValue.getPrimitiveType() == CSSPrimitiveValue.CSS_IDENT) {
                // Single Value : should be one of the predefined cursors or
                // 'inherit'
                cursorStr = cursorValue.getStringValue();
                return convertBuiltInCursor(e, cursorStr);
            } else if (cursorValue.getCssValueType() ==
                       CSSValue.CSS_VALUE_LIST) {
                int nValues = cursorValue.getLength();
                if (nValues == 1) {
                    cursorValue = cursorValue.item(0);
                    if (cursorValue.getPrimitiveType() ==
                        CSSPrimitiveValue.CSS_IDENT) {
                        cursorStr = cursorValue.getStringValue();
                        return convertBuiltInCursor(e, cursorStr);
                    }
                } else if (nValues > 1) {
                    //
                    // Look for the first cursor url we can handle.
                    // That would be a reference to a <cursor> element.
                    //
                    return convertSVGCursor(e, cursorValue);
                }
            }
        }

        return convertBuiltInCursor(e, cursorStr);
    }

    public Cursor convertBuiltInCursor(Element e, String cursorStr) {
        Cursor cursor = null;

        // The CSS engine guarantees an non null, non empty string
        // as the computed value for cursor. Therefore, the following
        // test is safe.
        if (cursorStr.charAt(0) == 'a') {
            //
            // Handle 'auto' value.
            //
            // - <a> The following sets the cursor for <a> element
            // enclosing text nodes. Setting the proper cursor (i.e.,
            // depending on the children's 'cursor' property, is
            // handled in the SVGAElementBridge so as to avoid going
            // up the tree on mouseover events (looking for an anchor
            // ancestor.
            //
            // - <image> The following does not change the cursor if
            // the element's cursor property is set to
            // 'auto'. Otherwise, it takes precedence over any child
            // (in case of SVG content) cursor setting.  This means
            // that for images referencing SVG content, a cursor
            // property set to 'auto' on the <image> element will not
            // override the cursor settings inside the SVG image. Any
            // other cursor property will take precedence.
            //
            // - <use> Same behavior as for <image> except that the
            // behavior is controlled from the <use> element bridge
            // (SVGUseElementBridge).
            //
            // - <text>, <tref> and <tspan> : a cursor value of auto
            // will cause the cursor to be set to a text cursor. Note
            // that text content with an 'auto' cursor and descendant
            // of an anchor will have its cursor set to the anchor
            // cursor through the SVGAElementBridge.
            //
            String nameSpaceURI = e.getNamespaceURI();
            if (SVGConstants.SVG_NAMESPACE_URI.equals(nameSpaceURI)) {
                String tag = e.getLocalName();
                if (SVGConstants.SVG_A_TAG.equals(tag)) {
                    cursor = CursorManager.ANCHOR_CURSOR;
                } else if (SVGConstants.SVG_TEXT_TAG.equals(tag) ||
                           SVGConstants.SVG_TSPAN_TAG.equals(tag) ||
                           SVGConstants.SVG_TREF_TAG.equals(tag) ) {
                    cursor = CursorManager.TEXT_CURSOR;
                } else if (SVGConstants.SVG_IMAGE_TAG.equals(tag)) {
                    // Do not change the cursor
                    return null;
                } else {
                    cursor = CursorManager.DEFAULT_CURSOR;
                }
            } else {
                cursor = CursorManager.DEFAULT_CURSOR;
            }
        } else {
            // Specific, logical cursor
            cursor = CursorManager.getPredefinedCursor(cursorStr);
        }

        return cursor;
    }


    /**
     * Returns a cursor for the given value list. Note that the
     * code assumes that the input value has at least two entries.
     * So the caller should check that before calling the method.
     * For example, CSSUtilities.convertCursor performs that check.
     */
    public Cursor convertSVGCursor(Element e, Value l) {
        int nValues = l.getLength();
        Element cursorElement = null;
        for (int i=0; i<nValues-1; i++) {
            Value cursorValue = l.item(i);
            if (cursorValue.getPrimitiveType() == CSSPrimitiveValue.CSS_URI) {
                String uri = cursorValue.getStringValue();

                // If the uri does not resolve to a cursor element,
                // then, this is not a type of cursor uri we can handle:
                // go to the next or default to logical cursor
                try {
                    cursorElement = ctx.getReferencedElement(e, uri);
                } catch (BridgeException be) {
                    // Be only silent if this is a case where the target
                    // could not be found. Do not catch other errors (e.g,
                    // malformed URIs)
                    if (!ERR_URI_BAD_TARGET.equals(be.getCode())) {
                        throw be;
                    }
                }

                if (cursorElement != null) {
                    // We go an element, check it is of type cursor
                    String cursorNS = cursorElement.getNamespaceURI();
                    if (SVGConstants.SVG_NAMESPACE_URI.equals(cursorNS) &&
                        SVGConstants.SVG_CURSOR_TAG.equals
                        (cursorElement.getLocalName())) {
                        Cursor c = convertSVGCursorElement(cursorElement);
                        if (c != null) {
                            return c;
                        }
                    }
                }
            }
        }

        // If we got to that point, it means that no cursorElement
        // produced a valid cursor, i.e., either a format we support
        // or a valid referenced image (no broken image).
        // Fallback on the built in cursor property.
        Value cursorValue = l.item(nValues-1);
        String cursorStr = SVGConstants.SVG_AUTO_VALUE;
        if (cursorValue.getPrimitiveType() == CSSPrimitiveValue.CSS_IDENT) {
            cursorStr = cursorValue.getStringValue();
        }

        return convertBuiltInCursor(e, cursorStr);
    }

    /**
     * Returns a cursor for a given element
     */
    public Cursor convertSVGCursorElement(Element cursorElement) {
        // One of the cursor url resolved to a <cursor> element
        // Try to handle its image.
        String uriStr = XLinkSupport.getXLinkHref(cursorElement);
        if (uriStr.length() == 0) {
            throw new BridgeException(ctx, cursorElement, ERR_ATTRIBUTE_MISSING,
                                      new Object[] {"xlink:href"});
        }

        String baseURI = AbstractNode.getBaseURI(cursorElement);
        ParsedURL purl;
        if (baseURI == null) {
            purl = new ParsedURL(uriStr);
        } else {
            purl = new ParsedURL(baseURI, uriStr);
        }

        //
        // Convert the cursor's hot spot
        //
        UnitProcessor.Context uctx
            = UnitProcessor.createContext(ctx, cursorElement);

        String s = cursorElement.getAttributeNS(null, SVG_X_ATTRIBUTE);
        float x = 0;
        if (s.length() != 0) {
            x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_X_ATTRIBUTE, uctx);
        }

        s = cursorElement.getAttributeNS(null, SVG_Y_ATTRIBUTE);
        float y = 0;
        if (s.length() != 0) {
            y = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_Y_ATTRIBUTE, uctx);
        }

        CursorDescriptor desc = new CursorDescriptor(purl, x, y);

        //
        // Check if there is a cursor in the cache for this url
        //
        Cursor cachedCursor = cursorCache.getCursor(desc);

        if (cachedCursor != null) {
            return cachedCursor;
        }

        //
        // Load image into Filter f and transform hotSpot to
        // cursor space.
        //
        Point2D.Float hotSpot = new Point2D.Float(x, y);
        Filter f = cursorHrefToFilter(cursorElement,
                                      purl,
                                      hotSpot);
        if (f == null) {
            cursorCache.clearCursor(desc);
            return null;
        }

        // The returned Filter is guaranteed to create a
        // default rendering of the desired size
        Rectangle cursorSize = f.getBounds2D().getBounds();
        RenderedImage ri = f.createScaledRendering(cursorSize.width,
                                                   cursorSize.height,
                                                   null);
        Image img = null;

        if (ri instanceof Image) {
            img = (Image)ri;
        } else {
            img = renderedImageToImage(ri);
        }

        // Make sure the not spot does not fall out of the cursor area. If it
        // does, then clamp the coordinates to the image space.
        hotSpot.x = hotSpot.x < 0 ? 0 : hotSpot.x;
        hotSpot.y = hotSpot.y < 0 ? 0 : hotSpot.y;
        hotSpot.x = hotSpot.x > (cursorSize.width-1) ? cursorSize.width - 1 : hotSpot.x;
        hotSpot.y = hotSpot.y > (cursorSize.height-1) ? cursorSize.height - 1: hotSpot.y;

        //
        // The cursor image is now into 'img'
        //
        Cursor c = Toolkit.getDefaultToolkit()
            .createCustomCursor(img,
                                new Point(Math.round(hotSpot.x),
                                          Math.round(hotSpot.y)),
                                purl.toString());

        cursorCache.putCursor(desc, c);
        return c;
    }

    /**
     * Converts the input ParsedURL into a Filter and transforms the
     * input hotSpot point (in image space) to cursor space
     */
    protected Filter cursorHrefToFilter(Element cursorElement,
                                        ParsedURL purl,
                                        Point2D hotSpot) {

        AffineRable8Bit f = null;
        String uriStr = purl.toString();
        Dimension cursorSize = null;

        // Try to load as an SVG Document
        DocumentLoader loader = ctx.getDocumentLoader();
        SVGDocument svgDoc = (SVGDocument)cursorElement.getOwnerDocument();
        URIResolver resolver = ctx.createURIResolver(svgDoc, loader);
        try {
            Element rootElement = null;
            Node n = resolver.getNode(uriStr, cursorElement);
            if (n.getNodeType() == Node.DOCUMENT_NODE) {
                SVGDocument doc = (SVGDocument)n;
                // FIXX: really should be subCtx here.
                ctx.initializeDocument(doc);
                rootElement = doc.getRootElement();
            } else {
                throw new BridgeException
                    (ctx, cursorElement, ERR_URI_IMAGE_INVALID,
                     new Object[] {uriStr});
            }
            GraphicsNode node = ctx.getGVTBuilder().build(ctx, rootElement);

            //
            // The cursorSize define the viewport into which the
            // cursor is displayed. That viewport is platform
            // dependant and is not defined by the SVG content.
            //
            float width  = DEFAULT_PREFERRED_WIDTH;
            float height = DEFAULT_PREFERRED_HEIGHT;
            UnitProcessor.Context uctx
                = UnitProcessor.createContext(ctx, rootElement);

            String s = rootElement.getAttribute(SVG_WIDTH_ATTRIBUTE);
            if (s.length() != 0) {
                width = UnitProcessor.svgHorizontalLengthToUserSpace
                (s, SVG_WIDTH_ATTRIBUTE, uctx);
            }

            s = rootElement.getAttribute(SVG_HEIGHT_ATTRIBUTE);
            if (s.length() != 0) {
                height = UnitProcessor.svgVerticalLengthToUserSpace
                    (s, SVG_HEIGHT_ATTRIBUTE, uctx);
            }

            cursorSize
                = Toolkit.getDefaultToolkit().getBestCursorSize
                (Math.round(width), Math.round(height));

            // Handle the viewBox transform
            AffineTransform at = ViewBox.getPreserveAspectRatioTransform
                (rootElement, cursorSize.width, cursorSize.height, ctx);
            Filter filter = node.getGraphicsNodeRable(true);
            f = new AffineRable8Bit(filter, at);
        } catch (BridgeException ex) {
            throw ex;
        } catch (SecurityException ex) {
            throw new BridgeException(ctx, cursorElement, ex, ERR_URI_UNSECURE,
                                      new Object[] {uriStr});
        } catch (Exception ex) {
            /* Nothing to do */
        }


        // If f is null, it means that we are not dealing with
        // an SVG image. Try as a raster image.
        if (f == null) {
            ImageTagRegistry reg = ImageTagRegistry.getRegistry();
            Filter filter = reg.readURL(purl);
            if (filter == null) {
                return null;
            }

            // Check if we got a broken image
            if (BrokenLinkProvider.hasBrokenLinkProperty(filter)) {
                return null;
            }

            Rectangle preferredSize = filter.getBounds2D().getBounds();
            cursorSize = Toolkit.getDefaultToolkit().getBestCursorSize
                (preferredSize.width, preferredSize.height);

            if (preferredSize != null && preferredSize.width >0
                && preferredSize.height > 0 ) {
                AffineTransform at = new AffineTransform();
                if (preferredSize.width > cursorSize.width
                    ||
                    preferredSize.height > cursorSize.height) {
                    at = ViewBox.getPreserveAspectRatioTransform
                        (new float[] {0, 0, preferredSize.width, preferredSize.height},
                         SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMINYMIN,
                         true,
                         cursorSize.width,
                         cursorSize.height);
                }
                f = new AffineRable8Bit(filter, at);
            } else {
                // Invalid Size
                return null;
            }
        }


        //
        // Transform the hot spot from image space to cursor space
        //
        AffineTransform at = f.getAffine();
        at.transform(hotSpot, hotSpot);

        //
        // In all cases, clip to the cursor boundaries
        //
        Rectangle cursorViewport
            = new Rectangle(0, 0, cursorSize.width, cursorSize.height);

        PadRable8Bit cursorImage
            = new PadRable8Bit(f, cursorViewport,
                               PadMode.ZERO_PAD);

        return cursorImage;

    }


    /**
     * Implementation helper: converts a RenderedImage to an Image
     */
    protected Image renderedImageToImage(RenderedImage ri) {
        int x = ri.getMinX();
        int y = ri.getMinY();
        SampleModel sm = ri.getSampleModel();
        ColorModel cm = ri.getColorModel();
        WritableRaster wr = Raster.createWritableRaster(sm, new Point(x,y));
        ri.copyData(wr);

        return new BufferedImage(cm, wr, cm.isAlphaPremultiplied(), null);
    }

    /**
     * Simple inner class which holds the information describing
     * a cursor, i.e., the image it points to and the hot spot point
     * coordinates.
     */
    static class CursorDescriptor {
        ParsedURL purl;
        float x;
        float y;
        String desc;

        public CursorDescriptor(ParsedURL purl,
                                float x, float y) {
            if (purl == null) {
                throw new IllegalArgumentException();
            }

            this.purl = purl;
            this.x = x;
            this.y = y;

            // Desc is used for hascode as well as for toString()
            this.desc = this.getClass().getName() +
                "\n\t:[" + this.purl + "]\n\t:[" + x + "]:[" + y + "]";
        }

        public boolean equals(Object obj) {
            if (obj == null
                ||
                !(obj instanceof CursorDescriptor)) {
                return false;
            }

            CursorDescriptor desc = (CursorDescriptor)obj;
            boolean isEqual =
                this.purl.equals(desc.purl)
                 &&
                 this.x == desc.x
                 &&
                 this.y == desc.y;

            return isEqual;
        }

        public String toString() {
            return this.desc;
        }

        public int hashCode() {
            return desc.hashCode();
        }
    }

    /**
     * Simple extension of the SoftReferenceCache that
     * offers typed interface (Kind of needed as SoftReferenceCache
     * mostly has protected methods).
     */
    static class CursorCache extends SoftReferenceCache {
        public CursorCache() {
        }

        public Cursor getCursor(CursorDescriptor desc) {
            return (Cursor)requestImpl(desc);
        }

        public void putCursor(CursorDescriptor desc,
                              Cursor cursor) {
            putImpl(desc, cursor);
        }

        public void clearCursor(CursorDescriptor desc) {
            clearImpl(desc);
        }
    }
}
