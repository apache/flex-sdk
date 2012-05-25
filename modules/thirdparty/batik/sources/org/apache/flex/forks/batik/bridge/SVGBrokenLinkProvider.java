/*

   Copyright 2001-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.bridge;

import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.spi.DefaultBrokenLinkProvider;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.filter.GraphicsNodeRable8Bit;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.flex.forks.dom.svg.SVGDocument;
/**
 * This interface is to be used to provide alternate ways of 
 * generating a placeholder image when the ImageTagRegistry
 * fails to handle a given reference.
 */
public class SVGBrokenLinkProvider 
    extends    DefaultBrokenLinkProvider 
    implements ErrorConstants {

    public final static String SVG_BROKEN_LINK_DOCUMENT_PROPERTY = 
        "org.apache.flex.forks.batik.bridge.BrokenLinkDocument";

    UserAgent      userAgent;
    DocumentLoader loader;
    BridgeContext  ctx;
    GraphicsNode   gvtRoot = null;
    SVGDocument       svgDoc;
    
    public SVGBrokenLinkProvider() {
        userAgent = new UserAgentAdapter();
        loader    = new DocumentLoader(userAgent);
        ctx       = new BridgeContext(userAgent, loader);

        Class cls = SVGBrokenLinkProvider.class;
        URL blURL = cls.getResource("BrokenLink.svg");
        if (blURL == null) return;

        GVTBuilder builder = new GVTBuilder();
        try {
            svgDoc  = (SVGDocument)loader.loadDocument(blURL.toString());
            gvtRoot = builder.build(ctx, svgDoc);
        } catch (Exception ex) {
            // t.printStackTrace();
        }
    }

    /**
     * This method is responsible for constructing an image that will
     * represent the missing image in the document.  This method
     * recives information about the reason a broken link image is
     * being requested in the <tt>code</tt> and <tt>params</tt>
     * parameters. These parameters may be used to generate nicely
     * localized messages for insertion into the broken link image, or
     * for selecting the broken link image returned.
     *
     * @param code This is the reason the image is unavailable should
     *             be taken from ErrorConstants.
     * @param params This is more detailed information about
     *        the circumstances of the failure.  */
    public Filter getBrokenLinkImage(Object base, String code, 
                                     Object[] params) {
        if (gvtRoot == null) 
            return null;

        String message = formatMessage(base, code, params);
        Document doc = getBrokenLinkDocument(message);
        Map props = new HashMap();
        props.put(BROKEN_LINK_PROPERTY, message);
        props.put(SVG_BROKEN_LINK_DOCUMENT_PROPERTY, doc);
        
        return new GraphicsNodeRable8Bit(gvtRoot, props);
    }

    public SVGDocument getBrokenLinkDocument(Object base, 
                                          String code, Object [] params) {
        String message = formatMessage(base, code, params);
        return getBrokenLinkDocument(message);
    }

    public SVGDocument getBrokenLinkDocument(String message) {
        SVGDocument doc = (SVGDocument)DOMUtilities.deepCloneDocument
            (svgDoc, svgDoc.getImplementation());
        Element infoE = doc.getElementById("__More_About");
        Element title = doc.createElementNS(SVGConstants.SVG_NAMESPACE_URI,
                                            SVGConstants.SVG_TITLE_TAG);
        title.appendChild(doc.createTextNode
                          (Messages.formatMessage
                           (MSG_BROKEN_LINK_TITLE, null)));
        Element desc = doc.createElementNS(SVGConstants.SVG_NAMESPACE_URI,
                                           SVGConstants.SVG_DESC_TAG);
        desc.appendChild(doc.createTextNode(message));
        infoE.insertBefore(desc, infoE.getFirstChild());
        infoE.insertBefore(title, desc);
        return doc;
    }
}
