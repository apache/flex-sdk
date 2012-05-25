/*

   Copyright 2003  The Apache Software Foundation 

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

import org.mozilla.javascript.Context;
import org.mozilla.javascript.Scriptable;
import org.mozilla.javascript.WrapFactory;
import org.w3c.dom.events.EventTarget;

/**
 * This is an utility class allowing to pass an ECMAScript function
 * as a parameter of the <code>addEventListener</code> method of
 * <code>EventTarget</code> objects as DOM Level 2 recommendation
 * required.
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: BatikWrapFactory.java,v 1.4 2004/08/18 07:14:57 vhardy Exp $
 */
class BatikWrapFactory extends WrapFactory {
    private RhinoInterpreter interpreter;

    public BatikWrapFactory(RhinoInterpreter interp) {
        interpreter = interp;
        setJavaPrimitiveWrap(false);
    }

    public Object wrap(Context ctx, Scriptable scope,
                       Object obj, Class staticType) {
        if (obj instanceof EventTarget) {
            return interpreter.buildEventTargetWrapper((EventTarget)obj);
        }
        return super.wrap(ctx, scope, obj, staticType);
    }
}
