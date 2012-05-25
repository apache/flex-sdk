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

/**
 * Checks that ECMA Scripts which should  be loaded are indeed
 * loaded.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: EcmaLoadTest.java,v 1.3 2004/08/18 07:16:38 vhardy Exp $
 */
public class EcmaLoadTest extends DefaultTestSuite {
    public EcmaLoadTest() {
        String scripts = "text/ecmascript";
        String[] scriptSource = {"ecmaCheckLoadAny",
                                 "ecmaCheckLoadSameAsDocument",
                                 "ecmaCheckLoadEmbed",
                                 "ecmaCheckLoadEmbedAttr",
        };
        boolean[] secure = {true, false};
        String[][] scriptOrigin = {{"any"},
                                   {"any", "document"},
                                   {"any", "document", "embeded"},
                                   {"any", "document", "embeded"},
                                   };;

        //
        // <!> Need to make restricted {true/false}
        // 

        //
        // An ecma script can be loaded if ECMA is listed
        // as an allowed script _and_ the loaded script
        // has an origin allowed by the scriptOrigin setting.
        // All other security settings should not have an 
        // influence on whether or not the script can be loaded.
        //
        for (int i=0; i<scriptSource.length; i++) {
            for (int j=0; j<scriptOrigin[i].length; j++) {
                for (int k=0; k<secure.length; k++) {
                    ScriptSelfTest t= buildTest(scripts, scriptSource[i],
                                                scriptOrigin[i][j],
                                                secure[k]);
                    addTest(t);
                }
            }
        }
    }

    ScriptSelfTest buildTest(String scripts, String id, String origin, boolean secure) {
        ScriptSelfTest t = new ScriptSelfTest();
        String desc = 
            "(scripts=" + scripts + 
            ")(scriptOrigin=" + origin +
            ")(secure=" + secure + ")";
        
        t.setId(id + desc);
        t.setScriptOrigin(origin);
        t.setSecure(secure);
        t.setScripts(scripts);

        return t;
    }
                             
}
