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

 */package org.apache.flex.forks.batik.test.svg;

import java.util.Vector;

import org.apache.flex.forks.batik.test.TestReport;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestSuite;

/**
 * This test validates the operation of SelfContainedSVGOnLoadTest.
 * It is a test agregation which points to several tests which 
 * correspond to expected error conditions. The test simply 
 * validates that the expected error conditions are properly 
 * detected and reported.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SelfContainedSVGOnLoadTestValidator.java,v 1.4 2004/08/18 07:17:03 vhardy Exp $
 */
public class SelfContainedSVGOnLoadTestValidator extends DefaultTestSuite {
    /**
     * Error codes
     */
    public static final String ERROR_UNEXPECTED_TEST_RESULT =
        "SelfContainedSVGOnLoadTestValidator.error.unexpected.test.result";

    public static final String ERROR_UNEXPECTED_ERROR_CODE =
        "SelfContainedSVGOnLoadTestValidator.error.unexpected.error.code";

    public static final String ERROR_UNEXPECTED_NUMBER_OF_DESCRIPTION_ENTRIES
        = "SelfContainedSVGOnLoadTestValidator.error.unexpected.number.of.description.entries";

    public static final String ERROR_UNEXPECTED_TEST_FAILURE
        = "SelfContainedSVGOnLoadTestValidator.error.unexpected.test.failure";

    public static final String ERROR_UNEXPECTED_DESCRIPTION_ENTRY
        = "SelfContainedSVGOnLoadTestValidator.error.unexpected.description.entry";

    public static final String ENTRY_ERROR_CODE = 
        "SelfContainedSVGOnLoadTestValidator.entry.error.code";

    public static final String ENTRY_EXPECTED_ERROR_CODE = 
        "SelfContainedSVGOnLoadTestValidator.entry.expected.error.code";

    public static final String ENTRY_NUMBER_OF_DESCRIPTION = 
        "SelfContainedSVGOnLoadTestValidator.entry.number.of.description";

    public static final String ENTRY_EXPECTED_NUMBER_OF_DESCRIPTION = 
        "SelfContainedSVGOnLoadTestValidator.entry.expected.number.of.description";

    public static final String ENTRY_KEY = 
        "SelfContainedSVGOnLoadTestValidator.entry.key";

    public static final String ENTRY_EXPECTED_KEY = 
        "SelfContainedSVGOnLoadTestValidator.entry.expected.key";

    
    /**
     * URLs for children tests
     */
    public static final String invalidURL 
        = "invalidURL";
    public static final String processingErrorURL 
        = "test-resources/org/apache/batik/test/svg/processingError.svg";
    public static final String invalidTestResultElementsNumberURL 
        = "test-resources/org/apache/batik/test/svg/invalidTestResultElementsNumber.svg";
    public static final String unexpectedResultValueURL 
        = "test-resources/org/apache/batik/test/svg/unexpectedResultValue.svg";
    public static final String missingOrEmptyErrorCodeURL
        = "test-resources/org/apache/batik/test/svg/missingOrEmptyErrorCode.svg";
    public static final String errorURL 
        = "test-resources/org/apache/batik/test/svg/error.svg";
    public static final String errorAndEntriesURL 
        = "test-resources/org/apache/batik/test/svg/errorAndEntries.svg";
    public static final String successURL 
        = "test-resources/org/apache/batik/test/svg/success.svg";

    
    public SelfContainedSVGOnLoadTestValidator(){
        addTest(new CannotLoadSVGDocument());
        addTest(new ProcessingError());
        addTest(new InvalidTestResultElementsNumber());
        addTest(new UnexpectedResultValue());
        addTest(new MissingOrEmptyErrorCode());
        addTest(new ReportError());
        addTest(new ReportSuccess());
        addTest(new ReportErrorAndEntries());
    }

    static class ReportErrorAndEntries extends DefaultErrorTest {
        public ReportErrorAndEntries() {
            super(errorAndEntriesURL,
                  "can.you.read.this.error.code",
                  new String[] { "can.you.read.this.first.entry",
                                 "can.you.read.this.second.entry" });
        }
    }

    static class ReportError extends DefaultErrorTest {
        public ReportError(){
            super(errorURL,
                   "can.you.read.this.error.code",
                   null);
        }
    }

    static class ReportSuccess extends AbstractTest {
        public TestReport rumImpl() throws Exception {
            SelfContainedSVGOnLoadTest t = new SelfContainedSVGOnLoadTest(successURL);
            TestReport tr = t.run();

            if (!tr.hasPassed()) {
                return reportError(ERROR_UNEXPECTED_TEST_FAILURE);
            }

            return reportSuccess();
        }
    }
    
    static class MissingOrEmptyErrorCode extends DefaultErrorTest {
        public MissingOrEmptyErrorCode(){
            super(missingOrEmptyErrorCodeURL,
                  SelfContainedSVGOnLoadTest.ERROR_MISSING_OR_EMPTY_ERROR_CODE_ON_FAILED_TEST,
                  null);
        }
    }

    static class UnexpectedResultValue extends DefaultErrorTest{
        public UnexpectedResultValue(){
            super(unexpectedResultValueURL,
                  SelfContainedSVGOnLoadTest.ERROR_UNEXPECTED_RESULT_VALUE,
                  new String[]{SelfContainedSVGOnLoadTest.ENTRY_KEY_RESULT_VALUE});
        }
    }


    static class InvalidTestResultElementsNumber extends DefaultErrorTest{
        public InvalidTestResultElementsNumber(){
            super(invalidTestResultElementsNumberURL,
                  SelfContainedSVGOnLoadTest.ERROR_UNEXPECTED_NUMBER_OF_TEST_RESULT_ELEMENTS,
                  new String[]{SelfContainedSVGOnLoadTest.ENTRY_KEY_NUMBER_OF_TEST_RESULT_ELEMENTS});
        }
    }

    static class ProcessingError extends DefaultErrorTest{
        public ProcessingError(){
            super(processingErrorURL,
                  SelfContainedSVGOnLoadTest.ERROR_WHILE_PROCESSING_SVG_DOCUMENT,
                  new String[]{SelfContainedSVGOnLoadTest.ENTRY_KEY_ERROR_DESCRIPTION});
        }
    }

    static class CannotLoadSVGDocument extends DefaultErrorTest {
        public CannotLoadSVGDocument(){
            super(invalidURL,
                  SelfContainedSVGOnLoadTest.ERROR_CANNOT_LOAD_SVG_DOCUMENT,
                  new String[] {SelfContainedSVGOnLoadTest.ENTRY_KEY_ERROR_DESCRIPTION});
        }
    }
    
    static class DefaultErrorTest extends AbstractTest{
        String svgURL;
        String expectedErrorCode;
        String[] expectedEntryCodes;
        
        public DefaultErrorTest(String svgURL,
                                String expectedErrorCode,
                                String[] expectedEntryCodes
                                ){
            this.svgURL = svgURL;
            this.expectedErrorCode = expectedErrorCode;
            this.expectedEntryCodes = expectedEntryCodes;
        }
        
        public TestReport runImpl() throws Exception {
            SelfContainedSVGOnLoadTest t 
                = new SelfContainedSVGOnLoadTest(svgURL);
            TestReport tr = t.run();
            
            if(tr.hasPassed()){
                return reportError(ERROR_UNEXPECTED_TEST_RESULT);
            }
            
            if(tr.getErrorCode() != expectedErrorCode){
                TestReport r = reportError(ERROR_UNEXPECTED_ERROR_CODE);
                r.addDescriptionEntry(ENTRY_ERROR_CODE, tr.getErrorCode());
                r.addDescriptionEntry(ENTRY_EXPECTED_ERROR_CODE, 
                                       expectedErrorCode);
                return r;
            }
            
            // Check that there is a description entry
            TestReport.Entry[] desc = tr.getDescription();
            int nDesc = 0, enDesc = 0;
            if (desc != null){
                nDesc = desc.length;
            }
            if (expectedEntryCodes != null){
                enDesc = expectedEntryCodes.length;
            }
            
            if (nDesc != enDesc){
                TestReport r = reportError(ERROR_UNEXPECTED_NUMBER_OF_DESCRIPTION_ENTRIES);
                
                r.addDescriptionEntry(ENTRY_NUMBER_OF_DESCRIPTION,
                                      "" + nDesc);
                r.addDescriptionEntry(ENTRY_EXPECTED_NUMBER_OF_DESCRIPTION,
                                      "" + enDesc);
                return r;
            }
            
            if (nDesc > 0){
                Vector veDesc = new Vector();
                for(int i=0; i<nDesc; i++){
                    veDesc.add(expectedEntryCodes[i]);
                }

                for(int i=0; i<nDesc; i++){
                    String key = desc[i].getKey();
                    if (key == null || !veDesc.contains(key)){
                        TestReport r = reportError(ERROR_UNEXPECTED_DESCRIPTION_ENTRY);
                        if (key != null){
                            r.addDescriptionEntry(ENTRY_KEY, key);
                            r.addDescriptionEntry(ENTRY_EXPECTED_KEY, 
                              SelfContainedSVGOnLoadTest.ENTRY_KEY_NUMBER_OF_TEST_RESULT_ELEMENTS);
                        }
                        return r;
                    }
                }
            }
            
            return reportSuccess();
        }
    }
    
}

