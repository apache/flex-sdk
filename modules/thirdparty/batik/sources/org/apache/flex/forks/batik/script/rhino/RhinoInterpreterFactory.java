/*

   Copyright 2001-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.script.rhino;

import java.net.URL;

import org.apache.flex.forks.batik.script.Interpreter;
import org.apache.flex.forks.batik.script.InterpreterFactory;

/**
 * Allows to create instances of <code>RhinoInterpreter</code> class.
 * 
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: RhinoInterpreterFactory.java,v 1.9 2004/08/27 00:42:07 deweese Exp $
 */
public class RhinoInterpreterFactory implements InterpreterFactory {

    final static String TEXT_ECMASCRIPT = "text/ecmascript";

    /**
     * Builds a <code>RhinoInterpreterFactory</code>.
     */
    public RhinoInterpreterFactory() {
    }

    /**
     * Returns the mime-type to register this interpereter with.
     */
    public String getMimeType() { return TEXT_ECMASCRIPT; }

    /**
     * Creates an instance of <code>RhinoInterpreter</code> class.
     * 
     * @param documentURL the url for the document which will be scripted
     */
    public Interpreter createInterpreter(URL documentURL) {
        return new RhinoInterpreter(documentURL);
    }
}
