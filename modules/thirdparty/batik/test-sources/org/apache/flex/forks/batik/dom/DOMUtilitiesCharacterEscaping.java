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
package org.apache.flex.forks.batik.dom;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.TestReport;

import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;

import org.apache.flex.forks.batik.dom.svg.SAXSVGDocumentFactory;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;

import org.apache.flex.forks.batik.util.XMLResourceDescriptor;

import org.w3c.dom.*;

import java.io.*;

/**
 * Checks that Text nodes can be properly written and read.
 * This test creates a Document with a CDATA section and checks
 * that the CDATA section content can be written out and then read
 * without being altered.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 */
public class DOMUtilitiesCharacterEscaping extends AbstractTest {
    public TestReport runImpl() throws Exception {
        DOMImplementation impl = new SVGDOMImplementation();
        Document doc = impl.createDocument(SVGConstants.SVG_NAMESPACE_URI,
                                           "svg", null);

        Element svg = doc.getDocumentElement();
        Element text = doc.createElementNS(SVGConstants.SVG_NAMESPACE_URI,
                                           "text");
        svg.appendChild(text);

        text.setAttributeNS(null, "id", "myText");
        String unescapedContent = "You should not escape: & # \" ...";
        CDATASection cdata = doc.createCDATASection(unescapedContent);

        text.appendChild(cdata);

        Writer stringWriter = new StringWriter();

        DOMUtilities.writeDocument(doc, stringWriter);
        
        String docString = stringWriter.toString();
        System.err.println(">>>>>>>>>>> Document content \n\n" + docString + "\n\n<<<<<<<<<<<<<<<<");

        String parser = XMLResourceDescriptor.getXMLParserClassName();
        SAXSVGDocumentFactory f = new SAXSVGDocumentFactory(parser);
        doc = f.createDocument("http://xml.apache.org/batik/foo.svg", 
                               new StringReader(stringWriter.toString()));

        text = doc.getElementById("myText");
        cdata = (CDATASection)text.getFirstChild();
        if (cdata.getData().equals(unescapedContent)) {
            return reportSuccess();
        } 

        TestReport report = reportError("Unexpected CDATA read-back");
        report.addDescriptionEntry("expected cdata", unescapedContent);
        report.addDescriptionEntry("actual cdata", cdata.getData());
        return report;
    }
}
