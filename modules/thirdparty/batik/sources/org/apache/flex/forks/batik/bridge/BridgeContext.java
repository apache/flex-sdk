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
import java.awt.geom.Dimension2D;
import java.io.IOException;
import java.io.InterruptedIOException;
import java.lang.ref.SoftReference;
import java.lang.ref.WeakReference;
import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Set;
import java.util.WeakHashMap;

import org.apache.flex.forks.batik.bridge.svg12.SVG12BridgeContext;
import org.apache.flex.forks.batik.bridge.svg12.SVG12BridgeExtension;
import org.apache.flex.forks.batik.css.engine.CSSContext;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSEngineEvent;
import org.apache.flex.forks.batik.css.engine.CSSEngineListener;
import org.apache.flex.forks.batik.css.engine.CSSEngineUserAgent;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.SystemColorSupport;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.svg.AnimatedAttributeListener;
import org.apache.flex.forks.batik.dom.svg.AnimatedLiveAttributeValue;
import org.apache.flex.forks.batik.dom.svg.SVGContext;
import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;
import org.apache.flex.forks.batik.dom.svg.SVGStylableElement;
import org.apache.flex.forks.batik.dom.xbl.XBLManager;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.TextPainter;
import org.apache.flex.forks.batik.script.Interpreter;
import org.apache.flex.forks.batik.script.InterpreterPool;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.CleanerThread;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.Service;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.events.MouseEvent;
import org.w3c.dom.events.MutationEvent;
import org.w3c.dom.svg.SVGDocument;

/**
 * This class represents a context used by the various bridges and the
 * builder. A bridge context is associated to a particular document
 * and cannot be reused.
 *
 * The context encapsulates the dynamic bindings between DOM elements
 * and GVT nodes, graphic contexts such as a <tt>GraphicsNodeRenderContext</tt>,
 * and the different objects required by the GVT builder to interpret
 * a SVG DOM tree such as the current viewport or the user agent.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: BridgeContext.java 599681 2007-11-30 02:55:48Z cam $
 */
public class BridgeContext implements ErrorConstants, CSSContext {

    /**
     * The document is bridge context is dedicated to.
     */
    protected Document document;

    /**
     * Whether the document is an SVG 1.2 document.
     */
    protected boolean isSVG12;

    /**
     * The GVT builder that might be used to create a GVT subtree.
     */
    protected GVTBuilder gvtBuilder;

    /**
     * The interpreter cache per document.
     * key is the language -
     * value is a Interpreter
     */
    protected Map interpreterMap = new HashMap(7);

    /**
     * A Map of all the font families already matched. This is
     * to reduce the number of instances of GVTFontFamilies and to
     * hopefully reduce the time taken to search for a matching SVG font.
     */
    private Map fontFamilyMap;

    /**
     * The viewports.
     * key is an Element -
     * value is a Viewport
     */
    protected Map viewportMap = new WeakHashMap();

    /**
     * The viewport stack. Used in building time.
     */
    protected List viewportStack = new LinkedList();

    /**
     * The user agent.
     */
    protected UserAgent userAgent;

    /**
     * Binding Map:
     * key is an SVG Element -
     * value is a GraphicsNode
     */
    protected Map elementNodeMap;

    /**
     * Binding Map:
     * key is GraphicsNode -
     * value is a SVG Element.
     */
    protected Map nodeElementMap;

    /**
     * Bridge Map:
     * Keys are namespace URI - values are HashMap (with keys are local
     * name and values are a Bridge instance).
     */
    protected Map namespaceURIMap;

    /**
     * Default bridge.
     * When a bridge is requested for an element type that does not have a
     * bridge, and there is no other bridge for elements in the same namespace,
     * the default bridge is returned.  This is used for custom elements,
     * which all use the same bridge type.
     */
    protected Bridge defaultBridge;

    /**
     * Default bridge reserved namespaces set.
     * Default bridges will not be created for elements that have a
     * namespace URI present in this set.
     */
    protected Set reservedNamespaceSet;

    /**
     * Element Data Map:
     * This is a general location for elements to 'cache'
     * data.  Such as the graphics tree for a pattern or
     * the Gradient arrays.
     *
     * This is a weak hash map and the data is referenced
     * by SoftReference so both must be referenced elsewhere
     * to stay live.
     */
    protected Map elementDataMap;

    /**
     * The interpreter pool used to handle scripts.
     */
    protected InterpreterPool interpreterPool;

    /**
     * The document loader used to load/create Document.
     */
    protected DocumentLoader documentLoader;

    /**
     * The size of the document.
     */
    protected Dimension2D documentSize;

    /**
     * The text painter to use. Typically, you can specify the text painter that
     * will be used be text nodes.
     */
    protected TextPainter textPainter;

    /**
     * Indicates that no DOM listeners should be registered.  In this
     * case the generated GVT tree should be totally independent of
     * the DOM tree (in practice text holds references to the source
     * text elements for font resolution).
     */
    public static final int STATIC      = 0;

    /**
     * Indicates that DOM listeners should be registered to support,
     * 'interactivity' this includes anchors and cursors, but does not
     * include support for DOM modifications.
     */
    public static final int INTERACTIVE = 1;

    /**
     * Indicates that all DOM listeners should be registered. This supports
     * 'interactivity' (anchors and cursors), as well as DOM modifications
     * listeners to update the GVT rendering tree.
     */
    public static final int DYNAMIC     = 2;

    /**
     * Whether the bridge should support dynamic, or interactive features.
     */
    protected int dynamicStatus = STATIC;

    /**
     * The update manager.
     */
    protected UpdateManager updateManager;

    /**
     * The XBL manager.
     */
    protected XBLManager xblManager;

    /**
     * The bridge context for the primary document, if this is a bridge
     * context for a resource document.
     */
    protected BridgeContext primaryContext;

    /**
     * Set of WeakReferences to child BridgeContexts.
     */
    protected HashSet childContexts = new HashSet();

    /**
     * The animation engine for the document.
     */
    protected SVGAnimationEngine animationEngine;

    /**
     * The animation limiting mode.
     */
    protected int animationLimitingMode;

    /**
     * The amount of animation limiting.
     */
    protected float animationLimitingAmount;

    /**
     * By default we share a unique instance of InterpreterPool.
     */
    private static InterpreterPool sharedPool = new InterpreterPool();

    /**
     * Constructs a new empty bridge context.
     */
    protected BridgeContext() {}

    /**
     * Constructs a new bridge context.
     * @param userAgent the user agent
     */
    public BridgeContext(UserAgent userAgent) {
        this(userAgent,
             sharedPool,
             new DocumentLoader(userAgent));
    }

    /**
     * Constructs a new bridge context.
     * @param userAgent the user agent
     * @param loader document loader
     */
    public BridgeContext(UserAgent userAgent,
                         DocumentLoader loader) {
        this(userAgent, sharedPool, loader);
    }

    /**
     * Constructs a new bridge context.
     * @param userAgent the user agent
     * @param interpreterPool the interpreter pool
     * @param documentLoader document loader
     */
    public BridgeContext(UserAgent userAgent,
                         InterpreterPool interpreterPool,
                         DocumentLoader documentLoader) {
        this.userAgent = userAgent;
        this.viewportMap.put(userAgent, new UserAgentViewport(userAgent));
        this.interpreterPool = interpreterPool;
        this.documentLoader = documentLoader;
    }

    /**
     * Calls dispose on this BridgeContext, if it is a child context.
     */
    protected void finalize() {
        if (primaryContext != null) {
            dispose();
        }
    }

    /**
     * This function creates a new 'sub' BridgeContext to associated
     * with 'newDoc' if one currently doesn't exist, otherwise it
     * returns the BridgeContext currently associated with the
     * document.
     * @param newDoc The document to get/create a BridgeContext for.
     */
    public BridgeContext createSubBridgeContext(SVGOMDocument newDoc) {
        BridgeContext subCtx;

        CSSEngine eng = newDoc.getCSSEngine();
        if (eng != null) {
            subCtx = (BridgeContext) newDoc.getCSSEngine().getCSSContext();
            return subCtx;
        }

        subCtx = createBridgeContext(newDoc);
        subCtx.primaryContext = primaryContext != null ? primaryContext : this;
        subCtx.primaryContext.childContexts.add(new WeakReference(subCtx));
        subCtx.dynamicStatus = dynamicStatus;
        subCtx.setGVTBuilder(getGVTBuilder());
        subCtx.setTextPainter(getTextPainter());
        subCtx.setDocument(newDoc);
        subCtx.initializeDocument(newDoc);
        if (isInteractive())
            subCtx.addUIEventListeners(newDoc);
        return subCtx;
    }

    /**
     * This function creates a new BridgeContext, it mostly
     * exists so subclasses can provide an instance of
     * themselves when a sub BridgeContext is needed.
     */
    public BridgeContext createBridgeContext(SVGOMDocument doc) {
        if (doc.isSVG12()) {
            return new SVG12BridgeContext(getUserAgent(), getDocumentLoader());
        }
        return new BridgeContext(getUserAgent(), getDocumentLoader());
    }

    /**
     * Initializes the given document.
     */
    protected void initializeDocument(Document document) {
        SVGOMDocument doc = (SVGOMDocument)document;
        CSSEngine eng = doc.getCSSEngine();
        if (eng == null) {
            SVGDOMImplementation impl;
            impl = (SVGDOMImplementation)doc.getImplementation();
            eng = impl.createCSSEngine(doc, this);
            eng.setCSSEngineUserAgent(new CSSEngineUserAgentWrapper(userAgent));
            doc.setCSSEngine(eng);
            eng.setMedia(userAgent.getMedia());
            String uri = userAgent.getUserStyleSheetURI();
            if (uri != null) {
                try {
                    ParsedURL url = new ParsedURL(uri);
                    eng.setUserAgentStyleSheet
                        (eng.parseStyleSheet(url, "all"));
                } catch (Exception e) {
                    userAgent.displayError(e);
                }
            }
            eng.setAlternateStyleSheet(userAgent.getAlternateStyleSheet());
        }
    }

    /**
     * Returns the CSS engine associated with given element.
     */
    public CSSEngine getCSSEngineForElement(Element e) {
        SVGOMDocument doc = (SVGOMDocument)e.getOwnerDocument();
        return doc.getCSSEngine();
    }

    // properties ////////////////////////////////////////////////////////////

    /**
     * Sets the text painter that will be used by text nodes. This attributes
     * might be used by bridges (especially SVGTextElementBridge) to set the
     * text painter of each TextNode.
     *
     * @param textPainter the text painter for text nodes
     */
    public void setTextPainter(TextPainter textPainter) {
        this.textPainter = textPainter;
    }

    /**
     * Returns the text painter that will be used be text nodes.
     */
    public TextPainter getTextPainter() {
        return textPainter;
    }

    /**
     * Returns the document this bridge context is dedicated to.
     */
    public Document getDocument() {
        return document;
    }

    /**
     * Sets the document this bridge context is dedicated to, to the
     * specified document.
     * @param document the document
     */
    protected void setDocument(Document document) {
        if (this.document != document){
            fontFamilyMap = null;
        }
        this.document = document;
        this.isSVG12 = ((SVGOMDocument) document).isSVG12();
        registerSVGBridges();
    }

    /**
     * Returns the map of font families
     */
    public Map getFontFamilyMap(){
        if (fontFamilyMap == null){
            fontFamilyMap = new HashMap();
        }
        return fontFamilyMap;
    }

    /**
     * Sets the map of font families to the specified value.
     *
     *@param fontFamilyMap the map of font families
     */
    protected void setFontFamilyMap(Map fontFamilyMap) {
        this.fontFamilyMap = fontFamilyMap;
    }

    /**
     * Associates a data object with a node so it can be retrieved later.
     * This is primarily used for caching the graphics node generated from
     * a 'pattern' element.  A soft reference to the data object is used.
     */
    public void setElementData(Node n, Object data) {
        if (elementDataMap == null) {
            elementDataMap = new WeakHashMap();
        }
        elementDataMap.put(n, new SoftReference(data));
    }

    /**
     * Retrieves a data object associated with the given node.
     */
    public Object getElementData(Node n) {
        if (elementDataMap == null)
            return null;
        Object o = elementDataMap.get(n);
        if (o == null) return null;
        SoftReference sr = (SoftReference)o;
        o = sr.get();
        if (o == null) {
            elementDataMap.remove(n);
        }
        return o;
    }

    /**
     * Returns the user agent of this bridge context.
     */
    public UserAgent getUserAgent() {
        return userAgent;
    }

    /**
     * Sets the user agent to the specified user agent.
     * @param userAgent the user agent
     */
    protected void setUserAgent(UserAgent userAgent) {
        this.userAgent = userAgent;
    }

    /**
     * Returns the GVT builder that is currently used to build the GVT tree.
     */
    public GVTBuilder getGVTBuilder() {
        return gvtBuilder;
    }

    /**
     * Sets the GVT builder that uses this context.
     */
    protected void setGVTBuilder(GVTBuilder gvtBuilder) {
        this.gvtBuilder = gvtBuilder;
    }

    /**
     * Returns the interpreter pool used to handle scripts.
     */
    public InterpreterPool getInterpreterPool() {
        return interpreterPool;
    }

    /**
     * Returns the focus manager.
     */
    public FocusManager getFocusManager() {
        return focusManager;
    }

    /**
     * Returns the cursor manager
     */
    public CursorManager getCursorManager() {
        return cursorManager;
    }

    /**
     * Sets the interpreter pool used to handle scripts to the
     * specified interpreter pool.
     * @param interpreterPool the interpreter pool
     */
    protected void setInterpreterPool(InterpreterPool interpreterPool) {
        this.interpreterPool = interpreterPool;
    }

    /**
     * Returns a Interpreter for the specified language.
     *
     * @param language the scripting language
     */
    public Interpreter getInterpreter(String language) {
        if (document == null) {
            throw new RuntimeException("Unknown document");
        }
        Interpreter interpreter = (Interpreter)interpreterMap.get(language);
        if (interpreter == null) {
            try {
                interpreter = interpreterPool.createInterpreter(document, language);
                interpreterMap.put(language, interpreter);
            } catch (Exception e) {
                if (userAgent != null) {
                    userAgent.displayError(e);
                    return null;
                }
            }
        }

        if (interpreter == null) {
            if (userAgent != null) {
                userAgent.displayError(new Exception("Unknown language: " + language));
            }
        }

        return interpreter;
    }

    /**
     * Returns the document loader used to load external documents.
     */
    public DocumentLoader getDocumentLoader() {
        return documentLoader;
    }

    /**
     * Sets the document loader used to load external documents.
     * @param newDocumentLoader the new document loader
     */
    protected void setDocumentLoader(DocumentLoader newDocumentLoader) {
        this.documentLoader = newDocumentLoader;
    }

    /**
     * Returns the actual size of the document or null if the document
     * has not been built yet.
     */
    public Dimension2D getDocumentSize() {
        return documentSize;
    }

    /**
     * Sets the size of the document to the specified dimension.
     *
     * @param d the actual size of the SVG document
     */
    protected void setDocumentSize(Dimension2D d) {
        this.documentSize = d;
    }

    /**
     * Returns true if the document is dynamic, false otherwise.
     */
    public boolean isDynamic() {
        return (dynamicStatus == DYNAMIC);
    }

    /**
     * Returns true if the document is interactive, false otherwise.
     */
    public boolean isInteractive() {
        return (dynamicStatus != STATIC);
    }

    /**
     * Sets the document as a STATIC, INTERACTIVE or DYNAMIC document.
     * Call this method before the build phase
     * (ie. before <tt>gvtBuilder.build(...)</tt>)
     * otherwise, that will have no effect.
     *
     *@param status the document dynamicStatus
     */
    public void setDynamicState(int status) {
        dynamicStatus = status;
    }

    /**
     * Sets the document as DYNAMIC if <tt>dynamic</tt> is true
     * STATIC otherwise.
     */
    public void setDynamic(boolean dynamic) {
        if (dynamic)
            setDynamicState(DYNAMIC);
        else
            setDynamicState(STATIC);
    }

    /**
     * Sets the document as INTERACTIVE if <tt>interactive</tt> is
     * true STATIC otherwise.
     */
    public void setInteractive(boolean interactive) {
        if (interactive)
            setDynamicState(INTERACTIVE);
        else
            setDynamicState(STATIC);
    }

    /**
     * Returns the update manager, if the bridge supports dynamic features.
     */
    public UpdateManager getUpdateManager() {
        return updateManager;
    }

    /**
     * Sets the update manager.
     */
    protected void setUpdateManager(UpdateManager um) {
        updateManager = um;
    }

    /**
     * Sets the update manager on the given BridgeContext.
     */
    protected void setUpdateManager(BridgeContext ctx, UpdateManager um) {
        ctx.setUpdateManager(um);
    }

    /**
     * Sets the xblManager variable of the given BridgeContext.
     */
    protected void setXBLManager(BridgeContext ctx, XBLManager xm) {
        ctx.xblManager = xm;
    }

    /**
     * Returns whether the managed document is an SVG 1.2 document.
     */
    public boolean isSVG12() {
        return isSVG12;
    }

    /**
     * Returns the primary bridge context.
     */
    public BridgeContext getPrimaryBridgeContext() {
        if (primaryContext != null) {
            return primaryContext;
        }
        return this;
    }

    /**
     * Returns an array of the child contexts.
     */
    public BridgeContext[] getChildContexts() {
        BridgeContext[] res = new BridgeContext[childContexts.size()];
        Iterator it = childContexts.iterator();
        for (int i = 0; i < res.length; i++) {
            WeakReference wr = (WeakReference) it.next();
            res[i] = (BridgeContext) wr.get();
        }
        return res;
    }

    /**
     * Returns the AnimationEngine for the document.  Creates one if
     * it doesn't exist.
     */
    public SVGAnimationEngine getAnimationEngine() {
        if (animationEngine == null) {
            animationEngine = new SVGAnimationEngine(document, this);
            setAnimationLimitingMode();
        }
        return animationEngine;
    }

    // reference management //////////////////////////////////////////////////

    /**
     * Returns a new URIResolver object.
     */
    public URIResolver createURIResolver(SVGDocument doc, DocumentLoader dl) {
        return new URIResolver(doc, dl);
    }

    /**
     * Returns the node referenced by the specified element by the specified
     * uri. The referenced node can be either an element given by a fragment
     * ID, or the document node.
     * @param e the element referencing
     * @param uri the uri of the referenced node
     */
    public Node getReferencedNode(Element e, String uri) {
        try {
            SVGDocument document = (SVGDocument)e.getOwnerDocument();
            URIResolver ur = createURIResolver(document, documentLoader);
            Node ref = ur.getNode(uri, e);
            if (ref == null) {
                throw new BridgeException(this, e, ERR_URI_BAD_TARGET,
                                          new Object[] {uri});
            } else {
                SVGOMDocument refDoc =
                    (SVGOMDocument) (ref.getNodeType() == Node.DOCUMENT_NODE
                                       ? ref
                                       : ref.getOwnerDocument());
                // This is new rather than attaching this BridgeContext
                // with the new document we now create a whole new
                // BridgeContext to go with the new document.
                // This means that the new document has it's own
                // world of stuff and it should avoid memory leaks
                // since the new document isn't 'tied into' this
                // bridge context.
                if (refDoc != document) {
                    createSubBridgeContext(refDoc);
                }
                return ref;
            }
        } catch (MalformedURLException ex) {
            throw new BridgeException(this, e, ex, ERR_URI_MALFORMED,
                                      new Object[] {uri});
        } catch (InterruptedIOException ex) {
            throw new InterruptedBridgeException();
        } catch (IOException ex) {
            //ex.printStackTrace();
            throw new BridgeException(this, e, ex, ERR_URI_IO,
                                      new Object[] {uri});
        } catch (SecurityException ex) {
            throw new BridgeException(this, e, ex, ERR_URI_UNSECURE,
                                      new Object[] {uri});
        }
    }

    /**
     * Returns the element referenced by the specified element by the
     * specified uri. The referenced element can not be a Document.
     *
     * @param e the element referencing
     * @param uri the uri of the referenced element
     */
    public Element getReferencedElement(Element e, String uri) {
        Node ref = getReferencedNode(e, uri);
        if (ref != null && ref.getNodeType() != Node.ELEMENT_NODE) {
            throw new BridgeException(this, e, ERR_URI_REFERENCE_A_DOCUMENT,
                                      new Object[] {uri});
        }
        return (Element) ref;
    }

    // Viewport //////////////////////////////////////////////////////////////

    /**
     * Returns the viewport of the specified element.
     *
     * @param e the element interested in its viewport
     */
    public Viewport getViewport(Element e) {
        if (viewportStack != null) {
            // building time
            if (viewportStack.size() == 0) {
                // outermost svg element
                return (Viewport)viewportMap.get(userAgent);
            } else {
                // current viewport
                return (Viewport)viewportStack.get(0);
            }
        } else {
            // search the first parent which has defined a viewport
            e = SVGUtilities.getParentElement(e);
            while (e != null) {
                Viewport viewport = (Viewport)viewportMap.get(e);
                if (viewport != null) {
                    return viewport;
                }
                e = SVGUtilities.getParentElement(e);
            }
            return (Viewport)viewportMap.get(userAgent);
        }
    }

    /**
     * Starts a new viewport from the specified element.
     *
     * @param e the element that defines a new viewport
     * @param viewport the viewport of the element
     */
    public void openViewport(Element e, Viewport viewport) {
        viewportMap.put(e, viewport);
        if (viewportStack == null) {
            viewportStack = new LinkedList();
        }
        viewportStack.add(0, viewport);
    }

    public void removeViewport(Element e) {
        viewportMap.remove(e);
    }

    /**
     * Closes the viewport associated to the specified element.
     * @param e the element that closes its viewport
     */
    public void closeViewport(Element e) {
        //viewportMap.remove(e); FIXME: potential memory leak
        viewportStack.remove(0);
        if (viewportStack.size() == 0) {
            viewportStack = null;
        }
    }

    // Bindings //////////////////////////////////////////////////////////////

    /**
     * Binds the specified GraphicsNode to the specified Node. This method
     * automatically bind the graphics node to the element and the element to
     * the graphics node.
     *
     * @param node the DOM Node to bind to the specified graphics node
     * @param gn the graphics node to bind to the specified element
     */
    public void bind(Node node, GraphicsNode gn) {
        if (elementNodeMap == null) {
            elementNodeMap = new WeakHashMap();
            nodeElementMap = new WeakHashMap();
        }
        elementNodeMap.put(node, new SoftReference(gn));
        nodeElementMap.put(gn, new SoftReference(node));
    }

    /**
     * Removes the binding of the specified Node.
     *
     * @param node the DOM Node to unbind
     */
    public void unbind(Node node) {
        if (elementNodeMap == null) {
            return;
        }
        GraphicsNode gn = null;
        SoftReference sr = (SoftReference)elementNodeMap.get(node);
        if (sr != null)
            gn = (GraphicsNode)sr.get();
        elementNodeMap.remove(node);
        if (gn != null)
            nodeElementMap.remove(gn);
    }

    /**
     * Returns the GraphicsNode associated to the specified Node or
     * null if any.
     *
     * @param node the DOM Node associated to the graphics node to return
     */
    public GraphicsNode getGraphicsNode(Node node) {
        if (elementNodeMap != null) {
            SoftReference sr = (SoftReference)elementNodeMap.get(node);
            if (sr != null)
                return (GraphicsNode)sr.get();
        }
        return null;
    }

    /**
     * Returns the Node associated to the specified GraphicsNode or
     * null if any.
     *
     * @param gn the graphics node associated to the element to return
     */
    public Element getElement(GraphicsNode gn) {
        if (nodeElementMap != null) {
            SoftReference sr = (SoftReference)nodeElementMap.get(gn);
            if (sr != null) {
                Node n = (Node) sr.get();
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    return (Element) n;
                }
            }
        }
        return null;
    }

    // Bridge management /////////////////////////////////////////////////////

    /**
     * Returns true if the specified element has a GraphicsNodeBridge
     * associated to it, false otherwise.
     *
     * @param element the element
     */
    public boolean hasGraphicsNodeBridge(Element element) {
        if (namespaceURIMap == null || element == null) {
            return false;
        }
        String localName = element.getLocalName();
        String namespaceURI = element.getNamespaceURI();
        namespaceURI = ((namespaceURI == null)? "" : namespaceURI);
        HashMap localNameMap = (HashMap) namespaceURIMap.get(namespaceURI);
        if (localNameMap == null) {
            return false;
        }
        return (localNameMap.get(localName) instanceof GraphicsNodeBridge);
    }

    /**
     * Returns the bridge for the document node.
     */
    public DocumentBridge getDocumentBridge() {
        return new SVGDocumentBridge();
    }

    /**
     * Returns the bridge associated with the specified element.
     *
     * @param element the element
     */
    public Bridge getBridge(Element element) {
        if (namespaceURIMap == null || element == null) {
            return null;
        }
        String localName = element.getLocalName();
        String namespaceURI = element.getNamespaceURI();
        namespaceURI = ((namespaceURI == null)? "" : namespaceURI);
        return getBridge(namespaceURI, localName);
    }

    /**
     * Returns the bridge associated with the element type
     *
     * @param namespaceURI namespace of the requested element
     * @param localName element's local name
     *
     */
    public Bridge getBridge(String namespaceURI, String localName) {
        Bridge bridge = null;
        if (namespaceURIMap != null) {
            HashMap localNameMap = (HashMap) namespaceURIMap.get(namespaceURI);
            if (localNameMap != null) {
                bridge = (Bridge)localNameMap.get(localName);
            }
        }
        if (bridge == null
                && (reservedNamespaceSet == null
                    || !reservedNamespaceSet.contains(namespaceURI))) {
            bridge = defaultBridge;
        }
        if (isDynamic()) {
            return bridge == null ? null : bridge.getInstance();
        } else {
            return bridge;
        }
    }

    /**
     * Associates the specified <tt>Bridge</tt> object with the specified
     * namespace URI and local name.
     * @param namespaceURI the namespace URI
     * @param localName the local name
     * @param bridge the bridge that manages the element
     */
    public void putBridge(String namespaceURI, String localName, Bridge bridge) {
        // start assert
        if (!(namespaceURI.equals(bridge.getNamespaceURI())
              && localName.equals(bridge.getLocalName()))) {
            throw new Error("Invalid Bridge: "+
                            namespaceURI+"/"+bridge.getNamespaceURI()+" "+
                            localName+"/"+bridge.getLocalName()+" "+
                            bridge.getClass());
        }
        // end assert
        if (namespaceURIMap == null) {
            namespaceURIMap = new HashMap();
        }
        namespaceURI = ((namespaceURI == null)? "" : namespaceURI);
        HashMap localNameMap = (HashMap) namespaceURIMap.get(namespaceURI);
        if (localNameMap == null) {
            localNameMap = new HashMap();
            namespaceURIMap.put(namespaceURI, localNameMap);
        }
        localNameMap.put(localName, bridge);
    }

    /**
     * Associates the specified <tt>Bridge</tt> object with it's
     * namespace URI and local name.
     *
     * @param bridge the bridge that manages the element
     */
    public void putBridge(Bridge bridge) {
        putBridge(bridge.getNamespaceURI(), bridge.getLocalName(), bridge);
    }

    /**
     * Removes the <tt>Bridge</tt> object associated to the specified
     * namespace URI and local name.
     *
     * @param namespaceURI the namespace URI
     * @param localName the local name
     */
    public void removeBridge(String namespaceURI, String localName) {
        if (namespaceURIMap == null) {
            return;
        }
        namespaceURI = ((namespaceURI == null)? "" : namespaceURI);
        HashMap localNameMap = (HashMap) namespaceURIMap.get(namespaceURI);
        if (localNameMap != null) {
            localNameMap.remove(localName);
            if (localNameMap.isEmpty()) {
                namespaceURIMap.remove(namespaceURI);
                if (namespaceURIMap.isEmpty()) {
                    namespaceURIMap = null;
                }
            }
        }
    }

    /**
     * Sets the <tt>Bridge</tt> object to be used for foreign
     * namespace elements.
     *
     * @param bridge the bridge that manages the element
     */
    public void setDefaultBridge(Bridge bridge) {
        defaultBridge = bridge;
    }

    /**
     * Adds a namespace URI to avoid when creating default bridges.
     */
    public void putReservedNamespaceURI(String namespaceURI) {
        if (namespaceURI == null) {
            namespaceURI = "";
        }
        if (reservedNamespaceSet == null) {
            reservedNamespaceSet = new HashSet();
        }
        reservedNamespaceSet.add(namespaceURI);
    }

    /**
     * Removes a namespace URI to avoid when creating default bridges.
     */
    public void removeReservedNamespaceURI(String namespaceURI) {
        if (namespaceURI == null) {
            namespaceURI = "";
        }
        if (reservedNamespaceSet != null) {
            reservedNamespaceSet.remove(namespaceURI);
            if (reservedNamespaceSet.isEmpty()) {
                reservedNamespaceSet = null;
            }
        }
    }

    // dynamic support ////////////////////////////////////////////////////////

    /**
     * The list of all EventListener attached by bridges that need to
     * be removed on a dispose() call.
     */
    protected Set eventListenerSet = new HashSet();

    /**
     * The DOM EventListener to receive 'DOMCharacterDataModified' event.
     */
    protected EventListener domCharacterDataModifiedEventListener;

    /**
     * The DOM EventListener to receive 'DOMAttrModified' event.
     */
    protected EventListener domAttrModifiedEventListener;

    /**
     * The DOM EventListener to receive 'DOMNodeInserted' event.
     */
    protected EventListener domNodeInsertedEventListener;

    /**
     * The DOM EventListener to receive 'DOMNodeRemoved' event.
     */
    protected EventListener domNodeRemovedEventListener;

    /**
     * The CSSEngine listener to receive CSSEngineEvent.
     */
    protected CSSEngineListener cssPropertiesChangedListener;

    /**
     * The listener to receive notification of animated attribute changes.
     */
    protected AnimatedAttributeListener animatedAttributeListener;

    /**
     * The EventListener that is responsible of managing DOM focus event.
     */
    protected FocusManager focusManager;

    /**
     * Manages cursors and performs caching when appropriate
     */
    protected CursorManager cursorManager = new CursorManager(this);

    /**
     * Adds EventListeners to the input document to handle the cursor
     * property.
     * This is not done in the addDOMListeners method because
     * addDOMListeners is only used for dynamic content whereas
     * cursor support is provided for all content.
     * Also note that it is very important that the listeners be
     * registered for the capture phase as the 'default' behavior
     * for cursors is handled by the BridgeContext during the
     * capture phase and the 'custom' behavior (handling of 'auto'
     * on anchors, for example), is handled during the bubbling phase.
     */
    public void addUIEventListeners(Document doc) {
        NodeEventTarget evtTarget = (NodeEventTarget)doc.getDocumentElement();

        DOMMouseOverEventListener domMouseOverListener =
            new DOMMouseOverEventListener();
        evtTarget.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             SVGConstants.SVG_EVENT_MOUSEOVER,
             domMouseOverListener, true, null);
        storeEventListenerNS
            (evtTarget,
             XMLConstants.XML_EVENTS_NAMESPACE_URI,
             SVGConstants.SVG_EVENT_MOUSEOVER,
             domMouseOverListener, true);

        DOMMouseOutEventListener domMouseOutListener =
            new DOMMouseOutEventListener();
        evtTarget.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             SVGConstants.SVG_EVENT_MOUSEOUT,
             domMouseOutListener, true, null);
        storeEventListenerNS
            (evtTarget,
             XMLConstants.XML_EVENTS_NAMESPACE_URI,
             SVGConstants.SVG_EVENT_MOUSEOUT,
             domMouseOutListener, true);

    }

    public void removeUIEventListeners(Document doc) {
        EventTarget evtTarget = (EventTarget)doc.getDocumentElement();
        synchronized (eventListenerSet) {
            Iterator i = eventListenerSet.iterator();
            while (i.hasNext()) {
                EventListenerMememto elm = (EventListenerMememto)i.next();
                NodeEventTarget et = elm.getTarget();
                if (et == evtTarget) {
                    EventListener el = elm.getListener();
                    boolean       uc = elm.getUseCapture();
                    String        t  = elm.getEventType();
                    boolean       n  = elm.getNamespaced();
                    if (et == null || el == null || t == null) {
                        continue;
                    }
                    if (n) {
                        String ns = elm.getNamespaceURI();
                        et.removeEventListenerNS(ns, t, el, uc);
                    } else {
                        et.removeEventListener(t, el, uc);
                    }
                }
            }
        }
    }

    /**
     * Adds EventListeners to the DOM and CSSEngineListener to the
     * CSSEngine to handle any modifications on the DOM tree or style
     * properties and update the GVT tree in response.
     */
    public void addDOMListeners() {
        SVGOMDocument doc = (SVGOMDocument)document;

        domAttrModifiedEventListener = new DOMAttrModifiedEventListener();
        doc.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMAttrModified",
             domAttrModifiedEventListener, true, null);

        domNodeInsertedEventListener = new DOMNodeInsertedEventListener();
        doc.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             domNodeInsertedEventListener, true, null);

        domNodeRemovedEventListener = new DOMNodeRemovedEventListener();
        doc.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             domNodeRemovedEventListener, true, null);

        domCharacterDataModifiedEventListener =
            new DOMCharacterDataModifiedEventListener();
        doc.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMCharacterDataModified",
             domCharacterDataModifiedEventListener, true, null);

        animatedAttributeListener = new AnimatedAttrListener();
        doc.addAnimatedAttributeListener(animatedAttributeListener);

        focusManager = new FocusManager(document);

        CSSEngine cssEngine = doc.getCSSEngine();
        cssPropertiesChangedListener = new CSSPropertiesChangedListener();
        cssEngine.addCSSEngineListener(cssPropertiesChangedListener);
    }

    /**
     * Removes event listeners from the DOM and CSS engine.
     */
    protected void removeDOMListeners() {
        SVGOMDocument doc = (SVGOMDocument)document;

        doc.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
             domAttrModifiedEventListener, true);
        doc.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
             domNodeInsertedEventListener, true);
        doc.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
             domNodeRemovedEventListener, true);
        doc.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMCharacterDataModified",
             domCharacterDataModifiedEventListener, true);

        doc.removeAnimatedAttributeListener(animatedAttributeListener);

        CSSEngine cssEngine = doc.getCSSEngine();
        if (cssEngine != null) {
            cssEngine.removeCSSEngineListener
                (cssPropertiesChangedListener);
            cssEngine.dispose();
            doc.setCSSEngine(null);
        }
    }

    /**
     * Adds to the eventListenerSet the specified event listener
     * registration.
     */
    protected void storeEventListener(EventTarget t,
                                      String s,
                                      EventListener l,
                                      boolean b) {
        synchronized (eventListenerSet) {
            eventListenerSet.add(new EventListenerMememto(t, s, l, b, this));
        }
    }

    /**
     * Adds to the eventListenerSet the specified event listener
     * registration.
     */
    protected void storeEventListenerNS(EventTarget t,
                                        String n,
                                        String s,
                                        EventListener l,
                                        boolean b) {
        synchronized (eventListenerSet) {
            eventListenerSet.add(new EventListenerMememto(t, n, s, l, b, this));
        }
    }

    public static class SoftReferenceMememto
        extends CleanerThread.SoftReferenceCleared {
        Object mememto;
        Set    set;
        // String refStr;
        SoftReferenceMememto(Object ref, Object mememto, Set set) {
            super(ref);
            // refStr = ref.toString();
            this.mememto = mememto;
            this.set     = set;
        }

        public void cleared() {
            synchronized (set) {
                // System.err.println("SRClear: " + refStr);
                set.remove(mememto);
                mememto = null;
                set     = null;
            }
        }
    }

    /**
     * A class used to store an EventListener added to the DOM.
     */
    protected static class EventListenerMememto {

        public SoftReference target; // Soft ref to EventTarget
        public SoftReference listener; // Soft ref to EventListener
        public boolean useCapture;
        public String namespaceURI;
        public String eventType;
        public boolean namespaced;

        public EventListenerMememto(EventTarget t,
                                    String s,
                                    EventListener l,
                                    boolean b,
                                    BridgeContext ctx) {
            Set set = ctx.eventListenerSet;
            target = new SoftReferenceMememto(t, this, set);
            listener = new SoftReferenceMememto(l, this, set);
            eventType = s;
            useCapture = b;
        }

        public EventListenerMememto(EventTarget t,
                                    String n,
                                    String s,
                                    EventListener l,
                                    boolean b,
                                    BridgeContext ctx) {
            this(t, s, l, b, ctx);
            namespaceURI = n;
            namespaced = true;
        }

        public EventListener getListener() {
            return (EventListener)listener.get();
        }
        public NodeEventTarget getTarget() {
            return (NodeEventTarget)target.get();
        }
        public boolean getUseCapture() {
            return useCapture;
        }
        public String getNamespaceURI() {
            return namespaceURI;
        }
        public String getEventType() {
            return eventType;
        }
        public boolean getNamespaced() {
            return namespaced;
        }
    }

    /**
     * Adds the GVT listener for AWT event support.
     */
    public void addGVTListener(Document doc) {
        BridgeEventSupport.addGVTListener(this, doc);
    }

    /**
     * Clears the list of child BridgeContexts and disposes them if there are
     * no more references to them.
     */
    protected void clearChildContexts() {
        childContexts.clear();
    }

    /**
     * Disposes this BridgeContext.
     */
    public void dispose() {
        clearChildContexts();

        synchronized (eventListenerSet) {
            // remove all listeners added by Bridges
            Iterator iter = eventListenerSet.iterator();
            while (iter.hasNext()) {
                EventListenerMememto m = (EventListenerMememto)iter.next();
                NodeEventTarget et = m.getTarget();
                EventListener   el = m.getListener();
                boolean         uc = m.getUseCapture();
                String          t  = m.getEventType();
                boolean         n  = m.getNamespaced();
                if (et == null || el == null || t == null) {
                    continue;
                }
                if (n) {
                    String ns = m.getNamespaceURI();
                    et.removeEventListenerNS(ns, t, el, uc);
                } else {
                    et.removeEventListener(t, el, uc);
                }
            }
        }

        if (document != null) {
            removeDOMListeners();
        }

        if (animationEngine != null) {
            animationEngine.dispose();
            animationEngine = null;
        }

        Iterator iter = interpreterMap.values().iterator();
        while (iter.hasNext()) {
            Interpreter interpreter = (Interpreter)iter.next();
            if (interpreter != null)
                interpreter.dispose();
        }
        interpreterMap.clear();

        if (focusManager != null) {
            focusManager.dispose();
        }
        if (elementDataMap != null) {
            elementDataMap.clear();
        }
        if (nodeElementMap != null) {
            nodeElementMap.clear();
        }
        if (elementNodeMap != null) {
            elementNodeMap.clear();
        }        
    }

    /**
     * Returns the SVGContext associated to the specified Node or null if
     * there is none.
     */
    protected static SVGContext getSVGContext(Node node) {
        if (node instanceof SVGOMElement) {
            return ((SVGOMElement) node).getSVGContext();
        } else if (node instanceof SVGOMDocument) {
            return ((SVGOMDocument) node).getSVGContext();
        } else {
            return null;
        }
    }

    /**
     * Returns the BridgeUpdateHandler associated to the specified Node
     * or null if there is none.
     */
    protected static BridgeUpdateHandler getBridgeUpdateHandler(Node node) {
        SVGContext ctx = getSVGContext(node);
        return (ctx == null) ? null : (BridgeUpdateHandler)ctx;
    }

    /**
     * The DOM EventListener invoked when an attribute is modified.
     */
    protected class DOMAttrModifiedEventListener implements EventListener {

        /**
         * Creates a new DOMAttrModifiedEventListener.
         */
        public DOMAttrModifiedEventListener() {
        }

        /**
         * Handles 'DOMAttrModified' event type.
         */
        public void handleEvent(Event evt) {
            Node node = (Node)evt.getTarget();
            BridgeUpdateHandler h = getBridgeUpdateHandler(node);
            if (h != null) {
                try {
                    h.handleDOMAttrModifiedEvent((MutationEvent)evt);
                } catch (Exception e) {
                    userAgent.displayError(e);
                }
            }
        }
    }

    /**
     * The DOM EventListener invoked when the mouse exits an element
     */
    protected class DOMMouseOutEventListener implements EventListener {

        /**
         * Creates a new DOMMouseOutEventListener.
         */
        public DOMMouseOutEventListener() {
        }

        /**
         * Handles 'mouseout' MouseEvent event type.
         */
        public void handleEvent(Event evt) {
            MouseEvent me = (MouseEvent)evt;
            Element newTarget = (Element)me.getRelatedTarget();
            Cursor cursor = CursorManager.DEFAULT_CURSOR;
            if (newTarget != null)
                cursor = CSSUtilities.convertCursor
                    (newTarget, BridgeContext.this);
            if (cursor == null)
                cursor = CursorManager.DEFAULT_CURSOR;

            userAgent.setSVGCursor(cursor);
        }
    }


    /**
     * The DOM EventListener invoked when the mouse mouves over a new
     * element.
     *
     * Here is how cursors are handled:
     *
     */
    protected class DOMMouseOverEventListener implements EventListener {

        /**
         * Creates a new DOMMouseOverEventListener.
         */
        public DOMMouseOverEventListener() {
        }

        /**
         * Handles 'mouseover' MouseEvent event type.
         */
        public void handleEvent(Event evt) {
            Element target = (Element)evt.getTarget();
            Cursor cursor = CSSUtilities.convertCursor(target, BridgeContext.this);

            if (cursor != null) {
                userAgent.setSVGCursor(cursor);
            }
        }
    }

    /**
     * The DOM EventListener invoked when a node is added.
     */
    protected class DOMNodeInsertedEventListener implements EventListener {

        /**
         * Creates a new DOMNodeInsertedEventListener.
         */
        public DOMNodeInsertedEventListener() {
        }

        /**
         * Handles 'DOMNodeInserted' event type.
         */
        public void handleEvent(Event evt) {
            MutationEvent me = (MutationEvent)evt;
            BridgeUpdateHandler h =
                getBridgeUpdateHandler(me.getRelatedNode());
            if (h != null) {
                try {
                    h.handleDOMNodeInsertedEvent(me);
                } catch (InterruptedBridgeException ibe) {
                    /* do nothing */
                } catch (Exception e) {
                    userAgent.displayError(e);
                }
            }
        }
    }

    /**
     * The DOM EventListener invoked when a node is removed.
     */
    protected class DOMNodeRemovedEventListener implements EventListener {

        /**
         * Creates a new DOMNodeRemovedEventListener.
         */
        public DOMNodeRemovedEventListener() {
        }

        /**
         * Handles 'DOMNodeRemoved' event type.
         */
        public void handleEvent(Event evt) {
            Node node = (Node)evt.getTarget();
            BridgeUpdateHandler h = getBridgeUpdateHandler(node);
            if (h != null) {
                try {
                    h.handleDOMNodeRemovedEvent((MutationEvent)evt);
                } catch (Exception e) {
                    userAgent.displayError(e);
                }
            }
        }
    }

    /**
     * The DOM EventListener invoked when a character data is changed.
     */
    protected class DOMCharacterDataModifiedEventListener
            implements EventListener {

        /**
         * Creates a new DOMCharacterDataModifiedEventListener.
         */
        public DOMCharacterDataModifiedEventListener() {
        }

        /**
         * Handles 'DOMCharacterDataModified' event type.
         */
        public void handleEvent(Event evt) {
            Node node = (Node)evt.getTarget();
            while (node != null && !(node instanceof SVGOMElement)) {
                node = (Node) ((AbstractNode) node).getParentNodeEventTarget();
            }
            BridgeUpdateHandler h = getBridgeUpdateHandler(node);
            if (h != null) {
                try {
                    h.handleDOMCharacterDataModified((MutationEvent)evt);
                } catch (Exception e) {
                    userAgent.displayError(e);
                }
            }
        }
    }

    /**
     * The CSSEngineListener invoked when CSS properties are modified
     * on a particular element.
     */
    protected class CSSPropertiesChangedListener implements CSSEngineListener {

        /**
         * Creates a new CSSPropertiesChangedListener.
         */
        public CSSPropertiesChangedListener() {
        }

        /**
         * Handles CSSEngineEvent that describes the CSS properties
         * that have changed on a particular element.
         */
        public void propertiesChanged(CSSEngineEvent evt) {
            Element elem = evt.getElement();
            SVGContext ctx = getSVGContext(elem);
            if (ctx == null) {
                GraphicsNode pgn = getGraphicsNode(elem.getParentNode());
                if ((pgn == null) || !(pgn instanceof CompositeGraphicsNode)) {
                    // Something changed in this element but we really don't
                    // care since its parent isn't displayed either.
                    return;
                }
                CompositeGraphicsNode parent = (CompositeGraphicsNode)pgn;
                // Check if 'display' changed on this element.

                int [] properties = evt.getProperties();
                for (int i=0; i < properties.length; ++i) {
                    if (properties[i] == SVGCSSEngine.DISPLAY_INDEX) {
                        if (!CSSUtilities.convertDisplay(elem)) {
                            // (Still) Not displayed
                            break;
                        }
                        // build the graphics node
                        GVTBuilder builder = getGVTBuilder();
                        GraphicsNode childNode = builder.build
                            (BridgeContext.this, elem);
                        if (childNode == null) {
                            // the added element is not a graphic element?
                            break;
                        }
                        int idx = -1;
                        for(Node ps = elem.getPreviousSibling(); ps != null;
                            ps = ps.getPreviousSibling()) {
                            if (ps.getNodeType() != Node.ELEMENT_NODE)
                                continue;
                            Element pse = (Element)ps;
                            GraphicsNode gn = getGraphicsNode(pse);
                            if (gn == null)
                                continue;
                            idx = parent.indexOf(gn);
                            if (idx == -1)
                                continue;
                            break;
                        }
                        // insert after prevSibling, if
                        // it was -1 this becomes 0 (first slot)
                        idx++;
                        parent.add(idx, childNode);
                        break;
                    }
                }
            } if (ctx != null && (ctx instanceof BridgeUpdateHandler)) {
                ((BridgeUpdateHandler)ctx).handleCSSEngineEvent(evt);
            }
        }
    }

    /**
     * A listener class for changes to animated attributes in the document.
     */
    protected class AnimatedAttrListener
        implements AnimatedAttributeListener {

        /**
         * Creates a new AnimatedAttributeListener.
         */
        public AnimatedAttrListener() {
        }

        /**
         * Called to notify an object of a change to the animated value of
         * an animated XML attribute.
         * @param e the owner element of the changed animated attribute
         * @param alav the AnimatedLiveAttributeValue that changed
         */
        public void animatedAttributeChanged(Element e,
                                             AnimatedLiveAttributeValue alav) {
            BridgeUpdateHandler h = getBridgeUpdateHandler(e);
            if (h != null) {
                try {
                    h.handleAnimatedAttributeChanged(alav);
                } catch (Exception ex) {
                    userAgent.displayError(ex);
                }
            }
        }

        /**
         * Called to notify an object of a change to the value of an 'other'
         * animation.
         * @param e the element being animated
         * @param type the type of animation whose value changed
         */
        public void otherAnimationChanged(Element e, String type) {
            BridgeUpdateHandler h = getBridgeUpdateHandler(e);
            if (h != null) {
                try {
                    h.handleOtherAnimationChanged(type);
                } catch (Exception ex) {
                    userAgent.displayError(ex);
                }
            }
        }
    }

    // CSS context ////////////////////////////////////////////////////////////

    /**
     * Returns the Value corresponding to the given system color.
     */
    public Value getSystemColor(String ident) {
        return SystemColorSupport.getSystemColor(ident);
    }

    /**
     * Returns the value corresponding to the default font.
     */
    public Value getDefaultFontFamily() {
        // No cache needed since the default font family is asked only
        // one time on the root element (only if it does not have its
        // own font-family).
        SVGOMDocument      doc  = (SVGOMDocument)document;
        SVGStylableElement root = (SVGStylableElement)doc.getRootElement();
        String str = userAgent.getDefaultFontFamily();
        return doc.getCSSEngine().parsePropertyValue
            (root,SVGConstants.CSS_FONT_FAMILY_PROPERTY, str);
    }

    /**
     * Returns a lighter font-weight.
     */
    public float getLighterFontWeight(float f) {
        return userAgent.getLighterFontWeight(f);
    }

    /**
     * Returns a bolder font-weight.
     */
    public float getBolderFontWeight(float f) {
        return userAgent.getBolderFontWeight(f);
    }

    /**
     * Returns the size of a px CSS unit in millimeters.
     */
    public float getPixelUnitToMillimeter() {
        return userAgent.getPixelUnitToMillimeter();
    }

    /**
     * Returns the size of a px CSS unit in millimeters.
     * This will be removed after next release.
     * @see #getPixelUnitToMillimeter()
     */
    public float getPixelToMillimeter() {
        return getPixelUnitToMillimeter();

    }

    /**
     * Returns the medium font size.
     */
    public float getMediumFontSize() {
        return userAgent.getMediumFontSize();
    }

    /**
     * Returns the width of the block which directly contains the
     * given element.
     */
    public float getBlockWidth(Element elt) {
        return getViewport(elt).getWidth();
    }

    /**
     * Returns the height of the block which directly contains the
     * given element.
     */
    public float getBlockHeight(Element elt) {
        return getViewport(elt).getHeight();
    }

    /**
     * This method throws a SecurityException if the resource
     * found at url and referenced from docURL
     * should not be loaded.
     *
     * This is a convenience method to call checkLoadExternalResource
     * on the ExternalResourceSecurity strategy returned by
     * getExternalResourceSecurity.
     *
     * @param resourceURL url for the script, as defined in
     *        the resource's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     * @param docURL url for the document into which the
     *        resource was found.
     */
    public void
        checkLoadExternalResource(ParsedURL resourceURL,
                                  ParsedURL docURL) throws SecurityException {
        userAgent.checkLoadExternalResource(resourceURL,
                                            docURL);
    }


    /**
     * Tells whether the given SVG document is dynamic.
     */
    public boolean isDynamicDocument(Document doc) {
        return BaseScriptingEnvironment.isDynamicDocument(this, doc);
    }

    /**
     * Tells whether the given SVG document is Interactive.
     * We say it is, if it has any &lt;title>, &lt;desc>, or &lt;a> elements,
     * of if the 'cursor' property is anything but Auto on any element.
     */
    public boolean isInteractiveDocument(Document doc) {

        Element root = ((SVGDocument)doc).getRootElement();
        if (!SVGConstants.SVG_NAMESPACE_URI.equals(root.getNamespaceURI()))
            return false;

        return checkInteractiveElement(root);
    }

    /**
     * used by isInteractiveDocument to check if document
     * contains any 'interactive' elements.
     */
    public boolean checkInteractiveElement(Element e) {
        return checkInteractiveElement
            ((SVGDocument)e.getOwnerDocument(), e);
    }

    /**
     * used by isInteractiveDocument to check if document
     * contains any 'interactive' elements.
     */
    public boolean checkInteractiveElement(SVGDocument doc,
                                           Element e) {
        String tag = e.getLocalName();

        // Check if it's one of our important element.
        if (SVGConstants.SVG_A_TAG.equals(tag))
            return true;

        // This is a bit of a hack but don't count
        // title and desc as children of root SVG since
        // we don't show tool tips for them anyways.
        if (SVGConstants.SVG_TITLE_TAG.equals(tag)) {
            return (e.getParentNode() != doc.getRootElement());
        }
        if (SVGConstants.SVG_DESC_TAG.equals(tag)) {
            return (e.getParentNode() != doc.getRootElement());
        }
        if (SVGConstants.SVG_CURSOR_TAG.equals(tag))
            return true;

        // I am well aware that this is not 100% accurate but it's
        // the best I can do w/o booting the CSSEngine.
        if (e.getAttribute(CSSConstants.CSS_CURSOR_PROPERTY).length() >0)
            return true;

        /* We would like to do this but the CSS Engine isn't setup when
           we want to do this.

        // Check if cursor property is set to something other than 'auto'.
        Value cursorValue = CSSUtilities.getComputedStyle
            (e, SVGCSSEngine.CURSOR_INDEX);
        if ((cursorValue != null) &&
            (cursorValue.getCssValueType()  == CSSValue.CSS_PRIMITIVE_VALUE) &&
            (cursorValue.getPrimitiveType() == CSSPrimitiveValue.CSS_IDENT) &&
            (SVGConstants.SVG_AUTO_VALUE.equals(cursorValue.getStringValue())))
            return true;
        */

        // Check all the child elements for any of the above.
        final String svg_ns = SVGConstants.SVG_NAMESPACE_URI;
        for (Node n = e.getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                Element child = (Element)n;
                if (svg_ns.equals(child.getNamespaceURI()))
                    if (checkInteractiveElement(child))
                        return true;
            }
        }
        return false;
    }

    /**
     * Sets the animation limiting mode to "none".
     */
    public void setAnimationLimitingNone() {
        animationLimitingMode = 0;
        if (animationEngine != null) {
            setAnimationLimitingMode();
        }
    }

    /**
     * Sets the animation limiting mode to a percentage of CPU.
     * @param pc the maximum percentage of CPU to use (0 &lt; pc ≤ 1)
     */
    public void setAnimationLimitingCPU(float pc) {
        animationLimitingMode = 1;
        animationLimitingAmount = pc;
        if (animationEngine != null) {
            setAnimationLimitingMode();
        }
    }

    /**
     * Sets the animation limiting mode to a number of frames per second.
     * @param fps the maximum number of frames per second (fps &gt; 0)
     */
    public void setAnimationLimitingFPS(float fps) {
        animationLimitingMode = 2;
        animationLimitingAmount = fps;
        if (animationEngine != null) {
            setAnimationLimitingMode();
        }
    }

    /**
     * Set the animationg limiting mode on the animation engine.
     */
    protected void setAnimationLimitingMode() {
        switch (animationLimitingMode) {
            case 0: // unlimited
                animationEngine.setAnimationLimitingNone();
                break;
            case 1: // %cpu
                animationEngine.setAnimationLimitingCPU
                    (animationLimitingAmount);
                break;
            case 2: // fps
                animationEngine.setAnimationLimitingFPS
                    (animationLimitingAmount);
                break;
        }
    }

    // bridge extensions support //////////////////////////////////////////////

    protected List extensions = null;

    /**
     * Registers the bridges to handle SVG 1.0 elements.
     */
    public void registerSVGBridges() {
        UserAgent ua = getUserAgent();
        List ext = getBridgeExtensions(document);
        Iterator iter = ext.iterator();

        while(iter.hasNext()) {
            BridgeExtension be = (BridgeExtension)iter.next();
            be.registerTags(this);
            ua.registerExtension(be);
        }
    }

    public List getBridgeExtensions(Document doc) {
        Element root = ((SVGOMDocument)doc).getRootElement();
        String ver = root.getAttributeNS
            (null, SVGConstants.SVG_VERSION_ATTRIBUTE);
        BridgeExtension svgBE;
        if ((ver.length()==0) || ver.equals("1.0") || ver.equals("1.1"))
            svgBE = new SVGBridgeExtension();
        else
            svgBE = new SVG12BridgeExtension();

        float priority = svgBE.getPriority();
        extensions = new LinkedList(getGlobalBridgeExtensions());

        ListIterator li = extensions.listIterator();
        for (;;) {
            if (!li.hasNext()) {
                li.add(svgBE);
                break;
            }
            BridgeExtension lbe = (BridgeExtension)li.next();
            if (lbe.getPriority() > priority) {
                li.previous();
                li.add(svgBE);
                break;
            }
        }

        return extensions;
    }

    /**
     * Returns the extensions supported by this bridge context.
     */
    protected static List globalExtensions = null;

    public static synchronized List getGlobalBridgeExtensions() {
        if (globalExtensions != null) {
            return globalExtensions;
        }
        globalExtensions = new LinkedList();

        Iterator iter = Service.providers(BridgeExtension.class);

        while (iter.hasNext()) {
            BridgeExtension be = (BridgeExtension)iter.next();
            float priority  = be.getPriority();
            ListIterator li = globalExtensions.listIterator();
            for (;;) {
                if (!li.hasNext()) {
                    li.add(be);
                    break;
                }
                BridgeExtension lbe = (BridgeExtension)li.next();
                if (lbe.getPriority() > priority) {
                    li.previous();
                    li.add(be);
                    break;
                }
            }
        }
        return globalExtensions;
    }

    public static class CSSEngineUserAgentWrapper implements CSSEngineUserAgent {
        UserAgent ua;
        CSSEngineUserAgentWrapper(UserAgent ua) {
            this.ua = ua;
        }

        /**
         * Displays an error resulting from the specified Exception.
         */
        public void displayError(Exception ex) { ua.displayError(ex); }

        /**
         * Displays a message in the User Agent interface.
         */
        public void displayMessage(String message) { ua.displayMessage(message); }
    }

}

