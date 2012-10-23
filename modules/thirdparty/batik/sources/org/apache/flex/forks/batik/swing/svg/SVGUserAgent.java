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

import org.apache.flex.forks.batik.bridge.ExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.ScriptSecurity;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.dom.Element;

/**
 * This interface must be implemented to provide client services to
 * a JSVGComponent.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGUserAgent.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SVGUserAgent {
    
    /**
     * Displays an error message.
     */
    void displayError(String message);
    
    /**
     * Displays an error resulting from the specified Exception.
     */
    void displayError(Exception ex);

    /**
     * Displays a message in the User Agent interface.
     * The given message is typically displayed in a status bar.
     */
    void displayMessage(String message);

    /**
     * Shows an alert dialog box.
     */
    void showAlert(String message);

    /**
     * Shows a prompt dialog box.
     */
    String showPrompt(String message);

    /**
     * Shows a prompt dialog box.
     */
    String showPrompt(String message, String defaultValue);

    /**
     * Shows a confirm dialog box.
     */
    boolean showConfirm(String message);

    /**
     * Returns the size of a px CSS unit in millimeters.
     */
    float getPixelUnitToMillimeter();

    /**
     * Returns the size of a px CSS unit in millimeters.
     * This will be removed after next release.
     * @see #getPixelUnitToMillimeter()
     */
    float getPixelToMM();

    /**
     * Returns the default font family.
     */
    String getDefaultFontFamily();

    /** 
     * Returns the  medium font size. 
     */
    float getMediumFontSize();

    /**
     * Returns a lighter font-weight.
     */
    float getLighterFontWeight(float f);

    /**
     * Returns a bolder font-weight.
     */
    float getBolderFontWeight(float f);

    /**
     * Returns the language settings.
     */
    String getLanguages();

    /**
     * Returns the user stylesheet uri.
     * @return null if no user style sheet was specified.
     */
    String getUserStyleSheetURI();

    /**
     * Returns the class name of the XML parser.
     */
    String getXMLParserClassName();

    /**
     * Returns true if the XML parser must be in validation mode, false
     * otherwise.
     */
    boolean isXMLParserValidating();

    /**
     * Returns this user agent's CSS media.
     */
    String getMedia();

    /**
     * Returns this user agent's alternate style-sheet title.
     */
    String getAlternateStyleSheet();

    /**
     * Opens a link in a new component.
     * @param uri The document URI.
     * @param newc Whether the link should be activated in a new component.
     */
    void openLink(String uri, boolean newc);

    /**
     * Tells whether the given extension is supported by this
     * user agent.
     */
    boolean supportExtension(String s);

    /**
     * Notifies the UserAgent that the input element 
     * has been found in the document. This is sometimes
     * called, for example, to handle &lt;a&gt; or
     * &lt;title&gt; elements in a UserAgent-dependant
     * way.
     */
    void handleElement(Element elt, Object data);


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
    ScriptSecurity getScriptSecurity(String scriptType,
                                     ParsedURL scriptURL,
                                     ParsedURL docURL);
        
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
    void checkLoadScript(String scriptType,
                         ParsedURL scriptURL,
                         ParsedURL docURL) throws SecurityException;

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
    ExternalResourceSecurity 
        getExternalResourceSecurity(ParsedURL resourceURL,
                                    ParsedURL docURL);
        
    /**
     * This method throws a SecurityException if the resource
     * found at url and referenced from docURL
     * should not be loaded.
     * 
     * This is a convenience method to call checkLoadExternalResource
     * on the ExternalResourceSecurity strategy returned by 
     * getExternalResourceSecurity.
     *
     * @param resourceURL url for the script, as defined in
     *        the resource's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     * @param docURL url for the document into which the 
     *        resource was found.
     */
    void checkLoadExternalResource(ParsedURL resourceURL,
                                   ParsedURL docURL) throws SecurityException;

}
