/*
 * Copyright 1999-2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.flex.forks.batik.dom;

import org.w3c.dom.*;

import java.io.*;
import java.net.*;
import org.apache.flex.forks.batik.dom.util.*;
import org.apache.flex.forks.batik.util.*;

import org.apache.flex.forks.batik.test.*;

/**
 * @author <a href="mailto:shillion@ilog.fr">Stephane Hillion</a>
 * @version $Id: SetAttributeTest.java,v 1.5 2005/04/01 02:28:16 deweese Exp $
 */
public class SetAttributeTest extends AbstractTest {
    protected String testFileName;
    protected String rootTag;
    protected String targetId;
    protected String targetAttribute;
    protected String targetValue;

    protected String parserClassName = XMLResourceDescriptor.getXMLParserClassName();

    public static String ERROR_GET_ELEMENT_BY_ID_FAILED 
        = "error.get.element.by.id.failed";

    public static String ENTRY_KEY_ID 
        = "entry.key.id";

    public SetAttributeTest(String testFileName,
                            String rootTag,
                            String targetId,
                            String targetAttribute,
                            String targetValue){
        this.testFileName = testFileName;
        this.rootTag = rootTag;
        this.targetId = targetId;
        this.targetAttribute = targetAttribute;
        this.targetValue = targetValue;
    }

    public String getParserClassName(){
        return parserClassName;
    }

    public void setParserClassName(String parserClassName){
        this.parserClassName = parserClassName;
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

        
        Element e = doc.getElementById(targetId);

        if(e == null){
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode(ERROR_GET_ELEMENT_BY_ID_FAILED);
            report.addDescriptionEntry(ENTRY_KEY_ID,
                                       targetId);
            report.setPassed(false);
            return report;
        }
            
            
        e.setAttribute(targetAttribute, targetValue);
        if(targetValue.equals(e.getAttribute(targetAttribute))){
            return reportSuccess();
        }
        DefaultTestReport report = new DefaultTestReport(this);
        report.setErrorCode(TestReport.ERROR_TEST_FAILED);
        report.setPassed(false);
        return report;
    }
}

