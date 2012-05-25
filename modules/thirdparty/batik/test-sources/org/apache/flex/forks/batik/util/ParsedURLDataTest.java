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
package org.apache.flex.forks.batik.util;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;

import java.io.StringWriter;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.IOException;
/**
 * This test validates that the ParsedURL class properly parses and
 * cascades URLs.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: ParsedURLDataTest.java,v 1.4 2004/08/18 07:17:15 vhardy Exp $
 */
public class ParsedURLDataTest extends AbstractTest {
    /**
     * Error when unable to parse URL
     * {0} = 'Base URL' or NULL
     * {1} = Sub URL
     * {2} = exception stack trace.
     */
    public static final String ERROR_CANNOT_PARSE_URL
        = "ParsedURLTest.error.cannot.parse.url";

    /**
     * Result didn't match expected result.
     * {0} = result
     * {1} = expected result
     */
    public static final String ERROR_WRONG_RESULT
        = "ParsedURLTest.error.wrong.result";

    public static final String ENTRY_KEY_ERROR_DESCRIPTION
        = "ParsedURLTest.entry.key.error.description";

    protected String base = null;
    protected String ref  = null;
    /**
     * Constructor
     * @param url The url to parse
     * @param ref The expected result.
     */
    public ParsedURLDataTest(String url, String ref ){
        this.base = url;
        this.ref  = ref;
    }

    /**
     * Returns this Test's name
     */
    public String getName() {
        return ref + " -- " + super.getName();
    }

    /**
     * This method will only throw exceptions if some aspect
     * of the test's internal operation fails.
     */
    public TestReport runImpl() throws Exception {
        DefaultTestReport report
            = new DefaultTestReport(this);

        ParsedURL purl;
        try {
            purl  = new ParsedURL(base);
        } catch(Exception e) {
            StringWriter trace = new StringWriter();
            e.printStackTrace(new PrintWriter(trace));
            report.setErrorCode(ERROR_CANNOT_PARSE_URL);
            report.setDescription(new TestReport.Entry[] {
                new TestReport.Entry
                    (TestMessages.formatMessage
                     (ENTRY_KEY_ERROR_DESCRIPTION, null),
                     TestMessages.formatMessage
                     (ERROR_CANNOT_PARSE_URL,
                      new String[]{"null", 
                                   base,
                                   trace.toString()}))
                    });
            report.setPassed(false);
            return report;
        }

        byte[] data = new byte[5];
        int num = 0;
        try {
            InputStream is = purl.openStream();
            num = is.read(data);
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
        StringBuffer sb = new StringBuffer();
        for (int i=0; i<num; i++) {
            int val = ((int)data[i])&0xFF;
            if (val < 16) {
                sb.append("0");
            }
            sb.append(Integer.toHexString(val) + " ");
        }
        
        String info = ( "CT: " + purl.getContentType() + 
                       " CE: " + purl.getContentEncoding() + 
                       " DATA: " + sb +
                       "URL: " + purl);

        if (ref.equals(info)) {
            report.setPassed(true);
            return report;
        }

        report.setErrorCode(ERROR_WRONG_RESULT);
        report.setDescription(new TestReport.Entry[] {
          new TestReport.Entry
            (TestMessages.formatMessage(ENTRY_KEY_ERROR_DESCRIPTION, null),
             TestMessages.formatMessage
             (ERROR_WRONG_RESULT, new String[]{info, ref }))
            });
        report.setPassed(false);
        return report;
    }
}
