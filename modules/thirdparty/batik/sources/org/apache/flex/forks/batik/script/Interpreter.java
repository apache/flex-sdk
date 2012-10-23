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
package org.apache.flex.forks.batik.script;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;

/**
 * An hight level interface that represents an interpreter engine of
 * a particular scripting language.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: Interpreter.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface Interpreter extends org.apache.flex.forks.batik.i18n.Localizable {

    /**
     * This method should evaluate a piece of script associated to a given 
     * description.
     *
     * @param scriptreader a <code>java.io.Reader</code> on the piece of script
     * @param description description which can be later used (e.g., for error 
     *        messages).
     * @return if no exception is thrown during the call, should return the
     * value of the last expression evaluated in the script
     */
    Object evaluate(Reader scriptreader, String description)
        throws InterpreterException, IOException;

    /**
     * This method should evaluate a piece of script.
     *
     * @param scriptreader a <code>java.io.Reader</code> on the piece of script
     * @return if no exception is thrown during the call, should return the
     * value of the last expression evaluated in the script
     */
    Object evaluate(Reader scriptreader)
        throws InterpreterException, IOException;

    /**
     * This method should evaluate a piece of script using a <code>String</code>
     * instead of a <code>Reader</code>. This usually allows do easily do some
     * caching.
     *
     * @param script the piece of script
     * @return if no exception is thrown during the call, should return the
     * value of the last expression evaluated in the script
     */
    Object evaluate(String script)
        throws InterpreterException;

    /**
     * This method should register a particular Java <code>Object</code> in
     * the environment of the interpreter.
     *
     * @param name the name of the script object to create
     * @param object the Java object
     */
    void bindObject(String name, Object object);

    /**
     * This method should change the output <code>Writer</code> that will be
     * used when output function of the scripting langage is used.
     *
     * @param output the new out <code>Writer</code>.
     */
    void setOut(Writer output);

    /**
     * This method can dispose resources used by the interpreter when it is
     * no longer used. Be careful, you SHOULD NOT use this interpreter instance
     * after calling this method.
     */
    void dispose();
}
