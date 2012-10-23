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
package org.apache.flex.forks.batik.swing.svg;

import org.apache.flex.forks.batik.util.XMLResourceDescriptor;

import org.apache.flex.forks.batik.bridge.ExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.RelaxedExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.RelaxedScriptSecurity;
import org.apache.flex.forks.batik.bridge.ScriptSecurity;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.dom.Element;

/*
import org.apache.flex.forks.batik.bridge.DefaultExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.DefaultScriptSecurity;
import org.apache.flex.forks.batik.bridge.EmbededExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.EmbededScriptSecurity;
import org.apache.flex.forks.batik.bridge.ExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.NoLoadExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.NoLoadScriptSecurity;
*/

/**
 * This Implements the SVGUserAgent interface to provide a very simple
 * version of client services to the JSVGComponent.
 *
 * This implementation does not require any GUI interaction to work.
 * This implementation is particularly bad about user interaction
 * most of the alert,prompt,etc methods are totally useless.
 * In a GUI environment you probably want to use SVGUserAgentGUIAdapter.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: SVGUserAgentAdapter.java 478176 2006-11-22 14:50:50Z dvholten $
 */
public class SVGUserAgentAdapter implements SVGUserAgent {
    public SVGUserAgentAdapter() { }

    /**
     * Displays an error message.
     */
    public void displayError(String message) {
        System.err.println(message);
    }

    /**
     * Displays an error resulting from the specified Exception.
     */
    public void displayError(Exception ex) {
        ex.printStackTrace();
    }

    /**
     * Displays a message in the User Agent interface.
     * The given message is typically displayed in a status bar.
     */
    public void displayMessage(String message) {
        System.out.println(message);
    }

    /**
     * Shows an alert dialog box.
     */
    public void showAlert(String message) {
        System.err.println(message);
    }

    /**
     * Shows a prompt dialog box.
     */
    public String showPrompt(String message) {
        return "";
    }

    /**
     * Shows a prompt dialog box.
     */
    public String showPrompt(String message, String defaultValue) {
        return defaultValue;
    }

    /**
     * Shows a confirm dialog box.
     */
    public boolean showConfirm(String message) {
        return false;
    }

    /**
     * Returns the size of a px CSS unit in millimeters.
     */
    public float getPixelUnitToMillimeter() {
        return 0.26458333333333333333333333333333f; // 96dpi
    }

    /**
     * Returns the size of a px CSS unit in millimeters.
     * This will be removed after next release.
     * @see #getPixelUnitToMillimeter()
     */
    public float getPixelToMM() {
        return getPixelUnitToMillimeter();

    }

    /**
     * Returns the default font family.
     */
    public String getDefaultFontFamily() {
        return "Serif";
    }

    /**
     * Returns the  medium font size.
     */
    public float getMediumFontSize() {
        // 9pt (72pt == 1in)
        return 9f * 25.4f / (72f * getPixelUnitToMillimeter());
    }

    /**
     * Returns a lighter font-weight.
     */
    public float getLighterFontWeight(float f) {
        // Round f to nearest 100...
        int weight = ((int)((f+50)/100))*100;
        switch (weight) {
        case 100: return 100;
        case 200: return 100;
        case 300: return 200;
        case 400: return 300;
        case 500: return 400;
        case 600: return 400;
        case 700: return 400;
        case 800: return 400;
        case 900: return 400;
        default:
            throw new IllegalArgumentException("Bad Font Weight: " + f);
        }
    }

    /**
     * Returns a bolder font-weight.
     */
    public float getBolderFontWeight(float f) {
        // Round f to nearest 100...
        int weight = ((int)((f+50)/100))*100;
        switch (weight) {
        case 100: return 600;
        case 200: return 600;
        case 300: return 600;
        case 400: return 600;
        case 500: return 600;
        case 600: return 700;
        case 700: return 800;
        case 800: return 900;
        case 900: return 900;
        default:
            throw new IllegalArgumentException("Bad Font Weight: " + f);
        }
    }


    /**
     * Returns the language settings.
     */
    public String getLanguages() {
        return "en";
    }

    /**
     * Returns the user stylesheet uri.
     * @return null if no user style sheet was specified.
     */
    public String getUserStyleSheetURI() {
        return null;
    }

    /**
     * Returns the class name of the XML parser.
     */
    public String getXMLParserClassName() {
        return XMLResourceDescriptor.getXMLParserClassName();
    }

    /**
     * Returns true if the XML parser must be in validation mode, false
     * otherwise.
     */
    public boolean isXMLParserValidating() {
        return false;
    }

    /**
     * Returns this user agent's CSS media.
     */
    public String getMedia() {
        return "screen";
    }

    /**
     * Returns this user agent's alternate style-sheet title.
     */
    public String getAlternateStyleSheet() {
        return null;
    }

    /**
     * Opens a link.
     * @param uri The document URI.
     * @param newc Whether the link should be activated in a new component.
     */
    public void openLink(String uri, boolean newc) {
    }

    /**
     * Tells whether the given extension is supported by this
     * user agent.
     */
    public boolean supportExtension(String s) {
        return false;
    }

    public void handleElement(Element elt, Object data){
    }

    /**
     * Returns the security settings for the given script
     * type, script url and document url
     *
     * @param scriptType type of script, as found in the
     *        type attribute of the &lt;script&gt; element.
     * @param scriptURL url for the script, as defined in
     *        the script's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     * @param docURL url for the document into which the
     *        script was found.
     */
    public ScriptSecurity getScriptSecurity(String scriptType,
                                            ParsedURL scriptURL,
                                            ParsedURL docURL){
        return new RelaxedScriptSecurity(scriptType,
                                         scriptURL,
                                         docURL);
        /*
        return new DefaultScriptSecurity(scriptType,
                                         scriptURL,
                                         docURL);
        return new EmbededScriptSecurity(scriptType,
                                         scriptURL,
                                         docURL);
        return new NoLoadScriptSecurity(scriptType);
        */
    }

    /**
     * This method throws a SecurityException if the script
     * of given type, found at url and referenced from docURL
     * should not be loaded.
     *
     * This is a convenience method to call checkLoadScript
     * on the ScriptSecurity strategy returned by
     * getScriptSecurity.
     *
     * @param scriptType type of script, as found in the
     *        type attribute of the &lt;script&gt; element.
     * @param scriptURL url for the script, as defined in
     *        the script's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     * @param docURL url for the document into which the
     *        script was found.
     */
    public void checkLoadScript(String scriptType,
                                ParsedURL scriptURL,
                                ParsedURL docURL) throws SecurityException {
        ScriptSecurity s = getScriptSecurity(scriptType,
                                             scriptURL,
                                             docURL);

        if (s != null) {
            s.checkLoadScript();
        }
    }

    /**
     * Returns the security settings for the given
     * resource url and document url
     *
     * @param resourceURL url for the resource, as defined in
     *        the resource's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     * @param docURL url for the document into which the
     *        resource was found.
     */
    public ExternalResourceSecurity
        getExternalResourceSecurity(ParsedURL resourceURL,
                                    ParsedURL docURL){
        return new RelaxedExternalResourceSecurity(resourceURL,
                                                   docURL);
        /*
        return new DefaultExternalResourceSecurity(resourceURL,
                                                   docURL);
        return new EmbededExternalResourceSecurity(resourceURL);
        return new NoLoadExternalResourceSecurity();
        */
    }

    /**
     * This method throws a SecurityException if the resource
     * found at url and referenced from docURL
     * should not be loaded.
     *
     * This is a convenience method to call checkLoadExternalResource
     * on the ExternalResourceSecurity strategy returned by
     * getExternalResourceSecurity.
     *
     * @param resourceURL url for the resource, as defined in
     *        the resource's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     * @param docURL url for the document into which the
     *        resource was found.
     */
    public void
        checkLoadExternalResource(ParsedURL resourceURL,
                                  ParsedURL docURL) throws SecurityException {
        ExternalResourceSecurity s
            =  getExternalResourceSecurity(resourceURL, docURL);

        if (s != null) {
            s.checkLoadExternalResource();
        }
    }
}
