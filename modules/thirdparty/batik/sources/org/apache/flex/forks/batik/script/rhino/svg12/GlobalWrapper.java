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

import org.apache.flex.forks.batik.dom.svg12.SVGGlobal;
import org.apache.flex.forks.batik.script.rhino.WindowWrapper;

import org.mozilla.javascript.Context;
import org.mozilla.javascript.Function;
import org.mozilla.javascript.NativeJavaObject;
import org.mozilla.javascript.Scriptable;
import org.mozilla.javascript.ScriptableObject;

import org.w3c.dom.events.EventTarget;

/**
 * Wrapper class for the SVGGlobal object.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: GlobalWrapper.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GlobalWrapper extends WindowWrapper {

    /**
     * Creates a new GlobalWrapper.
     */
    public GlobalWrapper(Context context) {
        super(context);
        String[] names = { "startMouseCapture", "stopMouseCapture" };
        this.defineFunctionProperties(names, GlobalWrapper.class,
                                      ScriptableObject.DONTENUM);
    }

    public String getClassName() {
        return "SVGGlobal";
    }
    
    public String toString() {
        return "[object SVGGlobal]";
    }

    /**
     * Wraps the 'startMouseCapture' method of the SVGGlobal interface.
     */
    public static void startMouseCapture(Context cx,
                                         Scriptable thisObj,
                                         Object[] args,
                                         Function funObj) {
        int len = args.length;
        GlobalWrapper gw = (GlobalWrapper) thisObj;
        SVGGlobal global = (SVGGlobal) gw.window;
        if (len >= 3) {
            EventTarget et = null;
            if (args[0] instanceof NativeJavaObject) {
                Object o = ((NativeJavaObject) args[0]).unwrap();
                if (o instanceof EventTarget) {
                    et = (EventTarget) o;
                }
            }
            if (et == null) {
                throw Context.reportRuntimeError("First argument to startMouseCapture must be an EventTarget");
            }
            boolean sendAll = Context.toBoolean(args[1]);
            boolean autoRelease = Context.toBoolean(args[2]);
            global.startMouseCapture(et, sendAll, autoRelease);
        }
    }

    /**
     * Wraps the 'stopMouseCapture' method of the SVGGlobal interface.
     */
    public static void stopMouseCapture(Context cx,
                                        Scriptable thisObj,
                                        Object[] args,
                                        Function funObj) {
        GlobalWrapper gw = (GlobalWrapper) thisObj;
        SVGGlobal global = (SVGGlobal) gw.window;
        global.stopMouseCapture();
    }
}
