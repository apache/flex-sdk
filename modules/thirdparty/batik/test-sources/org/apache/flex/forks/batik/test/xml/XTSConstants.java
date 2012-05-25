/*
 * Copyright 1999-2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.flex.forks.batik.test.xml;

/**
 * Contains constants for the XML Test Suite (XTS) syntax.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: XTSConstants.java,v 1.7 2005/04/01 02:28:16 deweese Exp $
 */
public interface XTSConstants extends XMLReflectConstants{
    String XTS_NAMESPACE_URI 
        = "http://xml.apache.org/xml-batik/test/xts";

    /////////////////////////////////////////////////////////////////////////
    // XTS tags
    /////////////////////////////////////////////////////////////////////////
    String XTS_TEST_TAG       = "test";
    String XTS_TEST_GROUP_TAG = "testGroup";
    String XTS_TEST_SUITE_TAG = "testSuite";

    /////////////////////////////////////////////////////////////////////////
    // XTS attributes
    /////////////////////////////////////////////////////////////////////////
    String XTS_ID_ATTRIBUTE   = "id";
    String XTS_NAME_ATTRIBUTE = "name";
}
