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

import java.awt.Dimension;
import java.awt.Font;
import java.io.StringWriter;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;

import org.apache.flex.forks.batik.dom.GenericDOMImplementation;
import org.apache.flex.forks.batik.svggen.SVGGeneratorContext.GraphicContextDefaults;
import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.TestReport;
import org.apache.flex.forks.batik.util.SVGConstants;

/**
 * This test validates that the SVGGraphics2D generates the same result 
 * with the two versions of its getRoot method.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: GetRootTest.java,v 1.4 2004/08/18 07:16:44 vhardy Exp $
 */
public class GetRootTest extends AbstractTest implements SVGConstants {
    public static final Dimension CANVAS_SIZE
        = new Dimension(300, 400);

    public static final String ERROR_DIFFERENT_SVG_OUTPUT
        = "GetRootTest.error.different.svg.output";

    public static final String ENTRY_KEY_NO_ARG_OUTPUT 
        = "GetRootTest.entry.key.no.arg.output";

    public static final String ENTRY_KEY_SVG_ARG_OUTPUT
        = "GetRootTest.entry.key.svg.arg.output";

    public TestReport runImpl() throws Exception {
        // First, use the no-argument getRoot

        DOMImplementation impl = GenericDOMImplementation.getDOMImplementation();
        String namespaceURI = SVGConstants.SVG_NAMESPACE_URI;
        Document domFactory = impl.createDocument(namespaceURI, SVG_SVG_TAG, null);
        SVGGeneratorContext ctx = SVGGeneratorContext.createDefault(domFactory);
        GraphicContextDefaults defaults 
            = new GraphicContextDefaults();
        defaults.font = new Font("Arial", Font.PLAIN, 12);
        ctx.setGraphicContextDefaults(defaults);
        SVGGraphics2D g2d = new SVGGraphics2D(ctx, false);

        g2d.setSVGCanvasSize(CANVAS_SIZE);

        Painter painter = new BasicShapes();
        painter.paint(g2d);

        StringWriter swA = new StringWriter();
        g2d.stream(g2d.getRoot(), swA);

        // Now, use the getRoot with argument
        domFactory = impl.createDocument(namespaceURI, SVG_SVG_TAG, null);
        ctx = SVGGeneratorContext.createDefault(domFactory);
        ctx.setGraphicContextDefaults(defaults);
        g2d = new SVGGraphics2D(ctx, false);

        g2d.setSVGCanvasSize(CANVAS_SIZE);

        painter.paint(g2d);

        StringWriter swB = new StringWriter();
        g2d.stream(g2d.getRoot(domFactory.getDocumentElement()),
                   swB);

        // Compare the two output: they should be identical
        if (swA.toString().equals(swB.toString())) {
            return reportSuccess();
        } else {
            TestReport report = reportError(ERROR_DIFFERENT_SVG_OUTPUT);
            report.addDescriptionEntry(ENTRY_KEY_NO_ARG_OUTPUT,
                                       swA.toString());
            report.addDescriptionEntry(ENTRY_KEY_SVG_ARG_OUTPUT,
                                       swB.toString());
            return report;
        }
    }
}
