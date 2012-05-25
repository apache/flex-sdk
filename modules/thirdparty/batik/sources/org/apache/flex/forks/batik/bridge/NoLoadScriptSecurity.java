/*

   Copyright 2002-2003  The Apache Software Foundation 

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

/**
 * This implementation for the <tt>ScriptSecurity</tt> interface
 * does not allow scripts to be loaded.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: NoLoadScriptSecurity.java,v 1.6 2005/03/27 08:58:30 cam Exp $
 */
public class NoLoadScriptSecurity implements ScriptSecurity {

    /**
     * Message when trying to load a script file and the Document
     * does not have a URL
     */
    public static final String ERROR_NO_SCRIPT_OF_TYPE_ALLOWED
        = "NoLoadScriptSecurity.error.no.script.of.type.allowed";

    /**
     * The exception is built in the constructor and thrown if 
     * the checkLoadScript method is called.
     */
    protected SecurityException se;

    /**
     * Controls whether the script should be loaded or not.
     *
     * @throws SecurityException if the script should not be loaded.
     */
    public void checkLoadScript(){
        throw se;
    }

    /**
     * Creates a new NoLoadScriptSecurity object.
     * @param scriptType type of script, as found in the 
     *        type attribute of the &lt;script&gt; element.
     */
    public NoLoadScriptSecurity(String scriptType){

        se = new SecurityException
            (Messages.formatMessage(ERROR_NO_SCRIPT_OF_TYPE_ALLOWED,
                                    new Object[]{scriptType}));
    }
}
