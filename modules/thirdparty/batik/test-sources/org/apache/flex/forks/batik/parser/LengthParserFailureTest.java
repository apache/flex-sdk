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
package org.apache.flex.forks.batik.parser;

import java.io.*;

import org.apache.flex.forks.batik.test.*;

/**
 * To test the length parser.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LengthParserFailureTest.java,v 1.3 2004/08/18 07:16:42 vhardy Exp $
 */
public class LengthParserFailureTest extends AbstractTest {

    protected String sourceLength;

    /**
     * Creates a new LengthParserFailureTest.
     * @param slength The length to parse.
     */
    public LengthParserFailureTest(String slength) {
        sourceLength = slength;
    }

    public TestReport runImpl() throws Exception {
        LengthParser pp = new LengthParser();
        try {
            pp.parse(new StringReader(sourceLength));
        } catch (ParseException e) {
            return reportSuccess();
        }
        DefaultTestReport report = new DefaultTestReport(this);
        report.setErrorCode("parse.without.error");
        report.addDescriptionEntry("input.text", sourceLength);
        report.setPassed(false);
        return report;
    }
}
