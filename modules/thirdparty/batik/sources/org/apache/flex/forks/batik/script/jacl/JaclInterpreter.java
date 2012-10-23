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
package org.apache.flex.forks.batik.script.jacl;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.Locale;

import org.apache.flex.forks.batik.script.InterpreterException;

import tcl.lang.Interp;
import tcl.lang.ReflectObject;
import tcl.lang.TclException;

/**
 * A simple implementation of <code>Interpreter</code> interface to use
 * JACL Tcl parser.
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: JaclInterpreter.java 475477 2006-11-15 22:44:28Z cam $
 */
public class JaclInterpreter implements org.apache.flex.forks.batik.script.Interpreter {
    private Interp interpreter = null;

    public JaclInterpreter() {
        interpreter = new Interp();
        try {
            interpreter.eval("package require java", 0);
        } catch (TclException e) {
        }
    }

    // org.apache.flex.forks.batik.script.Intepreter implementation

    public Object evaluate(Reader scriptreader) throws IOException {
        return evaluate(scriptreader, "");
    }

    public Object evaluate(Reader scriptreader, String description)
        throws IOException {
        // oops jacl doesn't accept reader in its eval method :-(
        StringBuffer sbuffer = new StringBuffer();
        char[] buffer = new char[1024];
        int val = 0;
        while ((val = scriptreader.read(buffer)) != -1) {
            sbuffer.append(buffer, 0, val);
        }
        String str = sbuffer.toString();
        return evaluate(str);
    }

    public Object evaluate(String script) {
        try {
            interpreter.eval(script, 0);
        } catch (TclException e) {
            throw new InterpreterException(e, e.getMessage(), -1, -1);
        } catch (RuntimeException re) {
            throw new InterpreterException(re, re.getMessage(), -1, -1);
        }
        return interpreter.getResult();
    }

    public void dispose() {
        interpreter.dispose();
    }

    public void bindObject(String name, Object object) {
        try {
            interpreter.
                setVar(name,
                       ReflectObject.
                       newInstance(interpreter, object.getClass(), object),
                       0);
        } catch (TclException e) {
            // should not happened we just register an object
        }
    }

    public void setOut(Writer out) {
        // no implementation of a default output function in Jacl
    }

    // org.apache.flex.forks.batik.i18n.Localizable implementation

    public Locale getLocale() {
        return Locale.getDefault();
    }

    public void setLocale(Locale locale) {
    }

    public String formatMessage(String key, Object[] args) {
        return null;
    }
}
