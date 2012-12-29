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
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.svg12.XBLOMContentElement;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.XBLConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * Bridge class for the &lt;xbl:content&gt; element.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: XBLContentElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class XBLContentElementBridge extends AbstractGraphicsNodeBridge {
    
    /**
     * The event listener for content element selection changes.
     */
    protected ContentChangedListener contentChangedListener;

    /**
     * The ContentManager object used for the content element selection
     * change events.
     */
    protected ContentManager contentManager;

    /**
     * Constructs a new bridge for the &lt;xbl:content&gt; element.
     */
    public XBLContentElementBridge() {
    }

    /**
     * Returns 'content'.
     */
    public String getLocalName() {
        return XBLConstants.XBL_CONTENT_TAG;
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
        return new XBLContentElementBridge();
    }

    /**
     * Creates a <tt>GraphicsNode</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @return a graphics node that represents the specified element
     */
    public GraphicsNode createGraphicsNode(BridgeContext ctx, Element e) {
        CompositeGraphicsNode gn = buildCompositeGraphicsNode(ctx, e, null);
        return gn;
    }

    /**
     * Creates a <tt>GraphicsNode</tt> from the input element and
     * populates the input <tt>CompositeGraphicsNode</tt>
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @param cgn the CompositeGraphicsNode where the use graphical 
     *        content will be appended. The composite node is emptied
     *        before appending new content.
     */
    public CompositeGraphicsNode buildCompositeGraphicsNode
        (BridgeContext ctx, Element e, CompositeGraphicsNode cgn) {

        XBLOMContentElement content = (XBLOMContentElement) e;
        AbstractDocument doc = (AbstractDocument) e.getOwnerDocument();
        DefaultXBLManager xm = (DefaultXBLManager) doc.getXBLManager();
        contentManager = xm.getContentManager(e);

        if (cgn == null) {
            cgn = new CompositeGraphicsNode();
            associateSVGContext(ctx, e, cgn);
        } else {
            int s = cgn.size();
            for (int i = 0; i < s; i++) {
                cgn.remove(0);
            }
        }

        GVTBuilder builder = ctx.getGVTBuilder();
        NodeList nl = contentManager.getSelectedContent(content);
        if (nl != null) {
            for (int i = 0; i < nl.getLength(); i++) {
                Node n = nl.item(i);
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    GraphicsNode gn = builder.build(ctx, (Element) n);
                    if (gn != null) {
                        cgn.add(gn);
                    }
                }
            }
        }

        if (ctx.isDynamic()) {
            if (contentChangedListener == null) {
                // Should be the same ContentManager each build
                contentChangedListener = new ContentChangedListener();
                contentManager.addContentSelectionChangedListener
                    (content, contentChangedListener);
            }
        }

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
     * Returns false as the &lt;xbl:content&gt; element's selected nodes
     * are built all in this class.
     */
    public boolean isComposite() {
        return false;
    }

    /**
     * Dispose this bridge by removing the ContentSelectionChangedListener
     * object.
     */
    public void dispose() {
        super.dispose();

        if (contentChangedListener != null) {
            contentManager.removeContentSelectionChangedListener
                ((XBLOMContentElement) e, contentChangedListener);
        }
    }

    /**
     * Class to respond to content selection changes and cause GVT rebuilds.
     */
    protected class ContentChangedListener
            implements ContentSelectionChangedListener {

        /**
         * Invoked after an xbl:content element has updated its selected
         * nodes list.
         * @param csce the ContentSelectionChangedEvent object
         */
        public void contentSelectionChanged(ContentSelectionChangedEvent csce) {
            buildCompositeGraphicsNode(ctx, e, (CompositeGraphicsNode) node);
        }
    }
}
