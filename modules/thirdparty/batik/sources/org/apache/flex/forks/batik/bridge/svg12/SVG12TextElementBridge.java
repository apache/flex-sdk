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

import org.apache.flex.forks.batik.bridge.Bridge;
import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.SVGTextElementBridge;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.svg12.XBLEventSupport;
import org.apache.flex.forks.batik.dom.events.EventSupport;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.xbl.NodeXBL;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.MutationEvent;

/**
 * Bridge class for SVG 'text' elements with support for text content
 * that has been specified with XBL.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVG12TextElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVG12TextElementBridge
        extends SVGTextElementBridge
        implements SVG12BridgeUpdateHandler {

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVG12TextElementBridge();
    }

    /**
     * Adds the DOM listeners for this text bridge.
     */
    protected void addTextEventListeners(BridgeContext ctx, NodeEventTarget e) {
        if (childNodeRemovedEventListener == null) {
            childNodeRemovedEventListener =
                new DOMChildNodeRemovedEventListener();
        }
        if (subtreeModifiedEventListener == null) {
            subtreeModifiedEventListener =
                new DOMSubtreeModifiedEventListener();
        }

        SVG12BridgeContext ctx12 = (SVG12BridgeContext) ctx;
        AbstractNode n = (AbstractNode) e;
        XBLEventSupport evtSupport =
            (XBLEventSupport) n.initializeEventSupport();

        //to be notified when a child is removed from the 
        //<text> element.
        evtSupport.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
             childNodeRemovedEventListener, true);
        ctx12.storeImplementationEventListenerNS
            (e, XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
             childNodeRemovedEventListener, true);
        
        //to be notified when the modification of the subtree
        //of the <text> element is done
        evtSupport.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMSubtreeModified",
             subtreeModifiedEventListener, false);
        ctx12.storeImplementationEventListenerNS
            (e, XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMSubtreeModified",
             subtreeModifiedEventListener, false);
    }

    /**
     * Removes the DOM listeners for this text bridge.
     */
    protected void removeTextEventListeners(BridgeContext ctx,
                                            NodeEventTarget e) {
        AbstractNode n = (AbstractNode) e;
        XBLEventSupport evtSupport =
            (XBLEventSupport) n.initializeEventSupport();

        evtSupport.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
             childNodeRemovedEventListener, true);
        evtSupport.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMSubtreeModified",
             subtreeModifiedEventListener, false);
    }

    /**
     * The DOM EventListener invoked when a node is removed.
     */
    protected class DOMChildNodeRemovedEventListener
            extends SVGTextElementBridge.DOMChildNodeRemovedEventListener {
        public void handleEvent(Event evt) {
            super.handleEvent(EventSupport.getUltimateOriginalEvent(evt));
        }
    }

    /**
     * The DOM EventListener invoked when the subtree is modified.
     */
    protected class DOMSubtreeModifiedEventListener
            extends SVGTextElementBridge.DOMSubtreeModifiedEventListener {
        public void handleEvent(Event evt) {
            super.handleEvent(EventSupport.getUltimateOriginalEvent(evt));
        }
    }

    // Tree navigation ------------------------------------------------------

    /**
     * Returns the first child node of the given node that should be
     * processed by the text bridge.
     */
    protected Node getFirstChild(Node n) {
        return ((NodeXBL) n).getXblFirstChild();
    }

    /**
     * Returns the next sibling node of the given node that should be
     * processed by the text bridge.
     */
    protected Node getNextSibling(Node n) {
        return ((NodeXBL) n).getXblNextSibling();
    }

    /**
     * Returns the parent node of the given node that should be
     * processed by the text bridge.
     */
    protected Node getParentNode(Node n) {
        return ((NodeXBL) n).getXblParentNode();
    }

    // SVG12BridgeUpdateHandler //////////////////////////////////////////////

    /**
     * Invoked when an MutationEvent of type 'DOMCharacterDataModified' 
     * is fired.
     */
    public void handleDOMCharacterDataModified(MutationEvent evt) {
        Node childNode = (Node)evt.getTarget();
        //if the parent is displayed, then discard the layout.
        if (isParentDisplayed(childNode)) {
            if (getParentNode(childNode) != childNode.getParentNode()) {
                // This text node was selected with an xbl:content element,
                // so a DOMSubtreeModified event is not going to be captured.
                // Better recompute the text layout now.
                computeLaidoutText(ctx, e, node);
            } else {
                laidoutText = null;
            }
        }
    }

    /**
     * Invoked when a bindable element's binding has changed.
     */
    public void handleBindingEvent(Element bindableElement,
                                   Element shadowTree) {
    }

    /**
     * Invoked when the xblChildNodes property has changed because a
     * descendant xbl:content element has updated its selected nodes.
     */
    public void handleContentSelectionChangedEvent
            (ContentSelectionChangedEvent csce) {
        computeLaidoutText(ctx, e, node);
    }
}
