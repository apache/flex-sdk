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

import java.util.Collections;
import java.util.Iterator;

import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Element;

/**
 * This is a Service interface for classes that want to extend the
 * functionality of the Bridge, to support new tags in the rendering tree.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: SVGBridgeExtension.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGBridgeExtension implements BridgeExtension {

    /**
     * Return the priority of this Extension.  Extensions are
     * registered from lowest to highest priority.  So if for some
     * reason you need to come before/after another existing extension
     * make sure your priority is lower/higher than theirs.
     */
    public float getPriority() { return 0f; }

    /**
     * This should return the list of extensions implemented
     * by this BridgeExtension.
     * @return An iterator containing strings one for each implemented
     *         extension.
     */
    public Iterator getImplementedExtensions() {
        return Collections.EMPTY_LIST.iterator();
    }

    /**
     * This should return the individual or company name responsible
     * for the this implementation of the extension.
     */
    public String getAuthor() {
        return "The Apache Batik Team.";
    }

    /**
     * This should contain a contact address (usually an e-mail address).
     */
    public String getContactAddress() {
        return "batik-dev@xmlgraphics.apache.org";
    }

    /**
     * This should return a URL where information can be obtained on
     * this extension.
     */
    public String getURL() {
        return "http://xml.apache.org/batik";
    }

    /**
     * Human readable description of the extension.
     * Perhaps that should be a resource for internationalization?
     * (although I suppose it could be done internally)
     */
    public String getDescription() {
        return "The required SVG 1.0 tags";
    }

    /**
     * This method should update the BridgeContext with support
     * for the tags in this extension.  In some rare cases it may
     * be necessary to replace existing tag handlers, although this
     * is discouraged.
     *
     * @param ctx The BridgeContext instance to be updated
     */
    public void registerTags(BridgeContext ctx) {
        // bridges to handle elements in the SVG namespace

        ctx.putBridge(new SVGAElementBridge());
        ctx.putBridge(new SVGAltGlyphElementBridge());
        ctx.putBridge(new SVGCircleElementBridge());
        ctx.putBridge(new SVGClipPathElementBridge());
        ctx.putBridge(new SVGColorProfileElementBridge());
        ctx.putBridge(new SVGDescElementBridge());
        ctx.putBridge(new SVGEllipseElementBridge());
        ctx.putBridge(new SVGFeBlendElementBridge());
        ctx.putBridge(new SVGFeColorMatrixElementBridge());
        ctx.putBridge(new SVGFeComponentTransferElementBridge());
        ctx.putBridge(new SVGFeCompositeElementBridge());
        ctx.putBridge(new SVGFeComponentTransferElementBridge.SVGFeFuncAElementBridge());
        ctx.putBridge(new SVGFeComponentTransferElementBridge.SVGFeFuncRElementBridge());
        ctx.putBridge(new SVGFeComponentTransferElementBridge.SVGFeFuncGElementBridge());
        ctx.putBridge(new SVGFeComponentTransferElementBridge.SVGFeFuncBElementBridge());
        ctx.putBridge(new SVGFeConvolveMatrixElementBridge());
        ctx.putBridge(new SVGFeDiffuseLightingElementBridge());
        ctx.putBridge(new SVGFeDisplacementMapElementBridge());
        ctx.putBridge(new AbstractSVGLightingElementBridge.SVGFeDistantLightElementBridge());
        ctx.putBridge(new SVGFeFloodElementBridge());
        ctx.putBridge(new SVGFeGaussianBlurElementBridge());
        ctx.putBridge(new SVGFeImageElementBridge());
        ctx.putBridge(new SVGFeMergeElementBridge());
        ctx.putBridge(new SVGFeMergeElementBridge.SVGFeMergeNodeElementBridge());
        ctx.putBridge(new SVGFeMorphologyElementBridge());
        ctx.putBridge(new SVGFeOffsetElementBridge());
        ctx.putBridge(new AbstractSVGLightingElementBridge.SVGFePointLightElementBridge());
        ctx.putBridge(new SVGFeSpecularLightingElementBridge());
        ctx.putBridge(new AbstractSVGLightingElementBridge.SVGFeSpotLightElementBridge());
        ctx.putBridge(new SVGFeTileElementBridge());
        ctx.putBridge(new SVGFeTurbulenceElementBridge());
        ctx.putBridge(new SVGFontElementBridge());
        ctx.putBridge(new SVGFontFaceElementBridge());
        ctx.putBridge(new SVGFilterElementBridge());
        ctx.putBridge(new SVGGElementBridge());
        ctx.putBridge(new SVGGlyphElementBridge());
        ctx.putBridge(new SVGHKernElementBridge());
        ctx.putBridge(new SVGImageElementBridge());
        ctx.putBridge(new SVGLineElementBridge());
        ctx.putBridge(new SVGLinearGradientElementBridge());
        ctx.putBridge(new SVGMarkerElementBridge());
        ctx.putBridge(new SVGMaskElementBridge());
        ctx.putBridge(new SVGMissingGlyphElementBridge());
        ctx.putBridge(new SVGPathElementBridge());
        ctx.putBridge(new SVGPatternElementBridge());
        ctx.putBridge(new SVGPolylineElementBridge());
        ctx.putBridge(new SVGPolygonElementBridge());
        ctx.putBridge(new SVGRadialGradientElementBridge());
        ctx.putBridge(new SVGRectElementBridge());
        ctx.putBridge(new AbstractSVGGradientElementBridge.SVGStopElementBridge());
        ctx.putBridge(new SVGSVGElementBridge());
        ctx.putBridge(new SVGSwitchElementBridge());
        ctx.putBridge(new SVGTextElementBridge());
        ctx.putBridge(new SVGTextPathElementBridge());
        ctx.putBridge(new SVGTitleElementBridge());
        ctx.putBridge(new SVGUseElementBridge());
        ctx.putBridge(new SVGVKernElementBridge());
        ctx.putBridge(new SVGSetElementBridge());
        ctx.putBridge(new SVGAnimateElementBridge());
        ctx.putBridge(new SVGAnimateColorElementBridge());
        ctx.putBridge(new SVGAnimateTransformElementBridge());
        ctx.putBridge(new SVGAnimateMotionElementBridge());
    }

    /**
     * Whether the presence of the specified element should cause
     * the document to be dynamic.  If this element isn't handled
     * by this BridgeExtension, just return false.
     *
     * @param e The element to check.
     */
    public boolean isDynamicElement(Element e) {
        String ns = e.getNamespaceURI();
        if (!SVGConstants.SVG_NAMESPACE_URI.equals(ns)) {
            return false;
        }
        String ln = e.getLocalName();
        if (ln.equals(SVGConstants.SVG_SCRIPT_TAG)
                || ln.startsWith("animate")
                || ln.equals(SVGConstants.SVG_SET_TAG)) {
            return true;
        }
        return false;
    }
}
