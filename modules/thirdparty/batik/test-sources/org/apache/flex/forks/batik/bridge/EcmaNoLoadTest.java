/*

   Copyright 2004  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.test.*;

import org.apache.flex.forks.batik.test.svg.SVGOnLoadExceptionTest;

/**
 * Checks that ECMA Scripts which should not be loaded are not
 * loaded.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: EcmaNoLoadTest.java,v 1.4 2005/03/29 10:48:04 deweese Exp $
 */
public class EcmaNoLoadTest extends DefaultTestSuite {
    public EcmaNoLoadTest() {
        String scripts = "application/java-archive";
        String[] scriptSource = {"bridge/ecmaCheckNoLoadAny",
                                 "bridge/ecmaCheckNoLoadSameAsDocument",
                                 "bridge/ecmaCheckNoLoadEmbed",
                                 "bridge/ecmaCheckNoLoadEmbedAttr",
        };
        boolean[] secure = {true, false};
        String[] scriptOrigin = {"ANY", "DOCUMENT", "EMBEDED", "NONE"};

        //
        // If "application/ecmascript" is disallowed, scripts
        // should not be loaded, no matter their origin or the
        // other security settings.
        //
        for (int i=0; i<scriptSource.length; i++) {
            for (int j=0; j<secure.length; j++) {
                for (int k=0; k<scriptOrigin.length; k++) {
                    SVGOnLoadExceptionTest t = buildTest(scripts,
                                                         scriptSource[i],
                                                         scriptOrigin[k],
                                                         secure[j],
                                                         false,
                                                         false);
                    addTest(t);
                }
            }
        }

        //
        // If script run in restricted mode, then there should be
        // a security exception, no matter what the other settings are
        // (if we are running code under a security manager, that is,
        // i.e., secure is true).
        scripts = "text/ecmascript";
        for (int i=0; i<scriptSource.length; i++) {
            for (int k=0; k<scriptOrigin.length; k++) {
                boolean expectSuccess = ((i>=2) && (k <= 2));
                SVGOnLoadExceptionTest t = buildTest(scripts,
                                                     scriptSource[i],
                                                     scriptOrigin[k],
                                                     true,
                                                     true,
                                                     expectSuccess);
                addTest(t);
            }
        }

        //
        // If "applicatin/ecmascript" is allowed, but the accepted
        // script origin is lower than the candidate script, then
        // the script should not be loaded (e.g., if scriptOrigin
        // is embeded and trying to load an external script).
        //
        for (int j=0; j<scriptOrigin.length; j++) {
            int max = j;
            if (j == scriptOrigin.length - 1) {
                max = j+1;
            }
            for (int i=0; i<max; i++) {
                for (int k=0; k<secure.length; k++) {
                    SVGOnLoadExceptionTest t= buildTest(scripts, scriptSource[i],
                                                        scriptOrigin[j],
                                                        secure[k],
                                                        false,
                                                        false);
                    addTest(t);
                }
            }
        }
    }

    SVGOnLoadExceptionTest buildTest(String scripts, String id, String origin, 
                                     boolean secure, boolean restricted, 
                                     boolean successExpected) {
        SVGOnLoadExceptionTest t = new SVGOnLoadExceptionTest();
        String desc = 
            "(scripts=" + scripts + 
            ")(scriptOrigin=" + origin +
            ")(secure=" + secure +
            ")(restricted=" + restricted + ")";
        
        t.setId(id + desc);
        t.setScriptOrigin(origin);
        t.setSecure(secure);
        t.setScripts(scripts);
        if (successExpected)
            t.setExpectedExceptionClass(null);
        else
            t.setExpectedExceptionClass("java.lang.SecurityException");
        t.setRestricted(restricted);

        return t;
    }
                             
}
