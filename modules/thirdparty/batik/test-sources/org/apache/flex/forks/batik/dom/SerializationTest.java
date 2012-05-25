/*

   Copyright 2001  The Apache Software Foundation 

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
 * To test the Java serialization.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SerializationTest.java,v 1.3 2004/08/18 07:16:40 vhardy Exp $
 */
public class SerializationTest extends AbstractTest {
    
    protected String testFileName;
    protected String rootTag;
    protected String parserClassName = XMLResourceDescriptor.getXMLParserClassName();

    public SerializationTest(String file,
                             String root) {
        testFileName = file;
        rootTag = root;
    }

    public TestReport runImpl() throws Exception {
        DocumentFactory df 
            = new SAXDocumentFactory(GenericDOMImplementation.getDOMImplementation(), 
                                     parserClassName);
        
        File f = (new File(testFileName));
        URL url = f.toURL();
        Document doc = df.createDocument(null,
                                         rootTag,
                                         url.toString(),
                                         url.openStream());

        File ser1 = File.createTempFile("doc1", "ser");
        File ser2 = File.createTempFile("doc2", "ser");

        try {
            // Serialization 1
            ObjectOutputStream oos;
            oos = new ObjectOutputStream(new FileOutputStream(ser1));
            oos.writeObject(doc);
            oos.close();

            // Deserialization 1
            ObjectInputStream ois;
            ois = new ObjectInputStream(new FileInputStream(ser1));
            doc = (Document)ois.readObject();
            ois.close();
        
            // Serialization 2
            oos = new ObjectOutputStream(new FileOutputStream(ser2));
            oos.writeObject(doc);
            oos.close();
        } catch (IOException e) {
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode("io.error");
            report.addDescriptionEntry("message",
                                       e.getClass().getName() +
                                       ": " + e.getMessage());
            report.addDescriptionEntry("file.name", testFileName);
            report.setPassed(false);
            return report;
        }
        
        // Binary diff
        InputStream is1 = new FileInputStream(ser1);
        InputStream is2 = new FileInputStream(ser2);

        for (;;) {
            int i1 = is1.read();
            int i2 = is2.read();
            if (i1 == -1 && i2 == -1) {
                return reportSuccess();
            }
            if (i1 != i2) {
                DefaultTestReport report = new DefaultTestReport(this);
                report.setErrorCode("difference.found");
                report.addDescriptionEntry("file.name", testFileName);
                report.setPassed(false);
                return report;
            }
        }
    }
}
