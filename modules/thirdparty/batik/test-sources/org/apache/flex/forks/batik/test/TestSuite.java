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
 * A <tt>TestSuite</tt> is a composite test, that is, a test
 * made of multiple children <tt>Test</tt> cases. Running a 
 * <tt>TestSuite</tt> will simply run the children test cases.
 *
 * @author <a href="mailto:vhardy@apache.lorg">Vincent Hardy</a>
 * @version $Id: TestSuite.java,v 1.4 2004/08/18 07:16:58 vhardy Exp $
 */
public interface TestSuite extends Test {
    /**
     * Adds a <tt>Test</tt> to the suite
     */
    public void addTest(Test test);

    /**
     * Removes a <tt>Test</tt> from the suite
     */
    public void removeTest(Test test);

    /**
     * Returns this suite's <tt>Test</tt>. This should 
     * not return a reference to any internal structure
     * held by the <tt>TestSuite</tt>. For example, if 
     * an internal array is used, this shoudl return 
     * a copy of that array.
     */
    public Test[] getChildrenTests();

    /**
     * Returns the number of child tests
     */
    public int getChildrenCount();

}
