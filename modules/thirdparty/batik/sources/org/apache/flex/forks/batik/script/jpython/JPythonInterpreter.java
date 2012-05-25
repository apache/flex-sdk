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
package org.apache.flex.forks.batik.script.jpython;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.Locale;

import org.apache.flex.forks.batik.script.InterpreterException;
import org.python.util.PythonInterpreter;

/**
 * A simple implementation of <code>Interpreter</code> interface to use
 * JPython python parser.
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: JPythonInterpreter.java,v 1.10 2005/03/27 08:58:35 cam Exp $
 */
public class JPythonInterpreter implements org.apache.flex.forks.batik.script.Interpreter {
    private PythonInterpreter interpreter = null;

    public JPythonInterpreter() {
        interpreter = new PythonInterpreter();
    }

    // org.apache.flex.forks.batik.script.Intepreter implementation

    public Object evaluate(Reader scriptreader)
        throws InterpreterException, IOException {
        return evaluate(scriptreader, "");
    }

    public Object evaluate(Reader scriptreader, String description)
        throws InterpreterException, IOException {

        // oups jpython doesn't accept reader in its eval method :-(
        StringBuffer sbuffer = new StringBuffer();
        char[] buffer = new char[1024];
        int val = 0;
        while ((val = scriptreader.read(buffer)) != -1) {
            sbuffer.append(buffer,0, val);
        }
        String str = sbuffer.toString();
        return evaluate(str);
    }

    public Object evaluate(String script)
        throws InterpreterException {
        try {
            interpreter.exec(script);
        } catch (org.python.core.PyException e) {
            throw new InterpreterException(e, e.getMessage(), -1, -1);
        } catch (RuntimeException re) {
            throw new InterpreterException(re, re.getMessage(), -1, -1);
        }
        return null;
    }

    public void dispose() {
    }

    public void bindObject(String name, Object object) {
        interpreter.set(name, object);
    }

    public void setOut(Writer out) {
        interpreter.setOut(out);
    }

    // org.apache.flex.forks.batik.i18n.Localizable implementation

    public Locale getLocale() {
        return null;
    }

    public void setLocale(Locale locale) {
    }

    public String formatMessage(String key, Object[] args) {
        return null;
    }
}
