/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.script.rhino.svg12;

import java.net.URL;

import org.apache.flex.forks.batik.script.rhino.RhinoInterpreter;

import org.mozilla.javascript.Context;
import org.mozilla.javascript.Scriptable;
import org.mozilla.javascript.ScriptableObject;

/**
 * A RhinoInterpreter for SVG 1.2 documents.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVG12RhinoInterpreter.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVG12RhinoInterpreter extends RhinoInterpreter {

    /**
     * Creates an SVG12RhinoInterpreter object.
     */
    public SVG12RhinoInterpreter(URL documentURL) {
        super(documentURL);
    }

    /**
     * Defines the class for the global object.
     */
    protected void defineGlobalWrapperClass(Scriptable global) {
        try {
            ScriptableObject.defineClass(global, GlobalWrapper.class);
        } catch (Exception ex) {
            // cannot happen
        }
    }

    /**
     * Creates the global object.
     */
    protected ScriptableObject createGlobalObject(Context ctx) {
        return new GlobalWrapper(ctx);
    }
}
