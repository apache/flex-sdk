/*

   Copyright 2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.swing;

import org.apache.flex.forks.batik.test.svg.JSVGRenderingAccuracyTest;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.dom.GenericDOMImplementation;

import org.w3c.dom.Document;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Element;

/**
 * Test setDocument on JSVGComponent with non-Batik SVGOMDocument.
 *
 * This test constructs a generic Document with SVG content then it
 * ensures that when this is passed to JSVGComponet.setDocument it is
 * properly imported to an SVGOMDocument and rendered from there.
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: SetSVGDocumentTest.java,v 1.5 2005/03/27 08:58:37 cam Exp $
 */
public class SetSVGDocumentTest extends JSVGRenderingAccuracyTest {
    public SetSVGDocumentTest() {
    }
    protected String[] breakSVGFile(String svgFile){
        if(svgFile == null) {
            throw new IllegalArgumentException(svgFile);
        }

        String [] ret = new String[3];
        ret[0] = "test-resources/org/apache/batik/test/svg/";
        ret[1] = "SetSVGDocumentTest";
        ret[2] = ".svg";
        return ret;
    }

    /* JSVGCanvasHandler.Delegate Interface */
    public boolean canvasInit(JSVGCanvas canvas) {
        DOMImplementation impl = 
            GenericDOMImplementation.getDOMImplementation();
        Document doc = impl.createDocument(SVGConstants.SVG_NAMESPACE_URI, 
                                           SVGConstants.SVG_SVG_TAG, null);
        Element e = doc.createElementNS(SVGConstants.SVG_NAMESPACE_URI, 
                                        SVGConstants.SVG_RECT_TAG);
        e.setAttribute("x", "10");
        e.setAttribute("y", "10");
        e.setAttribute("width", "100");
        e.setAttribute("height", "50");
        e.setAttribute("fill", "crimson");
        doc.getDocumentElement().appendChild(e);

        e = doc.createElementNS(SVGConstants.SVG_NAMESPACE_URI, 
                                SVGConstants.SVG_CIRCLE_TAG);
        e.setAttribute("cx", "55");
        e.setAttribute("cy", "35");
        e.setAttribute("r", "30");
        e.setAttribute("fill", "gold");
        doc.getDocumentElement().appendChild(e);
        
        canvas.setDocument(doc);
        return false; // We didn't trigger a load event.
    }

    public boolean canvasUpdated(JSVGCanvas canvas) {
        return true;
    }
}
