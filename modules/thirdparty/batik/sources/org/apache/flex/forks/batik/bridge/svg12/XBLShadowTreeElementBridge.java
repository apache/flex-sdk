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
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.XBLConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for the &lt;xbl:shadowTree&gt; element.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: XBLShadowTreeElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class XBLShadowTreeElementBridge extends AbstractGraphicsNodeBridge {
    
    /**
     * Constructs a new bridge for the &lt;xbl:shadowTree&gt; element.
     */
    public XBLShadowTreeElementBridge() {}

    /**
     * Returns 'shadowTree'.
     */
    public String getLocalName() {
        return XBLConstants.XBL_SHADOW_TREE_TAG;
    }

    /**
     * Returns the XBL namespace.
     */
    public String getNamespaceURI() {
        return XBLConstants.XBL_NAMESPACE_URI;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new XBLShadowTreeElementBridge();
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

        CompositeGraphicsNode cgn = new CompositeGraphicsNode();

        associateSVGContext(ctx, e, cgn);

        return cgn;
    }

    /**
     * Creates a <tt>CompositeGraphicsNode</tt>.
     */
    protected GraphicsNode instantiateGraphicsNode() {
        // Not needed, since createGraphicsNode is overridden
        return null;
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

    /**
     * Returns true if the graphics node has to be displayed, false
     * otherwise.
     */
    public boolean getDisplay(Element e) {
        return true;
    }

    /**
     * Returns true as the &lt;xbl:template&gt; element is a container.
     */
    public boolean isComposite() {
        return true;
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Invoked when an MutationEvent of type 'DOMNodeInserted' is fired.
     */
    public void handleDOMNodeInsertedEvent(MutationEvent evt) {
        if (evt.getTarget() instanceof Element) {
            handleElementAdded((CompositeGraphicsNode)node, 
                               e, 
                               (Element)evt.getTarget());
        }
    }

    /**
     * Invoked when an MutationEvent of type 'DOMNodeInserted' is fired.
     */
    public void handleElementAdded(CompositeGraphicsNode gn, 
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
