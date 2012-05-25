/*

   Copyright 2002  The Apache Software Foundation 

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

import org.w3c.dom.*;

import java.io.*;
import java.net.*;
import org.apache.flex.forks.batik.dom.util.*;
import org.apache.flex.forks.batik.util.*;
import org.apache.flex.forks.batik.test.*;

/**
 * This class tests the getElementsByTagNameNS method.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GetElementsByTagNameNSTest.java,v 1.3 2004/08/18 07:16:39 vhardy Exp $
 */
public class GetElementsByTagNameNSTest extends AbstractTest {
    protected String testFileName;
    protected String rootTag;
    protected String tagName;

    public GetElementsByTagNameNSTest(String file,
                                      String root,
                                      String tag) {
        testFileName = file;
        rootTag = root;
        tagName = tag;
    }

    public TestReport runImpl() throws Exception {
        String parser =
            XMLResourceDescriptor.getXMLParserClassName();

        DocumentFactory df 
            = new SAXDocumentFactory
            (GenericDOMImplementation.getDOMImplementation(), parser);

        File f = (new File(testFileName));
        URL url = f.toURL();
        Document doc = df.createDocument(null,
                                         rootTag,
                                         url.toString(),
                                         url.openStream());
        
        Element root = doc.getDocumentElement();
        NodeList lst = root.getElementsByTagNameNS(null, tagName);

        if (lst.getLength() != 1) {
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode("error.getElementByTagNameNS.failed");
            report.setPassed(false);
            return report;
        }
        
        Node n;
        while ((n = root.getFirstChild()) != null) {
            root.removeChild(n);
        }

        if (lst.getLength() != 0) {
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode("error.getElementByTagNameNS.failed");
            report.setPassed(false);
            return report;
        }

        return reportSuccess();
    }
    
}
