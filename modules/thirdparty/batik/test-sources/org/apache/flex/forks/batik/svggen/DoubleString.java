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
package org.apache.flex.forks.batik.svggen;

import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.TestReport;

import org.apache.flex.forks.batik.dom.GenericDOMImplementation;

import org.w3c.dom.Document;
import org.w3c.dom.DOMImplementation;

/**
 * Checks that no NullPointerException is thrown by default
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: DoubleString.java,v 1.3 2004/08/18 07:16:44 vhardy Exp $
 */
public class DoubleString extends AbstractTest {
    public TestReport runImpl() throws Exception {
        // Get a DOMImplementation
        DOMImplementation domImpl =
            GenericDOMImplementation.getDOMImplementation();
        
        // Create an instance of org.w3c.dom.Document
        Document document = domImpl.createDocument(null, "svg", null);
        
        SVGGraphics2D g = new SVGGraphics2D(document);
        Rectangle2D r = new Rectangle2D.Float(0.5f, 0.5f, 2.33f, 2.33f);
        g.fill(r);

        return reportSuccess();
    }
}
