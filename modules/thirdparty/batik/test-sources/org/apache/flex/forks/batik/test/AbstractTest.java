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

import java.io.StringWriter;
import java.io.PrintWriter;

/**
 * Base class containing convenience methods for writing tests. <br />
 * There are at least three approaches to write new tests derived from
 * <tt>AbstractTest</tt>:<br /><ul>
 * <li>You can simply override the <tt>runImplBase</tt> method and 
 * return true or false depending on whether or not the test fails.</li>
 * <li>You can choose to report more complex test failure conditions 
 * by overriding the <tt>runImpl</tt> method which returns a <tt>TestReport</tt>.
 * In that case, you can use the convenience methods such as <tt>reportFailure</tt>
 * <tt>reportSuccess</tt> or <tt>reportException</tt> to help build a <tt>TestReport</tt>,
 * and use the <tt>TestReport</tt>'s <tt>addDescriptionEntry</tt> to populate
 * the report with relevant error description.</li>
 * <li>You can choose to use the various assertion methods such as <tt>assertNull</tt>,
 * <tt>assertEquals</tt> or <tt>assertTrue</tt>. These methods throw exceptions which
 * will be turned in <tt>TestReports</tt> by the <tt>AbstractTest</tt>.</li>
 * </ul>
 * 
 * Here are some examples:
 * <code>
 * public class MyTestA extends AbstractTest {
 * public boolean runImplBase() {
 *    if(someConditionFails){
 *       return false;
 *    }
 *    return true;
 * }
 * }
 * </code>
 * 
 * <code>
 * public class MyTestB extends AbstractTest {
 * public TestReport runImpl() {
 *    if(someConditionFails){
 *       TestReport report = reportError(MY_ERROR_CODE);
 *       report.addDescriptionEntry(ENTRY_KEY_MY_ERROR_DESCRIPTION_KEY,
 *                                  myErrorDescriptionValue);
 *       return report;
 *    }
 * 
 *    return reportSuccess();
 * }
 * </code>
 *
 * <code>
 * public class MyTestC extends AbstractTest {
 * public TestReport runImpl() throws Exception {
 *      assertTrue(somCondition);
 *      assertEquals(valueA, valueB);
 *      assertNull(shouldBeNullRef);
 *
 *      if(someErrorCondition){
 *         error(MY_ERROR_CODE);
 *      }
 *
 *      return reportSuccess();
 * }
 * </code>
 *
 * @author <a href="mailto:vhardy@apache.lorg">Vincent Hardy</a>
 * @version $Id: AbstractTest.java,v 1.12 2004/08/18 07:16:55 vhardy Exp $
 */
public abstract class AbstractTest implements Test {
    /**
     * This test's id.
     */
    protected String id = "";
    
    /**
     * This test's parent, in case this test is part of 
     * a suite.
     */
    protected TestSuite parent;

    /**
     * This test's name. If null, the class' name is returned.
     */
    protected String name;
    
    /**
     * TestReport
     */
    private DefaultTestReport report 
        = new DefaultTestReport(this) {
                {
                    setErrorCode(ERROR_INTERNAL_TEST_FAILURE);
                    setPassed(false);
                }
            };
    
    /**
     * Returns this <tt>Test</tt>'s name. 
     */
    public String getName(){
        if(name == null){
            if (id != null && !"".equals(id)){
                return id;
            } else {
                return getClass().getName();
            }
        }

        return name;
    }

    /**
     * Sets this test's name
     */
    public void setName(String name){
        this.name = name;
    }

    /**
     * Return this <tt>Test</tt>'s id.
     */
    public String getId(){
        return id;
    }

    /**
     * Return this <tt>Test</tt>'s qualified id.
     */
    public String getQualifiedId(){
        if(parent == null){
            return getId();
        }
        return getParent().getQualifiedId() + "." + getId();
    }

    /**
     * Set this <tt>Test</tt>'s id. Null is not allowed.
     */
    public void setId(String id){
        if(id == null){
            throw new IllegalArgumentException();
        }

        this.id = id;
    }

    public TestSuite getParent(){
        return parent;
    }

    public void setParent(TestSuite parent){
        this.parent = parent;
    }
    
    /**
     * This default implementation of the run method
     * catches any Exception thrown from the 
     * runImpl method and creates a <tt>TestReport</tt>
     * indicating an internal <tt>Test</tt> failure
     * when that happens. Otherwise, this method
     * simply returns the <tt>TestReport</tt> generated
     * by the <tt>runImpl</tt> method.
     */
    public TestReport run(){
        try{
            return runImpl();
        } catch(TestErrorConditionException e){
            return e.getTestReport(this);
        } catch(Exception e){
            try {
                
                StringWriter trace = new StringWriter();
                e.printStackTrace(new PrintWriter(trace));
                
                TestReport.Entry[] entries = new TestReport.Entry[]{
                    new TestReport.Entry
                        (Messages.formatMessage
                         (TestReport.ENTRY_KEY_INTERNAL_TEST_FAILURE_EXCEPTION_CLASS, null),
                         e.getClass().getName()),
                    new TestReport.Entry
                        (Messages.formatMessage
                         (TestReport.ENTRY_KEY_INTERNAL_TEST_FAILURE_EXCEPTION_MESSAGE, null),
                         e.getMessage()),
                    new TestReport.Entry
                        (Messages.formatMessage
                         (TestReport.ENTRY_KEY_INTERNAL_TEST_FAILURE_EXCEPTION_STACK_TRACE, null),
                         trace.toString())
                        };

                report.setDescription(entries);

            }catch(Exception ex){
                ex.printStackTrace();
            }finally {
                //
                // In case we are in severe trouble, even filling in the 
                // TestReport may fail. Because the TestReport instance
                // was created up-front, this ensures we can return 
                // the report, even though it may be incomplete.
                e.printStackTrace();
                System.out.println("SERIOUS ERROR");
                return report;
            }
                
        }
    }

    /**
     * Subclasses should implement this method with the content of 
     * the test case. Typically, implementations will choose to 
     * catch and process all exceptions and error conditions they
     * are looking for in the code they exercise but will let 
     * exceptions due to their own processing propagate. 
     */
    public TestReport runImpl() throws Exception {
        boolean passed = runImplBasic();
        
        // No exception was thrown if we get to this 
        // portion of rumImpl. The test result is 
        // given by passed.
        DefaultTestReport report = new DefaultTestReport(this);
        if(!passed){
            report.setErrorCode(TestReport.ERROR_TEST_FAILED);
        }
        report.setPassed(passed);
        return report;
    }
    
    /**
     * In the simplest test implementation, developers can 
     * simply implement the following method.
     */
    public boolean runImplBasic() throws Exception {
        return true;
    }
    
    /**
     * Convenience method.
     */
    public TestReport reportSuccess() {
        DefaultTestReport report = new DefaultTestReport(this);
        report.setPassed(true);
        return report;
    }
    
    /**
     * Convenience method to report a simple error code.
     */
    public TestReport reportError(String errorCode){
        DefaultTestReport report = new DefaultTestReport(this);
        report.setErrorCode(errorCode);
        report.setPassed(false);
        return report;
    }
    
    /**
     * Convenience method to report an error condition.
     */
    public void error(String errorCode) throws TestErrorConditionException {
        throw new TestErrorConditionException(errorCode);
    }

    /**
     * Convenience method to check that a reference is null
     */
    public void assertNull(Object ref) throws AssertNullException {
        if(ref != null){
            throw new AssertNullException();
        }
    }

    /**
     * Convenience method to check that a given boolean is true.
     */
    public void assertTrue(boolean b) throws AssertTrueException {
        if (!b){
            throw new AssertTrueException();
        }
    }
        
    /**
     * Convenience method to check for a specific condition.
     * Returns true if both objects are null or if ref is not
     * null and ref.equals(cmp) is true.
     */
    public void assertEquals(Object ref, Object cmp) throws AssertEqualsException {
        if(ref == null && cmp != null){
            throw new AssertEqualsException(ref, cmp);
        }

        if(ref != null && !ref.equals(cmp)){
            throw new AssertEqualsException(ref, cmp);
        }
    }

    public void assertEquals(int ref, int cmp) throws AssertEqualsException {
        assertEquals(new Integer(ref), new Integer(cmp));
    }

    /**
     * Convenience method to help implementations report errors.
     * An <tt>AbstractTest</tt> extension will typically catch 
     * exceptions for specific error conditions it wants to point 
     * out. For example:<tt>
     * public TestReport runImpl() throws Exception { <br />
     *   try{ <br />
     *      .... something .... <br />
     *   catch(MySpecialException e){ <br />
     *      return reportException(MY_SPECIAL_ERROR_CODE, e); <br />
     *   } <br />
     * <br />
     * public static final String MY_SPECIAL_ERROR_CODE = "myNonQualifiedClassName.my.error.code" <br />
     * <br />
     * </tt> <br />
     * Note that the implementor will also need to add an entry
     * in its Messages.properties file. That file is expected to be 
     * in a resource file called <tt>Messages</tt> having the same package 
     * name as the <tt>Test</tt> class, appended with "<tt>.resources</tt>".
     */
    public TestReport reportException(String errorCode,
                                      Exception e){
        DefaultTestReport report 
            = new DefaultTestReport(this);

        StringWriter trace = new StringWriter();
        e.printStackTrace(new PrintWriter(trace));
        report.setErrorCode(errorCode);

                
        TestReport.Entry[] entries = new TestReport.Entry[]{
            new TestReport.Entry
                (Messages.formatMessage
                 (TestReport.ENTRY_KEY_REPORTED_TEST_FAILURE_EXCEPTION_CLASS, null),
                 e.getClass().getName()),
            new TestReport.Entry
                (Messages.formatMessage
                 (TestReport.ENTRY_KEY_REPORTED_TEST_FAILURE_EXCEPTION_MESSAGE, null),
                 e.getMessage()),
            new TestReport.Entry
                (Messages.formatMessage
                 (TestReport.ENTRY_KEY_REPORTED_TEST_FAILURE_EXCEPTION_STACK_TRACE, null),
                 trace.toString())
                };
        report.setDescription(entries);
        report.setPassed(false);
        return report;
    }
            

}
