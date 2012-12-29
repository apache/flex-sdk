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

import org.w3c.dom.Document;

/**
 * This interface must be implemented in order to call Java code from
 * an SVG document.
 *
 * A ScriptHandler instance is called when a 'script' element's 'type'
 * attribute value is 'application/java-archive' and when the
 * manifest of the jar file referenced by the 'xlink:href' attribute
 * contains a 'Script-Handler' entry.  The value of this entry must be
 * the classname of the ScriptHandler to call.
 *
 * This classes implementing this interface must have a default
 * constructor.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ScriptHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface ScriptHandler {

    /**
     * Runs this handler.  This method is called by the SVG viewer
     * when the scripts are loaded.
     * @param doc The current document.
     * @param win An object which represents the current viewer.
     */
    void run(Document doc, Window win);
}
