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
package org.apache.flex.forks.batik.bridge.svg12;

import org.apache.flex.forks.batik.bridge.AbstractGraphicsNodeBridge;
import org.apache.flex.forks.batik.bridge.Bridge;
import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.GVTBuilder;
import org.apache.flex.forks.batik.bridge.SVGUtilities;
import org.apache.flex.forks.batik.bridge.ScriptingEnvironment;
import org.apache.flex.forks.batik.bridge.UpdateManager;
import org.apache.flex.forks.batik.dom.svg12.BindableElement;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for foreign namespace elements that can be bound with sXBL.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: BindableElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class BindableElementBridge
        extends AbstractGraphicsNodeBridge
        implements SVG12BridgeUpdateHandler {

    /**
     * Constructs a new bridge for custom elements.
     */
    public BindableElementBridge() {
    }

    /**
     * Returns "*" to indicate a default bridge.
     */
    public String getNamespaceURI() {
        return "*";
    }

    /**
     * Returns "*" to indicate a default bridge.
     */
    public String getLocalName() {
        return "*";
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new BindableElementBridge();
    }

    /**
     * Creates a <tt>GraphicsNode</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @return a graphics node that represents the specified element
     */
    public GraphicsNode createGraphicsNode(BridgeContext ctx, Element e) {
        // 'requiredFeatures', 'requiredExtensions' and 'systemLanguage'
        if (!SVGUtilities.matchUserAgent(e, ctx.getUserAgent())) {
            return null;
        }

        CompositeGraphicsNode gn = buildCompositeGraphicsNode(ctx, e, null);

        return gn;
    }

    /**
     * Creates a <tt>GraphicsNode</tt> from the input element and
     * populates the input <tt>CompositeGraphicsNode</tt>
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @param gn the CompositeGraphicsNode where the use graphical 
     *        content will be appended. The composite node is emptied
     *        before appending new content.
     */
    public CompositeGraphicsNode
            buildCompositeGraphicsNode(BridgeContext ctx, 
                                       Element e,
                                       CompositeGraphicsNode gn) {

        BindableElement be = (BindableElement) e;
        Element shadowTree = be.getXblShadowTree();

        UpdateManager um = ctx.getUpdateManager();
        ScriptingEnvironment se = um == null ? null
                                             : um.getScriptingEnvironment();

        if (se != null && shadowTree != null) {
            se.addScriptingListeners(shadowTree);
        }

        if (gn == null) {
            gn = new CompositeGraphicsNode();
            associateSVGContext(ctx, e, gn);
        } else {
            int s = gn.size();
            for (int i = 0; i < s; i++) {
                gn.remove(0);
            }
        }

        GVTBuilder builder = ctx.getGVTBuilder();

        if (shadowTree != null) {
            GraphicsNode shadowNode = builder.build(ctx, shadowTree);
            if (shadowNode != null) {
                gn.add(shadowNode);
            }
        } else {
            for (Node m = e.getFirstChild(); m != null; m = m.getNextSibling()) {
                if (m.getNodeType() == Node.ELEMENT_NODE) {
                    GraphicsNode n = builder.build(ctx, (Element) m);
                    if (n != null) {
                        gn.add(n);
                    }
                }
            }
        }

        return gn;
    }

    public void dispose() {
        BindableElement be = (BindableElement) e;
        if (be != null && be.getCSSFirstChild() != null) {
            disposeTree(be.getCSSFirstChild());
        }

        super.dispose();
    }

    /**
     * Creates the GraphicsNode depending on the GraphicsNodeBridge
     * implementation.
     */
    protected GraphicsNode instantiateGraphicsNode() {
        return null; // nothing to do, createGraphicsNode is fully overriden
    }

    /**
     * Returns false as the custom element is a not container.
     */
    public boolean isComposite() {
        return false;
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

        initializeDynamicSupport(ctx, e, node);
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when an MutationEvent of type 'DOMNodeInserted' is fired.
     */
    public void handleDOMNodeInsertedEvent(MutationEvent evt) {
        // Only rebuild the graphics tree if this custom element is not bound.
        BindableElement be = (BindableElement) e;
        Element shadowTree = be.getXblShadowTree();

        if (shadowTree == null && evt.getTarget() instanceof Element) {
            handleElementAdded((CompositeGraphicsNode) node, 
                               e, 
                               (Element) evt.getTarget());
        }
    }

    /**
     * Invoked when a bindable element's binding has changed.
     */
    public void handleBindingEvent(Element bindableElement,
                                   Element shadowTree) {
        CompositeGraphicsNode gn = node.getParent();
        gn.remove(node);
        disposeTree(e);

        handleElementAdded(gn, e.getParentNode(), e);
    }

    /**
     * Invoked when the xblChildNodes property has changed because a
     * descendant xbl:content element has updated its selected nodes.
     */
    public void handleContentSelectionChangedEvent
            (ContentSelectionChangedEvent csce) {
    }

    /**
     * Rebuild the graphics tree.
     */
    protected void handleElementAdded(CompositeGraphicsNode gn, 
                                      Node parent, 
                                      Element childElt) {
        // build the graphics node
        GVTBuilder builder = ctx.getGVTBuilder();
        GraphicsNode childNode = builder.build(ctx, childElt);
        if (childNode == null) {
            return; // the added element is not a graphic element
        }
        
        // Find the index where the GraphicsNode should be added
        int idx = -1;
        for(Node ps = childElt.getPreviousSibling(); ps != null;
            ps = ps.getPreviousSibling()) {
            if (ps.getNodeType() != Node.ELEMENT_NODE)
                continue;
            Element pse = (Element)ps;
            GraphicsNode psgn = ctx.getGraphicsNode(pse);
            while ((psgn != null) && (psgn.getParent() != gn)) {
                // In some cases the GN linked is
                // a child (in particular for images).
                psgn = psgn.getParent();
            }
            if (psgn == null)
                continue;
            idx = gn.indexOf(psgn);
            if (idx == -1)
                continue;
            break;
        }
        // insert after prevSibling, if
        // it was -1 this becomes 0 (first slot)
        idx++; 
        gn.add(idx, childNode);
    }
}
