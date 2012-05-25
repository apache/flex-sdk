/*

   Copyright 2002-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.svggen;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Shape;
import java.awt.geom.Ellipse2D;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Element;
import org.w3c.flex.forks.dom.svg.SVGDocument;

import org.apache.flex.forks.batik.bridge.BaseScriptingEnvironment;
import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.GVTBuilder;
import org.apache.flex.forks.batik.bridge.UserAgentAdapter;
import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;
import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.TestReport;

/**
 * Checks that the content generated from the SVGGraphics2D and to which
 * an event handler has been added can be processed by Batik.
 *
 * @author <a mailto="vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: ShowGraphics2DOutput.java,v 1.4 2004/08/18 07:16:45 vhardy Exp $
 */
public class ShowGraphics2DOutput extends AbstractTest {
    public TestReport runImpl() throws Exception {

        DOMImplementation impl = SVGDOMImplementation.getDOMImplementation();
        String svgNS = SVGDOMImplementation.SVG_NAMESPACE_URI;
        SVGDocument doc = (SVGDocument)impl.createDocument(svgNS, "svg", null);
        
        SVGGraphics2D g = new SVGGraphics2D(doc);

        Shape circle = new Ellipse2D.Double(0,0,50,50);
        g.setPaint(Color.red);
        g.fill(circle);
        g.translate(60,0);
        g.setPaint(Color.green);
        g.fill(circle);
        g.translate(60,0);
        g.setPaint(Color.blue);
        g.fill(circle);
        g.setSVGCanvasSize(new Dimension(180,50));

        Element root = doc.getDocumentElement();

        // The following populates the document root with the 
        // generated SVG content.
        g.getRoot(root);

        root.setAttribute("onload", "System.out.println('hello')");

        // Now that the SVG file has been loaded, build
        // a GVT Tree from it
        TestUserAgent userAgent = new TestUserAgent();
        GVTBuilder builder = new GVTBuilder();
        BridgeContext ctx = new BridgeContext(userAgent);
        ctx.setDynamic(true);

        builder.build(ctx, doc);
        BaseScriptingEnvironment scriptEnvironment 
            = new BaseScriptingEnvironment(ctx);
        scriptEnvironment.loadScripts();
        scriptEnvironment.dispatchSVGLoadEvent();

        if (!userAgent.failed) {
            return reportSuccess();
        } else {
            return reportError("Got exception while processing document");
        }
    }

    class TestUserAgent extends UserAgentAdapter {
        boolean failed;

        public void displayError(Exception e) {
            failed = true;
        } 
    }
}
