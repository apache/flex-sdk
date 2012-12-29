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
package org.apache.flex.forks.batik.bridge;

import java.awt.Cursor;
import java.awt.Point;
import java.awt.geom.AffineTransform;
import java.awt.geom.Dimension2D;

import org.apache.flex.forks.batik.gvt.event.EventDispatcher;
import org.apache.flex.forks.batik.gvt.text.Mark;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGAElement;
import org.w3c.dom.svg.SVGDocument;

/**
 * An interface that provides access to the User Agent informations
 * needed by the bridge.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: UserAgent.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface UserAgent {

    // <!> FIXME: TO BE REMOVED
    /**
     * Returns the event dispatcher to use.
     */
    EventDispatcher getEventDispatcher();

    /**
     * Returns the default size of the viewport.
     */
    Dimension2D getViewportSize();

    /**
     * Displays an error resulting from the specified Exception.
     */
    void displayError(Exception ex);

    /**
     * Displays a message in the User Agent interface.
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
     * Returns the default font family.
     */
    String getDefaultFontFamily();

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
     * Opens a link.
     * @param elt The activated link element.
     */
    void openLink(SVGAElement elt);

    /**
     * Informs the user agent to change the cursor.
     * @param cursor the new cursor
     */
    void setSVGCursor(Cursor cursor);

    /**
     * Informs the user agent that the text selection has changed.
     * @param start The Mark for the start of the selection.
     * @param end   The Mark for the end of the selection.
     */
    void setTextSelection(Mark start, Mark end);

    /**
     * Informs the user agent that the text selection should be cleared.
     */
    void deselectAll();

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
     * Returns the <code>AffineTransform</code> currently
     * applied to the drawing by the UserAgent.
     */
    AffineTransform getTransform();

    /**
     * Sets the <code>AffineTransform</code> currently
     * applied to the drawing by the UserAgent.
     */
    void setTransform(AffineTransform at);

    /**
     * Returns this user agent's CSS media.
     */
    String getMedia();

    /**
     * Returns this user agent's alternate style-sheet title.
     */
    String getAlternateStyleSheet();

    /**
     * Returns the location on the screen of the
     * client area in the UserAgent.
     */
    Point getClientAreaLocationOnScreen();

    /**
     * Tells whether the given feature is supported by this
     * user agent.
     */
    boolean hasFeature(String s);

    /**
     * Tells whether the given extension is supported by this
     * user agent.
     */
    boolean supportExtension(String s);

    /**
     * Lets the bridge tell the user agent that the following
     * extension is supported by the bridge.
     */
    void registerExtension(BridgeExtension ext);

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
     * Returns the security settings for the given resource
     * url and document url
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
     * @param resourceURL url for the resource, as defined in
     *        the resource's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     * @param docURL url for the document into which the 
     *        resource was found.
     */
    void checkLoadExternalResource(ParsedURL resourceURL,
                                   ParsedURL docURL) throws SecurityException;


    /**
     * This method should return an image to be displayed when an image
     * can't be loaded.  If it returns 'null' then a BridgeException will
     * be thrown.
     *
     * @param e   The &lt;image> element that can't be loaded.
     * @param url The resolved url that can't be loaded.
     * @param message As best as can be determined the reason it can't be
     *                loaded (not available, corrupt, unknown format, ...).
     */
    SVGDocument getBrokenLinkDocument(Element e, String url, String message);
}
