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
import org.apache.flex.forks.batik.gvt.RootGraphicsNode;
import org.apache.flex.forks.batik.util.HaltingThread;
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * This class is responsible for creating a GVT tree using an SVG DOM tree.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: GVTBuilder.java 599681 2007-11-30 02:55:48Z cam $
 */
public class GVTBuilder implements SVGConstants {

    /**
     * Constructs a new builder.
     */
    public GVTBuilder() { }

    /**
     * Builds using the specified bridge context the specified SVG document.
     *
     * @param ctx the bridge context
     * @param document the SVG document to build
     * @exception BridgeException if an error occured while constructing
     * the GVT tree
     */
    public GraphicsNode build(BridgeContext ctx, Document document) {
        // the bridge context is now associated to one document
        ctx.setDocument(document);
        ctx.initializeDocument(document);

        // inform the bridge context the builder to use
        ctx.setGVTBuilder(this);

        // build the GVT tree
        DocumentBridge dBridge = ctx.getDocumentBridge();
        RootGraphicsNode rootNode = null;
        try {
            // create the root node
            rootNode = dBridge.createGraphicsNode(ctx, document);
            Element svgElement = document.getDocumentElement();
            GraphicsNode topNode = null;

            // get the appropriate bridge according to the specified element
            Bridge bridge = ctx.getBridge(svgElement);
            if (bridge == null || !(bridge instanceof GraphicsNodeBridge)) {
                return null;
            }
            // create the associated composite graphics node
            GraphicsNodeBridge gnBridge = (GraphicsNodeBridge)bridge;
            topNode = gnBridge.createGraphicsNode(ctx, svgElement);
            if (topNode == null) {
                return null;
            }
            rootNode.getChildren().add(topNode);

            buildComposite(ctx, svgElement, (CompositeGraphicsNode)topNode);
            gnBridge.buildGraphicsNode(ctx, svgElement, topNode);

            // finally, build the root node
            dBridge.buildGraphicsNode(ctx, document, rootNode);
        } catch (BridgeException ex) {
            // update the exception with the missing parameters
            ex.setGraphicsNode(rootNode);
            //ex.printStackTrace();
            throw ex; // re-throw the udpated exception
        }

        // For cursor handling
        if (ctx.isInteractive()) {
            ctx.addUIEventListeners(document);

            // register GVT listeners for AWT event support
            ctx.addGVTListener(document);
        }

        // <!> FIXME: TO BE REMOVED
        if (ctx.isDynamic()) {
            // register DOM listeners for dynamic support
            ctx.addDOMListeners();
        }
        return rootNode;
    }

    /**
     * Builds using the specified bridge context the specified Element.
     *
     * @param ctx the bridge context
     * @param e the element to build
     * @exception BridgeException if an error occured while constructing
     * the GVT tree
     */
    public GraphicsNode build(BridgeContext ctx, Element e) {
        // get the appropriate bridge according to the specified element
        Bridge bridge = ctx.getBridge(e);
        if (bridge instanceof GenericBridge) {
            // If it is a GenericBridge just handle it and any GenericBridge
            // descendents and return.
            ((GenericBridge) bridge).handleElement(ctx, e);
            handleGenericBridges(ctx, e);
            return null;
        } else if (bridge == null || !(bridge instanceof GraphicsNodeBridge)) {
            handleGenericBridges(ctx, e);
            return null;
        }
        // create the associated graphics node
        GraphicsNodeBridge gnBridge = (GraphicsNodeBridge)bridge;
        // check the display property
        if (!gnBridge.getDisplay(e)) {
            handleGenericBridges(ctx, e);
            return null;
        }
        GraphicsNode gn = gnBridge.createGraphicsNode(ctx, e);
        if (gn != null) {
            if (gnBridge.isComposite()) {
                buildComposite(ctx, e, (CompositeGraphicsNode)gn);
            } else {
                handleGenericBridges(ctx, e);
            }
            gnBridge.buildGraphicsNode(ctx, e, gn);
        }
        // <!> FIXME: see build(BridgeContext, Element)
        // + may load the script twice (for example
        // outside 'use' is ok versus local 'use' maybe wrong).
        if (ctx.isDynamic()) {
            //BridgeEventSupport.loadScripts(ctx, e);
        }
        return gn;
    }

    /**
     * Builds a composite Element.
     *
     * @param ctx the bridge context
     * @param e the element to build
     * @param parentNode the composite graphics node, parent of the
     *                   graphics node to build
     * @exception BridgeException if an error occured while constructing
     * the GVT tree
     */
    protected void buildComposite(BridgeContext ctx,
                                  Element e,
                                  CompositeGraphicsNode parentNode) {
        for (Node n = e.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                buildGraphicsNode(ctx, (Element)n, parentNode);
            }
        }
    }

    /**
     * Builds a 'leaf' Element.
     *
     * @param ctx the bridge context
     * @param e the element to build
     * @param parentNode the composite graphics node, parent of the
     *                   graphics node to build
     * @exception BridgeException if an error occured while constructing
     * the GVT tree
     */
    protected void buildGraphicsNode(BridgeContext ctx,
                                     Element e,
                                     CompositeGraphicsNode parentNode) {
        // Check If we should halt early.
        if (HaltingThread.hasBeenHalted()) {
            throw new InterruptedBridgeException();
        }
        // get the appropriate bridge according to the specified element
        Bridge bridge = ctx.getBridge(e);
        if (bridge instanceof GenericBridge) {
            // If it is a GenericBridge just handle it and any GenericBridge
            // descendents and return.
            ((GenericBridge) bridge).handleElement(ctx, e);
            handleGenericBridges(ctx, e);
            return;
        } else if (bridge == null || !(bridge instanceof GraphicsNodeBridge)) {
            handleGenericBridges(ctx, e);
            return;
        }
        // check the display property
        if (!CSSUtilities.convertDisplay(e)) {
            handleGenericBridges(ctx, e);
            return;
        }
        GraphicsNodeBridge gnBridge = (GraphicsNodeBridge)bridge;
        try {
            // create the associated graphics node
            GraphicsNode gn = gnBridge.createGraphicsNode(ctx, e);
            if (gn != null) {
                // attach the graphics node to the GVT tree now !
                parentNode.getChildren().add(gn);
                // check if the element has children to build
                if (gnBridge.isComposite()) {
                    buildComposite(ctx, e, (CompositeGraphicsNode)gn);
                } else {
                    // if not then still handle the GenericBridges
                    handleGenericBridges(ctx, e);
                }
                gnBridge.buildGraphicsNode(ctx, e, gn);
            } else {
                handleGenericBridges(ctx, e);
            }
        } catch (BridgeException ex) {
            // some bridge may decide that the node in error can be
            // displayed (e.g. polyline, path...)
            // In this case, the exception contains the GraphicsNode
            GraphicsNode errNode = ex.getGraphicsNode();
            if (errNode != null) {
                parentNode.getChildren().add(errNode);
                gnBridge.buildGraphicsNode(ctx, e, errNode);
                ex.setGraphicsNode(null);
            }
            //ex.printStackTrace();
            throw ex;
        }
    }

    /**
     * Handles any GenericBridge elements which are children of the
     * specified element.
     * @param ctx the bridge context
     * @param e the element whose child elements should be handled
     */
    protected void handleGenericBridges(BridgeContext ctx, Element e) {
        for (Node n = e.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (n instanceof Element) {
                Element e2 = (Element) n;
                Bridge b = ctx.getBridge(e2);
                if (b instanceof GenericBridge) {
                    ((GenericBridge) b).handleElement(ctx, e2);
                }
                handleGenericBridges(ctx, e2);
            }
        }
    }
}
