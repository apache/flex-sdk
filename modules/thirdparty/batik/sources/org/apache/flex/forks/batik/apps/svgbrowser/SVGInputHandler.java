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
 * This implementation of the <tt>SquiggleInputHandler</tt> class
 * simply displays an SVG file into the JSVGCanvas.
 *
 * @author <a mailto="vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: SVGInputHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGInputHandler implements SquiggleInputHandler {
    public static final String[] SVG_MIME_TYPES = 
    { "image/svg+xml" };

    public static final String[] SVG_FILE_EXTENSIONS =
    { ".svg", ".svgz" };

    /**
     * Returns the list of mime types handled by this handler.
     */
    public String[] getHandledMimeTypes() {
        return SVG_MIME_TYPES;
    }
    
    /**
     * Returns the list of file extensions handled by this handler
     */
    public String[] getHandledExtensions() {
        return SVG_FILE_EXTENSIONS;
    }

    /**
     * Returns a description for this handler.
     */
    public String getDescription() {
        return "";
    }

    /**
     * Handles the given input for the given JSVGViewerFrame
     */
    public void handle(ParsedURL purl, JSVGViewerFrame svgViewerFrame) {
        svgViewerFrame.getJSVGCanvas().loadSVGDocument(purl.toString());
    }

    /**
     * Returns true if the input file can be handled.
     */
    public boolean accept(File f) {
        return f != null && f.isFile() && accept(f.getPath());
    }

    /**
     * Returns true if the input URI can be handled by the handler
     */
    public boolean accept(ParsedURL purl) {
        // <!> Note: this should be improved to rely on Mime Type 
        //     when the http protocol is used. This will use the 
        //     ParsedURL.getContentType method.
        if (purl == null) {
            return false;
        }

        String path = purl.getPath();
        if (path == null) return false;

        return accept(path);
    }

    /**
     * Returns true if the resource at the given path can be handled
     */
    public boolean accept(String path) {
        if (path == null) return false;
        for (int i=0; i<SVG_FILE_EXTENSIONS.length; i++) {
            if (path.endsWith(SVG_FILE_EXTENSIONS[i])) {
                return true;
            }
        }

        return false;
    }
}
