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

import java.awt.geom.AffineTransform;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.io.IOException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.StringTokenizer;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.parser.AWTTransformProducer;
import org.apache.flex.forks.batik.parser.ClockHandler;
import org.apache.flex.forks.batik.parser.ClockParser;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVG12Constants;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGDocument;
import org.w3c.dom.svg.SVGElement;
import org.w3c.dom.svg.SVGLangSpace;
import org.w3c.dom.svg.SVGNumberList;

/**
 * A collection of utility methods for SVG.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGUtilities.java 594740 2007-11-14 02:55:05Z cam $
 */
public abstract class SVGUtilities implements SVGConstants, ErrorConstants {

    /**
     * No instance of this class is required.
     */
    protected SVGUtilities() {}

    ////////////////////////////////////////////////////////////////////////
    // common methods
    ////////////////////////////////////////////////////////////////////////

    /**
     * Returns the logical parent element of the given element.
     * The parent element of a used element is the &lt;use> element
     * which reference it.
     */
    public static Element getParentElement(Element elt) {
        Node n = CSSEngine.getCSSParentNode(elt);
        while (n != null && n.getNodeType() != Node.ELEMENT_NODE) {
            n = CSSEngine.getCSSParentNode(n);
        }
        return (Element) n;
    }

    /**
     * Converts an SVGNumberList into a float array.
     * @param l the list to convert
     */
    public static float[] convertSVGNumberList(SVGNumberList l) {
        int n = l.getNumberOfItems();
        if (n == 0) {
            return null;
        }
        float[] fl = new float[n];
        for (int i=0; i < n; i++) {
            fl[i] = l.getItem(i).getValue();
        }
        return fl;
    }

    /**
     * Converts a string into a float.
     * @param s the float representation to convert
     */
    public static float convertSVGNumber(String s) {
        return Float.parseFloat(s);
    }

    /**
     * Converts a string into an integer.
     * @param s the integer representation to convert
     */
    public static int convertSVGInteger(String s) {
        return Integer.parseInt(s);
    }

    /**
     * Converts the specified ratio to float number.
     * @param v the ratio value to convert
     * @exception NumberFormatException if the ratio is not a valid
     * number or percentage
     */
    public static float convertRatio(String v) {
        float d = 1;
        if (v.endsWith("%")) {
            v = v.substring(0, v.length() - 1);
            d = 100;
        }
        float r = Float.parseFloat(v)/d;
        if (r < 0) {
            r = 0;
        } else if (r > 1) {
            r = 1;
        }
        return r;
    }

    /**
     * Returns the content of the 'desc' child of the given element.
     */
    public static String getDescription(SVGElement elt) {
        String result = "";
        boolean preserve = false;
        Node n = elt.getFirstChild();
        if (n != null && n.getNodeType() == Node.ELEMENT_NODE) {
            String name =
                (n.getPrefix() == null) ? n.getNodeName() : n.getLocalName();
            if (name.equals(SVG_DESC_TAG)) {
                preserve = ((SVGLangSpace)n).getXMLspace().equals
                    (SVG_PRESERVE_VALUE);
                for (n = n.getFirstChild();
                     n != null;
                     n = n.getNextSibling()) {
                    if (n.getNodeType() == Node.TEXT_NODE) {
                        result += n.getNodeValue();
                    }
                }
            }
        }
        return (preserve)
            ? XMLSupport.preserveXMLSpace(result)
            : XMLSupport.defaultXMLSpace(result);
    }

    /**
     * Tests whether or not the given element match a specified user agent.
     *
     * @param elt the element to check
     * @param ua the user agent
     */
    public static boolean matchUserAgent(Element elt, UserAgent ua) {
        test: if (elt.hasAttributeNS(null, SVG_SYSTEM_LANGUAGE_ATTRIBUTE)) {
            // Tests the system languages.
            String sl = elt.getAttributeNS(null,
                                           SVG_SYSTEM_LANGUAGE_ATTRIBUTE);
            if (sl.length() == 0) // SVG spec says empty returns false
                return false;
            StringTokenizer st = new StringTokenizer(sl, ", ");
            while (st.hasMoreTokens()) {
                String s = st.nextToken();
                if (matchUserLanguage(s, ua.getLanguages())) {
                    break test;
                }
            }
            return false;
        }
        if (elt.hasAttributeNS(null, SVG_REQUIRED_FEATURES_ATTRIBUTE)) {
            // Tests the system features.
            String rf = elt.getAttributeNS(null,
                                           SVG_REQUIRED_FEATURES_ATTRIBUTE);
            if (rf.length() == 0)  // SVG spec says empty returns false
                return false;
            StringTokenizer st = new StringTokenizer(rf, " ");
            while (st.hasMoreTokens()) {
                String s = st.nextToken();
                if (!ua.hasFeature(s)) {
                    return false;
                }
            }
        }
        if (elt.hasAttributeNS(null, SVG_REQUIRED_EXTENSIONS_ATTRIBUTE)) {
            // Tests the system features.
            String re = elt.getAttributeNS(null,
                                           SVG_REQUIRED_EXTENSIONS_ATTRIBUTE);
            if (re.length() == 0)  // SVG spec says empty returns false
                return false;
            StringTokenizer st = new StringTokenizer(re, " ");
            while (st.hasMoreTokens()) {
                String s = st.nextToken();
                if (!ua.supportExtension(s)) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * Tests whether or not the specified language specification matches
     * the user preferences.
     *
     * @param s the langage to check
     * @param userLanguages the user langages
     */
    protected static boolean matchUserLanguage(String s,
                                               String userLanguages) {
        StringTokenizer st = new StringTokenizer(userLanguages, ", ");
        while (st.hasMoreTokens()) {
            String t = st.nextToken();
            if (s.startsWith(t)) {
                if (s.length() > t.length()) {
                    return (s.charAt(t.length()) == '-');
                }
                return true;
            }
        }
        return false;
    }

    /**
     * Returns the value of the specified attribute specified on the
     * specified element or one of its ancestor. Ancestors are found
     * using the xlink:href attribute.
     *
     * @param element the element to start with
     * @param namespaceURI the namespace URI of the attribute to return
     * @param attrName the name of the attribute to search
     * @param ctx the bridge context
     * @return the value of the attribute or an empty string if not defined
     */
    public static String getChainableAttributeNS(Element element,
                                                 String namespaceURI,
                                                 String attrName,
                                                 BridgeContext ctx) {

        DocumentLoader loader = ctx.getDocumentLoader();
        Element e = element;
        List refs = new LinkedList();
        for (;;) {
            String v = e.getAttributeNS(namespaceURI, attrName);
            if (v.length() > 0) { // exit if attribute defined
                return v;
            }
            String uriStr = XLinkSupport.getXLinkHref(e);
            if (uriStr.length() == 0) { // exit if no more xlink:href
                return "";
            }
            String baseURI = ((AbstractNode) e).getBaseURI();
            ParsedURL purl = new ParsedURL(baseURI, uriStr);

            Iterator iter = refs.iterator();
            while (iter.hasNext()) {
                if (purl.equals(iter.next()))
                    throw new BridgeException
                        (ctx, e, ERR_XLINK_HREF_CIRCULAR_DEPENDENCIES,
                         new Object[] {uriStr});
            }

            try {
                SVGDocument svgDoc = (SVGDocument)e.getOwnerDocument();
                URIResolver resolver = ctx.createURIResolver(svgDoc, loader);
                e = resolver.getElement(purl.toString(), e);
                refs.add(purl);
            } catch(IOException ioEx ) {
                throw new BridgeException(ctx, e, ioEx, ERR_URI_IO,
                                          new Object[] {uriStr});
            } catch(SecurityException secEx ) {
                throw new BridgeException(ctx, e, secEx, ERR_URI_UNSECURE,
                                          new Object[] {uriStr});
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // <linearGradient> and <radialGradient>
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns a Point2D in user units according to the specified parameters.
     *
     * @param xStr the x coordinate
     * @param xAttr the name of the attribute that represents the x coordinate
     * @param yStr the y coordinate
     * @param yAttr the name of the attribute that represents the y coordinate
     * @param unitsType the coordinate system (OBJECT_BOUNDING_BOX |
     * USER_SPACE_ON_USE)
     * @param uctx the unit processor context
     */
    public static Point2D convertPoint(String xStr,
                                       String xAttr,
                                       String yStr,
                                       String yAttr,
                                       short unitsType,
                                       UnitProcessor.Context uctx) {
        float x, y;
        switch (unitsType) {
        case OBJECT_BOUNDING_BOX:
            x = UnitProcessor.svgHorizontalCoordinateToObjectBoundingBox
                (xStr, xAttr, uctx);
            y = UnitProcessor.svgVerticalCoordinateToObjectBoundingBox
                (yStr, yAttr, uctx);
            break;
        case USER_SPACE_ON_USE:
            x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (xStr, xAttr, uctx);
            y = UnitProcessor.svgVerticalCoordinateToUserSpace
                (yStr, yAttr, uctx);
            break;
        default:
            throw new IllegalArgumentException("Invalid unit type");
        }
        return new Point2D.Float(x, y);
    }

    /**
     * Returns a float in user units according to the specified parameters.
     *
     * @param length the length
     * @param attr the name of the attribute that represents the length
     * @param unitsType the coordinate system (OBJECT_BOUNDING_BOX |
     * USER_SPACE_ON_USE)
     * @param uctx the unit processor context
     */
    public static float convertLength(String length,
                                      String attr,
                                      short unitsType,
                                      UnitProcessor.Context uctx) {
        switch (unitsType) {
        case OBJECT_BOUNDING_BOX:
            return UnitProcessor.svgOtherLengthToObjectBoundingBox
                (length, attr, uctx);
        case USER_SPACE_ON_USE:
            return UnitProcessor.svgOtherLengthToUserSpace(length, attr, uctx);
        default:
            throw new IllegalArgumentException("Invalid unit type");
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // <mask> region
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the mask region according to the x, y, width, height,
     * and maskUnits attributes.
     *
     * @param maskElement the mask element that defines the various attributes
     * @param maskedElement the element referencing the mask
     * @param maskedNode the graphics node to mask (objectBoundingBox)
     * @param ctx the bridge context
     */
    public static Rectangle2D convertMaskRegion(Element maskElement,
                                                Element maskedElement,
                                                GraphicsNode maskedNode,
                                                BridgeContext ctx) {

        // 'x' attribute - default is -10%
        String xStr = maskElement.getAttributeNS(null, SVG_X_ATTRIBUTE);
        if (xStr.length() == 0) {
            xStr = SVG_MASK_X_DEFAULT_VALUE;
        }
        // 'y' attribute - default is -10%
        String yStr = maskElement.getAttributeNS(null, SVG_Y_ATTRIBUTE);
        if (yStr.length() == 0) {
            yStr = SVG_MASK_Y_DEFAULT_VALUE;
        }
        // 'width' attribute - default is 120%
        String wStr = maskElement.getAttributeNS(null, SVG_WIDTH_ATTRIBUTE);
        if (wStr.length() == 0) {
            wStr = SVG_MASK_WIDTH_DEFAULT_VALUE;
        }
        // 'height' attribute - default is 120%
        String hStr = maskElement.getAttributeNS(null, SVG_HEIGHT_ATTRIBUTE);
        if (hStr.length() == 0) {
            hStr = SVG_MASK_HEIGHT_DEFAULT_VALUE;
        }
        // 'maskUnits' attribute - default is 'objectBoundingBox'
        short unitsType;
        String units =
            maskElement.getAttributeNS(null, SVG_MASK_UNITS_ATTRIBUTE);
        if (units.length() == 0) {
            unitsType = OBJECT_BOUNDING_BOX;
        } else {
            unitsType = parseCoordinateSystem
                (maskElement, SVG_MASK_UNITS_ATTRIBUTE, units, ctx);
        }

        // resolve units in the (referenced) maskedElement's coordinate system
        UnitProcessor.Context uctx
            = UnitProcessor.createContext(ctx, maskedElement);

        return convertRegion(xStr,
                             yStr,
                             wStr,
                             hStr,
                             unitsType,
                             maskedNode,
                             uctx);
    }

    /////////////////////////////////////////////////////////////////////////
    // <pattern> region
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns the pattern region according to the x, y, width, height,
     * and patternUnits attributes.
     *
     * @param patternElement the pattern element that defines the attributes
     * @param paintedElement the element referencing the pattern
     * @param paintedNode the graphics node to paint (objectBoundingBox)
     * @param ctx the bridge context
     */
    public static Rectangle2D convertPatternRegion(Element patternElement,
                                                   Element paintedElement,
                                                   GraphicsNode paintedNode,
                                                   BridgeContext ctx) {

        // 'x' attribute - default is 0%
        String xStr = getChainableAttributeNS
            (patternElement, null, SVG_X_ATTRIBUTE, ctx);
        if (xStr.length() == 0) {
            xStr = SVG_PATTERN_X_DEFAULT_VALUE;
        }
        // 'y' attribute - default is 0%
        String yStr = getChainableAttributeNS
            (patternElement, null, SVG_Y_ATTRIBUTE, ctx);
        if (yStr.length() == 0) {
            yStr = SVG_PATTERN_Y_DEFAULT_VALUE;
        }
        // 'width' attribute - required
        String wStr = getChainableAttributeNS
            (patternElement, null, SVG_WIDTH_ATTRIBUTE, ctx);
        if (wStr.length() == 0) {
            throw new BridgeException
                (ctx, patternElement, ERR_ATTRIBUTE_MISSING,
                 new Object[] {SVG_WIDTH_ATTRIBUTE});
        }
        // 'height' attribute - required
        String hStr = getChainableAttributeNS
            (patternElement, null, SVG_HEIGHT_ATTRIBUTE, ctx);
        if (hStr.length() == 0) {
            throw new BridgeException
                (ctx, patternElement, ERR_ATTRIBUTE_MISSING,
                 new Object[] {SVG_HEIGHT_ATTRIBUTE});
        }
        // 'patternUnits' attribute - default is 'objectBoundingBox'
        short unitsType;
        String units = getChainableAttributeNS
            (patternElement, null, SVG_PATTERN_UNITS_ATTRIBUTE, ctx);
        if (units.length() == 0) {
            unitsType = OBJECT_BOUNDING_BOX;
        } else {
            unitsType = parseCoordinateSystem
                (patternElement, SVG_PATTERN_UNITS_ATTRIBUTE, units, ctx);
        }

        // resolve units in the (referenced) paintedElement's coordinate system
        UnitProcessor.Context uctx
            = UnitProcessor.createContext(ctx, paintedElement);

        return convertRegion(xStr,
                             yStr,
                             wStr,
                             hStr,
                             unitsType,
                             paintedNode,
                             uctx);
    }

    /////////////////////////////////////////////////////////////////////////
    // <filter> and filter primitive
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns an array of 2 float numbers that describes the filter
     * resolution of the specified filter element.
     *
     * @param filterElement the filter element
     * @param ctx the bridge context
     */
    public static
        float [] convertFilterRes(Element filterElement, BridgeContext ctx) {

        float [] filterRes = new float[2];
        String s = getChainableAttributeNS
            (filterElement, null, SVG_FILTER_RES_ATTRIBUTE, ctx);
        Float [] vals = convertSVGNumberOptionalNumber
            (filterElement, SVG_FILTER_RES_ATTRIBUTE, s, ctx);

        if (filterRes[0] < 0 || filterRes[1] < 0) {
            throw new BridgeException
                (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {SVG_FILTER_RES_ATTRIBUTE, s});
        }

        if (vals[0] == null)
            filterRes[0] = -1;
        else {
            filterRes[0] = vals[0].floatValue();
            if (filterRes[0] < 0)
                throw new BridgeException
                    (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {SVG_FILTER_RES_ATTRIBUTE, s});
        }

        if (vals[1] == null)
            filterRes[1] = filterRes[0];
        else {
            filterRes[1] = vals[1].floatValue();
            if (filterRes[1] < 0)
                throw new BridgeException
                    (ctx, filterElement, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {SVG_FILTER_RES_ATTRIBUTE, s});
        }
        return filterRes;
    }

    /**
     * This function parses attrValue for a number followed by an optional
     * second Number. It always returns an array of two Floats.  If either
     * or both values are not provided the entries are set to null
     */
    public static Float[] convertSVGNumberOptionalNumber(Element elem,
                                                         String attrName,
                                                         String attrValue,
                                                         BridgeContext ctx) {

        Float[] ret = new Float[2];
        if (attrValue.length() == 0)
            return ret;

        try {
            StringTokenizer tokens = new StringTokenizer(attrValue, " ");
            ret[0] = new Float(Float.parseFloat(tokens.nextToken()));
            if (tokens.hasMoreTokens()) {
                ret[1] = new Float(Float.parseFloat(tokens.nextToken()));
            }

            if (tokens.hasMoreTokens()) {
                throw new BridgeException
                    (ctx, elem, ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] {attrName, attrValue});
            }
        } catch (NumberFormatException nfEx ) {
            throw new BridgeException
                (ctx, elem, nfEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] {attrName, attrValue, nfEx });
        }
        return ret;
    }


   /**
    * Returns the filter region according to the x, y, width, height,
    * dx, dy, dw, dh and filterUnits attributes.
    *
    * @param filterElement the filter element that defines the attributes
    * @param filteredElement the element referencing the filter
    * @param filteredNode the graphics node to filter (objectBoundingBox)
    * @param ctx the bridge context
    */
   public static
       Rectangle2D convertFilterChainRegion(Element filterElement,
                                            Element filteredElement,
                                            GraphicsNode filteredNode,
                                            BridgeContext ctx) {

       // 'x' attribute - default is -10%
       String xStr = getChainableAttributeNS
           (filterElement, null, SVG_X_ATTRIBUTE, ctx);
       if (xStr.length() == 0) {
           xStr = SVG_FILTER_X_DEFAULT_VALUE;
       }
       // 'y' attribute - default is -10%
       String yStr = getChainableAttributeNS
           (filterElement, null, SVG_Y_ATTRIBUTE, ctx);
       if (yStr.length() == 0) {
           yStr = SVG_FILTER_Y_DEFAULT_VALUE;
       }
       // 'width' attribute - default is 120%
       String wStr = getChainableAttributeNS
           (filterElement, null, SVG_WIDTH_ATTRIBUTE, ctx);
       if (wStr.length() == 0) {
           wStr = SVG_FILTER_WIDTH_DEFAULT_VALUE;
       }
       // 'height' attribute - default is 120%
       String hStr = getChainableAttributeNS
           (filterElement, null, SVG_HEIGHT_ATTRIBUTE, ctx);
       if (hStr.length() == 0) {
           hStr = SVG_FILTER_HEIGHT_DEFAULT_VALUE;
       }
       // 'filterUnits' attribute - default is 'objectBoundingBox'
       short unitsType;
       String units = getChainableAttributeNS
           (filterElement, null, SVG_FILTER_UNITS_ATTRIBUTE, ctx);
       if (units.length() == 0) {
           unitsType = OBJECT_BOUNDING_BOX;
       } else {
           unitsType = parseCoordinateSystem
               (filterElement, SVG_FILTER_UNITS_ATTRIBUTE, units, ctx);
       }

       // The last paragraph of section 7.11 in SVG 1.1 states that objects
       // with zero width or height bounding boxes that use filters with
       // filterUnits="objectBoundingBox" must not use the filter.
       // TODO: Uncomment this after confirming this is the desired behaviour.
       /*AbstractGraphicsNodeBridge bridge =
           (AbstractGraphicsNodeBridge) ctx.getSVGContext(filteredElement);
       if (unitsType == OBJECT_BOUNDING_BOX && bridge != null) {
           Rectangle2D bbox = bridge.getBBox();
           if (bbox != null && bbox.getWidth() == 0 || bbox.getHeight() == 0) {
               return null;
           }
       }*/

       // resolve units in the (referenced) filteredElement's
       // coordinate system
       UnitProcessor.Context uctx
           = UnitProcessor.createContext(ctx, filteredElement);

       Rectangle2D region = convertRegion(xStr,
                                          yStr,
                                          wStr,
                                          hStr,
                                          unitsType,
                                          filteredNode,
                                          uctx);
       //
       // Account for region padding
       //
       units = getChainableAttributeNS
           (filterElement, null,
            SVG12Constants.SVG_FILTER_MARGINS_UNITS_ATTRIBUTE, ctx);
       if (units.length() == 0) {
           // Default to user space on use for margins, not objectBoundingBox
           unitsType = USER_SPACE_ON_USE;
       } else {
           unitsType = parseCoordinateSystem
               (filterElement,
                SVG12Constants.SVG_FILTER_MARGINS_UNITS_ATTRIBUTE, units, ctx);
       }

       // 'batik:dx' attribute - default is 0
       String dxStr = filterElement.getAttributeNS(null,
                                                   SVG12Constants.SVG_MX_ATRIBUTE);
       if (dxStr.length() == 0) {
           dxStr = SVG12Constants.SVG_FILTER_MX_DEFAULT_VALUE;
       }
       // 'batik:dy' attribute - default is 0
       String dyStr = filterElement.getAttributeNS(null, SVG12Constants.SVG_MY_ATRIBUTE);
       if (dyStr.length() == 0) {
           dyStr = SVG12Constants.SVG_FILTER_MY_DEFAULT_VALUE;
       }
       // 'batik:dw' attribute - default is 0
       String dwStr = filterElement.getAttributeNS(null, SVG12Constants.SVG_MW_ATRIBUTE);
       if (dwStr.length() == 0) {
           dwStr = SVG12Constants.SVG_FILTER_MW_DEFAULT_VALUE;
       }
       // 'batik:dh' attribute - default is 0
       String dhStr = filterElement.getAttributeNS(null, SVG12Constants.SVG_MH_ATRIBUTE);
       if (dhStr.length() == 0) {
           dhStr = SVG12Constants.SVG_FILTER_MH_DEFAULT_VALUE;
       }

       return extendRegion(dxStr,
                           dyStr,
                           dwStr,
                           dhStr,
                           unitsType,
                           filteredNode,
                           region,
                           uctx);
   }

   /**
    * Returns a rectangle that represents the region extended by the
    * specified differential coordinates.
    *
    * @param dxStr the differential x coordinate of the region
    * @param dyStr the differential y coordinate of the region
    * @param dwStr the differential width of the region
    * @param dhStr the differential height of the region
    * @param unitsType specifies whether the values are in userSpaceOnUse
    *        or objectBoundingBox space
    * @param region the region to extend
    * @param uctx the unit processor context (needed for userSpaceOnUse)
    */
    protected static Rectangle2D extendRegion(String dxStr,
                                              String dyStr,
                                              String dwStr,
                                              String dhStr,
                                              short unitsType,
                                              GraphicsNode filteredNode,
                                              Rectangle2D region,
                                              UnitProcessor.Context uctx) {

        float dx,dy,dw,dh;
        switch (unitsType) {
        case USER_SPACE_ON_USE:
            dx = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (dxStr, SVG12Constants.SVG_MX_ATRIBUTE, uctx);
            dy = UnitProcessor.svgVerticalCoordinateToUserSpace
                (dyStr, SVG12Constants.SVG_MY_ATRIBUTE, uctx);
            dw = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (dwStr, SVG12Constants.SVG_MW_ATRIBUTE, uctx);
            dh = UnitProcessor.svgVerticalCoordinateToUserSpace
                (dhStr, SVG12Constants.SVG_MH_ATRIBUTE, uctx);
            break;
        case OBJECT_BOUNDING_BOX:
            Rectangle2D bounds = filteredNode.getGeometryBounds();
            if (bounds == null) {
                dx = dy = dw = dh = 0;
            } else {
                dx = UnitProcessor.svgHorizontalCoordinateToObjectBoundingBox
                    (dxStr, SVG12Constants.SVG_MX_ATRIBUTE, uctx);
                dx *= bounds.getWidth();

                dy = UnitProcessor.svgVerticalCoordinateToObjectBoundingBox
                    (dyStr, SVG12Constants.SVG_MY_ATRIBUTE, uctx);
                dy *= bounds.getHeight();

                dw = UnitProcessor.svgHorizontalCoordinateToObjectBoundingBox
                    (dwStr, SVG12Constants.SVG_MW_ATRIBUTE, uctx);
                dw *= bounds.getWidth();

                dh = UnitProcessor.svgVerticalCoordinateToObjectBoundingBox
                    (dhStr, SVG12Constants.SVG_MH_ATRIBUTE, uctx);
                dh *= bounds.getHeight();
            }
            break;
        default:
            throw new IllegalArgumentException("Invalid unit type");
        }

        region.setRect(region.getX() + dx,
                       region.getY() + dy,
                       region.getWidth() + dw,
                       region.getHeight() + dh);

        return region;
    }


    public static Rectangle2D
        getBaseFilterPrimitiveRegion(Element filterPrimitiveElement,
                                     Element filteredElement,
                                     GraphicsNode filteredNode,
                                     Rectangle2D defaultRegion,
                                     BridgeContext ctx) {
        String s;

        // resolve units in the (referenced) filteredElement's
        // coordinate system
        UnitProcessor.Context uctx;
        uctx = UnitProcessor.createContext(ctx, filteredElement);

        // 'x' attribute - default is defaultRegion.getX()
        double x = defaultRegion.getX();
        s = filterPrimitiveElement.getAttributeNS(null, SVG_X_ATTRIBUTE);
        if (s.length() != 0) {
            x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (s, SVG_X_ATTRIBUTE, uctx);
        }

        // 'y' attribute - default is defaultRegion.getY()
        double y = defaultRegion.getY();
        s = filterPrimitiveElement.getAttributeNS(null, SVG_Y_ATTRIBUTE);
        if (s.length() != 0) {
            y = UnitProcessor.svgVerticalCoordinateToUserSpace
                (s, SVG_Y_ATTRIBUTE, uctx);
        }

        // 'width' attribute - default is defaultRegion.getWidth()
        double w = defaultRegion.getWidth();
        s = filterPrimitiveElement.getAttributeNS(null, SVG_WIDTH_ATTRIBUTE);
        if (s.length() != 0) {
            w = UnitProcessor.svgHorizontalLengthToUserSpace
                (s, SVG_WIDTH_ATTRIBUTE, uctx);
        }

        // 'height' attribute - default is defaultRegion.getHeight()
        double h = defaultRegion.getHeight();
        s = filterPrimitiveElement.getAttributeNS(null, SVG_HEIGHT_ATTRIBUTE);
        if (s.length() != 0) {
            h = UnitProcessor.svgVerticalLengthToUserSpace
                (s, SVG_HEIGHT_ATTRIBUTE, uctx);
        }

        // NOTE: it may be that dx/dy/dw/dh should be applied here
        //       but since this is mostly aimed at feImage I am
        //       unsure that it is really needed.
        return new Rectangle2D.Double(x, y, w, h);
    }

    /**
     * Returns the filter primitive region according to the x, y,
     * width, height, and filterUnits attributes. Processing the
     * element as the top one in the filter chain.
     *
     * @param filterPrimitiveElement the filter primitive element
     * @param filterElement the filter element
     * @param filteredElement the element referencing the filter
     * @param filteredNode the graphics node to use (objectBoundingBox)
     * @param defaultRegion the default region to filter
     * @param filterRegion the filter chain region
     * @param ctx the bridge context
     */
    public static Rectangle2D
        convertFilterPrimitiveRegion(Element filterPrimitiveElement,
                                     Element filterElement,
                                     Element filteredElement,
                                     GraphicsNode filteredNode,
                                     Rectangle2D defaultRegion,
                                     Rectangle2D filterRegion,
                                     BridgeContext ctx) {

        // 'primitiveUnits' - default is userSpaceOnUse
        String units = "";
        if (filterElement != null) {
            units = getChainableAttributeNS(filterElement,
                                            null,
                                            SVG_PRIMITIVE_UNITS_ATTRIBUTE,
                                            ctx);
        }
        short unitsType;
        if (units.length() == 0) {
            unitsType = USER_SPACE_ON_USE;
        } else {
            unitsType = parseCoordinateSystem
                (filterElement, SVG_FILTER_UNITS_ATTRIBUTE, units, ctx);
        }

        String xStr = "", yStr = "", wStr = "", hStr = "";

        if (filterPrimitiveElement != null) {
            // 'x' attribute - default is defaultRegion.getX()
            xStr = filterPrimitiveElement.getAttributeNS(null,
                                                         SVG_X_ATTRIBUTE);

            // 'y' attribute - default is defaultRegion.getY()
            yStr = filterPrimitiveElement.getAttributeNS(null,
                                                         SVG_Y_ATTRIBUTE);

            // 'width' attribute - default is defaultRegion.getWidth()
            wStr = filterPrimitiveElement.getAttributeNS(null,
                                                         SVG_WIDTH_ATTRIBUTE);

            // 'height' attribute - default is defaultRegion.getHeight()
            hStr = filterPrimitiveElement.getAttributeNS(null,
                                                         SVG_HEIGHT_ATTRIBUTE);
        }

        double x = defaultRegion.getX();
        double y = defaultRegion.getY();
        double w = defaultRegion.getWidth();
        double h = defaultRegion.getHeight();

        // resolve units in the (referenced) filteredElement's coordinate system
        UnitProcessor.Context uctx
            = UnitProcessor.createContext(ctx, filteredElement);

        switch (unitsType) {
        case OBJECT_BOUNDING_BOX:
            Rectangle2D bounds = filteredNode.getGeometryBounds();
            if (bounds != null) {
                if (xStr.length() != 0) {
                    x = UnitProcessor.svgHorizontalCoordinateToObjectBoundingBox
                        (xStr, SVG_X_ATTRIBUTE, uctx);
                    x = bounds.getX() + x*bounds.getWidth();
                }
                if (yStr.length() != 0) {
                    y = UnitProcessor.svgVerticalCoordinateToObjectBoundingBox
                        (yStr, SVG_Y_ATTRIBUTE, uctx);
                    y = bounds.getY() + y*bounds.getHeight();
                }
                if (wStr.length() != 0) {
                    w = UnitProcessor.svgHorizontalLengthToObjectBoundingBox
                        (wStr, SVG_WIDTH_ATTRIBUTE, uctx);
                    w *= bounds.getWidth();
                }
                if (hStr.length() != 0) {
                    h = UnitProcessor.svgVerticalLengthToObjectBoundingBox
                        (hStr, SVG_HEIGHT_ATTRIBUTE, uctx);
                    h *= bounds.getHeight();
                }
            }
            break;
        case USER_SPACE_ON_USE:
            if (xStr.length() != 0) {
                x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                    (xStr, SVG_X_ATTRIBUTE, uctx);
            }
            if (yStr.length() != 0) {
                y = UnitProcessor.svgVerticalCoordinateToUserSpace
                    (yStr, SVG_Y_ATTRIBUTE, uctx);
            }
            if (wStr.length() != 0) {
                w = UnitProcessor.svgHorizontalLengthToUserSpace
                    (wStr, SVG_WIDTH_ATTRIBUTE, uctx);
            }
            if (hStr.length() != 0) {
                h = UnitProcessor.svgVerticalLengthToUserSpace
                    (hStr, SVG_HEIGHT_ATTRIBUTE, uctx);
            }
            break;
        default:
            throw new Error("invalid unitsType:" + unitsType); // can't be reached
        }

        Rectangle2D region = new Rectangle2D.Double(x, y, w, h);

        // Now, extend filter primitive region with dx/dy/dw/dh
        // settings (Batik extension). The dx/dy/dw/dh padding is
        // *always* in userSpaceOnUse space.

        units = "";
        if (filterElement != null) {
            units = getChainableAttributeNS
                (filterElement, null,
                 SVG12Constants.SVG_FILTER_PRIMITIVE_MARGINS_UNITS_ATTRIBUTE,
                 ctx);
        }

        if (units.length() == 0) {
            unitsType = USER_SPACE_ON_USE;
        } else {
            unitsType = parseCoordinateSystem
                (filterElement,
                 SVG12Constants.SVG_FILTER_PRIMITIVE_MARGINS_UNITS_ATTRIBUTE,
                 units, ctx);
        }

        String dxStr = "", dyStr = "", dwStr = "", dhStr = "";

        if (filterPrimitiveElement != null) {
            // 'batik:dx' attribute - default is 0
            dxStr = filterPrimitiveElement.getAttributeNS
                (null, SVG12Constants.SVG_MX_ATRIBUTE);

            // 'batik:dy' attribute - default is 0
            dyStr = filterPrimitiveElement.getAttributeNS
                (null, SVG12Constants.SVG_MY_ATRIBUTE);

            // 'batik:dw' attribute - default is 0
            dwStr = filterPrimitiveElement.getAttributeNS
                (null, SVG12Constants.SVG_MW_ATRIBUTE);

            // 'batik:dh' attribute - default is 0
            dhStr = filterPrimitiveElement.getAttributeNS
                (null, SVG12Constants.SVG_MH_ATRIBUTE);
        }
        if (dxStr.length() == 0) {
            dxStr = SVG12Constants.SVG_FILTER_MX_DEFAULT_VALUE;
        }
        if (dyStr.length() == 0) {
            dyStr = SVG12Constants.SVG_FILTER_MY_DEFAULT_VALUE;
        }
        if (dwStr.length() == 0) {
            dwStr = SVG12Constants.SVG_FILTER_MW_DEFAULT_VALUE;
        }
        if (dhStr.length() == 0) {
            dhStr = SVG12Constants.SVG_FILTER_MH_DEFAULT_VALUE;
        }

        region = extendRegion(dxStr,
                              dyStr,
                              dwStr,
                              dhStr,
                              unitsType,
                              filteredNode,
                              region,
                              uctx);

        Rectangle2D.intersect(region, filterRegion, region);

        return region;
    }

    /**
     * Returns the filter primitive region according to the x, y,
     * width, height, and filterUnits attributes. Processing the
     * element as the top one in the filter chain.
     *
     * @param filterPrimitiveElement the filter primitive element
     * @param filteredElement the element referencing the filter
     * @param filteredNode the graphics node to use (objectBoundingBox)
     * @param defaultRegion the default region to filter
     * @param filterRegion the filter chain region
     * @param ctx the bridge context
     */
    public static Rectangle2D
        convertFilterPrimitiveRegion(Element filterPrimitiveElement,
                                     Element filteredElement,
                                     GraphicsNode filteredNode,
                                     Rectangle2D defaultRegion,
                                     Rectangle2D filterRegion,
                                     BridgeContext ctx) {

        Node parentNode = filterPrimitiveElement.getParentNode();
        Element filterElement = null;
        if (parentNode != null &&
                parentNode.getNodeType() == Node.ELEMENT_NODE) {
            filterElement = (Element) parentNode;
        }
        return convertFilterPrimitiveRegion(filterPrimitiveElement,
                                            filterElement,
                                            filteredElement,
                                            filteredNode,
                                            defaultRegion,
                                            filterRegion,
                                            ctx);
    }

    /////////////////////////////////////////////////////////////////////////
    // region convenient methods
    /////////////////////////////////////////////////////////////////////////


    /** The userSpaceOnUse coordinate system constants. */
    public static final short USER_SPACE_ON_USE = 1;

    /** The objectBoundingBox coordinate system constants. */
    public static final short OBJECT_BOUNDING_BOX = 2;

    /** The strokeWidth coordinate system constants. */
    public static final short STROKE_WIDTH = 3;

    /**
     * Parses the specified coordinate system defined by the specified element.
     *
     * @param e the element that defines the coordinate system
     * @param attr the attribute which contains the coordinate system
     * @param coordinateSystem the coordinate system to parse
     * @param ctx the BridgeContext to use for error information
     * @return OBJECT_BOUNDING_BOX | USER_SPACE_ON_USE
     */
    public static short parseCoordinateSystem(Element e,
                                              String attr,
                                              String coordinateSystem,
                                              BridgeContext ctx) {
        if (SVG_USER_SPACE_ON_USE_VALUE.equals(coordinateSystem)) {
            return USER_SPACE_ON_USE;
        } else if (SVG_OBJECT_BOUNDING_BOX_VALUE.equals(coordinateSystem)) {
            return OBJECT_BOUNDING_BOX;
        } else {
            throw new BridgeException(ctx, e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                      new Object[] {attr, coordinateSystem});
        }
    }

    /**
     * Parses the specified coordinate system defined by the specified
     * marker element.
     *
     * @param e the element that defines the coordinate system
     * @param attr the attribute which contains the coordinate system
     * @param coordinateSystem the coordinate system to parse
     * @param ctx the BridgeContext to use for error information
     * @return STROKE_WIDTH | USER_SPACE_ON_USE
     */
    public static short parseMarkerCoordinateSystem(Element e,
                                                    String attr,
                                                    String coordinateSystem,
                                                    BridgeContext ctx) {
        if (SVG_USER_SPACE_ON_USE_VALUE.equals(coordinateSystem)) {
            return USER_SPACE_ON_USE;
        } else if (SVG_STROKE_WIDTH_VALUE.equals(coordinateSystem)) {
            return STROKE_WIDTH;
        } else {
            throw new BridgeException(ctx, e, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                      new Object[] {attr, coordinateSystem});
        }
    }

    /**
     * Returns a rectangle that represents the region defined by the
     * specified coordinates.
     *
     * @param xStr the x coordinate of the region
     * @param yStr the y coordinate of the region
     * @param wStr the width of the region
     * @param hStr the height of the region
     * @param targetNode the graphics node (needed for objectBoundingBox)
     * @param uctx the unit processor context (needed for userSpaceOnUse)
     */
    protected static Rectangle2D convertRegion(String xStr,
                                               String yStr,
                                               String wStr,
                                               String hStr,
                                               short unitsType,
                                               GraphicsNode targetNode,
                                               UnitProcessor.Context uctx) {

        // construct the mask region in the appropriate coordinate system
        double x, y, w, h;
        switch (unitsType) {
        case OBJECT_BOUNDING_BOX:
            x = UnitProcessor.svgHorizontalCoordinateToObjectBoundingBox
                (xStr, SVG_X_ATTRIBUTE, uctx);
            y = UnitProcessor.svgVerticalCoordinateToObjectBoundingBox
                (yStr, SVG_Y_ATTRIBUTE, uctx);
            w = UnitProcessor.svgHorizontalLengthToObjectBoundingBox
                (wStr, SVG_WIDTH_ATTRIBUTE, uctx);
            h = UnitProcessor.svgVerticalLengthToObjectBoundingBox
                (hStr, SVG_HEIGHT_ATTRIBUTE, uctx);

            Rectangle2D bounds = targetNode.getGeometryBounds();
            if (bounds != null ) {
                x = bounds.getX() + x*bounds.getWidth();
                y = bounds.getY() + y*bounds.getHeight();
                w *= bounds.getWidth();
                h *= bounds.getHeight();
            } else {
                x = y = w = h = 0;
            }
            break;
        case USER_SPACE_ON_USE:
            x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (xStr, SVG_X_ATTRIBUTE, uctx);
            y = UnitProcessor.svgVerticalCoordinateToUserSpace
                (yStr, SVG_Y_ATTRIBUTE, uctx);
            w = UnitProcessor.svgHorizontalLengthToUserSpace
                (wStr, SVG_WIDTH_ATTRIBUTE, uctx);
            h = UnitProcessor.svgVerticalLengthToUserSpace
                (hStr, SVG_HEIGHT_ATTRIBUTE, uctx);
            break;
        default:
            throw new Error("invalid unitsType:" + unitsType ); // can't be reached
        }
        return new Rectangle2D.Double(x, y, w, h);
    }

    /////////////////////////////////////////////////////////////////////////
    // coordinate system and transformation support methods
    /////////////////////////////////////////////////////////////////////////

    /**
     * Returns an AffineTransform according to the specified parameters.
     *
     * @param e the element that defines the transform
     * @param attr the name of the attribute that represents the transform
     * @param transform the transform to parse
     * @param ctx the BridgeContext to use for error information
     */
    public static AffineTransform convertTransform(Element e,
                                                   String attr,
                                                   String transform,
                                                   BridgeContext ctx) {
        try {
            return AWTTransformProducer.createAffineTransform(transform);
        } catch (ParseException pEx) {
            throw new BridgeException(ctx, e, pEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                                      new Object[] {attr, transform, pEx });
        }
    }

    /**
     * Returns an AffineTransform to move to the objectBoundingBox
     * coordinate system.
     *
     * @param Tx the original transformation
     * @param node the graphics node that defines the coordinate
     *             system to move into
     */
    public static AffineTransform toObjectBBox(AffineTransform Tx,
                                               GraphicsNode node) {

        AffineTransform Mx = new AffineTransform();
        Rectangle2D bounds = node.getGeometryBounds();
        if (bounds != null) {
            Mx.translate(bounds.getX(), bounds.getY());
            Mx.scale(bounds.getWidth(), bounds.getHeight());
        }
        Mx.concatenate(Tx);
        return Mx;
    }

    /**
     * Returns the specified a Rectangle2D move to the objectBoundingBox
     * coordinate system of the specified graphics node.
     *
     * @param r the original Rectangle2D
     * @param node the graphics node that defines the coordinate
     *             system to move into
     */
    public static Rectangle2D toObjectBBox(Rectangle2D r,
                                           GraphicsNode node) {

        Rectangle2D bounds = node.getGeometryBounds();
        if (bounds != null) {
            return new Rectangle2D.Double
                (bounds.getX() + r.getX()*bounds.getWidth(),
                 bounds.getY() + r.getY()*bounds.getHeight(),
                 r.getWidth() * bounds.getWidth(),
                 r.getHeight() * bounds.getHeight());
        } else {
            return new Rectangle2D.Double();
        }
    }

    /**
     * Returns the value of the 'snapshotTime' attribute on the specified
     * element as a float, or <code>0f</code> if the attribute is missing
     * or given as <code>"none"</code>.
     *
     * @param e the element from which to retrieve the 'snapshotTime' attribute
     * @param ctx the BridgeContext to use for error information
     */
    public static float convertSnapshotTime(Element e, BridgeContext ctx) {
        if (!e.hasAttributeNS(null, SVG_SNAPSHOT_TIME_ATTRIBUTE)) {
            return 0f;
        }
        String t = e.getAttributeNS(null, SVG_SNAPSHOT_TIME_ATTRIBUTE);
        if (t.equals(SVG_NONE_VALUE)) {
            return 0f;
        }

        class Handler implements ClockHandler {
            float time;
            public void clockValue(float t) {
                time = t;
            }
        }
        ClockParser p = new ClockParser(false);
        Handler h = new Handler();
        p.setClockHandler(h);
        try {
            p.parse(t);
        } catch (ParseException pEx ) {
            throw new BridgeException
                (null, e, pEx, ERR_ATTRIBUTE_VALUE_MALFORMED,
                 new Object[] { SVG_SNAPSHOT_TIME_ATTRIBUTE, t, pEx });
        }
        return h.time;
    }
}
