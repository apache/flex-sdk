/*

   Copyright 2002  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */package org.apache.flex.forks.batik.bridge;

import org.w3c.dom.*;
import org.apache.flex.forks.batik.script.ScriptHandler;
import org.apache.flex.forks.batik.script.Window;

/**
 * If this script is loaded by jarCheckLoad.svg, it will mark
 * the test result as passed.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: IWasLoadedToo.java,v 1.3 2004/08/18 07:16:02 vhardy Exp $
 */
public class IWasLoadedToo implements ScriptHandler {
    public void run(final Document document, final Window win){
        Element result = document.getElementById("testResult");
        result.setAttributeNS(null, "result", "passed");
    }
}
