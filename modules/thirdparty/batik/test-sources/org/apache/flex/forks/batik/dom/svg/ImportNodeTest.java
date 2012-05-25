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
package org.apache.flex.forks.batik.dom.svg;

import java.io.File;
import java.net.URL;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;
import org.apache.flex.forks.batik.util.XMLResourceDescriptor;

/**
 * This class tests the importNode method.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ImportNodeTest.java,v 1.4 2004/08/18 07:16:41 vhardy Exp $
 */
public class ImportNodeTest extends AbstractTest {
    protected String testFileName;
    protected String targetId;

    public ImportNodeTest(String file, String id) {
        testFileName = file;
        targetId = id;
    }
    
    public TestReport runImpl() throws Exception {
        String parser =
            XMLResourceDescriptor.getXMLParserClassName();

        SAXSVGDocumentFactory df = new SAXSVGDocumentFactory(parser);

        File f = (new File(testFileName));
        URL url = f.toURL();
        Document doc = df.createDocument(url.toString(),
                                         url.openStream());
        
        Element e = doc.getElementById(targetId);

        if (e == null){
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode("error.get.element.by.id.failed");
            report.addDescriptionEntry("entry.key.id", targetId);
            report.setPassed(false);
            return report;
        }

        DOMImplementation di = SVGDOMImplementation.getDOMImplementation();
        Document d = di.createDocument(SVGDOMImplementation.SVG_NAMESPACE_URI,
                                       "svg", null);
        

        Element celt = (Element)d.importNode(e, true);

        NamedNodeMap attrs = e.getAttributes();

        for (int i = 0; i < attrs.getLength(); i++) {
            Node attr = attrs.item(i);
            String ns = attr.getNamespaceURI();
            String name = (ns == null)
                ? attr.getNodeName()
                : attr.getLocalName();
            String val = attr.getNodeValue();
            String val2 = celt.getAttributeNS(ns, name);
            if (!val.equals(val2)) {
                DefaultTestReport report = new DefaultTestReport(this);
                report.setErrorCode("error.attr.comparison.failed");
                report.addDescriptionEntry("entry.attr.name", name);
                report.addDescriptionEntry("entry.attr.value1", val);
                report.addDescriptionEntry("entry.attr.value2", val2);
                report.setPassed(false);
                return report;
            }
        }

        return reportSuccess();
    }
}
