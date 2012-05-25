/*

   Copyright 2002 The Apache Software Foundation 

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
    
/**
 * If this script is loaded by ecmaCheckNoLoad.svg, it will mark
 * the test result as failed.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: iWasLoaded.js,v 1.2 2005/03/27 08:58:37 cam Exp $
 */

    var result = document.getElementById("testResult");
    result.setAttributeNS(null, "result", "failed");
    result.setAttributeNS(null, "errorCode", "iWasLoaded.js should not have been loaded");
