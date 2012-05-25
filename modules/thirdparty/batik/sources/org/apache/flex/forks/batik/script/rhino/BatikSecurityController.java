/*

   Copyright 2003-2004  The Apache Software Foundation 

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
import org.mozilla.javascript.GeneratedClassLoader;
import org.mozilla.javascript.JavaScriptException;
import org.mozilla.javascript.Script;
import org.mozilla.javascript.Scriptable;
import org.mozilla.javascript.SecurityController;

import java.security.AccessController;
import java.security.AccessControlContext;
import java.security.PrivilegedAction;
import java.security.PrivilegedExceptionAction;
import java.security.PrivilegedActionException;

/**
 * This implementation of the Rhino <tt>SecurityController</tt> interface is
 * meant for use within the context of Batik only. It is a partial
 * implementation of the interface that does what is needed by Batik and
 * no more.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: BatikSecurityController.java,v 1.6 2004/08/18 07:14:57 vhardy Exp $
 */
public class BatikSecurityController extends SecurityController {

    /**
     * Default constructor
     */
    public GeneratedClassLoader createClassLoader
        (final ClassLoader parentLoader, Object securityDomain) {

        if (securityDomain instanceof RhinoClassLoader) {
            return (RhinoClassLoader)securityDomain;
        }
		
        // FIXX: This should be supported by intersecting perms.
        // Calling var script = Script(source); script(); is not supported
        throw new SecurityException("Script() objects are not supported");
    }

    /**
     * Get dynamic security domain that allows an action only if it is allowed
     * by the current Java stack and <i>securityDomain</i>. If
     * <i>securityDomain</i> is null, return domain representing permissions
     * allowed by the current stack.
     */
    public Object getDynamicSecurityDomain(Object securityDomain) {

        ClassLoader loader = (RhinoClassLoader)securityDomain;
        // Already have a rhino loader in place no need to
        // do anything (normally you would want to union the
        // the current stack with the loader's context but
        // in our case no one has lower privledges than a
        // rhino class loader).
        if (loader != null) 
            return loader;

        return AccessController.getContext();
    }

    /**
     * Call {@link Script#exec(Context cx, Scriptable scope)} of
     * <i>script</i> under restricted security domain where an action is
     * allowed only if it is allowed according to the Java stack on the
     * moment of the <i>execWithDomain</i> call and <i>securityDomain</i>.
     * Any call to {@link #getDynamicSecurityDomain(Object)} during
     * execution of {@link Script#exec(Context cx, Scriptable scope)}
     * should return a domain incorporate restrictions imposed by
     * <i>securityDomain</i>.
     */
    public Object execWithDomain(final Context cx, final Scriptable scope,
                                 final Script script, Object securityDomain)
        throws JavaScriptException {
        
        AccessControlContext acc;
        if (securityDomain instanceof AccessControlContext)
            acc = (AccessControlContext)securityDomain;
        else {
            RhinoClassLoader loader = (RhinoClassLoader)securityDomain;
            acc = loader.rhinoAccessControlContext;
        }

        try {
            // acc = new AccessController(acc, acc.getDomainCombiner());
            return AccessController.doPrivileged
                (new PrivilegedExceptionAction() {
                        public Object run() throws JavaScriptException {
                            return script.exec(cx, scope);
                        }
                    }, acc );
        } catch (Exception e) {
            throw new JavaScriptException(e);
        }

    }
}
