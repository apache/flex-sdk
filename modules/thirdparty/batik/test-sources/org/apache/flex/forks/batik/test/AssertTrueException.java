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
 * Exception which Tests can throw when a specific <tt>assertTrue</tt> fails.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: AssertTrueException.java,v 1.3 2004/08/18 07:16:56 vhardy Exp $
 */
public class AssertTrueException extends AssertException {
    public static final String ASSERTION_TYPE = "assertTrue";

    /**
     * Objects which should have be equal
     */
    protected Object ref, cmp;

    public AssertTrueException(){
    }

    /**
     * Requests that the exception populates the TestReport with the
     * relevant information.
     */
    public void addDescription(TestReport report){
    }

    public String getAssertionType(){
        return ASSERTION_TYPE;
    }
}
