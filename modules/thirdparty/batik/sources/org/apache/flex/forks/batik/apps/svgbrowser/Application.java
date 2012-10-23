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

import javax.swing.Action;

/**
 * This interface represents a SVG viewer application.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: Application.java 498290 2007-01-21 11:44:05Z cam $
 */
public interface Application {

    /**
     * Creates and shows a new viewer frame.
     */
    JSVGViewerFrame createAndShowJSVGViewerFrame();

    /**
     * Closes the given viewer frame.
     */
    void closeJSVGViewerFrame(JSVGViewerFrame f);

    /**
     * Creates an action to exit the application.
     */
    Action createExitAction(JSVGViewerFrame vf);

    /**
     * Opens the given link in a new window.
     */
    void openLink(String url);

    /**
     * Returns the XML parser class name.
     */
    String getXMLParserClassName();

    /**
     * Returns true if the XML parser must be in validation mode, false
     * otherwise.
     */
    boolean isXMLParserValidating();

    /**
     * Shows the preference dialog.
     */
    void showPreferenceDialog(JSVGViewerFrame f);

    /**
     * Returns the user languages.
     */
    String getLanguages();

    /**
     * Returns the user stylesheet uri.
     * @return null if no user style sheet was specified.
     */
    String getUserStyleSheetURI();

    /**
     * Returns the default value for the CSS
     * "font-family" property
     */
    String getDefaultFontFamily();

    /**
     * Returns the CSS media to use.
     * @return empty string if no CSS media was specified.
     */
    String getMedia();

    /**
     * Returns true if the selection overlay is painted in XOR mode, false
     * otherwise.
     */
    boolean isSelectionOverlayXORMode();

    /**
     * Returns true if the input scriptType can be loaded in
     * this application.
     */
    boolean canLoadScriptType(String scriptType);

    /**
     * Returns the allowed origins for scripts.
     * @see ResourceOrigin
     */
    int getAllowedScriptOrigin();

    /**
     * Returns the allowed origins for external
     * resources. 
     *
     * @see ResourceOrigin
     */
    int getAllowedExternalResourceOrigin();

    /**
     * Notifies Application of recently visited URI
     */
    void addVisitedURI(String uri);

    /**
     * Asks Application for a list of recently visited URI
     */
    String[] getVisitedURIs();

    /**
     * Returns the UI resource specialization to use.
     */
    String getUISpecialization();
}
