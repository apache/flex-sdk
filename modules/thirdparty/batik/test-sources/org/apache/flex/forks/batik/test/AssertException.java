/*

   Copyright 2001-2003  The Apache Software Foundation 

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

/**
 * Exception which Tests can throw when a specific assertion fails.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: AssertException.java,v 1.5 2004/08/18 07:16:56 vhardy Exp $
 */
public abstract class AssertException extends TestErrorConditionException {
    public static final String ENTRY_KEY_ASSERTION_TYPE 
        = "AssertException.entry.key.assertion.type";

    /**
     * <tt>TestErrorConditionException</tt> implementation.
     */
    public TestReport getTestReport(Test test){
        DefaultTestReport report = new DefaultTestReport(test);
        report.setErrorCode(TestReport.ERROR_ASSERTION_FAILED);
        report.addDescriptionEntry(ENTRY_KEY_ASSERTION_TYPE,
                                   getAssertionType());
        addDescription(report);
        addStackTraceDescription(report);  
        report.setPassed(false);
        return report;
    }

    /**
     * Requests that the exception populates the TestReport with the
     * relevant information.
     */
    public abstract void addDescription(TestReport report);

    /**
     * Returns the type of assertion which failed. e.g., "assertEquals"
     */
    public abstract String getAssertionType();
}
