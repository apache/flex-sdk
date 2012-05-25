/*

   Copyright 1999-2003  The Apache Software Foundation 

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

package org.apache.flex.forks.batik.bridge.svg12;

import java.awt.Shape;
import java.awt.font.TextAttribute;
import java.awt.geom.AffineTransform;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;
import java.text.AttributedString;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.LinkedList;
import java.util.Map;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.EventTarget;

import org.apache.flex.forks.batik.bridge.Bridge;
import org.apache.flex.forks.batik.bridge.BridgeException;
import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.CSSUtilities;
import org.apache.flex.forks.batik.bridge.GraphicsNodeBridge;
import org.apache.flex.forks.batik.bridge.GVTBuilder;
import org.apache.flex.forks.batik.bridge.SVGTextElementBridge;
import org.apache.flex.forks.batik.bridge.SVGUtilities;
import org.apache.flex.forks.batik.bridge.TextUtilities;
import org.apache.flex.forks.batik.bridge.UnitProcessor;
import org.apache.flex.forks.batik.bridge.UserAgent;
import org.apache.flex.forks.batik.bridge.SVGAElementBridge;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.value.ComputedValue;
import org.apache.flex.forks.batik.css.engine.value.svg12.SVG12ValueConstants;
import org.apache.flex.forks.batik.css.engine.value.svg12.LineHeightValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueConstants;

import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;

import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.TextNode;
import org.apache.flex.forks.batik.gvt.flow.BlockInfo;
import org.apache.flex.forks.batik.gvt.flow.FlowTextNode;
import org.apache.flex.forks.batik.gvt.flow.RegionInfo;
import org.apache.flex.forks.batik.gvt.flow.TextLineBreaks;

import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.TextPaintInfo;
import org.apache.flex.forks.batik.gvt.text.TextPath;

import org.apache.flex.forks.batik.util.SVG12Constants;
import org.apache.flex.forks.batik.util.SVG12CSSConstants;

/**
 * Bridge class for the &lt;flowRoot> element.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: SVGFlowRootElementBridge.java,v 1.4 2005/03/27 08:58:30 cam Exp $
 */
public class SVGFlowRootElementBridge extends SVGTextElementBridge {

    public static final AttributedCharacterIterator.Attribute FLOW_PARAGRAPH
        = GVTAttributedCharacterIterator.TextAttribute.FLOW_PARAGRAPH;

    public static final AttributedCharacterIterator.Attribute 
        FLOW_EMPTY_PARAGRAPH
        = GVTAttributedCharacterIterator.TextAttribute.FLOW_EMPTY_PARAGRAPH;

    public static final AttributedCharacterIterator.Attribute FLOW_LINE_BREAK
        = GVTAttributedCharacterIterator.TextAttribute.FLOW_LINE_BREAK;
    
    public static final AttributedCharacterIterator.Attribute FLOW_REGIONS
        = GVTAttributedCharacterIterator.TextAttribute.FLOW_REGIONS;

    public static final AttributedCharacterIterator.Attribute LINE_HEIGHT
        = GVTAttributedCharacterIterator.TextAttribute.LINE_HEIGHT;

    /**
     * Constructs a new bridge for the &lt;flowRoot> element.
     */
    public SVGFlowRootElementBridge() {}

    /**
     * Returns the SVG namespace URI.
     */
    public String getNamespaceURI() {
        return SVG12Constants.SVG_NAMESPACE_URI;
    }

    /**
     * Returns 'flowRoot'.
     */
    public String getLocalName() {
        return SVG12Constants.SVG_FLOW_ROOT_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGFlowRootElementBridge();
    }

    /**
     * Returns false as text is not a container.
     */
    public boolean isComposite() {
        return false;
    }

    protected GraphicsNode instantiateGraphicsNode() {
        return new FlowTextNode();
    }

    /**
     * Returns the text node location In this case the text node may
     * have serveral effective locations (one for each flow region).
     * So it always returns 0,0.
     *
     * @param ctx the bridge context to use
     * @param e the text element
     */
    protected Point2D getLocation(BridgeContext ctx, Element e) {
        return new Point2D.Float(0,0);
    }

    protected boolean isTextElement(Element e) {
        if (!SVG_NAMESPACE_URI.equals(e.getNamespaceURI()))
            return false;
        String nodeName = e.getLocalName();
        return (nodeName.equals(SVG12Constants.SVG_FLOW_DIV_TAG) ||
                nodeName.equals(SVG12Constants.SVG_FLOW_LINE_TAG) ||
                nodeName.equals(SVG12Constants.SVG_FLOW_PARA_TAG) ||
                nodeName.equals(SVG12Constants.SVG_FLOW_REGION_BREAK_TAG) ||
                nodeName.equals(SVG12Constants.SVG_FLOW_SPAN_TAG));
    }

    protected boolean isTextChild(Element e) {
        if (!SVG_NAMESPACE_URI.equals(e.getNamespaceURI()))
            return false;
        String nodeName = e.getLocalName();
        return (nodeName.equals(SVG12Constants.SVG_A_TAG) ||
                nodeName.equals(SVG12Constants.SVG_FLOW_LINE_TAG) ||
                nodeName.equals(SVG12Constants.SVG_FLOW_PARA_TAG) ||
                nodeName.equals(SVG12Constants.SVG_FLOW_REGION_BREAK_TAG) ||
                nodeName.equals(SVG12Constants.SVG_FLOW_SPAN_TAG));
    }
    
    protected void computeLaidoutText(BridgeContext ctx, 
                                       Element e,
                                       GraphicsNode node) {
        super.computeLaidoutText(ctx, getFlowDivElement(e), node);
    }

    /**
     * Creates the attributed string which represents the given text
     * element children.
     *
     * @param ctx the bridge context to use
     * @param element the text element
     */
    protected AttributedString buildAttributedString(BridgeContext ctx,
                                                     Element element) {
        List rgns = getRegions(ctx, element);
        AttributedString ret = getFlowDiv(ctx, element);
        ret.addAttribute(FLOW_REGIONS, rgns, 0, 1);
        TextLineBreaks.findLineBrk(ret);
        // dumpACIWord(ret);
        return ret;
    }

    protected void dumpACIWord(AttributedString as) {
        String chars = "";
        String brkStr = "";
        AttributedCharacterIterator aci = as.getIterator();
        AttributedCharacterIterator.Attribute WORD_LIMIT =
            TextLineBreaks.WORD_LIMIT;

        for (char ch = aci.current(); 
             ch!=AttributedCharacterIterator.DONE;
             ch = aci.next()) {
            chars  += ch + "  ";
            int w = ((Integer)aci.getAttribute(WORD_LIMIT)).intValue();
            if (w >=10)
                brkStr += ""+w+" ";
            else 
                brkStr += ""+w+"  ";
        }
        System.out.println(chars);
        System.out.println(brkStr);
    }

    protected Element getFlowDivElement(Element elem) {
        String eNS = elem.getNamespaceURI();
        if (!eNS.equals(SVG_NAMESPACE_URI)) return null;

        String nodeName = elem.getLocalName();
        if (nodeName.equals(SVG12Constants.SVG_FLOW_DIV_TAG)) return elem;

        if (!nodeName.equals(SVG12Constants.SVG_FLOW_ROOT_TAG)) return null;
        
        for (Node n = elem.getFirstChild();
             n != null; n = n.getNextSibling()) {
            if (n.getNodeType()     != Node.ELEMENT_NODE) continue;

            String nNS = n.getNamespaceURI();
            if (!SVG_NAMESPACE_URI.equals(nNS)) continue;

            Element e = (Element)n;
            String ln = e.getLocalName();
            if (ln.equals(SVG12Constants.SVG_FLOW_DIV_TAG)) 
                return e;
        }
        return null;
    }

    protected AttributedString getFlowDiv(BridgeContext ctx, Element element) {
        Element flowDiv = getFlowDivElement(element);
        if (flowDiv == null) return null;

        return gatherFlowPara(ctx, flowDiv);
    }

    protected AttributedString gatherFlowPara
        (BridgeContext ctx, Element div) {
        AttributedStringBuffer asb = new AttributedStringBuffer();
        List paraEnds  = new ArrayList();
        List paraElems = new ArrayList();
        List lnLocs    = new ArrayList();
        for (Node n = div.getFirstChild();
             n != null; n = n.getNextSibling()) {
            if (n.getNodeType()     != Node.ELEMENT_NODE) continue;
            if (!getNamespaceURI().equals(n.getNamespaceURI())) continue;
            Element e = (Element)n;

            String ln = e.getLocalName();
            if (ln.equals(SVG12Constants.SVG_FLOW_PARA_TAG)) {
                fillAttributedStringBuffer(ctx, e, true, null, asb, lnLocs);

                paraElems.add(e);
                paraEnds.add(new Integer(asb.length()));
            } else if (ln.equals(SVG12Constants.SVG_FLOW_REGION_BREAK_TAG)) {
                fillAttributedStringBuffer(ctx, e, true, null, asb, lnLocs);

                paraElems.add(e);
                paraEnds.add(new Integer(asb.length()));
            }
        }

        // Layer in the PARAGRAPH/LINE_BREAK Attributes so we can
        // break up text chunks.
        AttributedString ret = asb.toAttributedString();

        // Note: The Working Group (in conjunction with XHTML working
        // group) has decided that multiple line elements collapse.
        int prevLN = 0;
        Iterator lnIter = lnLocs.iterator();
        while (lnIter.hasNext()) {
            int nextLN = ((Integer)lnIter.next()).intValue();
            if (nextLN == prevLN) continue;

            // System.out.println("Attr: [" + prevLN + "," + nextLN + "]");
            ret.addAttribute(FLOW_LINE_BREAK, 
                             new Object(),
                             prevLN, nextLN);
            prevLN  = nextLN;
        }

        int start=0;
        int end;
        List emptyPara = null;
        for (int i=0; i<paraElems.size(); i++, start=end) {
            Element elem = (Element)paraElems.get(i);
            end  = ((Integer)paraEnds.get(i)).intValue();
            if (start == end) {
                if (emptyPara == null)
                    emptyPara = new LinkedList();
                emptyPara.add(makeBlockInfo(ctx, elem));
                continue;
            }
            // System.out.println("Para: [" + start + ", " + end + "]");
            ret.addAttribute(FLOW_PARAGRAPH, makeBlockInfo(ctx, elem), 
                             start, end);
            if (emptyPara != null) {
                ret.addAttribute(FLOW_EMPTY_PARAGRAPH, emptyPara, start, end);
                emptyPara = null;
            }
        }

        return ret;
    }

    protected List getRegions(BridgeContext ctx, Element element)  {
        // Element comes in as flowDiv element we want flowRoot.
        element = (Element)element.getParentNode();
        List ret = new LinkedList();
        for (Node n = element.getFirstChild();
             n != null; n = n.getNextSibling()) {
            
            if (n.getNodeType()     != Node.ELEMENT_NODE) continue;
            if (!SVG12Constants.SVG_NAMESPACE_URI.equals(n.getNamespaceURI())) 
                continue;

            Element e = (Element)n;
            String ln = e.getLocalName();
            if (!SVG12Constants.SVG_FLOW_REGION_TAG.equals(ln))  continue;

            // our default alignment is to the top of the flow rect.
            float verticalAlignment = 0.0f;
            
            gatherRegionInfo(ctx, e, verticalAlignment, ret);
        }

        return ret;
    }
    
    protected void gatherRegionInfo(BridgeContext ctx, Element rgn,
                                    float verticalAlign, List regions) {

        GVTBuilder builder = ctx.getGVTBuilder();
        for (Node n = rgn.getFirstChild(); 
             n != null; n = n.getNextSibling()) {

            if (n.getNodeType()     != Node.ELEMENT_NODE) continue;
            if (!getNamespaceURI().equals(n.getNamespaceURI())) continue;
            Element e = (Element)n;

            GraphicsNode gn = builder.build(ctx, e) ;
            if (gn == null) continue;

            Shape s = gn.getOutline();
            if (s == null) continue;
            AffineTransform at = gn.getTransform();
            if (at != null) 
                s = at.createTransformedShape(s);
            regions.add(new RegionInfo(s, verticalAlign));
        }
    }

    protected int startLen;

    /**
     * Fills the given AttributedStringBuffer.
     */
    protected void fillAttributedStringBuffer(BridgeContext ctx,
                                              Element element,
                                              boolean top,
                                              Integer bidiLevel,
                                              AttributedStringBuffer asb,
                                              List lnLocs) {
        // 'requiredFeatures', 'requiredExtensions', 'systemLanguage' &
        // 'display="none".
        if ((!SVGUtilities.matchUserAgent(element, ctx.getUserAgent())) ||
            (!CSSUtilities.convertDisplay(element))) {
            return;
        }

        String  s        = XMLSupport.getXMLSpace(element);
        boolean preserve = s.equals(SVG_PRESERVE_VALUE);
        boolean prevEndsWithSpace;
        Element nodeElement = element;

        if (top)
            endLimit = startLen = asb.length();

        if (preserve)
            endLimit = startLen;
        
	Map map = getAttributeMap(ctx, element, null, bidiLevel);
	Object o = map.get(TextAttribute.BIDI_EMBEDDING);
        Integer subBidiLevel = bidiLevel;
	if (o != null)
	    subBidiLevel = (Integer)o;

        int lineBreak = -1;
        if (lnLocs.size() != 0)
            lineBreak = ((Integer)lnLocs.get(lnLocs.size()-1)).intValue();

        for (Node n = element.getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            
            if (preserve) {
                prevEndsWithSpace = false;
            } else {
                int len = asb.length();
                if (len == startLen) 
                    prevEndsWithSpace = true;
                else {
                    prevEndsWithSpace = (asb.getLastChar() == ' ');
                    int idx = lnLocs.size()-1;
                    if (!prevEndsWithSpace && (idx >= 0)) {
                        Integer i = (Integer)lnLocs.get(idx);
                        if (i.intValue() == len)
                            prevEndsWithSpace = true;
                    }
                }
            }

            switch (n.getNodeType()) {
            case Node.ELEMENT_NODE:
                // System.out.println("Element: " + n);
                if (!SVG_NAMESPACE_URI.equals(n.getNamespaceURI()))
                    break;
                
                nodeElement = (Element)n;

                String ln = n.getLocalName();

                if (ln.equals(SVG12Constants.SVG_FLOW_LINE_TAG)) {
                    fillAttributedStringBuffer(ctx, nodeElement, 
                                               false, subBidiLevel, 
					       asb, lnLocs);
                    // System.out.println("Line: " + asb.length() + 
                    //                    " - '" +  asb + "'");
                    lineBreak = asb.length();
                    lnLocs.add(new Integer(lineBreak));
                } else if (ln.equals(SVG12Constants.SVG_FLOW_SPAN_TAG) ||
                           ln.equals(SVG12Constants.SVG_ALT_GLYPH_TAG)) {
                    fillAttributedStringBuffer(ctx, nodeElement,
                                               false, subBidiLevel, 
					       asb, lnLocs);
                } else if (ln.equals(SVG_A_TAG)) {
                    if (ctx.isInteractive()) {
                        EventTarget target = (EventTarget)nodeElement;
                        UserAgent ua = ctx.getUserAgent();
                        target.addEventListener
                            (SVG_EVENT_CLICK, 
                             new SVGAElementBridge.AnchorListener(ua),
                             false);
                    
                        target.addEventListener
                            (SVG_EVENT_MOUSEOVER,
                             new SVGAElementBridge.CursorMouseOverListener(ua),
                             false);
                    
                        target.addEventListener
                            (SVG_EVENT_MOUSEOUT,
                             new SVGAElementBridge.CursorMouseOutListener(ua),
                             false);
                    }
                    fillAttributedStringBuffer(ctx,
                                               nodeElement,
                                               false, subBidiLevel,
                                               asb, lnLocs);
                } else if (ln.equals(SVG_TREF_TAG)) {
                    String uriStr = XLinkSupport.getXLinkHref((Element)n);
                    Element ref = ctx.getReferencedElement((Element)n, uriStr);
                    s = TextUtilities.getElementContent(ref);
                    s = normalizeString(s, preserve, prevEndsWithSpace);
                    if (s != null) {
                        Map m = getAttributeMap(ctx, nodeElement, null, 
						bidiLevel);
                        asb.append(s, m);
                    }
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
            while ((endLimit < asb.length()) && (asb.getLastChar() == ' ')) {
                int idx = lnLocs.size()-1;
                int len = asb.length();
                if (idx >= 0) {
                    Integer i = (Integer)lnLocs.get(idx);
                    if (i.intValue() >= len) {
                        i = new Integer(len-1);
                        lnLocs.set(idx, i);
                        idx--;
                        while (idx >= 0) {
                            i = (Integer)lnLocs.get(idx);
                            if (i.intValue() < len-1)
                                break;
                            lnLocs.remove(idx);
                            idx--;
                        }
                    }
                }
                asb.stripLast();
            }
        }
    }

    /**
     * Returns the map to pass to the current characters.
     */
    protected Map getAttributeMap(BridgeContext ctx,
                                  Element element,
                                  TextPath textPath,
                                  Integer bidiLevel) {
        Map result = super.getAttributeMap(ctx, element, textPath, bidiLevel);

        float fontSize   = TextUtilities.convertFontSize(element).floatValue();
        float lineHeight = getLineHeight(ctx, element, fontSize);
        result.put(LINE_HEIGHT, new Float(lineHeight));
        
        return result;
    }

    protected final static 
        GVTAttributedCharacterIterator.TextAttribute TEXTPATH = 
        GVTAttributedCharacterIterator.TextAttribute.TEXTPATH;

    protected final static 
        GVTAttributedCharacterIterator.TextAttribute ANCHOR_TYPE = 
        GVTAttributedCharacterIterator.TextAttribute.ANCHOR_TYPE;

    protected final static 
        GVTAttributedCharacterIterator.TextAttribute LETTER_SPACING = 
        GVTAttributedCharacterIterator.TextAttribute.LETTER_SPACING;

    protected final static 
        GVTAttributedCharacterIterator.TextAttribute WORD_SPACING = 
        GVTAttributedCharacterIterator.TextAttribute.WORD_SPACING;

    protected final static 
        GVTAttributedCharacterIterator.TextAttribute KERNING = 
        GVTAttributedCharacterIterator.TextAttribute.KERNING;

    protected void checkMap(Map attrs) {
        if (attrs.containsKey(TEXTPATH)) {
            return; // Problem, unsupported attr
        }

        if (attrs.containsKey(ANCHOR_TYPE)) {
            return; // Problem, unsupported attr
        }

        if (attrs.containsKey(LETTER_SPACING)) {
            return; // Problem, unsupported attr
        }

        if (attrs.containsKey(WORD_SPACING)) {
            return; // Problem, unsupported attr
        }

        if (attrs.containsKey(KERNING)) {
            return; // Problem, unsupported attr
        }
    }

    int marginTopIndex    = -1;
    int marginRightIndex  = -1;
    int marginBottomIndex = -1;
    int marginLeftIndex   = -1;
    int indentIndex       = -1;
    int textAlignIndex    = -1;
    int lineHeightIndex   = -1;

    protected void initCSSPropertyIndexes(Element e) {
        CSSEngine eng = CSSUtilities.getCSSEngine(e);
        marginTopIndex    = eng.getPropertyIndex(SVG12CSSConstants.CSS_MARGIN_TOP_PROPERTY);
        marginRightIndex  = eng.getPropertyIndex(SVG12CSSConstants.CSS_MARGIN_RIGHT_PROPERTY);
        marginBottomIndex = eng.getPropertyIndex(SVG12CSSConstants.CSS_MARGIN_BOTTOM_PROPERTY);
        marginLeftIndex   = eng.getPropertyIndex(SVG12CSSConstants.CSS_MARGIN_LEFT_PROPERTY);
        indentIndex       = eng.getPropertyIndex(SVG12CSSConstants.CSS_INDENT_PROPERTY);
        textAlignIndex    = eng.getPropertyIndex(SVG12CSSConstants.CSS_TEXT_ALIGN_PROPERTY);
        lineHeightIndex   = eng.getPropertyIndex(SVG12CSSConstants.CSS_LINE_HEIGHT_PROPERTY);
    }

    public BlockInfo makeBlockInfo(BridgeContext ctx, Element element) {
        if (marginTopIndex == -1) initCSSPropertyIndexes(element);

        Value v;
        v = CSSUtilities.getComputedStyle(element, marginTopIndex);
        float top = v.getFloatValue();

        v = CSSUtilities.getComputedStyle(element, marginRightIndex);
        float right = v.getFloatValue();

        v = CSSUtilities.getComputedStyle(element, marginBottomIndex);
        float bottom = v.getFloatValue();

        v = CSSUtilities.getComputedStyle(element, marginLeftIndex);
        float left = v.getFloatValue();

        v = CSSUtilities.getComputedStyle(element, indentIndex);
        float indent = v.getFloatValue();

        v = CSSUtilities.getComputedStyle(element, textAlignIndex);
        if (v == ValueConstants.INHERIT_VALUE) {
            v = CSSUtilities.getComputedStyle(element, 
                                              SVGCSSEngine.DIRECTION_INDEX);
            if (v == ValueConstants.LTR_VALUE) 
                v = SVG12ValueConstants.START_VALUE;
            else
                v = SVG12ValueConstants.END_VALUE;
        }
        int textAlign;
        if (v == SVG12ValueConstants.START_VALUE)
            textAlign = BlockInfo.ALIGN_START;
        else if (v == SVG12ValueConstants.MIDDLE_VALUE)
            textAlign = BlockInfo.ALIGN_MIDDLE;
        else if (v == SVG12ValueConstants.END_VALUE)
            textAlign = BlockInfo.ALIGN_END;
        else
            textAlign = BlockInfo.ALIGN_FULL;

        Map   fontAttrs      = getFontProperties(ctx, element, null);
        Float fs             = (Float)fontAttrs.get(TextAttribute.SIZE);
        float fontSize       = fs.floatValue();
        float lineHeight     = getLineHeight(ctx, element, fontSize);
        List  fontFamilyList = getFontFamilyList(element, ctx);

        String ln = element.getLocalName();
        boolean rgnBr;
        rgnBr = ln.equals(SVG12Constants.SVG_FLOW_REGION_BREAK_TAG);
        return new BlockInfo(top, right, bottom, left, indent, textAlign, 
                             lineHeight, fontFamilyList, fontAttrs,
                             rgnBr);
    }

    protected float getLineHeight(BridgeContext ctx, Element element, 
                                  float fontSize) {
        if (lineHeightIndex == -1) initCSSPropertyIndexes(element);

        Value v = CSSUtilities.getComputedStyle(element, lineHeightIndex);
        if ((v == ValueConstants.INHERIT_VALUE) ||
            (v == SVG12ValueConstants.NORMAL_VALUE)) {
            return fontSize*1.1f;
        }

        float lineHeight = v.getFloatValue();
        if (v instanceof ComputedValue)
            v = ((ComputedValue)v).getComputedValue();
        if ((v instanceof LineHeightValue) &&
            ((LineHeightValue)v).getFontSizeRelative())
            lineHeight *= fontSize;
        return lineHeight;
    }
}
