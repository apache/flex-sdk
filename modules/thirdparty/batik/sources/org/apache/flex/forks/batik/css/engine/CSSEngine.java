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
package org.apache.flex.forks.batik.css.engine;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.apache.flex.forks.batik.css.engine.sac.CSSConditionFactory;
import org.apache.flex.forks.batik.css.engine.sac.CSSSelectorFactory;
import org.apache.flex.forks.batik.css.engine.sac.ExtendedSelector;
import org.apache.flex.forks.batik.css.engine.value.ComputedValue;
import org.apache.flex.forks.batik.css.engine.value.InheritValue;
import org.apache.flex.forks.batik.css.engine.value.ShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.css.parser.ExtendedParser;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.ParsedURL;

import org.w3c.css.sac.CSSException;
import org.w3c.css.sac.DocumentHandler;
import org.w3c.css.sac.InputSource;
import org.w3c.css.sac.LexicalUnit;
import org.w3c.css.sac.SACMediaList;
import org.w3c.css.sac.SelectorList;
import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.events.MutationEvent;

/**
 * This is the base class for all the CSS engines.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSEngine.java 606891 2007-12-26 11:45:26Z cam $
 */
public abstract class CSSEngine {

    /**
     * Returns the CSS parent node of the given node.
     */
    public static Node getCSSParentNode(Node n) {
        if (n instanceof CSSNavigableNode) {
            return ((CSSNavigableNode) n).getCSSParentNode();
        }
        return n.getParentNode();
    }

    /**
     * Returns the CSS first child node of the given node.
     */
    protected static Node getCSSFirstChild(Node n) {
        if (n instanceof CSSNavigableNode) {
            return ((CSSNavigableNode) n).getCSSFirstChild();
        }
        return n.getFirstChild();
    }

    /**
     * Returns the CSS next sibling node of the given node.
     */
    protected static Node getCSSNextSibling(Node n) {
        if (n instanceof CSSNavigableNode) {
            return ((CSSNavigableNode) n).getCSSNextSibling();
        }
        return n.getNextSibling();
    }

    /**
     * Returns the CSS previous sibling node of the given node.
     */
    protected static Node getCSSPreviousSibling(Node n) {
        if (n instanceof CSSNavigableNode) {
            return ((CSSNavigableNode) n).getCSSPreviousSibling();
        }
        return n.getPreviousSibling();
    }

    /**
     * Returns the next stylable parent of the given element.
     */
    public static CSSStylableElement getParentCSSStylableElement(Element elt) {
        Node n = getCSSParentNode(elt);
        while (n != null) {
            if (n instanceof CSSStylableElement) {
                return (CSSStylableElement) n;
            }
            n = getCSSParentNode(n);
        }
        return null;
    }

    /**
     * The user agent used for showing error messages.
     */
    protected CSSEngineUserAgent userAgent;

    /**
     * The CSS context.
     */
    protected CSSContext cssContext;

    /**
     * The associated document.
     */
    protected Document document;

    /**
     * The document URI.
     */
    protected ParsedURL documentURI;

    /**
     * Whether the document is a CSSNavigableDocument.
     */
    protected boolean isCSSNavigableDocument;

    /**
     * The property/int mappings.
     */
    protected StringIntMap indexes;

    /**
     * The shorthand-property/int mappings.
     */
    protected StringIntMap shorthandIndexes;

    /**
     * The value managers.
     */
    protected ValueManager[] valueManagers;

    /**
     * The shorthand managers.
     */
    protected ShorthandManager[] shorthandManagers;

    /**
     * The CSS parser.
     */
    protected ExtendedParser parser;

    /**
     * The pseudo-element names.
     */
    protected String[] pseudoElementNames;

    /**
     * The font-size property index.
     */
    protected int fontSizeIndex = -1;

    /**
     * The line-height property index.
     */
    protected int lineHeightIndex = -1;

    /**
     * The color property index.
     */
    protected int colorIndex = -1;

    /**
     * The user-agent style-sheet.
     */
    protected StyleSheet userAgentStyleSheet;

    /**
     * The user style-sheet.
     */
    protected StyleSheet userStyleSheet;

    /**
     * The media to use to cascade properties.
     */
    protected SACMediaList media;

    /**
     * The DOM nodes which contains StyleSheets.
     */
    protected List styleSheetNodes;

    /**
     * List of StyleMap objects, one for each @font-face rule
     * encountered by this CSSEngine.
     */
    protected List fontFaces = new LinkedList();

    /**
     * The style attribute namespace URI.
     */
    protected String styleNamespaceURI;

    /**
     * The style attribute local name.
     */
    protected String styleLocalName;

    /**
     * The class attribute namespace URI.
     */
    protected String classNamespaceURI;

    /**
     * The class attribute local name.
     */
    protected String classLocalName;

    /**
     * The non CSS presentational hints.
     */
    protected Set nonCSSPresentationalHints;

    /**
     * The non CSS presentational hints namespace URI.
     */
    protected String nonCSSPresentationalHintsNamespaceURI;

    /**
     * The style declaration document handler.
     */
    protected StyleDeclarationDocumentHandler styleDeclarationDocumentHandler =
        new StyleDeclarationDocumentHandler();

    /**
     * The style declaration update handler.
     */
    protected StyleDeclarationUpdateHandler styleDeclarationUpdateHandler;

    /**
     * The style sheet document handler.
     */
    protected StyleSheetDocumentHandler styleSheetDocumentHandler =
        new StyleSheetDocumentHandler();

    /**
     * The style declaration document handler used to build a
     * StyleDeclaration object.
     */
    protected StyleDeclarationBuilder styleDeclarationBuilder =
        new StyleDeclarationBuilder();

    /**
     * The current element.
     */
    protected CSSStylableElement element;

    /**
     * The current base URI.
     */
    protected ParsedURL cssBaseURI;

    /**
     * The alternate stylesheet title.
     */
    protected String alternateStyleSheet;

    /**
     * Listener for CSSNavigableDocument events.
     */
    protected CSSNavigableDocumentHandler cssNavigableDocumentListener;

    /**
     * The DOMAttrModified event listener.
     */
    protected EventListener domAttrModifiedListener;

    /**
     * The DOMNodeInserted event listener.
     */
    protected EventListener domNodeInsertedListener;

    /**
     * The DOMNodeRemoved event listener.
     */
    protected EventListener domNodeRemovedListener;

    /**
     * The DOMSubtreeModified event listener.
     */
    protected EventListener domSubtreeModifiedListener;

    /**
     * The DOMCharacterDataModified event listener.
     */
    protected EventListener domCharacterDataModifiedListener;

    /**
     * Whether a style sheet as been removed from the document.
     */
    protected boolean styleSheetRemoved;

    /**
     * The right sibling of the last removed node.
     */
    protected Node removedStylableElementSibling;

    /**
     * The listeners.
     */
    protected List listeners = Collections.synchronizedList(new LinkedList());

    /**
     * The attributes found in stylesheets selectors.
     */
    protected Set selectorAttributes;

    /**
     * Used to fire a change event for all the properties.
     */
    protected final int[] ALL_PROPERTIES;

    /**
     * The CSS condition factory.
     */
    protected CSSConditionFactory cssConditionFactory;

    /**
     * Creates a new CSSEngine.
     * @param doc The associated document.
     * @param uri The document URI.
     * @param p The CSS parser.
     * @param vm The property value managers.
     * @param sm The shorthand properties managers.
     * @param pe The pseudo-element names supported by the associated
     *           XML dialect. Must be null if no support for pseudo-
     *           elements is required.
     * @param sns The namespace URI of the style attribute.
     * @param sln The local name of the style attribute.
     * @param cns The namespace URI of the class attribute.
     * @param cln The local name of the class attribute.
     * @param hints Whether the CSS engine should support non CSS
     *              presentational hints.
     * @param hintsNS The hints namespace URI.
     * @param ctx The CSS context.
     */
    protected CSSEngine(Document doc,
                        ParsedURL uri,
                        ExtendedParser p,
                        ValueManager[] vm,
                        ShorthandManager[] sm,
                        String[] pe,
                        String sns,
                        String sln,
                        String cns,
                        String cln,
                        boolean hints,
                        String hintsNS,
                        CSSContext ctx) {
        document = doc;
        documentURI = uri;
        parser = p;
        pseudoElementNames = pe;
        styleNamespaceURI = sns;
        styleLocalName = sln;
        classNamespaceURI = cns;
        classLocalName = cln;
        cssContext = ctx;

        isCSSNavigableDocument = doc instanceof CSSNavigableDocument;

        cssConditionFactory = new CSSConditionFactory(cns, cln, null, "id");

        int len = vm.length;
        indexes = new StringIntMap(len);
        valueManagers = vm;

        for (int i = len - 1; i >= 0; --i) {
            String pn = vm[i].getPropertyName();
            indexes.put(pn, i);
            if (fontSizeIndex == -1 &&
                pn.equals(CSSConstants.CSS_FONT_SIZE_PROPERTY)) {
                fontSizeIndex = i;
            }
            if (lineHeightIndex == -1 &&
                pn.equals(CSSConstants.CSS_LINE_HEIGHT_PROPERTY)) {
                lineHeightIndex = i;
            }
            if (colorIndex == -1 &&
                pn.equals(CSSConstants.CSS_COLOR_PROPERTY)) {
                colorIndex = i;
            }
        }

        len = sm.length;
        shorthandIndexes = new StringIntMap(len);
        shorthandManagers = sm;
        for (int i = len - 1; i >= 0; --i) {
            shorthandIndexes.put(sm[i].getPropertyName(), i);
        }

        if (hints) {
            nonCSSPresentationalHints = new HashSet(vm.length+sm.length);
            nonCSSPresentationalHintsNamespaceURI = hintsNS;
            len = vm.length;
            for (int i = 0; i < len; i++) {
                String pn = vm[i].getPropertyName();
                nonCSSPresentationalHints.add(pn);
            }
            len = sm.length;
            for (int i = 0; i < len; i++) {
                String pn = sm[i].getPropertyName();
                nonCSSPresentationalHints.add(pn);
            }
        }

        if (cssContext.isDynamic() && document instanceof EventTarget) {
            // Attach the mutation events listeners.
            addEventListeners((EventTarget) document);
            styleDeclarationUpdateHandler =
                new StyleDeclarationUpdateHandler();
        }

        ALL_PROPERTIES = new int[getNumberOfProperties()];
        for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
            ALL_PROPERTIES[i] = i;
        }
    }

    /**
     * Adds event listeners to the document to track CSS changes.
     */
    protected void addEventListeners(EventTarget doc) {
        if (isCSSNavigableDocument) {
            cssNavigableDocumentListener = new CSSNavigableDocumentHandler();
            CSSNavigableDocument cnd = (CSSNavigableDocument) doc;
            cnd.addCSSNavigableDocumentListener(cssNavigableDocumentListener);
        } else {
            domAttrModifiedListener = new DOMAttrModifiedListener();
            doc.addEventListener("DOMAttrModified",
                                 domAttrModifiedListener,
                                 false);
            domNodeInsertedListener = new DOMNodeInsertedListener();
            doc.addEventListener("DOMNodeInserted",
                                 domNodeInsertedListener,
                                 false);
            domNodeRemovedListener = new DOMNodeRemovedListener();
            doc.addEventListener("DOMNodeRemoved",
                                 domNodeRemovedListener,
                                 false);
            domSubtreeModifiedListener = new DOMSubtreeModifiedListener();
            doc.addEventListener("DOMSubtreeModified",
                                 domSubtreeModifiedListener,
                                 false);
            domCharacterDataModifiedListener =
                new DOMCharacterDataModifiedListener();
            doc.addEventListener("DOMCharacterDataModified",
                                 domCharacterDataModifiedListener,
                                 false);
        }
    }

    /**
     * Removes the event listeners from the document.
     */
    protected void removeEventListeners(EventTarget doc) {
        if (isCSSNavigableDocument) {
            CSSNavigableDocument cnd = (CSSNavigableDocument) doc;
            cnd.removeCSSNavigableDocumentListener
                (cssNavigableDocumentListener);
        } else {
            doc.removeEventListener("DOMAttrModified",
                                    domAttrModifiedListener,
                                    false);
            doc.removeEventListener("DOMNodeInserted",
                                    domNodeInsertedListener,
                                    false);
            doc.removeEventListener("DOMNodeRemoved",
                                    domNodeRemovedListener,
                                    false);
            doc.removeEventListener("DOMSubtreeModified",
                                    domSubtreeModifiedListener,
                                    false);
            doc.removeEventListener("DOMCharacterDataModified",
                                    domCharacterDataModifiedListener,
                                    false);
        }
    }

    /**
     * Disposes the CSSEngine and all the attached resources.
     */
    public void dispose() {
        setCSSEngineUserAgent(null);
        disposeStyleMaps(document.getDocumentElement());
        if (document instanceof EventTarget) {
            // Detach the mutation events listeners.
            removeEventListeners((EventTarget) document);
        }
    }

    /**
     * Removes the style maps from each CSSStylableElement in the document.
     */
    protected void disposeStyleMaps(Node node) {
        if (node instanceof CSSStylableElement) {
            ((CSSStylableElement)node).setComputedStyleMap(null, null);
        }
        for (Node n = getCSSFirstChild(node);
             n != null;
             n = getCSSNextSibling(n)) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                disposeStyleMaps(n);
            }
        }
    }

    /**
     * Returns the CSS context.
     */
    public CSSContext getCSSContext() {
        return cssContext;
    }

    /**
     * Returns the document associated with this engine.
     */
    public Document getDocument() {
        return document;
    }

    /**
     * Returns the font-size property index.
     */
    public int getFontSizeIndex() {
        return fontSizeIndex;
    }

    /**
     * Returns the line-height property index.
     */
    public int getLineHeightIndex() {
        return lineHeightIndex;
    }

    /**
     * Returns the color property index.
     */
    public int getColorIndex() {
        return colorIndex;
    }

    /**
     * Returns the number of properties.
     */
    public int getNumberOfProperties() {
        return valueManagers.length;
    }

    /**
     * Returns the property index, or -1.
     */
    public int getPropertyIndex(String name) {
        return indexes.get(name);
    }

    /**
     * Returns the shorthand property index, or -1.
     */
    public int getShorthandIndex(String name) {
        return shorthandIndexes.get(name);
    }

    /**
     * Returns the name of the property at the given index.
     */
    public String getPropertyName(int idx) {
        return valueManagers[idx].getPropertyName();
    }

    public void setCSSEngineUserAgent(CSSEngineUserAgent userAgent) {
        this.userAgent = userAgent;
    }

    public CSSEngineUserAgent getCSSEngineUserAgent() {
        return userAgent;
    }

    /**
     * Sets the user agent style-sheet.
     */
    public void setUserAgentStyleSheet(StyleSheet ss) {
        userAgentStyleSheet = ss;
    }

    /**
     * Sets the user style-sheet.
     */
    public void setUserStyleSheet(StyleSheet ss) {
        userStyleSheet = ss;
    }

    /**
     * Returns the ValueManagers.
     */
    public ValueManager[] getValueManagers() {
        return valueManagers;
    }

    /**
     * Returns the ShorthandManagers.
     */
    public ShorthandManager[] getShorthandManagers() {
        return shorthandManagers;
    }

    /**
     * Gets the StyleMaps generated by @font-face rules
     * encountered by this CSSEngine thus far.
     */
    public List getFontFaces() {
        return fontFaces;
    }

    /**
     * Sets the media to use to compute the styles.
     */
    public void setMedia(String str) {
        try {
            media = parser.parseMedia(str);
        } catch (Exception e) {
            String m = e.getMessage();
            if (m == null) m = "";
            String s =Messages.formatMessage
                ("media.error", new Object[] { str, m });
            throw new DOMException(DOMException.SYNTAX_ERR, s);
        }
    }

    /**
     * Sets the alternate style-sheet title.
     */
    public void setAlternateStyleSheet(String str) {
        alternateStyleSheet = str;
    }

    /**
     * Recursively imports the cascaded style from a source element
     * to an element of the current document.
     */
    public void importCascadedStyleMaps(Element src,
                                        CSSEngine srceng,
                                        Element dest) {
        if (src instanceof CSSStylableElement) {
            CSSStylableElement csrc  = (CSSStylableElement)src;
            CSSStylableElement cdest = (CSSStylableElement)dest;

            StyleMap sm = srceng.getCascadedStyleMap(csrc, null);
            sm.setFixedCascadedStyle(true);
            cdest.setComputedStyleMap(null, sm);

            if (pseudoElementNames != null) {
                int len = pseudoElementNames.length;
                for (int i = 0; i < len; i++) {
                    String pe = pseudoElementNames[i];
                    sm = srceng.getCascadedStyleMap(csrc, pe);
                    cdest.setComputedStyleMap(pe, sm);
                }
            }
        }

        for (Node dn = getCSSFirstChild(dest), sn = getCSSFirstChild(src);
             dn != null;
             dn = getCSSNextSibling(dn), sn = getCSSNextSibling(sn)) {
            if (sn.getNodeType() == Node.ELEMENT_NODE) {
                importCascadedStyleMaps((Element)sn, srceng, (Element)dn);
            }
        }
    }

    /**
     * Returns the current base-url.
     */
    public ParsedURL getCSSBaseURI() {
        if (cssBaseURI == null) {
            cssBaseURI = element.getCSSBase();
        }
        return cssBaseURI;
    }

    /**
     * Returns the cascaded style of the given element/pseudo-element.
     * @param elt The stylable element.
     * @param pseudo Optional pseudo-element string (null if none).
     */
    public StyleMap getCascadedStyleMap(CSSStylableElement elt,
                                        String pseudo) {
        int props = getNumberOfProperties();
        final StyleMap result = new StyleMap(props);

        // Apply the user-agent style-sheet to the result.
        if (userAgentStyleSheet != null) {
            ArrayList rules = new ArrayList();
            addMatchingRules(rules, userAgentStyleSheet, elt, pseudo);
            addRules(elt, pseudo, result, rules, StyleMap.USER_AGENT_ORIGIN);
        }

        // Apply the user properties style-sheet to the result.
        if (userStyleSheet != null) {
            ArrayList rules = new ArrayList();
            addMatchingRules(rules, userStyleSheet, elt, pseudo);
            addRules(elt, pseudo, result, rules, StyleMap.USER_ORIGIN);
        }

        element = elt;
        try {
            // Apply the non-CSS presentational hints to the result.
            if (nonCSSPresentationalHints != null) {
                ShorthandManager.PropertyHandler ph =
                    new ShorthandManager.PropertyHandler() {
                        public void property(String pname, LexicalUnit lu,
                                             boolean important) {
                            int idx = getPropertyIndex(pname);
                            if (idx != -1) {
                                ValueManager vm = valueManagers[idx];
                                Value v = vm.createValue(lu, CSSEngine.this);
                                putAuthorProperty(result, idx, v, important,
                                                  StyleMap.NON_CSS_ORIGIN);
                                return;
                            }
                            idx = getShorthandIndex(pname);
                            if (idx == -1)
                                return; // Unknown property...
                            // Shorthand value
                            shorthandManagers[idx].setValues
                                (CSSEngine.this, this, lu, important);
                        }
                    };

                NamedNodeMap attrs = elt.getAttributes();
                int len = attrs.getLength();
                for (int i = 0; i < len; i++) {
                    Node attr = attrs.item(i);
                    String an = attr.getNodeName();
                    if (nonCSSPresentationalHints.contains(an)) {
                      String attrValue = attr.getNodeValue();          // -- dvh
                        try {
                            LexicalUnit lu;
                            lu = parser.parsePropertyValue(attr.getNodeValue());
                            ph.property(an, lu, false);
                        } catch (Exception e) {

                          System.err.println("\n***** CSSEngine: exception property.syntax.error:" + e );  // ---
                          System.err.println("\nAttrValue:" + attrValue );
                          System.err.println("\nException:" + e.getClass().getName() );
                          e.printStackTrace( System.err );                           // ---
                          System.err.println("\n***** CSSEngine: exception...." );   // ---

                            String m = e.getMessage();
                            if (m == null) m = "";
                            String u = ((documentURI == null)?"<unknown>":
                                        documentURI.toString());
                            String s = Messages.formatMessage
                                ("property.syntax.error.at",
                                 new Object[] { u, an, attr.getNodeValue(),m});
                            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
                            if (userAgent == null) throw de;
                            userAgent.displayError(de);
                        }
                    }
                }
            }

            // Apply the document style-sheets to the result.
            CSSEngine eng = cssContext.getCSSEngineForElement(elt);
            List snodes = eng.getStyleSheetNodes();
            int slen = snodes.size();
            if (slen > 0) {
                ArrayList rules = new ArrayList();
                for (int i = 0; i < slen; i++) {
                    CSSStyleSheetNode ssn = (CSSStyleSheetNode)snodes.get(i);
                    StyleSheet ss = ssn.getCSSStyleSheet();
                    if (ss != null &&
                        (!ss.isAlternate() ||
                         ss.getTitle() == null ||
                         ss.getTitle().equals(alternateStyleSheet)) &&
                        mediaMatch(ss.getMedia())) {
                        addMatchingRules(rules, ss, elt, pseudo);
                    }
                }
                addRules(elt, pseudo, result, rules, StyleMap.AUTHOR_ORIGIN);
            }

            // Apply the inline style to the result.
            if (styleLocalName != null) {
                String style = elt.getAttributeNS(styleNamespaceURI,
                                                  styleLocalName);
                if (style.length() > 0) {
                    try {
                        parser.setSelectorFactory(CSSSelectorFactory.INSTANCE);
                        parser.setConditionFactory(cssConditionFactory);
                        styleDeclarationDocumentHandler.styleMap = result;
                        parser.setDocumentHandler
                            (styleDeclarationDocumentHandler);
                        parser.parseStyleDeclaration(style);
                        styleDeclarationDocumentHandler.styleMap = null;
                    } catch (Exception e) {
                        String m = e.getMessage();
                        if (m == null) m = e.getClass().getName();
                        String u = ((documentURI == null)?"<unknown>":
                                    documentURI.toString());
                        String s = Messages.formatMessage
                            ("style.syntax.error.at",
                             new Object[] { u, styleLocalName, style, m });
                        DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
                        if (userAgent == null) throw de;
                        userAgent.displayError(de);
                    }
                }
            }

            // Apply the override rules to the result.
            StyleDeclarationProvider p =
                elt.getOverrideStyleDeclarationProvider();
            if (p != null) {
                StyleDeclaration over = p.getStyleDeclaration();
                if (over != null) {
                    int ol = over.size();
                    for (int i = 0; i < ol; i++) {
                        int idx = over.getIndex(i);
                        Value value = over.getValue(i);
                        boolean important = over.getPriority(i);
                        if (!result.isImportant(idx) || important) {
                            result.putValue(idx, value);
                            result.putImportant(idx, important);
                            result.putOrigin(idx, StyleMap.OVERRIDE_ORIGIN);
                        }
                    }
                }
            }
        } finally {
            element = null;
            cssBaseURI = null;
        }

        return result;
    }

    /**
     * Returns the computed style of the given element/pseudo for the
     * property corresponding to the given index.
     */
    public Value getComputedStyle(CSSStylableElement elt,
                                  String pseudo,
                                  int propidx) {
        StyleMap sm = elt.getComputedStyleMap(pseudo);
        if (sm == null) {
            sm = getCascadedStyleMap(elt, pseudo);
            elt.setComputedStyleMap(pseudo, sm);
        }

        Value value = sm.getValue(propidx);
        if (sm.isComputed(propidx))
            return value;

        Value result = value;
        ValueManager vm = valueManagers[propidx];
        CSSStylableElement p = getParentCSSStylableElement(elt);
        if (value == null) {
            if ((p == null) || !vm.isInheritedProperty())
                result = vm.getDefaultValue();
        } else if ((p != null) && (value == InheritValue.INSTANCE)) {
            result = null;
        }
        if (result == null) {
            // Value is 'inherit' and p != null.
            // The pseudo class is not propagated.
            result = getComputedStyle(p, null, propidx);
            sm.putParentRelative(propidx, true);
            sm.putInherited     (propidx, true);
        } else {
            // Maybe is it a relative value.
            result = vm.computeValue(elt, pseudo, this, propidx,
                                     sm, result);
        }
        if (value == null) {
            sm.putValue(propidx, result);
            sm.putNullCascaded(propidx, true);
        } else if (result != value) {
            ComputedValue cv = new ComputedValue(value);
            cv.setComputedValue(result);
            sm.putValue(propidx, cv);
            result = cv;
        }

        sm.putComputed(propidx, true);
        return result;
    }

    /**
     * Returns the document CSSStyleSheetNodes in a list. This list is
     * updated as the document is modified.
     */
    public List getStyleSheetNodes() {
        if (styleSheetNodes == null) {
            styleSheetNodes = new ArrayList();
            selectorAttributes = new HashSet();
            // Find all the style-sheets in the document.
            findStyleSheetNodes(document);
            int len = styleSheetNodes.size();
            for (int i = 0; i < len; i++) {
                CSSStyleSheetNode ssn;
                ssn = (CSSStyleSheetNode)styleSheetNodes.get(i);
                StyleSheet ss = ssn.getCSSStyleSheet();
                if (ss != null) {
                    findSelectorAttributes(selectorAttributes, ss);
                }
            }
        }
        return styleSheetNodes;
    }

    /**
     * An auxiliary method for getStyleSheets().
     */
    protected void findStyleSheetNodes(Node n) {
        if (n instanceof CSSStyleSheetNode) {
            styleSheetNodes.add(n);
        }
        for (Node nd = getCSSFirstChild(n);
             nd != null;
             nd = getCSSNextSibling(nd)) {
            findStyleSheetNodes(nd);
        }
    }

    /**
     * Finds the selector attributes in the given stylesheet.
     */
    protected void findSelectorAttributes(Set attrs, StyleSheet ss) {
        int len = ss.getSize();
        for (int i = 0; i < len; i++) {
            Rule r = ss.getRule(i);
            switch (r.getType()) {
            case StyleRule.TYPE:
                StyleRule style = (StyleRule)r;
                SelectorList sl = style.getSelectorList();
                int slen = sl.getLength();
                for (int j = 0; j < slen; j++) {
                    ExtendedSelector s = (ExtendedSelector)sl.item(j);
                    s.fillAttributeSet(attrs);
                }
                break;

            case MediaRule.TYPE:
            case ImportRule.TYPE:
                MediaRule mr = (MediaRule)r;
                if (mediaMatch(mr.getMediaList())) {
                    findSelectorAttributes(attrs, mr);
                }
                break;
            }
        }
    }

    /**
     * Interface for people interesting in having 'primary' properties
     * set.  Shorthand properties will be expanded "automatically".
     */
    public interface MainPropertyReceiver {

        /**
         * Called with a non-shorthand property name and it's value.
         */
        void setMainProperty(String name, Value v, boolean important);
    }

    public void setMainProperties
        (CSSStylableElement elt, final MainPropertyReceiver dst,
         String pname, String value, boolean important){
        try {
            element = elt;
            LexicalUnit lu = parser.parsePropertyValue(value);
            ShorthandManager.PropertyHandler ph =
                new ShorthandManager.PropertyHandler() {
                    public void property(String pname, LexicalUnit lu,
                                         boolean important) {
                        int idx = getPropertyIndex(pname);
                        if (idx != -1) {
                            ValueManager vm = valueManagers[idx];
                            Value v = vm.createValue(lu, CSSEngine.this);
                            dst.setMainProperty(pname, v, important);
                            return;
                        }
                        idx = getShorthandIndex(pname);
                        if (idx == -1)
                            return; // Unknown property...
                        // Shorthand value
                        shorthandManagers[idx].setValues
                            (CSSEngine.this, this, lu, important);
                    }
                };
            ph.property(pname, lu, important);
        } catch (Exception e) {
            String m = e.getMessage();
            if (m == null) m = "";                  // todo - better handling of NPE
            String u = ((documentURI == null)?"<unknown>":
                        documentURI.toString());
            String s = Messages.formatMessage
                ("property.syntax.error.at",
                 new Object[] { u, pname, value, m});
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
        } finally {
            element = null;
            cssBaseURI = null;
        }
    }

    /**
     * Parses and creates a property value from elt.
     * @param elt  The element property is from.
     * @param prop The property name.
     * @param value The property value.
     */
    public Value parsePropertyValue(CSSStylableElement elt,
                                    String prop, String value) {
        int idx = getPropertyIndex(prop);
        if (idx == -1) return null;
        ValueManager vm = valueManagers[idx];
        try {
            element = elt;
            LexicalUnit lu;
            lu = parser.parsePropertyValue(value);
            return vm.createValue(lu, this);
        } catch (Exception e) {
            String m = e.getMessage();
            if (m == null) m = "";
            String u = ((documentURI == null)?"<unknown>":
                        documentURI.toString());
            String s = Messages.formatMessage
                ("property.syntax.error.at",
                 new Object[] { u, prop, value, m });
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
        } finally {
            element = null;
            cssBaseURI = null;
        }
        return vm.getDefaultValue();
    }

    /**
     * Parses and creates a style declaration.
     * @param value The style declaration text.
     */
    public StyleDeclaration parseStyleDeclaration(CSSStylableElement elt,
                                                  String value) {
        styleDeclarationBuilder.styleDeclaration = new StyleDeclaration();
        try {
            element = elt;
            parser.setSelectorFactory(CSSSelectorFactory.INSTANCE);
            parser.setConditionFactory(cssConditionFactory);
            parser.setDocumentHandler(styleDeclarationBuilder);
            parser.parseStyleDeclaration(value);
        } catch (Exception e) {
            String m = e.getMessage();
            if (m == null) m = "";
            String u = ((documentURI == null)?"<unknown>":
                        documentURI.toString());
            String s = Messages.formatMessage
                ("syntax.error.at", new Object[] { u, m });
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
        } finally {
            element = null;
            cssBaseURI = null;
        }
        return styleDeclarationBuilder.styleDeclaration;
    }

    /**
     * Parses and creates a new style-sheet.
     * @param uri The style-sheet URI.
     * @param media The target media of the style-sheet.
     */
    public StyleSheet parseStyleSheet(ParsedURL uri, String media)
        throws DOMException {
        StyleSheet ss = new StyleSheet();
        try {
            ss.setMedia(parser.parseMedia(media));
        } catch (Exception e) {
            String m = e.getMessage();
            if (m == null) m = "";
            String u = ((documentURI == null)?"<unknown>":
                        documentURI.toString());
            String s = Messages.formatMessage
                ("syntax.error.at", new Object[] { u, m });
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
            return ss;
        }
        parseStyleSheet(ss, uri);
        return ss;
    }

    /**
     * Parses and creates a new style-sheet.
     * @param is The input source used to read the document.
     * @param uri The base URI.
     * @param media The target media of the style-sheet.
     */
    public StyleSheet parseStyleSheet(InputSource is, ParsedURL uri,
                                      String media)
        throws DOMException {
        StyleSheet ss = new StyleSheet();
        try {
            ss.setMedia(parser.parseMedia(media));
            parseStyleSheet(ss, is, uri);
        } catch (Exception e) {
            String m = e.getMessage();
            if (m == null) m = "";
            String u = ((documentURI == null)?"<unknown>":
                        documentURI.toString());
            String s = Messages.formatMessage
                ("syntax.error.at", new Object[] { u, m });
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
        }
        return ss;
    }

    /**
     * Parses and fills the given style-sheet.
     * @param ss The stylesheet to fill.
     * @param uri The base URI.
     */
    public void parseStyleSheet(StyleSheet ss, ParsedURL uri)
            throws DOMException {
        if (uri == null) {
            String s = Messages.formatMessage
                ("syntax.error.at",
                 new Object[] { "Null Document reference", "" });
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
            return;
        }

        try {
            // Check that access to the uri is allowed
            cssContext.checkLoadExternalResource(uri, documentURI);
            parseStyleSheet(ss, new InputSource(uri.toString()), uri);
        } catch (SecurityException e) {
            throw e;
        } catch (Exception e) {
            String m = e.getMessage();
            if (m == null) m = e.getClass().getName();
            String s = Messages.formatMessage
                ("syntax.error.at", new Object[] { uri.toString(), m });
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
        }
    }

    /**
     * Parses and creates a new style-sheet.
     * @param rules The style-sheet rules to parse.
     * @param uri The style-sheet URI.
     * @param media The target media of the style-sheet.
     */
    public StyleSheet parseStyleSheet(String rules, ParsedURL uri, String media)
            throws DOMException {
        StyleSheet ss = new StyleSheet();
        try {
            ss.setMedia(parser.parseMedia(media));
        } catch (Exception e) {
            String m = e.getMessage();
            if (m == null) m = "";
            String u = ((documentURI == null)?"<unknown>":
                        documentURI.toString());
            String s = Messages.formatMessage
                ("syntax.error.at", new Object[] { u, m });
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
            return ss;
        }
        parseStyleSheet(ss, rules, uri);
        return ss;
    }

    /**
     * Parses and fills the given style-sheet.
     * @param ss The stylesheet to fill.
     * @param rules The style-sheet rules to parse.
     * @param uri The base URI.
     */
    public void parseStyleSheet(StyleSheet ss,
                                String rules,
                                ParsedURL uri) throws DOMException {
        try {
            parseStyleSheet(ss, new InputSource(new StringReader(rules)), uri);
        } catch (Exception e) {
            // e.printStackTrace();
            String m = e.getMessage();
            if (m == null) m = "";
            String s = Messages.formatMessage
                ("stylesheet.syntax.error",
                 new Object[] { uri.toString(), rules, m });
            DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
            if (userAgent == null) throw de;
            userAgent.displayError(de);
        }
    }

    /**
     * Parses and fills the given style-sheet.
     * @param ss The stylesheet to fill.
     * @param uri The base URI.
     */
    protected void parseStyleSheet(StyleSheet ss, InputSource is, ParsedURL uri)
        throws IOException {
        parser.setSelectorFactory(CSSSelectorFactory.INSTANCE);
        parser.setConditionFactory(cssConditionFactory);
        try {
            cssBaseURI = uri;
            styleSheetDocumentHandler.styleSheet = ss;
            parser.setDocumentHandler(styleSheetDocumentHandler);
            parser.parseStyleSheet(is);

            // Load the imported sheets.
            int len = ss.getSize();
            for (int i = 0; i < len; i++) {
                Rule r = ss.getRule(i);
                if (r.getType() != ImportRule.TYPE) {
                    // @import rules must be the first rules.
                    break;
                }
                ImportRule ir = (ImportRule)r;
                parseStyleSheet(ir, ir.getURI());
            }
        } finally {
            cssBaseURI = null;
        }
    }

    /**
     * Puts an author property from a style-map in another style-map,
     * if possible.
     */
    protected void putAuthorProperty(StyleMap dest,
                                     int idx,
                                     Value sval,
                                     boolean imp,
                                     short origin) {
        Value   dval = dest.getValue(idx);
        short   dorg = dest.getOrigin(idx);
        boolean dimp = dest.isImportant(idx);

        boolean cond = dval == null;
        if (!cond) {
            switch (dorg) {
            case StyleMap.USER_ORIGIN:
                cond = !dimp;
                break;
            case StyleMap.AUTHOR_ORIGIN:
                cond = !dimp || imp;
                break;
            case StyleMap.OVERRIDE_ORIGIN:
                cond = false;
                break;
            default:
                cond = true;
            }
        }

        if (cond) {
            dest.putValue(idx, sval);
            dest.putImportant(idx, imp);
            dest.putOrigin(idx, origin);
        }
    }

    /**
     * Adds the rules matching the element/pseudo-element of given style
     * sheet to the list.
     */
    protected void addMatchingRules(List rules,
                                    StyleSheet ss,
                                    Element elt,
                                    String pseudo) {
        int len = ss.getSize();
        for (int i = 0; i < len; i++) {
            Rule r = ss.getRule(i);
            switch (r.getType()) {
            case StyleRule.TYPE:
                StyleRule style = (StyleRule)r;
                SelectorList sl = style.getSelectorList();
                int slen = sl.getLength();
                for (int j = 0; j < slen; j++) {
                    ExtendedSelector s = (ExtendedSelector)sl.item(j);
                    if (s.match(elt, pseudo)) {
                        rules.add(style);
                    }
                }
                break;

            case MediaRule.TYPE:
            case ImportRule.TYPE:
                MediaRule mr = (MediaRule)r;
                if (mediaMatch(mr.getMediaList())) {
                    addMatchingRules(rules, mr, elt, pseudo);
                }
                break;
            }
        }
    }

    /**
     * Adds the rules contained in the given list to a stylemap.
     */
    protected void addRules(Element elt,
                            String pseudo,
                            StyleMap sm,
                            ArrayList rules,
                            short origin) {
        sortRules(rules, elt, pseudo);
        int rlen = rules.size();

        if (origin == StyleMap.AUTHOR_ORIGIN) {
            for (int r = 0; r < rlen; r++) {
                StyleRule sr = (StyleRule)rules.get(r);
                StyleDeclaration sd = sr.getStyleDeclaration();
                int len = sd.size();
                for (int i = 0; i < len; i++) {
                    putAuthorProperty(sm,
                                      sd.getIndex(i),
                                      sd.getValue(i),
                                      sd.getPriority(i),
                                      origin);
                }
            }
        } else {
            for (int r = 0; r < rlen; r++) {
                StyleRule sr = (StyleRule)rules.get(r);
                StyleDeclaration sd = sr.getStyleDeclaration();
                int len = sd.size();
                for (int i = 0; i < len; i++) {
                    int idx = sd.getIndex(i);
                    sm.putValue(idx, sd.getValue(i));
                    sm.putImportant(idx, sd.getPriority(i));
                    sm.putOrigin(idx, origin);
                }
            }
        }
    }

    /**
     * Sorts the rules matching the element/pseudo-element of given style
     * sheet to the list.
     */
    protected void sortRules(ArrayList rules, Element elt, String pseudo) {
        int len = rules.size();
        int[] specificities = new int[len];
        for (int i = 0; i < len; i++) {
            StyleRule r = (StyleRule) rules.get(i);
            SelectorList sl = r.getSelectorList();
            int spec = 0;
            int slen = sl.getLength();
            for (int k = 0; k < slen; k++) {
                ExtendedSelector s = (ExtendedSelector) sl.item(k);
                if (s.match(elt, pseudo)) {
                    int sp = s.getSpecificity();
                    if (sp > spec) {
                        spec = sp;
                    }
                }
            }
            specificities[i] = spec;
        }
        for (int i = 1; i < len; i++) {
            Object rule = rules.get(i);
            int spec = specificities[i];
            int j = i - 1;
            while (j >= 0 && specificities[j] > spec) {
                rules.set(j + 1, rules.get(j));
                specificities[j + 1] = specificities[j];
                j--;
            }
            rules.set(j + 1, rule);
            specificities[j + 1] = spec;
        }
    }

    /**
     * Whether the given media list matches the media list of this
     * CSSEngine object.
     */
    protected boolean mediaMatch(SACMediaList ml) {
    if (media == null ||
            ml == null ||
            media.getLength() == 0 ||
            ml.getLength() == 0) {
        return true;
    }
    for (int i = 0; i < ml.getLength(); i++) {
            if (ml.item(i).equalsIgnoreCase("all"))
                return true;
        for (int j = 0; j < media.getLength(); j++) {
        if (media.item(j).equalsIgnoreCase("all") ||
                    ml.item(i).equalsIgnoreCase(media.item(j))) {
            return true;
        }
        }
    }
    return false;
    }

    /**
     * To parse a style declaration.
     */
    protected class StyleDeclarationDocumentHandler
        extends DocumentAdapter
        implements ShorthandManager.PropertyHandler {
        public StyleMap styleMap;

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#property(String,LexicalUnit,boolean)}.
         */
        public void property(String name, LexicalUnit value, boolean important)
            throws CSSException {
            int i = getPropertyIndex(name);
            if (i == -1) {
                i = getShorthandIndex(name);
                if (i == -1) {
                    // Unknown property
                    return;
                }
                shorthandManagers[i].setValues(CSSEngine.this,
                                               this,
                                               value,
                                               important);
            } else {
                Value v = valueManagers[i].createValue(value, CSSEngine.this);
                putAuthorProperty(styleMap, i, v, important,
                                  StyleMap.INLINE_AUTHOR_ORIGIN);
            }
        }
    }

    /**
     * To build a StyleDeclaration object.
     */
    protected class StyleDeclarationBuilder
        extends DocumentAdapter
        implements ShorthandManager.PropertyHandler {
        public StyleDeclaration styleDeclaration;

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#property(String,LexicalUnit,boolean)}.
         */
        public void property(String name, LexicalUnit value, boolean important)
            throws CSSException {
            int i = getPropertyIndex(name);
            if (i == -1) {
                i = getShorthandIndex(name);
                if (i == -1) {
                    // Unknown property
                    return;
                }
                shorthandManagers[i].setValues(CSSEngine.this,
                                               this,
                                               value,
                                               important);
            } else {
                Value v = valueManagers[i].createValue(value, CSSEngine.this);
                styleDeclaration.append(v, i, important);
            }
        }
    }

    /**
     * To parse a style sheet.
     */
    protected class StyleSheetDocumentHandler
        extends DocumentAdapter
        implements ShorthandManager.PropertyHandler {
        public StyleSheet styleSheet;
        protected StyleRule styleRule;
        protected StyleDeclaration styleDeclaration;

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#startDocument(InputSource)}.
         */
        public void startDocument(InputSource source)
            throws CSSException {
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#endDocument(InputSource)}.
         */
        public void endDocument(InputSource source) throws CSSException {
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#ignorableAtRule(String)}.
         */
        public void ignorableAtRule(String atRule) throws CSSException {
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#importStyle(String,SACMediaList,String)}.
         */
        public void importStyle(String       uri,
                                SACMediaList media,
                                String       defaultNamespaceURI)
            throws CSSException {
            ImportRule ir = new ImportRule();
            ir.setMediaList(media);
            ir.setParent(styleSheet);
            ParsedURL base = getCSSBaseURI();
            ParsedURL url;
            if (base == null) {
                url = new ParsedURL(uri);
            } else {
                url = new ParsedURL(base, uri);
            }
            ir.setURI(url);
            styleSheet.append(ir);
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#startMedia(SACMediaList)}.
         */
        public void startMedia(SACMediaList media) throws CSSException {
            MediaRule mr = new MediaRule();
            mr.setMediaList(media);
            mr.setParent(styleSheet);
            styleSheet.append(mr);
            styleSheet = mr;
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#endMedia(SACMediaList)}.
         */
        public void endMedia(SACMediaList media) throws CSSException {
            styleSheet = styleSheet.getParent();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#startPage(String,String)}.
         */
        public void startPage(String name, String pseudo_page)
            throws CSSException {
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#endPage(String,String)}.
         */
        public void endPage(String name, String pseudo_page)
            throws CSSException {
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#startFontFace()}.
         */
        public void startFontFace() throws CSSException {
            styleDeclaration = new StyleDeclaration();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#endFontFace()}.
         */
        public void endFontFace() throws CSSException {
            StyleMap sm = new StyleMap(getNumberOfProperties());
            int len = styleDeclaration.size();
            for (int i=0; i<len; i++) {
                int idx = styleDeclaration.getIndex(i);
                sm.putValue(idx, styleDeclaration.getValue(i));
                sm.putImportant(idx, styleDeclaration.getPriority(i));
                // Not sure on this..
                sm.putOrigin(idx, StyleMap.AUTHOR_ORIGIN);
            }
            styleDeclaration = null;

            int pidx = getPropertyIndex(CSSConstants.CSS_FONT_FAMILY_PROPERTY);
            Value fontFamily = sm.getValue(pidx);
            if (fontFamily == null) return;

            ParsedURL base = getCSSBaseURI();
            fontFaces.add(new FontFaceRule(sm, base));
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#startSelector(SelectorList)}.
         */
        public void startSelector(SelectorList selectors) throws CSSException {
            styleRule = new StyleRule();
            styleRule.setSelectorList(selectors);
            styleDeclaration = new StyleDeclaration();
            styleRule.setStyleDeclaration(styleDeclaration);
            styleSheet.append(styleRule);
        }

        /**
         * <b>SAC</b>: Implements {@link
         * org.w3c.css.sac.DocumentHandler#endSelector(SelectorList)}.
         */
        public void endSelector(SelectorList selectors) throws CSSException {
            styleRule = null;
            styleDeclaration = null;
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#property(String,LexicalUnit,boolean)}.
         */
        public void property(String name, LexicalUnit value, boolean important)
            throws CSSException {
            int i = getPropertyIndex(name);
            if (i == -1) {
                i = getShorthandIndex(name);
                if (i == -1) {
                    // Unknown property
                    return;
                }
                shorthandManagers[i].setValues(CSSEngine.this,
                                               this,
                                               value,
                                               important);
            } else {
                Value v = valueManagers[i].createValue(value, CSSEngine.this);
                styleDeclaration.append(v, i, important);
            }
        }
    }

    /**
     * Provides an (empty) adapter for the DocumentHandler interface.
     * Most methods just throw an UnsupportedOperationException, so
     * the subclasses <i>must</i> override them with 'real' methods.
     */
    protected static class DocumentAdapter implements DocumentHandler {

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#startDocument(InputSource)}.
         */
        public void startDocument(InputSource source){
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#endDocument(InputSource)}.
         */
        public void endDocument(InputSource source) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#comment(String)}.
         */
        public void comment(String text) {
            // We always ignore the comments.
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#ignorableAtRule(String)}.
         */
        public void ignorableAtRule(String atRule) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#namespaceDeclaration(String,String)}.
         */
        public void namespaceDeclaration(String prefix, String uri) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#importStyle(String,SACMediaList,String)}.
         */
        public void importStyle(String       uri,
                                SACMediaList media,
                                String       defaultNamespaceURI) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#startMedia(SACMediaList)}.
         */
        public void startMedia(SACMediaList media) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#endMedia(SACMediaList)}.
         */
        public void endMedia(SACMediaList media) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#startPage(String,String)}.
         */
        public void startPage(String name, String pseudo_page) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#endPage(String,String)}.
         */
        public void endPage(String name, String pseudo_page) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link DocumentHandler#startFontFace()}.
         */
        public void startFontFace() {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link DocumentHandler#endFontFace()}.
         */
        public void endFontFace() {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#startSelector(SelectorList)}.
         */
        public void startSelector(SelectorList selectors) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#endSelector(SelectorList)}.
         */
        public void endSelector(SelectorList selectors) {
            throwUnsupportedEx();
        }

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#property(String,LexicalUnit,boolean)}.
         */
        public void property(String name, LexicalUnit value, boolean important) {
            throwUnsupportedEx();
        }


        private void throwUnsupportedEx(){
            throw new UnsupportedOperationException("you try to use an empty method in Adapter-class" );
        }
    }

    // CSS events /////////////////////////////////////////////////////////

    protected static final CSSEngineListener[] LISTENER_ARRAY =
        new CSSEngineListener[0];

    /**
     * Adds a CSS engine listener.
     */
    public void addCSSEngineListener(CSSEngineListener l) {
        listeners.add(l);
    }

    /**
     * Removes a CSS engine listener.
     */
    public void removeCSSEngineListener(CSSEngineListener l) {
        listeners.remove(l);
    }

    /**
     * Fires a CSSEngineEvent, given a list of modified properties.
     */
    protected void firePropertiesChangedEvent(Element target, int[] props) {
        CSSEngineListener[] ll =
            (CSSEngineListener[])listeners.toArray(LISTENER_ARRAY);

        int len = ll.length;
        if (len > 0) {
            CSSEngineEvent evt = new CSSEngineEvent(this, target, props);
            for (int i = 0; i < len; i++) {
                ll[i].propertiesChanged(evt);
            }
        }
    }

    // Dynamic updates ////////////////////////////////////////////////////

    /**
     * Called when the inline style of the given element has been updated.
     */
    protected void inlineStyleAttributeUpdated(CSSStylableElement elt,
                                               StyleMap style,
                                               short attrChange,
                                               String prevValue,
                                               String newValue) {
        boolean[] updated = styleDeclarationUpdateHandler.updatedProperties;
        for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
            updated[i] = false;
        }

        switch (attrChange) {
        case MutationEvent.ADDITION:            // intentional fall-through
        case MutationEvent.MODIFICATION:
            if (newValue.length() > 0) {
                element = elt;
                try {
                    parser.setSelectorFactory(CSSSelectorFactory.INSTANCE);
                    parser.setConditionFactory(cssConditionFactory);
                    styleDeclarationUpdateHandler.styleMap = style;
                    parser.setDocumentHandler(styleDeclarationUpdateHandler);
                    parser.parseStyleDeclaration(newValue);
                    styleDeclarationUpdateHandler.styleMap = null;
                } catch (Exception e) {
                    String m = e.getMessage();
                    if (m == null) m = "";
                    String u = ((documentURI == null)?"<unknown>":
                                documentURI.toString());
                    String s = Messages.formatMessage
                        ("style.syntax.error.at",
                         new Object[] { u, styleLocalName, newValue, m });
                    DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
                    if (userAgent == null) throw de;
                    userAgent.displayError(de);
                } finally {
                    element = null;
                    cssBaseURI = null;
                }
            }

            // Fall through
        case MutationEvent.REMOVAL:
            boolean removed = false;

            if (prevValue != null && prevValue.length() > 0) {
                // Check if the style map has cascaded styles which
                // come from the inline style attribute or override style.
                for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
                    if (style.isComputed(i) && !updated[i]) {
                        short origin = style.getOrigin(i);
                        if (origin >= StyleMap.INLINE_AUTHOR_ORIGIN) {     // ToDo Jlint says: always same result ??
                            removed = true;
                            updated[i] = true;
                        }
                    }
                }
            }

            if (removed) {
                invalidateProperties(elt, null, updated, true);
            } else {
                int count = 0;
                // Invalidate the relative values
                boolean fs = (fontSizeIndex == -1)
                    ? false
                    : updated[fontSizeIndex];
                boolean lh = (lineHeightIndex == -1)
                    ? false
                    : updated[lineHeightIndex];
                boolean cl = (colorIndex == -1)
                    ? false
                    : updated[colorIndex];

                for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
                    if (updated[i]) {
                        count++;
                    }
                    else if ((fs && style.isFontSizeRelative(i)) ||
                             (lh && style.isLineHeightRelative(i)) ||
                             (cl && style.isColorRelative(i))) {
                        updated[i] = true;
                        clearComputedValue(style, i);
                        count++;
                    }
                }

                if (count > 0) {
                    int[] props = new int[count];
                    count = 0;
                    for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
                        if (updated[i]) {
                            props[count++] = i;
                        }
                    }
                    invalidateProperties(elt, props, null, true);
                }
            }
            break;

        default:
            // Must not happen
            throw new IllegalStateException("Invalid attrChangeType");
        }
    }

    private static void clearComputedValue(StyleMap style, int n) {
        if (style.isNullCascaded(n)) {
            style.putValue(n, null);
        } else {
            Value v = style.getValue(n);
            if (v instanceof ComputedValue) {
                ComputedValue cv = (ComputedValue)v;
                v = cv.getCascadedValue();
                style.putValue(n, v);
            }
        }
        style.putComputed(n, false);
    }

    /**
     * Invalidates all the properties of the given node.
     */
    protected void invalidateProperties(Node node,
                                        int [] properties,
                                        boolean [] updated,
                                        boolean recascade) {

        if (!(node instanceof CSSStylableElement))
            return;  // Not Stylable sub tree

        CSSStylableElement elt = (CSSStylableElement)node;
        StyleMap style = elt.getComputedStyleMap(null);
        if (style == null)
            return;  // Nothing to invalidate.

        boolean [] diffs = new boolean[getNumberOfProperties()];
        if (updated != null) {
            System.arraycopy( updated, 0, diffs, 0, updated.length );
        }
        if (properties != null) {
            for (int i=0; i<properties.length; i++) {
                diffs[properties[i]] = true;
            }
        }
        int count =0;
        if (!recascade) {
            for (int i=0; i<diffs.length; i++) {
                if (diffs[i]) {
                    count++;
                }
            }
        } else {
            StyleMap newStyle = getCascadedStyleMap(elt, null);
            elt.setComputedStyleMap(null, newStyle);
            for (int i=0; i<diffs.length; i++) {
                if (diffs[i]) {
                    count++;
                    continue; // Already marked changed.
                }

                // Value nv = getComputedStyle(elt, null, i);
                Value nv = newStyle.getValue(i);
                Value ov = null;
                if (!style.isNullCascaded(i)) {
                    ov = style.getValue(i);
                    if (ov instanceof ComputedValue) {
                        ov = ((ComputedValue)ov).getCascadedValue();
                    }
                }

                if (nv == ov) continue;
                if ((nv != null) && (ov != null)) {
                    if (nv.equals(ov)) continue;
                    String ovCssText = ov.getCssText();
                    String nvCssText = nv.getCssText();
                    if ((nvCssText == ovCssText) ||
                        ((nvCssText != null) && nvCssText.equals(ovCssText)))
                        continue;
                }
                count++;
                diffs[i] = true;
            }
        }
        int []props = null;
        if (count != 0) {
            props = new int[count];
            count = 0;
            for (int i=0; i<diffs.length; i++) {
                if (diffs[i])
                    props[count++] = i;
            }
        }
        propagateChanges(elt, props, recascade);
    }

    /**
     * Propagates the changes that occurs on the parent of the given node.
     * Props is a list of known 'changed' properties.
     * If recascade is true then the stylesheets will be applied
     * again to see if the any new rules apply (or old rules don't
     * apply).
     */
    protected void propagateChanges(Node node, int[] props,
                                    boolean recascade) {
        if (!(node instanceof CSSStylableElement))
            return;
        CSSStylableElement elt = (CSSStylableElement)node;
        StyleMap style = elt.getComputedStyleMap(null);
        if (style != null) {
            boolean[] updated =
                styleDeclarationUpdateHandler.updatedProperties;
            for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
                updated[i] = false;
            }
            if (props != null) {
                for (int i = props.length - 1; i >= 0; --i) {
                    int idx = props[i];
                    updated[idx] = true;
                }
            }

            // Invalidate the relative values
            boolean fs = (fontSizeIndex == -1)
                ? false
                : updated[fontSizeIndex];
            boolean lh = (lineHeightIndex == -1)
                ? false
                : updated[lineHeightIndex];
            boolean cl = (colorIndex == -1)
                ? false
                : updated[colorIndex];

            int count = 0;
            for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
                if (updated[i]) {
                    count++;
                }
                else if ((fs && style.isFontSizeRelative(i)) ||
                         (lh && style.isLineHeightRelative(i)) ||
                         (cl && style.isColorRelative(i))) {
                    updated[i] = true;
                    clearComputedValue(style, i);
                    count++;
                }
            }

            if (count == 0) {
                props = null;
            } else {
                props = new int[count];
                count = 0;
                for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
                    if (updated[i]) {
                        props[count++] = i;
                    }
                }
                firePropertiesChangedEvent(elt, props);
            }
        }

        int [] inherited = props;
        if (props != null) {
            // Filter out uninheritable properties when we
            // propogate to children.
            int count = 0;
            for (int i=0; i<props.length; i++) {
                ValueManager vm = valueManagers[props[i]];
                if (vm.isInheritedProperty()) count++;
                else props[i] = -1;
            }

            if (count == 0) {
                // nothing to propogate for sure
                inherited = null;
            } else {
                inherited = new int[count];
                count=0;
                for (int i=0; i<props.length; i++)
                    if (props[i] != -1)
                        inherited[count++] = props[i];
            }
        }

        for (Node n = getCSSFirstChild(node);
             n != null;
             n = getCSSNextSibling(n)) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                // XXX Should this invalidateProperties be called on eng?
                // In r216064 with CSSImportedElementRoot, the imported
                // element's CSSEngine was indeed used.
                // CSSEngine eng = cssContext.getCSSEngineForElement((Element) n);
                invalidateProperties(n, inherited, null, recascade);
            }
        }
    }

    /**
     * To parse a style declaration and update a StyleMap.
     */
    protected class StyleDeclarationUpdateHandler
        extends DocumentAdapter
        implements ShorthandManager.PropertyHandler {
        public StyleMap styleMap;
        public boolean[] updatedProperties =
            new boolean[getNumberOfProperties()];

        /**
         * <b>SAC</b>: Implements {@link
         * DocumentHandler#property(String,LexicalUnit,boolean)}.
         */
        public void property(String name, LexicalUnit value, boolean important)
            throws CSSException {
            int i = getPropertyIndex(name);
            if (i == -1) {
                i = getShorthandIndex(name);
                if (i == -1) {
                    // Unknown property
                    return;
                }
                shorthandManagers[i].setValues(CSSEngine.this,
                                               this,
                                               value,
                                               important);
            } else {
                if (styleMap.isImportant(i)) {
                    // The previous value is important, and a value
                    // from a style attribute cannot be important...
                    return;
                }

                updatedProperties[i] = true;

                Value v = valueManagers[i].createValue(value, CSSEngine.this);
                styleMap.putMask(i, (short)0);
                styleMap.putValue(i, v);
                styleMap.putOrigin(i, StyleMap.INLINE_AUTHOR_ORIGIN);
            }
        }
    }

    /**
     * Called when a non-CSS presentational hint has been updated.
     */
    protected void nonCSSPresentationalHintUpdated(CSSStylableElement elt,
                                                   StyleMap style,
                                                   String property,
                                                   short attrChange,
                                                   String newValue) {
        int idx = getPropertyIndex(property);

        if (style.isImportant(idx)) {
            // The current value is important, and a value
            // from an XML attribute cannot be important...
            return;
        }

        if (style.getOrigin(idx) >= StyleMap.AUTHOR_ORIGIN) {
            // The current value has a greater priority
            return;
        }

        switch (attrChange) {
        case MutationEvent.ADDITION:   // intentional fall-through
        case MutationEvent.MODIFICATION:
            element = elt;
            try {
                LexicalUnit lu;
                lu = parser.parsePropertyValue(newValue);
                ValueManager vm = valueManagers[idx];
                Value v = vm.createValue(lu, CSSEngine.this);
                style.putMask(idx, (short)0);
                style.putValue(idx, v);
                style.putOrigin(idx, StyleMap.NON_CSS_ORIGIN);
            } catch (Exception e) {
                String m = e.getMessage();
                if (m == null) m = "";
                String u = ((documentURI == null)?"<unknown>":
                            documentURI.toString());
                String s = Messages.formatMessage
                    ("property.syntax.error.at",
                     new Object[] { u, property, newValue, m });
                DOMException de = new DOMException(DOMException.SYNTAX_ERR, s);
                if (userAgent == null) throw de;
                userAgent.displayError(de);
            } finally {
                element = null;
                cssBaseURI = null;
            }
            break;

        case MutationEvent.REMOVAL:
            {
                int [] invalid = { idx };
                invalidateProperties(elt, invalid, null, true);
                return;
            }
        }

        boolean[] updated = styleDeclarationUpdateHandler.updatedProperties;
        for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
            updated[i] = false;
        }
        updated[idx] = true;

        // Invalidate the relative values
        boolean fs = idx == fontSizeIndex;
        boolean lh = idx == lineHeightIndex;
        boolean cl = idx == colorIndex;
        int count = 0;

        for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
            if (updated[i]) {
                count++;
            }
            else if ((fs && style.isFontSizeRelative(i)) ||
                     (lh && style.isLineHeightRelative(i)) ||
                     (cl && style.isColorRelative(i))) {
                updated[i] = true;
                clearComputedValue(style, i);
                count++;
            }
        }

        int[] props = new int[count];
        count = 0;
        for (int i = getNumberOfProperties() - 1; i >= 0; --i) {
            if (updated[i]) {
                props[count++] = i;
            }
        }

        invalidateProperties(elt, props, null, true);
    }

    /**
     * Returns whether the DOM subtree rooted at the specified node
     * contains a {@link CSSStyleSheetNode}.
     */
    protected boolean hasStyleSheetNode(Node n) {
        if (n instanceof CSSStyleSheetNode) {
            return true;
        }
        n = getCSSFirstChild(n);
        while (n != null) {
            if (hasStyleSheetNode(n)) {
                return true;
            }
            n = getCSSNextSibling(n);
        }
        return false;
    }

    /**
     * Handles an attribute change in the document.
     */
    protected void handleAttrModified(Element e,
                                      Attr attr,
                                      short attrChange,
                                      String prevValue,
                                      String newValue) {
        if (!(e instanceof CSSStylableElement)) {
            // Not a stylable element.
            return;
        }

        if (newValue.equals(prevValue)) {
            return;  // no change really...
        }

        String attrNS = attr.getNamespaceURI();
        String name = attrNS == null ? attr.getNodeName() : attr.getLocalName();

        CSSStylableElement elt = (CSSStylableElement) e;
        StyleMap style = elt.getComputedStyleMap(null);
        if (style != null) {
            if (attrNS == styleNamespaceURI
                    || attrNS != null && attrNS.equals(styleNamespaceURI)) {
                if (name.equals(styleLocalName)) {
                    // The style declaration attribute has been modified.
                    inlineStyleAttributeUpdated
                        (elt, style, attrChange, prevValue, newValue);
                    return;
                }
            }

            if (nonCSSPresentationalHints != null) {
                if (attrNS == nonCSSPresentationalHintsNamespaceURI ||
                        attrNS != null &&
                        attrNS.equals(nonCSSPresentationalHintsNamespaceURI)) {
                    if (nonCSSPresentationalHints.contains(name)) {
                        // The 'name' attribute which represents a non CSS
                        // presentational hint has been modified.
                        nonCSSPresentationalHintUpdated
                            (elt, style, name, attrChange, newValue);
                        return;
                    }
                }
            }
        }

        if (selectorAttributes != null &&
            selectorAttributes.contains(name)) {
            // An attribute has been modified, invalidate all the
            // properties to correctly match attribute selectors.
            invalidateProperties(elt, null, null, true);
            for (Node n = getCSSNextSibling(elt);
                 n != null;
                 n = getCSSNextSibling(n)) {
                invalidateProperties(n, null, null, true);
            }
        }
    }

    /**
     * Handles a node insertion in the document.
     */
    protected void handleNodeInserted(Node n) {
        if (hasStyleSheetNode(n)) {
            // Invalidate all the CSSStylableElements in the document.
            styleSheetNodes = null;
            invalidateProperties(document.getDocumentElement(),
                                 null, null, true);
        } else if (n instanceof CSSStylableElement) {
            // Invalidate the CSSStylableElement siblings, to correctly
            // match the adjacent selectors and first-child pseudo-class.
            n = getCSSNextSibling(n);
            while (n != null) {
                invalidateProperties(n, null, null, true);
                n = getCSSNextSibling(n);
            }
        }
    }

    /**
     * Handles a node removal from the document.
     */
    protected void handleNodeRemoved(Node n) {
        if (hasStyleSheetNode(n)) {
            // Wait for the DOMSubtreeModified to do the invalidations
            // because at this time the node is in the tree.
            styleSheetRemoved = true;
        } else if (n instanceof CSSStylableElement) {
            // Wait for the DOMSubtreeModified to do the invalidations
            // because at this time the node is in the tree.
            removedStylableElementSibling = getCSSNextSibling(n);
        }
        // Clears the computed styles in the removed tree.
        disposeStyleMaps(n);
    }

    /**
     * Handles a subtree modification in the document.
     * todo the incoming Node is actually ignored (not used) here,
     *     but it seems caller-sites assume that it is used - is this done right??
     */
    protected void handleSubtreeModified(Node ignored) {
        if (styleSheetRemoved) {
            // Invalidate all the CSSStylableElements in the document.
            styleSheetRemoved = false;
            styleSheetNodes = null;
            invalidateProperties(document.getDocumentElement(),
                                 null, null, true);
        } else if (removedStylableElementSibling != null) {
            // Invalidate the CSSStylableElement siblings, to
            // correctly match the adjacent selectors and
            // first-child pseudo-class.
            Node n = removedStylableElementSibling;
            while (n != null) {
                invalidateProperties(n, null, null, true);
                n = getCSSNextSibling(n);
            }
            removedStylableElementSibling = null;
        }
    }

    /**
     * Handles a character data modification in the document.
     */
    protected void handleCharacterDataModified(Node n) {
        if (getCSSParentNode(n) instanceof CSSStyleSheetNode) {
            // Invalidate all the CSSStylableElements in the document.
            styleSheetNodes = null;
            invalidateProperties(document.getDocumentElement(),
                                 null, null, true);
        }
    }

    /**
     * To handle mutations of a CSSNavigableDocument.
     */
    protected class CSSNavigableDocumentHandler
            implements CSSNavigableDocumentListener,
                       MainPropertyReceiver {

        /**
         * Array to hold which properties have been changed by a call to
         * setMainProperties.
         */
        protected boolean[] mainPropertiesChanged;

        /**
         * The StyleDeclaration to use from the MainPropertyReceiver.
         */
        protected StyleDeclaration declaration;

        /**
         * A node has been inserted into the CSSNavigableDocument tree.
         */
        public void nodeInserted(Node newNode) {
            handleNodeInserted(newNode);
        }

        /**
         * A node is about to be removed from the CSSNavigableDocument tree.
         */
        public void nodeToBeRemoved(Node oldNode) {
            handleNodeRemoved(oldNode);
        }

        /**
         * A subtree of the CSSNavigableDocument tree has been modified
         * in some way.
         */
        public void subtreeModified(Node rootOfModifications) {
            handleSubtreeModified(rootOfModifications);
        }

        /**
         * Character data in the CSSNavigableDocument tree has been modified.
         */
        public void characterDataModified(Node text) {
            handleCharacterDataModified(text);
        }

        /**
         * An attribute has changed in the CSSNavigableDocument.
         */
        public void attrModified(Element e,
                                 Attr attr,
                                 short attrChange,
                                 String prevValue,
                                 String newValue) {
            handleAttrModified(e, attr, attrChange, prevValue, newValue);
        }

        /**
         * The text of the override style declaration for this element has been
         * modified.
         */
        public void overrideStyleTextChanged(CSSStylableElement elt,
                                             String text) {
            StyleDeclarationProvider p =
                elt.getOverrideStyleDeclarationProvider();
            StyleDeclaration declaration = p.getStyleDeclaration();
            int ds = declaration.size();
            boolean[] updated = new boolean[getNumberOfProperties()];
            for (int i = 0; i < ds; i++) {
                updated[declaration.getIndex(i)] = true;
            }
            declaration = parseStyleDeclaration(elt, text);
            p.setStyleDeclaration(declaration);
            ds = declaration.size();
            for (int i = 0; i < ds; i++) {
                updated[declaration.getIndex(i)] = true;
            }
            invalidateProperties(elt, null, updated, true);
        }

        /**
         * A property in the override style declaration has been removed.
         */
        public void overrideStylePropertyRemoved(CSSStylableElement elt,
                                                 String name) {
            StyleDeclarationProvider p =
                elt.getOverrideStyleDeclarationProvider();
            StyleDeclaration declaration = p.getStyleDeclaration();
            int idx = getPropertyIndex(name);
            int ds = declaration.size();
            for (int i = 0; i < ds; i++) {
                if (idx == declaration.getIndex(i)) {
                    declaration.remove(i);
                    StyleMap style = elt.getComputedStyleMap(null);
                    if (style != null
                            && style.getOrigin(idx) == StyleMap.OVERRIDE_ORIGIN
                            /* && style.isComputed(idx) */) {
                        invalidateProperties
                            (elt, new int[] { idx }, null, true);
                    }
                    break;
                }
            }
        }

        /**
         * A property in the override style declaration has been changed.
         */
        public void overrideStylePropertyChanged(CSSStylableElement elt,
                                                 String name, String val,
                                                 String prio) {
            boolean important = prio != null && prio.length() != 0;
            StyleDeclarationProvider p =
                elt.getOverrideStyleDeclarationProvider();
            declaration = p.getStyleDeclaration();
            setMainProperties(elt, this, name, val, important);
            declaration = null;
            invalidateProperties(elt, null, mainPropertiesChanged, true);
        }

        // MainPropertyReceiver //////////////////////////////////////////////

        /**
         * Sets a main property value in response to a shorthand property
         * being set.
         */
        public void setMainProperty(String name, Value v, boolean important) {
            int idx = getPropertyIndex(name);
            if (idx == -1) {
                return;   // unknown property
            }

            int i;
            for (i = 0; i < declaration.size(); i++) {
                if (idx == declaration.getIndex(i)) {
                    break;
                }
            }
            if (i < declaration.size()) {
                declaration.put(i, v, idx, important);
            } else {
                declaration.append(v, idx, important);
            }
        }
    }

    /**
     * To handle the insertion of a CSSStyleSheetNode in the
     * associated document.
     */
    protected class DOMNodeInsertedListener implements EventListener {
        public void handleEvent(Event evt) {
            handleNodeInserted((Node) evt.getTarget());
        }
    }

    /**
     * To handle the removal of a CSSStyleSheetNode from the
     * associated document.
     */
    protected class DOMNodeRemovedListener implements EventListener {
        public void handleEvent(Event evt) {
            handleNodeRemoved((Node) evt.getTarget());
        }
    }

    /**
     * To handle the removal of a CSSStyleSheetNode from the
     * associated document.
     */
    protected class DOMSubtreeModifiedListener implements EventListener {
        public void handleEvent(Event evt) {
            handleSubtreeModified((Node) evt.getTarget());
        }
    }

    /**
     * To handle the modification of a CSSStyleSheetNode.
     */
    protected class DOMCharacterDataModifiedListener implements EventListener {
        public void handleEvent(Event evt) {
            handleCharacterDataModified((Node) evt.getTarget());
        }
    }

    /**
     * To handle the element attributes modification in the associated
     * document.
     */
    protected class DOMAttrModifiedListener implements EventListener {
        public void handleEvent(Event evt) {
            MutationEvent mevt = (MutationEvent) evt;
            handleAttrModified((Element) evt.getTarget(),
                               (Attr) mevt.getRelatedNode(),
                               mevt.getAttrChange(),
                               mevt.getPrevValue(),
                               mevt.getNewValue());
        }
    }
}
