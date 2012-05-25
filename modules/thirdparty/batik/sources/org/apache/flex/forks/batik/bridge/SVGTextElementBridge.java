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

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Composite;
import java.awt.Paint;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.Stroke;
import java.awt.font.TextAttribute;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;
import java.text.AttributedString;
import java.text.AttributedCharacterIterator.Attribute;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.Vector;
import java.util.WeakHashMap;

import org.apache.flex.forks.batik.css.engine.CSSEngineEvent;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.value.ListValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.dom.svg.SVGContext;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;
import org.apache.flex.forks.batik.dom.svg.SVGTextContent;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.TextNode;
import org.apache.flex.forks.batik.gvt.font.GVTFontFamily;
import org.apache.flex.forks.batik.gvt.font.GVTGlyphMetrics;
import org.apache.flex.forks.batik.gvt.font.GVTGlyphVector;
import org.apache.flex.forks.batik.gvt.renderer.StrokingTextPainter;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.Mark;
import org.apache.flex.forks.batik.gvt.text.TextHit;
import org.apache.flex.forks.batik.gvt.text.TextPaintInfo;
import org.apache.flex.forks.batik.gvt.text.TextPath;
import org.apache.flex.forks.batik.gvt.text.TextSpanLayout;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.css.CSSValue;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for the &lt;text> element.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: SVGTextElementBridge.java,v 1.106 2005/03/27 08:58:30 cam Exp $
 */
public class SVGTextElementBridge extends AbstractGraphicsNodeBridge 
    implements SVGTextContent {

    protected final static Integer ZERO = new Integer(0);

    public static final 
        AttributedCharacterIterator.Attribute TEXT_COMPOUND_DELIMITER =
        GVTAttributedCharacterIterator.TextAttribute.TEXT_COMPOUND_DELIMITER;

    public static final AttributedCharacterIterator.Attribute PAINT_INFO =
         GVTAttributedCharacterIterator.TextAttribute.PAINT_INFO;

    public static final 
        AttributedCharacterIterator.Attribute ALT_GLYPH_HANDLER =
        GVTAttributedCharacterIterator.TextAttribute.ALT_GLYPH_HANDLER;
        

    protected AttributedString laidoutText;

    // This is used to track the TextPainterInfo for each element
    // in this text element.
    protected WeakHashMap elemTPI = new WeakHashMap();

    // This s true if any of the spans of this text element
    // use a 'complex' SVG font (meaning the font uses more
    // and just the 'd' attribute on the glyph element.
    // In this case we need to recreate the font when ever
    // CSS attributes change on the text - so we can capture
    // the effects of CSS inheritence.
    protected boolean usingComplexSVGFont = false;

    /**
     * Constructs a new bridge for the &lt;text> element.
     */
    public SVGTextElementBridge() {}

    /**
     * Returns 'text'.
     */
    public String getLocalName() {
        return SVG_TEXT_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGTextElementBridge();
    }

    /**
     * Creates a <tt>GraphicsNode</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @return a graphics node that represents the specified element
     */
    public GraphicsNode createGraphicsNode(BridgeContext ctx, Element e) {
        TextNode node = (TextNode)super.createGraphicsNode(ctx, e);
        if (node == null)
            return null;

        // specify the text painter to use
        if (ctx.getTextPainter() != null)
            node.setTextPainter(ctx.getTextPainter());

        // 'text-rendering' and 'color-rendering'
        RenderingHints hints = null;
        hints = CSSUtilities.convertColorRendering(e, hints);
        hints = CSSUtilities.convertTextRendering (e, hints);
        if (hints != null)
            node.setRenderingHints(hints);

        node.setLocation(getLocation(ctx, e));

        return node;
    }

    /**
     * Creates the GraphicsNode depending on the GraphicsNodeBridge
     * implementation.
     */
    protected GraphicsNode instantiateGraphicsNode() {
        return new TextNode();
    }

    /**
     * Returns the text node location according to the 'x' and 'y'
     * attributes of the specified text element.
     *
     * @param ctx the bridge context to use
     * @param e the text element
     */
    protected Point2D getLocation(BridgeContext ctx, Element e) {
        UnitProcessor.Context uctx = UnitProcessor.createContext(ctx, e);

        // 'x' attribute - default is 0
        String s = e.getAttributeNS(null, SVG_X_ATTRIBUTE);
        float x = 0;
        if (s.length() != 0) {
            StringTokenizer st = new StringTokenizer(s, ", ", false);
            x = UnitProcessor.svgHorizontalCoordinateToUserSpace
                (st.nextToken(), SVG_X_ATTRIBUTE, uctx);
        }

        // 'y' attribute - default is 0
        s = e.getAttributeNS(null, SVG_Y_ATTRIBUTE);
        float y = 0;
        if (s.length() != 0) {
            StringTokenizer st = new StringTokenizer(s, ", ", false);
            y = UnitProcessor.svgVerticalCoordinateToUserSpace
                (st.nextToken(), SVG_Y_ATTRIBUTE, uctx);
        }

        return new Point2D.Float(x, y);
    }

    protected boolean isTextElement(Element e) {
        if (!SVG_NAMESPACE_URI.equals(e.getNamespaceURI()))
            return false;
        String nodeName = e.getLocalName();
        return (nodeName.equals(SVG_TEXT_TAG) ||
                nodeName.equals(SVG_TSPAN_TAG) ||
                nodeName.equals(SVG_ALT_GLYPH_TAG) ||
                nodeName.equals(SVG_A_TAG) ||
                nodeName.equals(SVG_TEXT_PATH_TAG) ||
                nodeName.equals(SVG_TREF_TAG));
    }

    protected boolean isTextChild(Element e) {
        if (!SVG_NAMESPACE_URI.equals(e.getNamespaceURI()))
            return false;
        String nodeName = e.getLocalName();
        return (nodeName.equals(SVG_TSPAN_TAG) ||
                nodeName.equals(SVG_ALT_GLYPH_TAG) ||
                nodeName.equals(SVG_A_TAG) ||
                nodeName.equals(SVG_TEXT_PATH_TAG) ||
                nodeName.equals(SVG_TREF_TAG));
    }

    /**
     * Builds using the specified BridgeContext and element, the
     * specified graphics node.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @param node the graphics node to build
     */
    public void buildGraphicsNode(BridgeContext ctx,
                                  Element e,
                                  GraphicsNode node) {
        e.normalize();
        computeLaidoutText(ctx, e, node);

        //
        // DO NOT CALL super, 'opacity' is handle during addPaintAttributes()
        //
        // 'opacity'
        node.setComposite(CSSUtilities.convertOpacity(e));
        // 'filter'
        node.setFilter(CSSUtilities.convertFilter(e, node, ctx));
        // 'mask'
        node.setMask(CSSUtilities.convertMask(e, node, ctx));
        // 'clip-path'
        node.setClip(CSSUtilities.convertClipPath(e, node, ctx));
        // 'pointer-events'
        node.setPointerEventType(CSSUtilities.convertPointerEvents(e));

        initializeDynamicSupport(ctx, e, node);
    }

    /**
     * Returns false as text is not a container.
     */
    public boolean isComposite() {
        return false;
    }

    // Listener implementation ----------------------------------------------

    /**
     * The DOM EventListener to receive 'DOMNodeRemoved' event.
     */
    protected DOMChildNodeRemovedEventListener childNodeRemovedEventListener = 
        new DOMChildNodeRemovedEventListener();

    /**
     * The DOM EventListener invoked when a node is removed.
     */
    protected class DOMChildNodeRemovedEventListener implements EventListener {

        /**
         * Handles 'DOMNodeRemoved' event type.
         */
        public void handleEvent(Event evt) {
            handleDOMChildNodeRemovedEvent((MutationEvent)evt);            
        }
    }

    /**
     * The DOM EventListener to receive 'DOMSubtreeModified' event.
     */
    protected DOMSubtreeModifiedEventListener subtreeModifiedEventListener = 
        new DOMSubtreeModifiedEventListener();

    /**
     * The DOM EventListener invoked when the subtree is modified.
     */
    protected class DOMSubtreeModifiedEventListener implements EventListener {

        /**
         * Handles 'DOMSubtreeModified' event type.
         */
        public void handleEvent(Event evt) {
            handleDOMSubtreeModifiedEvent((MutationEvent)evt);
        }
    }

    // BridgeUpdateHandler implementation -----------------------------------

    /**
     * This method insures that any modification to a text
     * element and its children is going to be reflected 
     * into the GVT tree.
     */
    protected void initializeDynamicSupport(BridgeContext ctx,
                                            Element e,
                                            GraphicsNode node) {
        super.initializeDynamicSupport(ctx,e,node);

        if (!ctx.isDynamic())
            return;             // Only add the listeners if we are dynamic


        EventTarget evtTarget = (EventTarget)e;

        //to be notified when a child is removed from the 
        //<text> element.
        evtTarget.addEventListener
            ("DOMNodeRemoved", childNodeRemovedEventListener, true);
        ctx.storeEventListener
            (evtTarget, "DOMNodeRemoved", childNodeRemovedEventListener, true);
        
        //to be notified when the modification of the subtree
        //of the <text> element is done
        evtTarget.addEventListener
            ("DOMSubtreeModified", subtreeModifiedEventListener, false);
        ctx.storeEventListener
            (evtTarget, "DOMSubtreeModified", subtreeModifiedEventListener, false);

        // traverse the children to add context on 
        // <tspan>, <tref> and <textPath>
        Node child  = e.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                addContextToChild(ctx,(Element)child);
            }
            child = child.getNextSibling();
        }
    }

    /**
     * Add to the element children of the node, a
     * <code>SVGContext</code> to support dynamic updated . This is
     * recurssive, the children of the nodes are also traversed to add
     * to the support elements their context
     *
     * @param ctx a <code>BridgeContext</code> value
     * @param e an <code>Element</code> value
     *
     * @see org.apache.flex.forks.batik.dom.svg.SVGContext
     * @see org.apache.flex.forks.batik.bridge.BridgeUpdateHandler
     */
    protected void addContextToChild(BridgeContext ctx,Element e) {
        if (SVG_NAMESPACE_URI.equals(e.getNamespaceURI())) {
            if (e.getLocalName().equals(SVG_TSPAN_TAG)) {
                ((SVGOMElement)e).setSVGContext
                    (new TspanBridge(ctx, this, e));
            } else if (e.getLocalName().equals(SVG_TEXT_PATH_TAG)) {
                ((SVGOMElement)e).setSVGContext
                    (new TextPathBridge(ctx, this, e));
            } else if (e.getLocalName().equals(SVG_TREF_TAG)) {
                ((SVGOMElement)e).setSVGContext
                    (new TRefBridge(ctx, this, e));
            }
        }

        Node child  = e.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                addContextToChild(ctx, (Element)child);
            }        
            child = child.getNextSibling();
        }
    }

    /**
     * Invoked when an MutationEvent of type 'DOMNodeInserted' is fired.
     */
    public void handleDOMNodeInsertedEvent(MutationEvent evt) {
        Node childNode = (Node)evt.getTarget();
        
        //check the type of the node inserted before discard the layout
        //in the case of <title> or <desc> or <metadata>, the layout
        //is unchanged
        switch( childNode.getNodeType() ){
        case Node.TEXT_NODE:
        case Node.CDATA_SECTION_NODE:
            laidoutText = null;
            break;
        case Node.ELEMENT_NODE: {
            Element childElement = (Element)childNode;
            if (isTextChild(childElement)) {
                addContextToChild( ctx, childElement);
                laidoutText = null;
            }
        }
            break;
        default:
        }
        if (laidoutText == null) {
            computeLaidoutText(ctx, e, node);
        }
    }

    /**
     * Invoked when an MutationEvent of type 'DOMNodeInserted' is fired.
     */
    public void handleDOMNodeRemovedEvent(MutationEvent evt) {
        EventTarget evtTarget = evt.getTarget();
        evtTarget.removeEventListener("DOMNodeRemoved",
                                      childNodeRemovedEventListener,
                                      true);
        evtTarget.removeEventListener("DOMSubtreeModified",
                                      subtreeModifiedEventListener,
                                      false);
        super.handleDOMNodeRemovedEvent(evt);
    }

    /**
     * Invoked when an MutationEvent of type 'DOMNodeRemoved' is fired.
     */
    public void handleDOMChildNodeRemovedEvent(MutationEvent evt) {
        Node childNode = (Node)evt.getTarget();

        //check the type of the node inserted before discard the layout
        //in the case of <title> or <desc> or <metadata>, the layout
        //is unchanged
        switch (childNode.getNodeType()) {
            case Node.TEXT_NODE:
            case Node.CDATA_SECTION_NODE:
                //the parent has to be a displayed node
                if (isParentDisplayed( childNode)) {
                    laidoutText = null;
                }
                break;
            case Node.ELEMENT_NODE: 
                if (isTextChild((Element)childNode)) {
                    laidoutText = null;
                }
                break;
            default:
        }
        //if the laidoutText was set to null,
        //then wait for DOMSubtreeChange to recompute it.
    }

    /**
     * Invoked when an MutationEvent of type 'DOMSubtree' is fired.
     */
    public void handleDOMSubtreeModifiedEvent(MutationEvent evt){
        //an operation occured onto the children of the
        //text element, check if the layout was discarded
        if (laidoutText == null) {
            computeLaidoutText(ctx, e, node);
        }
    }

    /**
     * Invoked when an MutationEvent of type 'DOMCharacterDataModified' 
     * is fired.
     */
    public void handleDOMCharacterDataModified(MutationEvent evt){
        Node childNode = (Node)evt.getTarget();
        //if the parent is displayed, then discard the layout.
        if (isParentDisplayed(childNode)) {
            laidoutText = null;
        }
    }

    /**
     * Indicate of the parent of a node is
     * a displayed element.
     * &lt;title&gt;, &lt;desc&gt; and &lt;metadata&gt;
     * are non displayable elements.
     *
     * @return true if the parent of the node is &lt;text&gt;, 
     *   &lt;tspan&gt;, &lt;tref&gt;, &lt;textPath&gt;, &lt;a&gt;,
     *   &lt;altGlyph&gt;
     */
    protected boolean isParentDisplayed(Node childNode) {
        Node parentNode = childNode.getParentNode();
        return isTextElement((Element)parentNode);
    }

    /**
     * Recompute the layout of the &lt;text&gt; node.
     *
     * Assign onto the TextNode pending to the element
     * the new recomputed AtrributedString. Also
     * update <code>laidoutText</code> with the new
     * value.
     */
    protected void computeLaidoutText(BridgeContext ctx, 
                                       Element e,
                                       GraphicsNode node) {
        AttributedString as = buildAttributedString(ctx, e);
        addGlyphPositionAttributes(as, e, ctx);
        if (ctx.isDynamic()) {
            laidoutText = new AttributedString(as.getIterator());
        }
        TextNode tn = (TextNode)node;
        elemTPI.clear();
        // Add null TPI objects to the text (after we set it on the
        // Text we will swap in the correct values.
        addNullPaintAttributes(as, e, ctx);

        // Install the ACI in the text node.
        tn.setAttributedCharacterIterator(as.getIterator());

        // Now get the real paint into - this needs to
        // wait until the text node is laidout so we can get
        // objectBoundingBox info.
        TextPaintInfo pi = new TextPaintInfo();
        setBaseTextPaintInfo(pi, e, node, ctx);
        // This get's Overline/underline info.
        setDecorationTextPaintInfo(pi, e);
        // Install the attributes.
        addPaintAttributes(as, e, tn, pi, ctx);

        if (usingComplexSVGFont) {
            // Force Complex SVG fonts to be recreated, if we have them.
            tn.setAttributedCharacterIterator(as.getIterator());
        }
    }

    /**
     * This creates 'dummy' TPI objects for each element and records
     * them in the elemTPI map so we can later update them with 
     * the correct paint attributes.
     */
    protected void addNullPaintAttributes(AttributedString as, 
                                          Element element,
                                          BridgeContext ctx) {
        // 'requiredFeatures', 'requiredExtensions' and 'systemLanguage'
        if ((!SVGUtilities.matchUserAgent(element, ctx.getUserAgent())) ||
            (!CSSUtilities.convertDisplay(element))) {
            return;
        }

        AttributedCharacterIterator aci = as.getIterator();

        // calculate which chars in the string belong to this element
        int firstChar = getElementStartIndex(aci, element);
        if (firstChar == -1)
            return; // Element not part of aci (no chars in elem usually)

        int lastChar = getElementEndIndex(aci, element);
        TextPaintInfo pi = new TextPaintInfo();
        // Set some basic props so we can get bounds info for complex paints.
        pi.visible   = true;        
        pi.fillPaint = Color.black;

        as.addAttribute(PAINT_INFO, pi, firstChar, lastChar+1);
        elemTPI.put(element, pi);

        addChildNullPaintAttributes(as, element, ctx);
    }
    
    protected void addChildNullPaintAttributes(AttributedString as,
                                               Element element,
                                               BridgeContext ctx) {
        // Add Paint attributres for children of text element
        for (Node child = element.getFirstChild();
             child != null;
             child = child.getNextSibling()) {
            if (child.getNodeType() != Node.ELEMENT_NODE) 
                continue;

            Element childElement = (Element)child;
            if (isTextChild(childElement)) {
                addNullPaintAttributes(as, childElement, ctx);
            }
        }
    }

    /**
     * This flag bit indicates if a new ACI has been created in
     * response to a CSSEngineEvent.
     * Avoid creating one ShapePainter per CSS property change
     */
    private boolean hasNewACI;

    /**
     * This is the element a CSS property has changed.
     */
    private Element cssProceedElement;

    /**
     * Invoked when an MutationEvent of type 'DOMAttrModified' is fired.
     */
    public void handleDOMAttrModifiedEvent(MutationEvent evt) {
        String attrName = evt.getAttrName();
        if (attrName.equals(SVG_X_ATTRIBUTE) ||
            attrName.equals(SVG_Y_ATTRIBUTE) ||
            attrName.equals(SVG_DX_ATTRIBUTE) ||
            attrName.equals(SVG_DY_ATTRIBUTE) ||
            attrName.equals(SVG_ROTATE_ATTRIBUTE) ){

            if ( attrName.equals(SVG_X_ATTRIBUTE) ||
                 attrName.equals(SVG_Y_ATTRIBUTE)){
                ((TextNode)node).setLocation(getLocation(ctx, e));
            }

            computeLaidoutText(ctx, e, node);
        }
        else{
            super.handleDOMAttrModifiedEvent(evt);
        }
    }

    /**
     * Invoked when CSS properties have changed on an element.
     *
     * @param evt the CSSEngine event that describes the update
     */
    public void handleCSSEngineEvent(CSSEngineEvent evt) {
        hasNewACI = false;
        int [] properties = evt.getProperties();
        // first try to find CSS properties that change the layout
        for (int i=0; i < properties.length; ++i) {
            switch(properties[i]) {
            case SVGCSSEngine.BASELINE_SHIFT_INDEX:
            case SVGCSSEngine.DIRECTION_INDEX:
            case SVGCSSEngine.DISPLAY_INDEX:
            case SVGCSSEngine.FONT_FAMILY_INDEX:
            case SVGCSSEngine.FONT_SIZE_INDEX:
            case SVGCSSEngine.FONT_STRETCH_INDEX:
            case SVGCSSEngine.FONT_STYLE_INDEX:
            case SVGCSSEngine.FONT_WEIGHT_INDEX:
            case SVGCSSEngine.GLYPH_ORIENTATION_HORIZONTAL_INDEX:
            case SVGCSSEngine.GLYPH_ORIENTATION_VERTICAL_INDEX:
            case SVGCSSEngine.KERNING_INDEX: 
            case SVGCSSEngine.LETTER_SPACING_INDEX:
            case SVGCSSEngine.TEXT_ANCHOR_INDEX:
            case SVGCSSEngine.UNICODE_BIDI_INDEX:
            case SVGCSSEngine.WORD_SPACING_INDEX:
            case SVGCSSEngine.WRITING_MODE_INDEX: {
                if (!hasNewACI) {
                    hasNewACI = true;
                    computeLaidoutText(ctx, e, node);
                }
                break;
            }
            }
        }
        //optimize the calculation of
        //the painting attributes and decoration
        //by only recomputing the section for the element
        cssProceedElement = evt.getElement();
        // go for the other CSS properties
        super.handleCSSEngineEvent(evt);
        cssProceedElement = null;
    }

    /**
     * Invoked for each CSS property that has changed.
     */
    protected void handleCSSPropertyChanged(int property) {
        switch(property) {
        case SVGCSSEngine.FILL_INDEX:
        case SVGCSSEngine.FILL_OPACITY_INDEX:
        case SVGCSSEngine.STROKE_INDEX:
        case SVGCSSEngine.STROKE_OPACITY_INDEX:
        case SVGCSSEngine.STROKE_WIDTH_INDEX:
        case SVGCSSEngine.STROKE_LINECAP_INDEX:
        case SVGCSSEngine.STROKE_LINEJOIN_INDEX:
        case SVGCSSEngine.STROKE_MITERLIMIT_INDEX:
        case SVGCSSEngine.STROKE_DASHARRAY_INDEX:
        case SVGCSSEngine.STROKE_DASHOFFSET_INDEX:
        case SVGCSSEngine.TEXT_DECORATION_INDEX:
            rebuildACI();
            break;
 
        case SVGCSSEngine.VISIBILITY_INDEX: 
            rebuildACI();
            super.handleCSSPropertyChanged(property);
            break;
        case SVGCSSEngine.TEXT_RENDERING_INDEX: {
            RenderingHints hints = node.getRenderingHints();
            hints = CSSUtilities.convertTextRendering(e, hints);
            if (hints != null) {
                node.setRenderingHints(hints);
            }
            break;
        }
        case SVGCSSEngine.COLOR_RENDERING_INDEX: {
            RenderingHints hints = node.getRenderingHints();
            hints = CSSUtilities.convertColorRendering(e, hints);
            if (hints != null) {
                node.setRenderingHints(hints);
            }
            break;
        } 
        default:
            super.handleCSSPropertyChanged(property);
        }
    }

    protected void rebuildACI() {
        if (hasNewACI)
            return;

        TextNode tn = (TextNode)node;

        TextPaintInfo pi, oldPI;
        if ( cssProceedElement == e ){
            pi = new TextPaintInfo();
            setBaseTextPaintInfo(pi, e, node, ctx);
            setDecorationTextPaintInfo(pi, e);
            oldPI = (TextPaintInfo)elemTPI.get(e);
        } else {
            //if a child CSS property has changed, then
            //retrieve the parent text decoration
            //and only update the section of the AtrtibutedString of
            //the child
            TextPaintInfo parentPI;
            parentPI = getParentTextPaintInfo
                (tn.getAttributedCharacterIterator(), cssProceedElement);
            pi = getTextPaintInfo(cssProceedElement, tn, parentPI, ctx);
            oldPI = (TextPaintInfo)elemTPI.get(cssProceedElement);
        }
        if (oldPI == null) return;

        tn.swapTextPaintInfo(pi, oldPI);
        if (usingComplexSVGFont) 
            // Force Complex SVG fonts to be recreated
            tn.setAttributedCharacterIterator
                (tn.getAttributedCharacterIterator());
    }

    int getElementStartIndex
        (AttributedCharacterIterator aci, Element element) {
        // calculate which chars in the string belong to this element
        for (int i = 0; i < aci.getEndIndex();) {
            aci.setIndex(i);
            Element delimeter;
            delimeter = (Element)aci.getAttribute(TEXT_COMPOUND_DELIMITER);
            if (delimeter == element || nodeAncestorOf(element, delimeter))
                return i;
            i = aci.getRunLimit(TEXT_COMPOUND_DELIMITER);
        }
        return -1;  
    }

    int getElementEndIndex
        (AttributedCharacterIterator aci, Element element) {
        // calculate which chars in the string belong to this element
        for (int i = aci.getEndIndex()-1; i >= 0;) {
            aci.setIndex(i);
            Element delimeter;
            delimeter = (Element)aci.getAttribute(TEXT_COMPOUND_DELIMITER);
            if (delimeter == element || nodeAncestorOf(element, delimeter))
                return i;
            i = aci.getRunStart(TEXT_COMPOUND_DELIMITER)-1;
        }
        return -1;  
    }

    // -----------------------------------------------------------------------
    // -----------------------------------------------------------------------
    // -----------------------------------------------------------------------
    // -----------------------------------------------------------------------

    /**
     * Creates the attributed string which represents the given text
     * element children.
     *
     * @param ctx the bridge context to use
     * @param element the text element
     */
    protected AttributedString buildAttributedString(BridgeContext ctx,
                                                     Element element) {
        
        AttributedStringBuffer asb = new AttributedStringBuffer();
        fillAttributedStringBuffer(ctx, element, true, null, null, asb);
        return asb.toAttributedString();
    }


    /**
     * This is used to store the end of the last piece of text
     * content from an element with xml:space="preserve".  When
     * we are stripping trailing spaces we need to make sure
     * we don't strip anything before this point.
     */
    protected int endLimit;

    /**
     * Fills the given AttributedStringBuffer.
     */
    protected void fillAttributedStringBuffer(BridgeContext ctx,
                                              Element element,
                                              boolean top,
                                              TextPath textPath,
                                              Integer bidiLevel,
                                              AttributedStringBuffer asb) {
        // 'requiredFeatures', 'requiredExtensions', 'systemLanguage' &
        // 'display="none".
        if ((!SVGUtilities.matchUserAgent(element, ctx.getUserAgent())) ||
            (!CSSUtilities.convertDisplay(element))) {
            return;
        }
        
        String s = XMLSupport.getXMLSpace(element);
        boolean preserve = s.equals(SVG_PRESERVE_VALUE);
        boolean prevEndsWithSpace;
        Element nodeElement = element;

        if (top)
            endLimit = 0;
        if (preserve)
            endLimit = asb.length();
        
	Map map = getAttributeMap(ctx, element, textPath, bidiLevel);
	Object o = map.get(TextAttribute.BIDI_EMBEDDING);
        Integer subBidiLevel = bidiLevel;
	if (o != null)
	    subBidiLevel = ((Integer)o);

        for (Node n = element.getFirstChild();
             n != null;
             n = n.getNextSibling()) {

            if (preserve) {
                prevEndsWithSpace = false;
            } else {
                if (asb.length() == 0) 
                    prevEndsWithSpace = true;
                else
                    prevEndsWithSpace = (asb.getLastChar() == ' ');
            }

            switch (n.getNodeType()) {
            case Node.ELEMENT_NODE:
                if (!SVG_NAMESPACE_URI.equals(n.getNamespaceURI()))
                    break;
                
                nodeElement = (Element)n;

                String ln = n.getLocalName();
                
                if (ln.equals(SVG_TSPAN_TAG) ||
                    ln.equals(SVG_ALT_GLYPH_TAG)) {
                    fillAttributedStringBuffer(ctx,
                                               nodeElement,
                                               false,
                                               textPath,
                                               subBidiLevel,
                                               asb);
                } else if (ln.equals(SVG_TEXT_PATH_TAG)) {
                    SVGTextPathElementBridge textPathBridge
                        = (SVGTextPathElementBridge)ctx.getBridge(nodeElement);
                    TextPath newTextPath
                        = textPathBridge.createTextPath(ctx, nodeElement);
                    if (newTextPath != null) {
                        fillAttributedStringBuffer(ctx,
                                                   nodeElement,
                                                   false,
                                                   newTextPath,
                                                   subBidiLevel,
                                                   asb);
                    }
                } else if (ln.equals(SVG_TREF_TAG)) {
                    String uriStr = XLinkSupport.getXLinkHref((Element)n);
                    Element ref = ctx.getReferencedElement((Element)n, uriStr);
                    s = TextUtilities.getElementContent(ref);
                    s = normalizeString(s, preserve, prevEndsWithSpace);
                    if (s != null) {
                        Map m = getAttributeMap(ctx, nodeElement, 
                                                textPath, bidiLevel);
                        asb.append(s, m);
                    }
                } else if (ln.equals(SVG_A_TAG)) {
                    EventTarget target = (EventTarget)nodeElement;
                    UserAgent ua = ctx.getUserAgent();
                    EventListener l = new SVGAElementBridge.AnchorListener(ua);
                    target.addEventListener(SVG_EVENT_CLICK, l, false);
                    ctx.storeEventListener(target, SVG_EVENT_CLICK, l, false);
                    
                    fillAttributedStringBuffer(ctx,
                                               nodeElement,
                                               false,
                                               textPath,
                                               subBidiLevel,
                                               asb);
                }
                break;
            case Node.TEXT_NODE:
            case Node.CDATA_SECTION_NODE:
                s = n.getNodeValue();
                s = normalizeString(s, preserve, prevEndsWithSpace);
                asb.append(s, map);
                if (preserve)
                    endLimit = asb.length();
            }
        }

        if (top) {
            while ((endLimit < asb.length()) && (asb.getLastChar() == ' '))
                asb.stripLast();
        }
    }

    /**
     * Normalizes the given string.
     */
    protected String normalizeString(String s,
                                     boolean preserve,
                                     boolean stripfirst) {
        StringBuffer sb = new StringBuffer(s.length());
        if (preserve) {
            for (int i = 0; i < s.length(); i++) {
                char c = s.charAt(i);
                switch (c) {
                case 10:
                case 13:
                case '\t':
                    sb.append(' ');
                    break;
                default:
                    sb.append(c);
                }
            }
            return sb.toString();
        }

        int idx = 0;
        if (stripfirst) {
            loop: while (idx < s.length()) {
                switch (s.charAt(idx)) {
                default:
                    break loop;
                case 10:
                case 13:
                case ' ':
                case '\t':
                    idx++;
                }
            }
        }

        boolean space = false;
        for (int i = idx; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
            case 10:
            case 13:
                break;
            case ' ':
            case '\t':
                if (!space) {
                    sb.append(' ');
                    space = true;
                }
                break;
            default:
                sb.append(c);
                space = false;
            }
        }

        return sb.toString();
    }

    /**
     * This class is used to build an AttributedString.
     */
    protected static class AttributedStringBuffer {

        /**
         * The strings.
         */
        protected List strings;

        /**
         * The attributes.
         */
        protected List attributes;
        
        /**
         * The number of items.
         */
        protected int count;

        /**
         * The length of the attributed string.
         */
        protected int length;
        
        /**
         * Creates a new empty AttributedStringBuffer.
         */
        public AttributedStringBuffer() {
            strings    = new ArrayList();
            attributes = new ArrayList();
            count      = 0;
            length     = 0;
        }

        /**
         * Tells whether this AttributedStringBuffer is empty.
         */
        public boolean isEmpty() {
            return count == 0;
        }
        
        /**
         * Returns the length in chars of the current Attributed String
         */
        public int length() {
            return length;
        }

        /**
         * Appends a String and its associated attributes.
         */
        public void append(String s, Map m) {
          if (s.length() == 0) return;
          strings.add(s);
          attributes.add(m);
          count++;
          length += s.length();
        }

        /**
         * Returns the value of the last char or -1.
         */
        public int getLastChar() {
            if (count == 0) {
                return -1;
            }
            String s = (String)strings.get(count - 1);
            return s.charAt(s.length() - 1);
        }

        /**
         * Strips the last string character.
         */
        public void stripFirst() {
            String s = (String)strings.get(0);
            if (s.charAt(s.length() - 1) != ' ') 
                return;

            length--;

            if (s.length() == 1) {
                attributes.remove(0);
                strings.remove(0);
                count--;
                return;
            }

            strings.set(0, s.substring(1));
        }

        /**
         * Strips the last string character.
         */
        public void stripLast() {
            String s = (String)strings.get(count - 1);
            if (s.charAt(s.length() - 1) != ' ') 
                return;

            length--;

            if (s.length() == 1) {
                attributes.remove(--count);
                strings.remove(count);
                return;
            }

            strings.set(count-1, s.substring(0, s.length() - 1));
        }

        /**
         * Builds an attributed string from the content of this
         * buffer.
         */
        public AttributedString toAttributedString() {
            switch (count) {
            case 0:
                return new AttributedString(" ");
            case 1:
                return new AttributedString((String)strings.get(0),
                                            (Map)attributes.get(0));
            }

            StringBuffer sb = new StringBuffer();
            Iterator it = strings.iterator();
            while (it.hasNext()) {
                sb.append((String)it.next());
            }

            AttributedString result = new AttributedString(sb.toString());

            // Set the attributes

            Iterator sit = strings.iterator();
            Iterator ait = attributes.iterator();
            int idx = 0;
            while (sit.hasNext()) {
                String s = (String)sit.next();
                int nidx = idx + s.length();
                Map m = (Map)ait.next();
                Iterator kit = m.keySet().iterator();
                Iterator vit = m.values().iterator();
                while (kit.hasNext()) {
                    Attribute attr = (Attribute)kit.next();
                    Object val = vit.next();
                    result.addAttribute(attr, val, idx, nidx);
                }
                idx = nidx;
            }

            return result;
        }

        public String toString() {
            switch (count) {
            case 0:
                return "";
            case 1:
                return (String)strings.get(0);
            }

            StringBuffer sb = new StringBuffer();
            Iterator it = strings.iterator();
            while (it.hasNext()) {
                sb.append((String)it.next());
            }
            return sb.toString();
        }
    }

    /**
     * Returns true if node1 is an ancestor of node2
     */
    protected boolean nodeAncestorOf(Node node1, Node node2) {
        if (node2 == null || node1 == null) {
            return false;
        }
        Node parent = node2.getParentNode();
        while (parent != null && parent != node1) {
            parent = parent.getParentNode();
        }
        return (parent == node1);
    }


    /**
     * Adds glyph position attributes to an AttributedString.
     */
    protected void addGlyphPositionAttributes(AttributedString as,
                                              Element element,
                                              BridgeContext ctx) {

        // 'requiredFeatures', 'requiredExtensions' and 'systemLanguage'
        if ((!SVGUtilities.matchUserAgent(element, ctx.getUserAgent())) ||
            (!CSSUtilities.convertDisplay(element))) {
            return;
        }
        if (element.getLocalName().equals(SVG_TEXT_PATH_TAG)) {
            // 'textPath' doesn't support position attributes.
            addChildGlyphPositionAttributes(as, element, ctx);
            return;
        }

        AttributedCharacterIterator aci = as.getIterator();

        // calculate which chars in the string belong to this element
        int firstChar = getElementStartIndex(aci, element);
        // No match so no chars to annotate.
        if (firstChar == -1) return;

        int lastChar = getElementEndIndex(aci, element);

        // get all of the glyph position attribute values
        String xAtt      = element.getAttributeNS(null, SVG_X_ATTRIBUTE);
        String yAtt      = element.getAttributeNS(null, SVG_Y_ATTRIBUTE);
        String dxAtt     = element.getAttributeNS(null, SVG_DX_ATTRIBUTE);
        String dyAtt     = element.getAttributeNS(null, SVG_DY_ATTRIBUTE);
        String rotateAtt = element.getAttributeNS(null, SVG_ROTATE_ATTRIBUTE);

        ArrayList al;
        int len;

        // process the x attribute
        if (xAtt.length() != 0) {
            al = TextUtilities.svgHorizontalCoordinateArrayToUserSpace
                (element, SVG_X_ATTRIBUTE, xAtt, ctx);
            len = al.size();
            for (int i = 0; i < len; i++) {
                if (firstChar + i <= lastChar) {
                    as.addAttribute
                        (GVTAttributedCharacterIterator.TextAttribute.X,
                         al.get(i), firstChar+i, firstChar+i+1);
                }
            }
        }


       // process the y attribute
        if (yAtt.length() != 0) {
            al = TextUtilities.svgVerticalCoordinateArrayToUserSpace
                (element, SVG_Y_ATTRIBUTE, yAtt, ctx);
            len = al.size();

            for (int i = 0; i < len; i++) {
                if (firstChar+i <= lastChar) {
                    as.addAttribute
                        (GVTAttributedCharacterIterator.TextAttribute.Y,
                         al.get(i), firstChar+i, firstChar+i+1);
                }
            }
        }

        // process dx attribute
        if (dxAtt.length() != 0) {
            al = TextUtilities.svgHorizontalCoordinateArrayToUserSpace
                (element, SVG_DX_ATTRIBUTE, dxAtt, ctx);
            len = al.size();

            for (int i = 0; i < len; i++) {
                if (firstChar+i <= lastChar) {
                    as.addAttribute
                        (GVTAttributedCharacterIterator.TextAttribute.DX,
                         al.get(i), firstChar+i, firstChar+i+1);
                }
            }
        }

        // process dy attribute
        if (dyAtt.length() != 0) {
            al = TextUtilities.svgVerticalCoordinateArrayToUserSpace
                (element, SVG_DY_ATTRIBUTE, dyAtt, ctx);
            len = al.size();

            for (int i = 0; i < len; i++) {
                if (firstChar+i <= lastChar) {
                    as.addAttribute
                        (GVTAttributedCharacterIterator.TextAttribute.DY,
                         al.get(i), firstChar+i, firstChar+i+1);
                }
            }
        }

        // process rotate attribute
        if (rotateAtt.length() != 0) {
            al = TextUtilities.svgRotateArrayToFloats
                (element, SVG_ROTATE_ATTRIBUTE, rotateAtt, ctx);
            len = al.size();

            if (len == 1) {  // not a list
                // each char will have the same rotate value
                as.addAttribute
                    (GVTAttributedCharacterIterator.TextAttribute.ROTATION,
                     al.get(0), firstChar, lastChar + 1);

            } else {  // its a list
                // set each rotate value from the list
                for (int i = 0; i < len; i++) {
                    if (firstChar+i <= lastChar) {
                        as.addAttribute
                            (GVTAttributedCharacterIterator.
                             TextAttribute.ROTATION,
                             al.get(i), firstChar+i, firstChar+i+1);
                    }
                }
            }
        }

        addChildGlyphPositionAttributes(as, element, ctx);
    }

    protected void addChildGlyphPositionAttributes(AttributedString as,
                                                   Element element,
                                                   BridgeContext ctx) {
        // do the same for each child element
        for (Node child = element.getFirstChild();
             child != null;
             child = child.getNextSibling()) {
            if (child.getNodeType() != Node.ELEMENT_NODE) continue;

            Element childElement = (Element)child;
            if (isTextChild(childElement)) {
                addGlyphPositionAttributes(as, childElement, ctx);
            }
        }
    }

    /**
     * Adds painting attributes to an AttributedString.
     */
    protected void addPaintAttributes(AttributedString as,
                                      Element element,
                                      TextNode node,
                                      TextPaintInfo pi,
                                      BridgeContext ctx) {
        // 'requiredFeatures', 'requiredExtensions' and 'systemLanguage'
        if ((!SVGUtilities.matchUserAgent(element, ctx.getUserAgent())) ||
            (!CSSUtilities.convertDisplay(element))) {
            return;
        }
        Object o = elemTPI.get(element);
        if (o == null) return;
        node.swapTextPaintInfo(pi, (TextPaintInfo)o);
        addChildPaintAttributes(as, element, node, pi, ctx);
    }

    protected void addChildPaintAttributes(AttributedString as,
                                           Element element,
                                           TextNode node,
                                           TextPaintInfo parentPI,
                                           BridgeContext ctx) {
        // Add Paint attributres for children of text element
        for (Node child = element.getFirstChild();
             child != null;
             child = child.getNextSibling()) {
            if (child.getNodeType() != Node.ELEMENT_NODE) {
                continue;
            }
            Element childElement = (Element)child;
            if (isTextChild(childElement)) {
                TextPaintInfo pi = getTextPaintInfo(childElement, node,
                                                        parentPI, ctx);
                addPaintAttributes(as, childElement, node, pi, ctx);
            }
        }
    }

    protected Map getFontProperties(BridgeContext ctx, Element element, 
                                    Map map) {
        if (map == null) map = new HashMap(4);

        // Needed for SVG fonts.
        map.put(TEXT_COMPOUND_DELIMITER, element);

        // Font size.
        map.put(TextAttribute.SIZE, TextUtilities.convertFontSize(element));

        // Font stretch
        map.put(TextAttribute.WIDTH, TextUtilities.convertFontStretch(element));

        // Font weight
        map.put(TextAttribute.WEIGHT, TextUtilities.convertFontWeight(element));

        // Font style
        map.put(TextAttribute.POSTURE, TextUtilities.convertFontStyle(element));

        return map;
    }

    /**
     * Returns the map to pass to the current characters.
     */
    protected Map getAttributeMap(BridgeContext ctx,
                                  Element element,
                                  TextPath textPath,
                                  Integer bidiLevel) {
        UnitProcessor.Context uctx = UnitProcessor.createContext(ctx, element);

        Map result = new HashMap();
        String s;
        float f;
        
        if (SVG_NAMESPACE_URI.equals(element.getNamespaceURI()) &&
            element.getLocalName().equals(SVG_ALT_GLYPH_TAG)) {
            result.put(ALT_GLYPH_HANDLER, 
                       new SVGAltGlyphHandler(ctx, element));
        }

        if (textPath != null) {
            result.put(GVTAttributedCharacterIterator.TextAttribute.TEXTPATH,
                       textPath);
        }

        // Text-anchor
        TextNode.Anchor a = TextUtilities.convertTextAnchor(element);
        result.put(GVTAttributedCharacterIterator.TextAttribute.ANCHOR_TYPE,
                   a);

        // get font size/width/weight/posture properties
        getFontProperties(ctx, element, result);

        // Font family
        List fontFamilyList = getFontFamilyList(element, ctx);
        result.put
            (GVTAttributedCharacterIterator.TextAttribute.GVT_FONT_FAMILIES,
             fontFamilyList);

        // Text baseline adjustment.
        Object bs = TextUtilities.convertBaselineShift(element);
        if (bs != null) {
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.BASELINE_SHIFT, bs);
        }

        // Unicode-bidi mode
        Value val =  CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.UNICODE_BIDI_INDEX);
        s = val.getStringValue();
        if (s.charAt(0) == 'n') {
            if (bidiLevel != null)
                result.put(TextAttribute.BIDI_EMBEDDING, bidiLevel);
        } else {

            // Text direction
            // XXX: this needs to coordinate with the unicode-bidi
            // property, so that when an explicit reversal
            // occurs, the BIDI_EMBEDDING level is
            // appropriately incremented or decremented.
            // Note that direction is implicitly handled by unicode
            // BiDi algorithm in most cases, this property
            // is only needed when one wants to override the
            // normal writing direction for a string/substring.

            val = CSSUtilities.getComputedStyle
                (element, SVGCSSEngine.DIRECTION_INDEX);
            String rs = val.getStringValue();
	    int cbidi = 0;
	    if (bidiLevel != null) cbidi = bidiLevel.intValue();

	    // We don't care if it was embed or override we just want
	    // it's level here. So map override to positive value.
	    if (cbidi < 0) cbidi = -cbidi;

            switch (rs.charAt(0)) {
            case 'l':
                result.put(TextAttribute.RUN_DIRECTION,
                           TextAttribute.RUN_DIRECTION_LTR);
		if ((cbidi & 0x1) == 1) cbidi++; // was odd now even
		else                    cbidi+=2; // next greater even number
                break;
            case 'r':
                result.put(TextAttribute.RUN_DIRECTION,
                           TextAttribute.RUN_DIRECTION_RTL);
		if ((cbidi & 0x1) == 1) cbidi+=2; // next greater odd number
		else                    cbidi++; // was even now odd
                break;
	    }
	    
	    switch (s.charAt(0)) {
	    case 'b': // bidi-override
		cbidi = -cbidi; // For bidi-override we want a negative number.
		break;
	    }

	    result.put(TextAttribute.BIDI_EMBEDDING, new Integer(cbidi));
        }

        // Writing mode

        val = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.WRITING_MODE_INDEX);
        s = val.getStringValue();
        switch (s.charAt(0)) {
        case 'l':
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.WRITING_MODE,
                       GVTAttributedCharacterIterator.
                       TextAttribute.WRITING_MODE_LTR);
            break;
        case 'r':
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.WRITING_MODE,
                       GVTAttributedCharacterIterator.
                       TextAttribute.WRITING_MODE_RTL);
            break;
        case 't':
                result.put(GVTAttributedCharacterIterator.
                       TextAttribute.WRITING_MODE,
                       GVTAttributedCharacterIterator.
                       TextAttribute.WRITING_MODE_TTB);
            break;
        }

        // glyph-orientation-vertical

        val = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.GLYPH_ORIENTATION_VERTICAL_INDEX);
        switch (val.getPrimitiveType()) {
        case CSSPrimitiveValue.CSS_IDENT: // auto
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.VERTICAL_ORIENTATION,
                       GVTAttributedCharacterIterator.
                       TextAttribute.ORIENTATION_AUTO);
            break;
        case CSSPrimitiveValue.CSS_DEG:
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.VERTICAL_ORIENTATION,
                       GVTAttributedCharacterIterator.
                       TextAttribute.ORIENTATION_ANGLE);
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.VERTICAL_ORIENTATION_ANGLE,
                       new Float(val.getFloatValue()));
            break;
        case CSSPrimitiveValue.CSS_RAD:
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.VERTICAL_ORIENTATION,
                       GVTAttributedCharacterIterator.
                       TextAttribute.ORIENTATION_ANGLE);
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.VERTICAL_ORIENTATION_ANGLE,
                       new Float(val.getFloatValue() * 180 / Math.PI));
            break;
        case CSSPrimitiveValue.CSS_GRAD:
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.VERTICAL_ORIENTATION,
                       GVTAttributedCharacterIterator.
                       TextAttribute.ORIENTATION_ANGLE);
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.VERTICAL_ORIENTATION_ANGLE,
                       new Float(val.getFloatValue() * 9 / 5));
            break;
        default:
            // Cannot happen
            throw new InternalError();
        }

        // glyph-orientation-horizontal

        val = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.GLYPH_ORIENTATION_HORIZONTAL_INDEX);
        switch (val.getPrimitiveType()) {
        case CSSPrimitiveValue.CSS_DEG:
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.HORIZONTAL_ORIENTATION_ANGLE,
                       new Float(val.getFloatValue()));
            break;
        case CSSPrimitiveValue.CSS_RAD:
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.HORIZONTAL_ORIENTATION_ANGLE,
                       new Float(val.getFloatValue() * 180 / Math.PI));
            break;
        case CSSPrimitiveValue.CSS_GRAD:
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.HORIZONTAL_ORIENTATION_ANGLE,
                       new Float(val.getFloatValue() * 9 / 5));
            break;
        default:
            // Cannot happen
            throw new InternalError();
        }

        // text spacing properties...

        // Letter Spacing
        Float sp = TextUtilities.convertLetterSpacing(element);
        if (sp != null) {
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.LETTER_SPACING,
                       sp);
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.CUSTOM_SPACING,
                       Boolean.TRUE);
        }

        // Word spacing
        sp = TextUtilities.convertWordSpacing(element);
        if (sp != null) {
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.WORD_SPACING,
                       sp);
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.CUSTOM_SPACING,
                       Boolean.TRUE);
        }

        // Kerning
        sp = TextUtilities.convertKerning(element);
        if (sp != null) {
            result.put(GVTAttributedCharacterIterator.TextAttribute.KERNING,
                       sp);
            result.put(GVTAttributedCharacterIterator.
                       TextAttribute.CUSTOM_SPACING,
                       Boolean.TRUE);
        }

        // textLength
        s = element.getAttributeNS(null, SVG_TEXT_LENGTH_ATTRIBUTE);
        if (s.length() != 0) {
            f = UnitProcessor.svgOtherLengthToUserSpace
                (s, SVG_TEXT_LENGTH_ATTRIBUTE, uctx);
            result.put(GVTAttributedCharacterIterator.TextAttribute.BBOX_WIDTH,
                       new Float(f));

            // lengthAdjust
            s = element.getAttributeNS(null, SVG_LENGTH_ADJUST_ATTRIBUTE);

            if (s.length() < 10) {
                result.put(GVTAttributedCharacterIterator.
                           TextAttribute.LENGTH_ADJUST,
                           GVTAttributedCharacterIterator.
                           TextAttribute.ADJUST_SPACING);
                result.put(GVTAttributedCharacterIterator.
                           TextAttribute.CUSTOM_SPACING,
                           Boolean.TRUE);
            } else {
                result.put(GVTAttributedCharacterIterator.
                           TextAttribute.LENGTH_ADJUST,
                           GVTAttributedCharacterIterator.
                           TextAttribute.ADJUST_ALL);
            }
        }

        return result;
    }


    protected List getFontFamilyList(Element element, BridgeContext ctx) {
        // Font weight
        Value v = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.FONT_WEIGHT_INDEX);
        String fontWeightString = v.getCssText();

        // Font style
        String fontStyleString = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.FONT_STYLE_INDEX).getStringValue();

        Value val = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.FONT_FAMILY_INDEX);
        //  make a list of GVTFontFamily objects
        List fontFamilyList = new ArrayList();
        int len = val.getLength();
        for (int i = 0; i < len; i++) {
            Value it = val.item(i);
            String fontFamilyName = it.getStringValue();
            GVTFontFamily fontFamily
                = SVGFontUtilities.getFontFamily(element, ctx, fontFamilyName,
                                                 fontWeightString, 
                                                 fontStyleString);
            if (fontFamily instanceof SVGFontFamily) {
                SVGFontFamily svgFF = (SVGFontFamily)fontFamily;
                if (svgFF.isComplex()) {
                    usingComplexSVGFont = true;
                }
            }
            fontFamilyList.add(fontFamily);
        }
        return fontFamilyList;
    }

    /**
     * Retrieve in the AttributeString the closest parent
     * of the node 'child' and extract the text decorations
     * of the parent.
     *
     * @param aci an <code>AttributedCharacterIterator</code> value
     * @param child an <code>Element</code> value
     * @return a <code>TextDecoration</code> value
     */
    protected TextPaintInfo getParentTextPaintInfo
        (AttributedCharacterIterator aci, Element child) {
        Element parent = null;

        // calculate which chars in the string belong to the parent
        int firstChar = -1;
        for (int i = 0; i < aci.getEndIndex();) {
            aci.setIndex(i);
            Element delimeter;
            delimeter = (Element)aci.getAttribute(TEXT_COMPOUND_DELIMITER);
            if (nodeAncestorOf(delimeter,child) &&
                ((parent == null) || nodeAncestorOf(parent, delimeter))) {
                parent = delimeter;
                firstChar = i;
            }
            if (delimeter == child || nodeAncestorOf(child, delimeter)) {
                break;
            }
            i = aci.getRunLimit(TEXT_COMPOUND_DELIMITER);
        }

        if ( parent == null)
            return new TextPaintInfo(); //no parent

        aci.setIndex(firstChar);
        return (TextPaintInfo)aci.getAttribute(PAINT_INFO);
    }

    /**
     * Constructs a TextDecoration object for the specified element. This will
     * contain all of the decoration properties to be used when drawing the
     * text.
     */
    protected TextPaintInfo getTextPaintInfo(Element element,
                                             GraphicsNode node,
                                             TextPaintInfo parent,
                                             BridgeContext ctx) {
        // Force the engine to update stuff..
        Value val = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.TEXT_DECORATION_INDEX);

        TextPaintInfo pi = new TextPaintInfo(parent);

        // Was text-decoration explicity set on this element?
        StyleMap sm = ((CSSStylableElement)element).getComputedStyleMap(null);
        if ((sm.isNullCascaded(SVGCSSEngine.TEXT_DECORATION_INDEX)) &&
            (sm.isNullCascaded(SVGCSSEngine.FILL_INDEX)) &&
            (sm.isNullCascaded(SVGCSSEngine.STROKE_INDEX)) &&
            (sm.isNullCascaded(SVGCSSEngine.STROKE_WIDTH_INDEX)) &&
            (sm.isNullCascaded(SVGCSSEngine.OPACITY_INDEX))) {
            // If not, keep the same decorations.
            return pi;
        }

        setBaseTextPaintInfo(pi, element, node, ctx);

        if (!sm.isNullCascaded(SVGCSSEngine.TEXT_DECORATION_INDEX))
            setDecorationTextPaintInfo(pi, element);

        return pi;
    }

    public void setBaseTextPaintInfo(TextPaintInfo pi, Element element,
                                     GraphicsNode node, BridgeContext ctx) {
        if (!element.getLocalName().equals(SVG_TEXT_TAG))
            pi.composite    = CSSUtilities.convertOpacity   (element);
        else
            pi.composite    = AlphaComposite.SrcOver;

        pi.visible      = CSSUtilities.convertVisibility(element);
        pi.fillPaint    = PaintServer.convertFillPaint  (element, node, ctx);
        pi.strokePaint  = PaintServer.convertStrokePaint(element, node, ctx);
        pi.strokeStroke = PaintServer.convertStroke     (element);
    }

    public void setDecorationTextPaintInfo(TextPaintInfo pi, Element element) {
        Value val = CSSUtilities.getComputedStyle
            (element, SVGCSSEngine.TEXT_DECORATION_INDEX);

        switch (val.getCssValueType()) {
        case CSSValue.CSS_VALUE_LIST:
            ListValue lst = (ListValue)val;

            int len = lst.getLength();
            for (int i = 0; i < len; i++) {
                Value v = lst.item(i);
                String s = v.getStringValue();
                switch (s.charAt(0)) {
                case 'u':
                    if (pi.fillPaint != null) {
                        pi.underlinePaint = pi.fillPaint;
                    }
                    if (pi.strokePaint != null) {
                        pi.underlineStrokePaint = pi.strokePaint;
                    }
                    if (pi.strokeStroke != null) {
                        pi.underlineStroke = pi.strokeStroke;
                    }
                    break;
                case 'o':
                    if (pi.fillPaint != null) {
                        pi.overlinePaint = pi.fillPaint;
                    }
                    if (pi.strokePaint != null) {
                        pi.overlineStrokePaint = pi.strokePaint;
                    }
                    if (pi.strokeStroke != null) {
                        pi.overlineStroke = pi.strokeStroke;
                    }
                    break;
                case 'l':
                    if (pi.fillPaint != null) {
                        pi.strikethroughPaint = pi.fillPaint;
                    }
                    if (pi.strokePaint != null) {
                        pi.strikethroughStrokePaint = pi.strokePaint;
                    }
                    if (pi.strokeStroke != null) {
                        pi.strikethroughStroke = pi.strokeStroke;
                    }
                    break;
                }
            }
            break;

        default: // None
            pi.underlinePaint = null;
            pi.underlineStrokePaint = null;
            pi.underlineStroke = null;
            
            pi.overlinePaint = null;
            pi.overlineStrokePaint = null;
            pi.overlineStroke = null;
            
            pi.strikethroughPaint = null;
            pi.strikethroughStrokePaint = null;
            pi.strikethroughStroke = null;
            break;
        }
    }

    /**
     * Implementation of <ode>SVGContext</code> for
     * the children of &lt;text&gt;
     */
    public abstract class AbstractTextChildSVGContext 
        implements SVGContext {

        /** Bridge Context */
        protected BridgeContext ctx;

        /** Text bridge parent */
        protected SVGTextElementBridge textBridge;

        /** Element */
        protected Element e;

        /**
         * Initialize the <code>SVGContext</code> implementation
         * with the bridgeContext, the parent bridge, and the
         * element supervised by this context
         */
        public AbstractTextChildSVGContext(BridgeContext ctx,
                                           SVGTextElementBridge parent,
                                           Element e) {
            this.ctx = ctx;
            this.textBridge = parent;
            this.e = e;
        }

        public SVGTextElementBridge getTextBridge() { return textBridge; }
        
        /**
         * Returns the size of a px CSS unit in millimeters.
         */
        public float getPixelUnitToMillimeter() {
            return ctx.getUserAgent().getPixelUnitToMillimeter();
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         * This will be removed after next release.
         * @see #getPixelUnitToMillimeter()
         */
        public float getPixelToMM() {
            return getPixelUnitToMillimeter();
            
        }
        /**
         * Returns the tight bounding box in current user space (i.e.,
         * after application of the transform attribute, if any) on the
         * geometry of all contained graphics elements, exclusive of
         * stroke-width and filter effects).
         */
        public Rectangle2D getBBox() {
            //text children does not support getBBox
            //return textBridge.getBBox();
            return null;
        }

        /**
         * Returns the transformation matrix from current user units
         * (i.e., after application of the transform attribute, if any) to
         * the viewport coordinate system for the nearestViewportElement.
         */
        public AffineTransform getCTM() {
            // text children does not support transform attribute
            //return textBridge.getCTM();
            return null;
        }

        /**
         * Returns the global transformation matrix from the current
         * element to the root.
         */
        public AffineTransform getGlobalTransform() {
            //return node.getGlobalTransform();
            return null;
        }

        /**
         * Returns the transformation matrix from the userspace of
         * the root element to the screen.
         */
        public AffineTransform getScreenTransform() {
            //return node.getScreenTransform();
            return null;
        }

        /**
         * Sets the transformation matrix to be used from the
         * userspace of the root element to the screen.
         */
        public void setScreenTransform(AffineTransform at) {
            //return node.setScreenTransform(at);
            return;
        }

        /**
         * Returns the width of the viewport which directly contains the
         * given element.
         */
        public float getViewportWidth() {
            return ctx.getBlockWidth(e);
        }
        
        /**
         * Returns the height of the viewport which directly contains the
         * given element.
         */
        public float getViewportHeight() {
            return ctx.getBlockHeight(e);
        }
        
        /**
         * Returns the font-size on the associated element.
         */
        public float getFontSize() {
            return CSSUtilities.getComputedStyle
                (e, SVGCSSEngine.FONT_SIZE_INDEX).getFloatValue();
        }
    }

    /**
     * Implementation for the <code>BridgeUpdateHandler</code>
     * for the child elements of &lt;text&gt;.
     * This implementation relies on the parent bridge
     * which contains the <code>TextNode</code>
     * representing the node this context supervised.
     * All operations are done by the parent bridge
     * <code>SVGTextElementBridge</code> which can determine
     * the impact of a change of one of its children for the others.
     */
    protected abstract class AbstractTextChildBridgeUpdateHandler 
        extends AbstractTextChildSVGContext implements BridgeUpdateHandler {

        /**
         * Initialize the BridgeUpdateHandler implementation.
         */
        public AbstractTextChildBridgeUpdateHandler
            (BridgeContext ctx,
             SVGTextElementBridge parent,
             Element e) {

            super(ctx,parent,e);
        }
        /**
         * Invoked when an MutationEvent of type 'DOMAttrModified' is fired.
         */
        public void handleDOMAttrModifiedEvent(MutationEvent evt) {
            //nothing to do
        }

        /**
         * Invoked when an MutationEvent of type 'DOMNodeInserted' is fired.
         */
        public void handleDOMNodeInsertedEvent(MutationEvent evt) {
            textBridge.handleDOMNodeInsertedEvent(evt);
        }

        /**
         * Invoked when an MutationEvent of type 'DOMNodeRemoved' is fired.
         */
        public void handleDOMNodeRemovedEvent(MutationEvent evt) {
            //nothing to do
            dispose();
        }

        /**
         * Invoked when an MutationEvent of type 'DOMCharacterDataModified' 
         * is fired.
         */
        public void handleDOMCharacterDataModified(MutationEvent evt) {
            textBridge.handleDOMCharacterDataModified(evt);
        }

        /**
         * Invoked when an CSSEngineEvent is fired.
         */
        public void handleCSSEngineEvent(CSSEngineEvent evt) {
            textBridge.handleCSSEngineEvent(evt);
        }

        /**
         * Disposes this BridgeUpdateHandler and releases all resources.
         */
        public void dispose(){
            ((SVGOMElement)e).setSVGContext(null);
            elemTPI.remove(e);
        }
    }

    protected class AbstractTextChildTextContent 
        extends AbstractTextChildBridgeUpdateHandler
        implements SVGTextContent{

        /**
         * Initialize the AbstractTextChildBridgeUpdateHandler implementation.
         */
        public AbstractTextChildTextContent
            (BridgeContext ctx,
             SVGTextElementBridge parent,
             Element e) {

            super(ctx,parent,e);
        }

        //Implementation of TextContent

        public int getNumberOfChars(){
            return textBridge.getNumberOfChars(e);
        }
        
        public Rectangle2D getExtentOfChar(int charnum ){
            return textBridge.getExtentOfChar(e,charnum);
        }

        public Point2D getStartPositionOfChar(int charnum){
            return textBridge.getStartPositionOfChar(e,charnum);
        }

        public Point2D getEndPositionOfChar(int charnum){
            return textBridge.getEndPositionOfChar(e,charnum);
        }

        public void selectSubString(int charnum, int nchars){
            textBridge.selectSubString(e,charnum,nchars);
        }

        public float getRotationOfChar(int charnum){
            return textBridge.getRotationOfChar(e,charnum);
        }

        public float getComputedTextLength(){
            return textBridge.getComputedTextLength(e);
        }
        
        public float getSubStringLength(int charnum, int nchars){
            return textBridge.getSubStringLength(e,charnum,nchars);
        }

        public int getCharNumAtPosition(float x , float y){
            return textBridge.getCharNumAtPosition(e,x,y);
        }
    }

    /**
     * BridgeUpdateHandle for &lt;tref&gt; element.
     */
    protected class TRefBridge 
        extends AbstractTextChildTextContent {

        public TRefBridge(BridgeContext ctx,
                          SVGTextElementBridge parent,
                          Element e) {
            super(ctx,parent,e);
        }

        /**
         * Handle the dynamic update for the attributes of 
         * &lt;tspan&gt; : 'x', 'y', 'dx', 'dy' and 'rotate'.
         */
        public void handleDOMAttrModifiedEvent(MutationEvent evt){
            String attrName = evt.getAttrName();
            if (attrName.equals(SVG_X_ATTRIBUTE) ||
                attrName.equals(SVG_Y_ATTRIBUTE) ||
                attrName.equals(SVG_DX_ATTRIBUTE) ||
                attrName.equals(SVG_DY_ATTRIBUTE) ||
                attrName.equals(SVG_ROTATE_ATTRIBUTE)) {
                //recompute the layout of the text node
                textBridge.computeLaidoutText(ctx, textBridge.e, 
                                               textBridge.node);
            }
        }        
    }

    /**
     * BridgeUpdateHandle for &lt;textPath&gt; element.
     */
    protected class TextPathBridge 
        extends AbstractTextChildTextContent{

        public TextPathBridge(BridgeContext ctx,
                              SVGTextElementBridge parent,
                              Element e){
            super(ctx,parent,e);
        }
    }

    /**
     * BridgeUpdateHandle for &lt;tspan&gt; element.
     */
    protected class TspanBridge 
        extends AbstractTextChildTextContent {

        public TspanBridge(BridgeContext ctx,
                           SVGTextElementBridge parent,
                           Element e){
            super(ctx,parent,e);
        }
        
        /**
         * Handle the dynamic update for the attributes of 
         * &lt;tspan&gt; : 'x', 'y', 'dx', 'dy' and 'rotate'.
         */
        public void handleDOMAttrModifiedEvent(MutationEvent evt){
            String attrName = evt.getAttrName();
            if (attrName.equals(SVG_X_ATTRIBUTE) ||
                attrName.equals(SVG_Y_ATTRIBUTE) ||
                attrName.equals(SVG_DX_ATTRIBUTE) ||
                attrName.equals(SVG_DY_ATTRIBUTE) ||
                attrName.equals(SVG_ROTATE_ATTRIBUTE)) {
                //recompute the layout of the text node
                textBridge.computeLaidoutText(ctx, textBridge.e, 
                                               textBridge.node);
            }
        }        
    }

    //Implementation of TextContent
    public int getNumberOfChars(){
        return getNumberOfChars(e);
    }

    public Rectangle2D getExtentOfChar(int charnum ){
        return getExtentOfChar(e,charnum);
    }

    public Point2D getStartPositionOfChar(int charnum){
        return getStartPositionOfChar(e,charnum);
    }

    public Point2D getEndPositionOfChar(int charnum){
        return getEndPositionOfChar(e,charnum);
    }
    
    public void selectSubString(int charnum, int nchars){
        selectSubString(e,charnum,nchars);
    }

    public float getRotationOfChar(int charnum){
        return getRotationOfChar(e,charnum);
    }

    public float getComputedTextLength(){
        return getComputedTextLength(e);
    }

    public float getSubStringLength(int charnum, int nchars){
        return getSubStringLength(e,charnum,nchars);
    }

    public int getCharNumAtPosition(float x , float y){
        return getCharNumAtPosition(e,x,y);
    }

    /**
     * Implementation of {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getNumberOfChars()}.
     */
    protected int getNumberOfChars(Element element){

        AttributedCharacterIterator aci = ((TextNode)node).getAttributedCharacterIterator();

        //get the index in the aci for the first character
        //of the element
        int firstChar = getElementStartIndex(aci,element);

        if (firstChar == -1)
            return 0; // Element not part of aci (no chars in elem usually)

        int lastChar = getElementEndIndex(aci,element);

        return( lastChar - firstChar + 1 );
    }


    /**
     * Implementation of {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getExtentOfChar(int charnum)}.
     */
    protected Rectangle2D getExtentOfChar(Element element,int charnum ){

        AttributedCharacterIterator aci;
        aci = ((TextNode)node).getAttributedCharacterIterator();

        int firstChar = getElementStartIndex(aci,element);

        if ( firstChar == -1 )
            return null;

        //retrieve the text run for the text node
        List list = getTextRuns((TextNode)node);

        //find the character 'charnum' in the text run
        CharacterInformation info;
        info = getCharacterInformation(list, firstChar,charnum, aci);
            
        if ( info == null )
            return null;

        //retrieve the glyphvector containing the glyph
        //for 'charnum'
        GVTGlyphVector it = info.layout.getGlyphVector();

        Shape b = null;

        if ( info.glyphIndexStart == info.glyphIndexEnd ){
            if (it.isGlyphVisible(info.glyphIndexStart))
                b = it.getGlyphOutline(info.glyphIndexStart);
        } else {
            GeneralPath path = null;
            for( int k = info.glyphIndexStart ; 
                 k <= info.glyphIndexEnd;
                 k++){
                if (it.isGlyphVisible(k)) {
                    if (path == null) 
                        path = new GeneralPath(it.getGlyphOutline(k));
                    else
                        path.append(it.getGlyphOutline(k),false);
                }
            }
            b = path;
        }

        if (b == null) 
            return null;
                
        //return the bounding box of the outline
        return b.getBounds2D();
    }


    /**
     * Implementation of {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getStartPositionOfChar(int charnum)}.
     */
    protected Point2D getStartPositionOfChar(Element element,int charnum){

        AttributedCharacterIterator aci = ((TextNode)node).getAttributedCharacterIterator();

        int firstChar = getElementStartIndex(aci,element);

        if ( firstChar == -1 )
            return null;

        //retrieve the text run for the text node
        List list = getTextRuns((TextNode)node);

        //find the character 'charnum' in the text run
        CharacterInformation info;
        info = getCharacterInformation(list, firstChar,charnum, aci);

        if ( info == null )
            return null;
        
        return getStartPoint( info );            
    }

    protected Point2D getStartPoint(CharacterInformation info){

        GVTGlyphVector it = info.layout.getGlyphVector();
        if (!it.isGlyphVisible(info.glyphIndexStart))
            return null;

        Point2D b = it.getGlyphPosition(info.glyphIndexStart);

        AffineTransform glyphTransform;
        glyphTransform = it.getGlyphTransform(info.glyphIndexStart);


        //glyph are defined starting at position (0,0)
        Point2D.Float result = new Point2D.Float(0, 0);
        if ( glyphTransform != null )
            //apply the glyph transformation to the start point
            glyphTransform.transform(result,result);

        result.x += b.getX();
        result.y += b.getY();
        return result;
    }

    /**
     * Implementation of {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getEndPositionOfChar(int charnum)}.
     */
    protected Point2D getEndPositionOfChar(Element element,int charnum ){

        AttributedCharacterIterator aci;
        aci = ((TextNode)node).getAttributedCharacterIterator();

        int firstChar = getElementStartIndex(aci,element);

        if ( firstChar == -1 )
            return null;

        //retrieve the text run for the text node
        List list = getTextRuns((TextNode)node);

        //find the glyph information for the character 'charnum'
        CharacterInformation info;
        info = getCharacterInformation(list, firstChar,charnum, aci);
            
        if ( info == null )
            return null;
        return getEndPoint(info);
    }

    protected Point2D getEndPoint(CharacterInformation info){

        GVTGlyphVector it = info.layout.getGlyphVector();
        if (!it.isGlyphVisible(info.glyphIndexEnd))
            return null;
        
        Point2D b = it.getGlyphPosition(info.glyphIndexEnd);
        
        AffineTransform glyphTransform;
        glyphTransform = it.getGlyphTransform(info.glyphIndexEnd);
        
        GVTGlyphMetrics metrics = it.getGlyphMetrics(info.glyphIndexEnd);
        
        
        Point2D.Float result = new Point2D.Float
            (metrics.getHorizontalAdvance(), 0);
            
        if ( glyphTransform != null )
            glyphTransform.transform(result,result);

        result.x += b.getX();
        result.y += b.getY();
        return result;
    }

    /**
     * Implementation of {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getRotationOfChar(int charnum)}.
     */
    protected float getRotationOfChar(Element element, int charnum){

        AttributedCharacterIterator aci;
        aci = ((TextNode)node).getAttributedCharacterIterator();
        //first the first character for the element
        int firstChar = getElementStartIndex(aci,element);

        if ( firstChar == -1 )
            return 0;

        //retrieve the text run for the text node
        List list = getTextRuns((TextNode)node);

        //find the glyph information for the character 'charnum'
        CharacterInformation info;
        info = getCharacterInformation(list, firstChar,charnum, aci);
            
        double angle = 0.0;
        int nbGlyphs = 0;

        if ( info != null ){
            GVTGlyphVector it = info.layout.getGlyphVector();

            for( int k = info.glyphIndexStart ;
                 k <= info.glyphIndexEnd ;
                 k++ ){
                if (!it.isGlyphVisible(k)) continue;

                nbGlyphs++;
                
                //the glyph transform contains only a scale and a rotate.
                AffineTransform glyphTransform = it.getGlyphTransform(k);
                if ( glyphTransform == null ) continue;

                double glyphAngle = 0.0;
                double cosTheta = glyphTransform.getScaleX();
                double sinTheta = glyphTransform.getShearX();
                
                //extract the angle
                if ( cosTheta == 0.0 ){
                    if ( sinTheta > 0 ) glyphAngle = Math.PI;
                    else                glyphAngle = -Math.PI;
                } else {
                    glyphAngle = Math.atan(sinTheta/cosTheta);
                    if ( cosTheta < 0 )
                        glyphAngle += Math.PI;
                }
                //get a degrees value for the angle
                //SVG angle are clock wise java anticlockwise 
                
                glyphAngle = (Math.toDegrees( - glyphAngle ) ) % 360.0;
                
                //remove the orientation from the value
                angle += glyphAngle - info.getComputedOrientationAngle();
            }
        }
        if (nbGlyphs == 0) return 0;
        return (float)(angle / nbGlyphs );
    }

    /**
     * Implementation of {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getComputedTextLength()}.
     */
    protected float getComputedTextLength(Element e) {
        return getSubStringLength(e,0,getNumberOfChars(e));
    }

    /**
     * Implementation of {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getSubStringLength(int charnum,int nchars)}.
     */
    protected float getSubStringLength(Element element,
                                       int charnum, 
                                       int nchars){
        if (nchars == 0) {
            return 0;
        }

        float length = 0;

        AttributedCharacterIterator aci;
        aci = ((TextNode)node).getAttributedCharacterIterator();
        TextNode textNode = (TextNode)node;

        int firstChar = getElementStartIndex(aci,element);

        if ( firstChar == -1 )
            return -1;

        List list = getTextRuns(textNode);

        CharacterInformation currentInfo;
        currentInfo = getCharacterInformation(list, firstChar,charnum,aci);
        CharacterInformation lastCharacterInRunInfo = null;
        int chIndex = currentInfo.characterIndex+1;
        GVTGlyphVector vector = currentInfo.layout.getGlyphVector();
        float [] advs = currentInfo.layout.getGlyphAdvances();
        boolean [] glyphTrack = new boolean[advs.length];
        for( int k = charnum +1; k < charnum +nchars ; k++) {
            if (currentInfo.layout.isOnATextPath() ){
                for (int gi = currentInfo.glyphIndexStart;
                     gi <= currentInfo.glyphIndexEnd; gi++) {
                    if ((vector.isGlyphVisible(gi)) && !glyphTrack[gi])
                        length += advs[gi+1]-advs[gi];
                    glyphTrack[gi] = true;
                }
                CharacterInformation newInfo;
                newInfo = getCharacterInformation(list, firstChar, k, aci);
                if (newInfo.layout != currentInfo.layout) {
                    vector = newInfo.layout.getGlyphVector();
                    advs = newInfo.layout.getGlyphAdvances();
                    glyphTrack = new boolean[advs.length];
                    chIndex = currentInfo.characterIndex+1;
                }
                currentInfo = newInfo;
            } else {
                //reach the next run
                if ( currentInfo.layout.hasCharacterIndex(chIndex) ){
                    chIndex++;
                    continue;
                }

                lastCharacterInRunInfo = getCharacterInformation
                    (list,firstChar,k-1,aci);

                //if the text run change compute the distance between the 
                //first character of the run and the last
                length += distanceFirstLastCharacterInRun
                    (currentInfo,lastCharacterInRunInfo);

                currentInfo = getCharacterInformation(list,firstChar,k,aci);
                chIndex = currentInfo.characterIndex+1;
                vector  = currentInfo.layout.getGlyphVector();
                advs    = currentInfo.layout.getGlyphAdvances();
                glyphTrack = new boolean[advs.length];
                lastCharacterInRunInfo = null;
            }
        }

        if (currentInfo.layout.isOnATextPath() ){
            for (int gi = currentInfo.glyphIndexStart;
                 gi <= currentInfo.glyphIndexEnd; gi++) {
                if ((vector.isGlyphVisible(gi)) && !glyphTrack[gi])
                    length += advs[gi+1]-advs[gi];
                glyphTrack[gi] = true;
            }
        } else {
            if ( lastCharacterInRunInfo == null ){
                lastCharacterInRunInfo = getCharacterInformation
                    (list,firstChar,charnum+nchars-1,aci);
            }
            //add the length between the end position of the last character
            //and the first character in the run
            length += distanceFirstLastCharacterInRun
                (currentInfo,lastCharacterInRunInfo);
        }

        return length;
    }

    protected float distanceFirstLastCharacterInRun
        (CharacterInformation first, CharacterInformation last){
        
        float [] advs = first.layout.getGlyphAdvances();
        
        int firstStart = first.glyphIndexStart;
        int firstEnd   = first.glyphIndexEnd;
        int lastStart  = last.glyphIndexStart;
        int lastEnd    = last.glyphIndexEnd;

        int start = (firstStart<lastStart)?firstStart:lastStart;
        int end   = (firstEnd<lastEnd)?lastEnd:firstEnd;
        return advs[end+1] - advs[start];
    }

    protected float distanceBetweenRun
        (CharacterInformation last, CharacterInformation first){
        
        float distance;
        Point2D startPoint;
        Point2D endPoint;
        CharacterInformation info = new CharacterInformation();

        //determine where the last run stops

        info.layout = last.layout;
        info.glyphIndexEnd = last.layout.getGlyphCount()-1;

        startPoint = getEndPoint(info);

        //determine where the next run starts
        info.layout = first.layout;
        info.glyphIndexStart = 0;

        endPoint = getStartPoint(info);

        if( first.isVertical() ){
            distance = (float)(endPoint.getY() - startPoint.getY());
        }
        else{
            distance = (float)(endPoint.getX() - startPoint.getX());
        }
    
        return distance;
    }
                                                    

    /**
     * Select an ensemble of characters for that element.
     *
     * TODO : report the selection to the selection
     *  manager in JSVGComponent.
     */
    protected void selectSubString(Element element, int charnum, int nchars) {
        AttributedCharacterIterator aci;
        aci = ((TextNode)node).getAttributedCharacterIterator();
        TextNode textNode = (TextNode)node;

        int firstChar = getElementStartIndex(aci,element);

        if ( firstChar == -1 )
            return;

        List list = getTextRuns(textNode);

        int lastChar = getElementEndIndex(aci,element);

        CharacterInformation firstInfo, lastInfo;
        firstInfo = getCharacterInformation(list, firstChar,charnum,aci);
        lastInfo  = getCharacterInformation(list, firstChar,charnum+nchars-1,aci);
        
        Mark firstMark, lastMark;
        firstMark = textNode.getMarkerForChar(firstInfo.characterIndex,true);

        if ( lastInfo != null && lastInfo.characterIndex <= lastChar ){
            lastMark = textNode.getMarkerForChar(lastInfo.characterIndex,false);
        }
        else{
            lastMark = textNode.getMarkerForChar(lastChar,false);
        }

        ctx.getUserAgent().setTextSelection(firstMark,lastMark);
    }

    protected int getCharNumAtPosition(Element e, float x, float y){
        
        TextNode textNode = (TextNode)node;

        //check if there is an hit
        List list = getTextRuns(textNode);

        //going backward in the list to catch the last character
        // displayed at that position
        TextHit hit = null;

        for( int i = list.size()-1 ; i>= 0 && hit == null; i-- ){

            hit = ((StrokingTextPainter.TextRun)list.get(i)).getLayout().hitTestChar(x,y);
        }

        if ( hit == null ){
            return -1;
        }

        AttributedCharacterIterator aci = ((TextNode)node).getAttributedCharacterIterator();

        //found an hit, check if it belong to the element
        int first = getElementStartIndex( aci, e );
        int last  = getElementEndIndex( aci, e );

        int hitIndex = hit.getCharIndex();

        if ( hitIndex >= first && hitIndex <= last ){
            
            return hitIndex - first;
        }
        else{
            return -1;
        }
    }

    /**
     * Retrieve the list of layout for the 
     * text node.
     */
    protected List getTextRuns(TextNode node){
        //System.out.println(node.getTextRuns());
        if ( node.getTextRuns() == null ){
            //TODO : need to work out a solution
            //to compute the text runs
            node.getPrimitiveBounds();
        }
        //System.out.println(node.getTextRuns());
        return node.getTextRuns();
    }

    /**
     * Retrieve the information about a character
     * of en element. The element first character in
     * the ACI is 'firstChar' and the character
     * look for is the charnum th character in the 
     * element
     *
     * @param list list of the layouts
     * @param startIndex index in the ACI of the first
     *   character for the element
     * @param charnum index of the character (among the 
     *   characters of the element) looked for.
     *
     * @return information about the glyph representing the
     *  character
     */
    protected CharacterInformation getCharacterInformation
        (List list,int startIndex, int charnum, 
         AttributedCharacterIterator aci)
    {
        CharacterInformation info = new CharacterInformation();
        info.characterIndex = startIndex+charnum;

        for (int i = 0; i < list.size(); i++) {
            StrokingTextPainter.TextRun run = 
                (StrokingTextPainter.TextRun)list.get(i);

            if ( run.getLayout().hasCharacterIndex(info.characterIndex) ){
                info.layout = run.getLayout();

                aci.setIndex(info.characterIndex);

                //check is it is a altGlyph
                if (aci.getAttribute(ALT_GLYPH_HANDLER) != null){
                    info.glyphIndexStart = 0;
                    info.glyphIndexEnd = info.layout.getGlyphCount()-1;
                } else {
                    info.glyphIndexStart = info.layout.getGlyphIndex
                        (info.characterIndex);

                    //special case when the glyph does not have a unicode
                    //associated to it, it will return -1
                    if ( info.glyphIndexStart == -1 ){
                        info.glyphIndexStart = 0;
                        info.glyphIndexEnd = info.layout.getGlyphCount()-1;
                    }
                    else{
                        info.glyphIndexEnd = info.glyphIndexStart;
                    }
                }
                return info;
            }
        }
        return null;
    }

    /**
     * Helper class to collect information about one Glyph
     * in the GlyphVector
     */
    protected static class CharacterInformation{
        ///layout associated to the Glyph
        TextSpanLayout layout;
        ///GlyphIndex in the vector
        int glyphIndexStart;

        int glyphIndexEnd;

        ///Character index in the ACI.
        int characterIndex;

        /// Indicates is the glyph is vertical
        public boolean isVertical(){
            return layout.isVertical();
        }
        /// Retrieve the orientation angle for the Glyph
        public double getComputedOrientationAngle(){
            return layout.getComputedOrientationAngle(characterIndex);
        }
    }


    public Set getTextIntersectionSet(AffineTransform at,
                                       Rectangle2D rect) {
        TextNode tn  = (TextNode)node;
        List list = tn.getTextRuns();
        Set elems = new HashSet();
        for (int i = 0 ; i < list.size(); i++) {
            StrokingTextPainter.TextRun run;
            run = (StrokingTextPainter.TextRun)list.get(i);
            TextSpanLayout layout = run.getLayout();
            AttributedCharacterIterator aci = run.getACI();
            aci.first();
            Element elem = (Element)aci.getAttribute(TEXT_COMPOUND_DELIMITER);

            if (elem == null) continue;
            if (elems.contains(elem)) continue;
            if (!isTextSensitive(elem))   continue;

            Rectangle2D glBounds = layout.getBounds2D();
            if (glBounds != null)
                glBounds = at.createTransformedShape(glBounds).getBounds2D();

            if (!rect.intersects(glBounds))
                continue;

            GVTGlyphVector gv = layout.getGlyphVector();
            for (int g = 0; g < gv.getNumGlyphs(); g++) {
                Shape gBounds = gv.getGlyphLogicalBounds(g);
                if (gBounds != null)
                    gBounds = at.createTransformedShape
                        (gBounds).getBounds2D();

                if (gBounds.intersects(rect)) {
                    elems.add(elem);
                    break;
                }
            }
        }
        return elems;
    }

    public Set getTextEnclosureSet(AffineTransform at,
                                    Rectangle2D rect) {
        TextNode tn = (TextNode)node;

        Set elems = new HashSet();
        Set reject = new HashSet();
        List list = tn.getTextRuns();
        for (int i = 0 ; i < list.size(); i++) {
            StrokingTextPainter.TextRun run;
            run = (StrokingTextPainter.TextRun)list.get(i);
            TextSpanLayout layout = run.getLayout();
            AttributedCharacterIterator aci = run.getACI();
            aci.first();
            Element elem = (Element)aci.getAttribute(TEXT_COMPOUND_DELIMITER);

            if (elem == null) continue;
            if (reject.contains(elem)) continue;
            if (!isTextSensitive(elem)) {
                reject.add(elem);
                continue;
            }
                        
            Rectangle2D glBounds = layout.getBounds2D();
            if (glBounds != null)
                glBounds = at.createTransformedShape
                    (glBounds).getBounds2D();

            if (rect.contains(glBounds)) {
                elems.add(elem);
            } else {
                reject.add(elem);
                elems.remove(elem);
            }
        }

        return elems;
    }

    public static boolean getTextIntersection(BridgeContext ctx,
                                              Element elem,
                                              AffineTransform ati,
                                              Rectangle2D rect,
                                              boolean checkSensitivity) {
        SVGContext svgCtx = null;
        if (elem instanceof SVGOMElement) 
            svgCtx  = ((SVGOMElement)elem).getSVGContext();
        if (svgCtx == null) return false;

        SVGTextElementBridge txtBridge = null;
        if (svgCtx instanceof SVGTextElementBridge) 
            txtBridge = (SVGTextElementBridge)svgCtx;
        else if (svgCtx instanceof AbstractTextChildSVGContext) {
            AbstractTextChildSVGContext childCtx;
            childCtx = (AbstractTextChildSVGContext)svgCtx;
            txtBridge = childCtx.getTextBridge();
        }
        if (txtBridge == null) return false;

        TextNode tn      = (TextNode)txtBridge.node;
        Element  txtElem = txtBridge.e;

        AffineTransform at = tn.getGlobalTransform();
        at.preConcatenate(ati);

        Rectangle2D tnRect;
        tnRect = tn.getBounds();
        tnRect = at.createTransformedShape(tnRect).getBounds2D();
        if (!rect.intersects(tnRect)) return false;

        List list = tn.getTextRuns();
        for (int i = 0 ; i < list.size(); i++) {
            StrokingTextPainter.TextRun run;
            run = (StrokingTextPainter.TextRun)list.get(i);
            TextSpanLayout layout = run.getLayout();
            AttributedCharacterIterator aci = run.getACI();
            aci.first();
            Element runElem = (Element)aci.getAttribute
                (TEXT_COMPOUND_DELIMITER);
            if (runElem == null) continue;

            // Only consider runElem if it is sensitive.
            if (checkSensitivity && !isTextSensitive(runElem)) continue;

            Element p = runElem;
            while ((p != null) && (p != txtElem) && (p != elem)) {
                p = (Element)p.getParentNode();
            }
            if (p != elem) continue;

            // runElem is a child of elem so check it out.
            Rectangle2D glBounds = layout.getBounds2D();
            if (glBounds == null) continue;
            glBounds = at.createTransformedShape(glBounds).getBounds2D();
            if (!rect.intersects(glBounds)) continue;
            
            GVTGlyphVector gv = layout.getGlyphVector();
            for (int g = 0; g < gv.getNumGlyphs(); g++) {
                Shape gBounds = gv.getGlyphLogicalBounds(g);
                if (gBounds != null)
                    gBounds = at.createTransformedShape
                        (gBounds).getBounds2D();

                if (gBounds.intersects(rect))
                    return true;
            }
        }
        return false;
    }

    public static Rectangle2D getTextBounds(BridgeContext ctx, Element elem,
                                            boolean checkSensitivity) {
        SVGContext svgCtx = null;
        if (elem instanceof SVGOMElement) 
            svgCtx  = ((SVGOMElement)elem).getSVGContext();
        if (svgCtx == null) return null;

        SVGTextElementBridge txtBridge = null;
        if (svgCtx instanceof SVGTextElementBridge) 
            txtBridge = (SVGTextElementBridge)svgCtx;
        else if (svgCtx instanceof AbstractTextChildSVGContext) {
            AbstractTextChildSVGContext childCtx;
            childCtx = (AbstractTextChildSVGContext)svgCtx;
            txtBridge = childCtx.getTextBridge();
        }
        if (txtBridge == null) return null;

        TextNode tn      = (TextNode)txtBridge.node;
        Element  txtElem = txtBridge.e;

        Rectangle2D ret = null;
        List list = tn.getTextRuns();
        if (list == null) return null;
        for (int i = 0 ; i < list.size(); i++) {
            StrokingTextPainter.TextRun run;
            run = (StrokingTextPainter.TextRun)list.get(i);
            TextSpanLayout layout = run.getLayout();
            AttributedCharacterIterator aci = run.getACI();
            aci.first();
            Element runElem = (Element)aci.getAttribute
                (TEXT_COMPOUND_DELIMITER);
            if (runElem == null) continue;

            // Only consider runElem if it is sensitive.
            if (checkSensitivity && !isTextSensitive(runElem)) continue;

            Element p = runElem;
            while ((p != null) && (p != txtElem) && (p != elem)) {
                p = (Element)p.getParentNode();
            }
            if (p != elem) continue;

            // runElem is a child of elem so include it's bounds.
            Rectangle2D glBounds = layout.getBounds2D();
            if (glBounds != null) {
                if (ret == null) ret = (Rectangle2D)glBounds.clone();
                else             ret.add(glBounds);
            }
        }
        return ret;
    }
         

    public static boolean isTextSensitive(Element e) {
        int     ptrEvts = CSSUtilities.convertPointerEvents(e);
        switch (ptrEvts) {
        case GraphicsNode.VISIBLE_PAINTED:
        case GraphicsNode.VISIBLE_FILL:
        case GraphicsNode.VISIBLE_STROKE:
        case GraphicsNode.VISIBLE:
            return CSSUtilities.convertVisibility(e);
        case GraphicsNode.PAINTED:
        case GraphicsNode.FILL:
        case GraphicsNode.STROKE:
        case GraphicsNode.ALL:
            return true;
        case GraphicsNode.NONE:
        default:
            return false;
        }
    }
}
