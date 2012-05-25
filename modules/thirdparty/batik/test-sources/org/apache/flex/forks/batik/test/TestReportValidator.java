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
package org.apache.flex.forks.batik.test;

/**
 * This <tt>Test</tt> implementation can be used to validate the 
 * operation of a specific test. A typical use is to create
 * known error conditions and check that the input <tt>Test</tt>
 * reports these errors properly.
 * <p>
 * This test checks that a given test status (passed or not) 
 * and a given error code is returned by a <tt>Test</tt>. 
 * A <tt>TestReportValidator</tt> is built with the <tt>Test</tt> to 
 * run, the expected status (passed or failed) and the expected
 * error code. The <tt>TestReportValidator</tt> will pass if the
 * expected values are produced by the <tt>TestReport</tt> 
 * created by the associated <tt>Test</tt>. Otherwise, it will
 * fail with one of two error codes:<br />
 * + if the status is not the one expected, then the 
 *   ERROR_UNEXPECTED_TEST_STATUS code is used.. The report
 *   description will have two entries: ENTRY_KEY_EXPECTED_STATUS
 *   and ENTRY_KEY_RECEIVED_STATUS, both of which are Strings.
 * + if the status is the one expected, but if the error code 
 *   differs from the expected one, then the
 *   ERROR_UNEXPECTED_ERROR_CODE code is used. The report
 *   description will have two entries: ENTRY_KEY_EXPECTED_ERROR_CODE
 *   and ENTRY_KEY_RECEIVED_ERROR_CODE.
 * 
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: TestReportValidator.java,v 1.4 2004/08/18 07:16:58 vhardy Exp $
 */
public class TestReportValidator extends AbstractTest {
    /**
     * Test that this validator checks
     */
    private Test test;
    
    /**
     * Status expected from the <tt>TestReport</tt>
     */
    private boolean expectedStatus;

    /**
     * Error code expected from the <tt>TestReport</tt>
     */
    private String expectedErrorCode;

    /**
     * Error code used when the test status is
     * is different from the expected status.
     */
    static final String ERROR_UNEXPECTED_TEST_STATUS 
        = "TestReportValidator.error.unexpected.test.status";
    
    /**
     * Error code used when the test error code is
     * different from the expected error code.
     */
    static final String ERROR_UNEXPECTED_ERROR_CODE 
        = "TestReportValidator.error.unexpected.error.code";

    /**
     * The error description entry when the test fails
     */
    public static final String ENTRY_KEY_EXPECTED_ERROR_CODE
        = "TestReportValidator.entry.key.expected.error.code";
    
    /**
     * Entry describing the received error code which is
     * different from the expected one.
     */
    public static final String ENTRY_KEY_RECEIVED_ERROR_CODE
        = "TestReportValidator.entry.key.received.error.code";
    
    /**
     * The entry describing the expected status when the test status
     * is unexpected.
     */
    public static final String ENTRY_KEY_EXPECTED_STATUS
        = "TestReportValidator.entry.key.expected.status";
    
    /**
     * Entry describing the received status which is
     * different from the expected one.
     */
    public static final String ENTRY_KEY_RECEIVED_STATUS
        = "TestReportValidator.entry.key.received.status";
    
    /**
     * Constructor
     * 
     */
    public TestReportValidator(Test test,
                               boolean expectedStatus,
                               String expectedErrorCode){
        setConfig(test, 
                  expectedStatus,
                  expectedErrorCode);
    }

    /**
     * Protected constructor, for use by derived classes
     */
    protected TestReportValidator(){
    }

    /**
     * Lets derived classes set the configuration parameters
     * for this test.
     */
    protected void setConfig(Test test,
                             boolean expectedStatus,
                             String expectedErrorCode){
        this.expectedErrorCode = expectedErrorCode;
        this.test = test;
        this.expectedStatus = expectedStatus;
    }

    public TestReport runImpl() throws Exception {
        TestReport tr = test.run();
        
        //
        // Check test output
        //
        DefaultTestReport r = new DefaultTestReport(this);
        
        if( tr.hasPassed() != expectedStatus ){
            TestReport.Entry expectedStatusEntry 
                = new TestReport.Entry(Messages.formatMessage(ENTRY_KEY_EXPECTED_STATUS, null),
                                       (new Boolean(expectedStatus)).toString());
            TestReport.Entry receivedStatusEntry 
                = new TestReport.Entry(Messages.formatMessage(ENTRY_KEY_RECEIVED_STATUS, null),
                                       (new Boolean(tr.hasPassed())).toString());
            r.setDescription(new TestReport.Entry[]{ expectedStatusEntry, receivedStatusEntry });
            r.setErrorCode(ERROR_UNEXPECTED_TEST_STATUS);
            r.setPassed(false);
        }
        else if( tr.getErrorCode() != expectedErrorCode ){
            TestReport.Entry expectedErrorCodeEntry 
                = new TestReport.Entry(Messages.formatMessage(ENTRY_KEY_EXPECTED_ERROR_CODE, null),
                                       expectedErrorCode);
            TestReport.Entry receivedErrorCodeEntry 
                = new TestReport.Entry(Messages.formatMessage(ENTRY_KEY_RECEIVED_ERROR_CODE, null),
                                       tr.getErrorCode());
            
            r.setDescription(new TestReport.Entry[]{ expectedErrorCodeEntry, receivedErrorCodeEntry });
            r.setErrorCode(ERROR_UNEXPECTED_ERROR_CODE);
            r.setPassed(false);
        }
        
        return r;
    }
}
