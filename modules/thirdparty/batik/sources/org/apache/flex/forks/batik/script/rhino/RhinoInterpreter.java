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
package org.apache.flex.forks.batik.script.rhino;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.io.Writer;
import java.net.URL;
import java.security.AccessControlContext;
import java.security.AccessController;
import java.security.PrivilegedAction;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.MissingResourceException;

import org.apache.flex.forks.batik.bridge.InterruptedBridgeException;
import org.apache.flex.forks.batik.script.Interpreter;
import org.apache.flex.forks.batik.script.InterpreterException;
import org.apache.flex.forks.batik.script.Window;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.ContextAction;
import org.mozilla.javascript.ContextFactory;
import org.mozilla.javascript.ClassCache;
import org.mozilla.javascript.ClassShutter;
import org.mozilla.javascript.Function;
import org.mozilla.javascript.JavaScriptException;
import org.mozilla.javascript.Script;
import org.mozilla.javascript.Scriptable;
import org.mozilla.javascript.ScriptableObject;
import org.mozilla.javascript.SecurityController;
import org.mozilla.javascript.WrapFactory;
import org.mozilla.javascript.WrappedException;
import org.w3c.dom.events.EventTarget;

/**
 * A simple implementation of <code>Interpreter</code> interface to use
 * Rhino ECMAScript interpreter.
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: RhinoInterpreter.java 524973 2007-04-02 23:49:32Z cam $
 */
public class RhinoInterpreter implements Interpreter {

    /**
     * Java packages that will be imported into the scripting environment.
     */
    protected static String[] TO_BE_IMPORTED = {
        "java.lang",
        "org.w3c.dom",
        "org.w3c.dom.css",
        "org.w3c.dom.events",
        "org.w3c.dom.smil",
        "org.w3c.dom.stylesheets",
        "org.w3c.dom.svg",
        "org.w3c.dom.views",
        "org.w3c.dom.xpath"
    };

    /**
     * The number of cached compiled scripts to store.
     */
    private static final int MAX_CACHED_SCRIPTS = 32;

    /**
     * Constant used to describe an SVG source
     */
    public static final String SOURCE_NAME_SVG = "<SVG>";

    /**
     * Name of the "window" object when referenced by scripts
     */
    public static final String BIND_NAME_WINDOW = "window";

    /**
     * Context vector, to make sure we are not
     * setting the security context too many times
     */
    protected static List contexts = new LinkedList();

    /**
     * The window object.
     */
    protected Window window;

    /**
     * The global object.
     */
    protected ScriptableObject globalObject = null;

    /**
     * List of cached compiled scripts.
     */
    protected LinkedList compiledScripts = new LinkedList();

    /**
     * Factory for Java wrapper objects.
     */
    protected WrapFactory wrapFactory = new BatikWrapFactory(this);

    /**
     * Class shutter.
     */
    protected ClassShutter classShutter = new RhinoClassShutter();

    /**
     * The Rhino 'security domain'. We use the RhinoClassLoader
     * which will grant permissions to connect to the document
     * URL.
     */
    protected RhinoClassLoader rhinoClassLoader;

    /**
     * The SecurityController implementation for Batik,
     * which ensures scripts have access to the
     * server they were downloaded from
     */
    protected SecurityController securityController
        = new BatikSecurityController();

    /**
     * Factory object for creating Contexts.
     */
    protected ContextFactory contextFactory = new Factory();

    /**
     * Default Context for scripts. This is used only for efficiency
     * reasons.
     */
    protected Context defaultContext;

    /**
     * Build a <code>Interpreter</code> for ECMAScript using Rhino.
     *
     * @param documentURL the URL for the document which references
     *
     * @see org.apache.flex.forks.batik.script.Interpreter
     * @see org.apache.flex.forks.batik.script.InterpreterPool
     */
    public RhinoInterpreter(URL documentURL) {
        try {
            rhinoClassLoader = new RhinoClassLoader
                (documentURL, getClass().getClassLoader());
        } catch (SecurityException se) {
            rhinoClassLoader = null;
        }
        ContextAction initAction = new ContextAction() {
            public Object run(Context cx) {
                Scriptable scriptable = cx.initStandardObjects(null, false);
                defineGlobalWrapperClass(scriptable);
                globalObject = createGlobalObject(cx);
                ClassCache cache = ClassCache.get(globalObject);
                cache.setCachingEnabled(rhinoClassLoader != null);
                // import Java lang package & DOM Level 3 & SVG DOM packages
                StringBuffer sb = new StringBuffer("importPackage(Packages.");
                for (int i = 0; i < TO_BE_IMPORTED.length - 1; i++) {
                    sb.append(TO_BE_IMPORTED[i]);
                    sb.append(");importPackage(Packages.");
                }
                sb.append(TO_BE_IMPORTED[TO_BE_IMPORTED.length - 1]);
                sb.append(')');
                cx.evaluateString(globalObject, sb.toString(), null, 0,
                                  rhinoClassLoader);
                return null;
            }
        };
        contextFactory.call(initAction);
    }

    /**
     * Returns the window object for this interpreter.
     */
    public Window getWindow() {
        return window;
    }

    /**
     * Returns the ContextFactory for this interpreter.
     */
    public ContextFactory getContextFactory() {
        return contextFactory;
    }

    /**
     * Defines the class for the global object.
     */
    protected void defineGlobalWrapperClass(Scriptable global) {
        try {
            ScriptableObject.defineClass(global, WindowWrapper.class);
        } catch (Exception ex) {
            // cannot happen
        }
    }

    /**
     * Creates the global object.
     */
    protected ScriptableObject createGlobalObject(Context ctx) {
        return new WindowWrapper(ctx);
    }

    /**
     * Returns the AccessControlContext associated with this Interpreter.
     * @see org.apache.flex.forks.batik.script.rhino.RhinoClassLoader
     */
    public AccessControlContext getAccessControlContext() {
        return rhinoClassLoader.getAccessControlContext();
    }

    /**
     * This method returns the ECMAScript global object used by this
     * interpreter.
     */
    protected ScriptableObject getGlobalObject() {
        return globalObject;
    }

    // org.apache.flex.forks.batik.script.Intepreter implementation

    /**
     * This method evaluates a piece of ECMAScript.
     * @param scriptreader a <code>java.io.Reader</code> on the piece of script
     * @return if no exception is thrown during the call, should return the
     * value of the last expression evaluated in the script.
     */
    public Object evaluate(Reader scriptreader) throws IOException {
        return evaluate(scriptreader, SOURCE_NAME_SVG);
    }

    /**
     * This method evaluates a piece of ECMAScript.
     * @param scriptReader a <code>java.io.Reader</code> on the piece of script
     * @param description description which can be later used (e.g., for error
     *        messages).
     * @return if no exception is thrown during the call, should return the
     * value of the last expression evaluated in the script.
     */
    public Object evaluate(final Reader scriptReader, final String description)
        throws IOException {

        ContextAction evaluateAction = new ContextAction() {
            public Object run(Context cx) {
                try {
                    return cx.evaluateReader(globalObject,
                                             scriptReader,
                                             description,
                                             1, rhinoClassLoader);
                } catch (IOException ioe) {
                    throw new WrappedException(ioe);
                }
            }
        };
        try {
            return contextFactory.call(evaluateAction);
        } catch (JavaScriptException e) {
            // exception from JavaScript (possibly wrapping a Java Ex)
            Object value = e.getValue();
            Exception ex = value instanceof Exception ? (Exception) value : e;
            throw new InterpreterException(ex, ex.getMessage(), -1, -1);
        } catch (WrappedException we) {
            Throwable w = we.getWrappedException();
            if (w instanceof Exception) {
                throw new InterpreterException
                    ((Exception) w, w.getMessage(), -1, -1);
            } else {
                throw new InterpreterException(w.getMessage(), -1, -1);
            }
        } catch (InterruptedBridgeException ibe) {
            throw ibe;
        } catch (RuntimeException re) {
            throw new InterpreterException(re, re.getMessage(), -1, -1);
        }
    }

    /**
     * This method evaluates a piece of ECMA script.
     * The first time a String is passed, it is compiled and evaluated.
     * At next call, the piece of script will only be evaluated to
     * prevent from recompiling it.
     * @param scriptStr the piece of script
     * @return if no exception is thrown during the call, should return the
     * value of the last expression evaluated in the script.
     */
    public Object evaluate(final String scriptStr) {

        ContextAction evalAction = new ContextAction() {
            public Object run(final Context cx) {
                Script script = null;
                Entry entry = null;
                Iterator it = compiledScripts.iterator();
                // between nlog(n) and log(n) because it is
                // an AbstractSequentialList
                while (it.hasNext()) {
                    if ((entry = (Entry) it.next()).str.equals(scriptStr)) {
                        // if it is not at the end, remove it because
                        // it will change from place (it is faster
                        // to remove it now)
                        script = entry.script;
                        it.remove();
                        break;
                    }
                }

                if (script == null) {
                    // this script has not been compiled yet or has been
                    // forgotten since the compilation:
                    // compile it and store it for future use.

                    PrivilegedAction compile = new PrivilegedAction() {
                        public Object run() {
                            try {
                                return cx.compileReader
                                    (new StringReader(scriptStr),
                                     SOURCE_NAME_SVG, 1, rhinoClassLoader);
                            } catch (IOException ioEx ) {
                                // Should never happen: using a string
                                throw new Error( ioEx.getMessage() );
                            }
                        }
                    };
                    script = (Script)AccessController.doPrivileged(compile);

                    if (compiledScripts.size() + 1 > MAX_CACHED_SCRIPTS) {
                        // too many cached items - we should delete the
                        // oldest entry.  all of this is very fast on
                        // linkedlist
                        compiledScripts.removeFirst();
                    }
                    // storing is done here:
                    compiledScripts.addLast(new Entry(scriptStr, script));
                } else {
                    // this script has been compiled before,
                    // just update its index so it won't get deleted soon.
                    compiledScripts.addLast(entry);
                }

                return script.exec(cx, globalObject);
            }
        };
        try {
            return contextFactory.call(evalAction);
        } catch (InterpreterException ie) {
            throw ie;
        } catch (JavaScriptException e) {
            // exception from JavaScript (possibly wrapping a Java Ex)
            Object value = e.getValue();
            Exception ex = value instanceof Exception ? (Exception) value : e;
            throw new InterpreterException(ex, ex.getMessage(), -1, -1);
        } catch (WrappedException we) {
            Throwable w = we.getWrappedException();
            if (w instanceof Exception) {
                throw new InterpreterException
                    ((Exception) w, w.getMessage(), -1, -1);
            } else {
                throw new InterpreterException(w.getMessage(), -1, -1);
            }
        } catch (RuntimeException re) {
            throw new InterpreterException(re, re.getMessage(), -1, -1);
        }
    }

    /**
     * For <code>RhinoInterpreter</code> this method flushes the
     * Rhino caches to avoid memory leaks.
     */
    public void dispose() {
        if (rhinoClassLoader != null) {
            ClassCache cache = ClassCache.get(globalObject);
            cache.setCachingEnabled(false);
        }
    }

    /**
     * This method registers a particular Java <code>Object</code> in
     * the environment of the interpreter.
     * @param name the name of the script object to create
     * @param object the Java object
     */
    public void bindObject(final String name, final Object object) {
        contextFactory.call(new ContextAction() {
            public Object run(Context cx) {
                Object o = object;
                if (name.equals(BIND_NAME_WINDOW) && object instanceof Window) {
                    ((WindowWrapper) globalObject).window = (Window) object;
                    window = (Window) object;
                    o = globalObject;
                }
                Scriptable jsObject;
                jsObject = Context.toObject(o, globalObject);
                globalObject.put(name, globalObject, jsObject);
                return null;
            }
        });
    }

    /**
     * To be used by <code>EventTargetWrapper</code>.
     */
    void callHandler(final Function handler, final Object arg) {
        contextFactory.call(new ContextAction() {
            public Object run(Context cx) {
                Object a = Context.toObject(arg, globalObject);
                Object[] args = { a };
                handler.call(cx, globalObject, globalObject, args);
                return null;
            }
        });
    }

    /**
     * To be used by <code>WindowWrapper</code>.
     */
    void callMethod(final ScriptableObject obj,
                    final String methodName,
                    final ArgumentsBuilder ab) {
        contextFactory.call(new ContextAction() {
            public Object run(Context cx) {
                ScriptableObject.callMethod
                    (obj, methodName, ab.buildArguments());
                return null;
            }
        });
    }

    /**
     * To be used by <code>WindowWrapper</code>.
     */
    void callHandler(final Function handler, final Object[] args) {
        contextFactory.call(new ContextAction() {
            public Object run(Context cx) {
                handler.call(cx, globalObject, globalObject, args);
                return null;
            }
        });
    }

    /**
     * To be used by <code>WindowWrapper</code>.
     */
    void callHandler(final Function handler, final ArgumentsBuilder ab) {
        contextFactory.call(new ContextAction() {
            public Object run(Context cx) {
                Object[] args = ab.buildArguments();
                handler.call(cx, handler.getParentScope(), globalObject, args);
                return null;
            }
        });
    }

    /**
     * To be used by <code>EventTargetWrapper</code>.
     */
    Object call(ContextAction action) {
        return contextFactory.call(action);
    }

    /**
     * To build an argument list.
     */
    public interface ArgumentsBuilder {
        Object[] buildArguments();
    }

    /**
     * Build the wrapper for objects implement <code>EventTarget</code>.
     */
    Scriptable buildEventTargetWrapper(EventTarget obj) {
        return new EventTargetWrapper(globalObject, obj, this);
    }

    /**
     * By default Rhino has no output method in its language. That's why
     * this method does nothing.
     * @param out the new out <code>Writer</code>.
     */
    public void setOut(Writer out) {
        // no implementation of a default output function in Rhino
    }

    // org.apache.flex.forks.batik.i18n.Localizable implementation

    /**
     * Returns the current locale or null if the locale currently used is
     * the default one.
     */
    public Locale getLocale() {
        // <!> TODO : in Rhino the locale is for a thread not a scope..
        return null;
    }

    /**
     * Provides a way to the user to specify a locale which override the
     * default one. If null is passed to this method, the used locale
     * becomes the global one.
     * @param locale The locale to set.
     */
    public void setLocale(Locale locale) {
        // <!> TODO : in Rhino the local is for a thread not a scope..
    }

    /**
     * Creates and returns a localized message, given the key of the message, 0, data.length
     * in the resource bundle and the message parameters.
     * The messages in the resource bundle must have the syntax described in
     * the java.text.MessageFormat class documentation.
     * @param key  The key used to retreive the message from the resource
     *             bundle.
     * @param args The objects that compose the message.
     * @exception MissingResourceException if the key is not in the bundle.
     */
    public String formatMessage(String key, Object[] args) {
        return null;
    }

    /**
     * Class to store cached compiled scripts.
     */
    protected static class Entry {

        /**
         * The script string.
         */
        public String str;

        /**
         * The compiled script.
         */
        public Script script;

        /**
         * Creates a new script cache entry object.
         */
        public Entry(String str, Script script) {
            this.str = str;
            this.script = script;
        }
    }

    /**
     * Factory for Context objects.
     */
    protected class Factory extends ContextFactory {

        /**
         * Creates a Context object for use with the interpreter.
         */
        protected Context makeContext() {
            Context cx = super.makeContext();
            cx.setWrapFactory(wrapFactory);
            cx.setSecurityController(securityController);
            cx.setClassShutter(classShutter);
            if (rhinoClassLoader == null) {
                cx.setOptimizationLevel(-1);
            }
            return cx;
        }
    }
}
