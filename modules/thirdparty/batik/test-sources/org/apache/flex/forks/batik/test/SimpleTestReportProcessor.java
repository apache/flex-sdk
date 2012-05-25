/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.test;

import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * A simple implementation of the <tt>TestReportProcessor</tt> interface
 * that prints out the <tt>TestReport</tt> to the standard output.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SimpleTestReportProcessor.java,v 1.4 2004/08/18 07:16:57 vhardy Exp $
 */
public class SimpleTestReportProcessor implements TestReportProcessor {
    /**
     * Message keys
     */
    public static final String MESSAGES_TEST_SUITE_STATUS_TEST_PASSED
        = "SimpleTestReportProcessor.messages.test.suite.status.testPassed";

    public static final String MESSAGES_TEST_SUITE_STATUS_TEST_FAILED
        = "SimpleTestReportProcessor.messages.test.suite.status.testFailed";

    public static final String MESSAGES_TEST_SUITE_STATUS
        = "SimpleTestReportProcessor.messages.test.suite.status";

    public static final String MESSAGES_TEST_SUITE_ERROR_CODE
        = "SimpleTestReportProcessor.messages.test.suite.error.code";

    /**
     * Default output writer
     */
    private PrintWriter printWriter;

    /**
     * Sets the <tt>PrintWriter</tt> this processor should use
     */
    public void setPrintWriter(PrintWriter printWriter){
        this.printWriter = printWriter;
    }

    /**
     * Recursively prints out the entries of the input 
     * report and its children reports, if any.
     */
    public void processReport(TestReport report)
        throws TestException{
        try{
            PrintWriter out = printWriter;
            if(printWriter == null){
                out = new PrintWriter(new OutputStreamWriter(System.out));
            }
            processReport(report, "", out);
            out.flush();
        }catch(Exception e){
            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            throw new TestException(INTERNAL_ERROR,
                                    new Object[] { e.getClass().getName(),
                                                   e.getMessage(),
                                                   sw.toString() },
                                    e);
        }
    }

    /**
     * Prints out the input report, prefixing all output
     * with the input string
     */
    public void processReport(TestReport report, String prefix, PrintWriter out){
        String status = report.hasPassed() 
            ? Messages.formatMessage(MESSAGES_TEST_SUITE_STATUS_TEST_PASSED, null)
            : Messages.formatMessage(MESSAGES_TEST_SUITE_STATUS_TEST_FAILED, null);

        out.println(Messages.formatMessage(MESSAGES_TEST_SUITE_STATUS,
                                                  new Object[]{ report.getTest().getName(),
                                                                status }));

        if(!report.hasPassed()){
            out.println(Messages.formatMessage(MESSAGES_TEST_SUITE_ERROR_CODE, 
                                                      new Object[]{report.getErrorCode()}));
        }
        
        TestReport.Entry[] entries = report.getDescription();
        int n = entries != null ? entries.length : 0;
        for(int i=0; i<n; i++){
            out.print(prefix + entries[i].getKey() + " : " );
            printValue(entries[i].getValue(), prefix + "    ", out);
        }
    }

    /**
     * Prints out the input value depending on its
     * type.
     */
    protected void printValue(Object value, String prefix, PrintWriter out){
        if(!(value instanceof TestReport)){
            out.println(value);
        }
        else{
            out.println();
            processReport((TestReport)value, prefix, out);
        }
    }
}


