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
package org.apache.flex.forks.batik.test.xml;

/**
 * Contains constants for the XML Test Run (XTRun) syntax.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: XTRunConstants.java,v 1.5 2004/08/18 07:17:08 vhardy Exp $
 */
public interface XTRunConstants {
    String XTRun_NAMESPACE_URI 
        = "http://xml.apache.org/xml-batik/test/xtrun";

    /////////////////////////////////////////////////////////////////////////
    // XTRun tags
    /////////////////////////////////////////////////////////////////////////
    String XTRun_TEST_RUN_TAG = "testRun";
    String XTRun_TEST_SUITE_TAG = "testSuite";
    String XTRun_TEST_REPORT_PROCESSOR_TAG = "testReportProcessor";

    /////////////////////////////////////////////////////////////////////////
    // XTRun attributes
    /////////////////////////////////////////////////////////////////////////
    String XTRun_HREF_ATTRIBUTE = "href";
    String XTRun_ID_ATTRIBUTE   = "id";
    String XTRun_NAME_ATTRIBUTE  = "name";
}
