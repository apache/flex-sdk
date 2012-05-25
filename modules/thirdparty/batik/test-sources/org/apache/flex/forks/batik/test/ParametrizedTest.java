/*

   Copyright 2003  The Apache Software Foundation 

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
 * This test validates that test properties are inherited from the class that
 * defines the "class" attribute down to each test instance that uses the 
 * same class.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: ParametrizedTest.java,v 1.4 2004/08/18 07:16:57 vhardy Exp $
 */
public class ParametrizedTest extends AbstractTest {
    protected String A = "initial_A_value";
    protected String B = "initial_B_value";
    protected String expectedA = "unset";
    protected String expectedB = "unset";

    public void setA(String A) {
        this.A = A;
    }

    public void setB(String B) {
        this.B = B;
    }

    public void setExpectedA(String expectedA) {
        this.expectedA = expectedA;
    }

    public void setExpectedB(String expectedB) {
        this.expectedB = expectedB;
    }

    public String getA() {
        return A;
    }

    public String getB() {
        return B;
    }

    public String getExpectedA() {
        return expectedA;
    }

    public String getExpectedB() {
        return expectedB;
    }

    public TestReport runImpl() throws Exception {
        if (!A.equals(expectedA) || !B.equals(expectedB)) {
            TestReport r = reportError("Unexpected A or B value");
            r.addDescriptionEntry("expected.A", expectedA);
            r.addDescriptionEntry("actual.A", A);
            r.addDescriptionEntry("expected.B", expectedB);
            r.addDescriptionEntry("actual.B", B);
            return r;
        }

        return reportSuccess();
    }
}
