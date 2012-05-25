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
 * Interace to accept or reject a test or testSuite.
 *
 * @author <a href="mailto:vhardy@apache.lorg">Vincent Hardy</a>
 * @version $Id: TestFilter.java,v 1.3 2004/08/18 07:16:58 vhardy Exp $
 */
public interface TestFilter {
    /**
     * The filter will return null or the input
     * <tt>Test</tt>. The filter may modify the test content
     * for example <tt>TestSuites</tt> may have some of their
     * children tests removed.
     */
    public Test filter(Test t);
}

