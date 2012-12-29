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

import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.svg.SVGTests;

/**
 * Bridge class for the &lt;switch> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGSwitchElementBridge.java 491178 2006-12-30 06:18:34Z cam $
 */
public class SVGSwitchElementBridge extends SVGGElementBridge {

    /**
     * The child element that was chosen for rendering according to the
     * test attributes.
     */
    protected Element selectedChild;

    /**
     * Constructs a new bridge for the &lt;switch> element.
     */
    public SVGSwitchElementBridge() {}

    /**
     * Returns 'switch'.
     */
    public String getLocalName() {
        return SVG_SWITCH_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGSwitchElementBridge();
    }

    /**
     * Creates a <tt>GraphicsNode</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param e the element that describes the graphics node to build
     * @return a graphics node that represents the specified element
     */
    public GraphicsNode createGraphicsNode(BridgeContext ctx, Element e) {
        GraphicsNode refNode = null;
        GVTBuilder builder = ctx.getGVTBuilder();
        selectedChild = null;
        for (Node n = e.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                Element ref = (Element)n;
                if (n instanceof SVGTests &&
                        SVGUtilities.matchUserAgent(ref, ctx.getUserAgent())) {
                    selectedChild = ref;
                    refNode = builder.build(ctx, ref);
                    break;
                }
            }
        }

        if (refNode == null) {
            return null;
        }

        CompositeGraphicsNode group =
            (CompositeGraphicsNode) super.createGraphicsNode(ctx, e);
        if (group == null) {
            return null;
        }

        group.add(refNode);

        return group;
    }

    /**
     * Returns true as the &lt;switch> element is not a container.
     */
    public boolean isComposite() {
        return false;
    }

    // BridgeUpdateHandler implementation //////////////////////////////////

    /**
     * Disposes this BridgeUpdateHandler and releases all resources.
     */
    public void dispose() {
        selectedChild = null;
        super.dispose();
    }

    /**
     * Responds to the insertion of a child element by re-evaluating the
     * test attributes.
     */
    protected void handleElementAdded(CompositeGraphicsNode gn, 
                                      Node parent, 
                                      Element childElt) {
        for (Node n = childElt.getPreviousSibling(); n
                != null;
                n = n.getPreviousSibling()) {
            if (n == childElt) {
                return;
            }
        }
        if (childElt instanceof SVGTests
                && SVGUtilities.matchUserAgent(childElt, ctx.getUserAgent())) {
            if (selectedChild != null) {
                gn.remove(0);
                disposeTree(selectedChild);
            }
            selectedChild = childElt;
            GVTBuilder builder = ctx.getGVTBuilder();
            GraphicsNode refNode = builder.build(ctx, childElt);
            if (refNode != null) {
                gn.add(refNode);
            }
        }
    }

    /**
     * Responds to the removal of a child element by re-evaluating the
     * test attributes.
     */
    protected void handleChildElementRemoved(Element e) {
        CompositeGraphicsNode gn = (CompositeGraphicsNode) node;
        if (selectedChild == e) {
            gn.remove(0);
            disposeTree(selectedChild);
            selectedChild = null;
            GraphicsNode refNode = null;
            GVTBuilder builder = ctx.getGVTBuilder();
            for (Node n = e.getNextSibling();
                    n != null;
                    n = n.getNextSibling()) {
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    Element ref = (Element) n;
                    if (n instanceof SVGTests &&
                            SVGUtilities.matchUserAgent
                                (ref, ctx.getUserAgent())) {
                        refNode = builder.build(ctx, ref);
                        selectedChild = ref;
                        break;
                    }
                }
            }

            if (refNode != null) {
                gn.add(refNode);
            }
        }
    }
}
