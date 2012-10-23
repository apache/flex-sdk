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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.io.File;

import org.apache.flex.forks.batik.util.ParsedURL;

/**
 * This is the interface expected from classes which can handle specific 
 * types of input for the Squiggle SVG browser. The simplest implementation
 * will simply handle SVG documents. Other, more sophisticated implementations
 * will handle other types of documents and convert them into SVG before
 * displaying them in an SVG canvas.
 *
 * @author <a mailto="vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: SquiggleInputHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SquiggleInputHandler {
    /**
     * Returns the list of mime types handled by this handler.
     */
    String[] getHandledMimeTypes();

    /**
     * Returns the list of file extensions handled by this handler
     */
    String[] getHandledExtensions();

    /**
     * Returns a description for this handler
     */
    String getDescription();

    /**
     * Returns true if the input file can be handled by the handler
     */
    boolean accept(File f);

    /**
     * Returns true if the input URI can be handled by the handler
     * @param purl URL describing the candidate input
     */
    boolean accept(ParsedURL purl);

    /**
     * Handles the given input for the given JSVGViewerFrame
     */
    void handle(ParsedURL purl, JSVGViewerFrame svgFrame) throws Exception ;
}
