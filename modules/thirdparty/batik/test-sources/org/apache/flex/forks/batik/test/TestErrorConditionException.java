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

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * Exception which <tt>AbstractTest</tt> extensions can throw from the 
 * <tt>rumImpl</tt> method to report an error condition.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: TestErrorConditionException.java,v 1.4 2004/08/18 07:16:58 vhardy Exp $
 */
public class TestErrorConditionException extends Exception {
    /**
     * Error code. May be null.
     */
    protected String errorCode;

    /**
     * Default constructor
     */
    protected TestErrorConditionException(){
    }

    /**
     * @param errorCode describes the error condition
     */
    public TestErrorConditionException(String errorCode){
        this.errorCode = errorCode;
    }

    /**
     * Requests a report which describes the exception.
     */
    public TestReport getTestReport(Test test){
        DefaultTestReport report = new DefaultTestReport(test);
        if(errorCode != null){
            report.setErrorCode(errorCode);
        } else {
            report.setErrorCode(TestReport.ERROR_TEST_FAILED);
        }

        report.setPassed(false);
        addStackTraceDescription(report);
        return report;
    }

    /**
     * Convenience method: adds a description entry for the stack
     * trace.
     */
    public void addStackTraceDescription(TestReport report){
        StringWriter trace = new StringWriter();
        printStackTrace(new PrintWriter(trace));
        
        report.addDescriptionEntry
          (TestReport.ENTRY_KEY_ERROR_CONDITION_STACK_TRACE,
           trace.toString());
    }
}
