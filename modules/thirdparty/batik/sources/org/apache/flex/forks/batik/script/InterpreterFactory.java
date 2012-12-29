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

import java.net.URL;

/**
 * An interface for factory objects than can create {@link Interpreter}
 * instances for a particular script language.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: InterpreterFactory.java 482913 2006-12-06 05:57:52Z cam $
 */
public interface InterpreterFactory {

    /**
     * Returns the mime-types to register this interpereter with.
     */
    String[] getMimeTypes();

    /**
     * This method should create an instance of <code>Interpreter</code>
     * interface implementation.
     *
     * @param documentURL the url for the document which will be scripted
     * @param svg12 whether the document is an SVG 1.2 document
     */
    Interpreter createInterpreter(URL documentURL, boolean svg12);
}
