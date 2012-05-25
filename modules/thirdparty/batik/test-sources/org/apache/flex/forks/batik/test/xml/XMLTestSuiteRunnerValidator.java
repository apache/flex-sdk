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
package org.apache.flex.forks.batik.test.xml;

import java.io.File;

import java.net.URL;

import java.util.HashSet;
import java.util.Set;
import java.util.StringTokenizer;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;

import org.w3c.dom.Document;

import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.DefaultTestSuite;
import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.TestReport;
import org.apache.flex.forks.batik.test.TestSuiteReport;

/**
 * Validates the operation of the <tt>XMLTestSuireRunner</tt> by checking
 * that it runs the tests specified by the command line parameter and 
 * only these tests. <br />
 * The test uses an dummy &lt;testRun&gt; which contains: <br />
 * - testRun, id="all"
 *     - testSuite, href="testSuiteA.xml" <br />
 *     - testSuite, href="testSuiteB.xml" <br />
 * Where: <br />
 * - testSuite, id="A" <br />
 *     - test, id="A1" <br />
 *     - test, id="A2" <br />
 *     - test, id="duplicateId" <br />
 *     - testGroup, id="AG" <br />
 *          - test, id="AG1" <br />
 *          - test, id="AG2" <br />
 *
 * and: <br />
 * - testSuite, id="B" <br />
 *     - test, id="B1" <br />
 *     - test, id="B2" <br />
 *     - test, id="B3" <br />
 *     - test, id="duplicateId" <br />
 *
 * where all the leaf test pass. <br />
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: XMLTestSuiteRunnerValidator.java,v 1.7 2004/08/18 07:17:08 vhardy Exp $
 */
public class XMLTestSuiteRunnerValidator extends DefaultTestSuite {
    public static final String ERROR_TEST_NOT_RUN
        = "error.test.not.run";

    public static final String ERROR_EXTRA_TEST_RUN
        = "error.extra.test.run";

    public static final String ENTRY_KEY_CONFIGURATION
        = "entry.key.configuration";

    public static final String ENTRY_KEY_EXPECTED_RESULT
        = "entry.key.expected.result";

    public static final String ENTRY_KEY_ACTUAL_RESULT
        = "entry.key.actual.result";

    public static final String ENTRY_KEY_TEST_IDS_NOT_RUN
        = "entry.key.test.ids.not.run";

    public static final String ENTRY_KEY_TEST_ID_NOT_EXPECTED
        = "entry.key.test.id.not.expected";

    /**
     * Dummy test-suite used to run the test
     */
    static final String dummyTestRun =
        "test-resources/org/apache/batik/test/xml/dummyTestRun.xml";

    /**
     * This suite is made of elementary tests which validate that
     * the XML result for a given input contains a list of 
     * report ids and no more (i.e., that the expected test reports
     * were generated and no more). <br />
     * Specificaly, with fully qualified ids: <br />
     * - no arguments. All tests-reports should be produced. <br />
     * - 1 target test: "all.B.B3". A single test-report should be produced
     *   for B3. <br />
     * - 1 target test-suite: "all.A". A test-report with
     *   "A1", "A2", "duplicatedId", "AG", "AG.AG1" and "AG.AG2" should be produced.<br />
     * - 1 target test-suite and 2 tests: "all.B and 
     *   all.A.A1 and all.A.A2. A test-report for "all.B.B1", "all.B.B2", 
     *   "all.B.B3", "all.B.duplicatedId", "all.A.A1" and "all.A.A2" 
     *   should be produced. <br />
     * - 1 target testGroup: "AG". A test-report with
     *   "A.AG", "A.AG.AG1" and "A.AG.AG2" should be produced.<br />
     * <br />
     * In addition, the following test with non-qualified ids: <br />
     * - 1 target test id: "duplicatedId" should be produced and
     *   pass for "all.A.duplicatedId" and "all.B.duplicatedId".
     */
    public XMLTestSuiteRunnerValidator() {
        Object config[][] = {
            {"", new String[]{"all", 
                              "all.A", "all.A.A1", "all.A.A2", "all.A.duplicatedId", "all.A.duplicatedId.1", "all.A.duplicatedId.2",
                              "all.A.AG", "all.A.AG.AG1", "all.A.AG.AG2",
                              "all.B", "all.B.B1", "all.B.B2", "all.B.B3", "all.B.duplicatedId"}},

            {"all.B.B3", new String[] {"all", "all.B", "all.B.B3"}},

            {"all.A", new String[] {"all",
                                    "all.A", "all.A.A1", "all.A.A2", "all.A.duplicatedId", "all.A.duplicatedId.1", "all.A.duplicatedId.2",
                                    "all.A.AG", "all.A.AG.AG1", "all.A.AG.AG2"}},

            {"all.B all.A.A1 all.A.A2", 
             new String[] {"all",
                           "all.B", "all.B.B1", "all.B.B2", "all.B.B3", "all.B.duplicatedId",
                           "all.A", "all.A.A1", "all.A.A2"}},

            {"duplicatedId", 
             new String[] {"all",
                           "all.A", "all.A.duplicatedId", "all.A.duplicatedId.1", "all.A.duplicatedId.2",
                           "all.B", "all.B.duplicatedId"}}, 

            {"AG",
             new String[] {"all",
                           "all.A",
                           "all.A.AG",
                           "all.A.AG.AG1", "all.A.AG.AG2"}}
        };

        for(int i=0; i<config.length; i++){
            addTest(new XMLTestSuiteRunnerTest(config[i]));
        }

    }
    
    static class XMLTestSuiteRunnerTest extends AbstractTest {
        /**
         * Argument to feed into the XMLTestSuiteRunner
         */
        protected String[] args;

        /**
         * Expected ids in the report generated by the
         * XMLTestSuiteRunner
         */
        protected HashSet ids;
        protected String[]  idsArray;

        /**
         * @param config an array of two objects: a String containing
         *        the "config" to pass to the XMLTestSuiteRunner and
         *        an array of Strings containing the expected ids
         *        from the XMLTestSuiteRunner operation.
         */
        public XMLTestSuiteRunnerTest(Object config[]){
            StringTokenizer st = new StringTokenizer((String)config[0], " ");
            int nArgs = st.countTokens();
            args = new String[nArgs];
            for(int i=0; i<nArgs; i++){
                args[i] = st.nextToken();
            }

            ids = new HashSet();
            for(int i=0; i<(config[1] != null? ((Object[])config[1]).length:0); i++){
                ids.add(((Object[])config[1])[i]);
            }
            idsArray = (String[])config[1];
        }

        /**
         * <tt>AbstractTest</tt>'s template method implementation.
         */
        public TestReport runImpl() throws Exception{
            //
            // Load the template dummy testRun file.
            //
            Document doc = loadDummyTestRun();

            //
            // Now run the test. 
            //
            XMLTestSuiteRunner runner 
                = new XMLTestSuiteRunner();

            TestReport runReport 
                = runner.run(doc, args);

            //
            // Analyse TestReport
            //
            Set idSet = (Set)(ids.clone());
            String idNotExpected = checkTestReport(runReport, idSet);

            if(idNotExpected == null){
                if(idSet.isEmpty()){
                    return reportSuccess();
                }
                else{
                    DefaultTestReport report = new DefaultTestReport(this);
                    report.setErrorCode(ERROR_TEST_NOT_RUN);
                    report.addDescriptionEntry(ENTRY_KEY_CONFIGURATION,
                                               arrayToString(args));
                    report.addDescriptionEntry(ENTRY_KEY_EXPECTED_RESULT,
                                               arrayToString(idsArray));
                    report.addDescriptionEntry(ENTRY_KEY_ACTUAL_RESULT,
                                               reportIdsToString(runReport));
                    report.addDescriptionEntry(ENTRY_KEY_TEST_IDS_NOT_RUN,
                                               arrayToString(idSet.toArray()));
                report.setPassed(false);
                return report;
                }
            }
            else{
                DefaultTestReport report = new DefaultTestReport(this);
                report.setErrorCode(ERROR_EXTRA_TEST_RUN);
                report.addDescriptionEntry(ENTRY_KEY_CONFIGURATION,
                                           arrayToString(args));
                report.addDescriptionEntry(ENTRY_KEY_EXPECTED_RESULT,
                                           arrayToString(idsArray));
                report.addDescriptionEntry(ENTRY_KEY_ACTUAL_RESULT,
                                          reportIdsToString(runReport));
                report.addDescriptionEntry(ENTRY_KEY_TEST_ID_NOT_EXPECTED,
                                           idNotExpected);
                report.setPassed(false);
                return report;
            }
        }

        protected String arrayToString(Object[] array){
            StringBuffer sb = new StringBuffer();
            if(array != null){
                if(array.length > 0){
                    sb.append(array[0]);
                }
                for(int i=1; i<array.length; i++){
                    sb.append(", ");
                    sb.append(array[i].toString());
                }
            }
            return sb.toString();
        }

        protected String reportIdsToString(TestReport r){
            StringBuffer sb = new StringBuffer();
            if(r != null){
                sb.append(r.getTest().getQualifiedId());
                if(r instanceof TestSuiteReport){
                    TestReport[] c = ((TestSuiteReport)r).getChildrenReports();
                    if(c != null){
                        for(int i=0; i<c.length; i++){
                            appendReportIds(c[i], sb);
                        }
                    }
                }
            }
            else{
                sb.append("null");
            }

            return sb.toString();
        }

        protected void appendReportIds(TestReport r, StringBuffer sb){
            if(r != null){
                sb.append(", ");
                sb.append(r.getTest().getQualifiedId());

                if(r instanceof TestSuiteReport){
                    TestReport[] c = ((TestSuiteReport)r).getChildrenReports();
                    if(c != null){
                        for(int i=0; i<c.length; i++){
                            appendReportIds(c[i], sb);
                        }
                    }
                }
            }
        }
           
        /**
         * Loads the dummy testRun description
         */
        protected Document loadDummyTestRun() throws Exception{
            DocumentBuilder docBuilder
                = DocumentBuilderFactory.newInstance().newDocumentBuilder();

            URL url = (new File(XMLTestSuiteRunnerValidator.dummyTestRun)).toURL();
            return docBuilder.parse(url.toString());

        }

        /**
         * Validates that the input <tt>TestReport</tt>
         * contains only the expected identifiers.
         * The following code is by no means optimized,
         * but it gets the job done.
         */
        protected String checkTestReport(TestReport report,
                                         Set idSet){
            String id = report.getTest().getQualifiedId();
            if(!(idSet.contains(id))){
                return id;
            }
            
            idSet.remove(id);

            //
            // Now, process children reports if any.
            //
            if(report instanceof TestSuiteReport){
                TestReport[] childReports = ((TestSuiteReport)report).getChildrenReports();
                if(childReports != null){
                    for(int i=0; i<childReports.length; i++){
                        String idNotExpected 
                            = checkTestReport(childReports[i],
                                              idSet);
                        if(idNotExpected != null){
                            return idNotExpected;
                        }
                    }
                }
            }

            return null;
        }
            
    }

    
}
