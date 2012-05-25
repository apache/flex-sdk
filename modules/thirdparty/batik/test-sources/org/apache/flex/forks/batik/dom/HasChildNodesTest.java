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
 * This class tests the hasChildNodes method.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: HasChildNodesTest.java,v 1.3 2004/08/18 07:16:39 vhardy Exp $
 */
public class HasChildNodesTest extends AbstractTest {
    public static String ERROR_GET_ELEMENT_BY_ID_FAILED 
        = "error.get.element.by.id.failed";

    public static String ENTRY_KEY_ID 
        = "entry.key.id";

    protected String testFileName;
    protected String rootTag;
    protected String targetId;

    public HasChildNodesTest(String file,
                             String root,
                             String id) {
        testFileName = file;
        rootTag = root;
        targetId = id;
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

        
        Element e = doc.getElementById(targetId);

        if (e == null){
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode(ERROR_GET_ELEMENT_BY_ID_FAILED);
            report.addDescriptionEntry(ENTRY_KEY_ID,
                                       targetId);
            report.setPassed(false);
            return report;
        }
           
        while (e.hasChildNodes()) {
            e.removeChild(e.getFirstChild());
        }

        return reportSuccess();
    }
}
